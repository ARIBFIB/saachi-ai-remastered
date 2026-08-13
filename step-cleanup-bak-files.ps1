<#
    step-cleanup-bak-files.ps1

    Finds and removes backup files across the SAI2 monorepo:
      - *.bak
      - *.bak-*
      - *.bak-final
      - page.tsx.bak, page.tsx.bak-YYYYMMDD-HHMMSS style timestamped backups

    Run from SAI2 root:
      PS D:\...\SAI2> .\step-cleanup-bak-files.ps1

    SAFE BY DEFAULT: runs in DRY-RUN mode first and just lists what would be
    deleted. Re-run with -Delete to actually remove the files.

      .\step-cleanup-bak-files.ps1            # dry run, lists files only
      .\step-cleanup-bak-files.ps1 -Delete    # actually deletes them
#>

param(
    [switch]$Delete
)

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

Write-Host "Scanning: $root" -ForegroundColor Cyan
Write-Host ""

# Match any file whose name contains ".bak" anywhere (covers .bak,
# .bak-final, .bak-20260813-143652, etc.), excluding node_modules/.git/.next
$bakFiles = Get-ChildItem -LiteralPath $root -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -match '\.bak' -and
        $_.FullName -notmatch '\\node_modules\\' -and
        $_.FullName -notmatch '\\\.git\\' -and
        $_.FullName -notmatch '\\\.next\\' -and
        $_.FullName -notmatch '\\dist\\'
    }

if (-not $bakFiles -or $bakFiles.Count -eq 0) {
    Write-Host "No backup files found. Nothing to clean up." -ForegroundColor Green
    exit 0
}

Write-Host "Found $($bakFiles.Count) backup file(s):" -ForegroundColor Yellow
Write-Host ""

$totalSize = 0
foreach ($f in $bakFiles) {
    $rel = $f.FullName.Substring($root.Length).TrimStart('\')
    $sizeKb = [math]::Round($f.Length / 1KB, 1)
    $totalSize += $f.Length
    Write-Host "  $rel  ($sizeKb KB)"
}

Write-Host ""
Write-Host "Total size: $([math]::Round($totalSize / 1KB, 1)) KB" -ForegroundColor Cyan
Write-Host ""

if (-not $Delete) {
    Write-Host "DRY RUN ONLY - no files were deleted." -ForegroundColor Yellow
    Write-Host "Re-run with -Delete to actually remove these files:" -ForegroundColor Yellow
    Write-Host "  .\step-cleanup-bak-files.ps1 -Delete" -ForegroundColor White
    exit 0
}

Write-Host "Deleting..." -ForegroundColor Red
$deletedCount = 0
$failedCount = 0

foreach ($f in $bakFiles) {
    try {
        [System.IO.File]::Delete($f.FullName)
        $deletedCount++
    }
    catch {
        Write-Host "  FAILED to delete: $($f.FullName) - $($_.Exception.Message)" -ForegroundColor Red
        $failedCount++
    }
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Deleted: $deletedCount" -ForegroundColor Green
if ($failedCount -gt 0) {
    Write-Host "Failed: $failedCount" -ForegroundColor Red
}