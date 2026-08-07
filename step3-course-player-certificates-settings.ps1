# step3-course-player-certificates-settings.ps1
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

Write-Host "Step 3: course player + certificates + notifications + settings..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Extend useEnrollmentStore with lesson-level progress tracking
# ---------------------------------------------------------------------------
$enrollmentStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type EnrollmentRecord = {
  courseId: string;
  slug: string;
  title: string;
  thumbnailUrl?: string;
  instructorName: string;
  progressPercent: number;
  purchasedAt: string;
  completedLessonIds: string[];
};

type EnrollmentState = {
  enrollments: EnrollmentRecord[];
  isEnrolled: (courseId: string) => boolean;
  enroll: (records: Omit<EnrollmentRecord, "progressPercent" | "purchasedAt" | "completedLessonIds">[]) => void;
  markLessonComplete: (courseId: string, lessonId: string, totalLessons: number) => void;
  getEnrollment: (courseId: string) => EnrollmentRecord | undefined;
};

export const useEnrollmentStore = create<EnrollmentState>()(
  persist(
    (set, get) => ({
      enrollments: [],

      isEnrolled: (courseId) => get().enrollments.some((e) => e.courseId === courseId),

      getEnrollment: (courseId) => get().enrollments.find((e) => e.courseId === courseId),

      enroll: (records) => {
        const now = new Date().toISOString();
        const existingIds = new Set(get().enrollments.map((e) => e.courseId));
        const fresh = records
          .filter((r) => !existingIds.has(r.courseId))
          .map((r) => ({ ...r, progressPercent: 0, purchasedAt: now, completedLessonIds: [] as string[] }));
        if (fresh.length === 0) return;
        set({ enrollments: [...get().enrollments, ...fresh] });
      },

      markLessonComplete: (courseId, lessonId, totalLessons) => {
        set({
          enrollments: get().enrollments.map((e) => {
            if (e.courseId !== courseId) return e;
            const completedLessonIds = e.completedLessonIds.includes(lessonId)
              ? e.completedLessonIds
              : [...e.completedLessonIds, lessonId];
            const progressPercent =
              totalLessons > 0 ? Math.round((completedLessonIds.length / totalLessons) * 100) : 0;
            return { ...e, completedLessonIds, progressPercent };
          })
        });
      }
    }),
    { name: "saachi-enrollments" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useEnrollmentStore.ts" -Content $enrollmentStore

# ---------------------------------------------------------------------------
# 2. My Courses - wire Continue/Start button to the real player route
# ---------------------------------------------------------------------------
$myCoursesPage = @'
"use client";

import Link from "next/link";
import { BookOpen } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { useCourseDetail } from "@saachi/api-client";
import { Button, Card, EmptyState } from "@saachi/ui";

function ContinueButton({ courseId, slug }: { courseId: string; slug: string }) {
  const { data: course } = useCourseDetail(slug);
  const firstLessonId = course?.curriculum?.[0]?.lessons?.[0]?.id;

  if (!firstLessonId) {
    return (
      <Button size="sm" variant="secondary" className="shrink-0" disabled>
        Loading...
      </Button>
    );
  }

  return (
    <Link href={`/learn/${courseId}/${firstLessonId}`}>
      <Button size="sm" variant="secondary" className="shrink-0">
        Continue
      </Button>
    </Link>
  );
}

export default function MyCoursesPage() {
  const { enrollments } = useEnrollmentStore();

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">My Courses</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Everything you're enrolled in, in one place.</p>
      </div>

      {enrollments.length === 0 ? (
        <EmptyState
          icon={<BookOpen size={22} />}
          title="No courses yet"
          description="Once you purchase a course, it will show up here with your progress."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-4">
          {enrollments.map((course) => (
            <Card key={course.courseId} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center">
              <Link href={`/courses/${course.slug}`} className="block h-[90px] w-[160px] shrink-0 overflow-hidden rounded-control bg-paper-dim">
                {course.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.thumbnailUrl} alt={course.title} className="h-full w-full object-cover" />
                )}
              </Link>
              <div className="flex-1">
                <Link href={`/courses/${course.slug}`} className="text-[15px] font-semibold text-ink hover:text-gold-dark">
                  {course.title}
                </Link>
                <p className="mt-1 text-[13px] text-ink-soft">{course.instructorName}</p>
                <div className="mt-3 flex items-center gap-3">
                  <div className="h-2 w-full max-w-[220px] overflow-hidden rounded-full bg-paper-dim">
                    <div
                      className="h-full rounded-full bg-gold"
                      style={{ width: `${course.progressPercent}%` }}
                    />
                  </div>
                  <span className="shrink-0 text-[12px] text-ink-soft">{course.progressPercent}% complete</span>
                </div>
              </div>
              {course.progressPercent >= 100 ? (
                <Link href="/certificates">
                  <Button size="sm" variant="secondary" className="shrink-0">
                    View certificate
                  </Button>
                </Link>
              ) : (
                <ContinueButton courseId={course.courseId} slug={course.slug} />
              )}
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\my-courses\page.tsx" -Content $myCoursesPage

# ---------------------------------------------------------------------------
# 3. Course Player page
# ---------------------------------------------------------------------------
$coursePlayerPage = @'
"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useMemo } from "react";
import {
  PlayCircle,
  FileText,
  HelpCircle,
  Download,
  CheckCircle2,
  Circle,
  ChevronLeft,
  ChevronRight,
  ArrowLeft
} from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState, SkeletonText } from "@saachi/ui";

const LESSON_ICONS = {
  video: PlayCircle,
  text: FileText,
  quiz: HelpCircle,
  resource: Download
} as const;

export default function CoursePlayerPage({
  params
}: {
  params: { courseId: string; lessonId: string };
}) {
  const router = useRouter();
  const { data: course, isLoading } = useCourseDetail(params.courseId);
  const enrollmentStore = useEnrollmentStore();
  const enrollment = enrollmentStore.getEnrollment(params.courseId);

  const flatLessons = useMemo(() => {
    if (!course?.curriculum) return [];
    return course.curriculum.flatMap((mod) =>
      mod.lessons.map((lesson) => ({ ...lesson, moduleTitle: mod.title }))
    );
  }, [course]);

  const currentIndex = flatLessons.findIndex((l) => l.id === params.lessonId);
  const currentLesson = flatLessons[currentIndex];
  const prevLesson = currentIndex > 0 ? flatLessons[currentIndex - 1] : null;
  const nextLesson = currentIndex >= 0 && currentIndex < flatLessons.length - 1 ? flatLessons[currentIndex + 1] : null;

  const isComplete = enrollment?.completedLessonIds.includes(params.lessonId) ?? false;

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[1140px] px-6 py-16">
        <SkeletonText lines={4} />
      </main>
    );
  }

  if (!course || !currentLesson) {
    return (
      <main className="mx-auto max-w-[1140px] px-6 py-16">
        <EmptyState
          title="Lesson not found"
          description="This lesson may not exist for this course."
          action={
            <Link href="/my-courses">
              <Button>Back to My Courses</Button>
            </Link>
          }
        />
      </main>
    );
  }

  const handleMarkComplete = () => {
    enrollmentStore.markLessonComplete(params.courseId, params.lessonId, flatLessons.length);
    if (nextLesson) {
      router.push(`/learn/${params.courseId}/${nextLesson.id}`);
    }
  };

  return (
    <div className="min-h-screen bg-paper">
      <header className="flex items-center justify-between border-b border-line bg-card px-6 py-3">
        <Link href="/my-courses" className="flex items-center gap-2 text-[13px] font-medium text-ink-soft hover:text-ink">
          <ArrowLeft size={16} /> My Courses
        </Link>
        <h1 className="line-clamp-1 text-[14px] font-semibold text-ink">{course.title}</h1>
        <span className="text-[12px] text-ink-soft">
          Lesson {currentIndex + 1} of {flatLessons.length}
        </span>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-[1fr_320px]">
        <div className="px-6 py-8 md:px-10">
          <div className="mx-auto max-w-[820px]">
            <div className="mb-6 aspect-video w-full overflow-hidden rounded-card bg-ink">
              {currentLesson.type === "video" ? (
                <div className="flex h-full w-full items-center justify-center text-white/60">
                  <PlayCircle size={56} />
                </div>
              ) : currentLesson.type === "quiz" ? (
                <div className="flex h-full w-full flex-col items-center justify-center gap-2 text-white/80">
                  <HelpCircle size={40} />
                  <span className="text-[14px]">Quiz content - demo placeholder</span>
                </div>
              ) : (
                <div className="flex h-full w-full flex-col items-center justify-center gap-2 text-white/80">
                  <FileText size={40} />
                  <span className="text-[14px]">Text/resource lesson - demo placeholder</span>
                </div>
              )}
            </div>

            <p className="mb-1 text-[12px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
              {currentLesson.moduleTitle}
            </p>
            <h2 className="font-display text-[24px] font-semibold text-ink">{currentLesson.title}</h2>
            <p className="mt-3 text-[14px] leading-relaxed text-ink-soft">
              This is demo lesson content. Once the backend and video CDN (Doc 3) are wired up,
              real video playback, transcripts, and downloadable resources will render here.
            </p>

            <div className="mt-8 flex items-center justify-between border-t border-line pt-6">
              <Button
                variant="ghost"
                onClick={() => prevLesson && router.push(`/learn/${params.courseId}/${prevLesson.id}`)}
                disabled={!prevLesson}
              >
                <ChevronLeft size={16} /> Previous
              </Button>

              {isComplete ? (
                <Button variant="secondary" disabled>
                  <CheckCircle2 size={16} className="text-teal" /> Completed
                </Button>
              ) : (
                <Button onClick={handleMarkComplete}>Mark complete & continue</Button>
              )}

              <Button
                variant="ghost"
                onClick={() => nextLesson && router.push(`/learn/${params.courseId}/${nextLesson.id}`)}
                disabled={!nextLesson}
              >
                Next <ChevronRight size={16} />
              </Button>
            </div>
          </div>
        </div>

        <aside className="border-t border-line bg-card lg:border-l lg:border-t-0">
          <div className="max-h-[calc(100vh-56px)] overflow-y-auto p-4">
            {course.curriculum?.map((mod) => (
              <div key={mod.id} className="mb-4">
                <h3 className="mb-2 px-2 text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/70">
                  {mod.title}
                </h3>
                <div className="flex flex-col gap-1">
                  {mod.lessons.map((lesson) => {
                    const Icon = LESSON_ICONS[lesson.type];
                    const done = enrollment?.completedLessonIds.includes(lesson.id) ?? false;
                    const active = lesson.id === params.lessonId;
                    return (
                      <Link
                        key={lesson.id}
                        href={`/learn/${params.courseId}/${lesson.id}`}
                        className={[
                          "flex items-center gap-2.5 rounded-control px-3 py-2.5 text-[13px] transition-colors duration-150 ease-out",
                          active ? "bg-gold-tint text-ink font-semibold" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                        ].join(" ")}
                      >
                        {done ? (
                          <CheckCircle2 size={15} className="shrink-0 text-teal" />
                        ) : (
                          <Circle size={15} className="shrink-0 text-line-strong" />
                        )}
                        <Icon size={14} className="shrink-0" />
                        <span className="line-clamp-1">{lesson.title}</span>
                      </Link>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        </aside>
      </div>
    </div>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\learn\[courseId]\[lessonId]\page.tsx" -Content $coursePlayerPage

# ---------------------------------------------------------------------------
# 4. Course Player needs a bare layout (no learner sidebar - full width player)
# ---------------------------------------------------------------------------
$learnLayout = @'
import type { ReactNode } from "react";

export default function LearnLayout({ children }: { children: ReactNode }) {
  return <>{children}</>;
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\learn\layout.tsx" -Content $learnLayout

# ---------------------------------------------------------------------------
# 5. Certificates page
# ---------------------------------------------------------------------------
$certificatesPage = @'
"use client";

import Link from "next/link";
import { Award, Download, ShieldCheck } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { useSession } from "@saachi/api-client";
import { Button, Card, EmptyState } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

function verificationId(courseId: string) {
  return `SAACHI-${courseId.toUpperCase().replace("CRS_", "")}-DEMO`;
}

export default function CertificatesPage() {
  const { enrollments } = useEnrollmentStore();
  const { data: session } = useSession();

  const completed = enrollments.filter((e) => e.progressPercent >= 100);

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Certificates</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Courses you've fully completed.</p>
      </div>

      {completed.length === 0 ? (
        <EmptyState
          icon={<Award size={22} />}
          title="No certificates yet"
          description="Complete every lesson in a course to earn your certificate."
          action={
            <Link href="/my-courses">
              <Button>Go to My Courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
          {completed.map((course) => (
            <Card key={course.courseId} className="flex flex-col gap-4 border-2 border-ink bg-gold-tint p-6">
              <div className="flex items-center justify-between">
                <Award size={28} className="text-gold-dark" />
                <span className="text-[11px] font-semibold uppercase tracking-[0.05em] text-ink-soft">
                  Certificate of Completion
                </span>
              </div>
              <div>
                <h3 className="font-display text-[18px] font-semibold text-ink">{course.title}</h3>
                <p className="mt-1 text-[13px] text-ink-soft">Awarded to {session?.fullName ?? "Learner"}</p>
                <p className="mt-1 text-[12px] text-ink-soft/70">
                  Completed {formatDate(course.purchasedAt)}
                </p>
              </div>
              <div className="flex items-center gap-1.5 text-[11px] text-ink-soft">
                <ShieldCheck size={13} /> Verification ID: {verificationId(course.courseId)}
              </div>
              <Button size="sm" variant="secondary" className="mt-2 w-fit">
                <Download size={15} /> Download (demo)
              </Button>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\certificates\page.tsx" -Content $certificatesPage

# ---------------------------------------------------------------------------
# 6. Notifications page (dummy notifications, local read/unread state)
# ---------------------------------------------------------------------------
$notificationsStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type NotificationItem = {
  id: string;
  title: string;
  body: string;
  createdAt: string;
  read: boolean;
  type: "course" | "system" | "community" | "payment";
};

const SEED_NOTIFICATIONS: NotificationItem[] = [
  {
    id: "ntf_1",
    title: "Welcome to Saachi AI",
    body: "Your account is ready. Explore practical AI courses to get started.",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString(),
    read: false,
    type: "system"
  },
  {
    id: "ntf_2",
    title: "New reply in Prompt Engineering Fundamentals",
    body: "An instructor answered your question in the course Q&A.",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 26).toISOString(),
    read: false,
    type: "community"
  },
  {
    id: "ntf_3",
    title: "Course completed",
    body: "You finished all lessons in a course. Your certificate is ready.",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 72).toISOString(),
    read: true,
    type: "course"
  }
];

type NotificationState = {
  items: NotificationItem[];
  markAllRead: () => void;
  markRead: (id: string) => void;
};

export const useNotificationStore = create<NotificationState>()(
  persist(
    (set, get) => ({
      items: SEED_NOTIFICATIONS,
      markAllRead: () => set({ items: get().items.map((n) => ({ ...n, read: true })) }),
      markRead: (id) =>
        set({ items: get().items.map((n) => (n.id === id ? { ...n, read: true } : n)) })
    }),
    { name: "saachi-notifications" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useNotificationStore.ts" -Content $notificationsStore

$storeIndexUpdated = @'
export * from "./useCartStore";
export * from "./useWishlistStore";
export * from "./useEnrollmentStore";
export * from "./useNotificationStore";
'@
Write-Utf8NoBom -Path "packages\store\src\index.ts" -Content $storeIndexUpdated

$notificationsPage = @'
"use client";

import { Bell, BookOpen, MessageSquare, CreditCard, Info } from "lucide-react";
import { useNotificationStore } from "@saachi/store";
import { Button, Card, EmptyState, Badge } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const TYPE_ICON = {
  course: BookOpen,
  system: Info,
  community: MessageSquare,
  payment: CreditCard
} as const;

export default function NotificationsPage() {
  const { items, markAllRead, markRead } = useNotificationStore();
  const unreadCount = items.filter((n) => !n.read).length;

  return (
    <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="font-display text-[26px] font-semibold text-ink">Notifications</h1>
          <p className="mt-1 text-[14px] text-ink-soft">
            {unreadCount > 0 ? `${unreadCount} unread` : "You're all caught up"}
          </p>
        </div>
        {unreadCount > 0 && (
          <Button size="sm" variant="secondary" onClick={markAllRead}>
            Mark all as read
          </Button>
        )}
      </div>

      {items.length === 0 ? (
        <EmptyState icon={<Bell size={22} />} title="No notifications" description="Nothing here yet." />
      ) : (
        <div className="flex flex-col gap-3">
          {items.map((n) => {
            const Icon = TYPE_ICON[n.type];
            return (
              <Card
                key={n.id}
                onClick={() => markRead(n.id)}
                className={[
                  "flex cursor-pointer items-start gap-4 p-4",
                  !n.read ? "border-gold-dark/40 bg-gold-tint/40" : ""
                ].join(" ")}
              >
                <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-teal-light text-teal">
                  <Icon size={16} />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <h3 className="text-[14px] font-semibold text-ink">{n.title}</h3>
                    {!n.read && <Badge variant="gold">New</Badge>}
                  </div>
                  <p className="mt-1 text-[13px] text-ink-soft">{n.body}</p>
                  <p className="mt-2 text-[12px] text-ink-soft/60">{formatRelativeTime(n.createdAt)}</p>
                </div>
              </Card>
            );
          })}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\notifications\page.tsx" -Content $notificationsPage

# ---------------------------------------------------------------------------
# 7. Settings - Profile page
# ---------------------------------------------------------------------------
$settingsProfilePage = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { useSession } from "@saachi/api-client";
import { Button, Card, Input, Textarea } from "@saachi/ui";

const SETTINGS_TABS = [
  { label: "Profile", href: "/settings/profile" },
  { label: "Security", href: "/settings/security" }
];

export default function SettingsProfilePage() {
  const { data: session } = useSession();
  const [fullName, setFullName] = useState(session?.fullName ?? "");
  const [bio, setBio] = useState("");
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    // NOTE: demo-only, local state. Replace with Users API PATCH once backend exists.
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <h1 className="mb-6 font-display text-[26px] font-semibold text-ink">Settings</h1>

      <div className="mb-8 flex gap-2 border-b border-line">
        {SETTINGS_TABS.map((tab) => (
          <Link
            key={tab.href}
            href={tab.href}
            className="border-b-2 border-ink px-1 pb-3 text-[14px] font-semibold text-ink"
          >
            {tab.label}
          </Link>
        ))}
      </div>

      <Card className="p-6">
        <div className="mb-6 flex items-center gap-4">
          <div className="flex h-16 w-16 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[20px] font-semibold text-teal">
            {session?.avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={session.avatarUrl} alt={session.fullName} className="h-full w-full object-cover" />
            ) : (
              session?.fullName?.charAt(0) ?? "?"
            )}
          </div>
          <div>
            <p className="text-[14px] font-semibold text-ink">Profile photo</p>
            <p className="text-[12px] text-ink-soft">Demo avatar - upload not wired to a backend yet.</p>
          </div>
        </div>

        <form onSubmit={handleSave} className="flex flex-col gap-4">
          <Input label="Full name" value={fullName} onChange={(e) => setFullName(e.target.value)} />
          <Input label="Email" value={session?.email ?? ""} disabled />
          <Textarea
            label="Bio"
            placeholder="Tell us a bit about yourself..."
            value={bio}
            onChange={(e) => setBio(e.target.value)}
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
Write-Utf8NoBom -Path "apps\web\app\(learner)\settings\profile\page.tsx" -Content $settingsProfilePage

# ---------------------------------------------------------------------------
# 8. Settings - Security page
# ---------------------------------------------------------------------------
$settingsSecurityPage = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { ShieldCheck } from "lucide-react";
import { Button, Card, Input } from "@saachi/ui";

const SETTINGS_TABS = [
  { label: "Profile", href: "/settings/profile" },
  { label: "Security", href: "/settings/security" }
];

export default function SettingsSecurityPage() {
  const [saved, setSaved] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    // NOTE: demo-only. Replace with real Auth/Users API call once backend exists.
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
      <h1 className="mb-6 font-display text-[26px] font-semibold text-ink">Settings</h1>

      <div className="mb-8 flex gap-6 border-b border-line">
        {SETTINGS_TABS.map((tab) => (
          <Link
            key={tab.href}
            href={tab.href}
            className={
              tab.label === "Security"
                ? "border-b-2 border-ink px-1 pb-3 text-[14px] font-semibold text-ink"
                : "px-1 pb-3 text-[14px] font-medium text-ink-soft hover:text-ink"
            }
          >
            {tab.label}
          </Link>
        ))}
      </div>

      <Card className="mb-6 p-6">
        <h2 className="mb-4 text-[16px] font-semibold text-ink">Change password</h2>
        <form onSubmit={handleSave} className="flex flex-col gap-4">
          <Input label="Current password" type="password" placeholder="********" />
          <Input label="New password" type="password" placeholder="At least 8 characters" />
          <Input label="Confirm new password" type="password" placeholder="Repeat new password" />
          <div className="mt-2 flex items-center gap-3">
            <Button type="submit">Update password</Button>
            {saved && <span className="text-[13px] text-teal">Saved</span>}
          </div>
        </form>
      </Card>

      <Card className="p-6">
        <div className="flex items-center gap-3">
          <ShieldCheck size={20} className="text-teal" />
          <div>
            <h2 className="text-[15px] font-semibold text-ink">Two-factor authentication</h2>
            <p className="text-[13px] text-ink-soft">Not enabled - available once the backend auth flow is live.</p>
          </div>
        </div>
      </Card>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\settings\security\page.tsx" -Content $settingsSecurityPage

# ---------------------------------------------------------------------------
# 9. LearnerShell - add a Cart badge with live item count
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(learner)\_components\LearnerShell.tsx" `
  -OldStr 'import { useSession, useLogout } from "@saachi/api-client";' `
  -NewStr @'
import { useSession, useLogout } from "@saachi/api-client";
import { useCartStore } from "@saachi/store";
'@ `
  -Label "import useCartStore in LearnerShell"

Patch-File -Path "apps\web\app\(learner)\_components\LearnerShell.tsx" `
  -OldStr 'export function LearnerShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const [mobileOpen, setMobileOpen] = useState(false);' `
  -NewStr @'
export function LearnerShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const cartCount = useCartStore((s) => s.items.length);
  const [mobileOpen, setMobileOpen] = useState(false);
'@ `
  -Label "read cart count in LearnerShell"

Patch-File -Path "apps\web\app\(learner)\_components\LearnerShell.tsx" `
  -OldStr '              <item.icon size={18} />
              {item.label}
            </Link>' `
  -NewStr @'
              <item.icon size={18} />
              {item.label}
              {item.href === "/cart" && cartCount > 0 && (
                <span className="ml-auto flex h-5 min-w-[20px] items-center justify-center rounded-full bg-gold px-1.5 text-[11px] font-bold text-ink">
                  {cartCount}
                </span>
              )}
            </Link>
'@ `
  -Label "cart badge in sidebar nav"

Write-Host ""
Write-Host "Step 3 done." -ForegroundColor Green
Write-Host "Run: pnpm dev:web" -ForegroundColor Green
Write-Host "Test flow: buy a course (Step 2 flow) -> /my-courses -> Continue -> complete all lessons -> /certificates -> /notifications -> /settings/profile -> /settings/security" -ForegroundColor Green