<#
    Export-InstructorPanel-Code.ps1
    --------------------------------
    Purpose:
      1) FULL code export -> sirf Instructor Panel (apps/web) files
      2) STATUS ONLY (TRUE/FALSE) -> baaqi related/dependency files
         (store, api-client, ui components, config etc.)
         Taake output .txt file lambi na ho, sirf pata chal jaye
         file exist karti hai ya nahi.

    Usage:
      Root SAI2 folder me is script ko rakh kar run karo:
      .\Export-InstructorPanel-Code.ps1

    Output:
      InstructorPanel-Export-<timestamp>.txt   (root me generate hogi)
#>

param(
    [string]$RootPath = (Get-Location).Path
)

# ---------- UTF-8 No-BOM writer (user's standard pattern) ----------
function Write-FileUtf8NoBom {
    param(
        [string]$Path,
        [string]$Content
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

# ---------- Helpers ----------
$sb = New-Object System.Text.StringBuilder

function Add-Line {
    param([string]$Text = "")
    [void]$sb.AppendLine($Text)
}

function Add-FullFile {
    param([string]$RelPath)
    $fullPath = Join-Path $RootPath $RelPath
    Add-Line "==================================================================="
    Add-Line "FILE: $RelPath"
    Add-Line "==================================================================="
    if (Test-Path $fullPath -PathType Leaf) {
        try {
            $content = Get-Content -Path $fullPath -Raw -Encoding UTF8
            Add-Line $content
        }
        catch {
            Add-Line "[ERROR READING FILE: $($_.Exception.Message)]"
        }
    }
    else {
        Add-Line "[FILE NOT FOUND: $RelPath]"
    }
    Add-Line ""
}

function Add-StatusOnly {
    param([string]$RelPath)
    $fullPath = Join-Path $RootPath $RelPath
    $exists = Test-Path $fullPath -PathType Leaf
    $status = if ($exists) { "TRUE" } else { "FALSE" }
    Add-Line ("{0,-6} : {1}" -f $status, $RelPath)
}

function Add-StatusOnlyFolder {
    param(
        [string]$RelFolder,
        [string]$Pattern = "*"
    )
    $fullPath = Join-Path $RootPath $RelFolder
    if (Test-Path $fullPath -PathType Container) {
        $files = Get-ChildItem -Path $fullPath -Recurse -File -Filter $Pattern -ErrorAction SilentlyContinue |
                 Where-Object { $_.Name -notmatch '\.bak' }
        if ($files.Count -eq 0) {
            Add-Line ("{0,-6} : {1}  [FOLDER EMPTY]" -f "FALSE", $RelFolder)
        }
        foreach ($f in $files) {
            $rel = $f.FullName.Substring($RootPath.Length + 1)
            Add-Line ("{0,-6} : {1}" -f "TRUE", $rel)
        }
    }
    else {
        Add-Line ("{0,-6} : {1}  [FOLDER NOT FOUND]" -f "FALSE", $RelFolder)
    }
}

# ============================================================
# SECTION 1: INSTRUCTOR PANEL - FULL CODE EXPORT
# ============================================================
Add-Line "###################################################################"
Add-Line "# SECTION 1: INSTRUCTOR PANEL - FULL CODE"
Add-Line "###################################################################"
Add-Line ""

$instructorBase = "apps\web\app\(instructor)"

# Shell / layout / sidebar components
$instructorShellFiles = @(
    "$instructorBase\layout.tsx",
    "$instructorBase\_components\InstructorShell.tsx",
    "$instructorBase\_components\InstructorTwoLevelSidebar.tsx"
)
foreach ($f in $instructorShellFiles) { Add-FullFile $f }

# All instructor route pages (dynamically discovered, skip .bak files)
$instructorRoutesPath = Join-Path $RootPath "$instructorBase\instructor"
if (Test-Path $instructorRoutesPath) {
    $instructorPageFiles = Get-ChildItem -Path $instructorRoutesPath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -notmatch '\.bak' }
    foreach ($f in $instructorPageFiles) {
        $rel = $f.FullName.Substring($RootPath.Length + 1)
        Add-FullFile $rel
    }
}
else {
    Add-Line "[FOLDER NOT FOUND: $instructorBase\instructor]"
    Add-Line ""
}

# Instructor-specific nav config + UI pieces used only by instructor panel
$instructorSupportFiles = @(
    "apps\web\lib\instructor-nav-config.ts",
    "apps\web\components\ui\instructor-sidebar-v2.tsx",
    "apps\web\components\ui\instructor-bento-card.tsx",
    "apps\web\components\ui\instructor-onboarding-checklist.tsx",
    "apps\web\components\ui\instructor-search-bar.tsx"
)
foreach ($f in $instructorSupportFiles) { Add-FullFile $f }

# ============================================================
# SECTION 2: DEPENDENCIES - STATUS ONLY (TRUE/FALSE)
# ============================================================
Add-Line "###################################################################"
Add-Line "# SECTION 2: RELATED / DEPENDENCY FILES - STATUS ONLY (TRUE/FALSE)"
Add-Line "# (Full code NAHI diya gaya, sirf file exist status)"
Add-Line "###################################################################"
Add-Line ""

Add-Line "--- packages/store (state used by instructor panel) ---"
Add-StatusOnlyFolder "packages\store\src"
Add-Line ""

Add-Line "--- packages/api-client (hooks + dummy data) ---"
Add-StatusOnlyFolder "packages\api-client\src\hooks"
Add-StatusOnly "packages\api-client\src\dummy-data.ts"
Add-StatusOnly "packages\api-client\src\dummy-data-admin.ts"
Add-StatusOnly "packages\api-client\src\http-client.ts"
Add-StatusOnly "packages\api-client\src\query-keys.ts"
Add-StatusOnly "packages\api-client\src\index.ts"
Add-StatusOnly "packages\api-client\src\types\index.ts"
Add-Line ""

Add-Line "--- packages/ui (shared components) ---"
Add-StatusOnlyFolder "packages\ui\src\components"
Add-StatusOnly "packages\ui\src\index.ts"
Add-StatusOnly "packages\ui\src\cn.ts"
Add-Line ""

Add-Line "--- packages/utils ---"
Add-StatusOnlyFolder "packages\utils\src"
Add-Line ""

Add-Line "--- apps/web shared components (used across panels) ---"
Add-StatusOnly "apps\web\app\_components\ConditionalChrome.tsx"
Add-StatusOnly "apps\web\app\_components\SiteHeader.tsx"
Add-StatusOnly "apps\web\app\_components\SiteFooter.tsx"
Add-StatusOnly "apps\web\app\_components\TopSearchBar.tsx"
Add-StatusOnly "apps\web\app\globals.css"
Add-StatusOnly "apps\web\app\providers.tsx"
Add-StatusOnly "apps\web\middleware.ts"
Add-StatusOnly "apps\web\tailwind.config.js"
Add-Line ""

Add-Line "--- root config ---"
Add-StatusOnly "package.json"
Add-StatusOnly "pnpm-workspace.yaml"
Add-StatusOnly "turbo.json"
Add-Line ""

# ============================================================
# WRITE OUTPUT
# ============================================================
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputFile = Join-Path $RootPath "InstructorPanel-Export-$timestamp.txt"

Write-FileUtf8NoBom -Path $outputFile -Content $sb.ToString()

Write-Host ""
Write-Host "Export complete!" -ForegroundColor Green
Write-Host "File: $outputFile" -ForegroundColor Cyan
Write-Host ""