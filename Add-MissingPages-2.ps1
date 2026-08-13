<#
  Add-MissingPages-2.ps1
  Run this from the SAI2 root:
  PS D:\...\SAI2> .\Add-MissingPages-2.ps1

  Adds:
  1. Stub hooks in @saachi/api-client (useCourseDetail, useInstructorProfile,
     useCertificateDetail) so the 4 pages from the previous script stop crashing.
  2. Course Player            -> /learn/[courseId]/[lessonId]
  3. Course Q&A / Community   -> /community/[courseId]
  4. Instructor lesson editors -> video / text / quiz
  5. Instructor Payouts pages  -> /instructor/payouts, /instructor/payouts/methods

  Only creates files that don't already exist. Never overwrites.
#>

$ErrorActionPreference = "Stop"

function New-PageIfMissing {
    param(
        [string]$RelativePath,
        [string]$Content
    )

    $fullPath = Join-Path $PWD $RelativePath

    if (Test-Path $fullPath) {
        Write-Host "SKIP (already exists): $RelativePath" -ForegroundColor Yellow
        return
    }

    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $utf8NoBom)
    Write-Host "CREATED: $RelativePath" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 1. Stub hooks: useCourseDetail, useInstructorProfile, useCertificateDetail
# ---------------------------------------------------------------------------
$stubHooksFile = 'packages\api-client\src\hooks\useCourseDetailStubs.ts'

$stubHooksContent = @'
// Stub hooks - frontend-only placeholders so pages relying on these hooks
// render without crashing before the real backend + typed API client exist.
// Replace the dummy data below with real network calls once the NestJS
// backend (Doc 3) and OpenAPI-generated client are ready.

import { useQuery } from "@tanstack/react-query";

// ---- Types (self-contained; align with real API types once backend lands) ----

export type CourseModuleLesson = { id: string; title: string };
export type CourseModule = { id: string; title: string; lessons: CourseModuleLesson[] };
export type CourseReview = { id: string; authorName: string; rating: number; comment: string };

export type CourseDetail = {
  id: string;
  slug: string;
  title: string;
  subtitle?: string;
  categoryName?: string;
  level: string;
  language: string;
  durationMinutes?: number;
  rating?: number;
  ratingCount?: number;
  price: number;
  currency: string;
  thumbnailUrl?: string;
  instructor: { slug: string; fullName: string; bio?: string };
  modules?: CourseModule[];
  reviews?: CourseReview[];
};

export type InstructorProfile = {
  slug: string;
  fullName: string;
  headline?: string;
  bio?: string;
  avatarUrl?: string;
  averageRating?: number;
  studentCount?: number;
  courseCount?: number;
  courses?: {
    id: string;
    slug: string;
    title: string;
    thumbnailUrl?: string;
    price: number;
    currency: string;
    rating?: number;
    ratingCount?: number;
  }[];
  reviews?: CourseReview[];
};

export type CertificateDetail = {
  id: string;
  verificationId: string;
  courseTitle: string;
  learnerName: string;
  instructorName: string;
  issuedAt: string;
};

// ---- Dummy data (demo-only, no backend wired up yet) ----

function buildDummyCourse(slug: string): CourseDetail {
  return {
    id: `course_${slug}`,
    slug,
    title: "AI Automation with n8n",
    subtitle: "Build end-to-end automations connecting AI models into no-code workflows.",
    categoryName: "AI Automation & Workflow Tools",
    level: "Intermediate",
    language: "en",
    durationMinutes: 420,
    rating: 4.7,
    ratingCount: 128,
    price: 49,
    currency: "USD",
    thumbnailUrl: "https://picsum.photos/seed/" + slug + "/800/450",
    instructor: {
      slug: "ayesha-khan",
      fullName: "Ayesha Khan",
      bio: "AI automation consultant with 6+ years building workflow systems for startups and agencies."
    },
    modules: [
      {
        id: "m1",
        title: "Getting started with n8n",
        lessons: [
          { id: "l1", title: "Installing and setting up n8n" },
          { id: "l2", title: "Your first workflow" }
        ]
      },
      {
        id: "m2",
        title: "Connecting AI models",
        lessons: [
          { id: "l3", title: "Calling the OpenAI API from n8n" },
          { id: "l4", title: "Building a WhatsApp AI auto-responder" }
        ]
      }
    ],
    reviews: [
      { id: "r1", authorName: "Bilal S.", rating: 5, comment: "Very practical, loved it." },
      { id: "r2", authorName: "Fatima R.", rating: 4, comment: "Good pacing, clear examples." }
    ]
  };
}

