<#
============================================================================
 Enhance-LandingPage.ps1
 Saachi AI (SAI2) - Landing Page Overhaul
----------------------------------------------------------------------------
 Run from the repo root:
     PS D:\...\SAI2> .\Enhance-LandingPage.ps1

 What it does:
   1. Backs up apps\web\app\(marketing)\page.tsx  -> page.tsx.bak-<timestamp>
   2. Adds apps\web\components\ui\border-beam-panel.tsx
   3. Adds several new landing-page section components under
      apps\web\app\(marketing)\_components\
   4. Adds a fake-data file for all the dummy content
   5. Rewrites page.tsx to wire everything together

 Safe to re-run: existing page.tsx is always backed up first, and new
 component files are overwritten (not appended) so you get a clean state.
============================================================================
#>

$ErrorActionPreference = "Stop"

$Root      = $PSScriptRoot
if (-not $Root) { $Root = Get-Location }

$WebApp    = Join-Path $Root "apps\web"
$AppDir    = Join-Path $WebApp "app"
$MktDir    = Join-Path $AppDir "(marketing)"
$MktComp   = Join-Path $MktDir "_components"
$UiDir     = Join-Path $WebApp "components\ui"

foreach ($dir in @($MktComp, $UiDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "Created dir: $dir" -ForegroundColor DarkGray
    }
}

function Write-File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $stream = New-Object System.IO.FileStream($fullPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
    try {
        $writer = New-Object System.IO.StreamWriter($stream, $encoding)
        try {
            $writer.Write($Content)
        }
        finally {
            $writer.Flush()
            $writer.Dispose()
        }
    }
    finally {
        $stream.Dispose()
    }
    Write-Host "Wrote: $fullPath" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 0. Backup existing page.tsx
# ---------------------------------------------------------------------------
$PageTsx = Join-Path $MktDir "page.tsx"
if (Test-Path $PageTsx) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = Join-Path $MktDir "page.tsx.bak-$stamp"
    Copy-Item $PageTsx $backup
    Write-Host "Backed up page.tsx -> $backup" -ForegroundColor Yellow
} else {
    Write-Host "WARNING: page.tsx not found at $PageTsx (continuing anyway)" -ForegroundColor Red
}

# ---------------------------------------------------------------------------
# 1. components/ui/border-beam-panel.tsx
# ---------------------------------------------------------------------------
$borderBeamPanel = @'
"use client";

import * as React from "react";
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

/* Border Beam Panel — from Motiq (https://motiq.dev/components/border-beam-panel).
   MIT licensed. Zero runtime dependencies. */

const MOTIQ_TOKENS = "@layer motiq{:root{--motiq-accent:#315fea;--motiq-accent-text:#244fd1;--motiq-bg:#f7f9fc;--motiq-border:#dce4ef;--motiq-border-strong:#c5d1e1;--motiq-fg:#101828;--motiq-fg-secondary:#344054;--motiq-muted:#667085;--motiq-secondary-accent:#009fb3;--motiq-signature:#e9564a;--motiq-surface:#ffffff;--motiq-surface-2:#f8fafd}}@layer motiq{.dark,[data-theme=\"dark\"]{--motiq-accent:#4f7cff;--motiq-accent-text:#7f9fff;--motiq-bg:#080c14;--motiq-border:#263449;--motiq-border-strong:#354863;--motiq-fg:#f8fafc;--motiq-fg-secondary:#cbd5e1;--motiq-muted:#9caabd;--motiq-secondary-accent:#22c7d9;--motiq-signature:#ff6b5e;--motiq-surface:#111827;--motiq-surface-2:#192337}}";

function cn(...inputs: ClassValue[]): string {
  return twMerge(clsx(inputs));
}

function useReducedMotion(): boolean {
  const [reduced, setReduced] = React.useState(
    () => typeof window !== "undefined" && window.matchMedia("(prefers-reduced-motion: reduce)").matches,
  );
  React.useEffect(() => {
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");
    setReduced(mq.matches);
    const onChange = (e: MediaQueryListEvent) => setReduced(e.matches);
    mq.addEventListener("change", onChange);
    return () => mq.removeEventListener("change", onChange);
  }, []);
  return reduced;
}

function useVisibilityPause<T extends Element>(
  ref: React.RefObject<T | null>,
  { threshold = 0.1 }: { threshold?: number } = {},
): boolean {
  const [onScreen, setOnScreen] = React.useState(true);
  const [tabVisible, setTabVisible] = React.useState(true);

  React.useEffect(() => {
    const el = ref.current;
    if (!el || typeof IntersectionObserver === "undefined") return;
    const io = new IntersectionObserver(
      (entries) => setOnScreen(entries.some((e) => e.isIntersecting)),
      { threshold },
    );
    io.observe(el);
    return () => io.disconnect();
  }, [ref, threshold]);

  React.useEffect(() => {
    const onVis = () => setTabVisible(document.visibilityState !== "hidden");
    onVis();
    document.addEventListener("visibilitychange", onVis);
    return () => document.removeEventListener("visibilitychange", onVis);
  }, []);

  return onScreen && tabVisible;
}

export interface BorderBeamPanelProps extends React.HTMLAttributes<HTMLDivElement> {
  children?: React.ReactNode;
  beams?: 1 | 2;
  colors?: [string, string?];
  thickness?: number;
  idleSpeed?: number;
  hoverSpeed?: number;
  glow?: boolean;
  radius?: number;
  spring?: { stiffness?: number; damping?: number };
  seed?: number;
  pauseWhenHidden?: boolean;
  reducedMotion?: boolean;
}

