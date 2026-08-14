<#
.SYNOPSIS
    SAI2 project mein se sirf WEBSITE FRONTEND (apps/web) aur uske
    related shared packages (ui, utils, store, api-client) ka code
    ek single .txt file mein export karta hai.

.USAGE
    1. Is script ko SAI2 project ke root folder mein rakhein (jahan package.json hai)
    2. PowerShell terminal mein run karein:
         .\Export-Web-Frontend-Code.ps1
    3. Output file banegi:
         - ProjectCode_WebFrontend.txt
#>

# ============ CONFIG ============
$ProjectRoot = "."
$OutputFileName = "ProjectCode_WebFrontend.txt"

# Website frontend + iske directly related shared packages
$IncludePaths = @(
    "apps\web",
    "packages\ui",
    "packages\utils",
    "packages\store",
    "packages\api-client"
)

# Kin extensions ki files include karni hain
$IncludeExtensions = @(
    "*.ts", "*.tsx", "*.js", "*.jsx",
    "*.css", "*.scss",
    "*.json",
    "*.md",
    "*.mjs", "*.cjs"
)

# Kin folders ko skip karna hai
$ExcludeDirs = @(
    "node_modules",
    ".next",
    ".git",
    "dist",
    "build",
    "out",
    "coverage",
    ".vercel",
    "public\fonts",
    "public\animations"
)

# Kin specific files ko skip karna hai
$ExcludeFiles = @(
    "package-lock.json",
    "yarn.lock",
    "pnpm-lock.yaml"
)

# ============ MAIN ============
$FullProjectPath = Resolve-Path $ProjectRoot
$OutputPath = Join-Path $FullProjectPath.Path $OutputFileName

Write-Host "Project scan shuru ho raha hai: $($FullProjectPath.Path)" -ForegroundColor Magenta

$AllFiles = @()

foreach ($path in $IncludePaths) {
    $ScanPath = Join-Path $FullProjectPath.Path $path

    if (-not (Test-Path $ScanPath)) {
        Write-Host "SKIP: Path nahi mila -> $ScanPath" -ForegroundColor Red
        continue
    }

    $Files = Get-ChildItem -Path $ScanPath -Recurse -File -Include $IncludeExtensions |
        Where-Object {
            $filePath = $_.FullName
            $relativePath = $filePath.Substring($FullProjectPath.Path.Length + 1)

            $isExcludedDir = $false
            foreach ($dir in $ExcludeDirs) {
                if ($relativePath -like "*$dir*") {
                    $isExcludedDir = $true
                    break
                }
            }

            $isExcludedFile = $ExcludeFiles -contains $_.Name

            -not $isExcludedDir -and -not $isExcludedFile
        }

    $AllFiles += $Files
}

$TotalFiles = $AllFiles.Count

Write-Host ""
Write-Host "=== WEBSITE FRONTEND EXPORT ===" -ForegroundColor Cyan
Write-Host "Total files mili: $TotalFiles" -ForegroundColor Yellow

if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Force
}

$Counter = 0
$StringBuilder = New-Object System.Text.StringBuilder

# Header
[void]$StringBuilder.AppendLine("=" * 80)
[void]$StringBuilder.AppendLine("WEBSITE FRONTEND CODE EXPORT (apps/web + shared packages)")
[void]$StringBuilder.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$StringBuilder.AppendLine("Total Files: $TotalFiles")
[void]$StringBuilder.AppendLine("=" * 80)
[void]$StringBuilder.AppendLine("")

foreach ($file in $AllFiles) {
    $Counter++
    $relativePath = $file.FullName.Substring($FullProjectPath.Path.Length + 1)

    Write-Host "[$Counter/$TotalFiles] Processing: $relativePath" -ForegroundColor Green

    [void]$StringBuilder.AppendLine("")
    [void]$StringBuilder.AppendLine("=" * 80)
    [void]$StringBuilder.AppendLine("FILE: $relativePath")
    [void]$StringBuilder.AppendLine("=" * 80)

    try {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
        if ([string]::IsNullOrEmpty($content)) {
            [void]$StringBuilder.AppendLine("(empty file)")
        } else {
            [void]$StringBuilder.AppendLine($content)
        }
    } catch {
        [void]$StringBuilder.AppendLine("!! ERROR reading file: $($_.Exception.Message)")
    }

    [void]$StringBuilder.AppendLine("")
}

[System.IO.File]::WriteAllText($OutputPath, $StringBuilder.ToString(), [System.Text.Encoding]::UTF8)

Write-Host ""
Write-Host "Done! Output file: $OutputPath" -ForegroundColor Cyan
Write-Host "Total files exported: $Counter" -ForegroundColor Cyan