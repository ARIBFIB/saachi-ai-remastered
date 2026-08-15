<#
  fix-lint-warnings.ps1
  Fixes the 8 remaining ESLint warnings from the latest CodeScan report:

    apps/web:
      1. app/error.tsx:14            - unused eslint-disable (no-console)
      2. components/ui/image-cursor-trail.tsx:118 - missing next/image note
      3. components/ui/image-stream-hero.tsx:105  - missing next/image note
      4. postcss.config.mjs:1        - anonymous default export

    apps/admin:
      5. app/(console)/dashboard/page.tsx:307 - unused eslint-disable
      6. app/(console)/dashboard/page.tsx:362 - useMemo missing dep 'allKpis'
      7. app/(console)/users/page.tsx:328     - useMemo missing deps
                                                 'buildActions', 'toggleSelectAll'
      8. postcss.config.mjs:1        - anonymous default export

  All edits are line-targeted based on the exact line numbers ESLint
  reported, and print a manual TODO note if a file no longer matches the
  expected shape (e.g. because it changed since the report was generated)
  instead of guessing and risking broken code.

  Run from: SAI2 root
    PS D:\...\SAI2> .\fix-lint-warnings.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
$webRoot = Join-Path $root "apps\web"
$adminRoot = Join-Path $root "apps\admin"

$encNoBom = New-Object System.Text.UTF8Encoding($false)
$manualTodos = New-Object System.Collections.Generic.List[string]

function Write-Utf8NoBom {
    param([string]$Path, [string[]]$Lines)
    [System.IO.File]::WriteAllLines($Path, $Lines, $encNoBom)
    Write-Host "  wrote: $Path"
}

function Edit-Line {
    <#
      Applies a transform to a single 1-indexed line of a file.
      $Transform receives the existing line text and must return either:
        - a single string (replacement line)
        - an array of strings (to insert multiple lines / delete via @())
      If the file doesn't exist, or the line doesn't match $ExpectedPattern,
      nothing is changed and a manual TODO is queued instead.
    #>
    param(
        [string]$Path,
        [int]$LineNumber,
        [string]$ExpectedPattern,
        [scriptblock]$Transform,
        [string]$Label
    )

    if (-not [System.IO.File]::Exists($Path)) {
        $manualTodos.Add("SKIPPED (file not found): $Label -> $Path")
        return
    }

    $lines = [System.IO.File]::ReadAllLines($Path)
    $index = $LineNumber - 1

    if ($index -lt 0 -or $index -ge $lines.Length) {
        $manualTodos.Add("SKIPPED (line $LineNumber out of range): $Label -> $Path")
        return
    }

    $current = $lines[$index]

    if ($current -notmatch $ExpectedPattern) {
        $manualTodos.Add("MANUAL CHECK NEEDED: $Label -> $Path`:$LineNumber (line content changed, didn't match expected pattern). Current line: $current")
        return
    }

    $result = & $Transform $current

    $before = $lines[0..($index - 1)]
    $after = if ($index + 1 -lt $lines.Length) { $lines[($index + 1)..($lines.Length - 1)] } else { @() }

    $newLines = @()
    if ($before) { $newLines += $before }
    if ($result -is [array]) { $newLines += $result } else { $newLines += , $result }
    if ($after) { $newLines += $after }

    Write-Utf8NoBom -Path $Path -Lines $newLines
    Write-Host "  fixed: $Label (line $LineNumber)"
}

Write-Host "== apps/web fixes ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. app/error.tsx:14 - unused eslint-disable (no-console)
# ---------------------------------------------------------------------------
Edit-Line -Path (Join-Path $webRoot "app\error.tsx") `
    -LineNumber 14 `
    -ExpectedPattern 'eslint-disable-next-line no-console' `
    -Label "app/error.tsx - unused no-console disable" `
    -Transform { param($line) @() }   # delete the line entirely

# ---------------------------------------------------------------------------
# 2. components/ui/image-cursor-trail.tsx:118 - <img> without a disable note
# ---------------------------------------------------------------------------
Edit-Line -Path (Join-Path $webRoot "components\ui\image-cursor-trail.tsx") `
    -LineNumber 118 `
    -ExpectedPattern '<img' `
    -Label "image-cursor-trail.tsx - next/image warning" `
    -Transform {
        param($line)
        $indent = ($line -replace '^(\s*).*', '$1')
        @(
            "$indent{/* eslint-disable-next-line @next/next/no-img-element -- intentional: dynamic cursor-trail image, next/image not suitable here */}",
            $line
        )
    }

# ---------------------------------------------------------------------------
# 3. components/ui/image-stream-hero.tsx:105 - <img> without a disable note
# ---------------------------------------------------------------------------
Edit-Line -Path (Join-Path $webRoot "components\ui\image-stream-hero.tsx") `
    -LineNumber 105 `
    -ExpectedPattern '<img' `
    -Label "image-stream-hero.tsx - next/image warning" `
    -Transform {
        param($line)
        $indent = ($line -replace '^(\s*).*', '$1')
        @(
            "$indent{/* eslint-disable-next-line @next/next/no-img-element -- intentional: CSS-animated corridor images, next/image not suitable here */}",
            $line
        )
    }

