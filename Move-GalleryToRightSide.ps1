# Move-GalleryToRightSide.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$webApp = Join-Path -Path $root -ChildPath "apps\web"
$pagePath = Join-Path -Path $webApp -ChildPath "app\(marketing)\page.tsx"
$galleryTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\gallery-cursor-trail.tsx"

if (-not (Test-Path $pagePath)) {
    Write-Host "ERROR: $pagePath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# 1. Make GalleryCursorTrail render as a compact VERTICAL-friendly
#    strip that fits a right-side column (narrower cards, taller box).
# ------------------------------------------------------------------
$galleryTrailContent = @'
"use client";

import { useState } from "react";
import { cn } from "@/lib/utils";
import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";

// Single shared image set: same images render as the gallery strip AND
// as the cursor-trail images, so the trail always matches what's shown.
export const GALLERY_IMAGES = [
  "https://images.unsplash.com/photo-1555949963-aa79dcee981c?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1531482615713-2afd69097998?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1550439062-609e1531270e?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&h=800&w=800&auto=format&fit=crop"
];

/**
 * Renders the gallery strip. On hovering any single image, the cursor
 * trail activates using THAT SAME IMAGE (repeated) so the trail is
 * always directly related to the image being hovered.
 *
 * `orientation="vertical"` renders a compact right-column-friendly
 * layout (fewer, taller cards) instead of the full-width horizontal
 * strip.
 */
export function GalleryCursorTrail({
  orientation = "horizontal"
}: {
  orientation?: "horizontal" | "vertical";
}) {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  const images = orientation === "vertical" ? GALLERY_IMAGES.slice(0, 4) : GALLERY_IMAGES;

  return (
    <div
      className={cn(
        "relative flex w-full",
        orientation === "vertical"
          ? "h-[440px] flex-col gap-2"
          : "h-[320px] items-center gap-2"
      )}
    >
      {images.map((src, idx) => (
        <div
          key={idx}
          onMouseEnter={() => setHoveredIndex(idx)}
          onMouseLeave={() => setHoveredIndex(null)}
          className={cn(
            "group relative flex-grow overflow-hidden rounded-lg transition-all duration-500",
            orientation === "vertical" ? "w-full h-24 hover:h-full" : "h-[320px] w-40 hover:w-full"
          )}
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            className="h-full w-full object-cover object-center"
            src={src}
            alt={`saachi-ai-gallery-${idx}`}
          />

          <ImageCursorTrail
            items={[src, src, src]}
            active={hoveredIndex === idx}
            maxNumberOfImages={3}
            distance={14}
            imgClass="w-20 h-24"
            className="!absolute !inset-0 !h-full !w-full !rounded-lg !bg-transparent"
          />
        </div>
      ))}
    </div>
  );
}

export default GalleryCursorTrail;
'@

Write-Utf8NoBom -Path $galleryTrailPath -Content $galleryTrailContent
Write-Host "Updated: $galleryTrailPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 2. page.tsx: remove gallery from below the paragraph/CTA area,
#    move it into the RIGHT-SIDE column (where HeroCursorTrail sits),
#    stacked with it so trail plays over the gallery's right column.
# ------------------------------------------------------------------
$pageContent = [System.IO.File]::ReadAllText($pagePath)

# --- remove old below-text placement ---
$oldCtaBlock = @'
          <div className="mt-8 mb-2 max-w-2xl">
            <GalleryCursorTrail />
          </div>

          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses" className="group">
'@

$revertedCtaBlock = @'
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses" className="group">
'@

if ($pageContent.Contains($oldCtaBlock)) {
    $pageContent = $pageContent.Replace($oldCtaBlock, $revertedCtaBlock)
    Write-Host "Removed GalleryCursorTrail from below the paragraph/CTA area." -ForegroundColor Green
} else {
    Write-Host "Below-text placement not found (may already be moved)." -ForegroundColor Yellow
}

# --- insert into the right-side column, alongside HeroCursorTrail ---
$rightColumnAnchor = "        <HeroCursorTrail />`r`n      </section>"

$newRightColumnBlock = @'
        <div className="pointer-events-auto absolute right-0 top-1/2 z-10 hidden w-[380px] -translate-y-1/2 lg:block xl:right-4 xl:w-[420px]">
          <GalleryCursorTrail orientation="vertical" />
        </div>

        <HeroCursorTrail />
      </section>
'@

if ($pageContent -notmatch [regex]::Escape('orientation="vertical"')) {
    if ($pageContent.Contains($rightColumnAnchor)) {
        $pageContent = $pageContent.Replace($rightColumnAnchor, $newRightColumnBlock)
        Write-Host "Inserted GalleryCursorTrail into the RIGHT-SIDE column." -ForegroundColor Green
    } else {
        Write-Host "ERROR: right-column anchor (HeroCursorTrail closing) not found - check page.tsx manually." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "GalleryCursorTrail already in right column, skipping." -ForegroundColor Yellow
}

Write-Utf8NoBom -Path $pagePath -Content $pageContent
Write-Host "Updated: $pagePath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan