<#
================================================================================
 08-repair-corrupted-syntax.ps1
================================================================================
 SURGICAL REPAIR for the two specific corruption patterns left behind by the
 earlier buggy theme scripts (04-...ps1's original border/shadow regex bug).
 This does NOT re-run the border-thickening or theming logic -- it only
 fixes broken syntax so the app compiles again. The border-2 CLASSNAME
 thickening that already succeeded correctly is left untouched.

 WHAT IT FIXES
 ----------------------------------------------------------------------------
 1. Invalid JS object keys produced by the old bug:
        style={{ border-2: "1px solid ..." }}
    ->  style={{ border: "1px solid ..." }}

    Also handles the ternary/conditional form seen in Pagination.tsx:
        : { border-2: `1px solid ${lineColor}`, color: inkSoft }
    ->  : { border: `1px solid ${lineColor}`, color: inkSoft }

 2. Nested/duplicated shadow token corruption, e.g.:
        shadow-[var(--token-shadow-[var(--token-shadow-sm)])]
        shadow-[var(--token-shadow-[var(--token-shadow-[var(--token-shadow-sm)])])]
    ->  shadow-[var(--token-shadow-sm)]
    (unwound iteratively so it doesn't matter how many times the buggy
    script ran / how deep the nesting got)

 SCOPE
 ----------------------------------------------------------------------------
 Scans every .ts/.tsx file under apps/web (app/ and components/), not just
 the file list from the earlier scripts, so nothing is missed regardless of
 how many times the buggy script was re-run.

 USAGE
 ----------------------------------------------------------------------------
   cd D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
   pwsh .\08-repair-corrupted-syntax.ps1 -WhatIf
   pwsh .\08-repair-corrupted-syntax.ps1

 After running:
   pnpm --filter web run tokens:sync
   pnpm --filter web build
================================================================================
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Write-Section($text) {
  Write-Host ""
  Write-Host "== $text ==" -ForegroundColor Cyan
}

function Backup-File([string]$path) {
  $bak = "$path.bak-$timestamp"
  Copy-Item -Path $path -Destination $bak -Force
  return $bak
}

$webRoot = Join-Path $RepoRoot "apps\web"
if (-not (Test-Path $webRoot)) {
  throw "Could not find apps\web under '$RepoRoot'. Run this from the SAI2 repo root, or pass -RepoRoot."
}

$appDir = Join-Path $webRoot "app"
$componentsDir = Join-Path $webRoot "components"

$targets = @()
if (Test-Path $appDir) { $targets += Get-ChildItem -Path $appDir -Recurse -Include "*.ts", "*.tsx" -File }
if (Test-Path $componentsDir) { $targets += Get-ChildItem -Path $componentsDir -Recurse -Include "*.ts", "*.tsx" -File }

Write-Section "Scanning $($targets.Count) files under app/ and components/"

$fixedBorderKey = 0
$fixedShadowNesting = 0
$totalFilesTouched = 0

foreach ($file in $targets) {
  $original = Get-Content -Path $file.FullName -Raw -Encoding UTF8
  $updated = $original
  $fileChanged = $false

  # ------------------------------------------------------------------
  # Fix 1: invalid `border-2:` object key -> `border:`
  # Safe because "border-2:" (with an immediately following colon) only
  # ever occurs from this specific bug -- legitimate Tailwind classes use
  # "border-2 " (space) or "border-2\"" (end quote), never "border-2:".
  # ------------------------------------------------------------------
  if ($updated -like "*border-2:*") {
    $before = $updated
    $updated = $updated -replace "border-2:", "border:"
    if ($updated -ne $before) {
      $fileChanged = $true
      $fixedBorderKey++
    }
  }

  # ------------------------------------------------------------------
  # Fix 2: unwind nested --token-shadow-[var(--token-shadow-X)] corruption,
  # however many levels deep, back to a single clean reference.
  # ------------------------------------------------------------------
  $nestedShadowPattern = '--token-shadow-\[var\(--token-shadow-(sm|md|lg)\)\]'
  $iterations = 0
  while ([regex]::IsMatch($updated, $nestedShadowPattern) -and $iterations -lt 10) {
    $before = $updated
    $updated = [regex]::Replace($updated, $nestedShadowPattern, '--token-shadow-$1')
    if ($updated -eq $before) { break }
    $fileChanged = $true
    $iterations++
  }
  if ($iterations -gt 0) { $fixedShadowNesting++ }

  if ($fileChanged) {
    $relPath = $file.FullName.Substring($webRoot.Length + 1)
    if ($PSCmdlet.ShouldProcess($file.FullName, "Repair corrupted border-2:/nested-shadow syntax")) {
      Backup-File $file.FullName | Out-Null
      Set-Content -Path $file.FullName -Value $updated -Encoding UTF8 -NoNewline
      Write-Host "  [repaired] $relPath" -ForegroundColor Green
      $totalFilesTouched++
    }
  }
}

Write-Section "Summary"
Write-Host "  Files repaired               : $totalFilesTouched"
Write-Host "  Files with border-2: fix     : $fixedBorderKey"
Write-Host "  Files with shadow-nesting fix: $fixedShadowNesting"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  pnpm --filter web run tokens:sync"
Write-Host "  pnpm --filter web build   # must pass before you push"
Write-Host ""
Write-Host "If the build passes, delete this run's .bak-$timestamp files and commit." -ForegroundColor DarkGray