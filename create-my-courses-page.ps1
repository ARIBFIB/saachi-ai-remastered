<#
================================================================================
 create-my-courses-page.ps1
 Creates the "My Courses" learner dashboard page for apps/web -- rebuilt
 from a broken Figma export (the original had nonsense fixed widths like
 w-7/w-6/w-12 on cards, causing the squished/cut-off layout you saw).
 This version uses a proper responsive grid instead, fully token-driven
 and built with Ant Design components (zero hardcoded hex colors).

 WHAT THIS SCRIPT DOES:
   1. Adds one new token to lib/design-system/tokens.ts (idempotent):
        - color.completedBadgeBg  soft emerald badge background used on
          "Completed" course cards (distinct from the existing "success"
          token, which is used for star ratings elsewhere)
   2. Creates apps/web/app/(learner)/dashboard/my-courses/page.tsx using:
        - Ant Design: Progress, Button, Tag, Typography
        - A real CSS grid for the course cards (fixes the broken fixed-
          width layout from the source export)
        - lucide-react icons (LayoutGrid, GraduationCap, Heart, Settings,
          HelpCircle, Clock, CheckCircle2)
      Demo course data is inline, clearly marked with a TODO comment for
      wiring to @saachi/api-client (useCourses / a future
      useLearnerCourses hook).

 USAGE:
   Place this script at the SAI2 monorepo root (same level as apps/,
   packages/) and run:
     powershell -ExecutionPolicy Bypass -File .\create-my-courses-page.ps1

 SAFE TO RE-RUN.
================================================================================
#>

$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$webRoot    = Join-Path $PSScriptRoot "apps\web"
$tokensPath = Join-Path $webRoot "lib\design-system\tokens.ts"
$pageDir    = Join-Path $webRoot "app\(learner)\dashboard\my-courses"
$pagePath   = Join-Path $pageDir "page.tsx"

if (-not (Test-Path -LiteralPath $tokensPath)) {
    Write-Host "ERROR: Could not find $tokensPath. Place this script at the SAI2 monorepo root." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------------------
# STEP 1: Add new token to tokens.ts (idempotent)
# ------------------------------------------------------------------------
$tokensContent = [System.IO.File]::ReadAllText($tokensPath, [System.Text.Encoding]::UTF8)

if ($tokensContent -notmatch "completedBadgeBg") {
    $anchor = '    successTint: "#D1FAE5",'
    if ($tokensContent.Contains($anchor)) {
        $insertion = $anchor + "`r`n" +
            '    completedBadgeBg: "#D1FAE5", // emerald-100 (Completed pill on course cards)'
        $tokensContent = $tokensContent.Replace($anchor, $insertion)
        [System.IO.File]::WriteAllText($tokensPath, $tokensContent, $utf8NoBom)
        Write-Host "Added completedBadgeBg token to tokens.ts" -ForegroundColor Green
        Write-Host "Remember to run 'pnpm --filter web run tokens:sync' (or 'pnpm dev') so globals.css picks up the new CSS var." -ForegroundColor Yellow
    } else {
        Write-Host "WARNING: Could not find the expected anchor line in tokens.ts. Add this manually to the color block:" -ForegroundColor Yellow
        Write-Host '  completedBadgeBg: "#D1FAE5",' -ForegroundColor Yellow
    }
} else {
    Write-Host "tokens.ts already has completedBadgeBg -- skipping token insertion." -ForegroundColor Cyan
}

# ------------------------------------------------------------------------
# STEP 2: Create the My Courses page
# ------------------------------------------------------------------------
if (-not (Test-Path -LiteralPath $pageDir)) {
    New-Item -ItemType Directory -Path $pageDir -Force | Out-Null
}

$pageContent = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Progress, Button, Typography } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  Clock,
  CheckCircle2,
} from "lucide-react";

const { Title, Text } = Typography;

// TODO: replace with useCourses() / a future useLearnerCourses() hook from @saachi/api-client
interface EnrolledCourse {
  id: string;
  title: string;
  category: string;
  image: string;
  status: "in-progress" | "completed";
  progress?: number;
  timeLeft?: string;
}

