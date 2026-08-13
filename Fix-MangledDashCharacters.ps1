# Fix-MangledDashCharacters.ps1
# Run from: SAI2/ root
# Fixes mangled UTF-8 em-dash characters ("Ã¢â‚¬â€") caused by encoding issues,
# replacing them with a plain " - " to avoid re-encoding problems in future.

$ErrorActionPreference = "Stop"

$targets = @(
    (Join-Path $PSScriptRoot "apps\web\app\(marketing)\page.tsx"),
    (Join-Path $PSScriptRoot "apps\web\lib\design-system\generate-css-vars.mjs")
)

$mangledPattern = "Ã¢â‚¬â€"

foreach ($file in $targets) {
    if (-not (Test-Path -LiteralPath $file)) {
        Write-Host "SKIP (not found): $file" -ForegroundColor Yellow
        continue
    }

    $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)

    if ($content.Contains($mangledPattern)) {
        $content = $content.Replace($mangledPattern, " - ")
        [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
        Write-Host "FIXED: $file" -ForegroundColor Green
    } else {
        Write-Host "No mangled characters found in: $file" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "Scan complete. Now searching entire apps/ and packages/ for any other occurrences..." -ForegroundColor Cyan

$allFiles = Get-ChildItem -Path (Join-Path $PSScriptRoot "apps"), (Join-Path $PSScriptRoot "packages") `
    -Recurse -Include *.ts, *.tsx, *.js, *.mjs, *.json, *.md -File -ErrorAction SilentlyContinue

$foundExtra = $false
foreach ($f in $allFiles) {
    try {
        $c = [System.IO.File]::ReadAllText($f.FullName, [System.Text.Encoding]::UTF8)
        if ($c.Contains($mangledPattern)) {
            $c = $c.Replace($mangledPattern, " - ")
            [System.IO.File]::WriteAllText($f.FullName, $c, [System.Text.Encoding]::UTF8)
            Write-Host "FIXED (extra): $($f.FullName)" -ForegroundColor Green
            $foundExtra = $true
        }
    } catch {
        # skip unreadable/binary files
    }
}

if (-not $foundExtra) {
    Write-Host "No additional mangled characters found elsewhere in apps/ or packages/." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Done. Now run:" -ForegroundColor Cyan
Write-Host "  git add ."
Write-Host "  git commit -m `"fix: replace mangled UTF-8 em-dash characters across project`""
Write-Host "  git push"