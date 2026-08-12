<#
================================================================================
 fix-mojibake-web.ps1  (v2 -- .NET File I/O, PowerShell 5.1 safe)
 Fixes UTF-8/ANSI mojibake corruption in apps/web (bullet, ellipsis,
 copyright, pound-sign sequences that were double-encoded).

 v2 CHANGE: Replaced Get-Content -Raw -Encoding UTF8 (which threw
 "A parameter cannot be found that matches parameter name 'Raw'" on some
 Windows PowerShell 5.1 setups -- usually caused by a conflicting alias/
 profile function shadowing Get-Content) with plain .NET
 [System.IO.File]::ReadAllText / WriteAllText calls. This sidesteps
 PowerShell's own cmdlet binding entirely.

 USAGE:
   Place this script at the SAI2 monorepo root (same level as apps/, packages/)
   and run:
     powershell -ExecutionPolicy Bypass -File .\fix-mojibake-web.ps1

 SAFE TO RE-RUN.
================================================================================
#>

$ErrorActionPreference = "Stop"

$root = Join-Path $PSScriptRoot "apps\web"

if (-not (Test-Path -LiteralPath $root)) {
    Write-Host "ERROR: Could not find apps\web relative to this script. Place this script at the SAI2 monorepo root." -ForegroundColor Red
    exit 1
}

# Map of corrupt byte-sequence (as literal string, read as UTF-8) -> correct replacement.
$replacements = [ordered]@{
    "Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢Ã¢â‚¬Â¢" = "Enter your password"
    "Ã¢â‚¬Â¢" = "*"
    "â€¦" = "..."
    "Â©" = "(c)"
    "Ã‚Â£" = "GBP "
}

$extensions = @(".tsx", ".ts", ".css", ".json")

$files = [System.Collections.Generic.List[string]]::new()
Get-ChildItem -LiteralPath $root -Recurse -File | ForEach-Object {
    if ($_.FullName -notmatch "\\node_modules\\" -and $_.FullName -notmatch "\\\.next\\") {
        if ($extensions -contains $_.Extension.ToLower()) {
            $files.Add($_.FullName)
        }
    }
}

$totalFilesChanged = 0
$totalReplacements = 0
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($filePath in $files) {
    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    if ([string]::IsNullOrEmpty($content)) { continue }

    $fileChangeCount = 0

    foreach ($key in $replacements.Keys) {
        if ($content.Contains($key)) {
            $occurrences = ([regex]::Matches($content, [regex]::Escape($key))).Count
            $content = $content.Replace($key, $replacements[$key])
            $fileChangeCount += $occurrences
        }
    }

    if ($fileChangeCount -gt 0) {
        [System.IO.File]::WriteAllText($filePath, $content, $utf8NoBom)
        $totalFilesChanged++
        $totalReplacements += $fileChangeCount
        $relativePath = $filePath.Substring($root.Length + 1)
        Write-Host "Fixed $fileChangeCount occurrence(s) in $relativePath" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "Done. $totalFilesChanged file(s) changed, $totalReplacements total replacement(s)." -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan

if ($totalFilesChanged -eq 0) {
    Write-Host "No mojibake sequences found -- files may already be clean, or new corruption patterns exist that this script doesn't cover yet." -ForegroundColor Yellow
}