<#
  scan-codebase-errors.ps1
  Scans the entire SAI2 monorepo for TypeScript type errors, ESLint
  syntax/logic/style issues, and warnings - writes everything into one
  timestamped .txt report at the SAI2 root.

  Run from: SAI2 root
    PS D:\...\SAI2> .\scan-codebase-errors.ps1

  Output:
    CodeScan-Report-<yyyyMMdd-HHmmss>.txt
#>

$ErrorActionPreference = "Continue"

$root = Get-Location
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportPath = Join-Path $root "CodeScan-Report-$timestamp.txt"

$enc = New-Object System.Text.UTF8Encoding($false)
$sb = New-Object System.Text.StringBuilder

function Add-Line {
    param([string]$Text = "")
    [void]$sb.AppendLine($Text)
}

function Add-Section {
    param([string]$Title)
    Add-Line ""
    Add-Line ("=" * 90)
    Add-Line "  $Title"
    Add-Line ("=" * 90)
}

function Run-CommandCapture {
    param(
        [string]$WorkingDir,
        [string]$Command,
        [string]$ArgsLine
    )
    Push-Location $WorkingDir
    try {
        $output = & cmd /c "$Command $ArgsLine 2>&1"
        return ($output -join [Environment]::NewLine)
    } catch {
        return "!! Failed to run: $Command $ArgsLine`n$($_.Exception.Message)"
    } finally {
        Pop-Location
    }
}

Add-Line "SAI2 CODEBASE SCAN REPORT"
Add-Line "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Add-Line "Root: $root"
Add-Line ""
Add-Line "This report includes:"
Add-Line "  1. TypeScript type-checking (tsc --noEmit) for apps/web, apps/admin, packages/*"
Add-Line "  2. ESLint (syntax, logic, unused vars, react-hooks rules, etc.) for apps/web, apps/admin"
Add-Line ""

# ---------------------------------------------------------------------------
# Discover targets
# ---------------------------------------------------------------------------
$targets = @()

$appsWeb = Join-Path $root "apps\web"
$appsAdmin = Join-Path $root "apps\admin"
$pkgApi = Join-Path $root "packages\api-client"
$pkgUi = Join-Path $root "packages\ui"
$pkgUtils = Join-Path $root "packages\utils"
$pkgStore = Join-Path $root "packages\store"

if ([System.IO.Directory]::Exists($appsWeb))   { $targets += @{ Name = "apps/web";           Path = $appsWeb;  Lint = $true  } }
if ([System.IO.Directory]::Exists($appsAdmin)) { $targets += @{ Name = "apps/admin";         Path = $appsAdmin; Lint = $true } }
if ([System.IO.Directory]::Exists($pkgApi))    { $targets += @{ Name = "packages/api-client"; Path = $pkgApi;   Lint = $false } }
if ([System.IO.Directory]::Exists($pkgUi))     { $targets += @{ Name = "packages/ui";         Path = $pkgUi;    Lint = $false } }
if ([System.IO.Directory]::Exists($pkgUtils))  { $targets += @{ Name = "packages/utils";      Path = $pkgUtils; Lint = $false } }
if ([System.IO.Directory]::Exists($pkgStore))  { $targets += @{ Name = "packages/store";      Path = $pkgStore; Lint = $false } }

if ($targets.Count -eq 0) {
    Add-Line "!! No known target folders found (apps/web, apps/admin, packages/*). Run this from the SAI2 root."
    [System.IO.File]::WriteAllText($reportPath, $sb.ToString(), $enc)
    Write-Host "No targets found. Report written to $reportPath" -ForegroundColor Yellow
    exit 1
}

$totalIssues = 0

foreach ($t in $targets) {
    $name = $t.Name
    $path = $t.Path

    Write-Host "Scanning $name ..." -ForegroundColor Cyan

    # -------------------------------------------------------------------
    # TypeScript type-check
    # -------------------------------------------------------------------
    Add-Section "TYPE CHECK: $name  (tsc --noEmit)"

    $hasTsconfig = [System.IO.File]::Exists((Join-Path $path "tsconfig.json"))
    if (-not $hasTsconfig) {
        Add-Line "  (skipped - no tsconfig.json found in $path)"
    } else {
        $npxCheck = Run-CommandCapture -WorkingDir $path -Command "npx" -ArgsLine "--yes tsc --noEmit --pretty false"
        if ([string]::IsNullOrWhiteSpace($npxCheck)) {
            Add-Line "  No type errors found."
        } else {
            Add-Line $npxCheck
            $issueLines = ($npxCheck -split "`n" | Where-Object { $_ -match "error TS" })
            $totalIssues += $issueLines.Count
        }
    }

    # -------------------------------------------------------------------
    # ESLint (only for the two Next.js apps - packages don't have eslint configs)
    # -------------------------------------------------------------------
    if ($t.Lint) {
        Add-Section "ESLINT: $name"

        $eslintOut = Run-CommandCapture -WorkingDir $path -Command "npx" -ArgsLine "--yes eslint . --ext .ts,.tsx --max-warnings=10000"
        if ([string]::IsNullOrWhiteSpace($eslintOut)) {
            Add-Line "  No lint issues found."
        } else {
            Add-Line $eslintOut
            $problemLine = ($eslintOut -split "`n" | Where-Object { $_ -match "\d+ problem" })
            if ($problemLine) {
                Add-Line ""
                Add-Line "  Summary line: $($problemLine -join ' ')"
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Quick static scan for common risky patterns (grep-style, no build needed)
# ---------------------------------------------------------------------------
Add-Section "QUICK PATTERN SCAN (console.log / TODO / any / debugger leftovers)"

$scanDirs = @($appsWeb, $appsAdmin, $pkgApi, $pkgUi, $pkgUtils, $pkgStore) | Where-Object { [System.IO.Directory]::Exists($_) }
$patterns = @(
    @{ Label = "console.log(" ;   Regex = "console\.log\(" },
    @{ Label = "debugger;"    ;   Regex = "\bdebugger\b" },
    @{ Label = "TODO / FIXME" ;   Regex = "TODO|FIXME" },
    @{ Label = ": any"        ;   Regex = ":\s*any\b" },
    @{ Label = "@ts-ignore"   ;   Regex = "@ts-ignore" }
)

foreach ($dir in $scanDirs) {
    $files = Get-ChildItem -Path $dir -Recurse -Include *.ts,*.tsx -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\node_modules\\" -and $_.FullName -notmatch "\\\.next\\" }

    foreach ($pattern in $patterns) {
        $matches = $files | Select-String -Pattern $pattern.Regex -ErrorAction SilentlyContinue
        if ($matches) {
            Add-Line ""
            Add-Line "  [$($pattern.Label)] in $($dir.Replace($root.Path, '.'))  -  $($matches.Count) match(es)"
            foreach ($m in $matches | Select-Object -First 50) {
                $relPath = $m.Path.Replace($root.Path, ".")
                Add-Line "    $relPath`:$($m.LineNumber)  $($m.Line.Trim())"
            }
            if ($matches.Count -gt 50) {
                Add-Line "    ... and $($matches.Count - 50) more (truncated)"
            }
        }
    }
}

# ---------------------------------------------------------------------------
# Final summary
# ---------------------------------------------------------------------------
Add-Section "SUMMARY"
Add-Line "  Approx. TypeScript error count across scanned targets: $totalIssues"
Add-Line "  Full detail above. Search this file for 'error TS' and 'problem' to jump to issues."
Add-Line ""
Add-Line "Report complete: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

[System.IO.File]::WriteAllText($reportPath, $sb.ToString(), $enc)

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Report written to: $reportPath"