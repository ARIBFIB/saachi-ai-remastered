<#
    fix-edit-page-import.ps1

    Fixes the relative import path in
    apps/web/app/(instructor)/instructor/courses/[id]/edit/page.tsx

    That file is one folder deeper than courses/new/page.tsx (extra [id]
    segment), so it needs one more "../" to reach apps/web/lib/categories.

    Run from SAI2 root:
      PS D:\...\SAI2> .\fix-edit-page-import.ps1
#>

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

$targetFile = Join-Path $root "apps\web\app\(instructor)\instructor\courses\[id]\edit\page.tsx"

if (-not (Test-Path -LiteralPath $targetFile)) {
    Write-Host "File not found: $targetFile" -ForegroundColor Red
    exit 1
}

$content = [System.IO.File]::ReadAllText($targetFile)

$old = '"../../../../../lib/categories"'
$new = '"../../../../../../lib/categories"'

if ($content -notmatch [regex]::Escape($old)) {
    Write-Host "Expected import string not found. File may already be fixed, or content differs." -ForegroundColor Yellow
    Write-Host "No changes made." -ForegroundColor Yellow
    exit 0
}

$fixed = $content.Replace($old, $new)
[System.IO.File]::WriteAllText($targetFile, $fixed, [System.Text.Encoding]::UTF8)

Write-Host "Fixed import path in:" -ForegroundColor Green
Write-Host "  apps\web\app\(instructor)\instructor\courses\[id]\edit\page.tsx" -ForegroundColor Green
Write-Host ""
Write-Host "Changed: $old" -ForegroundColor Cyan
Write-Host "     to: $new" -ForegroundColor Cyan