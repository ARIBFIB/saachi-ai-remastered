# Phase3a-InstructorPortal-Core.ps1
# Run from: SAI2/ root
# Creates Instructor Portal core screens (Doc 2, Section 12, items 1-7 + 3-7 wizard):
#   1. Instructor layout (sidebar nav)
#   2. Dashboard
#   3. My Courses (instructor view)
#   4-8. Course Wizard (5 steps, single page with local stepper state)
#   9. Analytics
#   10. Earnings Overview
#
# Safety note: uses only verified-safe @saachi/ui components (Button, Input, Select,
# Textarea, EmptyState, Badge, KpiCard, Loading, Card, cn) — avoids Switch/StatusPill/
# DataTable which caused build breaks earlier. Uses local/dummy state instead of
# guessing @saachi/store's useInstructorCourseStore shape, since its exact fields
# haven't been confirmed from source.

$ErrorActionPreference = "Stop"
$webApp = Join-Path $PSScriptRoot "apps\web\app"

function New-PageFile {
    param([string]$RelativePath, [string]$Content)
    $fullPath = Join-Path $webApp $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (Test-Path -LiteralPath $fullPath) {
        Write-Host "SKIP (already exists): $fullPath" -ForegroundColor Yellow
        return
    }
    [System.IO.File]::WriteAllText($fullPath, $Content, [System.Text.Encoding]::UTF8)
    Write-Host "CREATED: $fullPath" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 1. Instructor layout — (instructor)/layout.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\layout.tsx" @'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import {
  LayoutDashboard,
  BookOpen,
  PlusCircle,
  BarChart3,
  Wallet,
  Banknote,
  Megaphone,
  GraduationCap,
  Star,
  Users,
  Settings,
  ShieldCheck
} from "lucide-react";
import { cn } from "@saachi/ui";

const NAV_ITEMS = [
  { href: "/instructor/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/instructor/courses", label: "My Courses", icon: BookOpen },
  { href: "/instructor/courses/new", label: "New Course", icon: PlusCircle },
  { href: "/instructor/analytics", label: "Analytics", icon: BarChart3 },
  { href: "/instructor/earnings", label: "Earnings", icon: Wallet },
  { href: "/instructor/payouts", label: "Payouts", icon: Banknote },
  { href: "/instructor/promotions", label: "Promotions", icon: Megaphone },
  { href: "/instructor/mentorship", label: "Mentorship", icon: GraduationCap },
  { href: "/instructor/reviews", label: "Reviews", icon: Star },
  { href: "/instructor/students", label: "Students", icon: Users },
  { href: "/instructor/settings", label: "Settings", icon: Settings },
  { href: "/instructor/verification", label: "Verification", icon: ShieldCheck }
];

export default function InstructorLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="mx-auto flex max-w-7xl gap-8 px-4 py-8 md:px-8">
      <aside className="hidden w-56 shrink-0 md:block">
        <div className="sticky top-24">
          <p className="mb-4 px-2 text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-soft/60">
            Instructor
          </p>
          <nav className="flex flex-col gap-1">
            {NAV_ITEMS.map((item) => {
              const active = pathname === item.href || pathname?.startsWith(item.href + "/");
              const Icon = item.icon;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    "flex items-center gap-2.5 rounded-control px-3 py-2 text-[13px] font-medium transition-colors",
                    active ? "bg-gold-tint text-gold-dark" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                  )}
                >
                  <Icon size={15} />
                  {item.label}
                </Link>
              );
            })}
          </nav>
        </div>
      </aside>

      <div className="min-w-0 flex-1">{children}</div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 2. Dashboard — (instructor)/instructor/dashboard/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\dashboard\page.tsx" @'
"use client";

import Link from "next/link";
import { DollarSign, Users, Star, MessageCircle } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, KpiCard, EmptyState } from "@saachi/ui";

// NOTE: demo-only dummy data. Replace with real analytics/enrollment hooks
// once packages/api-client hooks/useInstructorAnalytics.ts is confirmed.
const RECENT_REVIEWS = [
  { id: "r1", course: "n8n Automation Bootcamp", author: "Bilal S.", rating: 5, comment: "Very practical, loved it." },
  { id: "r2", course: "AI Chatbots for WhatsApp", author: "Fatima R.", rating: 4, comment: "Good pacing, clear examples." }
];

export default function InstructorDashboardPage() {
  const { data: session } = useSession();

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">
        Welcome back{session ? `, ${session.fullName}` : ""}
      </h1>
      <p className="mb-8 text-[14px] text-ink-soft">Here is how your courses are performing.</p>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard label="Lifetime earnings" value="$0.00" icon={DollarSign} />
        <KpiCard label="Total students" value="0" icon={Users} />
        <KpiCard label="Average rating" value="—" icon={Star} />
        <KpiCard label="Pending Q&A" value="0" icon={MessageCircle} />
      </div>

      <div className="mb-10 flex flex-wrap gap-3">
        <Link href="/instructor/courses/new">
          <Button>Create a new course</Button>
        </Link>
        <Link href="/instructor/courses">
          <Button variant="secondary">View my courses</Button>
        </Link>
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Recent reviews</h2>
      {RECENT_REVIEWS.length === 0 ? (
        <EmptyState title="No reviews yet" description="Reviews on your courses will show up here." />
      ) : (
        <div className="flex flex-col gap-3">
          {RECENT_REVIEWS.map((r) => (
            <div key={r.id} className="rounded-card border border-line bg-card p-4">
              <div className="mb-1 flex items-center justify-between">
                <p className="text-[14px] font-semibold text-ink">{r.course}</p>
                <span className="text-[12px] text-ink-soft">{"★".repeat(r.rating)}</span>
              </div>
              <p className="text-[13px] text-ink-soft">
                {r.author} — {r.comment}
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 3. My Courses (instructor view) — (instructor)/instructor/courses/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\courses\page.tsx" @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { Button, EmptyState, Select, Badge } from "@saachi/ui";

type CourseStatus = "draft" | "pending_review" | "published" | "rejected" | "archived";

type InstructorCourse = {
  id: string;
  title: string;
  status: CourseStatus;
  enrollments: number;
  price: number;
  currency: string;
};

// NOTE: demo-only dummy data. Replace with useInstructorCourses() once
// packages/api-client's instructor-course hooks are confirmed.
const COURSES: InstructorCourse[] = [];

const STATUS_OPTIONS = [
  { label: "All", value: "all" },
  { label: "Draft", value: "draft" },
  { label: "Pending review", value: "pending_review" },
  { label: "Published", value: "published" },
  { label: "Rejected", value: "rejected" },
  { label: "Archived", value: "archived" }
];

const STATUS_BADGE: Record<CourseStatus, "gold" | "success" | "error" | "neutral"> = {
  draft: "neutral",
  pending_review: "gold",
  published: "success",
  rejected: "error",
  archived: "neutral"
};

const STATUS_LABEL: Record<CourseStatus, string> = {
  draft: "Draft",
  pending_review: "Pending review",
  published: "Published",
  rejected: "Rejected",
  archived: "Archived"
};

export default function InstructorMyCoursesPage() {
  const [status, setStatus] = useState("all");

  const filtered = COURSES.filter((c) => status === "all" || c.status === status);

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <h1 className="font-display text-[26px] font-bold text-ink">My Courses</h1>
        <div className="flex items-center gap-3">
          <Select options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} className="w-48" />
          <Link href="/instructor/courses/new">
            <Button>New course</Button>
          </Link>
        </div>
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No courses yet"
          description="Create your first course to start selling on Saachi AI."
          action={
            <Link href="/instructor/courses/new">
              <Button>Create a course</Button>
            </Link>
          }
        />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Course</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Enrollments</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Price</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((c) => (
                <tr key={c.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3.5 font-medium text-ink">{c.title}</td>
                  <td className="px-4 py-3.5">
                    <Badge variant={STATUS_BADGE[c.status]}>{STATUS_LABEL[c.status]}</Badge>
                  </td>
                  <td className="px-4 py-3.5 text-ink-soft">{c.enrollments}</td>
                  <td className="px-4 py-3.5 font-mono text-ink">
                    {new Intl.NumberFormat("en-US", { style: "currency", currency: c.currency }).format(c.price)}
                  </td>
                  <td className="px-4 py-3.5">
                    <Link href={`/instructor/courses/${c.id}/edit`} className="text-gold-dark hover:underline">
                      Edit
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 4-8. Course Wizard (5 steps, single page) — (instructor)/instructor/courses/new/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\courses\new\page.tsx" @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Check } from "lucide-react";
import { Button, Input, Select, Textarea, EmptyState, cn } from "@saachi/ui";
import { CATEGORIES } from "../../../../../lib/categories";

const STEPS = ["Basics", "Curriculum", "Pricing", "Media", "Review & Submit"];

const LEVEL_OPTIONS = [
  { label: "Beginner", value: "beginner" },
  { label: "Intermediate", value: "intermediate" },
  { label: "Advanced", value: "advanced" }
];

const LANGUAGE_OPTIONS = [
  { label: "English", value: "en" },
  { label: "Urdu", value: "ur" }
];

type LessonType = "video" | "text" | "quiz" | "resource";

type Lesson = { id: string; title: string; type: LessonType };
type Module = { id: string; title: string; lessons: Lesson[] };

let idCounter = 0;
function nextId() {
  idCounter += 1;
  return `m${idCounter}`;
}

export default function CourseWizardPage() {
  const router = useRouter();
  const [step, setStep] = useState(0);
  const [submitted, setSubmitted] = useState(false);

  // Step 1: Basics
  const [title, setTitle] = useState("");
  const [subtitle, setSubtitle] = useState("");
  const [category, setCategory] = useState(CATEGORIES[0]?.id ?? "");
  const [level, setLevel] = useState("beginner");
  const [language, setLanguage] = useState("en");

  // Step 2: Curriculum
  const [modules, setModules] = useState<Module[]>([]);

  function addModule() {
    setModules((prev) => [...prev, { id: nextId(), title: `Module ${prev.length + 1}`, lessons: [] }]);
  }

  function addLesson(moduleId: string, type: LessonType) {
    setModules((prev) =>
      prev.map((m) =>
        m.id === moduleId
          ? { ...m, lessons: [...m.lessons, { id: nextId(), title: `New ${type} lesson`, type }] }
          : m
      )
    );
  }

  // Step 3: Pricing
  const [price, setPrice] = useState("");
  const [currency, setCurrency] = useState("USD");
  const [includeInSubscription, setIncludeInSubscription] = useState(false);

  // Step 4: Media
  const [thumbnailUrl, setThumbnailUrl] = useState("");
  const [promoVideoUrl, setPromoVideoUrl] = useState("");

  const canGoNext = (() => {
    if (step === 0) return title.trim().length > 0 && category.length > 0;
    if (step === 1) return modules.length > 0;
    if (step === 2) return price.trim().length > 0;
    return true;
  })();

  function handleSubmit() {
    // NOTE: demo-only, no backend course-creation mutation wired up yet.
    setSubmitted(true);
  }

  if (submitted) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Course submitted for review"
          description="Our moderation team will review your course and notify you once it's approved."
          action={<Button onClick={() => router.push("/instructor/courses")}>Back to my courses</Button>}
        />
      </div>
    );
  }

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Create a new course</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Step {step + 1} of {STEPS.length}: {STEPS[step]}</p>

      {/* Stepper */}
      <div className="mb-8 flex items-center gap-2">
        {STEPS.map((s, i) => (
          <div key={s} className="flex flex-1 items-center gap-2">
            <div
              className={cn(
                "flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-[12px] font-semibold",
                i < step ? "bg-teal text-white" : i === step ? "bg-gold-dark text-white" : "bg-paper-dim text-ink-soft"
              )}
            >
              {i < step ? <Check size={14} /> : i + 1}
            </div>
            {i < STEPS.length - 1 && <div className={cn("h-0.5 flex-1", i < step ? "bg-teal" : "bg-line")} />}
          </div>
        ))}
      </div>

      <div className="rounded-card border border-line bg-card p-6">
        {step === 0 && (
          <div className="flex flex-col gap-4">
            <Input label="Course title" required value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. n8n Automation Bootcamp" />
            <Input label="Subtitle" value={subtitle} onChange={(e) => setSubtitle(e.target.value)} placeholder="A short one-line summary" />
            <Select
              label="Category"
              options={CATEGORIES.map((c) => ({ label: c.name, value: c.id }))}
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            />
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Select label="Level" options={LEVEL_OPTIONS} value={level} onChange={(e) => setLevel(e.target.value)} />
              <Select label="Language" options={LANGUAGE_OPTIONS} value={language} onChange={(e) => setLanguage(e.target.value)} />
            </div>
          </div>
        )}

        {step === 1 && (
          <div>
            {modules.length === 0 ? (
              <EmptyState title="No modules yet" description="Add your first module to start building the curriculum." />
            ) : (
              <div className="flex flex-col gap-4">
                {modules.map((m) => (
                  <div key={m.id} className="rounded-control border border-line p-4">
                    <p className="mb-3 text-[14px] font-semibold text-ink">{m.title}</p>
                    {m.lessons.length > 0 && (
                      <ul className="mb-3 flex flex-col gap-1.5">
                        {m.lessons.map((l) => (
                          <li key={l.id} className="flex items-center gap-2 text-[13px] text-ink-soft">
                            <span className="rounded bg-paper-dim px-1.5 py-0.5 text-[11px] uppercase">{l.type}</span>
                            {l.title}
                          </li>
                        ))}
                      </ul>
                    )}
                    <div className="flex flex-wrap gap-2">
                      <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "video")}>+ Video</Button>
                      <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "text")}>+ Text</Button>
                      <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "quiz")}>+ Quiz</Button>
                      <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "resource")}>+ Resource</Button>
                    </div>
                  </div>
                ))}
              </div>
            )}
            <Button variant="secondary" className="mt-4" onClick={addModule}>+ Add module</Button>
          </div>
        )}

        {step === 2 && (
          <div className="flex flex-col gap-4">
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Input label="Price" type="number" required value={price} onChange={(e) => setPrice(e.target.value)} placeholder="49.00" />
              <Select
                label="Currency"
                options={[
                  { label: "USD", value: "USD" },
                  { label: "PKR", value: "PKR" }
                ]}
                value={currency}
                onChange={(e) => setCurrency(e.target.value)}
              />
            </div>
            <label className="flex items-center gap-2 text-[13px] text-ink-soft">
              <input
                type="checkbox"
                checked={includeInSubscription}
                onChange={(e) => setIncludeInSubscription(e.target.checked)}
                className="h-4 w-4 accent-gold-dark"
              />
              Include this course in the Saachi AI Pro subscription
            </label>
          </div>
        )}

        {step === 3 && (
          <div className="flex flex-col gap-4">
            <Input label="Thumbnail URL" value={thumbnailUrl} onChange={(e) => setThumbnailUrl(e.target.value)} placeholder="https://..." />
            <Input label="Promo video URL" value={promoVideoUrl} onChange={(e) => setPromoVideoUrl(e.target.value)} placeholder="https://..." />
            <p className="text-[12px] text-ink-soft">
              File upload with resumable/chunked upload will be wired up once the signed-URL flow from the backend is available.
            </p>
          </div>
        )}

        {step === 4 && (
          <div className="flex flex-col gap-4 text-[14px]">
            <div>
              <p className="text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/60">Title</p>
              <p className="text-ink">{title || "—"}</p>
            </div>
            <div>
              <p className="text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/60">Category</p>
              <p className="text-ink">{CATEGORIES.find((c) => c.id === category)?.name ?? "—"}</p>
            </div>
            <div>
              <p className="text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/60">Modules</p>
              <p className="text-ink">{modules.length} module(s), {modules.reduce((sum, m) => sum + m.lessons.length, 0)} lesson(s)</p>
            </div>
            <div>
              <p className="text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/60">Price</p>
              <p className="text-ink">{price ? `${price} ${currency}` : "—"}</p>
            </div>
          </div>
        )}
      </div>

      <div className="mt-6 flex justify-between">
        <Button variant="secondary" disabled={step === 0} onClick={() => setStep((s) => Math.max(0, s - 1))}>
          Back
        </Button>
        {step < STEPS.length - 1 ? (
          <Button disabled={!canGoNext} onClick={() => setStep((s) => Math.min(STEPS.length - 1, s + 1))}>
            Next
          </Button>
        ) : (
          <Button onClick={handleSubmit}>Submit for review</Button>
        )}
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 9. Analytics — (instructor)/instructor/analytics/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\analytics\page.tsx" @'
"use client";

