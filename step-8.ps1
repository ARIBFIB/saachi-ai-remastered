$ErrorActionPreference = "Stop"
$root = Get-Location

$webDir = Join-Path $root "apps\web"
$uiDir = Join-Path $webDir "components\ui"
$libDir = Join-Path $webDir "lib"
$pkgJsonPath = Join-Path $webDir "package.json"
$homePath = Join-Path $webDir "app\(marketing)\page.tsx"

foreach ($p in @($webDir, $pkgJsonPath, $homePath)) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Error "Not found: $p -- run this script from the SAI2 root."
        exit 1
    }
}

New-Item -ItemType Directory -Path $uiDir -Force | Out-Null
New-Item -ItemType Directory -Path $libDir -Force | Out-Null

$backupDir = Join-Path $root "theme-migration-backup\step8"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item -LiteralPath $pkgJsonPath -Destination (Join-Path $backupDir "package.json.bak") -Force
Copy-Item -LiteralPath $homePath -Destination (Join-Path $backupDir "page.tsx.bak") -Force
Write-Host "Backups saved to: $backupDir"
Write-Host ""

# ---------------------------------------------------------------------------
# 1. lib/utils.ts -- shadcn's cn() helper (clsx + tailwind-merge, both
#    already in apps/web's package.json dependencies)
# ---------------------------------------------------------------------------
$utilsContent = @'
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
'@
Set-Content -LiteralPath (Join-Path $libDir "utils.ts") -Value $utilsContent -Encoding UTF8
Write-Host "Created: lib/utils.ts"

# ---------------------------------------------------------------------------
# 2. components/ui/coverflow-carousel.tsx
#    (shadcn foreground/background/muted tokens mapped to our tokens)
# ---------------------------------------------------------------------------
$coverflowContent = @'
"use client";

import * as React from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

import { cn } from "@/lib/utils";

const useIsoLayoutEffect =
  typeof window !== "undefined" ? React.useLayoutEffect : React.useEffect;

export interface CoverflowSlide {
  src: string;
  alt: string;
  title?: string;
  subtitle?: string;
  meta?: { label: string; value: string }[];
}

export interface CoverflowCarouselProps {
  slides: CoverflowSlide[];
  rotate?: number;
  depth?: number;
  perspective?: number;
  falloff?: number;
  fade?: number;
  cardWidth?: string;
  gap?: number;
  loop?: boolean;
  showCaption?: boolean;
  showPagination?: boolean;
  showNavigation?: boolean;
  label?: string;
  className?: string;
  cardClassName?: string;
}

export function CoverflowCarousel({
  slides,
  rotate = 44,
  depth = 0.6,
  perspective = 3,
  falloff = 0.56,
  fade = 0.1,
  cardWidth = "clamp(148px, 22vw, 260px)",
  gap = 0.05,
  loop = true,
  showCaption = false,
  showPagination = false,
  showNavigation = false,
  label = "Cover carousel",
  className,
  cardClassName
}: CoverflowCarouselProps) {
  const count = slides.length;

  const frameRef = React.useRef<HTMLDivElement>(null);
  const cardRefs = React.useRef<(HTMLDivElement | null)[]>([]);
  const posRef = React.useRef(0);
  const targetRef = React.useRef(0);
  const widthRef = React.useRef(0);
  const rafRef = React.useRef<number | null>(null);
  const dragRef = React.useRef<{ id: number; x: number; pos: number; v: number; t: number } | null>(null);

  const [selected, setSelected] = React.useState(0);

  const indexAt = React.useCallback((pos: number) => ((Math.round(pos) % count) + count) % count, [count]);

  const paint = React.useCallback(() => {
    const width = widthRef.current;
    if (!width) return;
    const pitch = width * (1 + gap);
    const pos = posRef.current;

    cardRefs.current.forEach((card, index) => {
      if (!card) return;
      let offset = index - pos;
      if (loop) {
        offset = ((offset % count) + count) % count;
        if (offset > count / 2) offset -= count;
      }
      const distance = Math.abs(offset);
      const ramp = Math.pow(distance, falloff);
      const tilt = Math.min(rotate * ramp, 82) * Math.sign(offset);

      card.style.transform =
        `translateX(calc(-50% + ${offset * pitch}px)) ` +
        `translateZ(${-depth * width * ramp}px) rotateY(${-tilt}deg)`;

      const edge = loop ? Math.min(1, Math.max(0, count / 2 - distance)) : 1;
      card.style.opacity = String(Math.max(0, 1 - fade * distance) * edge);
      card.style.zIndex = String(100 - Math.round(distance));
    });
  }, [count, depth, fade, falloff, gap, loop, rotate]);

  const settle = React.useCallback(
    (target: number) => {
      if (rafRef.current !== null) cancelAnimationFrame(rafRef.current);
      targetRef.current = target;
      setSelected(indexAt(target));

      const step = () => {
        const remaining = target - posRef.current;
        if (Math.abs(remaining) < 0.0004) {
          posRef.current = target;
          paint();
          rafRef.current = null;
          return;
        }
        posRef.current += remaining * 0.16;
        paint();
        rafRef.current = requestAnimationFrame(step);
      };
      rafRef.current = requestAnimationFrame(step);
    },
    [indexAt, paint]
  );

  const clamp = React.useCallback((pos: number) => (loop ? pos : Math.max(0, Math.min(count - 1, pos))), [count, loop]);

  const goTo = React.useCallback(
    (index: number) => {
      const target = loop ? index + Math.round((targetRef.current - index) / count) * count : index;
      settle(clamp(target));
    },
    [clamp, count, loop, settle]
  );

  const nudge = React.useCallback((by: number) => settle(clamp(Math.round(targetRef.current) + by)), [clamp, settle]);

  const onPointerDown = (event: React.PointerEvent<HTMLDivElement>) => {
    if (rafRef.current !== null) {
      cancelAnimationFrame(rafRef.current);
      rafRef.current = null;
    }
    event.currentTarget.setPointerCapture(event.pointerId);
    targetRef.current = posRef.current;
    dragRef.current = { id: event.pointerId, x: event.clientX, pos: posRef.current, v: 0, t: performance.now() };
  };

  const onPointerMove = (event: React.PointerEvent<HTMLDivElement>) => {
    const drag = dragRef.current;
    if (!drag || drag.id !== event.pointerId) return;

    const pitch = widthRef.current * (1 + gap);
    if (!pitch) return;

    const now = performance.now();
    const previous = posRef.current;
    posRef.current = clamp(drag.pos - (event.clientX - drag.x) / pitch);
    drag.v = ((posRef.current - previous) / Math.max(now - drag.t, 1)) * 1000;
    drag.t = now;

    const index = indexAt(posRef.current);
    if (index !== selected) setSelected(index);
    paint();
  };

  const endDrag = (event: React.PointerEvent<HTMLDivElement>) => {
    const drag = dragRef.current;
    if (!drag || drag.id !== event.pointerId) return;
    dragRef.current = null;
    const carried = Math.max(-2, Math.min(2, drag.v * 0.18));
    settle(clamp(Math.round(posRef.current + carried)));
  };

  useIsoLayoutEffect(() => {
    const frame = frameRef.current;
    if (!frame) return;

    const measure = () => {
      const card = cardRefs.current[0];
      if (!card) return;
      widthRef.current = card.offsetWidth;
      paint();
    };

    measure();
    const observer = new ResizeObserver(measure);
    observer.observe(frame);
    return () => observer.disconnect();
  }, [paint]);

  React.useEffect(
    () => () => {
      if (rafRef.current !== null) cancelAnimationFrame(rafRef.current);
    },
    []
  );

  const active = slides[selected];

  return (
    <div className={cn("w-full", className)} style={{ ["--cf-card" as string]: cardWidth }} role="region" aria-roledescription="carousel" aria-label={label}>
      <div className="relative">
        <div
          ref={frameRef}
          tabIndex={0}
          onPointerDown={onPointerDown}
          onPointerMove={onPointerMove}
          onPointerUp={endDrag}
          onPointerCancel={endDrag}
          onKeyDown={(event) => {
            if (event.key === "ArrowLeft") {
              event.preventDefault();
              nudge(-1);
            } else if (event.key === "ArrowRight") {
              event.preventDefault();
              nudge(1);
            }
          }}
          className="cursor-grab overflow-hidden py-10 outline-none ring-accent-violet focus-visible:ring-2 active:cursor-grabbing"
          style={{ perspective: `calc(var(--cf-card) * ${perspective})`, touchAction: "pan-y" }}
        >
          <div className="relative select-none" style={{ height: "var(--cf-card)", transformStyle: "preserve-3d" }}>
            {slides.map((slide, index) => (
              <div
                key={index}
                ref={(node) => {
                  cardRefs.current[index] = node;
                }}
                role="group"
                aria-roledescription="slide"
                aria-label={`${index + 1} of ${count}`}
                className={cn("absolute left-1/2 top-0 aspect-square overflow-hidden rounded-2xl bg-paper-dim shadow-xl will-change-transform", cardClassName)}
                style={{ width: "var(--cf-card)" }}
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={slide.src} alt={slide.alt} draggable={false} className="h-full w-full select-none object-cover" />
              </div>
            ))}
          </div>
        </div>

        {showNavigation && (
          <>
            <button
              type="button"
              aria-label="Previous slide"
              onClick={() => nudge(-1)}
              className="absolute left-3 top-1/2 z-[200] -translate-y-1/2 rounded-full bg-card/80 p-2 text-ink backdrop-blur transition hover:bg-card"
            >
              <ChevronLeft className="size-5" />
            </button>
            <button
              type="button"
              aria-label="Next slide"
              onClick={() => nudge(1)}
              className="absolute right-3 top-1/2 z-[200] -translate-y-1/2 rounded-full bg-card/80 p-2 text-ink backdrop-blur transition hover:bg-card"
            >
              <ChevronRight className="size-5" />
            </button>
          </>
        )}
      </div>

      {showCaption && active?.title && (
        <div key={selected} className="mt-2 flex flex-col items-center px-6 duration-300 animate-in fade-in">
          <p className="text-[15px] font-semibold tracking-tight text-ink">{active.title}</p>
          {active.subtitle && <p className="mt-1 text-[13px] text-ink-soft">{active.subtitle}</p>}
          {active.meta && active.meta.length > 0 && (
            <dl className="mt-6 w-full max-w-[230px] text-[12px]">
              {active.meta.map((row) => (
                <div key={row.label} className="flex justify-between py-[5px]">
                  <dt className="text-ink-soft">{row.label}</dt>
                  <dd className="font-medium text-ink">{row.value}</dd>
                </div>
              ))}
            </dl>
          )}
        </div>
      )}

      {showPagination && (
        <div className="mt-6 flex items-center justify-center gap-2">
          {slides.map((_, index) => (
            <button
              key={index}
              type="button"
              aria-label={`Go to slide ${index + 1}`}
              aria-current={index === selected}
              onClick={() => goTo(index)}
              className={cn("size-2 rounded-full bg-ink transition-opacity", index === selected ? "opacity-100" : "opacity-30")}
            />
          ))}
        </div>
      )}
    </div>
  );
}
'@
Set-Content -LiteralPath (Join-Path $uiDir "coverflow-carousel.tsx") -Value $coverflowContent -Encoding UTF8
Write-Host "Created: components/ui/coverflow-carousel.tsx"

