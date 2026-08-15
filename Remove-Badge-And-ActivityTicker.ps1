# Remove-Badge-And-ActivityTicker.ps1
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
$pagePath = Join-Path -Path $webApp -ChildPath "app\(marketing)\page.tsx"

if (-not (Test-Path $pagePath)) {
    Write-Host "ERROR: $pagePath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

$content = [System.IO.File]::ReadAllText($pagePath)

# --- 1. Remove "42,000+ learners already building with AI" badge ---
$oldBadge = @'
          <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-line bg-card px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet">
            <Zap size={13} />
            42,000+ learners already building with AI
          </div>
'@

if ($content.Contains($oldBadge)) {
    $content = $content.Replace($oldBadge, "")
    Write-Host "Removed '42,000+ learners already building with AI' badge." -ForegroundColor Green
} else {
    Write-Host "Badge block not found (may already be removed)." -ForegroundColor Yellow
}

# --- 2. Remove ActivityTicker usage ("Omar Sheikh booked a mentorship...") ---
$oldTickerBlock = @'
          <div className="mt-6">
            <ActivityTicker />
          </div>
'@

if ($content.Contains($oldTickerBlock)) {
    $content = $content.Replace($oldTickerBlock, "")
    Write-Host "Removed ActivityTicker usage." -ForegroundColor Green
} else {
    Write-Host "ActivityTicker usage block not found (may already be removed)." -ForegroundColor Yellow
}

# --- 3. Remove the now-unused import ---
$oldImport = 'import { ActivityTicker } from "./_components/ActivityTicker";'
if ($content.Contains($oldImport)) {
    $content = $content.Replace("`r`n" + $oldImport, "")
    $content = $content.Replace($oldImport + "`r`n", "")
    $content = $content.Replace($oldImport, "")
    Write-Host "Removed ActivityTicker import." -ForegroundColor Green
} else {
    Write-Host "ActivityTicker import not found (may already be removed)." -ForegroundColor Yellow
}

Write-Utf8NoBom -Path $pagePath -Content $content
Write-Host "Updated: $pagePath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan