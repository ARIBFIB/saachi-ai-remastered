# ============================================================
#  Saachi AI - Fix TopSearchBar wrapperRef type error
#  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
#  PS> .\Fix-WrapperRefType.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$web  = Join-Path $root "apps\web"
$filePath = Join-Path $web "app\_components\TopSearchBar.tsx"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fixing wrapperRef type in TopSearchBar.tsx" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $filePath)) {
    Write-Host "  [ERROR] Could not find $filePath" -ForegroundColor Red
    exit 1
}

$content = [System.IO.File]::ReadAllText($filePath)

$old = 'const wrapperRef = useRef<HTMLDivElement>(null);'
$new = 'const wrapperRef = useRef<HTMLFormElement>(null);'

if ($content.Contains($new)) {
    Write-Host "  [SKIP] Already fixed" -ForegroundColor DarkGray
} elseif ($content.Contains($old)) {
    $content = $content.Replace($old, $new)
    [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  [OK] wrapperRef type fixed to HTMLFormElement" -ForegroundColor Green
} else {
    Write-Host "  [WARN] Could not find the exact line. Please fix manually:" -ForegroundColor Yellow
    Write-Host "  Change: const wrapperRef = useRef<HTMLDivElement>(null);" -ForegroundColor Yellow
    Write-Host "  To:     const wrapperRef = useRef<HTMLFormElement>(null);" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Done! Now run:" -ForegroundColor Cyan
Write-Host "  cd apps\web; pnpm run build" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""