import { TrendingUp, Users, CheckCircle2, Globe } from "lucide-react";
import { KpiCard, EmptyState } from "@saachi/ui";

export default function InstructorAnalyticsPage() {
  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Analytics</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Enrollment, completion, and revenue trends across your courses.</p>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard label="Total enrollments" value="0" icon={Users} />
        <KpiCard label="Completion rate" value="—" icon={CheckCircle2} />
        <KpiCard label="Revenue (30d)" value="$0.00" icon={TrendingUp} />
        <KpiCard label="Top traffic source" value="—" icon={Globe} />
      </div>

      <EmptyState
        title="Not enough data yet"
        description="Charts for enrollment trends, completion rate, revenue, and student engagement will appear here once your courses start getting enrollments."
      />
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 10. Earnings Overview — (instructor)/instructor/earnings/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\earnings\page.tsx" @'
"use client";

import Link from "next/link";
import { Wallet, TrendingUp, Clock } from "lucide-react";
import { Button, KpiCard, EmptyState } from "@saachi/ui";

export default function InstructorEarningsPage() {
  return (
    <div>
      <div className="mb-8 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Earnings</h1>
          <p className="text-[14px] text-ink-soft">Your current balance and lifetime earnings breakdown.</p>
        </div>
        <Link href="/instructor/payouts">
          <Button>Request payout</Button>
        </Link>
      </div>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <KpiCard label="Available balance" value="$0.00" icon={Wallet} />
        <KpiCard label="Lifetime earnings" value="$0.00" icon={TrendingUp} />
        <KpiCard label="Pending clearance" value="$0.00" icon={Clock} />
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Earnings by course</h2>
      <EmptyState
        title="No earnings yet"
        description="Once learners start purchasing your courses, a per-course earnings breakdown will appear here."
      />
    </div>
  );
}
'@

Write-Host ""
Write-Host "Phase 3a done. Review the files above, then:" -ForegroundColor Cyan
Write-Host "  git add ."
Write-Host "  git commit -m `"feat: Phase 3a Instructor Portal core (layout, dashboard, my-courses, course wizard, analytics, earnings)`""
Write-Host "  git push"
Write-Host ""
Write-Host "Test routes after deploy (must be logged in):" -ForegroundColor Cyan
Write-Host "  /instructor/dashboard"
Write-Host "  /instructor/courses"
Write-Host "  /instructor/courses/new"
Write-Host "  /instructor/analytics"
Write-Host "  /instructor/earnings"