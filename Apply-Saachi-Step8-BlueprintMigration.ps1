<#
================================================================================
Apply-Saachi-Step8-BlueprintMigration.ps1
STEP 8: Migrate the REST of apps\web (auth, cart, checkout, learner dashboard,
pricing, search, legal, support, course-detail, etc.) from the old legacy
purple/soft-shadow look to the Blueprint (blue neo-brutalist) token system,
so the whole site reads as one consistent design language.

This is a regex-based repair pass (like Step 5) -- safe to re-run.

WHAT IT DOES:
  1. Hardcoded purple hex (#3525CD, #2A1DA3, #1E1B4B) -> Blueprint color vars
     (var(--token-color-amber) / amberDark / inkDeep)
  2. Legacy CSS var names (--token-color-primary, primaryHover, primaryTint,
     primaryDark) -> Blueprint equivalents (amber / amberDark / amberTint / inkDeep)
  3. Blurred Tailwind shadow utilities (shadow-sm / shadow-md / shadow-lg, and
     arbitrary rgba(...) box-shadows) -> hard-offset shadow tokens
     (var(--token-shadow-sm) etc, which are already "Npx Npx 0 ink" per tokens.ts)
  4. Loosely-rounded corners (rounded-xl / rounded-2xl / rounded-lg) -> the
     Blueprint radius scale (var(--token-radius-lg) / var(--token-radius-md))

WHAT IT DOES NOT DO (needs manual/visual pass later):
  - Border THICKNESS (skill wants 2px solid ink on every card/input/pill).
    Existing 1px gray borders are left as-is here because blindly rewriting
    every `border`/`border-[var(--token-color-border)]` risks breaking
    layouts that rely on hairline dividers vs. card outlines. Flag this as
    a follow-up visual QA pass once this step is applied.

USAGE:
  1. Save into repo root: D:\...\SAI2\Apply-Saachi-Step8-BlueprintMigration.ps1
  2. Run:  .\Apply-Saachi-Step8-BlueprintMigration.ps1
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

Write-Host "=== STEP 8: Blueprint design-token migration ==="
Write-Host "Scanning: $webRoot"
Write-Host ""

# Skip the design-system folder itself and files already on Blueprint tokens
# (marketing/*, marketplace/* were built in Steps 3-4 and already correct).
$targetFiles = Get-ChildItem -Path $webRoot -Recurse -Include *.tsx, *.ts -File |
    Where-Object {
        $_.FullName -notmatch "\\node_modules\\" -and
        $_.FullName -notmatch "\\lib\\design-system\\" -and
        $_.FullName -notmatch "\\components\\marketing\\" -and
        $_.FullName -notmatch "\\components\\marketplace\\"
    }

# Ordered list of (pattern, replacement) pairs. Order matters -- more specific
# patterns first so they aren't partially consumed by broader ones.
$replacements = @(
    # --- 1. Hardcoded legacy purple hex -> Blueprint color vars -----------
    @{ Pattern = '#3525CD'; Replacement = 'var(--token-color-amber)' }
    @{ Pattern = '#2A1DA3'; Replacement = 'var(--token-color-amberDark)' }
    @{ Pattern = '#1E1B4B'; Replacement = 'var(--token-color-inkDeep)' }

    # --- 2. Legacy CSS var names -> Blueprint equivalents ------------------
    @{ Pattern = 'var\(--token-color-primaryHover\)'; Replacement = 'var(--token-color-amberDark)' }
    @{ Pattern = 'var\(--token-color-primaryTint\)';  Replacement = 'var(--token-color-amberTint)' }
    @{ Pattern = 'var\(--token-color-primaryDark\)';  Replacement = 'var(--token-color-inkDeep)' }
    @{ Pattern = 'var\(--token-color-primary\)';      Replacement = 'var(--token-color-amber)' }
    @{ Pattern = '"var\(--token-color-primaryHover\)"'; Replacement = '"var(--token-color-amberDark)"' }

    # --- 3. Blurred shadows -> hard-offset shadow tokens -------------------
    @{ Pattern = 'shadow-\[0px_[0-9a-zA-Z_\.]*rgba\([^\]]*\)\]'; Replacement = 'shadow-[var(--token-shadow-sm)]' }
    @{ Pattern = '(?<!--token-)\bshadow-lg\b'; Replacement = 'shadow-[var(--token-shadow-lg)]' }
    @{ Pattern = '(?<!--token-)\bshadow-md\b'; Replacement = 'shadow-[var(--token-shadow-md)]' }
    @{ Pattern = '(?<!--token-)\bshadow-sm\b'; Replacement = 'shadow-[var(--token-shadow-sm)]' }

    # --- 4. Loosely-rounded corners -> Blueprint radius scale --------------
    @{ Pattern = '\brounded-2xl\b'; Replacement = 'rounded-[var(--token-radius-lg)]' }
    @{ Pattern = '\brounded-xl\b';  Replacement = 'rounded-[var(--token-radius-lg)]' }
    @{ Pattern = '\brounded-lg\b';  Replacement = 'rounded-[var(--token-radius-md)]' }
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
        Write-Host "  migrated ($fixCountForFile): $relativePath"
    }
}

Write-Host ""
Write-Host "=== STEP 8 complete: $filesChanged file(s) modified, $totalFixes total replacement(s). ==="
if ($filesChanged -gt 0) {
    Write-Host "Backups of originals: $backupDir"
}
Write-Host ""
Write-Host "Next: run 'pnpm --filter web run type-check' and 'pnpm --filter web run tokens:sync', then eyeball the auth/cart/checkout/dashboard pages."
Write-Host "NOTE: border thickness/color (skill wants 2px solid ink everywhere) was NOT touched -- that needs a visual pass, see script header."