# ---------------------------------------------------------------------------
# 3. components/ui/image-stream-hero.tsx (theme-agnostic, used as-is)
# ---------------------------------------------------------------------------
$streamContent = @'
"use client";

import * as React from "react";
import { cn } from "@/lib/utils";

export type CorridorPath = {
  perspective?: number;
  cardWidth?: number;
  cardHeight?: number;
  cardRadius?: number;
  birthHeight?: number;
  exitHeight?: number;
  railBirth?: number;
  railExit?: number;
  fan?: number;
  turnBirth?: number;
  turnExit?: number;
  stops?: number;
};

const PATH: Required<CorridorPath> = {
  perspective: 30,
  cardWidth: 18,
  cardHeight: 25,
  cardRadius: 0.4,
  birthHeight: 2.6,
  exitHeight: 46,
  railBirth: -11,
  railExit: 44,
  fan: 3.3,
  turnBirth: 6,
  turnExit: 28,
  stops: 24
};

function keyframes(dir: 1 | -1, name: string, p: Required<CorridorPath>) {
  const steps: string[] = [];
  for (let s = 0; s <= p.stops; s++) {
    const u = s / p.stops;
    const scale = (p.birthHeight / p.cardHeight) * Math.pow(p.exitHeight / p.birthHeight, u);
    const z = p.perspective * (1 - 1 / scale);
    const rail = p.railExit - (p.railExit - p.railBirth) * Math.pow(1 - u, p.fan);
    const turn = p.turnBirth + (p.turnExit - p.turnBirth) * u;
    steps.push(
      `${(u * 100).toFixed(2)}%{transform:translate3d(${(dir * rail).toFixed(2)}cqw,0,${z.toFixed(2)}cqw) rotateY(${(-dir * turn).toFixed(2)}deg)}`
    );
  }
  return `@keyframes ${name}{${steps.join("")}}`;
}

