# step4-instructor-portal.ps1
# Run from: SAI2 root folder

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}

function Patch-File {
    param([string]$Path, [string]$OldStr, [string]$NewStr, [string]$Label)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP (file not found): $fullPath" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Path $fullPath -Raw
    if ($content.Contains($OldStr)) {
        $updated = $content.Replace($OldStr, $NewStr)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($fullPath, $updated, $enc)
        Write-Host "  patched ($Label): $fullPath"
    } else {
        Write-Host "  WARNING: pattern for '$Label' not found in $fullPath - skipped." -ForegroundColor Yellow
    }
}

Write-Host "Step 4: Instructor portal (dashboard, courses, wizard, analytics, earnings, reviews, students, settings)..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. useInstructorCourseStore - locally-created draft/published courses (Zustand)
# ---------------------------------------------------------------------------
$instructorCourseStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type InstructorCourseLesson = {
  id: string;
  title: string;
  type: "video" | "text" | "quiz" | "resource";
};

export type InstructorCourseModule = {
  id: string;
  title: string;
  lessons: InstructorCourseLesson[];
};

export type InstructorCourse = {
  id: string;
  title: string;
  subtitle: string;
  categoryId: string;
  language: string;
  level: "beginner" | "intermediate" | "advanced";
  price: number;
  currency: string;
  status: "draft" | "pending_review" | "published";
  modules: InstructorCourseModule[];
  createdAt: string;
  enrollmentCount: number;
  revenue: number;
  rating: number;
};

type InstructorCourseState = {
  courses: InstructorCourse[];
  addCourse: (course: InstructorCourse) => void;
  updateCourse: (id: string, patch: Partial<InstructorCourse>) => void;
  removeCourse: (id: string) => void;
};

