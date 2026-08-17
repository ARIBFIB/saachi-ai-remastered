<#
  Fix-QuizBuilderSyntax.ps1  (v2 - LiteralPath fix)
  Fixes invalid JS identifiers in Phase-1 placeholder pages caused by
  hyphenated route segments. Uses -LiteralPath everywhere so dynamic route
  folders like [id], [lessonId], [courseId] (square brackets) don't get
  misinterpreted as PowerShell wildcards.

  Run from: SAI2 root
    PS D:\...\SAI2> .\Fix-QuizBuilderSyntax.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
$instructorAppDir = Join-Path $root "apps\web\app\(instructor)\instructor"

if (-not (Test-Path -LiteralPath $instructorAppDir)) {
    Write-Host "ERROR: app/(instructor)/instructor not found. Run from SAI2 root." -ForegroundColor Red
    exit 1
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$fixedCount = 0
$skippedCount = 0

Write-Host "== Scanning instructor placeholder pages for invalid function identifiers ==" -ForegroundColor Cyan

# Recurse manually instead of Get-ChildItem -Recurse with wildcard-prone
# paths, to stay safe with bracketed folder names like [id].
function Get-PageFilesRecursive($dir) {
    $results = @()
    $items = Get-ChildItem -LiteralPath $dir -Force
    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            $results += Get-PageFilesRecursive -dir $item.FullName
        } elseif ($item.Name -eq "page.tsx") {
            $results += $item.FullName
        }
    }
    return $results
}

$pageFiles = Get-PageFilesRecursive -dir $instructorAppDir

foreach ($filePath in $pageFiles) {
    try {
        # Use .NET directly to avoid any PowerShell provider path-parsing quirks
        $content = [System.IO.File]::ReadAllText($filePath)
    } catch {
        Write-Host "  Could not read: $filePath ($($_.Exception.Message))" -ForegroundColor Yellow
        $skippedCount++
        continue
    }

    if ($content -match 'export default function ([A-Za-z0-9_-]*-[A-Za-z0-9_-]*)\s*\(') {
        $badName = $matches[1]
        $fixedName = $badName -replace '-', ''

        Write-Host "`n  Found invalid identifier in: $filePath"
        Write-Host "    '$badName' -> '$fixedName'"

        $backupPath = "$filePath.bak-$timestamp"
        Copy-Item -LiteralPath $filePath -Destination $backupPath
        Write-Host "    Backed up -> $backupPath"

        $newContent = $content -replace [regex]::Escape($badName), $fixedName
        [System.IO.File]::WriteAllText($filePath, $newContent)
        Write-Host "    Fixed." -ForegroundColor Green

        $fixedCount++
    }
}

Write-Host "`n== Done ==" -ForegroundColor Cyan
if ($fixedCount -eq 0) {
    Write-Host "No invalid identifiers found. Nothing to fix (quiz-builder was already fixed in the previous run)."
} else {
    Write-Host "Fixed $fixedCount file(s)." -ForegroundColor Green
}
if ($skippedCount -gt 0) {
    Write-Host "Skipped $skippedCount unreadable file(s) - check messages above." -ForegroundColor Yellow
}
Write-Host "`nNext: cd apps\web ; pnpm run build   -- to confirm the build passes now."