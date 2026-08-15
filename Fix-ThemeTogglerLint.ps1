# Fix-ThemeTogglerLint.ps1
# Run this from: SAI2 root

$ErrorActionPreference = "Stop"

$targetFile = Join-Path $PSScriptRoot "apps\web\components\ui\animated-theme-toggler.tsx"

if (-not (Test-Path $targetFile)) {
    Write-Host "ERROR: Could not find $targetFile" -ForegroundColor Red
    exit 1
}

$content = Get-Content -Path $targetFile -Raw

$oldBlock = @'
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const transition = (document as any).startViewTransition(() => {
'@

$newBlock = @'
    const transition = (
      document as unknown as {
        startViewTransition: (callback: () => void) => { ready: Promise<void> };
      }
    ).startViewTransition(() => {
'@

if ($content -notmatch [regex]::Escape($oldBlock)) {
    if ($content -match "startViewTransition: \(callback") {
        Write-Host "Already fixed, no changes needed." -ForegroundColor Yellow
        exit 0
    }
    Write-Host "ERROR: Could not find the expected block. No changes made." -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$targetFile.bak-$timestamp"
Copy-Item -Path $targetFile -Destination $backupPath -Force
Write-Host "Backed up to: $backupPath" -ForegroundColor Yellow

$content = $content.Replace($oldBlock, $newBlock)
Set-Content -Path $targetFile -Value $content -Encoding UTF8 -NoNewline

Write-Host "Fixed: $targetFile" -ForegroundColor Green
Write-Host ""
Write-Host "Now run: cd apps\web; pnpm run build" -ForegroundColor DarkGray