export type StreamImage = { src: string; alt?: string };

export type ImageStreamHeroProps = {
  images: StreamImage[];
  cards?: number;
  speed?: number;
  axis?: number;
  path?: CorridorPath;
  children?: React.ReactNode;
  className?: string;
};

export function ImageStreamHero({ images, cards = 9, speed = 18, axis = 55, path, children, className, ...props }: React.ComponentProps<"div"> & ImageStreamHeroProps) {
  const id = React.useId().replace(/[^a-zA-Z0-9]/g, "");
  const right = `ish-r-${id}`;
  const left = `ish-l-${id}`;
  const card = `ish-c-${id}`;

  const p = React.useMemo(() => ({ ...PATH, ...path }), [path]);

  const css = React.useMemo(
    () =>
      `${keyframes(1, right, p)}${keyframes(-1, left, p)}` +
      `@media(prefers-reduced-motion:reduce){.${card}{animation-play-state:paused}}`,
    [right, left, card, p]
  );

  return (
    <div className={cn("relative overflow-hidden", className)} {...props} style={{ containerType: "inline-size", ...props.style }}>
      <style>{css}</style>

      <div aria-hidden className="pointer-events-none absolute inset-0" style={{ perspective: `${p.perspective}cqw`, perspectiveOrigin: `50% ${axis}%` }}>
        <div className="absolute inset-0" style={{ transformStyle: "preserve-3d" }}>
          {[right, left].map((name) =>
            Array.from({ length: cards }, (_, i) => {
              const img = images[i % Math.max(images.length, 1)];
              return (
                <div
                  key={`${name}-${i}`}
                  className={cn(card, "absolute overflow-hidden")}
                  style={{
                    left: "50%",
                    top: `${axis}%`,
                    width: `${p.cardWidth}cqw`,
                    height: `${p.cardHeight}cqw`,
                    marginLeft: `${-p.cardWidth / 2}cqw`,
                    marginTop: `${-p.cardHeight / 2}cqw`,
                    borderRadius: `${p.cardRadius}cqw`,
                    animation: `${name} ${speed}s linear infinite`,
                    animationDelay: `${-(i * speed) / cards}s`,
                    backfaceVisibility: "hidden"
                  }}
                >
                  {img ? (
                    <img src={img.src} alt={img.alt ?? ""} loading="lazy" decoding="async" className="h-full w-full object-cover" draggable={false} />
                  ) : null}
                </div>
              );
            })
          )}
        </div>
      </div>

      {children}
    </div>
  );
}

