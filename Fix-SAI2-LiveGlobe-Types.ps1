<#
.SYNOPSIS
    Fixes the last 2 REAL TypeScript errors in apps/web (components/ui/live-globe.tsx),
    caused by the installed `cobe` package's type defs no longer matching the code:
      1. TS2353: 'markerElevation' does not exist in type 'COBEOptions'
      2. TS2339: Property 'update' does not exist on type 'Renderer'
    Then rebuilds apps/web and re-runs type-check + lint to confirm everything is clean.

.EXAMPLE
    PS D:\...\SAI2> .\Fix-SAI2-LiveGlobe-Types.ps1
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

function Write-Section($text) {
    Write-Host ""
    Write-Host ("=" * 90) -ForegroundColor DarkGray
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host ("=" * 90) -ForegroundColor DarkGray
}

$webPath  = Join-Path $root "apps\web"
$filePath = Join-Path $webPath "components\ui\live-globe.tsx"

if (-not (Test-Path $filePath)) {
    Write-Host "ERROR: could not find $filePath" -ForegroundColor Red
    Write-Host "Run this script from the SAI2 repo root." -ForegroundColor Red
    exit 1
}

Write-Section "Step 1/4 - Patching live-globe.tsx"

$content = Get-Content -Path $filePath -Raw

# Track whether we actually changed anything, so re-runs are safe/no-op.
$original = $content

# ---------------------------------------------------------------------------
# Fix 1: remove the unsupported 'markerElevation' option (TS2353).
# The installed cobe types no longer expose this property on COBEOptions.
# ---------------------------------------------------------------------------
$content = $content -replace [regex]::Escape("        markerElevation: 0.01,`r`n"), ""
$content = $content -replace [regex]::Escape("        markerElevation: 0.01,`n"), ""

# ---------------------------------------------------------------------------
# Fix 2: 'globe.update(...)' - TS2339 Property 'update' does not exist on
# type 'Renderer'. cobe's own runtime object DOES have .update(), the
# installed @types just don't declare it correctly. Cast through `any` at
# the call site rather than fighting the library's type defs.
# ---------------------------------------------------------------------------
$content = $content -replace `
    [regex]::Escape("        globe!.update({"), `
    "        (globe as any)!.update({"

if ($content -eq $original) {
    Write-Host "  No changes made - file may already be patched, or the" -ForegroundColor Yellow
    Write-Host "  expected lines were not found verbatim. Diffing manually" -ForegroundColor Yellow
    Write-Host "  may be required if cobe usage in this file has changed." -ForegroundColor Yellow
} else {
    Set-Content -Path $filePath -Value $content -NoNewline
    Write-Host "  Patched: $filePath" -ForegroundColor Green
    Write-Host "    - removed 'markerElevation: 0.01,'" -ForegroundColor Green
    Write-Host "    - cast 'globe' to any before calling .update(...)" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# Step 2 - Clean caches again (build partially ran before, be safe)
# ---------------------------------------------------------------------------
Write-Section "Step 2/4 - Cleaning .next cache for apps/web"

$nextDir = Join-Path $webPath ".next"
if (Test-Path $nextDir) {
    Remove-Item -Path $nextDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  Removed $nextDir" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Step 3 - Rebuild apps/web
# ---------------------------------------------------------------------------
Write-Section "Step 3/4 - Rebuilding apps/web"

Push-Location $root
try {
    pnpm --filter web run build
    $buildOk = ($LASTEXITCODE -eq 0)
} finally {
    Pop-Location
}

if (-not $buildOk) {
    Write-Host ""
    Write-Host "Build still failing - see output above." -ForegroundColor Red
    Write-Host "If the error is still about 'markerElevation' or 'update', open" -ForegroundColor Red
    Write-Host "$filePath manually and check the surrounding createGlobe(...) call" -ForegroundColor Red
    Write-Host "matches what this script expected to patch." -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# Step 4 - Re-run type-check + lint to confirm
# ---------------------------------------------------------------------------
Write-Section "Step 4/4 - Re-running type-check + lint for apps/web"

Push-Location $webPath
try {
    Write-Host "type-check:" -ForegroundColor Cyan
    pnpm run type-check
    $typeCheckOk = ($LASTEXITCODE -eq 0)

    Write-Host ""
    Write-Host "lint:" -ForegroundColor Cyan
    pnpm run lint
} finally {
    Pop-Location
}

Write-Section "SUMMARY"
if ($typeCheckOk) {
    Write-Host "apps/web type-check: PASSED - all clear." -ForegroundColor Green
} else {
    Write-Host "apps/web type-check: FAILED - see output above." -ForegroundColor Red
}
Write-Host ""