class Spring {
  x: number;
  v = 0;
  target: number;
  k: number;
  d: number;
  constructor(value: number, k: number, d: number) {
    this.x = value;
    this.target = value;
    this.k = k;
    this.d = d;
  }
  step(dt: number): number {
    const a = this.k * (this.target - this.x) - this.d * this.v;
    this.v += a * dt;
    this.x += this.v * dt;
    return this.x;
  }
}

const clamp = (n: number, lo: number, hi: number) => Math.min(hi, Math.max(lo, n));

const PARKED_ANGLE = 40;

function comet(tail: string, head: string, tip: string, midAlpha: number, start: number): string {
  return [
    `color-mix(in srgb, ${tail} 4%, transparent) ${start + 18}deg`,
    `color-mix(in srgb, ${tail} ${midAlpha}%, transparent) ${start + 46}deg`,
    `${head} ${start + 56}deg`,
    `${tip} ${start + 60}deg`,
    `transparent ${start + 63}deg`,
  ].join(", ");
}

function ringGradient(beams: 1 | 2, colors: [string, string?] | undefined): string {
  const tail0 = colors?.[0] ?? "var(--motiq-accent, #4f7cff)";
  const head0 = colors?.[0] ?? "var(--motiq-secondary-accent, #22c7d9)";
  const stops = [
    "transparent 0deg",
    comet(tail0, head0, `color-mix(in srgb, ${head0} 22%, #ffffff)`, 55, 0),
  ];
  if (beams === 2) {
    const c1 = colors?.[1] ?? "var(--motiq-signature, #ff6b5e)";
    stops.push("transparent 198deg", comet(c1, c1, `color-mix(in srgb, ${c1} 26%, #ffffff)`, 50, 198));
  }
  stops.push("transparent 360deg");
  return `conic-gradient(from var(--mk-beam-a, 0deg), ${stops.join(", ")})`;
}

function BorderBeamPanelBase({
  children,
  beams = 2,
  colors,
  thickness = 2,
  idleSpeed = 42,
  hoverSpeed = 240,
  glow = true,
  radius = 16,
  spring,
  seed = 1,
  pauseWhenHidden = true,
  reducedMotion,
  className,
  style,
  ...props
}: BorderBeamPanelProps) {
  const uid = React.useId().replace(/[^a-zA-Z0-9]/g, "");
  const cls = `mk-beam-${uid}`;
  const rootRef = React.useRef<HTMLDivElement | null>(null);

  const systemReduced = useReducedMotion();
  const [hydrated, setHydrated] = React.useState(false);
  React.useEffect(() => setHydrated(true), []);
  const staticMode = reducedMotion === true || (hydrated && systemReduced);
  const onScreen = useVisibilityPause(rootRef, { threshold: 0.05 });
  const paused = pauseWhenHidden && !onScreen;
  const animate = !staticMode && !paused;

  const stiffness = spring?.stiffness ?? 30;
  const damping = spring?.damping ?? 11;

  const startAngle = React.useMemo(() => ((seed * 137.508) % 360 + 360) % 360, [seed]);

  const speedRef = React.useRef(new Spring(idleSpeed, stiffness, damping));
  const angleRef = React.useRef(startAngle);
  const liveRef = React.useRef({ idleSpeed, hoverSpeed });
  liveRef.current = { idleSpeed, hoverSpeed };

  React.useEffect(() => {
    speedRef.current.k = stiffness;
    speedRef.current.d = damping;
  }, [stiffness, damping]);

  const paint = React.useCallback((angle: number) => {
    rootRef.current?.style.setProperty("--mk-beam-a", `${(((angle % 360) + 360) % 360).toFixed(2)}deg`);
  }, []);

  React.useEffect(() => {
    if (!animate) return;
    let raf = 0;
    let last = 0;
    const frame = (now: number) => {
      if (!last) last = now;
      const dt = clamp((now - last) / 1000, 0, 0.05);
      last = now;
      angleRef.current += speedRef.current.step(dt) * dt;
      paint(angleRef.current);
      raf = requestAnimationFrame(frame);
    };
    raf = requestAnimationFrame(frame);
    return () => cancelAnimationFrame(raf);
  }, [animate, paint]);

  React.useEffect(() => {
    if (!staticMode) return;
    angleRef.current = PARKED_ANGLE;
    speedRef.current.x = speedRef.current.target = liveRef.current.idleSpeed;
    speedRef.current.v = 0;
    paint(PARKED_ANGLE);
  }, [staticMode, paint]);

  const surge = React.useCallback(() => {
    speedRef.current.target = liveRef.current.hoverSpeed;
  }, []);
  const settle = React.useCallback(() => {
    speedRef.current.target = liveRef.current.idleSpeed;
  }, []);

  const gradient = React.useMemo(() => ringGradient(beams, colors), [beams, colors]);

  const css = `
.${cls} .mk-beam-ring, .${cls} .mk-beam-glow {
  position: absolute;
  inset: -1px;
  border-radius: ${radius}px;
  pointer-events: none;
  background: ${gradient};
}
.${cls} .mk-beam-ring {
  padding: ${Math.max(1, thickness)}px;
  -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  -webkit-mask-composite: xor;
  mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
  mask-composite: exclude;
}
.${cls} .mk-beam-glow { filter: blur(14px); opacity: 0.35; z-index: -1; }
@media (forced-colors: active) {
  .${cls} .mk-beam-ring, .${cls} .mk-beam-glow { display: none; }
  .${cls} { border-color: CanvasText; }
}`.trim();

  return (
    <div
      ref={rootRef}
      data-motion={staticMode ? "static" : "animated"}
      data-paused={paused ? "true" : "false"}
      onPointerEnter={surge}
      onPointerLeave={settle}
      onFocus={surge}
      onBlur={settle}
      className={cn(
        "relative w-full border border-[var(--motiq-border,#263449)] bg-[var(--motiq-surface,#111827)] p-7",
        cls,
        className,
      )}
      style={{
        borderRadius: `${radius}px`,
        isolation: "isolate",
        ["--mk-beam-a" as string]: `${startAngle.toFixed(2)}deg`,
        ...style,
      }}
      {...props}
    >
      <style dangerouslySetInnerHTML={{ __html: css }} />
      {glow ? <div aria-hidden="true" className="mk-beam-glow" /> : null}
      <div aria-hidden="true" className="mk-beam-ring" />
      {children}
    </div>
  );
}