export default ImageStreamHero;
'@
Set-Content -LiteralPath (Join-Path $uiDir "image-stream-hero.tsx") -Value $streamContent -Encoding UTF8
Write-Host "Created: components/ui/image-stream-hero.tsx"

# ---------------------------------------------------------------------------
# 4. components/ui/how-it-works.tsx
#    (white/black/orange/blue/purple hardcodes swapped for our tokens;
#     uses motion/react for the animated connector path)
# ---------------------------------------------------------------------------
$howItWorksContent = @'
"use client";

import React from "react";
import { LazyMotion, domAnimation, m } from "motion/react";

interface CardProps {
  number: string;
  title: string;
  description: string;
  className?: string;
  rotate?: string;
  colors?: { bg: string; text: string; border: string };
}

const Pin = ({ className }: { className?: string }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="currentColor" className={className}>
    <path stroke="none" d="M0 0h24v24H0z" fill="none" />
    <path d="M16 3a1 1 0 0 1 .117 1.993l-.117 .007v4.764l1.894 3.789a1 1 0 0 1 .1 .331l.006 .116v2a1 1 0 0 1 -.883 .993l-.117 .007h-4v4a1 1 0 0 1 -1.993 .117l-.007 -.117v-4h-4a1 1 0 0 1 -.993 -.883l-.007 -.117v-2a1 1 0 0 1 .06 -.34l.046 -.107l1.894 -3.791v-4.762a1 1 0 0 1 -.117 -1.993l.117 -.007h8z" />
  </svg>
);

const DEFAULT_PALETTE = { bg: "bg-gold-tint", text: "text-accent-violet", border: "border-line-strong" };

const Card = ({ number, title, description, className, rotate, colors }: CardProps) => {
  const c = colors ?? DEFAULT_PALETTE;

  return (
    <div className={`relative w-full md:w-[280px] transition-transform duration-300 hover:z-30 hover:scale-105 ${rotate ?? ""} ${className ?? ""}`}>
      <div className="bg-card p-2 rounded-[25px] shadow-[0px_10px_20px_0px_rgba(124,58,237,0.12)] border border-line">
        <Pin className={`w-8 h-8 ${c.text} z-20 mb-6 mx-auto`} />
        <div className={`${c.bg} border ${c.border} rounded-[15px] p-[15px] h-full flex flex-col relative overflow-hidden`}>
          <span className={`${c.text} text-4xl font-bold mb-5`}>{number}</span>
          <h3 className="text-2xl font-semibold text-ink leading-none mb-[10px]">{title}</h3>
          <p className="text-ink-soft text-sm/5 tracking-tight">{description}</p>
        </div>
      </div>
    </div>
  );
};

export interface Step {
  title: string;
  description: string;
  colors?: { bg: string; text: string; border: string };
}

export interface StepPosition {
  className?: string;
  rotate?: string;
}

export interface HowItWorksProps {
  features?: Step[];
  className?: string;
  stepPositions?: StepPosition[];
}

const DEFAULT_CARD_POSITIONS: StepPosition[] = [
  { className: "md:absolute md:top-0 md:left-[15%]", rotate: "rotate-8" },
  { className: "md:absolute md:top-[120px] md:right-[15%]", rotate: "-rotate-8" },
  { className: "md:absolute md:top-[450px] md:left-[15%]", rotate: "rotate-8" },
  { className: "md:absolute md:top-[570px] md:right-[10%]", rotate: "-rotate-8" },
  { className: "md:absolute md:top-[850px] md:left-[15%]", rotate: "rotate-8" }
];

