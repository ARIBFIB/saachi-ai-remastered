<#
    check-routing.ps1

    Static route/navigation checker for apps/web (Next.js App Router).

    What it does:
      1. Scans apps/web/app for every page.tsx to build the list of REAL
         routes that exist (converting [slug]/[id] segments to :param, and
         stripping route-group folders like (marketing), (learner), etc.)
      2. Scans every .tsx file for href="..." and Link href={`...`} usages
         that point to internal routes (starting with "/")
      3. Cross-checks each used href against the real route list and
         reports any that don't match anything (likely broken links / pages
         that don't exist yet).

    NOTE: this is a STATIC text-based check, not a real crawl/click test.
    It won't catch things like disabled buttons, JS-only navigation without
    Link/href, or auth-gated redirects. But it will catch the most common
    issue: a Link pointing to a route that was never built.

    Run from SAI2 root:
      PS D:\...\SAI2> .\check-routing.ps1

    Output: ProjectCode_RouteCheck.txt in the SAI2 root.
#>

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

$webApp = Join-Path $root "apps\web\app"
$outFile = Join-Path $root "ProjectCode_RouteCheck.txt"

if (-not (Test-Path -LiteralPath $webApp)) {
    Write-Host "Could not find apps\web\app under $root" -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# Step 1: build the list of real routes from page.tsx files
# ------------------------------------------------------------------
$pageFiles = Get-ChildItem -LiteralPath $webApp -Recurse -Filter "page.tsx" -File -ErrorAction SilentlyContinue

$realRoutes = New-Object System.Collections.Generic.List[string]
$routeToFile = @{}

foreach ($pf in $pageFiles) {
    $rel = $pf.FullName.Substring($webApp.Length).TrimStart('\')
    $rel = $rel -replace '\\page\.tsx$', ''
    $rel = $rel -replace '\\', '/'

    # strip route groups like (marketing), (auth), (learner), (instructor), (console)
    $segments = $rel -split '/'
    $cleanSegments = @()
    foreach ($seg in $segments) {
        if ($seg -match '^\(.*\)$') { continue }  # skip route groups
        $cleanSegments += $seg
    }
    $route = '/' + ($cleanSegments -join '/')
    $route = $route -replace '/+$', ''
    if ($route -eq '') { $route = '/' }

    # convert [param] and [...param] to a wildcard marker for matching
    $routePattern = $route -replace '\[\.\.\.[^\]]+\]', '__CATCHALL__'
    $routePattern = $routePattern -replace '\[[^\]]+\]', '__PARAM__'

    if (-not $realRoutes.Contains($routePattern)) {
        $realRoutes.Add($routePattern) | Out-Null
    }
    $routeToFile[$routePattern] = $rel
}

# ------------------------------------------------------------------
# Step 2: scan all tsx/ts files for internal href usages
# ------------------------------------------------------------------
$allSourceFiles = Get-ChildItem -LiteralPath (Join-Path $root "apps\web") -Recurse -Include "*.tsx","*.ts" -File -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '\\node_modules\\' -and $_.FullName -notmatch '\\\.next\\' }

# Matches: href="/something"  or  href={`/something/${x}`}  or href={"/something"}
$hrefRegex = [regex]'href=\{?["`]([^"`{}]*)'

$foundLinks = New-Object System.Collections.Generic.List[object]

foreach ($sf in $allSourceFiles) {
    $text = [System.IO.File]::ReadAllText($sf.FullName)
    $matches = $hrefRegex.Matches($text)
    foreach ($m in $matches) {
        $hrefVal = $m.Groups[1].Value
        if (-not $hrefVal.StartsWith('/')) { continue }   # skip external/mailto/etc
        if ($hrefVal.StartsWith('//')) { continue }

        $relSource = $sf.FullName.Substring($root.Length).TrimStart('\')
        $foundLinks.Add([PSCustomObject]@{
            SourceFile = $relSource
            Href       = $hrefVal
        }) | Out-Null
    }
}

# ------------------------------------------------------------------
# Step 3: normalize each found href into a comparable pattern and check
# ------------------------------------------------------------------
function Normalize-Href {
    param([string]$Href)

    # strip query string / hash
    $h = $Href -split '\?' | Select-Object -First 1
    $h = $h -split '#' | Select-Object -First 1
    $h = $h -replace '/+$', ''
    if ($h -eq '') { $h = '/' }

    # replace template-literal dynamic segments like ${x.id} or ${courseId} with a param marker
    $h = $h -replace '\$\{[^}]*\}', '__PARAM__'

    return $h
}

$results = New-Object System.Collections.Generic.List[object]

foreach ($link in $foundLinks) {
    $norm = Normalize-Href -Href $link.Href

    $isMatch = $false
    foreach ($rp in $realRoutes) {
        # build a comparable version of the route pattern (already has __PARAM__/__CATCHALL__)
        $rpEscaped = [regex]::Escape($rp) -replace '__PARAM__', '[^/]+' -replace '__CATCHALL__', '.+'
        $rpEscaped = $rpEscaped -replace '\\_\\_PARAM\\_\\_', '[^/]+'
        if ($norm -match "^$rpEscaped$") { $isMatch = $true; break }

        # also try direct normalized-vs-normalized comparison for simple param hrefs
        $normForCompare = $norm -replace '__PARAM__', '[^/]+'
        if ($rp -match "^$normForCompare$") { $isMatch = $true; break }
    }

    $results.Add([PSCustomObject]@{
        SourceFile = $link.SourceFile
        Href       = $link.Href
        Matched    = $isMatch
    }) | Out-Null
}

# ------------------------------------------------------------------
# Step 4: write report
# ------------------------------------------------------------------
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("ROUTE / NAVIGATION CHECK REPORT")
[void]$sb.AppendLine("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Real routes found (from page.tsx files): $($realRoutes.Count)")
[void]$sb.AppendLine("Internal hrefs/Links scanned: $($results.Count)")
[void]$sb.AppendLine("")

$broken = $results | Where-Object { -not $_.Matched } | Sort-Object SourceFile, Href -Unique
$ok = $results | Where-Object { $_.Matched }

[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("POTENTIALLY BROKEN LINKS (href doesn't match any known route): $($broken.Count)")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("")

if ($broken.Count -eq 0) {
    [void]$sb.AppendLine("None found. Every internal href matched a real route.")
}
else {
    foreach ($b in ($broken | Sort-Object Href)) {
        [void]$sb.AppendLine("HREF: $($b.Href)")
        [void]$sb.AppendLine("  found in: $($b.SourceFile)")
        [void]$sb.AppendLine("")
    }
}

[void]$sb.AppendLine("")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("ALL REAL ROUTES DISCOVERED (from page.tsx files)")
[void]$sb.AppendLine("================================================================================")
[void]$sb.AppendLine("")
foreach ($r in ($realRoutes | Sort-Object)) {
    [void]$sb.AppendLine("  $r   <-  $($routeToFile[$r])")
}

[System.IO.File]::WriteAllText($outFile, $sb.ToString(), [System.Text.Encoding]::UTF8)

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Real routes found: $($realRoutes.Count)" -ForegroundColor Cyan
Write-Host "Internal links scanned: $($results.Count)" -ForegroundColor Cyan
Write-Host "Potentially broken links: $($broken.Count)" -ForegroundColor $(if ($broken.Count -gt 0) { "Yellow" } else { "Green" })
Write-Host "Report written to: $outFile" -ForegroundColor Cyan