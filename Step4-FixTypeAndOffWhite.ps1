$ErrorActionPreference = "Stop"
$root = Get-Location

$buttonPath = Join-Path $root "packages\ui\src\components\Button.tsx"
$globalsPath = Join-Path $root "apps\web\app\globals.css"

foreach ($p in @($buttonPath, $globalsPath)) {
    if (-not (Test-Path -LiteralPath $p)) {
        Write-Error "File not found: $p -- run this script from the SAI2 root."
        exit 1
    }
}

$backupDir = Join-Path $root "theme-migration-backup\step4"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item -LiteralPath $buttonPath -Destination (Join-Path $backupDir "Button.tsx.bak") -Force
Copy-Item -LiteralPath $globalsPath -Destination (Join-Path $backupDir "globals.css.bak") -Force
Write-Host "Backups saved to: $backupDir"
Write-Host ""

# 1. Fix ButtonVariant type union to include "brand"
$buttonContent = Get-Content -LiteralPath $buttonPath -Raw
$fixedType = $false

$typePatterns = @(
    @{ Old = '"primary" | "secondary" | "ghost" | "danger"'; New = '"primary" | "secondary" | "ghost" | "danger" | "brand"' },
    @{ Old = '"primary" | "secondary" | "danger" | "ghost"'; New = '"primary" | "secondary" | "danger" | "ghost" | "brand"' },
    @{ Old = "'primary' | 'secondary' | 'ghost' | 'danger'"; New = "'primary' | 'secondary' | 'ghost' | 'danger' | 'brand'" }
)

foreach ($pattern in $typePatterns) {
    if ($buttonContent.Contains($pattern.Old)) {
        $buttonContent = $buttonContent.Replace($pattern.Old, $pattern.New)
        $fixedType = $true
        Write-Host "OK -- ButtonVariant type updated to include brand."
        break
    }
}

if ($fixedType) {
    Set-Content -LiteralPath $buttonPath -Value $buttonContent -Encoding UTF8 -NoNewline
} else {
    Write-Host "SKIPPED -- could not find the ButtonVariant type union with a known pattern."
    Write-Host "Run this and paste the output:"
    Write-Host '  Get-Content "packages\ui\src\components\Button.tsx" | Select-String "variant"'
}

# 2. Remove pure white from light mode
$globalsContent = Get-Content -LiteralPath $globalsPath -Raw

$oldPaper = '--color-paper: #fafaf8;'
$newPaper = '--color-paper: #f6f4f9;'
$oldPaperDim = '--color-paper-dim: #f0efec;'
$newPaperDim = '--color-paper-dim: #edeaf2;'
$oldCard = '--color-card: #ffffff;'
$newCard = '--color-card: #f3f0f7;'
$oldLine = '--color-line: #e6e4e0;'
$newLine = '--color-line: #e2dce9;'
$oldLineStrong = '--color-line-strong: #d3d0ca;'
$newLineStrong = '--color-line-strong: #cdc4d6;'

$pairs = @(
    ,@($oldPaper, $newPaper)
    ,@($oldPaperDim, $newPaperDim)
    ,@($oldCard, $newCard)
    ,@($oldLine, $newLine)
    ,@($oldLineStrong, $newLineStrong)
)

foreach ($pair in $pairs) {
    $old = $pair[0]
    $new = $pair[1]
    $count = ([regex]::Matches($globalsContent, [regex]::Escape($old))).Count
    if ($count -eq 1) {
        $globalsContent = $globalsContent.Replace($old, $new)
        Write-Host "OK -- $old -> $new"
    } elseif ($count -gt 1) {
        Write-Host "SKIPPED -- '$old' appears $count times (expected 1)."
    } else {
        Write-Host "SKIPPED -- '$old' not found."
    }
}

Set-Content -LiteralPath $globalsPath -Value $globalsContent -Encoding UTF8 -NoNewline

Write-Host ""
Write-Host "Step 4 complete. Light mode card is now #f3f0f7 (violet-tinted"
Write-Host "off-white), page background #f6f4f9 -- no pure white anywhere."
Write-Host ""
Write-Host "Run: pnpm --filter web build"