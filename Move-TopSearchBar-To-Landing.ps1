# Move-TopSearchBar-To-Landing.ps1
# Removes TopSearchBar from sticky SiteHeader and places it standalone in the
# landing page hero section. Run this from the SAI2 repo root.

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$headerPath       = Join-Path -Path $root -ChildPath "apps\web\app\_components\SiteHeader.tsx"
$topSearchBarPath = Join-Path -Path $root -ChildPath "apps\web\app\_components\TopSearchBar.tsx"
$landingPagePath  = Join-Path -Path $root -ChildPath "apps\web\app\(marketing)\page.tsx"

foreach ($p in @($headerPath, $topSearchBarPath, $landingPagePath)) {
    if (-not (Test-Path -LiteralPath $p)) {
        throw "File not found: $p"
    }
}

# Backups
Copy-Item -LiteralPath $headerPath       -Destination "$headerPath.bak-$timestamp"
Copy-Item -LiteralPath $topSearchBarPath -Destination "$topSearchBarPath.bak-$timestamp"
Copy-Item -LiteralPath $landingPagePath  -Destination "$landingPagePath.bak-$timestamp"

Write-Host "Backups created with suffix .bak-$timestamp" -ForegroundColor Cyan

# =========================================================================
# 1. SiteHeader.tsx -- remove TopSearchBar usage
# =========================================================================
$header = Get-Content -Raw -LiteralPath $headerPath

$before = $header

$header = $header.Replace(
    'import { usePathname } from "next/navigation";' + "`n",
    ""
)

$header = $header.Replace(
    'import { TopSearchBar, useSearchBarHidden } from "./TopSearchBar";' + "`n",
    ""
)

$header = $header.Replace(
    "  const searchHidden = useSearchBarHidden();`n",
    ""
)

$header = $header.Replace(
    "  const pathname = usePathname();`n",
    ""
)

$header = $header.Replace(
    '  const isCheckoutRoute = pathname?.startsWith("/checkout") ?? false;' + "`n",
    ""
)

$header = $header.Replace(
    '      <TopSearchBar hidden={searchHidden || isCheckoutRoute} />' + "`n`n",
    ""
)

if ($header -eq $before) {
    Write-Warning "SiteHeader.tsx: no changes were applied - anchors may not have matched. Check file manually."
} else {
    Write-Utf8NoBom -Path $headerPath -Content $header
    Write-Host "Updated: SiteHeader.tsx" -ForegroundColor Green
}

# =========================================================================
# 2. TopSearchBar.tsx -- make it usable standalone (hidden optional, restyle)
# =========================================================================
$tsb = Get-Content -Raw -LiteralPath $topSearchBarPath
$tsbBefore = $tsb

$tsb = $tsb.Replace(
    'export function TopSearchBar({ hidden }: { hidden: boolean }) {',
    'export function TopSearchBar({ hidden = false }: { hidden?: boolean }) {'
)

$tsb = $tsb.Replace(
    '        "overflow-hidden border-t border-black/10 transition-all duration-300 ease-in-out",',
    '        "overflow-hidden rounded-full border border-line-strong shadow-lg transition-all duration-300 ease-in-out",'
)

if ($tsb -eq $tsbBefore) {
    Write-Warning "TopSearchBar.tsx: no changes were applied - anchors may not have matched. Check file manually."
} else {
    Write-Utf8NoBom -Path $topSearchBarPath -Content $tsb
    Write-Host "Updated: TopSearchBar.tsx" -ForegroundColor Green
}

# =========================================================================
# 3. (marketing)/page.tsx -- import + render TopSearchBar in the hero
# =========================================================================
$page = Get-Content -Raw -LiteralPath $landingPagePath
$pageBefore = $page

# add import right after the CATEGORIES import
$page = $page.Replace(
    'import { CATEGORIES } from "../../lib/categories";' + "`n",
    'import { CATEGORIES } from "../../lib/categories";' + "`n" + 'import { TopSearchBar } from "../_components/TopSearchBar";' + "`n"
)

# insert the search bar right after the CTA buttons block in the hero
$anchor = @'
                Become an instructor
                <ArrowRight size={16} className="transition-transform duration-200 ease-out group-hover:translate-x-1" />
              </button>
            </Link>
          </div>
'@

$replacement = @'
                Become an instructor
                <ArrowRight size={16} className="transition-transform duration-200 ease-out group-hover:translate-x-1" />
              </button>
            </Link>
          </div>

          <div className="relative z-10 mt-8 max-w-xl">
            <TopSearchBar />
          </div>
'@

$page = $page.Replace($anchor, $replacement)

if ($page -eq $pageBefore) {
    Write-Warning "(marketing)/page.tsx: no changes were applied - anchors may not have matched. Check file manually."
} else {
    Write-Utf8NoBom -Path $landingPagePath -Content $page
    Write-Host "Updated: (marketing)/page.tsx" -ForegroundColor Green
}

Write-Host "`nDone. Run 'pnpm dev' (or your usual dev command) inside apps/web and check the homepage hero." -ForegroundColor Cyan