export function BorderBeamPanel(props: BorderBeamPanelProps) {
  return (
    <>
      <style dangerouslySetInnerHTML={{ __html: MOTIQ_TOKENS }} />
      <BorderBeamPanelBase {...props} />
    </>
  );
}

export default BorderBeamPanel;
'@
Write-File (Join-Path $UiDir "border-beam-panel.tsx") $borderBeamPanel

# ---------------------------------------------------------------------------
# 2. _components/landing-fake-data.ts
# ---------------------------------------------------------------------------
$fakeData = @'
// Landing-page dummy content. All names, numbers, quotes, and logos here are
// fictional placeholders for UI/UX purposes only -- swap for real API data
// once the backend endpoints (courses, reviews, activity feed) are wired up.

export type TrendingCourse = {
  id: string;
  title: string;
  category: string;
  instructor: string;
  price: string;
  rating: number;
  students: string;
  badge: "Bestseller" | "New" | "Hot" | "Staff pick";
  image: string;
};

export const TRENDING_COURSES: TrendingCourse[] = [
  { id: "t1", title: "Automate Everything with n8n & AI", category: "Automation", instructor: "Ayesha Khan", price: "$39", rating: 4.8, students: "6.2k", badge: "Bestseller", image: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t2", title: "Build AI Agents with LangChain", category: "Development", instructor: "Omar Sheikh", price: "$59", rating: 4.9, students: "3.2k", badge: "Hot", image: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t3", title: "AI Chatbots for WhatsApp Support", category: "Automation", instructor: "Ayesha Khan", price: "$49", rating: 4.7, students: "1.6k", badge: "New", image: "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t4", title: "AI Design Systems in Figma", category: "Design", instructor: "Noor Fatima", price: "$45", rating: 4.7, students: "1.1k", badge: "Staff pick", image: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t5", title: "Prompt Engineering for Client Work", category: "Fundamentals", instructor: "Hamza Malik", price: "$29", rating: 4.6, students: "980", badge: "Bestseller", image: "https://images.unsplash.com/photo-1550439062-609e1531270e?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "t6", title: "Voice AI & Call Automation", category: "Automation", instructor: "Hina Malik", price: "$55", rating: 4.6, students: "890", badge: "New", image: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=480&h=320&fit=crop&q=70&auto=format" }
];

export type ActivityItem = { id: string; text: string };

export const ACTIVITY_FEED: ActivityItem[] = [
  { id: "a1", text: "Bilal S. just enrolled in \"Automate Everything with n8n & AI\"" },
  { id: "a2", text: "Fatima R. earned a certificate in \"AI Chatbots for WhatsApp Support\"" },
  { id: "a3", text: "Omar Sheikh booked a mentorship session with Ayesha Khan" },
  { id: "a4", text: "Hina Malik just enrolled in \"Voice AI & Call Automation\"" },
  { id: "a5", text: "Sara Iqbal left a 5-star review on \"Prompt Engineering for Client Work\"" },
  { id: "a6", text: "Ali Raza just enrolled in \"Build AI Agents with LangChain\"" },
  { id: "a7", text: "Noor Fatima earned a certificate in \"AI Design Systems in Figma\"" }
];

export const COMPANY_LOGOS: string[] = [
  "NovaWorks", "BrightStack", "Vertex Labs", "Cirrus Digital", "Ember Systems",
  "Northline Tech", "Quill & Co", "Fenwick Studio"
];

export type BlogPost = {
  id: string;
  title: string;
  tag: string;
  readTime: string;
  image: string;
};

export const BLOG_POSTS: BlogPost[] = [
  { id: "b1", title: "5 n8n workflows every freelancer should automate first", tag: "Automation", readTime: "6 min read", image: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "b2", title: "How we structure a beginner-to-advanced AI curriculum", tag: "Teaching", readTime: "8 min read", image: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=320&fit=crop&q=70&auto=format" },
  { id: "b3", title: "From student to instructor: Ayesha's story", tag: "Community", readTime: "4 min read", image: "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=320&fit=crop&q=70&auto=format" }
];

export type ExtraTestimonial = {
  name: string;
  role: string;
  avatar: string;
  rating: number;
  quote: string;
  verified?: boolean;
};

export const EXTRA_TESTIMONIALS: ExtraTestimonial[] = [
  { name: "Zara Ahmed", role: "Product designer", avatar: "https://i.pravatar.cc/64?img=48", rating: 5, verified: true, quote: "The design systems course completely changed how I hand off files to developers. Immediate ROI." },
  { name: "Usman Tariq", role: "Agency owner", avatar: "https://i.pravatar.cc/64?img=13", rating: 5, verified: true, quote: "We onboarded our whole team through Saachi AI Business. Certificates and dashboards made tracking easy." },
  { name: "Mahnoor Khalid", role: "Content strategist", avatar: "https://i.pravatar.cc/64?img=45", rating: 4, verified: false, quote: "Solid course library, wish there was more advanced copywriting content, but great value overall." },
  { name: "Danish Iqbal", role: "Automation freelancer", avatar: "https://i.pravatar.cc/64?img=33", rating: 5, verified: true, quote: "Booked a mentorship call the same week I finished the course. Instructor feedback was gold." }
];

export const EXTRA_FAQS: { q: string; a: string }[] = [
  { q: "Do certificates expire?", a: "No -- once issued, your completion certificate is yours to keep and share forever." },
  { q: "Can I switch from learner to instructor later?", a: "Yes, anytime. Apply from your dashboard and our team reviews applications within a few business days." },
  { q: "Is there a mobile app?", a: "The platform is fully responsive today; native apps are on our roadmap." }
];
'@
Write-File (Join-Path $MktComp "landing-fake-data.ts") $fakeData

# ---------------------------------------------------------------------------
# 3. _components/TrendingCarousel.tsx
# ---------------------------------------------------------------------------
$trendingCarousel = @'
"use client";

import Link from "next/link";
import { useRef } from "react";
import { ChevronLeft, ChevronRight, Star, Flame } from "lucide-react";
import { cn } from "@saachi/ui";
import { TRENDING_COURSES } from "./landing-fake-data";

const BADGE_STYLES: Record<string, string> = {
  Bestseller: "bg-gold text-ink",
  New: "bg-teal text-white",
  Hot: "bg-accent-pink text-white",
  "Staff pick": "bg-accent-violet text-white"
};

export function TrendingCarousel() {
  const trackRef = useRef<HTMLDivElement>(null);

  function scrollBy(amount: number) {
    trackRef.current?.scrollBy({ left: amount, behavior: "smooth" });
  }

  return (
    <div>
      <div className="mb-5 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Flame size={18} className="text-accent-pink" />
          <h2 className="font-display text-[22px] font-semibold text-ink">Trending this week</h2>
        </div>
        <div className="hidden items-center gap-2 md:flex">
          <button
            type="button"
            aria-label="Scroll left"
            onClick={() => scrollBy(-360)}
            className="flex h-9 w-9 items-center justify-center rounded-full border border-line bg-card text-ink-soft hover:bg-paper-dim"
          >
            <ChevronLeft size={16} />
          </button>
          <button
            type="button"
            aria-label="Scroll right"
            onClick={() => scrollBy(360)}
            className="flex h-9 w-9 items-center justify-center rounded-full border border-line bg-card text-ink-soft hover:bg-paper-dim"
          >
            <ChevronRight size={16} />
          </button>
        </div>
      </div>

      <div
        ref={trackRef}
        className="flex snap-x snap-mandatory gap-4 overflow-x-auto pb-3 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
      >
        {TRENDING_COURSES.map((c) => (
          <Link
            key={c.id}
            href="/courses"
            className="group relative w-[260px] shrink-0 snap-start overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg"
          >
            <div className="relative aspect-video w-full overflow-hidden">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={c.image} alt={c.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
              <span className={cn("absolute left-3 top-3 rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide", BADGE_STYLES[c.badge])}>
                {c.badge}
              </span>
            </div>
            <div className="p-4">
              <p className="text-[11px] font-medium uppercase tracking-wide text-accent-violet">{c.category}</p>
              <h3 className="mt-1 line-clamp-2 text-[14.5px] font-semibold leading-snug text-ink">{c.title}</h3>
              <p className="mt-1 text-[12.5px] text-ink-soft">{c.instructor}</p>
              <div className="mt-3 flex items-center justify-between">
                <span className="flex items-center gap-1 text-[12.5px] font-medium text-ink-soft">
                  <Star size={12} className="fill-current text-accent-pink" />
                  {c.rating} ({c.students})
                </span>
                <span className="font-mono text-[14px] font-bold text-ink">{c.price}</span>
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
'@
Write-File (Join-Path $MktComp "TrendingCarousel.tsx") $trendingCarousel

# ---------------------------------------------------------------------------
# 4. _components/SpotlightPanels.tsx
# ---------------------------------------------------------------------------
$spotlightPanels = @'
"use client";

import Link from "next/link";
import { GraduationCap, Users, Building2 } from "lucide-react";
import { BorderBeamPanel } from "@/components/ui/border-beam-panel";

const PANELS = [
  {
    icon: GraduationCap,
    tag: "Certification",
    title: "AI Automation Track",
    desc: "A guided path through automation, prompt engineering, and agent-building -- finish with a verified certificate.",
    cta: "Explore track",
    href: "/courses",
    colors: ["#7c3aed", "#ec4899"] as [string, string]
  },
  {
    icon: Users,
    tag: "1-on-1",
    title: "Mentorship Sessions",
    desc: "Book paid sessions directly with verified instructors for code review, feedback, or career advice.",
    cta: "Book a mentor",
    href: "/mentorship",
    colors: ["#c026d3", "#22c7d9"] as [string, string]
  },
  {
    icon: Building2,
    tag: "For teams",
    title: "Saachi AI Business",
    desc: "Bulk seat licenses, team dashboards, and custom invoicing for organizations upskilling at scale.",
    cta: "Talk to sales",
    href: "/contact",
    colors: ["#009fb3", "#7c3aed"] as [string, string]
  }
];

export function SpotlightPanels() {
  return (
    <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
      {PANELS.map((p) => (
        <BorderBeamPanel key={p.title} beams={2} thickness={2} radius={18} colors={p.colors} className="!bg-card !border-line">
          <div className="flex flex-col gap-4">
            <span className="flex w-fit items-center gap-1.5 rounded-full border border-line px-2.5 py-0.5 text-[10px] font-semibold uppercase tracking-[0.14em] text-ink-soft">
              <p.icon size={12} />
              {p.tag}
            </span>
            <h3 className="font-display text-[20px] font-semibold text-ink">{p.title}</h3>
            <p className="text-[13.5px] leading-relaxed text-ink-soft">{p.desc}</p>
            <Link
              href={p.href}
              className="mt-1 w-fit rounded-lg bg-ink px-4 py-2 text-[13px] font-medium text-paper transition-opacity hover:opacity-90"
            >
              {p.cta}
            </Link>
          </div>
        </BorderBeamPanel>
      ))}
    </div>
  );
}
'@
Write-File (Join-Path $MktComp "SpotlightPanels.tsx") $spotlightPanels

# ---------------------------------------------------------------------------
# 5. _components/ActivityTicker.tsx
# ---------------------------------------------------------------------------
$activityTicker = @'
"use client";

import { useEffect, useState } from "react";
import { Sparkle } from "lucide-react";
import { ACTIVITY_FEED } from "./landing-fake-data";

export function ActivityTicker() {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setIndex((i) => (i + 1) % ACTIVITY_FEED.length);
    }, 3200);
    return () => clearInterval(id);
  }, []);

  const item = ACTIVITY_FEED[index];

  return (
    <div className="mx-auto flex w-fit max-w-full items-center gap-2 rounded-full border border-line bg-card px-4 py-2 shadow-sm">
      <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-teal-light text-teal">
        <Sparkle size={11} />
      </span>
      <span key={item.id} className="truncate text-[12.5px] text-ink-soft duration-300 animate-in fade-in slide-in-from-bottom-1">
        {item.text}
      </span>
    </div>
  );
}
'@
Write-File (Join-Path $MktComp "ActivityTicker.tsx") $activityTicker

# ---------------------------------------------------------------------------
# 6. _components/LogoCloud.tsx
# ---------------------------------------------------------------------------
$logoCloud = @'
import { COMPANY_LOGOS } from "./landing-fake-data";

export function LogoCloud() {
  return (
    <div>
      <p className="mb-6 text-center text-[12.5px] font-medium uppercase tracking-[0.1em] text-ink-soft/70">
        Teams upskilling with Saachi AI
      </p>
      <div className="flex flex-wrap items-center justify-center gap-x-10 gap-y-5">
        {COMPANY_LOGOS.map((name) => (
          <span key={name} className="font-display text-[16px] font-bold text-ink-soft/50 transition-colors hover:text-ink-soft">
            {name}
          </span>
        ))}
      </div>
    </div>
  );
}
'@
Write-File (Join-Path $MktComp "LogoCloud.tsx") $logoCloud

# ---------------------------------------------------------------------------
# 7. _components/BlogPreview.tsx
# ---------------------------------------------------------------------------
$blogPreview = @'
import Link from "next/link";
import { ArrowUpRight } from "lucide-react";
import { BLOG_POSTS } from "./landing-fake-data";

export function BlogPreview() {
  return (
    <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
      {BLOG_POSTS.map((post) => (
        <Link
          key={post.id}
          href="/about"
          className="group overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg"
        >
          <div className="aspect-video w-full overflow-hidden">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={post.image} alt={post.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
          </div>
          <div className="p-5">
            <div className="mb-2 flex items-center justify-between">
              <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{post.tag}</span>
              <span className="text-[11.5px] text-ink-soft">{post.readTime}</span>
            </div>
            <h3 className="line-clamp-2 text-[15px] font-semibold leading-snug text-ink">{post.title}</h3>
            <span className="mt-3 flex items-center gap-1 text-[12.5px] font-medium text-accent-violet">
              Read more
              <ArrowUpRight size={13} className="transition-transform group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
            </span>
          </div>
        </Link>
      ))}
    </div>
  );
}
'@
Write-File (Join-Path $MktComp "BlogPreview.tsx") $blogPreview

# ---------------------------------------------------------------------------
# 8. _components/PricingTeaser.tsx
# ---------------------------------------------------------------------------
$pricingTeaser = @'
import Link from "next/link";
import { Check } from "lucide-react";
import { cn } from "@saachi/ui";

const PLANS = [
  { name: "Basic", price: "Free", accent: "border-line", features: ["Buy courses individually", "Completion certificates"] },
  { name: "Pro", price: "$19/mo", accent: "border-accent-violet/50 bg-gold-tint", highlighted: true, features: ["Unlimited standard courses", "Priority support", "Verified certificates"] },
  { name: "Business", price: "Contact us", accent: "border-line", features: ["Bulk seat licenses", "Team dashboards"] }
];

export function PricingTeaser() {
  return (
    <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
      {PLANS.map((plan) => (
        <div key={plan.name} className={cn("flex flex-col rounded-card border p-6", plan.accent)}>
          {plan.highlighted && (
            <span className="mb-3 w-fit rounded-full bg-gold-dark px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-white">
              Most popular
            </span>
          )}
          <h3 className="font-display text-[18px] font-semibold text-ink">{plan.name}</h3>
          <p className="mt-1 font-mono text-[24px] font-bold text-ink">{plan.price}</p>
          <ul className="my-5 flex flex-1 flex-col gap-2 text-[13px] text-ink-soft">
            {plan.features.map((f) => (
              <li key={f} className="flex items-start gap-2">
                <Check size={14} className="mt-0.5 shrink-0 text-teal" />
                {f}
              </li>
            ))}
          </ul>
          <Link
            href="/pricing"
            className={cn(
              "w-full rounded-full py-2.5 text-center text-[13px] font-semibold transition-opacity hover:opacity-90",
              plan.highlighted ? "bg-ink text-paper" : "border border-line text-ink"
            )}
          >
            View plan
          </Link>
        </div>
      ))}
    </div>
  );
}
'@
Write-File (Join-Path $MktComp "PricingTeaser.tsx") $pricingTeaser

# ---------------------------------------------------------------------------
# 9. _components/NewsletterCard.tsx
# ---------------------------------------------------------------------------
$newsletterCard = @'
"use client";

import { useState, type FormEvent } from "react";
import { Mail, CheckCircle2 } from "lucide-react";

export function NewsletterCard() {
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend newsletter-signup endpoint wired up yet.
    setSubmitted(true);
  }

  return (
    <div
      className="relative overflow-hidden rounded-card p-8 text-center md:p-12"
      style={{ backgroundImage: "var(--color-accent-gradient)" }}
    >
      <Mail size={26} className="mx-auto mb-3 text-white/90" />
      <h2 className="font-display text-[22px] font-bold text-white md:text-[26px]">
        Get new courses in your inbox
      </h2>
      <p className="mx-auto mt-2 max-w-md text-[13.5px] text-white/85">
        One email a week. New releases, instructor spotlights, and the occasional discount code.
      </p>

      {submitted ? (
        <div className="mx-auto mt-6 flex w-fit items-center gap-2 rounded-full bg-white/15 px-4 py-2 text-[13px] font-medium text-white">
          <CheckCircle2 size={16} />
          You&apos;re on the list -- check your inbox.
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="mx-auto mt-6 flex max-w-md flex-col gap-2 sm:flex-row">
          <input
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            className="w-full rounded-full border-0 px-4 py-2.5 text-[13.5px] text-ink outline-none placeholder:text-ink-soft/60 focus:ring-2 focus:ring-white/60"
          />
          <button
            type="submit"
            className="shrink-0 rounded-full bg-white px-5 py-2.5 text-[13.5px] font-semibold text-accent-violet transition-transform hover:scale-105"
          >
            Subscribe
          </button>
        </form>
      )}
    </div>
  );
}
'@
Write-File (Join-Path $MktComp "NewsletterCard.tsx") $newsletterCard

# ---------------------------------------------------------------------------
# 10. page.tsx  (full rewrite)
# ---------------------------------------------------------------------------
$PageBody = @'
"use client";

import Link from "next/link";
import { useCourseList } from "@saachi/api-client";
import { Button, CourseCard, Loading } from "@saachi/ui";
import {
  Sparkles,
  Users,
  BookOpen,
  Award,
  Star,
  ShieldCheck,
  Zap,
  TrendingUp,
  PlayCircle,
  Quote,
  BadgeCheck,
  ShieldCheck as VerifiedIcon
} from "lucide-react";
import { CATEGORIES } from "../../lib/categories";
import { Reveal } from "./_components/Reveal";
import { LandingSearch } from "./_components/LandingSearch";
import { FaqAccordion } from "./_components/FaqAccordion";
import { TrendingCarousel } from "./_components/TrendingCarousel";
import { SpotlightPanels } from "./_components/SpotlightPanels";
import { ActivityTicker } from "./_components/ActivityTicker";
import { LogoCloud } from "./_components/LogoCloud";
import { BlogPreview } from "./_components/BlogPreview";
import { PricingTeaser } from "./_components/PricingTeaser";
import { NewsletterCard } from "./_components/NewsletterCard";
import { EXTRA_TESTIMONIALS } from "./_components/landing-fake-data";
import { CoverflowCarousel } from "@/components/ui/coverflow-carousel";
import { ImageStreamHero } from "@/components/ui/image-stream-hero";
import HowItWorks from "@/components/ui/how-it-works";

const STATS = [
  { label: "Active students", value: "42,000+", icon: Users },
  { label: "Courses live", value: "1,280+", icon: BookOpen },
  { label: "Instructor payouts", value: "$2.1M+", icon: TrendingUp },
  { label: "Avg. rating", value: "4.8 / 5", icon: Star }
];

const TRUST_BADGES = [
  "Featured on ProductHunt", "AI Weekly Pick", "TechCrunch Mentioned",
  "500+ 5-star reviews", "SSL Secured Checkout", "7-Day Refunds",
  "42,000+ learners", "1,280+ live courses"
];

const INSTRUCTORS = [
  { name: "Ayesha Khan", role: "Automation & n8n", students: "6.2k", avatar: "https://i.pravatar.cc/96?img=47" },
  { name: "Hamza Malik", role: "AI Integration", students: "4.8k", avatar: "https://i.pravatar.cc/96?img=12" },
  { name: "Sara Iqbal", role: "AI Marketing", students: "3.1k", avatar: "https://i.pravatar.cc/96?img=32" },
  { name: "Omar Sheikh", role: "AI Development", students: "5.5k", avatar: "https://i.pravatar.cc/96?img=15" },
  { name: "Noor Fatima", role: "AI Design", students: "2.7k", avatar: "https://i.pravatar.cc/96?img=44" },
  { name: "Bilal S.", role: "Career & Freelancing", students: "1.9k", avatar: "https://i.pravatar.cc/96?img=8" }
];

const TESTIMONIALS = [
  {
    name: "Fatima R.", role: "Freelance automation consultant", avatar: "https://i.pravatar.cc/64?img=5",
    rating: 5, verified: true,
    quote: "I landed 3 client projects within a month of finishing the n8n automation course. The invoice-parsing workflow alone paid for the course ten times over."
  },
  {
    name: "Ali Raza", role: "Support team lead", avatar: "https://i.pravatar.cc/64?img=22",
    rating: 5, verified: true,
    quote: "Our WhatsApp response time dropped by 70% after building the chatbot from the course. Practical, no fluff, straight to the point."
  },
  {
    name: "Hina Malik", role: "Marketing manager", avatar: "https://i.pravatar.cc/64?img=25",
    rating: 4, verified: false,
    quote: "Best structured AI marketing content I have found anywhere. Wish there were a couple more advanced modules, but genuinely worth it."
  },
  {
    name: "Omar Sheikh", role: "Indie developer", avatar: "https://i.pravatar.cc/64?img=15",
    rating: 5, verified: true,
    quote: "Went from zero to shipping my own AI agent product in six weeks. The instructor actually answers Q&A -- that made all the difference."
  },
  ...EXTRA_TESTIMONIALS
];

const HOW_IT_WORKS = [
  { title: "Pick a skill", desc: "Browse 1,200+ practical AI courses across automation, marketing, design, and development.", icon: Sparkles },
  { title: "Learn by building", desc: "Every course ships real projects and templates, not just watch-and-forget video.", icon: PlayCircle },
  { title: "Get certified & earn", desc: "Finish, get certified, and turn what you learned into freelance work -- or teach it yourself.", icon: Award }
];

export default function HomePage() {
  const { data: featured, isLoading } = useCourseList({ sort: "popular", page: 1 });

  return (
    <div className="overflow-hidden">
      {/* Hero */}
      <section className="relative mx-auto max-w-7xl px-4 pb-14 pt-16 md:px-8 md:pt-24">
        <div
          className="pointer-events-none absolute -left-32 -top-32 h-96 w-96 rounded-full opacity-30 blur-3xl"
          style={{ backgroundImage: "var(--color-accent-gradient)" }}
        />
        <div className="relative max-w-2xl">
          <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-line bg-card px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet">
            <Zap size={13} />
            42,000+ learners already building with AI
          </div>
          <h1 className="font-display text-[38px] font-bold leading-[1.05] text-ink md:text-[64px]">
            Learn AI Skills.
            <br />
            <span className="text-gradient-brand">Build Real Projects.</span>
          </h1>
          <p className="mt-5 text-[16px] leading-relaxed text-ink-soft md:text-[18px]">
            Not another watch-time platform. Saachi AI is a skills exchange for the AI era -
            structured, practical, and paid.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses">
              <Button size="lg" variant="brand">Browse courses</Button>
            </Link>
            <Link href="/register">
              <Button size="lg" variant="secondary">
                Become an instructor
              </Button>
            </Link>
          </div>

          <div className="mt-10">
            <LandingSearch />
          </div>

          <div className="mt-6">
            <ActivityTicker />
          </div>
        </div>
      </section>

      {/* Trust badges marquee */}
      <section className="border-y border-line bg-paper-dim py-4">
        <div className="marquee-track">
          {[...TRUST_BADGES, ...TRUST_BADGES].map((badge, i) => (
            <span
              key={`${badge}-${i}`}
              className="mx-4 flex shrink-0 items-center gap-2 text-[13px] font-medium text-ink-soft"
            >
              <BadgeCheck size={14} className="text-accent-violet" />
              {badge}
            </span>
          ))}
        </div>
      </section>

      {/* Stats */}
      <section className="mx-auto max-w-7xl px-4 py-16 md:px-8">
        <Reveal>
          <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
            {STATS.map((s) => (
              <div key={s.label} className="rounded-card border border-line bg-card p-5 text-center">
                <s.icon size={20} className="mx-auto mb-2 text-accent-violet" />
                <p className="font-display text-[24px] font-bold text-ink">{s.value}</p>
                <p className="mt-1 text-[12.5px] text-ink-soft">{s.label}</p>
              </div>
            ))}
          </div>
        </Reveal>
      </section>

      {/* Logo cloud */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <LogoCloud />
        </Reveal>
      </section>

      {/* Category grid */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-5 font-display text-[22px] font-semibold text-ink">Browse by category</h2>
        </Reveal>
        <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
          {CATEGORIES.map((cat, i) => (
            <Reveal key={cat.id} delay={i * 40}>
              <Link
                href={`/categories/${cat.slug}`}
                className="group flex h-full flex-col justify-between rounded-card border border-line bg-card p-4 text-[14px] font-medium text-ink transition-all hover:-translate-y-1 hover:border-accent-violet/50 hover:shadow-md"
              >
                <span>{cat.name}</span>
                <span className="mt-3 text-[11px] font-semibold text-ink-soft group-hover:text-accent-violet">
                  Explore &rarr;
                </span>
              </Link>
            </Reveal>
          ))}
        </div>
      </section>

      {/* Trending carousel */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <TrendingCarousel />
        </Reveal>
      </section>

      {/* Spotlight panels (Border Beam) */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Ways to level up</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Pick the path that fits how you learn best.</p>
        </Reveal>
        <Reveal delay={80}>
          <SpotlightPanels />
        </Reveal>
      </section>

      {/* How it works */}
      <Reveal>
        <HowItWorks />
      </Reveal>

      {/* Featured courses */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <div className="mb-5 flex items-center justify-between">
            <h2 className="font-display text-[22px] font-semibold text-ink">Featured courses</h2>
            <Link href="/courses" className="text-[14px] font-medium text-accent-violet hover:underline">
              View all
            </Link>
          </div>
        </Reveal>

        {isLoading ? (
          <Loading label="Loading courses..." />
        ) : (
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {featured?.items.map((course, i) => (
              <Reveal key={course.id} delay={i * 60}>
                <CourseCard
                  slug={course.slug}
                  title={course.title}
                  thumbnailUrl={course.thumbnailUrl}
                  instructorName={course.instructor.fullName}
                  price={course.price}
                  currency={course.currency}
                  rating={course.rating}
                  ratingCount={course.ratingCount}
                />
              </Reveal>
            ))}
          </div>
        )}
      </section>

      {/* Pricing teaser */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Simple, transparent pricing</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Buy individual courses, or go unlimited with Pro.</p>
        </Reveal>
        <Reveal delay={80}>
          <PricingTeaser />
        </Reveal>
      </section>

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

      {/* Testimonials */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">What learners are saying</h2>
          <p className="mb-8 text-[14px] text-ink-soft">4.8 average rating across 12,000+ reviews.</p>
        </Reveal>
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
          {TESTIMONIALS.map((t, i) => (
            <Reveal key={t.name} delay={i * 70}>
              <div className="relative h-full rounded-card border border-line bg-card p-6">
                <Quote size={28} className="absolute right-5 top-5 text-line-strong" />
                <div className="mb-3 flex items-center gap-3">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={t.avatar} alt={t.name} className="h-11 w-11 rounded-full object-cover" />
                  <div>
                    <p className="flex items-center gap-1 text-[13.5px] font-semibold text-ink">
                      {t.name}
                      {t.verified && <VerifiedIcon size={12} className="text-teal" />}
                    </p>
                    <p className="text-[12px] text-ink-soft">{t.role}</p>
                  </div>
                </div>
                <div className="mb-2 flex items-center gap-0.5 text-accent-pink">
                  {Array.from({ length: 5 }).map((_, idx) => (
                    <Star key={idx} size={13} fill={idx < t.rating ? "currentColor" : "none"} />
                  ))}
                </div>
                <p className="text-[13.5px] leading-relaxed text-ink-soft">&quot;{t.quote}&quot;</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

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

      {/* Blog / resources */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <div className="mb-5 flex items-center justify-between">
            <h2 className="font-display text-[22px] font-semibold text-ink">From the blog</h2>
            <Link href="/about" className="text-[14px] font-medium text-accent-violet hover:underline">
              View all
            </Link>
          </div>
        </Reveal>
        <Reveal delay={80}>
          <BlogPreview />
        </Reveal>
      </section>

      {/* FAQ */}
      <section className="mx-auto max-w-4xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Frequently asked questions</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Everything you need to know before you start.</p>
        </Reveal>
        <Reveal delay={100}>
          <FaqAccordion />
        </Reveal>
      </section>

      {/* Newsletter */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <NewsletterCard />
        </Reveal>
      </section>

      {/* Final CTA */}
      <section className="mx-auto max-w-7xl px-4 pb-24 md:px-8">
        <Reveal>
          <div
            className="relative overflow-hidden rounded-card p-10 text-center md:p-16"
            style={{ backgroundImage: "var(--color-accent-gradient)" }}
          >
            <ShieldCheck size={28} className="mx-auto mb-4 text-white/90" />
            <h2 className="font-display text-[26px] font-bold text-white md:text-[34px]">
              Your next skill is one course away.
            </h2>
            <p className="mx-auto mt-3 max-w-lg text-[14.5px] text-white/85">
              Join 42,000+ learners already building real AI projects. 7-day refund window, no risk.
            </p>
            <div className="mt-7 flex flex-wrap items-center justify-center gap-3">
              <Link href="/courses">
                <button className="rounded-full bg-white px-6 py-3 text-[14px] font-semibold text-accent-violet transition-transform hover:scale-105">
                  Start learning free
                </button>
              </Link>
              <Link href="/register">
                <button className="rounded-full border border-white/40 px-6 py-3 text-[14px] font-semibold text-white transition-colors hover:bg-white/10">
                  Become an instructor
                </button>
              </Link>
            </div>
          </div>
        </Reveal>
      </section>
    </div>
  );
}
'@
Write-File $PageTsx $PageBody

Write-Host ""
Write-Host "Done. New/updated files:" -ForegroundColor Cyan
Write-Host "  apps\web\components\ui\border-beam-panel.tsx"
Write-Host "  apps\web\app\(marketing)\_components\landing-fake-data.ts"
Write-Host "  apps\web\app\(marketing)\_components\TrendingCarousel.tsx"
Write-Host "  apps\web\app\(marketing)\_components\SpotlightPanels.tsx"
Write-Host "  apps\web\app\(marketing)\_components\ActivityTicker.tsx"
Write-Host "  apps\web\app\(marketing)\_components\LogoCloud.tsx"
Write-Host "  apps\web\app\(marketing)\_components\BlogPreview.tsx"
Write-Host "  apps\web\app\(marketing)\_components\PricingTeaser.tsx"
Write-Host "  apps\web\app\(marketing)\_components\NewsletterCard.tsx"
Write-Host "  apps\web\app\(marketing)\page.tsx  (backup saved alongside)"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  cd apps\web"
Write-Host "  pnpm install   # clsx / tailwind-merge already in package.json"
Write-Host "  pnpm dev"