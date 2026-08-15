# Fix-ButtonAsChild.ps1
# Run this from: SAI2 root

$ErrorActionPreference = "Stop"

$targetFile = Join-Path $PSScriptRoot "apps\web\components\ui\limited-time-offer-pricing.tsx"

if (-not (Test-Path $targetFile)) {
    Write-Host "ERROR: Could not find $targetFile" -ForegroundColor Red
    exit 1
}

$content = Get-Content -Path $targetFile -Raw

if ($content -match "asChild") {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "$targetFile.bak-$timestamp"
    Copy-Item -Path $targetFile -Destination $backupPath -Force
    Write-Host "Backed up to: $backupPath" -ForegroundColor Yellow
} else {
    Write-Host "No asChild usage found, nothing to fix." -ForegroundColor Yellow
    exit 0
}

# --- Monthly button ---
$oldMonthly = @'
                  <Button className="w-full" variant="secondary" asChild>
                    <a href="/register">Start Your Journey</a>
                  </Button>
'@

$newMonthly = @'
                  
                    href="/register"
                    className="inline-flex h-11 w-full items-center justify-center gap-2 rounded-full border border-line-strong bg-card text-[15px] font-semibold text-ink transition-colors duration-150 ease-out hover:bg-paper-dim"
                  >
                    Start Your Journey
                  </a>
'@

if ($content -match [regex]::Escape($oldMonthly)) {
    $content = $content.Replace($oldMonthly, $newMonthly)
    Write-Host "Replaced Monthly CTA button." -ForegroundColor Green
} else {
    Write-Host "WARNING: Monthly CTA pattern not found, skipping." -ForegroundColor Yellow
}

# --- Yearly button ---
$oldYearly = @'
                  <Button className="w-full" variant="brand" asChild>
                    <a href="/register">Claim This Offer</a>
                  </Button>
'@

$newYearly = @'
                  
                    href="/register"
                    className="inline-flex h-11 w-full items-center justify-center gap-2 rounded-full font-semibold text-[15px] text-white transition-transform duration-150 ease-out hover:brightness-110"
                    style={{ backgroundImage: "var(--color-accent-gradient)" }}
                  >
                    Claim This Offer
                  </a>
'@

if ($content -match [regex]::Escape($oldYearly)) {
    $content = $content.Replace($oldYearly, $newYearly)
    Write-Host "Replaced Yearly CTA button." -ForegroundColor Green
} else {
    Write-Host "WARNING: Yearly CTA pattern not found, skipping." -ForegroundColor Yellow
}

# --- Remove now-unused Button import if no other Button usage remains ---
if ($content -notmatch "<Button") {
    $content = $content.Replace('import { Badge, Button } from "@saachi/ui";', 'import { Badge } from "@saachi/ui";')
    Write-Host "Removed unused Button import." -ForegroundColor Green
}

Set-Content -Path $targetFile -Value $content -Encoding UTF8 -NoNewline
Write-Host "Fixed: $targetFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now run: cd apps\web; pnpm run build" -ForegroundColor DarkGray