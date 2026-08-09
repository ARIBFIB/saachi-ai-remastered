# ============================================================================
# fix-dashboard-import-paths.ps1
# Run from: SAI2 root
# ============================================================================

$ErrorActionPreference = "Stop"

$root = Get-Location
$dashboardPagePath = Join-Path $root "apps\admin\app\(console)\dashboard\page.tsx"

if (-not (Test-Path $dashboardPagePath)) {
    Write-Error "Could not find $dashboardPagePath"
    exit 1
}

$content = Get-Content $dashboardPagePath -Raw

$before = $content

$content = $content -replace '\.\./\.\./lib/permissions', '../../../lib/permissions'
$content = $content -replace '\.\./\.\./lib/dashboard-config', '../../../lib/dashboard-config'

if ($content -eq $before) {
    Write-Host "  [SKIP] No matching import paths found - file may already be correct or structured differently." -ForegroundColor Yellow
} else {
    Set-Content -Path $dashboardPagePath -Value $content -Encoding UTF8
    Write-Host "  [OK] Fixed import paths in dashboard/page.tsx" -ForegroundColor Green
    Write-Host "       ../../lib/...  ->  ../../../lib/..." -ForegroundColor Green
}

Write-Host ""
Write-Host "Verify the fix:" -ForegroundColor Cyan
Select-String -Path $dashboardPagePath -Pattern "lib/permissions|lib/dashboard-config"