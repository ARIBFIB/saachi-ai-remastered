<#
================================================================================
Apply-Saachi-Step9-BorderNormalize.ps1
STEP 9: Border normalization pass across apps\web (everything Step 8 touched).

The skill's core rule #1 is "border, not shadow, creates depth" -- every card/
input/pill should have a solid black (ink) border, not a faint gray hairline.
This pass:

  1. Inline style={{ border: "1px solid var(--token-color-border)" }} and its
     color-mix(...) variants -> "2px solid var(--token-color-inkDeep)"
  2. Inline style={{ borderColor: "var(--token-color-border)" }} -> adds
     borderWidth/borderStyle so the border actually renders at 2px ink
  3. Tailwind gray/slate/zinc border-color utility classes
     (border-slate-300/30, border-zinc-200, border-[var(--token-color-border)],
     including /opacity variants) -> border-[var(--token-color-inkDeep)]

WHAT IT DOES NOT DO:
  - It does not force every Tailwind `border` (1px) utility up to `border-2`,
    since that requires knowing which element the class belongs to (some
    hairline dividers are intentionally 1px). Color is fixed everywhere;
    width bump only happens where it was already an inline style shorthand
    (item 1/2 above). If you want every card border bumped to 2px as well,
    say so and a more targeted pass can be built next.

USAGE:
  1. Save into repo root: D:\...\SAI2\Apply-Saachi-Step9-BorderNormalize.ps1
  2. Run:  .\Apply-Saachi-Step9-BorderNormalize.ps1
  3. Modified files are backed up first into .\_backup_stepwise\<timestamp>\
================================================================================
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$webRoot = Join-Path $root "apps\web"
if (-not (Test-Path $webRoot)) {
    Write-Host "Could not find apps\web under $root -- are you running this from the SAI2 root?" -ForegroundColor Red
    exit 1
}

$backupDir = Join-Path $root ("_backup_stepwise\{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$filesChanged = 0
$totalFixes = 0

Write-Host "=== STEP 9: Border normalization (light gray -> thick ink) ==="
Write-Host "Scanning: $webRoot"
Write-Host ""

$targetFiles = Get-ChildItem -Path $webRoot -Recurse -Include *.tsx, *.ts -File |
    Where-Object {
        $_.FullName -notmatch "\\node_modules\\" -and
        $_.FullName -notmatch "\\lib\\design-system\\" -and
        $_.FullName -notmatch "\\components\\marketing\\" -and
        $_.FullName -notmatch "\\components\\marketplace\\"
    }

$replacements = @(
    # --- Inline style shorthand: bump width to 2px + recolor to ink -------
    @{ Pattern = 'border:\s*"1px solid var\(--token-color-border\)"'; Replacement = 'border: "2px solid var(--token-color-inkDeep)"' }
    @{ Pattern = 'border:\s*"1px solid color-mix\(in srgb, var\(--token-color-border\) \d+%, transparent\)"'; Replacement = 'border: "2px solid var(--token-color-inkDeep)"' }
    @{ Pattern = 'border:\s*"1px solid color-mix\(in srgb, var\(--token-color-error\) \d+%, transparent\)"'; Replacement = 'border: "2px solid var(--token-color-error)"' }

    # --- Inline style borderColor-only -> recolor + force width/style -----
    @{ Pattern = 'borderColor:\s*"var\(--token-color-border\)"'; Replacement = 'borderColor: "var(--token-color-inkDeep)", borderWidth: "2px", borderStyle: "solid"' }

    # --- Tailwind gray/slate/zinc border-color utilities -> ink -----------
    @{ Pattern = '\bborder-slate-300/\d+\b'; Replacement = 'border-[var(--token-color-inkDeep)]' }
    @{ Pattern = '\bborder-zinc-200\b'; Replacement = 'border-[var(--token-color-inkDeep)]' }
    @{ Pattern = '\bborder-\[var\(--token-color-border\)\]/\d+\b'; Replacement = 'border-[var(--token-color-inkDeep)]' }
    @{ Pattern = '\bborder-\[var\(--token-color-border\)\]\b'; Replacement = 'border-[var(--token-color-inkDeep)]' }
)

foreach ($file in $targetFiles) {
    $original = [System.IO.File]::ReadAllText($file.FullName)
    if ($null -eq $original) { continue }

    $content = $original
    $fixCountForFile = 0

    foreach ($rule in $replacements) {
        $before = $content
        $content = [regex]::Replace($content, $rule.Pattern, $rule.Replacement)
        if ($content -ne $before) {
            $fixCountForFile += ([regex]::Matches($before, $rule.Pattern)).Count
        }
    }

    if ($content -ne $original) {
        $rootStr = $root.ToString()
        $relativePath = $file.FullName.Substring($rootStr.Length).TrimStart('\')

        $backupTarget = Join-Path $backupDir $relativePath
        $backupTargetDir = Split-Path $backupTarget -Parent
        if (-not (Test-Path $backupTargetDir)) {
            New-Item -ItemType Directory -Path $backupTargetDir -Force | Out-Null
        }
        Copy-Item -Path $file.FullName -Destination $backupTarget -Force

        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($file.FullName, $content, $utf8NoBom)
        $filesChanged++
        $totalFixes += $fixCountForFile
        Write-Host "  fixed ($fixCountForFile): $relativePath"
    }
}

Write-Host ""
Write-Host "=== STEP 9 complete: $filesChanged file(s) modified, $totalFixes total replacement(s). ==="
if ($filesChanged -gt 0) {
    Write-Host "Backups of originals: $backupDir"
}
Write-Host ""
Write-Host "Next: run 'pnpm --filter web run type-check', then visually check cards/inputs across the site for thick black borders."