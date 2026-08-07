<#
.SYNOPSIS
    SAI2 project ki code files ko 4 alag modules mein export karta hai:
      1. Admin       -> apps/admin
      2. Web         -> apps/web
      3. Packages    -> packages (api-client, config, store, ui, utils)
      4. RootConfig  -> root level config files (package.json, turbo.json, pnpm-workspace.yaml, README.md, etc)

.USAGE
    1. Is script ko SAI2 project ke root folder mein rakhein (jahan package.json hai)
    2. PowerShell terminal mein run karein:
         .\Export-Modules-Code.ps1
    3. 4 alag output files ban jayengi:
         - ProjectCode_Admin.txt
         - ProjectCode_Web.txt
         - ProjectCode_Packages.txt
         - ProjectCode_RootConfig.txt
#>

# ============ CONFIG ============
$ProjectRoot = "."

# Kin extensions ki files include karni hain
$IncludeExtensions = @(
    "*.ts", "*.tsx", "*.js", "*.jsx",
    "*.css", "*.scss",
    "*.json",
    "*.md",
    "*.mjs", "*.cjs"
)

# Kin folders ko skip karna hai (bade/irrelevant folders)
$ExcludeDirs = @(
    "node_modules",
    ".next",
    ".git",
    "dist",
    "build",
    "out",
    "coverage",
    ".vercel",
    "public\fonts"
)

# Kin specific files ko skip karna hai
$ExcludeFiles = @(
    "package-lock.json",
    "yarn.lock",
    "pnpm-lock.yaml"
)

# ============ MODULE DEFINITIONS ============
# Har module ka naam, uska sub-path (relative to root), aur output file name.
# "RootConfig" module ke liye SubPath khali chorha hai (special-case handle hoga neeche).
$Modules = @(
    @{ Name = "Admin";      SubPath = "apps\admin"; Output = "ProjectCode_Admin.txt" },
    @{ Name = "Web";        SubPath = "apps\web";    Output = "ProjectCode_Web.txt" },
    @{ Name = "Packages";   SubPath = "packages";    Output = "ProjectCode_Packages.txt" },
    @{ Name = "RootConfig"; SubPath = "";            Output = "ProjectCode_RootConfig.txt" }
)

# ============ HELPER FUNCTION ============
function Export-ModuleCode {
    param(
        [string]$ModuleName,
        [string]$SubPath,
        [string]$OutputFileName,
        [string]$RootPath
    )

    $FullProjectPath = Resolve-Path $RootPath

    if ([string]::IsNullOrEmpty($SubPath)) {
        # RootConfig module -> sirf root level ki files (subfolders skip)
        $ScanPath = $FullProjectPath.Path
        $AllFiles = Get-ChildItem -Path $ScanPath -File -Include $IncludeExtensions |
            Where-Object {
                $isExcludedFile = $ExcludeFiles -contains $_.Name
                -not $isExcludedFile
            }
    }
    else {
        $ScanPath = Join-Path $FullProjectPath.Path $SubPath

        if (-not (Test-Path $ScanPath)) {
            Write-Host "SKIP: Path nahi mila -> $ScanPath" -ForegroundColor Red
            return
        }

        $AllFiles = Get-ChildItem -Path $ScanPath -Recurse -File -Include $IncludeExtensions |
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
    }

    $TotalFiles = $AllFiles.Count
    $OutputPath = Join-Path $FullProjectPath.Path $OutputFileName

    Write-Host ""
    Write-Host "=== MODULE: $ModuleName ===" -ForegroundColor Cyan
    Write-Host "Scan path: $ScanPath" -ForegroundColor Cyan
    Write-Host "Total files mili: $TotalFiles" -ForegroundColor Yellow

    if (Test-Path $OutputPath) {
        Remove-Item $OutputPath -Force
    }

    $Counter = 0
    $StringBuilder = New-Object System.Text.StringBuilder

    # Header
    [void]$StringBuilder.AppendLine("=" * 80)
    [void]$StringBuilder.AppendLine("MODULE CODE EXPORT: $ModuleName")
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

    Write-Host "Done! Output file: $OutputPath" -ForegroundColor Cyan
    Write-Host "Total files exported: $Counter" -ForegroundColor Cyan
}

# ============ RUN ALL MODULES ============
Write-Host "Project scan shuru ho raha hai: $(Resolve-Path $ProjectRoot)" -ForegroundColor Magenta

foreach ($mod in $Modules) {
    Export-ModuleCode -ModuleName $mod.Name -SubPath $mod.SubPath -OutputFileName $mod.Output -RootPath $ProjectRoot
}

Write-Host ""
Write-Host "=== SAARE MODULES EXPORT MUKAMMAL HO GAYE ===" -ForegroundColor Magenta