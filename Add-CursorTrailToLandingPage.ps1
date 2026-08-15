# Add-CursorTrailToLandingPage.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $dir = Split-Path -Path $Path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$webApp = Join-Path -Path $root -ChildPath "apps\web"

if (-not (Test-Path $webApp)) {
    Write-Host "ERROR: apps\web not found under $root. Run this script from the SAI2 repo root." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# 1. Base component: components/ui/image-cursor-trail.tsx
# ------------------------------------------------------------------
$cursorTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\image-cursor-trail.tsx"

$cursorTrailContent = @'
"use client";

import React, { createRef, useRef, type ReactNode } from "react";
import { cn } from "@/lib/utils";

interface ImageMouseTrailProps {
  items: string[];
  children?: ReactNode;
  className?: string;
  imgClass?: string;
  distance?: number;
  maxNumberOfImages?: number;
  fadeAnimation?: boolean;
}

export function ImageCursorTrail({
  items,
  children,
  className,
  maxNumberOfImages = 5,
  imgClass = "w-40 h-48",
  distance = 20,
  fadeAnimation = false,
}: ImageMouseTrailProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const refs = useRef(items.map(() => createRef<HTMLImageElement>()));
  const currentZIndexRef = useRef(1);

  let globalIndex = 0;
  let last = { x: 0, y: 0 };

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
    last = { x, y };
  };

  const distanceFromLast = (x: number, y: number) =>
    Math.hypot(x - last.x, y - last.y);

  const deactivate = (image: HTMLImageElement) => {
    image.dataset.status = "inactive";
  };

  const handleOnMove = (e: MouseEvent | Touch) => {
    if (distanceFromLast(e.clientX, e.clientY) > window.innerWidth / distance) {
      const lead = refs.current[globalIndex % refs.current.length].current;
      const tail =
        refs.current[
          (globalIndex - maxNumberOfImages) % refs.current.length
        ]?.current;
      if (lead) activate(lead, e.clientX, e.clientY);
      if (tail) deactivate(tail);
      globalIndex++;
    }
  };

  return (
    <section
      onMouseMove={(e) => handleOnMove(e.nativeEvent)}
      onTouchMove={(e) => handleOnMove(e.touches[0])}
      ref={containerRef}
      className={cn(
        "relative grid h-[600px] w-full place-content-center overflow-hidden rounded-lg",
        className
      )}
    >
      {items.map((item, index) => (
        <img
          key={index}
          className={cn(
            "opacity:0 data-[status='active']:ease-out-expo absolute -translate-x-[50%] -translate-y-[50%] scale-0 rounded-3xl object-cover transition-transform duration-300 data-[status='active']:scale-100 data-[status='active']:opacity-100 data-[status='active']:duration-500",
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
Write-Host "Created: $cursorTrailPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 2. Wrapper: components/ui/cursor-trail-banner.tsx (AI/course-relevant)
# ------------------------------------------------------------------
$bannerPath = Join-Path -Path $webApp -ChildPath "components\ui\cursor-trail-banner.tsx"

$bannerContent = @'
"use client";

import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";

// Course/AI-relevant imagery (same visual family already used across the
// landing page trending carousel + blog preview), instead of generic
// unsplash portraits.
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

export function CursorTrailBanner() {
  return (
    <section className="relative mx-auto w-full max-w-7xl px-4 pt-6 md:px-8">
      <div className="relative overflow-hidden rounded-[24px] border border-line bg-card shadow-sm">
        <ImageCursorTrail
          items={SHOWCASE_IMAGES}
          maxNumberOfImages={5}
          distance={25}
          imgClass="sm:w-40 w-28 sm:h-48 h-36"
          className="!h-[420px] max-w-none rounded-[24px] bg-paper-dim md:!h-[480px]"
        >
          <div className="pointer-events-none absolute inset-0 flex flex-col items-center justify-center gap-2 text-center">
            <span className="rounded-full border border-line bg-card/90 px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet backdrop-blur-sm">
              Move your cursor
            </span>
            <h2 className="font-display text-[26px] font-bold text-ink md:text-[38px]">
              Learn AI Skills. <span className="text-gradient-brand">Build Real Projects.</span>
            </h2>
          </div>
        </ImageCursorTrail>
      </div>
    </section>
  );
}

export default CursorTrailBanner;
'@

Write-Utf8NoBom -Path $bannerPath -Content $bannerContent
Write-Host "Created: $bannerPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 3. Wire it into the top of apps/web/app/(marketing)/page.tsx
# ------------------------------------------------------------------
$pagePath = Join-Path -Path $webApp -ChildPath "app\(marketing)\page.tsx"

if (-not (Test-Path $pagePath)) {
    Write-Host "ERROR: $pagePath not found." -ForegroundColor Red
    exit 1
}

$pageContent = [System.IO.File]::ReadAllText($pagePath)

# --- add import (after LimitedTimeOfferPricing import line) ---
$importAnchor = 'import { LimitedTimeOfferPricing } from "@/components/ui/limited-time-offer-pricing";'
if ($pageContent -notmatch [regex]::Escape('cursor-trail-banner')) {
    if ($pageContent.Contains($importAnchor)) {
        $newImportBlock = $importAnchor + "`r`nimport { CursorTrailBanner } from `"@/components/ui/cursor-trail-banner`";"
        $pageContent = $pageContent.Replace($importAnchor, $newImportBlock)
        Write-Host "Import added to page.tsx" -ForegroundColor Green
    } else {
        Write-Host "WARNING: import anchor not found, import not added (check LimitedTimeOfferPricing import still exists)." -ForegroundColor Yellow
    }
} else {
    Write-Host "Import already present, skipping." -ForegroundColor Yellow
}

# --- insert banner above Hero section ---
$heroAnchor = "    <div className=`"overflow-hidden`">`r`n      {/* Hero */}"
if ($pageContent -notmatch [regex]::Escape('<CursorTrailBanner')) {
    if ($pageContent.Contains($heroAnchor)) {
        $newHeroBlock = "    <div className=`"overflow-hidden`">`r`n      {/* Cursor Trail Showcase */}`r`n      <CursorTrailBanner />`r`n`r`n      {/* Hero */}"
        $pageContent = $pageContent.Replace($heroAnchor, $newHeroBlock)
        Write-Host "CursorTrailBanner inserted above Hero section." -ForegroundColor Green
    } else {
        Write-Host "ERROR: Hero anchor not found in page.tsx - no changes made to JSX. Check file manually." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "CursorTrailBanner already inserted, skipping." -ForegroundColor Yellow
}

Write-Utf8NoBom -Path $pagePath -Content $pageContent
Write-Host "Updated: $pagePath" -ForegroundColor Green

Write-Host "`nDone. Run 'npm run dev' (or your usual dev command) inside apps\web and check the top of the homepage." -ForegroundColor Cyan