function buildDummyInstructor(slug: string): InstructorProfile {
  return {
    slug,
    fullName: "Ayesha Khan",
    headline: "AI Automation & Workflow Tools instructor",
    bio: "AI automation consultant with 6+ years building workflow systems for startups and agencies.",
    averageRating: 4.7,
    studentCount: 1240,
    courseCount: 3,
    courses: [
      {
        id: "course_1",
        slug: "ai-automation-with-n8n",
        title: "AI Automation with n8n",
        thumbnailUrl: "https://picsum.photos/seed/n8n/600/340",
        price: 49,
        currency: "USD",
        rating: 4.7,
        ratingCount: 128
      }
    ],
    reviews: [{ id: "r1", authorName: "Bilal S.", rating: 5, comment: "Clear, practical teaching style." }]
  };
}

function buildDummyCertificate(id: string): CertificateDetail {
  return {
    id,
    verificationId: `SAI-${id.toUpperCase()}`,
    courseTitle: "AI Automation with n8n",
    learnerName: "Learner Name",
    instructorName: "Ayesha Khan",
    issuedAt: new Date().toISOString()
  };
}

// ---- Hooks ----

export function useCourseDetail(slug: string) {
  return useQuery({
    queryKey: ["course-detail", slug],
    queryFn: async () => buildDummyCourse(slug),
    enabled: Boolean(slug)
  });
}

export function useInstructorProfile(slug: string) {
  return useQuery({
    queryKey: ["instructor-profile", slug],
    queryFn: async () => buildDummyInstructor(slug),
    enabled: Boolean(slug)
  });
}

export function useCertificateDetail(id: string) {
  return useQuery({
    queryKey: ["certificate-detail", id],
    queryFn: async () => buildDummyCertificate(id),
    enabled: Boolean(id)
  });
}
'@

New-PageIfMissing -RelativePath $stubHooksFile -Content $stubHooksContent

