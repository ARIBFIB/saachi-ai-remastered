<#
  fix-broken-jsx-and-deps.ps1

  Repairs damage from the earlier fix-lint-warnings.ps1 run, which inserted
  a `{/* eslint-disable-next-line ... */}` comment directly before a lone
  JSX element sitting inside a parenthesized arrow-function return (i.e.
  `(<img ... />)` with nothing else in that group). That turned one JSX
  element into two adjacent siblings with no wrapping Fragment, which is a
  syntax error - exactly the "')' expected" / "Identifier expected" errors
  from the latest scan.

  Fix strategy (safe, no structural JSX guessing needed):
    - Remove the bad inline comment line.
    - Add a FILE-LEVEL `/* eslint-disable @next/next/no-img-element */`
      comment right after "use client"; instead. This disables the rule
      for the whole file without touching JSX structure at all.

  Also makes another, more lenient attempt at the two outstanding
  react-hooks/exhaustive-deps warnings in apps/admin. If it still can't
  find a confident single-line match, it prints the exact surrounding
  lines from the file so you can fix it by hand in 10 seconds - no
  guessing / no risk of corrupting the file further.

  Run from: SAI2 root
    PS D:\...\SAI2> .\fix-broken-jsx-and-deps.ps1
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

function Repair-BrokenImgDisable {
    param(
        [string]$Path,
        [string]$BadCommentSubstring,
        [string]$Label
    )

    if (-not [System.IO.File]::Exists($Path)) {
        $manualTodos.Add("SKIPPED (file not found): $Label -> $Path")
        return
    }

    $lines = [System.IO.File]::ReadAllLines($Path)
    $newLines = New-Object System.Collections.Generic.List[string]
    $removedCount = 0

    foreach ($line in $lines) {
        if ($line.Contains($BadCommentSubstring)) {
            $removedCount++
            continue   # drop this line - it's the JSX-breaking comment
        }
        $newLines.Add($line)
    }

    if ($removedCount -eq 0) {
        $manualTodos.Add("MANUAL CHECK NEEDED: $Label -> could not find the broken comment line to remove. Check for a stray `{/* eslint-disable-next-line @next/next/no-img-element ... */}` sitting alone before an <img> and delete it, then add a file-level disable instead.")
        return
    }

    # Now insert a file-level disable comment right after "use client";
    # (only if one isn't already present).
    $alreadyHasFileDisable = $newLines | Where-Object { $_ -match '^\s*/\*\s*eslint-disable\s+@next/next/no-img-element\s*\*/\s*$' }

    if (-not $alreadyHasFileDisable) {
        $useClientIndex = -1
        for ($i = 0; $i -lt $newLines.Count; $i++) {
            if ($newLines[$i] -match '^\s*"use client"\s*;\s*$') {
                $useClientIndex = $i
                break
            }
        }

        if ($useClientIndex -ge 0) {
            $newLines.Insert($useClientIndex + 1, "")
            $newLines.Insert($useClientIndex + 2, "/* eslint-disable @next/next/no-img-element -- intentional: this file renders raw <img> for effects (cursor trails / animated corridors) where next/image isn't a fit. */")
        } else {
            # no "use client" line found - prepend at very top as a fallback
            $newLines.Insert(0, "/* eslint-disable @next/next/no-img-element -- intentional: this file renders raw <img> for effects (cursor trails / animated corridors) where next/image isn't a fit. */")
        }
    }

    Write-Utf8NoBom -Path $Path -Lines $newLines
    Write-Host "  fixed: $Label (removed $removedCount broken comment line(s), added file-level disable)"
}

Write-Host "== Repairing broken JSX in apps/web ==" -ForegroundColor Cyan

Repair-BrokenImgDisable `
    -Path (Join-Path $webRoot "components\ui\image-cursor-trail.tsx") `
    -BadCommentSubstring "intentional: dynamic cursor-trail image, next/image not suitable here" `
    -Label "image-cursor-trail.tsx"

Repair-BrokenImgDisable `
    -Path (Join-Path $webRoot "components\ui\image-stream-hero.tsx") `
    -BadCommentSubstring "intentional: CSS-animated corridor images, next/image not suitable here" `
    -Label "image-stream-hero.tsx"

Write-Host ""
Write-Host "== Attempting react-hooks/exhaustive-deps fixes in apps/admin ==" -ForegroundColor Cyan

function Try-FixDependencyArray {
    param(
        [string]$Path,
        [int]$ApproxLine,
        [string[]]$MissingDeps,
        [string]$Label
    )

    if (-not [System.IO.File]::Exists($Path)) {
        $manualTodos.Add("SKIPPED (file not found): $Label -> $Path")
        return
    }

    $lines = [System.IO.File]::ReadAllLines($Path)
    $windowStart = [Math]::Max(0, $ApproxLine - 6)
    $windowEnd = [Math]::Min($lines.Count - 1, $ApproxLine + 2)

    $fixedIndex = -1
    for ($i = $ApproxLine - 1; $i -ge $windowStart; $i--) {
        $line = $lines[$i]
        if ($line -match '\[([^\[\]]*)\]') {
            $depsInside = $Matches[1].Trim()
            $toAdd = @()
            foreach ($dep in $MissingDeps) {
                if ($depsInside -notmatch "\b$([regex]::Escape($dep))\b") {
                    $toAdd += $dep
                }
            }
            if ($toAdd.Count -eq 0) {
                # Already has all deps somehow - nothing to do.
                $fixedIndex = $i
                break
            }
            $newDeps = if ($depsInside -eq "") { ($toAdd -join ", ") } else { "$depsInside, " + ($toAdd -join ", ") }
            $lines[$i] = $line -replace [regex]::Escape($Matches[1]), $newDeps
            $fixedIndex = $i
            break
        }
    }

    if ($fixedIndex -ge 0) {
        Write-Utf8NoBom -Path $Path -Lines $lines
        Write-Host "  fixed: $Label (line $($fixedIndex + 1))"
    } else {
        $context = ($lines[$windowStart..$windowEnd] | ForEach-Object { "    $_" }) -join "`n"
        $manualTodos.Add("MANUAL FIX NEEDED: $Label -> couldn't find a single-line dependency array near line $ApproxLine in $Path.`nAdd { $($MissingDeps -join ', ') } to the dependency array by hand. Context (lines $($windowStart+1)-$($windowEnd+1)):`n$context")
    }
}

Try-FixDependencyArray `
    -Path (Join-Path $adminRoot "app\(console)\dashboard\page.tsx") `
    -ApproxLine 362 `
    -MissingDeps @("allKpis") `
    -Label "dashboard/page.tsx - useMemo missing dep 'allKpis'"

Try-FixDependencyArray `
    -Path (Join-Path $adminRoot "app\(console)\users\page.tsx") `
    -ApproxLine 328 `
    -MissingDeps @("buildActions", "toggleSelectAll") `
    -Label "users/page.tsx - useMemo missing deps 'buildActions', 'toggleSelectAll'"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Host ""
if ($manualTodos.Count -gt 0) {
    Write-Host "== Items needing a manual look ==" -ForegroundColor Yellow
    foreach ($item in $manualTodos) {
        Write-Host ""
        Write-Host "  - $item" -ForegroundColor Yellow
    }
    Write-Host ""
}

Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Re-run scan-codebase-errors.ps1 to confirm the syntax errors are gone."