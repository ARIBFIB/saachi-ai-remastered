# ============================================================
#  Saachi AI - Fix BadgeCheck missing import
#  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
#  PS> .\Fix-BadgeCheck.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$web  = Join-Path $root "apps\web"
$landingPath = Join-Path $web "app\(marketing)\page.tsx"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fixing BadgeCheck import" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $landingPath)) {
    Write-Host "  [ERROR] Could not find $landingPath" -ForegroundColor Red
    exit 1
}

$landing = [System.IO.File]::ReadAllText($landingPath)

if ($landing -match '\bBadgeCheck\b\s*,?\s*\r?\n\}\s*from\s*"lucide-react"') {
    Write-Host "  [SKIP] BadgeCheck already imported" -ForegroundColor DarkGray
} else {
    $pattern = '(\bPlayCircle\s*,\s*)\r?\n(\}\s*from\s*"lucide-react";)'
    if ($landing -match $pattern) {
        $landing = [regex]::Replace($landing, $pattern, "`$1`n  BadgeCheck,`n`$2")
        [System.IO.File]::WriteAllText($landingPath, $landing, [System.Text.UTF8Encoding]::new($false))
        Write-Host "  [OK] BadgeCheck import added" -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Could not find the lucide-react import block automatically." -ForegroundColor Yellow
        Write-Host "  Please add 'BadgeCheck,' manually to the lucide-react import in:" -ForegroundColor Yellow
        Write-Host "  $landingPath" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Done! Now run:" -ForegroundColor Cyan
Write-Host "  cd apps\web; pnpm run build" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""