export default function HowItWorks({ features, className, stepPositions }: HowItWorksProps) {
  const defaultFeatures: Step[] = [
    { title: "Create account", description: "Sign up in minutes and pick learner or instructor." },
    { title: "Pick a skill", description: "Browse 1,200+ practical AI courses across every category." },
    { title: "Learn by building", description: "Every course ships real templates and projects, not just video." },
    { title: "Get certified", description: "Finish a course and earn a shareable completion certificate." },
    { title: "Earn or teach", description: "Turn what you learned into freelance work, or publish your own course." }
  ];

  const data = features && features.length > 0 ? features : defaultFeatures;
  const positions = stepPositions || DEFAULT_CARD_POSITIONS;

  let height = 1130;
  if (data.length === 1) height = 400;
  else if (data.length === 2) height = 450;
  else if (data.length === 3) height = 800;
  else if (data.length === 4) height = 900;
  else height = 1130;

  return (
    <LazyMotion features={domAnimation}>
      <div className={`bg-paper max-md:pt-10 max-md:pb-25 md:py-20 px-8 relative ${className ?? ""}`}>
        <div
          className="absolute inset-0 pointer-events-none opacity-[0.06]"
          style={{ backgroundImage: "linear-gradient(var(--color-ink) 1px, transparent 1px)", backgroundSize: "100% 32px", marginTop: "4px" }}
        />
        <div className="from-paper pointer-events-none absolute inset-y-0 left-0 w-1/2 bg-gradient-to-r" />
        <div className="from-paper pointer-events-none absolute inset-y-0 right-0 w-1/2 bg-gradient-to-l" />

        <div className="max-w-6xl mx-auto relative z-10">
          <div
            className="relative w-full max-w-[1000px] mx-auto flex flex-col space-y-8 md:space-y-0 md:block h-auto md:h-[var(--md-height)]"
            style={{ "--md-height": `${height}px` } as React.CSSProperties}
          >
            {data.length > 1 && (
              <svg className="absolute top-0 left-0 w-full h-full pointer-events-none hidden md:block z-0" viewBox={`0 0 1000 ${height}`} preserveAspectRatio="none">
                {(() => {
                  const pathD = data.reduce((acc, _, index) => {
                    if (index >= data.length - 1) return acc;
                    if (index === 0) return "M 290 150 C 500 150, 550 270, 710 270";
                    if (index === 1) return acc + " C 850 270, 500 350, 290 450";
                    if (index === 2) return acc + " C 290 600, 550 720, 750 720";
                    if (index === 3) return acc + " C 950 720, 500 800, 290 850";
                    return acc;
                  }, "");
                  return (
                    <m.path
                      d={pathD}
                      stroke="currentColor"
                      className="text-line-strong"
                      strokeWidth="2"
                      strokeDasharray="8 6"
                      fill="none"
                      strokeLinecap="round"
                      vectorEffect="non-scaling-stroke"
                      initial={{ strokeDashoffset: 0 }}
                      animate={{ strokeDashoffset: -140 }}
                      transition={{ duration: 3, repeat: Infinity, ease: "linear" }}
                    />
                  );
                })()}
              </svg>
            )}

            {data.map((step, index) => {
              const position = positions[index % positions.length];
              return (
                <Card
                  key={step.title}
                  number={`0${index + 1}`}
                  title={step.title}
                  description={step.description}
                  colors={step.colors}
                  rotate={position.rotate}
                  className={position.className}
                />
              );
            })}
          </div>
        </div>
      </div>
    </LazyMotion>
  );
}
'@
Set-Content -LiteralPath (Join-Path $uiDir "how-it-works.tsx") -Value $howItWorksContent -Encoding UTF8
Write-Host "Created: components/ui/how-it-works.tsx"

