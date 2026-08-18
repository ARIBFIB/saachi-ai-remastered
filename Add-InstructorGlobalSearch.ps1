<#
.SYNOPSIS
    Adds Instructor Global Search to the InstructorShell top bar.
    Searches the instructor's own courses, students, and reviews (dummy data)
    and lets them click a result to navigate to the relevant page.

.USAGE
    Run from the SAI2 repo root:
    PS D:\...\SAI2> .\Add-InstructorGlobalSearch.ps1
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot

function Write-Section($msg) {
    Write-Host ""
    Write-Host "== $msg ==" -ForegroundColor Cyan
}

function Write-FileSafe($path, $content) {
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Set-Content -Path $path -Value $content -NoNewline -Encoding UTF8
    Write-Host "  [OK] Wrote $path" -ForegroundColor Green
}

# ===========================================================================
# 1. InstructorSearchBar component
# ===========================================================================
Write-Section "Instructor Search Bar component"

$searchBarPath = Join-Path $root "apps\web\components\ui\instructor-search-bar.tsx"

$searchBarContent = @'
"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Search, BookOpen, Users, Star, ArrowUpRight } from "lucide-react";
import { useInstructorCourseStore } from "@saachi/store";
import { cn } from "@/lib/utils";

type ResultItem = {
  id: string;
  title: string;
  sub?: string;
  href: string;
};

type ResultGroup = {
  key: string;
  label: string;
  icon: React.ReactNode;
  items: ResultItem[];
};

// NOTE: demo-only dummy data for students/reviews. Courses come from the
// real instructor course store. Replace students/reviews with
// useInstructorStudents() / useInstructorReviews() once confirmed.
const DUMMY_STUDENTS = [
  { id: "stu_1", name: "Hina Malik", courseTitle: "Automate Everything with n8n & AI" },
  { id: "stu_2", name: "Omar Sheikh", courseTitle: "Automate Everything with n8n & AI" },
  { id: "stu_3", name: "Sara Iqbal", courseTitle: "AI Chatbots for WhatsApp Support" },
  { id: "stu_4", name: "Noor Fatima", courseTitle: "Automate Everything with n8n & AI" },
  { id: "stu_5", name: "Ali Raza", courseTitle: "AI Chatbots for WhatsApp Support" },
  { id: "stu_6", name: "Danish Iqbal", courseTitle: "Prompt Engineering for Client Work" }
];

const DUMMY_REVIEWS = [
  { id: "rev_i1", author: "Bilal S.", courseTitle: "Automate Everything with n8n & AI", comment: "Very practical, loved it." },
  { id: "rev_i2", author: "Fatima R.", courseTitle: "AI Chatbots for WhatsApp Support", comment: "Good pacing, clear examples." },
  { id: "rev_i3", author: "Omar Sheikh", courseTitle: "Automate Everything with n8n & AI", comment: "Best automation course I've taken." }
];

