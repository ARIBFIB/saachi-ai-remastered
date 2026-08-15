# Fix-CursorTrailTypeError.ps1
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
$filePath = Join-Path -Path $root -ChildPath "apps\web\components\ui\image-cursor-trail.tsx"

if (-not (Test-Path $filePath)) {
    Write-Host "ERROR: $filePath not found. Run this from the SAI2 repo root." -ForegroundColor Red
    exit 1
}

$content = [System.IO.File]::ReadAllText($filePath)

$oldSignature = "const handleOnMove = (e: MouseEvent | Touch) => {"
$newSignature = "const handleOnMove = (e: { clientX: number; clientY: number }) => {"

$oldTouchHandler = 'onTouchMove={(e) => handleOnMove(e.touches[0])}'
$newTouchHandler = 'onTouchMove={(e) => handleOnMove({ clientX: e.touches[0].clientX, clientY: e.touches[0].clientY })}'

if (-not $content.Contains($oldSignature)) {
    Write-Host "ERROR: expected handleOnMove signature not found. File may already be patched or modified." -ForegroundColor Red
    exit 1
}

$content = $content.Replace($oldSignature, $newSignature)
$content = $content.Replace($oldTouchHandler, $newTouchHandler)

Write-Utf8NoBom -Path $filePath -Content $content
Write-Host "Patched: $filePath" -ForegroundColor Green
Write-Host "`nNow run: cd apps\web ; pnpm run build" -ForegroundColor Cyan