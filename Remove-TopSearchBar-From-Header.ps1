# Remove-TopSearchBar-From-Header.ps1
$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$headerPath = Join-Path -Path $root -ChildPath "apps\web\app\_components\SiteHeader.tsx"

if (-not (Test-Path -LiteralPath $headerPath)) {
    throw "File not found: $headerPath"
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
Copy-Item -LiteralPath $headerPath -Destination "$headerPath.bak-$timestamp"
Write-Host "Backup created: SiteHeader.tsx.bak-$timestamp" -ForegroundColor Cyan

$content = Get-Content -Raw -LiteralPath $headerPath
$original = $content

$patterns = @(
    @{ Name = "import usePathname";        Pattern = 'import\s*\{\s*usePathname\s*\}\s*from\s*"next/navigation";\s*\r?\n' },
    @{ Name = "import TopSearchBar";        Pattern = 'import\s*\{\s*TopSearchBar,\s*useSearchBarHidden\s*\}\s*from\s*"\./TopSearchBar";\s*\r?\n' },
    @{ Name = "const searchHidden";         Pattern = '\s*const\s+searchHidden\s*=\s*useSearchBarHidden\(\);\s*\r?\n' },
    @{ Name = "const pathname";             Pattern = '\s*const\s+pathname\s*=\s*usePathname\(\);\s*\r?\n' },
    @{ Name = "const isCheckoutRoute";      Pattern = '\s*const\s+isCheckoutRoute\s*=\s*pathname\?\.startsWith\("/checkout"\)\s*\?\?\s*false;\s*\r?\n' },
    @{ Name = "render TopSearchBar";        Pattern = '\r?\n?\s*<TopSearchBar\s+hidden=\{searchHidden\s*\|\|\s*isCheckoutRoute\}\s*/>\s*\r?\n' }
)

foreach ($p in $patterns) {
    if ($content -match $p.Pattern) {
        $content = [regex]::Replace($content, $p.Pattern, "`n", 1)
        Write-Host "Removed: $($p.Name)" -ForegroundColor Green
    } else {
        Write-Warning "Not found (skipped): $($p.Name)"
    }
}

# collapse any accidental triple+ blank lines left behind
$content = [regex]::Replace($content, "(\r?\n){3,}", "`n`n")

if ($content -eq $original) {
    Write-Warning "No changes were made at all. File may already be clean, or structure differs from expected."
} else {
    Write-Utf8NoBom -Path $headerPath -Content $content
    Write-Host "`nSiteHeader.tsx updated successfully." -ForegroundColor Green
}

Write-Host "`nDone. Now run your build again." -ForegroundColor Cyan