<#
.SYNOPSIS
    Replaces the "Coming soon" placeholder at /instructor/courses/preview
    with a real learner-view course preview: course selector + mock
    public-course-page rendering (thumbnail/title/price/curriculum accordion).

.USAGE
    Run from the SAI2 repo root:
    PS D:\...\SAI2> .\Add-CoursePreview.ps1
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

Write-Section "Course Preview page"

$previewPath = Join-Path $root "apps\web\app\(instructor)\instructor\courses\preview\page.tsx"

$previewContent = @'
"use client";

import { useMemo, useState } from "react";
import { Eye, Star, Globe2, BarChart3, Clock, Video, FileText, HelpCircle, Paperclip } from "lucide-react";
import { useInstructorCourseStore, type InstructorCourseLesson } from "@saachi/store";
import { useSession } from "@saachi/api-client";
import { Select, EmptyState, Badge, Accordion, Button, type AccordionItemData } from "@saachi/ui";

const LEVEL_LABEL: Record<string, string> = {
  beginner: "Beginner",
  intermediate: "Intermediate",
  advanced: "Advanced"
};

const LANGUAGE_LABEL: Record<string, string> = {
  en: "English",
  ur: "Urdu"
};

const LESSON_TYPE_META: Record<InstructorCourseLesson["type"], { label: string; icon: typeof Video }> = {
  video: { label: "Video", icon: Video },
  text: { label: "Text", icon: FileText },
  quiz: { label: "Quiz", icon: HelpCircle },
  resource: { label: "Resource", icon: Paperclip }
};