export function InstructorSearchBar() {
  const router = useRouter();
  const courses = useInstructorCourseStore((s) => s.courses);

  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const wrapperRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const groups: ResultGroup[] = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return [];

    const courseResults: ResultItem[] = courses
      .filter((c) => c.title.toLowerCase().includes(q))
      .slice(0, 5)
      .map((c) => ({
        id: c.id,
        title: c.title,
        sub: c.status === "published" ? "Published" : c.status === "pending_review" ? "Pending review" : "Draft",
        href: `/instructor/courses/${c.id}/edit`
      }));

    const studentResults: ResultItem[] = DUMMY_STUDENTS
      .filter((s) => s.name.toLowerCase().includes(q) || s.courseTitle.toLowerCase().includes(q))
      .slice(0, 5)
      .map((s) => ({
        id: s.id,
        title: s.name,
        sub: s.courseTitle,
        href: "/instructor/students"
      }));

    const reviewResults: ResultItem[] = DUMMY_REVIEWS
      .filter(
        (r) =>
          r.author.toLowerCase().includes(q) ||
          r.courseTitle.toLowerCase().includes(q) ||
          r.comment.toLowerCase().includes(q)
      )
      .slice(0, 5)
      .map((r) => ({
        id: r.id,
        title: `${r.author} - ${r.courseTitle}`,
        sub: r.comment,
        href: "/instructor/reviews"
      }));

    const out: ResultGroup[] = [];
    if (courseResults.length > 0) out.push({ key: "courses", label: "Courses", icon: <BookOpen size={12} />, items: courseResults });
    if (studentResults.length > 0) out.push({ key: "students", label: "Students", icon: <Users size={12} />, items: studentResults });
    if (reviewResults.length > 0) out.push({ key: "reviews", label: "Reviews", icon: <Star size={12} />, items: reviewResults });
    return out;
  }, [courses, query]);

  const totalResults = groups.reduce((sum, g) => sum + g.items.length, 0);
  const showDropdown = open && query.trim().length > 0;

  function handleSelect(href: string) {
    setOpen(false);
    setQuery("");
    router.push(href);
  }

  return (
    <div ref={wrapperRef} className="relative hidden md:block">
      <div className="flex h-9 w-64 items-center gap-2 rounded-control border border-line bg-paper-dim px-3">
        <Search size={14} className="shrink-0 text-ink-soft" />
        <input
          value={query}
          onChange={(e) => {
            setQuery(e.target.value);
            setOpen(true);
          }}
          onFocus={() => setOpen(true)}
          placeholder="Search your courses, students..."
          className="w-full bg-transparent text-[12.5px] text-ink placeholder:text-ink-soft/60 outline-none"
        />
      </div>

      {showDropdown && (
        <div className="absolute right-0 top-[calc(100%+8px)] z-50 w-[340px] overflow-hidden rounded-card border border-line bg-card shadow-xl">
          {totalResults === 0 ? (
            <div className="px-4 py-8 text-center text-[12.5px] text-ink-soft">
              No results for &quot;{query}&quot;
            </div>
          ) : (
            <div className="max-h-[380px] overflow-y-auto p-1.5">
              {groups.map((group) => (
                <div key={group.key} className="mb-1 last:mb-0">
                  <div className="flex items-center gap-1.5 px-2.5 pb-1 pt-2 text-[10.5px] font-semibold uppercase tracking-[0.06em] text-ink-soft/60">
                    {group.icon}
                    {group.label}
                  </div>
                  {group.items.map((item) => (
                    <button
                      key={item.id}
                      type="button"
                      onClick={() => handleSelect(item.href)}
                      className="flex w-full items-center justify-between gap-3 rounded-control px-2.5 py-2 text-left transition-colors duration-100 ease-out hover:bg-paper-dim"
                    >
                      <div className="min-w-0">
                        <p className="truncate text-[12.5px] font-medium text-ink">{item.title}</p>
                        {item.sub && <p className="truncate text-[11px] text-ink-soft">{item.sub}</p>}
                      </div>
                      <ArrowUpRight size={12} className="shrink-0 text-ink-soft/50" />
                    </button>
                  ))}
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  );
}

export default InstructorSearchBar;
'@

Write-FileSafe -path $searchBarPath -content $searchBarContent

# ===========================================================================
# 2. Wire into InstructorShell top bar
# ===========================================================================
Write-Section "Wiring search bar into InstructorShell"

$shellPath = Join-Path $root "apps\web\app\(instructor)\_components\InstructorShell.tsx"

if (Test-Path $shellPath) {
    $shellContent = Get-Content -Path $shellPath -Raw

    # --- add import ---
    $importAnchor = 'import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";'
    $newImportBlock = @'
import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";
import { InstructorSearchBar } from "@/components/ui/instructor-search-bar";
'@

    if ($shellContent.Contains($importAnchor) -and -not $shellContent.Contains("InstructorSearchBar")) {
        $shellContent = $shellContent.Replace($importAnchor, $newImportBlock)
        Write-Host "  [OK] Added InstructorSearchBar import." -ForegroundColor Green
    } elseif ($shellContent.Contains("InstructorSearchBar")) {
        Write-Host "  [SKIP] InstructorSearchBar already imported." -ForegroundColor Yellow
    } else {
        Write-Host "  [WARN] Could not find import anchor line. Add manually:" -ForegroundColor Yellow
        Write-Host '         import { InstructorSearchBar } from "@/components/ui/instructor-search-bar";' -ForegroundColor Yellow
    }

    # --- insert component into top bar JSX, right before the notification bell block ---
    $jsxAnchor = '<div className="flex items-center gap-2 sm:gap-3">'
    $newJsxBlock = @'
<div className="flex items-center gap-2 sm:gap-3">
          <InstructorSearchBar />
'@

    if ($shellContent.Contains($jsxAnchor) -and -not $shellContent.Contains("<InstructorSearchBar")) {
        # Replace only the first occurrence (top bar right-icons wrapper)
        $idx = $shellContent.IndexOf($jsxAnchor)
        if ($idx -ge 0) {
            $shellContent = $shellContent.Substring(0, $idx) + $newJsxBlock + $shellContent.Substring($idx + $jsxAnchor.Length)
            Write-Host "  [OK] Inserted <InstructorSearchBar /> into top bar JSX." -ForegroundColor Green
        }
    } elseif ($shellContent.Contains("<InstructorSearchBar")) {
        Write-Host "  [SKIP] Top bar JSX already renders InstructorSearchBar." -ForegroundColor Yellow
    } else {
        Write-Host "  [WARN] Could not find expected JSX anchor in InstructorShell.tsx." -ForegroundColor Yellow
        Write-Host "         Manually add <InstructorSearchBar /> as the first child inside the" -ForegroundColor Yellow
        Write-Host '         <div className="flex items-center gap-2 sm:gap-3"> wrapper in the top bar.' -ForegroundColor Yellow
    }

    Set-Content -Path $shellPath -Value $shellContent -NoNewline -Encoding UTF8
} else {
    Write-Host "  [WARN] Could not find InstructorShell.tsx at: $shellPath" -ForegroundColor Yellow
    Write-Host "         Add <InstructorSearchBar /> to the top bar manually." -ForegroundColor Yellow
}

# ===========================================================================
# DONE
# ===========================================================================
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Instructor Global Search added." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Next steps:"
Write-Host "  1. git status / git diff  -> review changes"
Write-Host "  2. pnpm turbo run build   -> verify it compiles"
Write-Host "  3. Commit and push"
Write-Host ""
Write-Host "Note: search bar is hidden below 'md' breakpoint (matches the" -ForegroundColor Yellow
Write-Host "      existing top-bar responsive pattern). Mobile users still" -ForegroundColor Yellow
Write-Host "      have full sidebar navigation." -ForegroundColor Yellow