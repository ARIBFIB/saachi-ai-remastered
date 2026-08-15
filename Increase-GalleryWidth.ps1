# Increase-GalleryWidth.ps1
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

# --- widen the overall container ---
$oldContainer = 'className="relative flex h-[400px] w-full max-w-[420px] items-stretch gap-1.5"'
$newContainer = 'className="relative flex h-[400px] w-full max-w-[620px] items-stretch gap-2"'

if ($content.Contains($oldContainer)) {
    $content = $content.Replace($oldContainer, $newContainer)
    Write-Host "Container width: max-w-[420px] -> max-w-[620px]" -ForegroundColor Green
} elseif ($content -match 'max-w-\[620px\]') {
    Write-Host "Container width already updated, skipping." -ForegroundColor Yellow
} else {
    Write-Host "ERROR: container className not found - check file manually." -ForegroundColor Red
    exit 1
}

# --- widen individual collapsed/expanded card widths ---
$oldCardWidths = 'isHovered ? "w-[170px] flex-grow-[3]" : "w-14 flex-grow"'
$newCardWidths = 'isHovered ? "w-[260px] flex-grow-[3]" : "w-20 flex-grow"'

if ($content.Contains($oldCardWidths)) {
    $content = $content.Replace($oldCardWidths, $newCardWidths)
    Write-Host "Card widths: collapsed 14->20, expanded 170px->260px" -ForegroundColor Green
} elseif ($content -match 'w-\[260px\] flex-grow-\[3\]') {
    Write-Host "Card widths already updated, skipping." -ForegroundColor Yellow
} else {
    Write-Host "ERROR: card width classes not found - check file manually." -ForegroundColor Red
    exit 1
}

# --- also widen the right-side placement's page.tsx offset isn't needed,
#     but adjust xl:right-4 stays same; container now controls total width.

Write-Utf8NoBom -Path $galleryTrailPath -Content $content
Write-Host "Updated: $galleryTrailPath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm dev to verify." -ForegroundColor Cyan