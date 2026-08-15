<#
.SYNOPSIS
    Fixes the SAI2 apps/web TS6053 "File not found" errors caused by a stale
    or missing .next/types folder, then re-verifies with type-check + lint.

.DESCRIPTION
    The 65 reported TypeScript errors in apps/web are NOT real code errors.
    apps/web/tsconfig.json includes the pattern ".next/types/**/*.ts", which
    Next.js only generates during `next dev` or `next build`. If .next is
    missing, stale, or was deleted, tsc tries to type-check files that don't
    exist yet -> TS6053 for every route.

    This script:
      1. Removes stale .next output + tsbuildinfo caches for web + admin
      2. Reinstalls deps (optional, skipped by default unless -Reinstall)
      3. Builds apps/web (regenerates .next/types/**)
      4. Re-runs `tsc --noEmit` (type-check) and `next lint` for both apps
      5. Prints a clear pass/fail summary

.PARAMETER Reinstall
    If passed, runs `pnpm install` before building (use if node_modules
    looks broken/out of sync with pnpm-lock.yaml).

.PARAMETER SkipAdmin
    If passed, skips checking/building apps/admin (web-only fix).

.EXAMPLE
    PS D:\...\SAI2> .\Fix-SAI2-TypeErrors.ps1

.EXAMPLE
    PS D:\...\SAI2> .\Fix-SAI2-TypeErrors.ps1 -Reinstall
#>

[CmdletBinding()]
param(
    [switch]$Reinstall,
    [switch]$SkipAdmin
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

function Write-Section($text) {
    Write-Host ""
    Write-Host ("=" * 90) -ForegroundColor DarkGray
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host ("=" * 90) -ForegroundColor DarkGray
}

function Remove-IfExists($path) {
    if (Test-Path $path) {
        Write-Host "  Removing: $path" -ForegroundColor Yellow
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "  (not present, skipping): $path" -ForegroundColor DarkGray
    }
}

# ---------------------------------------------------------------------------
# 0. Sanity check: run from repo root
# ---------------------------------------------------------------------------
Write-Section "SAI2 - Fix stale .next type-check errors"

$webPath   = Join-Path $root "apps\web"
$adminPath = Join-Path $root "apps\admin"

if (-not (Test-Path $webPath)) {
    Write-Host "ERROR: apps\web not found under '$root'." -ForegroundColor Red
    Write-Host "Run this script from the SAI2 repo root, e.g.:" -ForegroundColor Red
    Write-Host "  PS D:\...\SAI2> .\Fix-SAI2-TypeErrors.ps1" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# 1. Clean stale caches
# ---------------------------------------------------------------------------
Write-Section "Step 1/5 - Cleaning stale .next / tsbuildinfo caches"

Remove-IfExists (Join-Path $webPath ".next")
Remove-IfExists (Join-Path $webPath "tsconfig.tsbuildinfo")

if (-not $SkipAdmin -and (Test-Path $adminPath)) {
    Remove-IfExists (Join-Path $adminPath ".next")
    Remove-IfExists (Join-Path $adminPath "tsconfig.tsbuildinfo")
}

# ---------------------------------------------------------------------------
# 2. Optional reinstall
# ---------------------------------------------------------------------------
if ($Reinstall) {
    Write-Section "Step 2/5 - Reinstalling dependencies (pnpm install)"
    Push-Location $root
    try {
        pnpm install
        if ($LASTEXITCODE -ne 0) { throw "pnpm install failed with exit code $LASTEXITCODE" }
    } finally {
        Pop-Location
    }
} else {
    Write-Section "Step 2/5 - Skipping reinstall (pass -Reinstall to force pnpm install)"
}

# ---------------------------------------------------------------------------
# 3. Build apps/web to regenerate .next/types
# ---------------------------------------------------------------------------
Write-Section "Step 3/5 - Building apps/web (regenerates .next/types/**)"

Push-Location $root
try {
    pnpm --filter web run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "Build failed. Fix any REAL build errors shown above first," -ForegroundColor Red
        Write-Host "then re-run this script." -ForegroundColor Red
        Pop-Location
        exit 1
    }
} finally {
    Pop-Location
}

if (-not $SkipAdmin -and (Test-Path $adminPath)) {
    Write-Host ""
    Write-Host "Building apps/admin too (keeps both apps' caches in sync)..." -ForegroundColor Cyan
    Push-Location $root
    try {
        pnpm --filter admin run build
        if ($LASTEXITCODE -ne 0) {
            Write-Host "WARNING: apps/admin build failed - see output above." -ForegroundColor Yellow
        }
    } finally {
        Pop-Location
    }
}

# ---------------------------------------------------------------------------
# 4. Re-run type-check for both apps
# ---------------------------------------------------------------------------
Write-Section "Step 4/5 - Re-running type-check (tsc --noEmit)"

$webTypeCheckOk = $true
Push-Location $webPath
try {
    Write-Host "apps/web:" -ForegroundColor Cyan
    pnpm run type-check
    if ($LASTEXITCODE -ne 0) { $webTypeCheckOk = $false }
} finally {
    Pop-Location
}

$adminTypeCheckOk = $true
if (-not $SkipAdmin -and (Test-Path $adminPath)) {
    Push-Location $adminPath
    try {
        Write-Host ""
        Write-Host "apps/admin:" -ForegroundColor Cyan
        pnpm run type-check
        if ($LASTEXITCODE -ne 0) { $adminTypeCheckOk = $false }
    } finally {
        Pop-Location
    }
}

# ---------------------------------------------------------------------------
# 5. Re-run lint for both apps
# ---------------------------------------------------------------------------
Write-Section "Step 5/5 - Re-running ESLint"

Push-Location $webPath
try {
    Write-Host "apps/web:" -ForegroundColor Cyan
    pnpm run lint
} finally {
    Pop-Location
}

if (-not $SkipAdmin -and (Test-Path $adminPath)) {
    Push-Location $adminPath
    try {
        Write-Host ""
        Write-Host "apps/admin:" -ForegroundColor Cyan
        pnpm run lint
    } finally {
        Pop-Location
    }
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Section "SUMMARY"

if ($webTypeCheckOk) {
    Write-Host "apps/web   type-check: PASSED" -ForegroundColor Green
} else {
    Write-Host "apps/web   type-check: FAILED (see output above - these are now REAL errors, not stale-cache noise)" -ForegroundColor Red
}

if (-not $SkipAdmin -and (Test-Path $adminPath)) {
    if ($adminTypeCheckOk) {
        Write-Host "apps/admin type-check: PASSED" -ForegroundColor Green
    } else {
        Write-Host "apps/admin type-check: FAILED (see output above)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Note: the 3 react-hooks/exhaustive-deps warnings in apps/admin" -ForegroundColor DarkGray
Write-Host "(dashboard/page.tsx, users/page.tsx) are non-blocking lint warnings," -ForegroundColor DarkGray
Write-Host "not build/type errors. Fix by moving 'allKpis' / 'toggleSelectAll' /" -ForegroundColor DarkGray
Write-Host "'buildActions' inside their useMemo callbacks or wrapping them in" -ForegroundColor DarkGray
Write-Host "useCallback(), as ESLint suggests." -ForegroundColor DarkGray
Write-Host ""