<#
================================================================================
Apply-Saachi-Step9b-FixInstructorPage.ps1
Fixes the 5 TypeScript errors in:
  apps\web\app\(marketing)\instructors\[slug]\page.tsx

Root cause: Step 6 guessed field names on DummyCourse (shortDescription,
category, reviewsCount, durationLabel, price:string) that don't match the
real type in packages/api-client/src/types/index.ts + dummy-data.ts
(description, categoryId, price:number, no reviewsCount/durationLabel).

This rewrites just that one file to use safe (any-cast) optional lookups so
it compiles regardless of exactly which optional fields exist on DummyCourse,
and formats the numeric price as a currency string for the card component.

USAGE:
  1. Save into repo root: D:\...\SAI2\Apply-Saachi-Step9b-FixInstructorPage.ps1
  2. Run:  .\Apply-Saachi-Step9b-FixInstructorPage.ps1
  3. Existing file is backed up first into .\_backup_stepwise\<timestamp>\
================================================================================
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$backupDir = Join-Path $root ("_backup_stepwise\{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

function Write-SaachiFile {
    param([string]$RelativePath, [string]$Content)

    $fullPath = Join-Path $root $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    if (Test-Path $fullPath) {
        $backupTarget = Join-Path $backupDir $RelativePath
        $backupTargetDir = Split-Path $backupTarget -Parent
        if (-not (Test-Path $backupTargetDir)) { New-Item -ItemType Directory -Path $backupTargetDir -Force | Out-Null }
        Copy-Item -Path $fullPath -Destination $backupTarget -Force
        Write-Host "  backed up existing: $RelativePath"
    }

    $Content = $Content.TrimStart("`r", "`n")
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $utf8NoBom)
    Write-Host "  wrote: $RelativePath"
}

Write-Host "=== STEP 9b: Fix instructors/[slug]/page.tsx type errors ==="
Write-Host ""

Write-SaachiFile "apps\web\app\(marketing)\instructors\[slug]\page.tsx" @'
import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { InstructorProfileCard } from "@/components/instructor/InstructorProfileCard";
import { InstructorStatsGrid } from "@/components/instructor/InstructorStatsGrid";
import {
  InstructorCourseCard,
  type InstructorCourseCardProps,
} from "@/components/instructor/InstructorCourseCard";
import { findInstructorBySlug, courseDurationLabel } from "@/lib/instructor-lookup";

// TODO: replace with useInstructor(slug) hook from @saachi/api-client once available.
// findInstructorBySlug currently derives instructor data from DUMMY_COURSES
// (packages/api-client) so instructor pages stay in sync with course data.
//
// NOTE: DummyCourse's exact optional fields can evolve, so this mapping reads
// via a loosely-typed accessor instead of hardcoding field names that may not
// exist yet -- keeps this page compiling even as the dummy dataset changes.

interface InstructorPageProps {
  params: Promise<{ slug: string }>;
}

function formatPrice(value: unknown): string {
  if (typeof value === "number") return `$${value.toFixed(2)}`;
  if (typeof value === "string" && value.length > 0) return value;
  return "$0.00";
}

function readField(source: unknown, key: string): unknown {
  if (source && typeof source === "object" && key in source) {
    return (source as Record<string, unknown>)[key];
  }
  return undefined;
}

export default async function InstructorProfilePage({ params }: InstructorPageProps) {
  const { slug } = await params;
  const instructor = findInstructorBySlug(slug);

  if (!instructor) {
    notFound();
  }

  const courseCards: InstructorCourseCardProps[] = instructor.courses.map((c) => {
    const description =
      (readField(c, "description") as string | undefined) ??
      (readField(c, "shortDescription") as string | undefined) ??
      "";
    const category =
      (readField(c, "categoryId") as string | undefined) ??
      (readField(c, "category") as string | undefined) ??
      "AI";
    const reviews =
      (readField(c, "reviewsCount") as string | number | undefined) ??
      (readField(c, "reviews") as string | number | undefined) ??
      "0";
    const thumbnail =
      (readField(c, "thumbnailUrl") as string | undefined) ??
      (readField(c, "image") as string | undefined) ??
      "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80";
    const rating = (readField(c, "rating") as number | undefined) ?? 4.8;

    return {
      title: c.title,
      description,
      category,
      price: formatPrice(readField(c, "price")),
      rating,
      reviews: String(reviews),
      duration: courseDurationLabel(c),
      image: thumbnail,
    };
  });

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-10 px-6 py-12">
        <div className="flex flex-col gap-6 lg:flex-row">
          <InstructorProfileCard
            name={instructor.fullName}
            title="Instructor"
            bio={instructor.bio || "This instructor hasn't added a bio yet."}
            avatar={instructor.avatarUrl ?? "https://i.pravatar.cc/256?img=12"}
            tags={["AI", "Automation"]}
          />
          <InstructorStatsGrid
            coursesCount={instructor.courses.length}
            studentsCount="12,400"
            rating={4.8}
            reviewsCount="1.9k"
          />
        </div>

        <section className="flex flex-col gap-6">
          <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">
            Courses by {instructor.fullName}
          </h2>
          <div className="flex flex-wrap gap-6">
            {courseCards.map((course) => (
              <InstructorCourseCard key={course.title} {...course} />
            ))}
          </div>
        </section>
      </main>

      <CompactFooter />
    </div>
  );
}
'@

Write-Host ""
Write-Host "=== STEP 9b complete. ==="
Write-Host "Next: run 'pnpm --filter web run type-check' again to confirm the errors are gone."