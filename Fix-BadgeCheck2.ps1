# ============================================================
#  Saachi AI - Fix BadgeCheck missing import (v2)
#  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
#  PS> .\Fix-BadgeCheck2.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$web  = Join-Path $root "apps\web"
$landingPath = Join-Path $web "app\(marketing)\page.tsx"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fixing BadgeCheck import (v2)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $landingPath)) {
    Write-Host "  [ERROR] Could not find $landingPath" -ForegroundColor Red
    exit 1
}

$landing = [System.IO.File]::ReadAllText($landingPath)

if ($landing -match '\bBadgeCheck\b') {
    Write-Host "  [SKIP] BadgeCheck already present somewhere in file" -ForegroundColor DarkGray
} else {
    $old = "  TrendingUp,`r`n  PlayCircle`r`n} from ""lucide-react"";"
    $new = "  TrendingUp,`r`n  PlayCircle,`r`n  BadgeCheck`r`n} from ""lucide-react"";"

    if ($landing.Contains($old)) {
        $landing = $landing.Replace($old, $new)
        [System.IO.File]::WriteAllText($landingPath, $landing, [System.Text.UTF8Encoding]::new($false))
        Write-Host "  [OK] BadgeCheck import added" -ForegroundColor Green
    } else {
        # fallback: try without CRLF (in case file uses LF only)
        $oldLf = "  TrendingUp,`n  PlayCircle`n} from ""lucide-react"";"
        $newLf = "  TrendingUp,`n  PlayCircle,`n  BadgeCheck`n} from ""lucide-react"";"
        if ($landing.Contains($oldLf)) {
            $landing = $landing.Replace($oldLf, $newLf)
            [System.IO.File]::WriteAllText($landingPath, $landing, [System.Text.UTF8Encoding]::new($false))
            Write-Host "  [OK] BadgeCheck import added (LF variant)" -ForegroundColor Green
        } else {
            Write-Host "  [WARN] Still could not find the exact block. Manual fix needed:" -ForegroundColor Yellow
            Write-Host "  Open the file and add BadgeCheck to the lucide-react import list." -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Done! Now run:" -ForegroundColor Cyan
Write-Host "  cd apps\web; pnpm run build" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""