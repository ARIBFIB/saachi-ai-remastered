<#
    Export-ErrorFiles.ps1
    Run this from: SAI2 root (where 'apps' folder lives)
    Example:
      PS D:\...\SAI2> .\Export-ErrorFiles.ps1

    Exports the specific files that failed to read in the last export
    (mostly dynamic [slug]/[id]/[courseId] routes) into one txt file,
    using .NET File IO directly (PS 5.1 safe — no Get-Content cmdlet).
#>

$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$relativePaths = @(
    "apps\web\app\(instructor)\instructor\courses\[id]\lessons\[lessonId]\quiz\page.tsx",
    "apps\web\app\(instructor)\instructor\courses\[id]\lessons\[lessonId]\text\page.tsx",
    "apps\web\app\(instructor)\instructor\courses\[id]\lessons\[lessonId]\video\page.tsx",
    "apps\web\app\(instructor)\instructor\courses\[id]\edit\page.tsx",
    "apps\web\app\(instructor)\instructor\courses\[id]\curriculum\page.tsx",
    "apps\web\app\(learner)\certificates\[id]\page.tsx",
    "apps\web\app\(learner)\community\[courseId]\page.tsx",
    "apps\web\app\(learner)\learn\[courseId]\[lessonId]\page.tsx",
    "apps\web\app\(marketing)\categories\[slug]\page.tsx",
    "apps\web\app\(marketing)\courses\[slug]\page.tsx",
    "apps\web\app\(marketing)\instructors\[slug]\page.tsx"
)

$outFile = Join-Path $root "ProjectCode_ErrorFiles.txt"

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("MODULE CODE EXPORT: Error Files (dynamic routes)")
[void]$sb.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$sb.AppendLine("Total Files Attempted: $($relativePaths.Count)")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("")

$foundCount = 0
$missingCount = 0

foreach ($rel in $relativePaths) {
    $fullPath = Join-Path $root $rel

    [void]$sb.AppendLine("================================================================================")
    [void]$sb.AppendLine("FILE: $rel")
    [void]$sb.AppendLine("================================================================================")

    if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
        try {
            $content = [System.IO.File]::ReadAllText($fullPath)
            [void]$sb.AppendLine($content)
            $foundCount++
        }
        catch {
            [void]$sb.AppendLine("!! ERROR reading file: $($_.Exception.Message)")
        }
    }
    else {
        [void]$sb.AppendLine("!! FILE NOT FOUND at this path.")
        $missingCount++
    }

    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("")
}

# Also do a broad scan: find any page.tsx under bracketed folders, in case
# some of the above paths are wrong/renamed, so nothing gets missed.
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("BONUS: Auto-discovered dynamic route files (folders containing '[')")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("")

$webAppRoot = Join-Path $root "apps\web\app"
if (Test-Path -LiteralPath $webAppRoot) {
    $dynamicFiles = Get-ChildItem -LiteralPath $webAppRoot -Recurse -Filter "page.tsx" -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\[' }

    foreach ($f in $dynamicFiles) {
        $rel2 = $f.FullName.Substring($root.Path.Length).TrimStart('\')
        [void]$sb.AppendLine("--------------------------------------------------------------------------------")
        [void]$sb.AppendLine("FILE: $rel2")
        [void]$sb.AppendLine("--------------------------------------------------------------------------------")
        try {
            $content2 = [System.IO.File]::ReadAllText($f.FullName)
            [void]$sb.AppendLine($content2)
        }
        catch {
            [void]$sb.AppendLine("!! ERROR reading file: $($_.Exception.Message)")
        }
        [void]$sb.AppendLine("")
    }
}
else {
    [void]$sb.AppendLine("!! apps\web\app not found relative to script root: $root")
}

[System.IO.File]::WriteAllText($outFile, $sb.ToString(), [System.Text.Encoding]::UTF8)

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Found & exported: $foundCount" -ForegroundColor Green
Write-Host "Missing (path wrong or file doesn't exist): $missingCount" -ForegroundColor Yellow
Write-Host "Output file: $outFile" -ForegroundColor Cyan