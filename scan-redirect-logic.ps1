<#
    scan-redirect-logic.ps1

    Scans apps/web for every router.push(...) / redirect(...) / Link href
    call, and reports:
      1. Every redirect call found, with its file/line and surrounding
         context (3 lines before/after) so you can eyeball whether it looks
         conditional (role-aware) or hardcoded.
      2. A specific flag for files that reference "role" ANYWHERE but whose
         router.push(...) calls do NOT contain a ternary/condition - a
         strong signal of the exact bug pattern we just fixed on the
         register page (branch not handled).

    This is a static text scan, not a runtime test - it won't catch every
    logic bug, but it catches this whole class of "hardcoded redirect
    ignoring a role/status variable" issues quickly.

    Run from SAI2 root:
      PS D:\...\SAI2> .\scan-redirect-logic.ps1

    Output: ProjectCode_RedirectScan.txt in the SAI2 root.
#>

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

$webRoot = Join-Path $root "apps\web"
$outFile = Join-Path $root "ProjectCode_RedirectScan.txt"

if (-not (Test-Path -LiteralPath $webRoot)) {
    Write-Host "Could not find apps\web under $root" -ForegroundColor Red
    exit 1
}

$allFiles = Get-ChildItem -LiteralPath $webRoot -Recurse -Include "*.tsx","*.ts" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\\.next\\' }

$redirectRegex = [regex]'(router\.push\(|router\.replace\(|redirect\()'

$allFindings = New-Object System.Collections.Generic.List[object]
$suspiciousFiles = New-Object System.Collections.Generic.List[object]

foreach ($f in $allFiles) {
    $text = [System.IO.File]::ReadAllText($f.FullName)
    $lines = $text -split "`r?`n"
    $rel = $f.FullName.Substring($root.Length).TrimStart('\')

    $fileHasRole = $text -match '\brole\b'
    $fileHasConditionalRedirect = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($redirectRegex.IsMatch($lines[$i])) {
            $lineNum = $i + 1
            $contextStart = [Math]::Max(0, $i - 2)
            $contextEnd = [Math]::Min($lines.Count - 1, $i + 2)
            $context = $lines[$contextStart..$contextEnd] -join "`n"

            # does this specific redirect line (or its immediate context) look conditional?
            $looksConditional = ($lines[$i] -match '\?' -and $lines[$i] -match ':') -or
                                 ($context -match '\bif\s*\(' ) -or
                                 ($context -match 'role\s*===')

            if ($looksConditional) { $fileHasConditionalRedirect = $true }

            $allFindings.Add([PSCustomObject]@{
                File            = $rel
                Line            = $lineNum
                Code            = $lines[$i].Trim()
                LooksConditional = $looksConditional
                Context         = $context
            }) | Out-Null
        }
    }

    if ($fileHasRole -and $allFindings.Count -gt 0) {
        $fileFindings = $allFindings | Where-Object { $_.File -eq $rel }
        $hasUnconditional = $fileFindings | Where-Object { -not $_.LooksConditional }
        if ($fileHasRole -and $hasUnconditional -and -not $fileHasConditionalRedirect) {
            $suspiciousFiles.Add($rel) | Out-Null
        }
    }
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("REDIRECT LOGIC SCAN REPORT")
[void]$sb.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Total redirect calls found: $($allFindings.Count)")
[void]$sb.AppendLine("Files that mention 'role' AND have an unconditional redirect nearby: $($suspiciousFiles.Count)")
[void]$sb.AppendLine("(worth double-checking these first - same bug pattern as the register page fix)")
[void]$sb.AppendLine("")

[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("SUSPICIOUS FILES (mentions 'role', has a redirect that doesn't look conditional)")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("")
if ($suspiciousFiles.Count -eq 0) {
    [void]$sb.AppendLine("None found.")
}
else {
    foreach ($sf in ($suspiciousFiles | Sort-Object -Unique)) {
        [void]$sb.AppendLine("  $sf")
    }
}
[void]$sb.AppendLine("")

[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("ALL REDIRECT CALLS FOUND (with context)")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("")

foreach ($find in ($allFindings | Sort-Object File, Line)) {
    $flag = if ($find.LooksConditional) { "[conditional]" } else { "[HARDCODED - review]" }
    [void]$sb.AppendLine("--------------------------------------------------------------------------------")
    [void]$sb.AppendLine("FILE: $($find.File) : line $($find.Line)  $flag")
    [void]$sb.AppendLine("--------------------------------------------------------------------------------")
    [void]$sb.AppendLine($find.Context)
    [void]$sb.AppendLine("")
}

[System.IO.File]::WriteAllText($outFile, $sb.ToString(), [System.Text.Encoding]::UTF8)

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Total redirect calls found: $($allFindings.Count)" -ForegroundColor Cyan
Write-Host "Suspicious files (role-aware but possibly hardcoded redirect): $($suspiciousFiles.Count)" -ForegroundColor Yellow
Write-Host "Report written to: $outFile" -ForegroundColor Cyan