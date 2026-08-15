# ============================================================
#  Saachi AI - Fix BadgeCheck missing import (v3 - regex based)
#  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
#  PS> .\Fix-BadgeCheck3.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$web  = Join-Path $root "apps\web"
$landingPath = Join-Path $web "app\(marketing)\page.tsx"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fixing BadgeCheck import (v3)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $landingPath)) {
    Write-Host "  [ERROR] Could not find $landingPath" -ForegroundColor Red
    exit 1
}

$landing = [System.IO.File]::ReadAllText($landingPath)

# Match: import { ... } from "lucide-react";  (multiline, non-greedy)
$pattern = '(?s)import\s*\{(.*?)\}\s*from\s*"lucide-react";'

$match = [regex]::Match($landing, $pattern)

if (-not $match.Success) {
    Write-Host "  [ERROR] Could not find the lucide-react import statement at all." -ForegroundColor Red
    exit 1
}

$importBody = $match.Groups[1].Value

if ($importBody -match '\bBadgeCheck\b') {
    Write-Host "  [SKIP] BadgeCheck already imported from lucide-react" -ForegroundColor DarkGray
} else {
    # Insert BadgeCheck right after the opening brace, keep everything else the same
    $newImportBody = $importBody.TrimEnd()
    if ($newImportBody.EndsWith(",")) {
        $newImportBody = $newImportBody + "`n  BadgeCheck,"
    } else {
        $newImportBody = $newImportBody + ",`n  BadgeCheck"
    }

    $newImportStatement = "import {" + $newImportBody + "`n} from ""lucide-react"";"

    $landing = $landing.Substring(0, $match.Index) + $newImportStatement + $landing.Substring($match.Index + $match.Length)

    [System.IO.File]::WriteAllText($landingPath, $landing, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  [OK] BadgeCheck added to lucide-react import" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Done! Now run:" -ForegroundColor Cyan
Write-Host "  cd apps\web; pnpm run build" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""