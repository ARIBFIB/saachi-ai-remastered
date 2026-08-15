# Fix-GalleryBelowText-And-ShiftTrailRight.ps1
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
$heroCursorTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\hero-cursor-trail.tsx"

if (-not (Test-Path $pagePath)) {
    Write-Host "ERROR: $pagePath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# 1. Remove GalleryCursorTrail from ABOVE the headline (badge area)
# ------------------------------------------------------------------
$pageContent = [System.IO.File]::ReadAllText($pagePath)

$topBlock = @'
          <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-line bg-card px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet">
            <Zap size={13} />
            42,000+ learners already building with AI
          </div>

          <div className="mb-8 max-w-2xl">
            <GalleryCursorTrail />
          </div>
'@

$revertedBadgeBlock = @'
          <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-line bg-card px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet">
            <Zap size={13} />
            42,000+ learners already building with AI
          </div>
'@

if ($pageContent.Contains($topBlock)) {
    $pageContent = $pageContent.Replace($topBlock, $revertedBadgeBlock)
    Write-Host "Removed GalleryCursorTrail from above the headline." -ForegroundColor Green
} else {
    Write-Host "Top placement block not found (may already be moved)." -ForegroundColor Yellow
}

# ------------------------------------------------------------------
# 2. Insert GalleryCursorTrail BELOW the paragraph text, right before
#    the CTA buttons ("Browse courses" / "Become an instructor").
# ------------------------------------------------------------------
$ctaAnchor = @'
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses" className="group">
'@

$newCtaBlock = @'
          <div className="mt-8 mb-2 max-w-2xl">
            <GalleryCursorTrail />
          </div>

          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses" className="group">
'@

if ($pageContent -notmatch [regex]::Escape('<GalleryCursorTrail')) {
    if ($pageContent.Contains($ctaAnchor)) {
        $pageContent = $pageContent.Replace($ctaAnchor, $newCtaBlock)
        Write-Host "Inserted GalleryCursorTrail below the paragraph, above CTA buttons." -ForegroundColor Green
    } else {
        Write-Host "ERROR: CTA anchor not found - check page.tsx Hero markup manually." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "GalleryCursorTrail already present elsewhere in page.tsx - skipping re-insert." -ForegroundColor Yellow
}

Write-Utf8NoBom -Path $pagePath -Content $pageContent
Write-Host "Updated: $pagePath" -ForegroundColor Green

# ------------------------------------------------------------------
# 3. Shift the right-side HeroCursorTrail slightly further right
# ------------------------------------------------------------------
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
 * never overlaps the heading, paragraph, or CTA buttons. Shifted
 * slightly further right (pl-12) so it sits clear of the text column.
 */
export function HeroCursorTrail() {
  return (
    <div
      className="pointer-events-none absolute inset-0 z-0 hidden pl-12 lg:block xl:pl-20"
      style={{
        maskImage: "linear-gradient(to right, transparent 0%, transparent 44%, black 62%, black 100%)",
        WebkitMaskImage: "linear-gradient(to right, transparent 0%, transparent 44%, black 62%, black 100%)"
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

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan