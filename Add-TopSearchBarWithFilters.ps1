# Add-TopSearchBarWithFilters.ps1
# Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $dir = Split-Path -Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$root = (Get-Location).Path
$webApp = Join-Path -Path $root -ChildPath "apps\web"
$siteHeaderPath = Join-Path -Path $webApp -ChildPath "app\_components\SiteHeader.tsx"
$searchBarPath = Join-Path -Path $webApp -ChildPath "app\_components\TopSearchBar.tsx"

if (-not (Test-Path $siteHeaderPath)) {
    Write-Host "ERROR: $siteHeaderPath not found. Run from SAI2 repo root." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# 1. New component: TopSearchBar.tsx - solid, high-contrast search
#    row with filter chips (All, Courses, Certificates, News, Blog,
#    Community). Submits to /search with query + type params.
# ------------------------------------------------------------------
$searchBarContent = @'
"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Search, GraduationCap, Award, Newspaper, BookOpen, Users } from "lucide-react";
import { cn } from "@/lib/utils";

type FilterOption = {
  value: string;
  label: string;
  icon: typeof Search;
};

const FILTERS: FilterOption[] = [
  { value: "all", label: "All", icon: Search },
  { value: "courses", label: "Courses", icon: GraduationCap },
  { value: "certificates", label: "Certificates", icon: Award },
  { value: "news", label: "News", icon: Newspaper },
  { value: "blog", label: "Blog", icon: BookOpen },
  { value: "community", label: "Community", icon: Users }
];

export function TopSearchBar() {
  const router = useRouter();
  const [query, setQuery] = useState("");
  const [activeFilter, setActiveFilter] = useState("all");

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const params = new URLSearchParams();
    if (query.trim()) params.set("q", query.trim());
    if (activeFilter !== "all") params.set("type", activeFilter);
    router.push(`/search?${params.toString()}`);
  }

  return (
    <div className="border-b border-line bg-ink">
      <div className="mx-auto flex max-w-7xl flex-col gap-3 px-4 py-3.5 md:px-8">
        <form onSubmit={handleSubmit} className="flex items-center gap-2.5">
          <div className="flex h-11 flex-1 items-center gap-2.5 rounded-full border border-white/15 bg-white px-4 shadow-sm">
            <Search size={17} className="shrink-0 text-ink-soft" />
            <input
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search courses, certificates, news, blog, or community..."
              className="w-full bg-transparent text-[14px] text-ink placeholder:text-ink-soft/60 focus:outline-none"
            />
          </div>
          <button
            type="submit"
            className="hidden h-11 shrink-0 items-center gap-1.5 rounded-full bg-gradient-brand px-5 text-[13.5px] font-semibold text-white transition-transform duration-150 hover:scale-[1.03] sm:flex"
          >
            <Search size={15} />
            Search
          </button>
        </form>

        <div className="flex flex-wrap items-center gap-2">
          {FILTERS.map((filter) => {
            const Icon = filter.icon;
            const active = activeFilter === filter.value;
            return (
              <button
                key={filter.value}
                type="button"
                onClick={() => setActiveFilter(filter.value)}
                className={cn(
                  "flex items-center gap-1.5 rounded-full border px-3.5 py-1.5 text-[12.5px] font-semibold transition-all duration-150",
                  active
                    ? "border-transparent bg-gradient-brand text-white shadow-sm"
                    : "border-white/15 bg-white/5 text-white/75 hover:border-white/30 hover:bg-white/10 hover:text-white"
                )}
              >
                <Icon size={13} />
                {filter.label}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default TopSearchBar;
'@

Write-Utf8NoBom -Path $searchBarPath -Content $searchBarContent
Write-Host "Created: $searchBarPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 2. Wire TopSearchBar into SiteHeader.tsx, directly below the nav row
#    (inside the sticky header, so it scrolls away with the header,
#    but always sits right underneath the top navigation).
# ------------------------------------------------------------------
$siteHeaderContent = [System.IO.File]::ReadAllText($siteHeaderPath)

# --- add import ---
$importAnchor = 'import { CATEGORIES } from "../../lib/categories";'
if ($siteHeaderContent -notmatch [regex]::Escape('TopSearchBar')) {
    if ($siteHeaderContent.Contains($importAnchor)) {
        $newImportBlock = $importAnchor + "`r`nimport { TopSearchBar } from `"./TopSearchBar`";"
        $siteHeaderContent = $siteHeaderContent.Replace($importAnchor, $newImportBlock)
        Write-Host "Added TopSearchBar import to SiteHeader.tsx" -ForegroundColor Green
    } else {
        Write-Host "ERROR: import anchor not found in SiteHeader.tsx - check file manually." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "TopSearchBar import already present, skipping." -ForegroundColor Yellow
}

# --- insert <TopSearchBar /> right after the closing </div> of the h-16 nav row,
#     before the mobile menu block, so it always renders under the nav ---
$navCloseAnchor = @'
      </div>

      {mobileOpen && (
'@

$newNavCloseBlock = @'
      </div>

      <TopSearchBar />

      {mobileOpen && (
'@

if ($siteHeaderContent -notmatch [regex]::Escape('<TopSearchBar')) {
    if ($siteHeaderContent.Contains($navCloseAnchor)) {
        $siteHeaderContent = $siteHeaderContent.Replace($navCloseAnchor, $newNavCloseBlock)
        Write-Host "Inserted <TopSearchBar /> below the top navigation." -ForegroundColor Green
    } else {
        Write-Host "ERROR: nav-row closing anchor not found - check SiteHeader.tsx structure manually." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "<TopSearchBar /> already present, skipping." -ForegroundColor Yellow
}

Write-Utf8NoBom -Path $siteHeaderPath -Content $siteHeaderContent
Write-Host "Updated: $siteHeaderPath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan