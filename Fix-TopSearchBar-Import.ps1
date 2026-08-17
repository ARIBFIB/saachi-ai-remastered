# Fix-TopSearchBar-Import.ps1
$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$landingPagePath = Join-Path -Path $root -ChildPath "apps\web\app\(marketing)\page.tsx"

if (-not (Test-Path -LiteralPath $landingPagePath)) {
    throw "File not found: $landingPagePath"
}

$page = Get-Content -Raw -LiteralPath $landingPagePath

if ($page -match 'import \{ TopSearchBar \} from "\.\./_components/TopSearchBar";') {
    Write-Host "Import already present. Nothing to do." -ForegroundColor Yellow
} else {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    Copy-Item -LiteralPath $landingPagePath -Destination "$landingPagePath.bak-$timestamp"

    $before = $page

    # Insert import after the last existing import line, robustly.
    $importLine = 'import { TopSearchBar } from "../_components/TopSearchBar";'

    if ($page -match '(?m)^import .+;\r?\n') {
        # find position after the LAST top-of-file import statement (before first blank line / non-import)
        $lines = $page -split "`r?`n"
        $lastImportIndex = -1
        for ($i = 0; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -match '^import .+;$') { $lastImportIndex = $i }
            elseif ($lastImportIndex -ge 0 -and $lines[$i].Trim() -eq "") { break }
            elseif ($lastImportIndex -ge 0 -and $lines[$i] -notmatch '^import .+;$') { break }
        }
        if ($lastImportIndex -ge 0) {
            $lines = $lines[0..$lastImportIndex] + @($importLine) + $lines[($lastImportIndex+1)..($lines.Length-1)]
            $page = $lines -join "`r`n"
        }
    }

    if ($page -eq $before) {
        Write-Warning "Could not auto-insert import. Add this line manually near the top imports of (marketing)/page.tsx:"
        Write-Host $importLine -ForegroundColor Cyan
    } else {
        Write-Utf8NoBom -Path $landingPagePath -Content $page
        Write-Host "Import added successfully." -ForegroundColor Green
    }
}