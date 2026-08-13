<#
================================================================================
Apply-Saachi-Step5-BugFix.ps1
STEP 5: Regex-based repair pass across apps\web (.tsx/.ts files)

Fixes two recurring syntax bugs found in the exported code:

  BUG 1 — Invalid JS object key `border-2:` inside style={{ ... }}
          e.g.  style={{ border-2: "1px solid var(--token-color-border)" }}
          ->    style={{ border: "1px solid var(--token-color-border)" }}

  BUG 2 — Malformed nested shadow token, e.g.
          shadow-[var(--token-shadow-[var(--token-shadow-sm)])]
          shadow-[var(--token-shadow-[var(--token-shadow-[var(--token-shadow-sm)])])]
          ->    shadow-[var(--token-shadow-sm)]

This does NOT retype any file content -- it runs targeted regex replacements
against the files already on disk, so it's safe to run even on files that
were hand-edited after Step 4.

USAGE:
  1. Save into your repo root (same folder as previous steps):
     D:\...\SAI2\Apply-Saachi-Step5-BugFix.ps1
  2. Run:
       .\Apply-Saachi-Step5-BugFix.ps1
  3. Every modified file is backed up first into .\_backup_stepwise\<timestamp>\
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

Write-Host "=== STEP 5: Bug-fix regex pass ==="
Write-Host "Scanning: $webRoot"
Write-Host ""

$targetFiles = Get-ChildItem -Path $webRoot -Recurse -Include *.tsx, *.ts -File |
    Where-Object { $_.FullName -notmatch "\\node_modules\\" }

foreach ($file in $targetFiles) {
    $original = [System.IO.File]::ReadAllText($file.FullName)
    if ($null -eq $original) { continue }

    $content = $original
    $fixCountForFile = 0

    # --- BUG 1: invalid `border-2:` object key inside inline style ---------
    $before = $content
    $content = $content -replace '(\bstyle=\{\{\s*)border-2:', '$1border:'
    $content = $content -replace '([\{,]\s*)border-2:', '$1border:'
    if ($content -ne $before) {
        $fixCountForFile += ([regex]::Matches($before, 'border-2:')).Count
    }

    # --- BUG 2: collapse nested shadow-[var(--token-shadow-[...])] ---------
    # Run multiple passes to unwrap double/triple nesting.
    for ($i = 0; $i -lt 5; $i++) {
        $before2 = $content
        $content = $content -replace `
            'shadow-\[var\(--token-shadow-\[var\(--token-shadow-(\w+)\)\]\)\]', `
            'shadow-[var(--token-shadow-$1)]'
        if ($content -eq $before2) { break }
        $fixCountForFile += 1
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
Write-Host "=== STEP 5 complete: $filesChanged file(s) modified, $totalFixes total fix(es) applied. ==="
if ($filesChanged -gt 0) {
    Write-Host "Backups of originals: $backupDir"
}
Write-Host ""
Write-Host "Next: run 'pnpm --filter web run type-check' to confirm no remaining syntax errors."