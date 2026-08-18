<#
  SAI2 - Add missing Radix deps (@radix-ui/react-dropdown-menu, @radix-ui/react-avatar)
  to apps/web/package.json and refresh pnpm-lock.yaml.
  Run from repo root:
  D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
  Usage: powershell -ExecutionPolicy Bypass -File .\fix-missing-deps.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
Write-Host "Running in: $root" -ForegroundColor Cyan

$pkgJsonPath = Join-Path $root "apps\web\package.json"

if (-not (Test-Path $pkgJsonPath)) {
    Write-Host "ERROR: apps\web\package.json not found. Run this from the SAI2 repo root." -ForegroundColor Red
    exit 1
}

# --- check pnpm is available --------------------------------------------
$pnpmCmd = Get-Command pnpm -ErrorAction SilentlyContinue
if (-not $pnpmCmd) {
    Write-Host "ERROR: 'pnpm' not found on PATH. Install pnpm first (npm i -g pnpm) then re-run this script." -ForegroundColor Red
    exit 1
}

# --- resolve latest compatible versions ---------------------------------
Write-Host "Adding @radix-ui/react-dropdown-menu and @radix-ui/react-avatar to apps/web..." -ForegroundColor Cyan

Push-Location (Join-Path $root "apps\web")
try {
    pnpm add "@radix-ui/react-dropdown-menu" "@radix-ui/react-avatar"
    if ($LASTEXITCODE -ne 0) {
        throw "pnpm add failed with exit code $LASTEXITCODE"
    }
} finally {
    Pop-Location
}

Write-Host "pnpm add completed - package.json and pnpm-lock.yaml updated." -ForegroundColor Green

# --- verify they landed in package.json ---------------------------------
$pkgJson = Get-Content -Path $pkgJsonPath -Raw
$missing = @()
if ($pkgJson -notmatch '"@radix-ui/react-dropdown-menu"') { $missing += "@radix-ui/react-dropdown-menu" }
if ($pkgJson -notmatch '"@radix-ui/react-avatar"') { $missing += "@radix-ui/react-avatar" }

if ($missing.Count -gt 0) {
    Write-Host "WARNING: these deps still missing from package.json - add manually: $($missing -join ', ')" -ForegroundColor Yellow
} else {
    Write-Host "Confirmed both deps are now in apps\web\package.json" -ForegroundColor Green
}

# =========================================================================
# Summary
# =========================================================================
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host " 1. Verify build locally:"
Write-Host "      cd apps\web"
Write-Host "      npx tsc --noEmit"
Write-Host "      npx next build"
Write-Host " 2. Commit BOTH changed files (this is what was missing before):"
Write-Host "      git add apps/web/package.json pnpm-lock.yaml"
Write-Host "      git commit -m 'fix: add missing radix dropdown-menu/avatar deps'"
Write-Host "      git push"
Write-Host ""
Write-Host "Vercel installs with a frozen lockfile, so pnpm-lock.yaml MUST be committed" -ForegroundColor Yellow
Write-Host "along with package.json, or the deploy will fail again with the same error." -ForegroundColor Yellow