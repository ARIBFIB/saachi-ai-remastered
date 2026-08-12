<#
================================================================================
Remove-BakFiles.ps1

Finds and deletes all *.bak files under the given root (default: current
directory). Skips node_modules and .git by default for speed/safety.

Usage:
    PS> .\Remove-BakFiles.ps1                # preview only (dry run)
    PS> .\Remove-BakFiles.ps1 -Apply         # actually delete

    PS> .\Remove-BakFiles.ps1 -RepoRoot "D:\...\SAI2" -Apply
================================================================================
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path,
    [switch]$Apply,
    [string[]]$ExcludeDirs = @("node_modules", ".git", ".next", ".fix-backups")
)

Write-Host "Searching for *.bak files under: $RepoRoot" -ForegroundColor Cyan

$excludePattern = ($ExcludeDirs | ForEach-Object { [regex]::Escape($_) }) -join "|"

$bakFiles = Get-ChildItem -Path $RepoRoot -Recurse -Filter "*.bak" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch "\\($excludePattern)\\" }

if ($bakFiles.Count -eq 0) {
    Write-Host "No .bak files found." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Found $($bakFiles.Count) .bak file(s):" -ForegroundColor Yellow
$totalSize = 0
foreach ($f in $bakFiles) {
    $relative = $f.FullName.Substring($RepoRoot.Length).TrimStart('\')
    Write-Host "  $relative  ($([math]::Round($f.Length / 1KB, 1)) KB)"
    $totalSize += $f.Length
}
Write-Host ""
Write-Host "Total size: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Cyan

if (-not $Apply) {
    Write-Host ""
    Write-Host "Dry run only -- no files deleted. Re-run with -Apply to delete them." -ForegroundColor Magenta
    exit 0
}

Write-Host ""
$confirm = Read-Host "Delete all $($bakFiles.Count) file(s) listed above? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Cancelled -- no files deleted." -ForegroundColor Yellow
    exit 0
}

$deleted = 0
foreach ($f in $bakFiles) {
    try {
        Remove-Item -LiteralPath $f.FullName -Force
        $deleted++
    } catch {
        Write-Host "  FAILED to delete: $($f.FullName) -- $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Deleted $deleted of $($bakFiles.Count) file(s)." -ForegroundColor Green