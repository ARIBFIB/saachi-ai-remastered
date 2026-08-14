<#
Fix-Mojibake-Encoding.ps1

Fixes corrupted "mojibake" text (e.g. "â€"", "â˜…", "Ã¢â‚¬â€") that appeared in
several files because UTF-8 characters (em dash —, star ★) got misread as
Windows-1252 at some point in the pipeline and re-saved as UTF-8.

How it works:
  Corrupted text = original UTF-8 bytes, misinterpreted as Windows-1252,
  then re-encoded as UTF-8.
  To undo it: take the corrupted string's UTF-8 bytes, decode THOSE bytes
  as Windows-1252 to recover the original byte sequence, then decode that
  sequence as UTF-8 to get the original correct text back.

  Files that were corrupted TWICE (double round-trip) need the fix applied
  twice. Plain ASCII text (all normal code) is unaffected by this transform,
  so it's safe to run on the whole file.

Run from the SAI2 project root:
    powershell -ExecutionPolicy Bypass -File .\Fix-Mojibake-Encoding.ps1
#>

$ErrorActionPreference = "Stop"

# Resolve project root = directory this script lives in
$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

Write-Host "Project root: $root" -ForegroundColor Cyan

# Files corrupted ONCE (single mojibake pass) -> fix pass count = 1
$singlePassFiles = @(
    "apps\web\app\(instructor)\instructor\analytics\page.tsx",
    "apps\web\app\(instructor)\instructor\courses\new\page.tsx",
    "apps\web\app\(instructor)\instructor\dashboard\page.tsx",
    "apps\web\app\(instructor)\instructor\mentorship\page.tsx"
)

# Files corrupted TWICE (double mojibake pass) -> fix pass count = 2
$doublePassFiles = @(
    "apps\web\app\(marketing)\page.tsx",
    "apps\web\lib\design-system\generate-css-vars.mjs"
)

function Fix-MojibakeText {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [int]$Passes = 1
    )

    $utf8 = [System.Text.Encoding]::UTF8
    $cp1252 = [System.Text.Encoding]::GetEncoding(1252)

    $current = $Text
    for ($i = 0; $i -lt $Passes; $i++) {
        # $current's chars -> raw cp1252 bytes (recovers the ORIGINAL utf8
        # byte sequence that got mis-decoded as cp1252) -> decode those
        # bytes as UTF-8 to get the correct text back.
        $current = $utf8.GetString($cp1252.GetBytes($current))
    }
    return $current
}

function Process-File {
    param(
        [string]$RelativePath,
        [int]$Passes
    )

    $fullPath = Join-Path $root $RelativePath

    if (-not (Test-Path -LiteralPath $fullPath)) {
        Write-Host "  SKIP (not found): $RelativePath" -ForegroundColor Yellow
        return
    }

    $original = [System.IO.File]::ReadAllText($fullPath, [System.Text.Encoding]::UTF8)
    $fixedText = Fix-MojibakeText -Text $original -Passes $Passes

    if ($fixedText -eq $original) {
        Write-Host "  No change needed: $RelativePath" -ForegroundColor DarkGray
        return
    }

    # Write back as UTF-8 without BOM
    $noBomUtf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $fixedText, $noBomUtf8)

    Write-Host "  FIXED ($Passes pass): $RelativePath" -ForegroundColor Green
}

Write-Host "`nFixing single-pass mojibake files..." -ForegroundColor Cyan
foreach ($f in $singlePassFiles) {
    Process-File -RelativePath $f -Passes 1
}

Write-Host "`nFixing double-pass mojibake files..." -ForegroundColor Cyan
foreach ($f in $doublePassFiles) {
    Process-File -RelativePath $f -Passes 2
}

Write-Host "`nDone. Please diff/review the changed files before committing." -ForegroundColor Cyan
Write-Host "Tip: run 'git diff' to confirm only the mojibake characters changed." -ForegroundColor Cyan