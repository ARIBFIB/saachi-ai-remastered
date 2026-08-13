<#
  Fix-UiPackageBuildErrors.ps1
  ---------------------------------------------------------------------------
  Fixes two PRE-EXISTING bugs in packages/ui (not caused by the web scaffold)
  that only surface on an isolated build like Vercel's:

    1. packages/ui/src/index.ts exports "Button" from two files
       (./components/Button AND ./Button) -> conflicting star export warning.
       Fix: keep the root ./Button (the richer hover/press-state version),
       drop the ./components/Button export.

    2. packages/ui/src/RefreshButton.tsx imports @tanstack/react-query but
       packages/ui/package.json never lists it as a dependency -> works
       locally (hoisted from apps/web's node_modules) but fails in an
       isolated Vercel build.
       Fix: add @tanstack/react-query to packages/ui/package.json deps.

  Run from the SAI2 repo root:
    powershell -ExecutionPolicy Bypass -File .\Fix-UiPackageBuildErrors.ps1
#>

$ErrorActionPreference = "Stop"
$Root = (Get-Location).Path

function Write-Utf8NoBom {
    param([string]$RelativePath, [string]$Content)
    $fullPath = Join-Path $Root $RelativePath
    [System.IO.File]::WriteAllText($fullPath, $Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  wrote $RelativePath"
}

Write-Host "== SAI2 :: fixing packages/ui build errors ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Fix duplicate Button export in packages/ui/src/index.ts
# ---------------------------------------------------------------------------
$indexPath = Join-Path $Root "packages/ui/src/index.ts"
$indexContent = Get-Content -Raw -LiteralPath $indexPath -Encoding UTF8

$oldLine = 'export * from "./components/Button";'
if ($indexContent -match [regex]::Escape($oldLine)) {
    $indexContent = $indexContent -replace [regex]::Escape($oldLine), '// export * from "./components/Button"; // removed: duplicate Button export, canonical Button now comes from ./Button'
    Write-Utf8NoBom "packages/ui/src/index.ts" $indexContent
    Write-Host "  fixed: removed duplicate ./components/Button export"
} else {
    Write-Host "  skipped: duplicate export line not found (may already be fixed)"
}

# ---------------------------------------------------------------------------
# 2. Add @tanstack/react-query to packages/ui/package.json
# ---------------------------------------------------------------------------
$pkgPath = Join-Path $Root "packages/ui/package.json"
$pkgJson = Get-Content -Raw -LiteralPath $pkgPath -Encoding UTF8 | ConvertFrom-Json

if (-not $pkgJson.dependencies.PSObject.Properties.Name -contains "@tanstack/react-query") {
    $pkgJson.dependencies | Add-Member -NotePropertyName "@tanstack/react-query" -NotePropertyValue "^5.56.0" -Force
    $updated = $pkgJson | ConvertTo-Json -Depth 10
    Write-Utf8NoBom "packages/ui/package.json" $updated
    Write-Host "  fixed: added @tanstack/react-query to packages/ui dependencies"
} else {
    Write-Host "  skipped: @tanstack/react-query already present"
}

Write-Host ""
Write-Host "== Done. Now run: ==" -ForegroundColor Green
Write-Host "  pnpm install"
Write-Host "  pnpm --filter web build   (to verify locally before pushing)"
Write-Host "  git add -A; git commit -m `"fix: resolve duplicate Button export and missing react-query dep in ui package`"; git push"