const courses: EnrolledCourse[] = [
  {
    id: "c1",
    title: "Advanced Machine Learning Algorithms",
    category: "Machine Learning",
    image: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
    status: "in-progress",
    progress: 62,
    timeLeft: "12h left",
  },
  {
    id: "c2",
    title: "Data Engineering Pipeline Mastery",
    category: "Data Engineering",
    image: "https://images.unsplash.com/photo-1518186285589-2f7649de83e0?auto=format&fit=crop&w=600&q=80",
    status: "in-progress",
    progress: 34,
    timeLeft: "20h left",
  },
  {
    id: "c3",
    title: "Python for Data Science Basics",
    category: "Data Science",
    image: "https://images.unsplash.com/photo-1526379879527-8559ecfcaec0?auto=format&fit=crop&w=600&q=80",
    status: "completed",
  },
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

const filters = [
  { key: "all", label: "All Courses", count: courses.length },
  { key: "in-progress", label: "In Progress", count: courses.filter((c) => c.status === "in-progress").length },
  { key: "completed", label: "Completed", count: courses.filter((c) => c.status === "completed").length },
] as const;

export default function MyCoursesPage() {
  const [activeFilter, setActiveFilter] = useState<(typeof filters)[number]["key"]>("all");

  const visibleCourses =
    activeFilter === "all" ? courses : courses.filter((c) => c.status === activeFilter);

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex items-center gap-4 border-b border-[var(--token-color-border)] p-6">
          <span className="relative block h-10 w-10 shrink-0 overflow-hidden rounded-full">
            <Image
              src="https://i.pravatar.cc/80?img=47"
              alt="Learner avatar"
              fill
              sizes="40px"
              className="object-cover"
            />
          </span>
          <div className="flex flex-col">
            <span
              className="font-bold tracking-wide"
              style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-sm)" }}
            >
              Learner Portal
            </span>
            <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
              Manage your skills
            </span>
          </div>
        </div>

        <nav className="flex flex-1 flex-col gap-2 py-6">
          {navItems.map(({ icon: Icon, label, href }) => {
            const isActive = label === "My Courses";
            return (
              <Link
                key={label}
                href={href}
                className="flex h-12 items-center gap-4 border-l-4 pl-4 pr-6 text-sm font-semibold tracking-wide transition"
                style={{
                  borderColor: isActive ? "var(--token-color-primary)" : "transparent",
                  backgroundColor: isActive ? "var(--token-color-primaryTint)" : "transparent",
                  color: isActive ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                }}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-[var(--token-color-border)] p-6">
          <Link
            href="/support"
            className="flex items-center gap-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main column */}
      <div className="flex w-full flex-col lg:pl-72">
        <main className="flex-1 px-6 pb-14 pt-10">
          <div className="mx-auto flex max-w-[1000px] flex-col gap-6">
            {/* Header */}
            <div className="flex flex-col gap-1.5">
              <Title level={1} style={{ margin: 0, color: "var(--token-color-ink)" }}>
                My Courses
              </Title>
              <Text style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-lg)" }}>
                Track your progress and pick up where you left off.
              </Text>
            </div>

            {/* Filters */}
            <div className="flex gap-2 border-b border-[var(--token-color-border)] pt-4">
              {filters.map((filter) => {
                const isActive = filter.key === activeFilter;
                return (
                  <button
                    key={filter.key}
                    type="button"
                    onClick={() => setActiveFilter(filter.key)}
                    className="border-b-2 px-5 py-2 text-sm font-semibold tracking-wide transition"
                    style={{
                      borderColor: isActive ? "var(--token-color-primary)" : "transparent",
                      color: isActive ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                      fontWeight: isActive ? 700 : 600,
                    }}
                  >
                    {filter.label} ({filter.count})
                  </button>
                );
              })}
            </div>

            {/* Course grid */}
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
              {visibleCourses.map((course) => (
                <CourseCard key={course.id} course={course} />
              ))}
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-[var(--token-color-surfaceAlt)]/60 px-6 py-10">
          <div className="mx-auto flex max-w-[1000px] flex-col gap-6 sm:flex-row sm:items-start sm:justify-between">
            <div className="flex flex-col gap-4">
              <span className="text-base font-bold text-[var(--token-color-primary)]">Saachi AI</span>
              <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                &copy; {new Date().getFullYear()} Saachi AI Marketplace.
                <br />
                Empowering the future of skills.
              </p>
            </div>

            <nav className="flex flex-wrap gap-6">
              <Link href="/about" className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
                About Us
              </Link>
              <Link href="/careers" className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
                Careers
              </Link>
              <Link href="/legal/privacy" className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
                Privacy Policy
              </Link>
              <Link href="/legal/terms" className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
                Terms of Service
              </Link>
              <Link href="/instructor/handbook" className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
                Instructor Handbook
              </Link>
            </nav>
          </div>
        </footer>
      </div>
    </div>
  );
}

function CourseCard({ course }: { course: EnrolledCourse }) {
  const isCompleted = course.status === "completed";

  return (
    <article className="flex flex-col overflow-hidden rounded-2xl border bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]"
      style={{ borderColor: "var(--token-color-border)" }}
    >
      <div className="relative h-40 w-full shrink-0 bg-[var(--token-color-surfaceAlt)]">
        <Image
          src={course.image}
          alt={course.title}
          fill
          sizes="(max-width: 768px) 100vw, 33vw"
          className="object-cover"
          style={{ opacity: isCompleted ? 0.7 : 1 }}
        />

        {course.status === "in-progress" && course.timeLeft && (
          <span className="absolute left-3 top-3 rounded-sm bg-[var(--token-color-surface)]/90 px-2 pb-1 pt-[3px] text-xs font-medium text-[var(--token-color-ink)] backdrop-blur-[2px]">
            {course.timeLeft}
          </span>
        )}

        {isCompleted && (
          <span className="absolute right-3 top-3 flex h-9 w-9 items-center justify-center rounded-full bg-[var(--token-color-surface)] shadow-[var(--token-shadow-sm)]">
            <CheckCircle2 size={18} color="var(--token-color-success)" />
          </span>
        )}
      </div>

      <div className="flex flex-1 flex-col gap-4 p-6">
        <span
          className="w-fit rounded-sm px-2 pb-1 pt-[3px] text-xs font-medium"
          style={{
            backgroundColor: isCompleted ? "var(--token-color-completedBadgeBg)" : "var(--token-color-primaryTint)",
            color: isCompleted ? "var(--token-color-success)" : "var(--token-color-primary)",
          }}
        >
          {course.category}
        </span>

        <h3
          className="line-clamp-2 text-lg font-semibold leading-6"
          style={{ color: "var(--token-color-ink)" }}
        >
          {course.title}
        </h3>

        <div className="mt-auto flex flex-col gap-3">
          {course.status === "in-progress" && course.progress !== undefined && (
            <div className="flex flex-col gap-1">
              <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
                Progress
              </span>
              <Progress percent={course.progress} showInfo strokeColor="var(--token-color-primary)" />
            </div>
          )}

          <Button type={isCompleted ? "default" : "primary"} block size="large">
            {isCompleted ? "Review Certificate" : "Resume Learning"}
          </Button>
        </div>
      </div>
    </article>
  );
}
'@

[System.IO.File]::WriteAllText($pagePath, $pageContent, $utf8NoBom)
Write-Host "Created $pagePath" -ForegroundColor Green

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host "Done." -ForegroundColor Cyan
Write-Host "Page:   apps/web/app/(learner)/dashboard/my-courses/page.tsx" -ForegroundColor Cyan
Write-Host "Route:  /dashboard/my-courses" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE 1: What was actually broken in the source export -- the Figma output" -ForegroundColor Yellow
Write-Host "gave course cards fixed pixel widths like w-7/w-6/w-12 (a handful of" -ForegroundColor Yellow
Write-Host "pixels), which squished every card into a sliver and clipped the text." -ForegroundColor Yellow
Write-Host "This version uses a real responsive CSS grid instead." -ForegroundColor Yellow
Write-Host ""
Write-Host "NOTE 2: Route is under /dashboard, which middleware.ts already protects" -ForegroundColor Yellow
Write-Host "(requires the 'saachi_session' cookie). No middleware changes needed." -ForegroundColor Yellow
Write-Host ""
Write-Host "NOTE 3: Confirm AntdProvider wraps children in apps/web/app/layout.tsx so" -ForegroundColor Yellow
Write-Host "Progress/Button pick up antdTheme derived from tokens.ts automatically." -ForegroundColor Yellow
Write-Host "================================================================================" -ForegroundColor Cyan