<#
Fix-Mojibake-Encoding-All.ps1

Recursively scans apps/web and apps/admin (skipping node_modules, .next,
and other build output) for mojibake-corrupted text and fixes it in place.

IMPORTANT: This script is written using ONLY plain ASCII characters. All
the corrupted "marker" sequences it looks for (a-circumflex-euro, star
mojibake, etc.) are built from Unicode code points via [char]0xXXXX
instead of being typed literally in the file. This is deliberate -
typing the actual corrupted characters into a .ps1 file risks the file
itself getting re-mangled by whatever tool saves/transfers it, which is
exactly the bug we are trying to fix. Building strings from code points
sidesteps that completely.

Why the corruption happens:
  Somewhere in the pipeline, real UTF-8 characters (em dash, star, smart
  quotes, etc.) got misread as Windows-1252 and re-saved as UTF-8. That
  shows up as garbage sequences. This also shows up in a browser tab
  title when metadata.title in layout.tsx contains a corrupted dash.

How the fix works:
  Take the corrupted string's characters, re-encode them as Windows-1252
  bytes (this recovers the ORIGINAL utf8 byte sequence that got
  misinterpreted), then decode THOSE bytes as UTF-8 to get the correct
  text back. Plain ASCII text is unaffected by this round-trip.

  The script tries up to 2 passes per file (some files were corrupted
  twice) and stops as soon as no more known mojibake markers are found.

Run from the SAI2 project root:
    powershell -ExecutionPolicy Bypass -File .\Fix-Mojibake-Encoding-All.ps1

Preview only, no writes:
    powershell -ExecutionPolicy Bypass -File .\Fix-Mojibake-Encoding-All.ps1 -WhatIf
#>

param(
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

Write-Host "Project root: $root" -ForegroundColor Cyan
if ($WhatIf) { Write-Host "Running in -WhatIf (preview only) mode`n" -ForegroundColor Yellow }

# Directories to scan
$targetDirs = @(
    (Join-Path $root "apps\web"),
    (Join-Path $root "apps\admin")
)

# Directories to skip anywhere in the path
$excludeDirNames = @("node_modules", ".next", ".turbo", "dist", "build", ".git")

# File extensions to scan
$includeExtensions = @(".ts", ".tsx", ".js", ".jsx", ".mjs", ".css", ".json")

# --- Build mojibake marker strings from Unicode code points (safe, no literal
#     corrupted characters typed anywhere in this script file) ---

function CharsToString {
    param([int[]]$Codes)
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $Codes) { [void]$sb.Append([char]$c) }
    return $sb.ToString()
}

# a-circumflex (0x00E2) + euro sign (0x20AC)  -> covers most single mojibake
$marker_a_euro        = CharsToString @(0x00E2, 0x20AC)
# A-tilde (0x00C3) + cent sign (0x00A2) + a-circumflex (0x00E2)  -> double-encoded prefix
$marker_Atilde_cent   = CharsToString @(0x00C3, 0x00A2, 0x00E2)
# a-circumflex + small tilde (0x02DC) + horizontal ellipsis (0x2026) -> corrupted star
$marker_star          = CharsToString @(0x00E2, 0x02DC, 0x2026)
# A-circumflex alone (0x00C2) -> common leftover artifact (e.g. before nbsp)
$marker_Acirc         = CharsToString @(0x00C2)

$mojibakeMarkers = @($marker_a_euro, $marker_Atilde_cent, $marker_star, $marker_Acirc)

$utf8 = [System.Text.Encoding]::UTF8
$cp1252 = [System.Text.Encoding]::GetEncoding(1252)

function Test-HasMojibake {
    param([string]$Text)
    foreach ($marker in $mojibakeMarkers) {
        if ($Text.Contains($marker)) { return $true }
    }
    return $false
}

function Invoke-MojibakePass {
    param([string]$Text)
    # One round-trip: chars -> cp1252 bytes (recovers original utf8 bytes)
    # -> decode as utf8 (recovers correct text).
    return $utf8.GetString($cp1252.GetBytes($Text))
}

function Repair-Mojibake {
    param([string]$Text)

    if (-not (Test-HasMojibake $Text)) {
        return @{ Changed = $false; Text = $Text; Passes = 0 }
    }

    $current = $Text
    for ($pass = 1; $pass -le 2; $pass++) {
        try {
            $next = Invoke-MojibakePass -Text $current
        } catch {
            break
        }
        $current = $next
        if (-not (Test-HasMojibake $current)) {
            return @{ Changed = $true; Text = $current; Passes = $pass }
        }
    }

    # Ran out of passes but still improved something (or made no dent) -
    # report as changed only if actually different from the original.
    return @{ Changed = ($current -ne $Text); Text = $current; Passes = 2 }
}

$filesScanned = 0
$filesChanged = 0
$changedList = @()

foreach ($dir in $targetDirs) {
    if (-not (Test-Path -LiteralPath $dir)) {
        Write-Host "SKIP (dir not found): $dir" -ForegroundColor Yellow
        continue
    }

    $files = Get-ChildItem -LiteralPath $dir -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $ext = $_.Extension.ToLowerInvariant()
            if ($includeExtensions -notcontains $ext) { return $false }
            foreach ($ex in $excludeDirNames) {
                if ($_.FullName -match [regex]::Escape("\$ex\")) { return $false }
            }
            return $true
        }

    foreach ($file in $files) {
        $filesScanned++
        $text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)

        if (-not (Test-HasMojibake $text)) { continue }

        $result = Repair-Mojibake -Text $text

        if ($result.Changed) {
            $relPath = $file.FullName.Substring($root.Length).TrimStart("\")
            $filesChanged++
            $changedList += $relPath

            if ($WhatIf) {
                Write-Host "  WOULD FIX ($($result.Passes) pass): $relPath" -ForegroundColor Green
            } else {
                $noBomUtf8 = New-Object System.Text.UTF8Encoding($false)
                [System.IO.File]::WriteAllText($file.FullName, $result.Text, $noBomUtf8)
                Write-Host "  FIXED ($($result.Passes) pass): $relPath" -ForegroundColor Green
            }
        }
    }
}

Write-Host "`n----------------------------------------" -ForegroundColor Cyan
Write-Host "Scanned: $filesScanned files"
Write-Host "Changed: $filesChanged files"
if ($changedList.Count -gt 0) {
    Write-Host "`nChanged files:" -ForegroundColor Cyan
    $changedList | ForEach-Object { Write-Host "  - $_" }
}
Write-Host "`nRun 'git diff' to review before committing." -ForegroundColor Cyan
if ($WhatIf) {
    Write-Host "This was a preview (-WhatIf). Re-run WITHOUT -WhatIf to apply." -ForegroundColor Yellow
}