# Wire the new hooks into the package's public export, but only if not already exported.
$indexPath = Join-Path $PWD 'packages\api-client\src\index.ts'
if (Test-Path $indexPath) {
    $indexContent = Get-Content $indexPath -Raw
    if ($indexContent -notmatch "useCourseDetailStubs") {
        Add-Content -Path $indexPath -Value "`nexport * from `"./hooks/useCourseDetailStubs`";"
        Write-Host "APPENDED export to packages\api-client\src\index.ts" -ForegroundColor Green
    } else {
        Write-Host "SKIP (already exported): useCourseDetailStubs in index.ts" -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: packages\api-client\src\index.ts not found - export the stub hooks manually." -ForegroundColor Red
}

# ---------------------------------------------------------------------------
# 2. Course Player -> /learn/[courseId]/[lessonId]
# ---------------------------------------------------------------------------
$coursePlayer = @'
"use client";

import { useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { PlayCircle, CheckCircle2, ChevronLeft, ChevronRight, FileText, Download, Menu, X } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState, cn } from "@saachi/ui";

type LessonType = "video" | "text" | "quiz" | "resource";
type Lesson = { id: string; title: string; type: LessonType; durationMinutes?: number };
type CourseModule = { id: string; title: string; lessons: Lesson[] };

// NOTE: demo-only dummy curriculum. Replace with useCourseCurriculum(courseId)
// once the backend curriculum endpoint and typed hook are available.
const DEMO_MODULES: CourseModule[] = [
  {
    id: "m1",
    title: "Getting started with n8n",
    lessons: [
      { id: "l1", title: "Installing and setting up n8n", type: "video", durationMinutes: 8 },
      { id: "l2", title: "Your first workflow", type: "video", durationMinutes: 12 },
      { id: "l3", title: "Key concepts recap", type: "text" }
    ]
  },
  {
    id: "m2",
    title: "Connecting AI models",
    lessons: [
      { id: "l4", title: "Calling the OpenAI API from n8n", type: "video", durationMinutes: 15 },
      { id: "l5", title: "Building a WhatsApp AI auto-responder", type: "video", durationMinutes: 20 },
      { id: "l6", title: "Module quiz", type: "quiz" }
    ]
  }
];

function flattenLessons(modules: CourseModule[]): Lesson[] {
  return modules.flatMap((m) => m.lessons);
}

export default function CoursePlayerPage() {
  const params = useParams<{ courseId: string; lessonId: string }>();
  const router = useRouter();
  const enrollments = useEnrollmentStore((s) => s.enrollments);
  const updateProgress = useEnrollmentStore((s) => s.updateProgress);

  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [completedIds, setCompletedIds] = useState<Set<string>>(new Set());

  const enrollment = useMemo(
    () => enrollments.find((e) => e.courseId === params.courseId),
    [enrollments, params.courseId]
  );

  const allLessons = useMemo(() => flattenLessons(DEMO_MODULES), []);
  const currentIndex = allLessons.findIndex((l) => l.id === params.lessonId);
  const currentLesson = currentIndex >= 0 ? allLessons[currentIndex] : allLessons[0];
  const nextLesson = allLessons[currentIndex + 1];
  const prevLesson = allLessons[currentIndex - 1];

  if (!enrollment) {
    return (
      <div className="mx-auto max-w-3xl px-4 py-16">
        <EmptyState
          title="Not enrolled in this course"
          description="You need to purchase this course before accessing the lessons."
          action={
            <Link href="/my-courses">
              <Button>Back to my courses</Button>
            </Link>
          }
        />
      </div>
    );
  }

  function handleMarkComplete() {
    setCompletedIds((prev) => new Set(prev).add(currentLesson.id));
    const pct = Math.round(((completedIds.size + 1) / allLessons.length) * 100);
    if (enrollment && updateProgress) {
      updateProgress(enrollment.courseId, Math.min(100, pct));
    }
    if (nextLesson) {
      router.push(`/learn/${params.courseId}/${nextLesson.id}`);
    }
  }

  return (
    <div className="fixed inset-0 flex flex-col bg-paper">
      {/* Top bar */}
      <div className="flex h-14 shrink-0 items-center justify-between border-b border-line bg-card px-4">
        <div className="flex items-center gap-3 overflow-hidden">
          <button
            type="button"
            onClick={() => setSidebarOpen((v) => !v)}
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
            aria-label="Toggle lesson list"
          >
            {sidebarOpen ? <X size={18} /> : <Menu size={18} />}
          </button>
          <Link href="/my-courses" className="truncate text-[14px] font-semibold text-ink hover:underline">
            {enrollment.title}
          </Link>
        </div>
        <span className="shrink-0 text-[13px] text-ink-soft">{enrollment.progressPercent}% complete</span>
      </div>

      <div className="flex flex-1 overflow-hidden">
        {/* Main content */}
        <div className="flex flex-1 flex-col overflow-y-auto">
          <div className="mx-auto w-full max-w-4xl px-4 py-8">
            {currentLesson.type === "video" && (
              <div className="mb-6 flex aspect-video w-full items-center justify-center rounded-card border border-line bg-ink text-paper">
                <PlayCircle size={56} strokeWidth={1.25} />
              </div>
            )}

            {currentLesson.type === "text" && (
              <div className="mb-6 flex min-h-[200px] items-start gap-3 rounded-card border border-line bg-card p-6">
                <FileText size={18} className="mt-0.5 shrink-0 text-ink-soft" />
                <p className="text-[14px] leading-relaxed text-ink-soft">
                  Lesson text content will render here once the rich-text lesson content API is wired up.
                </p>
              </div>
            )}

            {currentLesson.type === "quiz" && (
              <div className="mb-6 rounded-card border border-line bg-card p-6">
                <p className="text-[14px] text-ink-soft">
                  Quiz interface will render here once the quiz builder + submission API is wired up.
                </p>
              </div>
            )}

            <h1 className="mb-2 font-display text-[22px] font-bold text-ink">{currentLesson.title}</h1>
            {currentLesson.durationMinutes && (
              <p className="mb-6 text-[13px] text-ink-soft">{currentLesson.durationMinutes} min</p>
            )}

            <div className="flex items-center justify-between border-t border-line pt-6">
              <Button
                variant="secondary"
                disabled={!prevLesson}
                onClick={() => prevLesson && router.push(`/learn/${params.courseId}/${prevLesson.id}`)}
              >
                <ChevronLeft size={15} className="mr-1" />
                Previous
              </Button>

              <Button onClick={handleMarkComplete}>
                {completedIds.has(currentLesson.id) ? "Completed" : "Mark complete & continue"}
                {nextLesson && <ChevronRight size={15} className="ml-1" />}
              </Button>
            </div>
          </div>
        </div>

        {/* Lesson sidebar */}
        {sidebarOpen && (
          <aside className="w-[320px] shrink-0 overflow-y-auto border-l border-line bg-card">
            {DEMO_MODULES.map((m) => (
              <div key={m.id} className="border-b border-line">
                <p className="px-4 py-3 text-[12.5px] font-semibold uppercase tracking-[0.04em] text-ink-soft/70">
                  {m.title}
                </p>
                <div className="flex flex-col pb-2">
                  {m.lessons.map((lesson) => {
                    const isActive = lesson.id === currentLesson.id;
                    const isDone = completedIds.has(lesson.id);
                    return (
                      <Link
                        key={lesson.id}
                        href={`/learn/${params.courseId}/${lesson.id}`}
                        className={cn(
                          "flex items-center gap-2.5 px-4 py-2.5 text-[13px] transition-colors",
                          isActive ? "bg-gold-tint text-ink font-semibold" : "text-ink-soft hover:bg-paper-dim"
                        )}
                      >
                        {isDone ? (
                          <CheckCircle2 size={14} className="shrink-0 text-teal" />
                        ) : (
                          <PlayCircle size={14} className="shrink-0" />
                        )}
                        <span className="truncate">{lesson.title}</span>
                      </Link>
                    );
                  })}
                </div>
              </div>
            ))}

            <div className="p-4">
              <Button variant="secondary" size="sm" className="w-full">
                <Download size={13} className="mr-1.5" />
                Download resources
              </Button>
            </div>
          </aside>
        )}
      </div>
    </div>
  );
}
'@

New-PageIfMissing -RelativePath 'apps\web\app\(learner)\learn\[courseId]\[lessonId]\page.tsx' -Content $coursePlayer

# ---------------------------------------------------------------------------
# 3. Course Q&A / Community -> /community/[courseId]
# ---------------------------------------------------------------------------
$communityPage = @'
"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { MessageCircle, ThumbsUp, Send } from "lucide-react";
import { Button, Textarea, EmptyState, Badge } from "@saachi/ui";

type Question = {
  id: string;
  authorName: string;
  body: string;
  createdAt: string;
  upvotes: number;
  instructorAnswer?: string;
};

// NOTE: demo-only dummy data. Replace with useCourseCommunity(courseId) once
// the community/Q&A backend endpoint and typed hook are available.
const INITIAL_QUESTIONS: Question[] = [
  {
    id: "q1",
    authorName: "Hassan Raza",
    body: "Does this work with the self-hosted n8n instance or only n8n Cloud?",
    createdAt: "2026-08-10T09:00:00Z",
    upvotes: 6,
    instructorAnswer: "Both! The workflows in this course work identically on self-hosted and n8n Cloud."
  },
  {
    id: "q2",
    authorName: "Sana Iqbal",
    body: "Is there a lesson on rate-limiting the OpenAI API calls inside a workflow?",
    createdAt: "2026-08-11T14:30:00Z",
    upvotes: 3
  }
];

export default function CourseCommunityPage() {
  const params = useParams<{ courseId: string }>();
  const [questions, setQuestions] = useState(INITIAL_QUESTIONS);
  const [draft, setDraft] = useState("");
  const [upvotedIds, setUpvotedIds] = useState<Set<string>>(new Set());

  function handlePost() {
    if (!draft.trim()) return;
    const newQuestion: Question = {
      id: `q${Date.now()}`,
      authorName: "You",
      body: draft.trim(),
      createdAt: new Date().toISOString(),
      upvotes: 0
    };
    setQuestions((prev) => [newQuestion, ...prev]);
    setDraft("");
  }

  function toggleUpvote(id: string) {
    setUpvotedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
    setQuestions((prev) =>
      prev.map((q) =>
        q.id === id ? { ...q, upvotes: q.upvotes + (upvotedIds.has(id) ? -1 : 1) } : q
      )
    );
  }

  return (
    <div className="mx-auto max-w-3xl px-4 py-10 md:px-8">
      <h1 className="mb-1 flex items-center gap-2 font-display text-[24px] font-bold text-ink">
        <MessageCircle size={22} />
        Course Q&amp;A
      </h1>
      <p className="mb-8 text-[14px] text-ink-soft">
        Ask questions about lesson {params.courseId} and get answers from the instructor and other learners.
      </p>

      <div className="mb-10 rounded-card border border-line bg-card p-5">
        <Textarea
          label="Ask a question"
          rows={3}
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          placeholder="What would you like to ask?"
        />
        <div className="mt-3 flex justify-end">
          <Button size="sm" disabled={!draft.trim()} onClick={handlePost}>
            <Send size={13} className="mr-1.5" />
            Post question
          </Button>
        </div>
      </div>

      {questions.length === 0 ? (
        <EmptyState title="No questions yet" description="Be the first to ask something about this course." />
      ) : (
        <div className="flex flex-col gap-4">
          {questions.map((q) => (
            <div key={q.id} className="rounded-card border border-line bg-card p-5">
              <div className="mb-1.5 flex items-center justify-between">
                <span className="text-[13.5px] font-semibold text-ink">{q.authorName}</span>
                <span className="text-[12px] text-ink-soft">
                  {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(q.createdAt))}
                </span>
              </div>
              <p className="mb-3 text-[14px] text-ink">{q.body}</p>

              <button
                type="button"
                onClick={() => toggleUpvote(q.id)}
                className={`flex items-center gap-1.5 rounded-control border px-2.5 py-1 text-[12px] font-medium transition-colors ${
                  upvotedIds.has(q.id)
                    ? "border-gold-dark bg-gold-tint text-ink"
                    : "border-line text-ink-soft hover:bg-paper-dim"
                }`}
              >
                <ThumbsUp size={12} />
                {q.upvotes}
              </button>

              {q.instructorAnswer && (
                <div className="mt-4 rounded-control border border-teal/30 bg-teal-light p-3.5">
                  <Badge className="mb-2">Instructor answer</Badge>
                  <p className="text-[13.5px] text-ink">{q.instructorAnswer}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
'@

New-PageIfMissing -RelativePath 'apps\web\app\(learner)\community\[courseId]\page.tsx' -Content $communityPage

# ---------------------------------------------------------------------------
# 4. Instructor Lesson Editors -> video / text / quiz
# ---------------------------------------------------------------------------
$lessonEditorVideo = @'
"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { UploadCloud, Captions, Paperclip } from "lucide-react";
import { Button, Input, Textarea } from "@saachi/ui";

export default function VideoLessonEditorPage() {
  const params = useParams<{ id: string; lessonId: string }>();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [videoFileName, setVideoFileName] = useState<string | null>(null);
  const [captionsFileName, setCaptionsFileName] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only, no backend lesson-save mutation or resumable/chunked
    // upload signed-URL flow wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Video lesson</h1>
      <p className="mb-8 text-[13px] text-ink-soft">
        Course {params.id} - Lesson {params.lessonId}
      </p>

      <div className="flex flex-col gap-4 rounded-card border border-line bg-card p-6">
        <Input label="Lesson title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. Your first workflow" />
        <Textarea label="Description" rows={3} value={description} onChange={(e) => setDescription(e.target.value)} />

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Video file</p>
          <label className="flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
            <UploadCloud size={16} />
            {videoFileName ?? "Upload video (resumable/chunked upload pending backend)"}
            <input
              type="file"
              accept="video/*"
              className="hidden"
              onChange={(e) => setVideoFileName(e.target.files?.[0]?.name ?? null)}
            />
          </label>
        </div>

        <div>
          <p className="mb-2 flex items-center gap-1.5 text-[13px] font-medium text-ink">
            <Captions size={14} /> Captions (optional)
          </p>
          <label className="flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
            <Paperclip size={16} />
            {captionsFileName ?? "Upload .vtt / .srt file"}
            <input
              type="file"
              accept=".vtt,.srt"
              className="hidden"
              onChange={(e) => setCaptionsFileName(e.target.files?.[0]?.name ?? null)}
            />
          </label>
        </div>
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save lesson"}
      </Button>
    </div>
  );
}
'@

New-PageIfMissing -RelativePath 'apps\web\app\(instructor)\instructor\courses\[id]\lessons\[lessonId]\video\page.tsx' -Content $lessonEditorVideo

$lessonEditorText = @'
"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { Button, Input, Textarea } from "@saachi/ui";

export default function TextLessonEditorPage() {
  const params = useParams<{ id: string; lessonId: string }>();
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only plain textarea. Replace with the Tiptap rich text
    // editor + lesson-content save mutation once available.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Text lesson</h1>
      <p className="mb-8 text-[13px] text-ink-soft">
        Course {params.id} - Lesson {params.lessonId}
      </p>

      <div className="flex flex-col gap-4 rounded-card border border-line bg-card p-6">
        <Input label="Lesson title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. Key concepts recap" />
        <Textarea
          label="Lesson content"
          rows={14}
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Write the lesson content here. This will be replaced with the Tiptap rich text editor."
        />
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save lesson"}
      </Button>
    </div>
  );
}
'@

New-PageIfMissing -RelativePath 'apps\web\app\(instructor)\instructor\courses\[id]\lessons\[lessonId]\text\page.tsx' -Content $lessonEditorText

$lessonEditorQuiz = @'
"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { Plus, Trash2, Check } from "lucide-react";
import { Button, Input, EmptyState } from "@saachi/ui";

type Choice = { id: string; text: string; correct: boolean };
type Question = { id: string; prompt: string; choices: Choice[] };

let counter = 0;
function nextId() {
  counter += 1;
  return `q${counter}`;
}

export default function QuizLessonEditorPage() {
  const params = useParams<{ id: string; lessonId: string }>();
  const [passingScore, setPassingScore] = useState("70");
  const [questions, setQuestions] = useState<Question[]>([]);
  const [saved, setSaved] = useState(false);

  function addQuestion() {
    setQuestions((prev) => [
      ...prev,
      {
        id: nextId(),
        prompt: "",
        choices: [
          { id: `${Date.now()}-a`, text: "", correct: true },
          { id: `${Date.now()}-b`, text: "", correct: false }
        ]
      }
    ]);
  }

  function updatePrompt(qId: string, prompt: string) {
    setQuestions((prev) => prev.map((q) => (q.id === qId ? { ...q, prompt } : q)));
  }

  function updateChoiceText(qId: string, cId: string, text: string) {
    setQuestions((prev) =>
      prev.map((q) => (q.id === qId ? { ...q, choices: q.choices.map((c) => (c.id === cId ? { ...c, text } : c)) } : q))
    );
  }

  function setCorrectChoice(qId: string, cId: string) {
    setQuestions((prev) =>
      prev.map((q) =>
        q.id === qId ? { ...q, choices: q.choices.map((c) => ({ ...c, correct: c.id === cId })) } : q
      )
    );
  }

  function addChoice(qId: string) {
    setQuestions((prev) =>
      prev.map((q) =>
        q.id === qId ? { ...q, choices: [...q.choices, { id: `${Date.now()}`, text: "", correct: false }] } : q
      )
    );
  }

  function removeQuestion(qId: string) {
    setQuestions((prev) => prev.filter((q) => q.id !== qId));
  }

  function handleSave() {
    // NOTE: demo-only, no backend quiz-save mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Quiz builder</h1>
      <p className="mb-8 text-[13px] text-ink-soft">
        Course {params.id} - Lesson {params.lessonId}
      </p>

      <div className="mb-6 rounded-card border border-line bg-card p-5">
        <Input
          label="Passing score (%)"
          type="number"
          min={0}
          max={100}
          value={passingScore}
          onChange={(e) => setPassingScore(e.target.value)}
          className="max-w-[160px]"
        />
      </div>

      {questions.length === 0 ? (
        <EmptyState title="No questions yet" description="Add your first quiz question below." />
      ) : (
        <div className="flex flex-col gap-4">
          {questions.map((q, index) => (
            <div key={q.id} className="rounded-card border border-line bg-card p-5">
              <div className="mb-3 flex items-center justify-between">
                <p className="text-[13px] font-semibold text-ink-soft">Question {index + 1}</p>
                <button type="button" onClick={() => removeQuestion(q.id)} className="text-ink-soft hover:text-error">
                  <Trash2 size={14} />
                </button>
              </div>

              <Input
                value={q.prompt}
                onChange={(e) => updatePrompt(q.id, e.target.value)}
                placeholder="Question prompt"
                className="mb-3"
              />

              <div className="flex flex-col gap-2">
                {q.choices.map((c) => (
                  <div key={c.id} className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => setCorrectChoice(q.id, c.id)}
                      title="Mark as correct answer"
                      className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-control border ${
                        c.correct ? "border-teal bg-teal-light text-teal" : "border-line text-ink-soft"
                      }`}
                    >
                      <Check size={14} />
                    </button>
                    <Input
                      value={c.text}
                      onChange={(e) => updateChoiceText(q.id, c.id, e.target.value)}
                      placeholder="Choice text"
                      className="flex-1"
                    />
                  </div>
                ))}
              </div>

              <Button size="sm" variant="secondary" className="mt-3" onClick={() => addChoice(q.id)}>
                <Plus size={13} className="mr-1" /> Add choice
              </Button>
            </div>
          ))}
        </div>
      )}

      <Button variant="secondary" className="mt-4" onClick={addQuestion}>
        <Plus size={14} className="mr-1.5" /> Add question
      </Button>

      <div className="mt-6">
        <Button size="lg" onClick={handleSave}>
          {saved ? "Saved" : "Save quiz"}
        </Button>
      </div>
    </div>
  );
}
'@

New-PageIfMissing -RelativePath 'apps\web\app\(instructor)\instructor\courses\[id]\lessons\[lessonId]\quiz\page.tsx' -Content $lessonEditorQuiz

# ---------------------------------------------------------------------------
# 5. Instructor Payouts -> /instructor/payouts, /instructor/payouts/methods
# ---------------------------------------------------------------------------
$instructorPayouts = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { Banknote, Wallet, Clock, Settings } from "lucide-react";
import { Button, KpiCard, EmptyState, Badge } from "@saachi/ui";

type Payout = {
  id: string;
  amount: number;
  currency: string;
  status: "pending" | "processing" | "paid" | "failed";
  requestedAt: string;
};

// NOTE: demo-only dummy data. Replace with useInstructorPayouts() once
// packages/api-client's payout hooks are confirmed.
const PAYOUTS: Payout[] = [];

const STATUS_LABEL: Record<Payout["status"], string> = {
  pending: "Pending",
  processing: "Processing",
  paid: "Paid",
  failed: "Failed"
};

const STATUS_VARIANT: Partial<Record<Payout["status"], "gold" | "success" | "error">> = {
  pending: "gold",
  paid: "success",
  failed: "error"
};

export default function InstructorPayoutsPage() {
  const [requesting, setRequesting] = useState(false);
  const [requested, setRequested] = useState(false);

  function handleRequestPayout() {
    setRequesting(true);
    // NOTE: demo-only, no backend payout-request mutation wired up yet.
    setTimeout(() => {
      setRequesting(false);
      setRequested(true);
    }, 700);
  }

  return (
    <div>
      <div className="mb-8 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Payouts</h1>
          <p className="text-[14px] text-ink-soft">Request payouts and track their status.</p>
        </div>
        <Link href="/instructor/payouts/methods">
          <Button variant="secondary">
            <Settings size={14} className="mr-1.5" />
            Payout methods
          </Button>
        </Link>
      </div>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <KpiCard label="Available balance" value="$0.00" icon={Wallet} />
        <KpiCard label="Pending clearance" value="$0.00" icon={Clock} />
        <KpiCard label="Lifetime payouts" value="$0.00" icon={Banknote} />
      </div>

      <div className="mb-10 rounded-card border border-line bg-card p-6">
        <p className="mb-1 text-[14px] font-semibold text-ink">Request a payout</p>
        <p className="mb-4 text-[13px] text-ink-soft">
          Your available balance will be transferred to your configured payout method.
        </p>
        <Button disabled={requesting || requested} onClick={handleRequestPayout}>
          {requested ? "Payout requested" : requesting ? "Requesting..." : "Request payout"}
        </Button>
      </div>

      <h2 className="mb-4 font-display text-[18px] font-semibold text-ink">Payout history</h2>
      {PAYOUTS.length === 0 ? (
        <EmptyState title="No payouts yet" description="Your payout requests and their status will appear here." />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Amount</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Requested</th>
              </tr>
            </thead>
            <tbody>
              {PAYOUTS.map((p) => (
                <tr key={p.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3.5 font-mono font-semibold text-ink">
                    {new Intl.NumberFormat("en-US", { style: "currency", currency: p.currency }).format(p.amount)}
                  </td>
                  <td className="px-4 py-3.5">
                    {STATUS_VARIANT[p.status] ? (
                      <Badge variant={STATUS_VARIANT[p.status]}>{STATUS_LABEL[p.status]}</Badge>
                    ) : (
                      <Badge>{STATUS_LABEL[p.status]}</Badge>
                    )}
                  </td>
                  <td className="px-4 py-3.5 text-ink-soft">
                    {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(p.requestedAt))}
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

New-PageIfMissing -RelativePath 'apps\web\app\(instructor)\instructor\payouts\page.tsx' -Content $instructorPayouts

$instructorPayoutMethods = @'
"use client";

import { useState } from "react";
import { Landmark, Smartphone, CreditCard } from "lucide-react";
import { Button, Input, Select, cn } from "@saachi/ui";

type PayoutMethod = "bank_transfer" | "easypaisa" | "jazzcash" | "stripe_connect";

const METHOD_OPTIONS: { value: PayoutMethod; label: string; icon: typeof Landmark }[] = [
  { value: "bank_transfer", label: "Bank transfer", icon: Landmark },
  { value: "easypaisa", label: "Easypaisa", icon: Smartphone },
  { value: "jazzcash", label: "JazzCash", icon: Smartphone },
  { value: "stripe_connect", label: "Stripe Connect", icon: CreditCard }
];

export default function InstructorPayoutMethodsPage() {
  const [method, setMethod] = useState<PayoutMethod>("bank_transfer");
  const [accountTitle, setAccountTitle] = useState("");
  const [accountNumber, setAccountNumber] = useState("");
  const [bankName, setBankName] = useState("");
  const [mobileNumber, setMobileNumber] = useState("");
  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only, no backend payout-method mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-lg">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Payout method</h1>
      <p className="mb-8 text-[13px] text-ink-soft">Choose how you'd like to receive your earnings.</p>

      <div className="mb-6 grid grid-cols-2 gap-3">
        {METHOD_OPTIONS.map((opt) => (
          <button
            key={opt.value}
            type="button"
            onClick={() => setMethod(opt.value)}
            className={cn(
              "flex flex-col items-start gap-2 rounded-control border p-4 text-left transition-colors",
              method === opt.value ? "border-gold-dark bg-gold-tint" : "border-line hover:bg-paper-dim"
            )}
          >
            <opt.icon size={18} className="text-ink" />
            <span className="text-[13px] font-medium text-ink">{opt.label}</span>
          </button>
        ))}
      </div>

      <div className="flex flex-col gap-4 rounded-card border border-line bg-card p-6">
        {method === "bank_transfer" && (
          <>
            <Input label="Bank name" value={bankName} onChange={(e) => setBankName(e.target.value)} placeholder="e.g. HBL, UBL, Allied Bank" />
            <Input label="Account title" value={accountTitle} onChange={(e) => setAccountTitle(e.target.value)} />
            <Input label="Account / IBAN number" value={accountNumber} onChange={(e) => setAccountNumber(e.target.value)} />
          </>
        )}

        {(method === "easypaisa" || method === "jazzcash") && (
          <>
            <Input label="Account title" value={accountTitle} onChange={(e) => setAccountTitle(e.target.value)} />
            <Input label="Mobile number" value={mobileNumber} onChange={(e) => setMobileNumber(e.target.value)} placeholder="03XXXXXXXXX" />
          </>
        )}

        {method === "stripe_connect" && (
          <p className="text-[13px] text-ink-soft">
            You'll be redirected to Stripe to connect your account once the Stripe Connect integration is wired up.
          </p>
        )}
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save payout method"}
      </Button>
    </div>
  );
}
'@

New-PageIfMissing -RelativePath 'apps\web\app\(instructor)\instructor\payouts\methods\page.tsx' -Content $instructorPayoutMethods

Write-Host ""
Write-Host "Done. Run 'pnpm dev' inside apps/web to see the new pages." -ForegroundColor Cyan
Write-Host "Course player, community Q&A, 3 lesson editors, and 2 payout pages were added" -ForegroundColor Cyan
Write-Host "(all frontend-only, demo/dummy data as requested)." -ForegroundColor Cyan