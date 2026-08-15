# Move-CursorTrailIntoHero.ps1
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
$bannerPath = Join-Path -Path $webApp -ChildPath "components\ui\cursor-trail-banner.tsx"
$heroCollageStylePath = Join-Path -Path $webApp -ChildPath "components\ui\hero-cursor-trail.tsx"

if (-not (Test-Path $pagePath)) {
    Write-Host "ERROR: $pagePath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# 1. New component sized/positioned to sit where HeroMediaCollage was
#    (right side of hero text, inside the hero section, not full-width)
# ------------------------------------------------------------------
$heroCursorTrailContent = @'
"use client";

import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";

// Course/AI-relevant imagery for the hero-side trail effect.
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

export function HeroCursorTrail() {
  return (
    <div className="pointer-events-auto absolute right-0 top-0 hidden h-[420px] w-[360px] lg:block xl:right-4 xl:h-[480px] xl:w-[420px]">
      <ImageCursorTrail
        items={SHOWCASE_IMAGES}
        maxNumberOfImages={5}
        distance={22}
        imgClass="w-24 h-28 xl:w-28 xl:h-32"
        className="!h-full !w-full rounded-2xl border border-line/60 bg-card/40 backdrop-blur-sm"
      />
    </div>
  );
}

export default HeroCursorTrail;
'@

Write-Utf8NoBom -Path $heroCollageStylePath -Content $heroCursorTrailContent
Write-Host "Created: $heroCollageStylePath" -ForegroundColor Green

# ------------------------------------------------------------------
# 2. Remove old top banner file if it exists (no longer used)
# ------------------------------------------------------------------
if (Test-Path $bannerPath) {
    Remove-Item -Path $bannerPath -Force
    Write-Host "Removed unused: $bannerPath" -ForegroundColor Yellow
}

# ------------------------------------------------------------------
# 3. Patch page.tsx:
#    - remove CursorTrailBanner import + usage above Hero (if present)
#    - swap <HeroMediaCollage /> for <HeroCursorTrail />
# ------------------------------------------------------------------
$pageContent = [System.IO.File]::ReadAllText($pagePath)

# Remove old import line
$oldImportLine = 'import { CursorTrailBanner } from "@/components/ui/cursor-trail-banner";'
if ($pageContent.Contains($oldImportLine)) {
    $pageContent = $pageContent.Replace("`r`n" + $oldImportLine, "")
    $pageContent = $pageContent.Replace($oldImportLine + "`r`n", "")
    $pageContent = $pageContent.Replace($oldImportLine, "")
    Write-Host "Removed old CursorTrailBanner import." -ForegroundColor Green
}

# Remove old banner usage block above Hero
$oldUsageBlock = "      {/* Cursor Trail Showcase */}`r`n      <CursorTrailBanner />`r`n`r`n      {/* Hero */}"
if ($pageContent.Contains($oldUsageBlock)) {
    $pageContent = $pageContent.Replace($oldUsageBlock, "      {/* Hero */}")
    Write-Host "Removed old CursorTrailBanner usage above Hero." -ForegroundColor Green
} else {
    Write-Host "No old banner usage block found above Hero (may already be clean)." -ForegroundColor Yellow
}

# Add new import (after HeroMediaCollage import line)
$heroImportAnchor = 'import { HeroMediaCollage } from "@/components/ui/hero-media-collage";'
if ($pageContent -notmatch [regex]::Escape('hero-cursor-trail')) {
    if ($pageContent.Contains($heroImportAnchor)) {
        $newImportBlock = $heroImportAnchor + "`r`nimport { HeroCursorTrail } from `"@/components/ui/hero-cursor-trail`";"
        $pageContent = $pageContent.Replace($heroImportAnchor, $newImportBlock)
        Write-Host "Added HeroCursorTrail import." -ForegroundColor Green
    } else {
        Write-Host "ERROR: HeroMediaCollage import anchor not found." -ForegroundColor Red
        exit 1
    }
}

# Swap <HeroMediaCollage /> usage for <HeroCursorTrail />
$oldUsage = "        <HeroMediaCollage />"
$newUsage = "        <HeroCursorTrail />"
if ($pageContent.Contains($oldUsage)) {
    $pageContent = $pageContent.Replace($oldUsage, $newUsage)
    Write-Host "Swapped HeroMediaCollage usage for HeroCursorTrail." -ForegroundColor Green
} elseif ($pageContent.Contains($newUsage)) {
    Write-Host "HeroCursorTrail already in place, skipping." -ForegroundColor Yellow
} else {
    Write-Host "ERROR: <HeroMediaCollage /> usage not found in page.tsx - check file manually." -ForegroundColor Red
    exit 1
}

Write-Utf8NoBom -Path $pagePath -Content $pageContent
Write-Host "Updated: $pagePath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan