<#
    Export-Learner-Auth-Full.ps1
    -----------------------------------------------------------
    Exports FULL CODE of:
      - apps/web/app/(learner)/**        (all pages, all sub-folders)
      - apps/web/app/(auth)/**           (login, register, forgot-password,
                                           reset-password, verify-email)
    into a single timestamped .txt file for review/sharing.

    Run from repo root:
      D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>
      .\Export-Learner-Auth-Full.ps1
#>

$ErrorActionPreference = "Stop"

# ---- Config ----------------------------------------------------------
$RootDir    = $PSScriptRoot
$WebAppDir  = [System.IO.Path]::Combine($RootDir, "apps", "web", "app")

$Timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
$OutputFile = [System.IO.Path]::Combine($RootDir, "Export-LearnerModule-AuthModule-Full-$Timestamp.txt")

# Folders we want to include FULLY (relative to apps/web/app)
$TargetPaths = @(
    [System.IO.Path]::Combine($WebAppDir, "(learner)"),
    [System.IO.Path]::Combine($WebAppDir, "(auth)")
)

# Extensions we care about
$IncludeExtensions = @(".tsx", ".ts", ".css", ".json")

# Skip backup/junk files
$ExcludePatterns = @("*.bak*", "*.tsbuildinfo", "*.moved-*")

# ---- Helpers -----------------------------------------------------------
function Test-ShouldExclude {
    param([string]$FileName)
    foreach ($pattern in $ExcludePatterns) {
        if ($FileName -like $pattern) { return $true }
    }
    return $false
}

function Get-RelativePath {
    param([string]$FullPath, [string]$BasePath)
    return $FullPath.Substring($BasePath.Length).TrimStart('\', '/')
}

# ---- Collect files -------------------------------------------------------
$AllFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]

foreach ($target in $TargetPaths) {
    if ([System.IO.Directory]::Exists($target)) {
        $files = Get-ChildItem -LiteralPath $target -Recurse -File -ErrorAction SilentlyContinue
        foreach ($f in $files) {
            if ($IncludeExtensions -contains $f.Extension -and -not (Test-ShouldExclude $f.Name)) {
                $AllFiles.Add($f)
            }
        }
    }
    else {
        Write-Warning "Path not found, skipping: $target"
    }
}

if ($AllFiles.Count -eq 0) {
    Write-Warning "No matching files found. Check folder structure/paths above."
    exit 1
}

# ---- Build output content ------------------------------------------------
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("=================================================================")
[void]$sb.AppendLine(" SAI2 - Full Learner Module + Full Auth Module Code Export")
[void]$sb.AppendLine(" Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$sb.AppendLine(" Total files: $($AllFiles.Count)")
[void]$sb.AppendLine("=================================================================")
[void]$sb.AppendLine("")

# Build a simple folder tree summary first
[void]$sb.AppendLine("---------------- FILE LIST (relative paths) ----------------")
$SortedFiles = $AllFiles | Sort-Object FullName
foreach ($file in $SortedFiles) {
    $relPath = Get-RelativePath -FullPath $file.FullName -BasePath $RootDir
    [void]$sb.AppendLine(" - $relPath")
}
[void]$sb.AppendLine("--------------------------------------------------------------")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("")

# Now full content dump
foreach ($file in $SortedFiles) {
    $relPath = Get-RelativePath -FullPath $file.FullName -BasePath $RootDir

    [void]$sb.AppendLine("-----------------------------------------------------------------")
    [void]$sb.AppendLine("FILE: $relPath")
    [void]$sb.AppendLine("-----------------------------------------------------------------")

    try {
        $content = [System.IO.File]::ReadAllText($file.FullName)
        [void]$sb.AppendLine($content)
    }
    catch {
        [void]$sb.AppendLine("!! ERROR READING FILE: $($_.Exception.Message)")
    }

    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("")
}

# ---- Write output (UTF-8, no BOM) ----------------------------------------
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($OutputFile, $sb.ToString(), $Utf8NoBom)

Write-Host ""
Write-Host "Export complete!" -ForegroundColor Green
Write-Host "Files exported : $($AllFiles.Count)" -ForegroundColor Green
Write-Host "Output file    : $OutputFile" -ForegroundColor Green
Write-Host ""