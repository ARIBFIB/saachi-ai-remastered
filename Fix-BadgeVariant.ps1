# Fix-BadgeVariant.ps1
# Run this from: SAI2 root

$ErrorActionPreference = "Stop"

$targetFile = Join-Path $PSScriptRoot "apps\web\components\ui\limited-time-offer-pricing.tsx"

if (-not (Test-Path $targetFile)) {
    Write-Host "ERROR: Could not find $targetFile" -ForegroundColor Red
    exit 1
}

$content = Get-Content -Path $targetFile -Raw

$oldLine = '<Badge variant="secondary">15% off</Badge>'
$newLine = '<Badge>15% off</Badge>'

if ($content -notmatch [regex]::Escape($oldLine)) {
    if ($content -match [regex]::Escape($newLine)) {
        Write-Host "Already fixed, no changes needed." -ForegroundColor Yellow
        exit 0
    }
    Write-Host "ERROR: Could not find the expected Badge line. No changes made." -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$targetFile.bak-$timestamp"
Copy-Item -Path $targetFile -Destination $backupPath -Force
Write-Host "Backed up to: $backupPath" -ForegroundColor Yellow

$content = $content.Replace($oldLine, $newLine)
Set-Content -Path $targetFile -Value $content -Encoding UTF8 -NoNewline

Write-Host "Fixed: $targetFile" -ForegroundColor Green
Write-Host "Badge variant secondary changed to default, matching the Badge component type." -ForegroundColor Cyan
Write-Host ""
Write-Host "Now run: cd apps\web; pnpm run build" -ForegroundColor DarkGray