# ---------------------------------------------------------------------------
# 5. Add "motion" dependency to apps/web/package.json (regex-based, keeps
#    whatever indentation style the file already uses)
# ---------------------------------------------------------------------------
$pkgContent = Get-Content -LiteralPath $pkgJsonPath -Raw
if ($pkgContent -notmatch '"motion"\s*:') {
    $pattern = '([ \t]*)"lucide-react"\s*:\s*"[^"]*",?\s*\r?\n'
    $match = [regex]::Match($pkgContent, $pattern)
    if ($match.Success) {
        $indent = $match.Groups[1].Value
        $insertion = $match.Value + $indent + '"motion": "^11.15.0",' + "`r`n"
        $pkgContent = $pkgContent.Substring(0, $match.Index) + $insertion + $pkgContent.Substring($match.Index + $match.Length)
        Set-Content -LiteralPath $pkgJsonPath -Value $pkgContent -Encoding UTF8 -NoNewline
        Write-Host "OK -- added 'motion' dependency to apps\web\package.json"
    } else {
        Write-Host "SKIPPED -- could not find 'lucide-react' line in package.json to anchor the insertion."
        Write-Host "Add manually: `"motion`": `"^11.15.0`","
    }
} else {
    Write-Host "SKIPPED -- 'motion' dependency already present in package.json"
}

# ---------------------------------------------------------------------------
# 6. Wire the components into the landing page
# ---------------------------------------------------------------------------
$homeContent = Get-Content -LiteralPath $homePath -Raw

# 6a. Imports
$oldImports = 'import { Reveal } from "./_components/Reveal";
import { LandingSearch } from "./_components/LandingSearch";
import { FaqAccordion } from "./_components/FaqAccordion";'
$newImports = 'import { Reveal } from "./_components/Reveal";
import { LandingSearch } from "./_components/LandingSearch";
import { FaqAccordion } from "./_components/FaqAccordion";
import { CoverflowCarousel } from "@/components/ui/coverflow-carousel";
import { ImageStreamHero } from "@/components/ui/image-stream-hero";
import HowItWorks from "@/components/ui/how-it-works";'

if ($homeContent.Contains($oldImports)) {
    $homeContent = $homeContent.Replace($oldImports, $newImports)
    Write-Host "OK -- page.tsx: added component imports"
} else {
    Write-Host "SKIPPED -- import block not found verbatim in page.tsx (may already differ)."
}

# 6b. Replace the old static "How it works" 3-card section with <HowItWorks />
$oldHowItWorks = @'
      {/* How it works */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">How Saachi AI works</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Three steps from curious to capable.</p>
        </Reveal>
        <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
          {HOW_IT_WORKS.map((step, i) => (
            <Reveal key={step.title} delay={i * 100}>
              <div className="h-full rounded-card border border-line bg-card p-6">
                <div
                  className="mb-4 flex h-11 w-11 items-center justify-center rounded-full text-white"
                  style={{ backgroundImage: "var(--color-accent-gradient)" }}
                >
                  <step.icon size={20} />
                </div>
                <h3 className="mb-1.5 text-[16px] font-semibold text-ink">{step.title}</h3>
                <p className="text-[13.5px] leading-relaxed text-ink-soft">{step.desc}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>
'@
$newHowItWorks = @'
      {/* How it works */}
      <Reveal>
        <HowItWorks />
      </Reveal>
'@

if ($homeContent.Contains($oldHowItWorks)) {
    $homeContent = $homeContent.Replace($oldHowItWorks, $newHowItWorks)
    Write-Host "OK -- page.tsx: replaced static How-it-works grid with animated HowItWorks component"
} else {
    Write-Host "SKIPPED -- old How-it-works section not found verbatim (may already differ)."
}

# 6c. Replace the "Popular instructors" grid with a CoverflowCarousel
$oldInstructors = @'
      {/* Popular instructors */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Learn from top instructors</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Verified practitioners, not just presenters.</p>
        </Reveal>
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-6">
          {INSTRUCTORS.map((inst, i) => (
            <Reveal key={inst.name} delay={i * 50}>
              <div className="flex flex-col items-center rounded-card border border-line bg-card p-4 text-center transition-transform hover:-translate-y-1">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={inst.avatar}
                  alt={inst.name}
                  className="mb-3 h-16 w-16 rounded-full border-2 border-line object-cover"
                />
                <p className="truncate text-[13px] font-semibold text-ink">{inst.name}</p>
                <p className="truncate text-[11.5px] text-ink-soft">{inst.role}</p>
                <span className="mt-2 flex items-center gap-1 text-[11px] font-medium text-accent-violet">
                  <Users size={11} />
                  {inst.students} students
                </span>
              </div>
            </Reveal>
          ))}
        </div>
      </section>
'@
$newInstructors = @'
      {/* Popular instructors -- coverflow */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Learn from top instructors</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Verified practitioners, not just presenters. Drag to browse.</p>
        </Reveal>
        <Reveal delay={100}>
          <CoverflowCarousel
            showCaption
            showNavigation
            label="Top instructors"
            slides={INSTRUCTORS.map((inst) => ({
              src: inst.avatar,
              alt: inst.name,
              title: inst.name,
              subtitle: inst.role,
              meta: [{ label: "Students", value: inst.students }]
            }))}
          />
        </Reveal>
      </section>
'@

if ($homeContent.Contains($oldInstructors)) {
    $homeContent = $homeContent.Replace($oldInstructors, $newInstructors)
    Write-Host "OK -- page.tsx: replaced instructor grid with CoverflowCarousel"
} else {
    Write-Host "SKIPPED -- old instructors section not found verbatim (may already differ)."
}

# 6d. Insert an ImageStreamHero "spotlight" section right before the FAQ section
$anchorFaq = '      {/* FAQ */}'
$streamSection = @'
      {/* Course spotlight stream */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <ImageStreamHero
            className="h-[420px] w-full rounded-card border border-line bg-paper-dim"
            images={[
              { src: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=480&fit=crop&q=70&auto=format", alt: "AI automation workspace" },
              { src: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=480&fit=crop&q=70&auto=format", alt: "Developer working with AI tools" },
              { src: "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=480&fit=crop&q=70&auto=format", alt: "Analytics dashboard" },
              { src: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=480&h=480&fit=crop&q=70&auto=format", alt: "Team collaborating" },
              { src: "https://images.unsplash.com/photo-1550439062-609e1531270e?w=480&h=480&fit=crop&q=70&auto=format", alt: "Whiteboard planning session" },
              { src: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=480&h=480&fit=crop&q=70&auto=format", alt: "Remote work setup" }
            ]}
          >
            <div className="relative z-10 flex h-full flex-col items-center justify-between py-10 text-center">
              <div className="px-6">
                <h2 className="text-balance font-display text-[28px] font-bold text-ink md:text-[36px]">
                  Every course, built around real work.
                </h2>
              </div>
              <p className="max-w-md text-balance px-6 text-[13.5px] text-ink-soft">
                Screenshots, templates, and workflows straight from working AI practitioners -- not stock slides.
              </p>
            </div>
          </ImageStreamHero>
        </Reveal>
      </section>

'@

if ($homeContent.Contains($anchorFaq) -and -not $homeContent.Contains("Course spotlight stream")) {
    $homeContent = $homeContent.Replace($anchorFaq, ($streamSection + $anchorFaq))
    Write-Host "OK -- page.tsx: inserted ImageStreamHero course-spotlight section before FAQ"
} elseif ($homeContent.Contains("Course spotlight stream")) {
    Write-Host "SKIPPED -- ImageStreamHero section already present."
} else {
    Write-Host "SKIPPED -- FAQ anchor not found verbatim, could not insert ImageStreamHero section."
}

Set-Content -LiteralPath $homePath -Value $homeContent -Encoding UTF8 -NoNewline
Write-Host ""
Write-Host "Step 8 file writes complete."
Write-Host ""
Write-Host "IMPORTANT -- one more command needed (package.json changed):"
Write-Host "  pnpm install"
Write-Host "Then:"
Write-Host "  pnpm --filter web build"