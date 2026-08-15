# Fix-GalleryPlacement-And-MatchTrailImages.ps1
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
# 1. gallery-cursor-trail.tsx: use the SAME images as the gallery
#    itself for the trail (single shared source of truth), and use
#    per-image hover so the trail shown matches the image being
#    hovered (that image + its neighbors), not unrelated images.
# ------------------------------------------------------------------
$galleryTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\gallery-cursor-trail.tsx"

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
 */
export function GalleryCursorTrail() {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  return (
    <div className="relative flex h-[320px] w-full items-center gap-2">
      {GALLERY_IMAGES.map((src, idx) => (
        <div
          key={idx}
          onMouseEnter={() => setHoveredIndex(idx)}
          onMouseLeave={() => setHoveredIndex(null)}
          className={cn(
            "group relative h-[320px] w-40 flex-grow overflow-hidden rounded-lg transition-all duration-500",
            "hover:w-full"
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

# image-gallery.tsx no longer separately needed by page.tsx (gallery is
# now inlined in gallery-cursor-trail.tsx), but keep the file for
# standalone reuse - just re-export from the shared source.
$galleryPath = Join-Path -Path $webApp -ChildPath "components\ui\image-gallery.tsx"
$galleryContent = @'
"use client";

import { cn } from "@/lib/utils";
import { GALLERY_IMAGES } from "@/components/ui/gallery-cursor-trail";

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
Write-Host "Updated: $galleryPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 2. Move GalleryCursorTrail to the TOP of the Hero section - right
#    under the "42,000+ learners" badge, ABOVE the H1 headline - so
#    it's immediately visible, prominent, full width of the text
#    column area, not hidden further down.
# ------------------------------------------------------------------
$pageContent = [System.IO.File]::ReadAllText($pagePath)

# Remove the previous placement (bottom of hero, after ActivityTicker) if present
$oldBottomBlock = @'
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

$revertedBottomBlock = @'
          <div className="mt-6">
            <ActivityTicker />
          </div>
        </div>

        <HeroCursorTrail />
      </section>
'@

if ($pageContent.Contains($oldBottomBlock)) {
    $pageContent = $pageContent.Replace($oldBottomBlock, $revertedBottomBlock)
    Write-Host "Removed old bottom-of-hero gallery placement." -ForegroundColor Green
}

# Insert near the top of the hero, right after the "learners" badge div,
# before the H1 headline block.
$badgeAnchor = @'
          <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-line bg-card px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet">
            <Zap size={13} />
            42,000+ learners already building with AI
          </div>
'@

$newTopBlock = @'
          <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-line bg-card px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet">
            <Zap size={13} />
            42,000+ learners already building with AI
          </div>

          <div className="mb-8 max-w-2xl">
            <GalleryCursorTrail />
          </div>
'@

if ($pageContent -notmatch [regex]::Escape('<GalleryCursorTrail')) {
    if ($pageContent.Contains($badgeAnchor)) {
        $pageContent = $pageContent.Replace($badgeAnchor, $newTopBlock)
        Write-Host "Inserted GalleryCursorTrail at the TOP of the Hero section." -ForegroundColor Green
    } else {
        Write-Host "ERROR: badge anchor not found - check page.tsx Hero markup manually." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "GalleryCursorTrail already present in page.tsx, skipping insertion (only image source patched)." -ForegroundColor Yellow
}

Write-Utf8NoBom -Path $pagePath -Content $pageContent
Write-Host "Updated: $pagePath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan