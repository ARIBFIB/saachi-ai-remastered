# =================================================================
# SAI2 - Export Onboarding Tour/Checklist files to JSON
# Run this from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
# =================================================================

$ErrorActionPreference = "Stop"

# Root of the monorepo (current directory when you run this script)
$root = Get-Location

# Filenames to search for (case-insensitive, matched anywhere under $root)
$targetNames = @(
    "learner-onboarding-tour.tsx",
    "learner-onboarding-checklist.tsx",
    "LearnerOnboardingTour.tsx",
    "LearnerOnboardingChecklist.tsx"
)

Write-Host "Searching for onboarding files under: $root" -ForegroundColor Cyan

# Find matching files, excluding node_modules / .next / build folders
$foundFiles = Get-ChildItem -Path $root -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
        ($targetNames -contains $_.Name) -and
        ($_.FullName -notmatch '\\node_modules\\') -and
        ($_.FullName -notmatch '\\\.next\\') -and
        ($_.FullName -notmatch '\\dist\\') -and
        ($_.FullName -notmatch '\\build\\')
    } |
    Sort-Object FullName -Unique

if ($foundFiles.Count -eq 0) {
    Write-Host "No matching files found. Searched for:" -ForegroundColor Yellow
    $targetNames | ForEach-Object { Write-Host "  - $_" }
    Write-Host ""
    Write-Host "TIP: If your files have different names, edit the `$targetNames array in this script and re-run." -ForegroundColor Yellow
    exit 1
}

Write-Host "Found $($foundFiles.Count) file(s):" -ForegroundColor Green
$foundFiles | ForEach-Object { Write-Host "  - $($_.FullName.Substring($root.Path.Length + 1))" }
Write-Host ""

# Build JSON object: relative path -> file content
$exportObject = [ordered]@{
    generated  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    root       = $root.Path
    totalFiles = $foundFiles.Count
    files      = [ordered]@{}
}

foreach ($file in $foundFiles) {
    $relativePath = $file.FullName.Substring($root.Path.Length + 1)
    # Read raw bytes and decode as UTF-8 explicitly to avoid mojibake
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $content = [System.Text.Encoding]::UTF8.GetString($bytes)
    $exportObject.files[$relativePath] = $content
}

# Convert to JSON (depth high enough for nested content, no HTML-escaping of special chars)
$json = $exportObject | ConvertTo-Json -Depth 10 -Compress:$false

# Write out as UTF-8 WITHOUT BOM using WriteAllBytes (avoids the mojibake issue
# that plain Out-File / Set-Content with -Encoding UTF8 causes on Windows PowerShell 5.x)
$outputPath = Join-Path $root "onboarding-export.json"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$jsonBytes = $utf8NoBom.GetBytes($json)
[System.IO.File]::WriteAllBytes($outputPath, $jsonBytes)

Write-Host "Done! JSON exported to:" -ForegroundColor Green
Write-Host "  $outputPath" -ForegroundColor White
Write-Host ""
Write-Host "Open this file, copy its full content, and paste it in the chat." -ForegroundColor Cyan