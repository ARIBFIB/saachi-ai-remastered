# Increase-GalleryHeight.ps1
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
$webApp = Join-Path -Path $root -ChildPath "apps\web"
$galleryTrailPath = Join-Path -Path $webApp -ChildPath "components\ui\gallery-cursor-trail.tsx"

if (-not (Test-Path $galleryTrailPath)) {
    Write-Host "ERROR: $galleryTrailPath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

$content = [System.IO.File]::ReadAllText($galleryTrailPath)

$oldHeight = 'className="relative flex h-[220px] w-full max-w-[420px] items-stretch gap-1.5"'
$newHeight = 'className="relative flex h-[400px] w-full max-w-[420px] items-stretch gap-1.5"'

if ($content.Contains($oldHeight)) {
    $content = $content.Replace($oldHeight, $newHeight)
    Write-Utf8NoBom -Path $galleryTrailPath -Content $content
    Write-Host "Updated gallery height: 220px -> 400px" -ForegroundColor Green
} elseif ($content -match 'h-\[400px\] w-full max-w-\[420px\]') {
    Write-Host "Gallery height already updated, skipping." -ForegroundColor Yellow
} else {
    Write-Host "ERROR: expected height class not found - file may have been modified. Check components\ui\gallery-cursor-trail.tsx manually for the container div's className." -ForegroundColor Red
    exit 1
}

Write-Host "`nDone. cd apps\web ; pnpm dev to verify." -ForegroundColor Cyan