# ---------------------------------------------------------------------------
# 4. apps/web/postcss.config.mjs - anonymous default export
# ---------------------------------------------------------------------------
$webPostcssPath = Join-Path $webRoot "postcss.config.mjs"
if ([System.IO.File]::Exists($webPostcssPath)) {
    $newPostcss = @(
        'const config = {',
        '  plugins: {',
        '    "@tailwindcss/postcss": {}',
        '  }',
        '};',
        '',
        'export default config;'
    )
    Write-Utf8NoBom -Path $webPostcssPath -Lines $newPostcss
    Write-Host "  fixed: apps/web/postcss.config.mjs (named config object)"
} else {
    $manualTodos.Add("SKIPPED (file not found): apps/web/postcss.config.mjs")
}

Write-Host ""
Write-Host "== apps/admin fixes ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 5. app/(console)/dashboard/page.tsx:307 - unused eslint-disable
# ---------------------------------------------------------------------------
$dashboardPath = Join-Path $adminRoot "app\(console)\dashboard\page.tsx"
Edit-Line -Path $dashboardPath `
    -LineNumber 307 `
    -ExpectedPattern 'eslint-disable-next-line react-hooks/exhaustive-deps' `
    -Label "dashboard/page.tsx - unused exhaustive-deps disable" `
    -Transform { param($line) @() }   # delete the line entirely

# ---------------------------------------------------------------------------
# 6. app/(console)/dashboard/page.tsx:362 - useMemo missing dep 'allKpis'
#    NOTE: line number shifts down by 1 after fix #5 removed a line above it.
# ---------------------------------------------------------------------------
Edit-Line -Path $dashboardPath `
    -LineNumber 361 `
    -ExpectedPattern '^\s*\},?\s*\[[^\]]*\]\s*\)\s*;?\s*$' `
    -Label "dashboard/page.tsx - useMemo missing dep 'allKpis'" `
    -Transform {
        param($line)
        if ($line -match '\[\s*\]') {
            $line -replace '\[\s*\]', '[allKpis]'
        } elseif ($line -match '\[([^\]]*)\]') {
            $depsInside = $Matches[1].TrimEnd()
            if ($depsInside -match '\ballKpis\b') {
                $line
            } elseif ($depsInside -eq '') {
                $line -replace '\[\]', '[allKpis]'
            } else {
                $line -replace [regex]::Escape($Matches[1]), "$depsInside, allKpis"
            }
        } else {
            $line
        }
    }

# ---------------------------------------------------------------------------
# 7. app/(console)/users/page.tsx:328 - useMemo missing deps
#    'buildActions', 'toggleSelectAll'
# ---------------------------------------------------------------------------
$usersPath = Join-Path $adminRoot "app\(console)\users\page.tsx"
Edit-Line -Path $usersPath `
    -LineNumber 328 `
    -ExpectedPattern '^\s*\},?\s*\[[^\]]*\]\s*\)\s*;?\s*$' `
    -Label "users/page.tsx - useMemo missing deps 'buildActions', 'toggleSelectAll'" `
    -Transform {
        param($line)
        if ($line -match '\[([^\]]*)\]') {
            $depsInside = $Matches[1].TrimEnd()
            $toAdd = @()
            if ($depsInside -notmatch '\bbuildActions\b') { $toAdd += "buildActions" }
            if ($depsInside -notmatch '\btoggleSelectAll\b') { $toAdd += "toggleSelectAll" }
            if ($toAdd.Count -eq 0) {
                $line
            } elseif ($depsInside -eq '') {
                $line -replace '\[\]', ("[" + ($toAdd -join ", ") + "]")
            } else {
                $newDeps = $depsInside + ", " + ($toAdd -join ", ")
                $line -replace [regex]::Escape($Matches[1]), $newDeps
            }
        } else {
            $line
        }
    }

# ---------------------------------------------------------------------------
# 8. apps/admin/postcss.config.mjs - anonymous default export
# ---------------------------------------------------------------------------
$adminPostcssPath = Join-Path $adminRoot "postcss.config.mjs"
if ([System.IO.File]::Exists($adminPostcssPath)) {
    $newAdminPostcss = @(
        'const config = {',
        '  plugins: {',
        '    "@tailwindcss/postcss": {}',
        '  }',
        '};',
        '',
        'export default config;'
    )
    Write-Utf8NoBom -Path $adminPostcssPath -Lines $newAdminPostcss
    Write-Host "  fixed: apps/admin/postcss.config.mjs (named config object)"
} else {
    $manualTodos.Add("SKIPPED (file not found): apps/admin/postcss.config.mjs")
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Host ""
if ($manualTodos.Count -gt 0) {
    Write-Host "== Items needing a manual look ==" -ForegroundColor Yellow
    foreach ($item in $manualTodos) {
        Write-Host "  - $item" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Re-run scan-codebase-errors.ps1 to confirm all warnings are gone."