export const useInstructorCourseStore = create<InstructorCourseState>()(
  persist(
    (set, get) => ({
      courses: [],
      addCourse: (course) => set({ courses: [course, ...get().courses] }),
      updateCourse: (id, patch) =>
        set({ courses: get().courses.map((c) => (c.id === id ? { ...c, ...patch } : c)) }),
      removeCourse: (id) => set({ courses: get().courses.filter((c) => c.id !== id) })
    }),
    { name: "saachi-instructor-courses" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useInstructorCourseStore.ts" -Content $instructorCourseStore

# ---------------------------------------------------------------------------
# 2. useCourseBuilderStore - multi-step wizard draft state (Doc 2 Zustand spec)
# ---------------------------------------------------------------------------
$courseBuilderStore = @'
import { create } from "zustand";
import type { InstructorCourseModule } from "./useInstructorCourseStore";

export type CourseBuilderDraft = {
  title: string;
  subtitle: string;
  categoryId: string;
  language: string;
  level: "beginner" | "intermediate" | "advanced";
  tags: string[];
  price: number;
  currency: "USD" | "PKR" | "GBP";
  subscriptionIncluded: boolean;
  modules: InstructorCourseModule[];
  thumbnailSeed: string;
};

const EMPTY_DRAFT: CourseBuilderDraft = {
  title: "",
  subtitle: "",
  categoryId: "",
  language: "en",
  level: "beginner",
  tags: [],
  price: 0,
  currency: "USD",
  subscriptionIncluded: false,
  modules: [],
  thumbnailSeed: ""
};

type CourseBuilderState = {
  step: number;
  draft: CourseBuilderDraft;
  setStep: (step: number) => void;
  updateDraft: (patch: Partial<CourseBuilderDraft>) => void;
  addModule: () => void;
  removeModule: (moduleId: string) => void;
  updateModuleTitle: (moduleId: string, title: string) => void;
  addLesson: (moduleId: string, type: InstructorCourseModule["lessons"][number]["type"]) => void;
  removeLesson: (moduleId: string, lessonId: string) => void;
  updateLessonTitle: (moduleId: string, lessonId: string, title: string) => void;
  reset: () => void;
};

function genId(prefix: string) {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

export const useCourseBuilderStore = create<CourseBuilderState>()((set, get) => ({
  step: 1,
  draft: EMPTY_DRAFT,

  setStep: (step) => set({ step }),

  updateDraft: (patch) => set({ draft: { ...get().draft, ...patch } }),

  addModule: () =>
    set({
      draft: {
        ...get().draft,
        modules: [...get().draft.modules, { id: genId("mod"), title: "New module", lessons: [] }]
      }
    }),

  removeModule: (moduleId) =>
    set({ draft: { ...get().draft, modules: get().draft.modules.filter((m) => m.id !== moduleId) } }),

  updateModuleTitle: (moduleId, title) =>
    set({
      draft: {
        ...get().draft,
        modules: get().draft.modules.map((m) => (m.id === moduleId ? { ...m, title } : m))
      }
    }),

  addLesson: (moduleId, type) =>
    set({
      draft: {
        ...get().draft,
        modules: get().draft.modules.map((m) =>
          m.id === moduleId
            ? { ...m, lessons: [...m.lessons, { id: genId("les"), title: "New lesson", type }] }
            : m
        )
      }
    }),

  removeLesson: (moduleId, lessonId) =>
    set({
      draft: {
        ...get().draft,
        modules: get().draft.modules.map((m) =>
          m.id === moduleId ? { ...m, lessons: m.lessons.filter((l) => l.id !== lessonId) } : m
        )
      }
    }),

  updateLessonTitle: (moduleId, lessonId, title) =>
    set({
      draft: {
        ...get().draft,
        modules: get().draft.modules.map((m) =>
          m.id === moduleId
            ? { ...m, lessons: m.lessons.map((l) => (l.id === lessonId ? { ...l, title } : l)) }
            : m
        )
      }
    }),

  reset: () => set({ step: 1, draft: EMPTY_DRAFT })
}));
'@
Write-Utf8NoBom -Path "packages\store\src\useCourseBuilderStore.ts" -Content $courseBuilderStore

$storeIndexUpdated = @'
export * from "./useCartStore";
export * from "./useWishlistStore";
export * from "./useEnrollmentStore";
export * from "./useNotificationStore";
export * from "./useInstructorCourseStore";
export * from "./useCourseBuilderStore";
'@
Write-Utf8NoBom -Path "packages\store\src\index.ts" -Content $storeIndexUpdated

# ---------------------------------------------------------------------------
# 3. Instructor shell (sidebar layout)
# ---------------------------------------------------------------------------
$instructorShell = @'
"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState, type ReactNode } from "react";
import {
  LayoutDashboard,
  BookOpen,
  PlusCircle,
  BarChart3,
  Wallet,
  Star,
  Users,
  Settings,
  LogOut,
  Menu,
  X
} from "lucide-react";
import { useSession, useLogout } from "@saachi/api-client";
import { cn } from "@saachi/ui";

const NAV_ITEMS = [
  { label: "Dashboard", href: "/instructor/dashboard", icon: LayoutDashboard },
  { label: "My Courses", href: "/instructor/courses", icon: BookOpen },
  { label: "Create Course", href: "/instructor/courses/new", icon: PlusCircle },
  { label: "Analytics", href: "/instructor/analytics", icon: BarChart3 },
  { label: "Earnings & Payouts", href: "/instructor/earnings", icon: Wallet },
  { label: "Reviews", href: "/instructor/reviews", icon: Star },
  { label: "Students", href: "/instructor/students", icon: Users },
  { label: "Settings", href: "/instructor/settings", icon: Settings }
];

export function InstructorShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const [mobileOpen, setMobileOpen] = useState(false);

  const handleLogout = async () => {
    await logout.mutateAsync();
    router.push("/");
  };

  const sidebarContent = (
    <div className="flex h-full flex-col">
      <Link href="/" className="flex items-center gap-2.5 px-6 py-6">
        <span className="flex h-9 w-9 items-center justify-center rounded-full border-2 border-ink bg-teal font-display text-[15px] font-bold text-white">
          S
        </span>
        <div>
          <div className="font-display text-[16px] font-semibold leading-none text-ink">Saachi AI</div>
          <div className="mt-1 text-[11px] font-medium uppercase tracking-[0.06em] text-teal">Instructor</div>
        </div>
      </Link>

      <nav className="flex flex-1 flex-col gap-1 px-3">
        {NAV_ITEMS.map((item) => {
          const active = pathname === item.href || Boolean(pathname && pathname.startsWith(`${item.href}/`));
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setMobileOpen(false)}
              className={cn(
                "flex items-center gap-3 rounded-control px-3.5 py-2.5 text-[14px] font-medium transition-colors duration-150 ease-out",
                active ? "bg-teal-light text-teal" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
              )}
            >
              <item.icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-line px-3 py-4">
        <div className="mb-3 flex items-center gap-3 px-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[13px] font-semibold text-teal">
            {session?.avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={session.avatarUrl} alt={session.fullName} className="h-full w-full object-cover" />
            ) : (
              session?.fullName?.charAt(0) ?? "?"
            )}
          </div>
          <div className="min-w-0">
            <div className="truncate text-[13px] font-semibold text-ink">{session?.fullName ?? "Guest"}</div>
            <div className="truncate text-[12px] text-ink-soft">{session?.email ?? ""}</div>
          </div>
        </div>
        <Link
          href="/dashboard"
          className="mb-1 flex w-full items-center gap-3 rounded-control px-3.5 py-2.5 text-[13px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
        >
          Switch to learner view
        </Link>
        <button
          type="button"
          onClick={handleLogout}
          disabled={logout.isPending}
          className="flex w-full items-center gap-3 rounded-control px-3.5 py-2.5 text-[14px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-error"
        >
          <LogOut size={18} />
          {logout.isPending ? "Logging out..." : "Log out"}
        </button>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-paper">
      <div className="hidden w-[260px] shrink-0 border-r border-line bg-card md:fixed md:inset-y-0 md:flex">
        {sidebarContent}
      </div>

      <div className="flex items-center justify-between border-b border-line bg-card px-4 py-3 md:hidden">
        <Link href="/" className="flex items-center gap-2">
          <span className="flex h-8 w-8 items-center justify-center rounded-full border-2 border-ink bg-teal font-display text-[13px] font-bold text-white">
            S
          </span>
          <span className="font-display text-[15px] font-semibold text-ink">Saachi AI Instructor</span>
        </Link>
        <button
          type="button"
          onClick={() => setMobileOpen(true)}
          aria-label="Open menu"
          className="flex h-9 w-9 items-center justify-center rounded-control text-ink"
        >
          <Menu size={20} />
        </button>
      </div>

      {mobileOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div className="absolute inset-0 bg-ink/40" onClick={() => setMobileOpen(false)} />
          <div className="relative flex h-full w-[280px] flex-col bg-card">
            <button
              type="button"
              onClick={() => setMobileOpen(false)}
              aria-label="Close menu"
              className="absolute right-3 top-3 flex h-9 w-9 items-center justify-center rounded-control text-ink"
            >
              <X size={20} />
            </button>
            {sidebarContent}
          </div>
        </div>
      )}

      <div className="md:pl-[260px]">{children}</div>
    </div>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\_components\InstructorShell.tsx" -Content $instructorShell

$instructorLayout = @'
import type { ReactNode } from "react";
import { InstructorShell } from "./_components/InstructorShell";

export default function InstructorLayout({ children }: { children: ReactNode }) {
  return <InstructorShell>{children}</InstructorShell>;
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\layout.tsx" -Content $instructorLayout

# ---------------------------------------------------------------------------
# 4. Instructor Dashboard
# ---------------------------------------------------------------------------
$instructorDashboard = @'
"use client";

import Link from "next/link";
import { DollarSign, BookOpen, Users, Star, PlusCircle } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { useInstructorCourseStore } from "@saachi/store";
import { Button, Card } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

export default function InstructorDashboardPage() {
  const { data: session } = useSession();
  const { courses } = useInstructorCourseStore();

  const totalRevenue = courses.reduce((sum, c) => sum + c.revenue, 0);
  const totalEnrollments = courses.reduce((sum, c) => sum + c.enrollmentCount, 0);
  const avgRating = courses.length
    ? (courses.reduce((sum, c) => sum + c.rating, 0) / courses.length).toFixed(1)
    : "—";
  const published = courses.filter((c) => c.status === "published").length;

  const stats = [
    { label: "Total earnings", value: formatCurrency(totalRevenue, "USD"), icon: DollarSign },
    { label: "Published courses", value: String(published), icon: BookOpen },
    { label: "Total students", value: totalEnrollments.toLocaleString(), icon: Users },
    { label: "Average rating", value: avgRating, icon: Star }
  ];

  return (
    <main className="mx-auto max-w-[1100px] px-6 py-10 md:px-10">
      <div className="mb-8 flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
        <div>
          <h1 className="font-display text-[26px] font-semibold text-ink">
            Welcome back{session?.fullName ? `, ${session.fullName.split(" ")[0]}` : ""}
          </h1>
          <p className="mt-1 text-[14px] text-ink-soft">Here's how your courses are performing.</p>
        </div>
        <Link href="/instructor/courses/new">
          <Button>
            <PlusCircle size={16} /> Create course
          </Button>
        </Link>
      </div>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.label} className="p-5">
            <div className="mb-3 flex h-9 w-9 items-center justify-center rounded-control bg-teal-light text-teal">
              <stat.icon size={17} />
            </div>
            <div className="font-mono text-[22px] font-semibold text-ink">{stat.value}</div>
            <div className="mt-1 text-[13px] text-ink-soft">{stat.label}</div>
          </Card>
        ))}
      </div>

      <h2 className="mb-4 font-display text-[18px] font-semibold text-ink">Your courses</h2>
      {courses.length === 0 ? (
        <Card className="p-6 text-center">
          <p className="mb-4 text-[14px] text-ink-soft">
            You haven't created any courses yet. This is demo data - courses you create here are
            stored locally in your browser.
          </p>
          <Link href="/instructor/courses/new">
            <Button>Create your first course</Button>
          </Link>
        </Card>
      ) : (
        <div className="flex flex-col gap-3">
          {courses.slice(0, 5).map((course) => (
            <Card key={course.id} className="flex items-center justify-between p-4">
              <div>
                <p className="text-[14px] font-semibold text-ink">{course.title || "Untitled course"}</p>
                <p className="mt-1 text-[12px] capitalize text-ink-soft">{course.status.replace("_", " ")}</p>
              </div>
              <span className="font-mono text-[14px] font-semibold text-ink">
                {formatCurrency(course.revenue, course.currency)}
              </span>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\dashboard\page.tsx" -Content $instructorDashboard

# ---------------------------------------------------------------------------
# 5. Instructor My Courses list
# ---------------------------------------------------------------------------
$instructorCoursesPage = @'
"use client";

import Link from "next/link";
import { PlusCircle, BookOpen } from "lucide-react";
import { useInstructorCourseStore } from "@saachi/store";
import { Button, Card, Badge, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_VARIANT = {
  draft: "default",
  pending_review: "warning",
  published: "success"
} as const;

export default function InstructorCoursesPage() {
  const { courses, removeCourse } = useInstructorCourseStore();

  return (
    <main className="mx-auto max-w-[1100px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="font-display text-[26px] font-semibold text-ink">My Courses</h1>
          <p className="mt-1 text-[14px] text-ink-soft">Manage the courses you've created.</p>
        </div>
        <Link href="/instructor/courses/new">
          <Button>
            <PlusCircle size={16} /> Create course
          </Button>
        </Link>
      </div>

      {courses.length === 0 ? (
        <EmptyState
          icon={<BookOpen size={22} />}
          title="No courses yet"
          description="Start the course creation wizard to publish your first course."
          action={
            <Link href="/instructor/courses/new">
              <Button>Create course</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-3">
          {courses.map((course) => (
            <Card key={course.id} className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <div className="flex items-center gap-2">
                  <p className="text-[15px] font-semibold text-ink">{course.title || "Untitled course"}</p>
                  <Badge variant={STATUS_VARIANT[course.status]}>{course.status.replace("_", " ")}</Badge>
                </div>
                <p className="mt-1 text-[13px] text-ink-soft">
                  {course.modules.length} modules &middot; Created {formatDate(course.createdAt)}
                </p>
              </div>
              <div className="flex items-center gap-4">
                <span className="font-mono text-[14px] font-semibold text-ink">
                  {formatCurrency(course.price, course.currency)}
                </span>
                <Button size="sm" variant="secondary" onClick={() => removeCourse(course.id)}>
                  Delete
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\courses\page.tsx" -Content $instructorCoursesPage

# ---------------------------------------------------------------------------
# 6. Course Creation Wizard (5 steps in one page, per Doc 2)
# ---------------------------------------------------------------------------
$courseWizardPage = @'
"use client";

import { useRouter } from "next/navigation";
import { Plus, Trash2, CheckCircle2, PlayCircle, FileText, HelpCircle, Download } from "lucide-react";
import { useCourseBuilderStore, useInstructorCourseStore } from "@saachi/store";
import { Button, Card, Input, Textarea, Select, Checkbox, Badge } from "@saachi/ui";

const STEPS = ["Basics", "Curriculum", "Pricing", "Media", "Review"];

const CATEGORY_OPTIONS = [
  { label: "AI Fundamentals & Prompt Engineering", value: "ai-fundamentals" },
  { label: "AI for Marketing & Sales", value: "ai-marketing" },
  { label: "AI Automation & Workflow Tools", value: "ai-automation" },
  { label: "AI Customer Support & Communication", value: "ai-support" },
  { label: "AI Website & App Development", value: "ai-dev" },
  { label: "AI Integration for Developers", value: "ai-integration" }
];

const LEVEL_OPTIONS = [
  { label: "Beginner", value: "beginner" },
  { label: "Intermediate", value: "intermediate" },
  { label: "Advanced", value: "advanced" }
];

const LANGUAGE_OPTIONS = [
  { label: "English", value: "en" },
  { label: "Urdu", value: "ur" }
];

const CURRENCY_OPTIONS = [
  { label: "USD", value: "USD" },
  { label: "PKR", value: "PKR" },
  { label: "GBP", value: "GBP" }
];

const LESSON_TYPE_ICON = {
  video: PlayCircle,
  text: FileText,
  quiz: HelpCircle,
  resource: Download
} as const;

export default function CourseWizardPage() {
  const router = useRouter();
  const wizard = useCourseBuilderStore();
  const instructorCourses = useInstructorCourseStore();
  const { draft, step } = wizard;

  const canGoNext = () => {
    if (step === 1) return draft.title.trim().length >= 5 && draft.categoryId;
    if (step === 2) return draft.modules.length > 0;
    if (step === 3) return draft.price >= 0;
    return true;
  };

  const handlePublish = (status: "draft" | "pending_review") => {
    const totalLessons = draft.modules.reduce((sum, m) => sum + m.lessons.length, 0);
    instructorCourses.addCourse({
      id: `crs_local_${Date.now()}`,
      title: draft.title,
      subtitle: draft.subtitle,
      categoryId: draft.categoryId,
      language: draft.language,
      level: draft.level,
      price: draft.price,
      currency: draft.currency,
      status,
      modules: draft.modules,
      createdAt: new Date().toISOString(),
      enrollmentCount: 0,
      revenue: 0,
      rating: 0
    });
    wizard.reset();
    router.push("/instructor/courses");
  };

  return (
    <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
      <h1 className="mb-2 font-display text-[26px] font-semibold text-ink">Create a course</h1>
      <p className="mb-8 text-[14px] text-ink-soft">
        This demo wizard saves your course locally in the browser (no backend yet).
      </p>

      <div className="mb-8 flex items-center gap-2">
        {STEPS.map((label, i) => {
          const stepNum = i + 1;
          const active = stepNum === step;
          const done = stepNum < step;
          return (
            <div key={label} className="flex flex-1 items-center gap-2">
              <div
                className={[
                  "flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-[12px] font-semibold",
                  done ? "bg-teal text-white" : active ? "bg-gold text-ink" : "bg-paper-dim text-ink-soft"
                ].join(" ")}
              >
                {done ? <CheckCircle2 size={15} /> : stepNum}
              </div>
              <span className={active ? "text-[12px] font-semibold text-ink" : "text-[12px] text-ink-soft"}>
                {label}
              </span>
              {stepNum < STEPS.length && <div className="h-px flex-1 bg-line" />}
            </div>
          );
        })}
      </div>

      <Card className="p-6">
        {step === 1 && (
          <div className="flex flex-col gap-4">
            <Input
              label="Course title"
              placeholder="e.g. Build a WhatsApp AI Auto-Responder"
              value={draft.title}
              onChange={(e) => wizard.updateDraft({ title: e.target.value })}
            />
            <Textarea
              label="Subtitle"
              placeholder="One sentence describing the outcome"
              value={draft.subtitle}
              onChange={(e) => wizard.updateDraft({ subtitle: e.target.value })}
            />
            <Select
              label="Category"
              placeholder="Select a category"
              options={CATEGORY_OPTIONS}
              value={draft.categoryId}
              onChange={(e) => wizard.updateDraft({ categoryId: e.target.value })}
            />
            <div className="grid grid-cols-2 gap-4">
              <Select
                label="Level"
                options={LEVEL_OPTIONS}
                value={draft.level}
                onChange={(e) => wizard.updateDraft({ level: e.target.value as typeof draft.level })}
              />
              <Select
                label="Language"
                options={LANGUAGE_OPTIONS}
                value={draft.language}
                onChange={(e) => wizard.updateDraft({ language: e.target.value })}
              />
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="flex flex-col gap-5">
            {draft.modules.length === 0 && (
              <p className="text-[13px] text-ink-soft">Add at least one module to continue.</p>
            )}
            {draft.modules.map((mod) => (
              <div key={mod.id} className="rounded-control border border-line p-4">
                <div className="mb-3 flex items-center gap-2">
                  <Input
                    value={mod.title}
                    onChange={(e) => wizard.updateModuleTitle(mod.id, e.target.value)}
                    className="flex-1"
                  />
                  <button
                    type="button"
                    onClick={() => wizard.removeModule(mod.id)}
                    className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
                  >
                    <Trash2 size={15} />
                  </button>
                </div>

                <div className="flex flex-col gap-2">
                  {mod.lessons.map((lesson) => {
                    const Icon = LESSON_TYPE_ICON[lesson.type];
                    return (
                      <div key={lesson.id} className="flex items-center gap-2">
                        <Icon size={15} className="shrink-0 text-ink-soft" />
                        <Input
                          value={lesson.title}
                          onChange={(e) => wizard.updateLessonTitle(mod.id, lesson.id, e.target.value)}
                          className="h-9 flex-1"
                        />
                        <button
                          type="button"
                          onClick={() => wizard.removeLesson(mod.id, lesson.id)}
                          className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
                        >
                          <Trash2 size={13} />
                        </button>
                      </div>
                    );
                  })}
                </div>

                <div className="mt-3 flex flex-wrap gap-2">
                  {(["video", "text", "quiz", "resource"] as const).map((type) => (
                    <button
                      key={type}
                      type="button"
                      onClick={() => wizard.addLesson(mod.id, type)}
                      className="flex items-center gap-1.5 rounded-full border border-line-strong px-3 py-1.5 text-[12px] font-medium text-ink-soft hover:border-ink hover:text-ink"
                    >
                      <Plus size={12} /> {type}
                    </button>
                  ))}
                </div>
              </div>
            ))}
            <Button variant="secondary" onClick={() => wizard.addModule()}>
              <Plus size={15} /> Add module
            </Button>
          </div>
        )}

        {step === 3 && (
          <div className="flex flex-col gap-4">
            <div className="grid grid-cols-2 gap-4">
              <Input
                label="Price"
                type="number"
                min={0}
                value={draft.price}
                onChange={(e) => wizard.updateDraft({ price: Number(e.target.value) })}
              />
              <Select
                label="Currency"
                options={CURRENCY_OPTIONS}
                value={draft.currency}
                onChange={(e) => wizard.updateDraft({ currency: e.target.value as typeof draft.currency })}
              />
            </div>
            <Checkbox
              label="Include this course in Saachi AI Pro subscription"
              checked={draft.subscriptionIncluded}
              onChange={(e) => wizard.updateDraft({ subscriptionIncluded: e.target.checked })}
            />
          </div>
        )}

        {step === 4 && (
          <div className="flex flex-col gap-4">
            <Input
              label="Thumbnail seed (demo)"
              placeholder="e.g. my-course-thumbnail"
              helperText="In demo mode this generates a placeholder image. Real upload wires to Media API later."
              value={draft.thumbnailSeed}
              onChange={(e) => wizard.updateDraft({ thumbnailSeed: e.target.value })}
            />
            {draft.thumbnailSeed && (
              <div className="aspect-video w-full max-w-[360px] overflow-hidden rounded-control bg-paper-dim">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={`https://picsum.photos/seed/${encodeURIComponent(draft.thumbnailSeed)}/800/450`}
                  alt="Course thumbnail preview"
                  className="h-full w-full object-cover"
                />
              </div>
            )}
          </div>
        )}

        {step === 5 && (
          <div className="flex flex-col gap-4">
            <h3 className="text-[16px] font-semibold text-ink">{draft.title || "Untitled course"}</h3>
            <p className="text-[14px] text-ink-soft">{draft.subtitle}</p>
            <div className="flex flex-wrap gap-2">
              <Badge>{draft.categoryId || "No category"}</Badge>
              <Badge>{draft.level}</Badge>
              <Badge>{draft.language === "en" ? "English" : "Urdu"}</Badge>
              <Badge variant="gold">
                {draft.currency} {draft.price}
              </Badge>
            </div>
            <p className="text-[13px] text-ink-soft">
              {draft.modules.length} modules, {draft.modules.reduce((s, m) => s + m.lessons.length, 0)} lessons
            </p>
          </div>
        )}
      </Card>

      <div className="mt-6 flex items-center justify-between">
        <Button
          variant="ghost"
          onClick={() => wizard.setStep(Math.max(1, step - 1))}
          disabled={step === 1}
        >
          Back
        </Button>

        {step < STEPS.length ? (
          <Button onClick={() => wizard.setStep(step + 1)} disabled={!canGoNext()}>
            Continue
          </Button>
        ) : (
          <div className="flex gap-3">
            <Button variant="secondary" onClick={() => handlePublish("draft")}>
              Save as draft
            </Button>
            <Button onClick={() => handlePublish("pending_review")}>Submit for review</Button>
          </div>
        )}
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\courses\new\page.tsx" -Content $courseWizardPage

# ---------------------------------------------------------------------------
# 7. Instructor Analytics (Recharts)
# ---------------------------------------------------------------------------
$instructorAnalytics = @'
"use client";

import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";
import { Card } from "@saachi/ui";

const ENROLLMENT_TREND = [
  { month: "Feb", enrollments: 40 },
  { month: "Mar", enrollments: 62 },
  { month: "Apr", enrollments: 58 },
  { month: "May", enrollments: 91 },
  { month: "Jun", enrollments: 120 },
  { month: "Jul", enrollments: 148 }
];

const REVENUE_TREND = [
  { month: "Feb", revenue: 620 },
  { month: "Mar", revenue: 980 },
  { month: "Apr", revenue: 890 },
  { month: "May", revenue: 1450 },
  { month: "Jun", revenue: 1980 },
  { month: "Jul", revenue: 2340 }
];

export default function InstructorAnalyticsPage() {
  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Analytics</h1>
        <p className="mt-1 text-[14px] text-ink-soft">
          Demo data - connects to the real Analytics/Enrollments API once the backend is live.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <Card className="p-6">
          <h2 className="mb-4 text-[15px] font-semibold text-ink">Enrollment trend</h2>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={ENROLLMENT_TREND}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" />
              <XAxis dataKey="month" stroke="var(--color-ink-soft)" fontSize={12} />
              <YAxis stroke="var(--color-ink-soft)" fontSize={12} />
              <Tooltip />
              <Line type="monotone" dataKey="enrollments" stroke="var(--color-teal)" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </Card>

        <Card className="p-6">
          <h2 className="mb-4 text-[15px] font-semibold text-ink">Revenue trend</h2>
          <ResponsiveContainer width="100%" height={240}>
            <LineChart data={REVENUE_TREND}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" />
              <XAxis dataKey="month" stroke="var(--color-ink-soft)" fontSize={12} />
              <YAxis stroke="var(--color-ink-soft)" fontSize={12} />
              <Tooltip />
              <Line type="monotone" dataKey="revenue" stroke="var(--color-gold-dark)" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </Card>
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\analytics\page.tsx" -Content $instructorAnalytics

# ---------------------------------------------------------------------------
# 8. Instructor Earnings & Payouts
# ---------------------------------------------------------------------------
$instructorEarnings = @'
"use client";

import { useState } from "react";
import { Wallet, Landmark } from "lucide-react";
import { Button, Card, Input, Select, Badge } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const PAYOUT_HISTORY = [
  { id: "po_1", amount: 420, date: "2026-06-01T00:00:00.000Z", status: "paid", method: "Bank Transfer" },
  { id: "po_2", amount: 610, date: "2026-05-01T00:00:00.000Z", status: "paid", method: "Easypaisa" },
  { id: "po_3", amount: 300, date: "2026-04-01T00:00:00.000Z", status: "paid", method: "Bank Transfer" }
];

export default function InstructorEarningsPage() {
  const [requested, setRequested] = useState(false);

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Earnings & Payouts</h1>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Available balance</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{formatCurrency(890, "USD")}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Lifetime earnings</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{formatCurrency(4620, "USD")}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Next payout</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">Aug 1</p>
        </Card>
      </div>

      <Card className="mb-8 p-6">
        <h2 className="mb-4 text-[16px] font-semibold text-ink">Request a payout</h2>
        {requested ? (
          <p className="text-[14px] text-teal">Payout request submitted (demo) - Finance will process within 3-5 days.</p>
        ) : (
          <div className="flex flex-col gap-4 sm:flex-row sm:items-end">
            <Input label="Amount" type="number" defaultValue={890} className="sm:w-[200px]" />
            <Select
              label="Payout method"
              options={[
                { label: "Bank Transfer", value: "bank_transfer" },
                { label: "Easypaisa", value: "easypaisa" },
                { label: "JazzCash", value: "jazzcash" }
              ]}
              defaultValue="bank_transfer"
              className="sm:w-[220px]"
            />
            <Button onClick={() => setRequested(true)}>
              <Wallet size={16} /> Request payout
            </Button>
          </div>
        )}
      </Card>

      <Card className="mb-8 p-6">
        <div className="flex items-center gap-3">
          <Landmark size={20} className="text-teal" />
          <div>
            <h2 className="text-[15px] font-semibold text-ink">Payout method</h2>
            <p className="text-[13px] text-ink-soft">Bank Transfer - HBL •••• 4821 (demo)</p>
          </div>
        </div>
      </Card>

      <h2 className="mb-4 text-[16px] font-semibold text-ink">Payout history</h2>
      <div className="flex flex-col gap-3">
        {PAYOUT_HISTORY.map((p) => (
          <Card key={p.id} className="flex items-center justify-between p-4">
            <div>
              <p className="text-[14px] font-semibold text-ink">{formatCurrency(p.amount, "USD")}</p>
              <p className="mt-1 text-[12px] text-ink-soft">
                {p.method} &middot; {formatDate(p.date)}
              </p>
            </div>
            <Badge variant="success">Paid</Badge>
          </Card>
        ))}
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\earnings\page.tsx" -Content $instructorEarnings

# ---------------------------------------------------------------------------
# 9. Instructor Reviews
# ---------------------------------------------------------------------------
$instructorReviews = @'
"use client";

import { ReviewCard } from "@saachi/ui";
import { DUMMY_COURSES } from "@saachi/api-client";

export default function InstructorReviewsPage() {
  const allReviews = DUMMY_COURSES.flatMap((c) =>
    (c.reviews ?? []).map((r) => ({ ...r, courseTitle: c.title }))
  );

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Reviews</h1>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        {allReviews.map((review) => (
          <div key={review.id}>
            <p className="mb-2 text-[12px] font-semibold uppercase tracking-[0.04em] text-gold-dark">
              {review.courseTitle}
            </p>
            <ReviewCard {...review} />
          </div>
        ))}
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\reviews\page.tsx" -Content $instructorReviews

# ---------------------------------------------------------------------------
# 10. Instructor Students
# ---------------------------------------------------------------------------
$instructorStudents = @'
"use client";

import { Card, Input, Badge } from "@saachi/ui";
import { Search } from "lucide-react";
import { useState } from "react";

const DEMO_STUDENTS = [
  { id: "std_1", name: "Bilal Ahmed", email: "bilal@example.com", course: "Prompt Engineering Fundamentals", progress: 80 },
  { id: "std_2", name: "Hina Malik", email: "hina@example.com", course: "Prompt Engineering Fundamentals", progress: 45 },
  { id: "std_3", name: "Omar Sheikh", email: "omar@example.com", course: "AI-Powered Marketing Campaigns", progress: 100 },
  { id: "std_4", name: "Fatima Noor", email: "fatima@example.com", course: "Automate Everything with n8n & AI", progress: 20 }
];

export default function InstructorStudentsPage() {
  const [search, setSearch] = useState("");

  const filtered = DEMO_STUDENTS.filter(
    (s) => s.name.toLowerCase().includes(search.toLowerCase()) || s.course.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <h1 className="mb-6 font-display text-[26px] font-semibold text-ink">Students</h1>

      <div className="relative mb-6 max-w-[360px]">
        <Search size={16} className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-ink-soft/60" />
        <Input placeholder="Search students or courses" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-10" />
      </div>

      <div className="flex flex-col gap-3">
        {filtered.map((s) => (
          <Card key={s.id} className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-[14px] font-semibold text-ink">{s.name}</p>
              <p className="text-[12px] text-ink-soft">{s.email}</p>
              <p className="mt-1 text-[12px] text-ink-soft">{s.course}</p>
            </div>
            <Badge variant={s.progress === 100 ? "success" : "default"}>{s.progress}% complete</Badge>
          </Card>
        ))}
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\students\page.tsx" -Content $instructorStudents

# ---------------------------------------------------------------------------
# 11. Instructor Settings
# ---------------------------------------------------------------------------
$instructorSettings = @'
"use client";

import { useState } from "react";
import { useSession } from "@saachi/api-client";
import { Button, Card, Input, Textarea } from "@saachi/ui";

export default function InstructorSettingsPage() {
  const { data: session } = useSession();
  const [bio, setBio] = useState("");
  const [portfolio, setPortfolio] = useState("");
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Instructor Settings</h1>

      <Card className="p-6">
        <form onSubmit={handleSave} className="flex flex-col gap-4">
          <Input label="Full name" defaultValue={session?.fullName ?? ""} />
          <Input label="Email" defaultValue={session?.email ?? ""} disabled />
          <Textarea
            label="Instructor bio"
            placeholder="Tell learners about your background and expertise..."
            value={bio}
            onChange={(e) => setBio(e.target.value)}
          />
          <Input
            label="Portfolio link"
            placeholder="https://github.com/you or LinkedIn"
            value={portfolio}
            onChange={(e) => setPortfolio(e.target.value)}
          />
          <div className="mt-2 flex items-center gap-3">
            <Button type="submit">Save changes</Button>
            {saved && <span className="text-[13px] text-teal">Saved</span>}
          </div>
        </form>
      </Card>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(instructor)\instructor\settings\page.tsx" -Content $instructorSettings

# ---------------------------------------------------------------------------
# 12. Navbar - "Become an Instructor" now routes properly for logged-in users
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(marketing)\_components\Navbar.tsx" `
  -OldStr '  { label: "Become an Instructor", href: "/register" },' `
  -NewStr '  { label: "Become an Instructor", href: "/instructor/dashboard" },' `
  -Label "Navbar instructor link"

Write-Host ""
Write-Host "Step 4 done." -ForegroundColor Green
Write-Host "Run: pnpm dev:web" -ForegroundColor Green
Write-Host "Test flow: log in -> go to /instructor/dashboard -> Create course (wizard) -> /instructor/courses -> /instructor/analytics -> /instructor/earnings -> /instructor/reviews -> /instructor/students -> /instructor/settings" -ForegroundColor Green