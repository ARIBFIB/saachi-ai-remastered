# Update-HeroCursorTrail-And-AddGallery.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $dir = Split-Path -Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$webApp = Join-Path -Path $root -ChildPath "apps\web"
$pagePath = Join-Path -Path $webApp -ChildPath "app\(marketing)\page.tsx"

if (-not (Test-Path $pagePath)) {
    Write-Host "ERROR: $pagePath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# 1. Patch base image-cursor-trail.tsx: track mouse via WINDOW listener
#    bounded to container's rect (so it works anywhere the container
#    covers), and stay pointer-events-none so it never blocks clicks
#    on text/buttons underneath.
# ------------------------------------------------------------------
$cursorTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\image-cursor-trail.tsx"

$cursorTrailContent = @'
"use client";

import React, { createRef, useEffect, useRef, type ReactNode } from "react";
import { cn } from "@/lib/utils";

interface ImageMouseTrailProps {
  items: string[];
  children?: ReactNode;
  className?: string;
  imgClass?: string;
  distance?: number;
  maxNumberOfImages?: number;
  fadeAnimation?: boolean;
  /** When false, the component stops tracking/showing images (used for hover-triggered galleries). */
  active?: boolean;
}

export function ImageCursorTrail({
  items,
  children,
  className,
  maxNumberOfImages = 5,
  imgClass = "w-40 h-48",
  distance = 20,
  fadeAnimation = false,
  active = true,
}: ImageMouseTrailProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const refs = useRef(items.map(() => createRef<HTMLImageElement>()));
  const currentZIndexRef = useRef(1);
  const globalIndexRef = useRef(0);
  const lastRef = useRef({ x: 0, y: 0 });

  const activate = (image: HTMLImageElement, x: number, y: number) => {
    const containerRect = containerRef.current?.getBoundingClientRect();
    if (!containerRect) return;
    const relativeX = x - containerRect.left;
    const relativeY = y - containerRect.top;
    image.style.left = `${relativeX}px`;
    image.style.top = `${relativeY}px`;

    if (currentZIndexRef.current > 40) {
      currentZIndexRef.current = 1;
    }
    image.style.zIndex = String(currentZIndexRef.current);
    currentZIndexRef.current++;

    image.dataset.status = "active";
    if (fadeAnimation) {
      setTimeout(() => {
        image.dataset.status = "inactive";
      }, 1500);
    }
    lastRef.current = { x, y };
  };

  const deactivate = (image: HTMLImageElement) => {
    image.dataset.status = "inactive";
  };

  useEffect(() => {
    if (!active) {
      refs.current.forEach((r) => {
        if (r.current) r.current.dataset.status = "inactive";
      });
      return;
    }

    function handlePoint(clientX: number, clientY: number) {
      const rect = containerRef.current?.getBoundingClientRect();
      if (!rect) return;
      const inside =
        clientX >= rect.left &&
        clientX <= rect.right &&
        clientY >= rect.top &&
        clientY <= rect.bottom;
      if (!inside) return;

      const distFromLast = Math.hypot(clientX - lastRef.current.x, clientY - lastRef.current.y);
      if (distFromLast > window.innerWidth / distance) {
        const lead = refs.current[globalIndexRef.current % refs.current.length].current;
        const tail =
          refs.current[
            (globalIndexRef.current - maxNumberOfImages) % refs.current.length
          ]?.current;
        if (lead) activate(lead, clientX, clientY);
        if (tail) deactivate(tail);
        globalIndexRef.current++;
      }
    }

    function onMouseMove(e: MouseEvent) {
      handlePoint(e.clientX, e.clientY);
    }
    function onTouchMove(e: TouchEvent) {
      const t = e.touches[0];
      if (t) handlePoint(t.clientX, t.clientY);
    }

    window.addEventListener("mousemove", onMouseMove);
    window.addEventListener("touchmove", onTouchMove);
    return () => {
      window.removeEventListener("mousemove", onMouseMove);
      window.removeEventListener("touchmove", onTouchMove);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [active, distance, maxNumberOfImages, fadeAnimation]);

  return (
    <section
      ref={containerRef}
      className={cn(
        "relative grid h-[600px] w-full place-content-center overflow-hidden rounded-lg pointer-events-none",
        className
      )}
    >
      {items.map((item, index) => (
        <img
          key={index}
          className={cn(
            "opacity:0 data-[status='active']:ease-out-expo pointer-events-none absolute -translate-x-[50%] -translate-y-[50%] scale-0 rounded-3xl object-cover transition-transform duration-300 data-[status='active']:scale-100 data-[status='active']:opacity-100 data-[status='active']:duration-500",
            imgClass
          )}
          data-index={index}
          data-status="inactive"
          src={item}
          alt={`saachi-ai-showcase-${index}`}
          ref={refs.current[index]}
        />
      ))}
      {children}
    </section>
  );
}

export default ImageCursorTrail;
'@

Write-Utf8NoBom -Path $cursorTrailPath -Content $cursorTrailContent
Write-Host "Patched: $cursorTrailPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 2. HeroCursorTrail: cover the WHOLE hero section, mask/fade opacity
#    near the left text column so it never visually competes with
#    text or CTA buttons.
# ------------------------------------------------------------------
$heroCursorTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\hero-cursor-trail.tsx"

$heroCursorTrailContent = @'
"use client";

import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";

// Course/AI-relevant imagery for the hero cursor-trail effect.
const SHOWCASE_IMAGES = [
  "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1550439062-609e1531270e?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?w=480&h=600&fit=crop&q=70&auto=format"
];

/**
 * Covers the ENTIRE hero section (so the trail reacts to the mouse
 * anywhere in the hero, not just a small box), but fades out via a
 * mask-image gradient as it approaches the left text column so it
 * never overlaps the heading, paragraph, or CTA buttons.
 */
export function HeroCursorTrail() {
  return (
    <div
      className="pointer-events-none absolute inset-0 z-0 hidden lg:block"
      style={{
        maskImage: "linear-gradient(to right, transparent 0%, transparent 38%, black 58%, black 100%)",
        WebkitMaskImage: "linear-gradient(to right, transparent 0%, transparent 38%, black 58%, black 100%)"
      }}
    >
      <ImageCursorTrail
        items={SHOWCASE_IMAGES}
        maxNumberOfImages={5}
        distance={20}
        imgClass="w-28 h-32 xl:w-32 xl:h-36"
        className="!h-full !w-full !rounded-none"
      />
    </div>
  );
}

export default HeroCursorTrail;
'@

Write-Utf8NoBom -Path $heroCursorTrailPath -Content $heroCursorTrailContent
Write-Host "Updated: $heroCursorTrailPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 3. New component: image-gallery.tsx (adapted to project's cn util)
# ------------------------------------------------------------------
$galleryPath = Join-Path -Path $webApp -ChildPath "components\ui\image-gallery.tsx"

$galleryContent = @'
"use client";

import { cn } from "@/lib/utils";

const GALLERY_IMAGES = [
  "https://images.unsplash.com/photo-1555949963-aa79dcee981c?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1531482615713-2afd69097998?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1550439062-609e1531270e?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&h=800&w=800&auto=format&fit=crop"
];

export function ImageGallery() {
  return (
    <div className={cn("flex items-center gap-2 h-[320px] w-full")}>
      {GALLERY_IMAGES.map((src, idx) => (
        <div
          key={idx}
          className="relative group flex-grow transition-all w-40 rounded-lg overflow-hidden h-[320px] duration-500 hover:w-full"
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            className="h-full w-full object-cover object-center"
            src={src}
            alt={`saachi-ai-gallery-${idx}`}
          />
        </div>
      ))}
    </div>
  );
}

export default ImageGallery;
'@

Write-Utf8NoBom -Path $galleryPath -Content $galleryContent
Write-Host "Created: $galleryPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 4. Wrapper: gallery + cursor trail that activates ONLY on hover
#    over the gallery area.
# ------------------------------------------------------------------
$galleryTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\gallery-cursor-trail.tsx"

$galleryTrailContent = @'
"use client";

import { useState } from "react";
import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";
import { ImageGallery } from "@/components/ui/image-gallery";

const TRAIL_IMAGES = [
  "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1550439062-609e1531270e?w=480&h=600&fit=crop&q=70&auto=format"
];

/**
 * Renders the image gallery. When the user hovers/points over the
 * gallery area, the ImageCursorTrail effect activates on top of it.
 * Outside of hover, the trail is inactive and invisible.
 */
export function GalleryCursorTrail() {
  const [hovering, setHovering] = useState(false);

  return (
    <div
      className="relative w-full"
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
    >
      <ImageGallery />

      <ImageCursorTrail
        items={TRAIL_IMAGES}
        active={hovering}
        maxNumberOfImages={4}
        distance={18}
        imgClass="w-24 h-28"
        className="!absolute !inset-0 !h-full !w-full !rounded-lg !bg-transparent"
      />
    </div>
  );
}

export default GalleryCursorTrail;
'@

Write-Utf8NoBom -Path $galleryTrailPath -Content $galleryTrailContent
Write-Host "Created: $galleryTrailPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 5. Wire GalleryCursorTrail into page.tsx, inside the Hero section,
#    right below the search + activity ticker block.
# ------------------------------------------------------------------
$pageContent = [System.IO.File]::ReadAllText($pagePath)

$importAnchor = 'import { HeroCursorTrail } from "@/components/ui/hero-cursor-trail";'
if ($pageContent -notmatch [regex]::Escape('gallery-cursor-trail')) {
    if ($pageContent.Contains($importAnchor)) {
        $newImportBlock = $importAnchor + "`r`nimport { GalleryCursorTrail } from `"@/components/ui/gallery-cursor-trail`";"
        $pageContent = $pageContent.Replace($importAnchor, $newImportBlock)
        Write-Host "Added GalleryCursorTrail import." -ForegroundColor Green
    } else {
        Write-Host "ERROR: HeroCursorTrail import anchor not found. Run the previous script first." -ForegroundColor Red
        exit 1
    }
}

$activityTickerAnchor = @'
          <div className="mt-6">
            <ActivityTicker />
          </div>
        </div>

        <HeroCursorTrail />
      </section>
'@

$newHeroBlock = @'
          <div className="mt-6">
            <ActivityTicker />
          </div>

          <div className="mt-10 hidden lg:block">
            <GalleryCursorTrail />
          </div>
        </div>

        <HeroCursorTrail />
      </section>
'@

if ($pageContent -notmatch [regex]::Escape('<GalleryCursorTrail')) {
    if ($pageContent.Contains($activityTickerAnchor)) {
        $pageContent = $pageContent.Replace($activityTickerAnchor, $newHeroBlock)
        Write-Host "Inserted GalleryCursorTrail into Hero section." -ForegroundColor Green
    } else {
        Write-Host "ERROR: Hero closing anchor not found - check page.tsx structure manually (ActivityTicker/HeroCursorTrail block)." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "GalleryCursorTrail already present, skipping." -ForegroundColor Yellow
}

Write-Utf8NoBom -Path $pagePath -Content $pageContent
Write-Host "Updated: $pagePath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan