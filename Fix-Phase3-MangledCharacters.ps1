# Fix-Phase3-MangledCharacters.ps1
# Run from: SAI2/ root
# Fixes mangled UTF-8 em-dash/star characters in Phase 3a/3b/3c instructor files

$ErrorActionPreference = "Stop"

$mangledEmDash = "â€”"
$mangledStar = "â˜…"
$properStar = [string][char]0x2605  # proper filled star, as a string

$allFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "apps\web\app\(instructor)") `
    -Recurse -Include *.ts, *.tsx -File -ErrorAction SilentlyContinue

$fixedCount = 0
foreach ($f in $allFiles) {
    $content = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
    $original = $content

    $content = $content.Replace($mangledEmDash, "-")
    $content = $content.Replace($mangledStar, $properStar)

    if ($content -ne $original) {
        [System.IO.File]::WriteAllText($f.FullName, $content, [System.Text.Encoding]::UTF8)
        Write-Host "FIXED: $($f.FullName)" -ForegroundColor Green
        $fixedCount++
    }
}

if ($fixedCount -eq 0) {
    Write-Host "No mangled characters found." -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "$fixedCount file(s) fixed." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Now run:" -ForegroundColor Cyan
Write-Host "  pnpm --filter web build"
Write-Host "  (if clean) git add . ; git commit -m fix-mangled-chars-instructor ; git push"