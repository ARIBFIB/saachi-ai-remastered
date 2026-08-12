<#
================================================================================
Check-DynamicRoutes.ps1   (read-only -- makes NO changes to your repo)

Run this from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>

    PS D:\...\SAI2> .\Check-DynamicRoutes.ps1

WHAT THIS DOES:
  The 7 dynamic-route pages below have twice failed to read in export/dump
  tools (bracket-folder wildcard bug in whatever tool produced those dumps).
  This script uses -LiteralPath throughout, so it reads them correctly
  regardless of the [slug]/[id]-style folder names.

  For each file it:
    - Confirms it exists
    - Reports its size in bytes
    - Flags it RED if empty or near-empty (likely a stub/placeholder)
    - Checks whether it already uses the Next.js 15 async params pattern
      (searchParams: Promise<...> / params: Promise<...> plus an `await`)
    - Writes the full content into one consolidated report file so it can
      be reviewed without opening 7 separate files

OUTPUT:
  DynamicRoutesReport.txt is created in the repo root. Share its contents
  back for review, or open it yourself in a text editor.
================================================================================
#>

[CmdletBinding()]
param(
    [string]$RepoRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$webRoot = Join-Path $RepoRoot "apps\web"
$reportPath = Join-Path $RepoRoot "DynamicRoutesReport.txt"

$routesToCheck = @(
    "app\(learner)\dashboard\certificates\[certificateId]\page.tsx",
    "app\(learner)\dashboard\community\[courseSlug]\page.tsx",
    "app\(learner)\dashboard\mentorship\[instructorSlug]\page.tsx",
    "app\(marketing)\categories\[slug]\page.tsx",
    "app\(marketing)\courses\[slug]\page.tsx",
    "app\(marketing)\instructors\[slug]\page.tsx",
    "app\courses\[slug]\learn\page.tsx"
)

if (-not (Test-Path -LiteralPath $webRoot)) {
    Write-Host "Could not find apps\web under '$RepoRoot'. Run this script from the SAI2 repo root." -ForegroundColor Red
    exit 1
}

$reportLines = New-Object System.Collections.Generic.List[string]
$reportLines.Add("================================================================================")
$reportLines.Add("DYNAMIC ROUTES REPORT")
$reportLines.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$reportLines.Add("================================================================================")

Write-Host ""
Write-Host "==== Checking 7 dynamic route files ====" -ForegroundColor Cyan

$summary = @()

foreach ($rel in $routesToCheck) {
    $full = Join-Path $webRoot $rel

    if (-not (Test-Path -LiteralPath $full)) {
        Write-Host "  MISSING: $rel" -ForegroundColor Red
        $summary += [PSCustomObject]@{ Route = $rel; Status = "MISSING"; SizeBytes = 0; HasAsyncParams = $false }

        $reportLines.Add("")
        $reportLines.Add("================================================================================")
        $reportLines.Add("FILE: $rel")
        $reportLines.Add("STATUS: MISSING ENTIRELY")
        $reportLines.Add("================================================================================")
        continue
    }

    $item = Get-Item -LiteralPath $full
    $size = $item.Length

    try {
        $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $full
    } catch {
        Write-Host "  UNREADABLE: $rel -- $($_.Exception.Message)" -ForegroundColor Red
        $summary += [PSCustomObject]@{ Route = $rel; Status = "UNREADABLE"; SizeBytes = $size; HasAsyncParams = $false }
        $reportLines.Add("")
        $reportLines.Add("================================================================================")
        $reportLines.Add("FILE: $rel")
        $reportLines.Add("STATUS: UNREADABLE -- $($_.Exception.Message)")
        $reportLines.Add("================================================================================")
        continue
    }

    $hasAsyncParams = ($content -match 'Promise<') -and ($content -match '\bawait\s+(params|searchParams)\b')
    $isEmpty = $size -lt 5
    $isNearEmpty = (-not $isEmpty) -and ($content.Trim().Length -lt 120)

    if ($isEmpty) {
        $status = "EMPTY"
        Write-Host "  EMPTY: $rel ($size bytes)" -ForegroundColor Red
    } elseif ($isNearEmpty) {
        $status = "NEAR-EMPTY"
        Write-Host "  NEAR-EMPTY: $rel ($size bytes) -- looks like a stub" -ForegroundColor Yellow
    } elseif (-not $hasAsyncParams) {
        $status = "OK-CONTENT / NEEDS ASYNC-PARAMS FIX"
        Write-Host "  OK ($size bytes) but NOT yet using async params/searchParams: $rel" -ForegroundColor Yellow
    } else {
        $status = "OK"
        Write-Host "  OK ($size bytes), async params already present: $rel" -ForegroundColor Green
    }

    $summary += [PSCustomObject]@{ Route = $rel; Status = $status; SizeBytes = $size; HasAsyncParams = $hasAsyncParams }

    $reportLines.Add("")
    $reportLines.Add("================================================================================")
    $reportLines.Add("FILE: $rel")
    $reportLines.Add("SIZE: $size bytes | STATUS: $status | ASYNC PARAMS PRESENT: $hasAsyncParams")
    $reportLines.Add("================================================================================")
    $reportLines.Add($content)
}

Write-Host ""
Write-Host "==== Summary ====" -ForegroundColor Cyan
$summary | Format-Table -AutoSize | Out-String | Write-Host

[System.IO.File]::WriteAllText($reportPath, ($reportLines -join "`n"), [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "Full content of all 7 files written to: $reportPath" -ForegroundColor Green
Write-Host "Share that file's contents back for review, or open it in a text editor." -ForegroundColor Green