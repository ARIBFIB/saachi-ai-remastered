$ErrorActionPreference = "Stop"
$root = Get-Location

$globalsPath = Join-Path $root "apps\web\app\globals.css"
$homePath = Join-Path $root "apps\web\app\(marketing)\page.tsx"

foreach ($p in @($globalsPath, $homePath)) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Error "File not found: $p -- run this script from the SAI2 root."
        exit 1
    }
}

$backupDir = Join-Path $root "theme-migration-backup\step6"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item -LiteralPath $globalsPath -Destination (Join-Path $backupDir "globals.css.bak") -Force
Copy-Item -LiteralPath $homePath -Destination (Join-Path $backupDir "page.tsx.bak") -Force
Write-Host "Backups saved to: $backupDir"
Write-Host ""

$content = Get-Content -LiteralPath $globalsPath -Raw

# ---------------------------------------------------------------------------
# LIGHT MODE -- soft lavender/plum tint, clearly not white
# ---------------------------------------------------------------------------
$lightPairs = @(
    ,@('--color-paper: #f6f4f9;',        '--color-paper: #E9E1F5;')
    ,@('--color-paper-dim: #edeaf2;',    '--color-paper-dim: #DFD3EE;')
    ,@('--color-card: #f3f0f7;',         '--color-card: #F0E8FA;')
    ,@('--color-line: #e2dce9;',         '--color-line: #CDBBE3;')
    ,@('--color-line-strong: #cdc4d6;',  '--color-line-strong: #B49FD1;')
)

# ---------------------------------------------------------------------------
# DARK MODE -- deep plum/aubergine, clearly not black
# ---------------------------------------------------------------------------
$darkPairs = @(
    ,@('--color-paper: #08070b;',        '--color-paper: #1B1029;')
    ,@('--color-paper-dim: #16151a;',    '--color-paper-dim: #241736;')
    ,@('--color-card: #111015;',         '--color-card: #2A1B3F;')
    ,@('--color-line: #242229;',         '--color-line: #3D2B58;')
    ,@('--color-line-strong: #33313a;',  '--color-line-strong: #4E3873;')
)

$allPairs = $lightPairs + $darkPairs

foreach ($pair in $allPairs) {
    $old = $pair[0]
    $new = $pair[1]
    $count = ([regex]::Matches($content, [regex]::Escape($old))).Count
    if ($count -eq 1) {
        $content = $content.Replace($old, $new)
        Write-Host "OK   $old  ->  $new"
    } elseif ($count -gt 1) {
        Write-Host "SKIPPED (found $count times, expected 1): $old"
    } else {
        Write-Host "SKIPPED (not found -- may already be changed): $old"
    }
}

Set-Content -LiteralPath $globalsPath -Value $content -Encoding UTF8 -NoNewline
Write-Host ""
Write-Host "Updated: $globalsPath"

# ---------------------------------------------------------------------------
# Fix mojibake dash in the hero subheading (encoding artifact -> en dash)
# ---------------------------------------------------------------------------
$homeContent = Get-Content -LiteralPath $homePath -Raw
if ($homeContent -match [char]0xFFFD -or $homeContent.Contains("i¿½") -or $homeContent.Contains([char]0x00EF)) {
    # Broad sweep: replace the mojibake sequence around "AI era" with a clean en dash
    $homeContent = $homeContent -replace 'AI era\s*\S*\s*structured', 'AI era - structured'
    Set-Content -LiteralPath $homePath -Value $homeContent -Encoding UTF8 -NoNewline
    Write-Host "OK   Fixed mojibake dash in hero subheading (page.tsx)"
} else {
    Write-Host "SKIPPED -- mojibake pattern not found in page.tsx (may already be fixed)."
}

Write-Host ""
Write-Host "Step 6 complete."
Write-Host "Light mode is now a visibly tinted lavender (#E9E1F5 page, #F0E8FA cards)."
Write-Host "Dark mode is now a visibly tinted deep plum (#1B1029 page, #2A1B3F cards)."
Write-Host "Neither touches pure white (#ffffff) or pure black (#000000)."
Write-Host ""
Write-Host "Run: pnpm --filter web build"