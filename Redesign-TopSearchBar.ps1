# Redesign-TopSearchBar.ps1
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
$searchBarPath = Join-Path -Path $webApp -ChildPath "app\_components\TopSearchBar.tsx"
$pagePath = Join-Path -Path $webApp -ChildPath "app\(marketing)\page.tsx"

if (-not (Test-Path $searchBarPath)) {
    Write-Host "ERROR: $searchBarPath not found. Run the earlier TopSearchBar script first." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------
# 1. Rewrite TopSearchBar.tsx:
#    - brand gradient background (violet/magenta/pink) instead of
#      flat black -> looks correct in BOTH light and dark mode since
#      the gradient vars are theme-independent
#    - sticky below the nav row, hides on scroll-down, reveals on
#      scroll-up
#    - chevron dropdown icon next to the search input
#    - narrower input width
#    - ButtonColorful-style submit button (matches gallery cards)
#    - live dropdown with course results grouped/filterable by
#      department (category)
# ------------------------------------------------------------------
$searchBarContent = @'
"use client";

import { useEffect, useMemo, useRef, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import {
  Search,
  ChevronDown,
  GraduationCap,
  Award,
  Newspaper,
  BookOpen,
  Users,
  ArrowUpRight
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useCourseList } from "@saachi/api-client";
import { CATEGORIES } from "../../lib/categories";

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

function useHideOnScroll() {
  const [hidden, setHidden] = useState(false);
  const lastY = useRef(0);

  useEffect(() => {
    lastY.current = window.scrollY;
    function onScroll() {
      const y = window.scrollY;
      const goingDown = y > lastY.current;
      const pastThreshold = y > 80;
      setHidden(goingDown && pastThreshold);
      lastY.current = y;
    }
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return hidden;
}

export function TopSearchBar() {
  const router = useRouter();
  const hidden = useHideOnScroll();

  const [query, setQuery] = useState("");
  const [activeFilter, setActiveFilter] = useState("all");
  const [deptOpen, setDeptOpen] = useState(false);
  const [department, setDepartment] = useState<string | undefined>(undefined);
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const wrapperRef = useRef<HTMLDivElement>(null);
  const deptRef = useRef<HTMLDivElement>(null);

  const { data } = useCourseList({
    search: query.trim() || undefined,
    category: department,
    sort: "popular"
  });

  const results = useMemo(() => (data?.items ?? []).slice(0, 6), [data]);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target as Node)) {
        setDropdownOpen(false);
      }
      if (deptRef.current && !deptRef.current.contains(e.target as Node)) {
        setDeptOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const params = new URLSearchParams();
    if (query.trim()) params.set("q", query.trim());
    if (activeFilter !== "all") params.set("type", activeFilter);
    if (department) params.set("category", department);
    router.push(`/search?${params.toString()}`);
    setDropdownOpen(false);
  }

  const departmentLabel = department
    ? CATEGORIES.find((c) => c.id === department)?.name ?? "Department"
    : "All departments";

  return (
    <div
      className={cn(
        "sticky top-16 z-30 border-b border-black/10 transition-transform duration-300 ease-out",
        hidden ? "-translate-y-full" : "translate-y-0"
      )}
      style={{ backgroundImage: "var(--color-accent-gradient)" }}
    >
      <div className="mx-auto flex max-w-7xl flex-col gap-3 px-4 py-3.5 md:px-8">
        <form onSubmit={handleSubmit} className="flex items-center gap-2.5">
          <div ref={wrapperRef} className="relative w-full max-w-md">
            <div className="flex h-11 items-center gap-2 rounded-full border border-white/25 bg-white pl-4 pr-2 shadow-sm">
              <Search size={16} className="shrink-0 text-ink-soft" />
              <input
                value={query}
                onChange={(e) => {
                  setQuery(e.target.value);
                  setDropdownOpen(true);
                }}
                onFocus={() => setDropdownOpen(true)}
                placeholder="Search courses, certificates, news..."
                className="w-full bg-transparent text-[13.5px] text-ink placeholder:text-ink-soft/60 focus:outline-none"
              />

              {/* Department filter toggle */}
              <div ref={deptRef} className="relative shrink-0">
                <button
                  type="button"
                  onClick={() => setDeptOpen((v) => !v)}
                  className="flex items-center gap-1 rounded-full bg-paper-dim px-2.5 py-1.5 text-[11px] font-semibold text-ink-soft transition-colors hover:text-ink"
                >
                  <span className="hidden max-w-[90px] truncate sm:inline">{departmentLabel}</span>
                  <ChevronDown size={13} className={cn("transition-transform duration-200", deptOpen && "rotate-180")} />
                </button>

                {deptOpen && (
                  <div className="absolute right-0 top-[calc(100%+8px)] z-40 w-56 overflow-hidden rounded-card border border-line bg-card shadow-lg">
                    <button
                      type="button"
                      onClick={() => {
                        setDepartment(undefined);
                        setDeptOpen(false);
                      }}
                      className={cn(
                        "flex w-full items-center px-4 py-2.5 text-left text-[13px] transition-colors hover:bg-paper-dim",
                        !department ? "font-semibold text-accent-violet" : "text-ink"
                      )}
                    >
                      All departments
                    </button>
                    {CATEGORIES.map((cat) => (
                      <button
                        key={cat.id}
                        type="button"
                        onClick={() => {
                          setDepartment(cat.id);
                          setDeptOpen(false);
                        }}
                        className={cn(
                          "flex w-full items-center px-4 py-2.5 text-left text-[13px] transition-colors hover:bg-paper-dim",
                          department === cat.id ? "font-semibold text-accent-violet" : "text-ink"
                        )}
                      >
                        {cat.name}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {/* Live results dropdown */}
            {dropdownOpen && query.trim().length > 0 && (
              <div className="absolute left-0 right-0 top-[calc(100%+8px)] z-40 overflow-hidden rounded-card border border-line bg-card shadow-xl">
                {results.length === 0 ? (
                  <div className="px-4 py-5 text-center text-[13px] text-ink-soft">
                    No courses found for &quot;{query}&quot;.
                  </div>
                ) : (
                  <ul className="flex max-h-80 flex-col divide-y divide-line overflow-y-auto">
                    {results.map((course) => {
                      const categoryName =
                        CATEGORIES.find((c) => course.slug.includes(c.id))?.name ?? "Course";
                      return (
                        <li key={course.id}>
                          <Link
                            href={`/courses/${course.slug}`}
                            onClick={() => setDropdownOpen(false)}
                            className="flex items-center justify-between gap-3 px-4 py-3 transition-colors hover:bg-paper-dim"
                          >
                            <div className="min-w-0">
                              <p className="truncate text-[13.5px] font-semibold text-ink">{course.title}</p>
                              <p className="text-[11.5px] text-ink-soft">
                                {categoryName} - {course.instructor.fullName}
                              </p>
                            </div>
                            <ArrowUpRight size={14} className="shrink-0 text-ink-soft" />
                          </Link>
                        </li>
                      );
                    })}
                  </ul>
                )}
                <Link
                  href={`/search?q=${encodeURIComponent(query)}${department ? `&category=${department}` : ""}`}
                  onClick={() => setDropdownOpen(false)}
                  className="flex items-center justify-center gap-2 border-t border-line bg-paper-dim px-4 py-2.5 text-[12px] font-semibold text-accent-violet hover:underline"
                >
                  See all results for &quot;{query}&quot;
                </Link>
              </div>
            )}
          </div>

          <button
            type="submit"
            className={cn(
              "group/searchbtn relative hidden h-11 shrink-0 items-center gap-1.5 overflow-hidden rounded-full bg-zinc-900 px-5 sm:flex"
            )}
          >
            <span className="absolute inset-0 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 opacity-50 blur transition-opacity duration-500 group-hover/searchbtn:opacity-90" />
            <span className="relative flex items-center gap-1.5 text-[13px] font-semibold text-white">
              <Search size={14} />
              Search
            </span>
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
                    ? "border-white bg-white text-ink shadow-sm"
                    : "border-white/40 bg-white/10 text-white/90 hover:border-white/70 hover:bg-white/20"
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
Write-Host "Updated: $searchBarPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 2. Remove the OLD inline hero search (LandingSearch) that sits below
#    the "Browse courses" / "Become an instructor" buttons - now
#    redundant since TopSearchBar covers this.
# ------------------------------------------------------------------
if (-not (Test-Path $pagePath)) {
    Write-Host "ERROR: $pagePath not found." -ForegroundColor Red
    exit 1
}

$pageContent = [System.IO.File]::ReadAllText($pagePath)

$oldLandingSearchBlock = @'
          <div className="mt-10">
            <LandingSearch />
          </div>
'@

if ($pageContent.Contains($oldLandingSearchBlock)) {
    $pageContent = $pageContent.Replace($oldLandingSearchBlock, "")
    Write-Host "Removed old LandingSearch block from Hero." -ForegroundColor Green
} else {
    Write-Host "Old LandingSearch usage block not found (may already be removed)." -ForegroundColor Yellow
}

# Remove now-unused import if no other usage remains
if ($pageContent -notmatch [regex]::Escape('<LandingSearch')) {
    $oldImport = 'import { LandingSearch } from "./_components/LandingSearch";'
    if ($pageContent.Contains($oldImport)) {
        $pageContent = $pageContent.Replace("`r`n" + $oldImport, "")
        $pageContent = $pageContent.Replace($oldImport + "`r`n", "")
        $pageContent = $pageContent.Replace($oldImport, "")
        Write-Host "Removed unused LandingSearch import." -ForegroundColor Green
    }
}

Write-Utf8NoBom -Path $pagePath -Content $pageContent
Write-Host "Updated: $pagePath" -ForegroundColor Green

Write-Host "`nDone. cd apps\web ; pnpm run build (or pnpm dev) to verify." -ForegroundColor Cyan