export default function InstructorCoursesPreviewPage() {
  const courses = useInstructorCourseStore((s) => s.courses);
  const { data: session } = useSession();

  const [courseId, setCourseId] = useState(courses[0]?.id ?? "");

  const course = useMemo(() => courses.find((c) => c.id === courseId), [courses, courseId]);

  const totalLessons = useMemo(
    () => course?.modules.reduce((sum, m) => sum + m.lessons.length, 0) ?? 0,
    [course]
  );

  const accordionItems: AccordionItemData[] = useMemo(() => {
    if (!course) return [];
    return course.modules.map((m) => ({
      id: m.id,
      title: m.title,
      meta: (
        <span className="text-[11.5px] text-ink-soft">
          {m.lessons.length} lesson{m.lessons.length === 1 ? "" : "s"}
        </span>
      ),
      content: (
        <ul className="flex flex-col gap-2">
          {m.lessons.map((lesson) => {
            const Icon = LESSON_TYPE_META[lesson.type].icon;
            return (
              <li key={lesson.id} className="flex items-center gap-2.5 text-[13px] text-ink">
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded bg-paper-dim text-ink-soft">
                  <Icon size={12} />
                </span>
                <span className="flex-1">{lesson.title}</span>
                <span className="text-[11px] uppercase tracking-wide text-ink-soft/60">
                  {LESSON_TYPE_META[lesson.type].label}
                </span>
              </li>
            );
          })}
        </ul>
      )
    }));
  }, [course]);

  if (courses.length === 0) {
    return (
      <div>
        <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Course Preview</h1>
        <p className="mb-8 text-[14px] text-ink-soft">Preview how your course appears to learners before publishing.</p>
        <EmptyState title="No courses yet" description="Create a course first to preview it." />
      </div>
    );
  }

  const courseOptions = courses.map((c) => ({ label: c.title, value: c.id }));

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Course Preview</h1>
          <p className="text-[14px] text-ink-soft">Preview how your course appears to learners before publishing.</p>
        </div>
        <Select options={courseOptions} value={courseId} onChange={(e) => setCourseId(e.target.value)} className="w-72" />
      </div>

      {!course ? (
        <EmptyState title="Select a course" description="Choose a course above to preview it." />
      ) : (
        <>
          <div className="mb-6 flex items-center gap-2 rounded-control border border-gold-dark/30 bg-gold-tint px-4 py-2.5 text-[12.5px] font-medium text-gold-dark">
            <Eye size={14} />
            Preview mode - this is how learners will see this course. Nothing here is live.
          </div>

          <div className="grid grid-cols-1 gap-6 lg:grid-cols-[1fr_320px]">
            <div>
              <div className="mb-6 flex aspect-video w-full items-center justify-center rounded-card border border-line bg-paper-dim text-[13px] text-ink-soft/60">
                No thumbnail uploaded
              </div>

              <h2 className="mb-1 font-display text-[24px] font-bold text-ink">{course.title}</h2>
              {course.subtitle && <p className="mb-4 text-[15px] text-ink-soft">{course.subtitle}</p>}

              <div className="mb-6 flex flex-wrap items-center gap-4 text-[13px] text-ink-soft">
                <span className="flex items-center gap-1.5">
                  <Star size={14} className="fill-gold text-gold" />
                  {course.rating > 0 ? course.rating.toFixed(1) : "No ratings yet"}
                  {course.rating > 0 && <span className="text-ink-soft/60">({course.enrollmentCount})</span>}
                </span>
                <span className="flex items-center gap-1.5">
                  <BarChart3 size={14} />
                  {LEVEL_LABEL[course.level] ?? course.level}
                </span>
                <span className="flex items-center gap-1.5">
                  <Globe2 size={14} />
                  {LANGUAGE_LABEL[course.language] ?? course.language}
                </span>
                <span className="flex items-center gap-1.5">
                  <Clock size={14} />
                  {totalLessons} lesson{totalLessons === 1 ? "" : "s"}
                </span>
              </div>

              <div className="mb-6 flex items-center gap-3 rounded-card border border-line bg-card p-4">
                <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-gold-tint text-[13px] font-semibold text-gold-dark">
                  {(session?.fullName ?? "I").charAt(0)}
                </div>
                <div>
                  <p className="text-[13px] font-semibold text-ink">{session?.fullName ?? "Instructor"}</p>
                  <p className="text-[12px] text-ink-soft">Course instructor</p>
                </div>
              </div>

              <h3 className="mb-4 font-display text-[18px] font-semibold text-ink">Curriculum</h3>
              {course.modules.length === 0 ? (
                <EmptyState
                  title="No curriculum yet"
                  description="Add modules and lessons in the Curriculum Builder to preview them here."
                />
              ) : (
                <Accordion items={accordionItems} />
              )}
            </div>

            <aside className="h-fit rounded-card border border-line bg-card p-6">
              <p className="mb-1 font-mono text-[26px] font-bold text-ink">
                {new Intl.NumberFormat("en-US", { style: "currency", currency: course.currency }).format(course.price)}
              </p>
              <p className="mb-5 text-[12.5px] text-ink-soft">One-time purchase</p>

              <Button className="mb-3 w-full" disabled>
                Enroll now (preview only)
              </Button>
              <p className="mb-5 text-center text-[11.5px] text-ink-soft/60">
                Learners will see a real, clickable button here once published.
              </p>

              <div className="flex flex-col gap-2 border-t border-line pt-4 text-[13px]">
                <div className="flex items-center justify-between">
                  <span className="text-ink-soft">Status</span>
                  <Badge variant={course.status === "published" ? "success" : course.status === "pending_review" ? "gold" : undefined}>
                    {course.status === "published" ? "Published" : course.status === "pending_review" ? "Pending review" : "Draft"}
                  </Badge>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-ink-soft">Modules</span>
                  <span className="font-medium text-ink">{course.modules.length}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-ink-soft">Lessons</span>
                  <span className="font-medium text-ink">{totalLessons}</span>
                </div>
              </div>
            </aside>
          </div>
        </>
      )}
    </div>
  );
}
'@

Write-FileSafe -path $previewPath -content $previewContent

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Course Preview page written." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Next steps:"
Write-Host "  1. git diff apps/web/app/(instructor)/instructor/courses/preview/page.tsx"
Write-Host "  2. pnpm turbo run build   -> verify it compiles"
Write-Host "  3. Commit and push"
Write-Host ""
Write-Host "Note: uses the existing Accordion component from @saachi/ui and" -ForegroundColor Yellow
Write-Host "      the useInstructorCourseStore data - no new store needed." -ForegroundColor Yellow