# ============================================================================
# step19-fix-nextjs15-params-types.ps1  (v3 -- fixed CRLF/LF mismatch)
#
# Fixes TS2344 errors: in Next.js 15, `params`/`searchParams` in page props
# must be typed as Promise<{...}>.
#
# v3 fix: v2's search strings spanned multiple lines using `n (LF), but the
# files on disk use Windows CRLF line endings, so the exact multi-line match
# never hit. This version replaces only the single inner line (no newline in
# the search pattern at all), so line-ending style doesn't matter.
#
# Run from SAI2 repo root:
#   PS D:\...\SAI2> .\step19-fix-nextjs15-params-types.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$webApp = Join-Path $root "apps\web\app"

function Patch-File {
    param(
        [string]$RelativePath,
        [string]$OldStr,
        [string]$NewStr
    )
    $fullPath = Join-Path $webApp $RelativePath

    if (-not [System.IO.File]::Exists($fullPath)) {
        Write-Host "  [SKIP - not found] $RelativePath" -ForegroundColor Yellow
        return
    }

    $content = [System.IO.File]::ReadAllText($fullPath)

    if ($content.Contains($NewStr)) {
        Write-Host "  [ALREADY OK] $RelativePath" -ForegroundColor DarkGray
        return
    }

    if (-not $content.Contains($OldStr)) {
        Write-Host "  [WARN - pattern not found] $RelativePath" -ForegroundColor Red
        return
    }

    $updated = $content.Replace($OldStr, $NewStr)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $updated, $utf8NoBom)
    Write-Host "  [OK] $RelativePath" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Patching Next.js 15 params/searchParams types (v3) ===" -ForegroundColor Cyan
Write-Host ""

# Single-line replacements only -- no embedded newlines, so CRLF vs LF
# on disk cannot break the match.

Patch-File "(learner)\dashboard\certificates\[certificateId]\page.tsx" `
    "params: { certificateId: string };" `
    "params: Promise<{ certificateId: string }>;"

Patch-File "(learner)\dashboard\community\[courseSlug]\page.tsx" `
    "params: { courseSlug: string };" `
    "params: Promise<{ courseSlug: string }>;"

Patch-File "(learner)\dashboard\mentorship\[instructorSlug]\page.tsx" `
    "params: { instructorSlug: string };" `
    "params: Promise<{ instructorSlug: string }>;"

Patch-File "(marketing)\categories\[slug]\page.tsx" `
    "params: { slug: string };" `
    "params: Promise<{ slug: string }>;"

Patch-File "(marketing)\courses\[slug]\page.tsx" `
    "params: { slug: string };" `
    "params: Promise<{ slug: string }>;"

Patch-File "(marketing)\instructors\[slug]\page.tsx" `
    "params: { slug: string };" `
    "params: Promise<{ slug: string }>;"

Patch-File "courses\[slug]\learn\page.tsx" `
    "params: { slug: string };" `
    "params: Promise<{ slug: string }>;"

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now run:" -ForegroundColor Yellow
Write-Host "  cd apps\web"
Write-Host "  pnpm run type-check"
Write-Host ""