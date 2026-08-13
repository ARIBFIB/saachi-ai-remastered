<#
================================================================================
Apply-Saachi-Step7-DynamicLearner.ps1
STEP 7: Missing learner-portal dynamic-route pages (also empty/corrupt in the
last export). Each route is a thin Server Component page.tsx that renders a
"use client" companion component, matching the pattern already used elsewhere
in the codebase (server page + client component split):

  - app\(learner)\dashboard\certificates\[certificateId]\page.tsx
    + CertificateDetailClient.tsx        (public-shareable certificate view)
  - app\(learner)\dashboard\community\[courseSlug]\page.tsx
    + CommunityQAClient.tsx              (per-course Q&A thread)
  - app\(learner)\dashboard\mentorship\[instructorSlug]\page.tsx
    + MentorshipBookingClient.tsx        (mentor availability + booking)
  - app\courses\[slug]\learn\page.tsx
    + CoursePlayerClient.tsx             (video lesson player + sidebar)

USAGE:
  1. Save into repo root: D:\...\SAI2\Apply-Saachi-Step7-DynamicLearner.ps1
  2. Run:  .\Apply-Saachi-Step7-DynamicLearner.ps1
  3. Existing files are backed up first into .\_backup_stepwise\<timestamp>\
================================================================================
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$backupDir = Join-Path $root ("_backup_stepwise\{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$writtenCount = 0

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
    $script:writtenCount++
    Write-Host "  wrote: $RelativePath"
}

Write-Host "=== STEP 7: Learner-portal dynamic routes ==="
Write-Host "Target repo root: $root"
Write-Host ""

# ==================================================================
# 1) Certificate detail / verification view
# ==================================================================
Write-SaachiFile "apps\web\app\(learner)\dashboard\certificates\[certificateId]\page.tsx" @'
import { CertificateDetailClient } from "./CertificateDetailClient";

interface CertificatePageProps {
  params: Promise<{ certificateId: string }>;
}

export default async function CertificateDetailPage({ params }: CertificatePageProps) {
  const { certificateId } = await params;
  return <CertificateDetailClient certificateId={certificateId} />;
}
'@

Write-SaachiFile "apps\web\app\(learner)\dashboard\certificates\[certificateId]\CertificateDetailClient.tsx" @'
"use client";

import Link from "next/link";
import { Button } from "antd";
import { Award, Download, Share2, CheckCircle2, ArrowLeft } from "lucide-react";

// TODO: replace with useCertificate(certificateId) hook from @saachi/api-client
interface CertificateRecord {
  id: string;
  title: string;
  learnerName: string;
  issuedDate: string;
  verificationId: string;
  category: string;
}

function getDummyCertificate(certificateId: string): CertificateRecord {
  return {
    id: certificateId,
    title: "Advanced Machine Learning Architectures",
    learnerName: "Alex Morgan",
    issuedDate: "Oct 12, 2024",
    verificationId: `SAI-CERT-${certificateId.toUpperCase()}`,
    category: "AI & Data",
  };
}

export function CertificateDetailClient({ certificateId }: { certificateId: string }) {
  const certificate = getDummyCertificate(certificateId);

  function handleDownload() {
    // TODO: wire to useCertificate(certificateId).downloadPdf() from @saachi/api-client
    console.log("download certificate", certificate.id);
  }

  function handleShare() {
    // TODO: wire to share sheet / copy verification link
    console.log("share certificate", certificate.id);
  }

  return (
    <div className="flex min-h-screen flex-col items-center bg-[var(--token-color-bg)] px-6 py-16">
      <div className="flex w-full max-w-[720px] flex-col gap-6">
        <Link
          href="/dashboard/certificates"
          className="flex items-center gap-1 text-sm font-semibold"
          style={{ color: "var(--token-color-inkSoft)" }}
        >
          <ArrowLeft size={14} />
          Back to Certificates
        </Link>

        <div
          className="flex flex-col items-center gap-6 rounded-2xl border-2 bg-[var(--token-color-surface)] p-12 text-center shadow-[var(--token-shadow-md)]"
          style={{ borderColor: "var(--token-color-primary)" }}
        >
          <span
            className="flex h-16 w-16 items-center justify-center rounded-full"
            style={{ backgroundColor: "var(--token-color-primaryTint)" }}
          >
            <Award size={28} color="var(--token-color-primary)" />
          </span>

          <div className="flex flex-col gap-1">
            <span
              className="text-xs font-semibold uppercase tracking-wide"
              style={{ color: "var(--token-color-inkSoft)" }}
            >
              Certificate of Completion
            </span>
            <h1 className="text-3xl font-bold" style={{ color: "var(--token-color-ink)" }}>
              {certificate.title}
            </h1>
          </div>

          <p style={{ color: "var(--token-color-inkSoft)" }}>
            Awarded to <span className="font-semibold">{certificate.learnerName}</span> on{" "}
            {certificate.issuedDate}
          </p>

          <div
            className="flex items-center gap-2 rounded-full px-4 py-2 text-xs font-semibold"
            style={{ backgroundColor: "var(--token-color-successTint)", color: "var(--token-color-success)" }}
          >
            <CheckCircle2 size={14} />
            Verified &middot; ID: {certificate.verificationId}
          </div>

          <div className="flex gap-4 pt-4">
            <Button type="primary" icon={<Download size={14} />} onClick={handleDownload}>
              Download PDF
            </Button>
            <Button icon={<Share2 size={14} />} onClick={handleShare}>
              Share
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
'@

# ==================================================================
# 2) Community / Course Q&A
# ==================================================================
Write-SaachiFile "apps\web\app\(learner)\dashboard\community\[courseSlug]\page.tsx" @'
import { CommunityQAClient } from "./CommunityQAClient";

interface CommunityPageProps {
  params: Promise<{ courseSlug: string }>;
}

export default async function CommunityQAPage({ params }: CommunityPageProps) {
  const { courseSlug } = await params;
  return <CommunityQAClient courseSlug={courseSlug} />;
}
'@

Write-SaachiFile "apps\web\app\(learner)\dashboard\community\[courseSlug]\CommunityQAClient.tsx" @'
"use client";

import { useState } from "react";
import Image from "next/image";
import { Button, Input } from "antd";
import { ThumbsUp, MessageSquare, BadgeCheck } from "lucide-react";

// TODO: replace with useCommunityThreads(courseSlug) hook from @saachi/api-client
interface ThreadPost {
  id: string;
  author: string;
  avatar: string;
  timestamp: string;
  content: string;
  upvotes: number;
  isInstructor?: boolean;
}

const initialThreads: ThreadPost[] = [
  {
    id: "t1",
    author: "Dr. Sarah Chen",
    avatar: "https://i.pravatar.cc/64?img=32",
    timestamp: "2 days ago",
    content:
      "Welcome to the Q&A for this course! Ask anything about the lessons and I'll do my best to answer within 24 hours.",
    upvotes: 24,
    isInstructor: true,
  },
  {
    id: "t2",
    author: "Jordan Lee",
    avatar: "https://i.pravatar.cc/64?img=15",
    timestamp: "1 day ago",
    content: "In lesson 3, why does the temperature parameter change the output so drastically?",
    upvotes: 8,
  },
];

export function CommunityQAClient({ courseSlug }: { courseSlug: string }) {
  const [threads, setThreads] = useState<ThreadPost[]>(initialThreads);
  const [draft, setDraft] = useState("");

  function handlePost() {
    if (!draft.trim()) return;
    // TODO: wire to useCommunityThreads(courseSlug).postQuestion() from @saachi/api-client
    setThreads((prev) => [
      {
        id: `local-${Date.now()}`,
        author: "You",
        avatar: "https://i.pravatar.cc/64?img=47",
        timestamp: "Just now",
        content: draft,
        upvotes: 0,
      },
      ...prev,
    ]);
    setDraft("");
  }

  function handleUpvote(id: string) {
    setThreads((prev) => prev.map((t) => (t.id === id ? { ...t, upvotes: t.upvotes + 1 } : t)));
  }

  return (
    <div className="mx-auto flex w-full max-w-[860px] flex-col gap-8 px-6 py-12">
      <div className="flex flex-col gap-1">
        <h1 className="text-3xl font-bold" style={{ color: "var(--token-color-ink)" }}>
          Course Discussion
        </h1>
        <p style={{ color: "var(--token-color-inkSoft)" }}>
          Ask questions and get help from the instructor and other learners in{" "}
          <span className="font-semibold">{courseSlug.replace(/-/g, " ")}</span>.
        </p>
      </div>

      <div
        className="flex flex-col gap-3 rounded-xl border p-5"
        style={{ borderColor: "var(--token-color-border)", backgroundColor: "var(--token-color-surface)" }}
      >
        <Input.TextArea
          rows={3}
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          placeholder="Ask a question about this course..."
        />
        <div className="flex justify-end">
          <Button type="primary" onClick={handlePost}>
            Post Question
          </Button>
        </div>
      </div>

      <div className="flex flex-col gap-4">
        {threads.map((post) => (
          <article
            key={post.id}
            className="flex gap-4 rounded-xl border p-5"
            style={{
              borderColor: post.isInstructor ? "var(--token-color-primary)" : "var(--token-color-border)",
              backgroundColor: "var(--token-color-surface)",
            }}
          >
            <span className="relative block h-10 w-10 shrink-0 overflow-hidden rounded-full">
              <Image src={post.avatar} alt={post.author} fill sizes="40px" className="object-cover" />
            </span>

            <div className="flex flex-1 flex-col gap-1.5">
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
                  {post.author}
                </span>
                {post.isInstructor && (
                  <span
                    className="flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold uppercase"
                    style={{ backgroundColor: "var(--token-color-primaryTint)", color: "var(--token-color-primary)" }}
                  >
                    <BadgeCheck size={10} />
                    Instructor
                  </span>
                )}
                <span className="text-xs" style={{ color: "var(--token-color-inkSoft)" }}>
                  &bull; {post.timestamp}
                </span>
              </div>

              <p className="text-sm leading-6" style={{ color: "var(--token-color-inkSoft)" }}>
                {post.content}
              </p>

              <div className="flex items-center gap-4 pt-1">
                <button
                  type="button"
                  onClick={() => handleUpvote(post.id)}
                  className="flex items-center gap-1 text-xs font-medium"
                  style={{ color: "var(--token-color-inkSoft)" }}
                >
                  <ThumbsUp size={13} />
                  {post.upvotes}
                </button>
                <button
                  type="button"
                  className="flex items-center gap-1 text-xs font-medium"
                  style={{ color: "var(--token-color-inkSoft)" }}
                >
                  <MessageSquare size={13} />
                  Reply
                </button>
              </div>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}
'@

# ==================================================================
# 3) Mentorship booking
# ==================================================================
Write-SaachiFile "apps\web\app\(learner)\dashboard\mentorship\[instructorSlug]\page.tsx" @'
import { MentorshipBookingClient } from "./MentorshipBookingClient";

interface MentorshipBookingPageProps {
  params: Promise<{ instructorSlug: string }>;
}

export default async function MentorshipBookingPage({ params }: MentorshipBookingPageProps) {
  const { instructorSlug } = await params;
  return <MentorshipBookingClient instructorSlug={instructorSlug} />;
}
'@

Write-SaachiFile "apps\web\app\(learner)\dashboard\mentorship\[instructorSlug]\MentorshipBookingClient.tsx" @'
"use client";

import { useState } from "react";
import Image from "next/image";
import { Button } from "antd";
import { Clock, Video, CalendarDays } from "lucide-react";

// TODO: replace with useInstructorAvailability(instructorSlug) hook from @saachi/api-client
const timeSlots = ["9:00 AM", "10:30 AM", "1:00 PM", "2:30 PM", "4:00 PM"];
const days = ["Mon 21", "Tue 22", "Wed 23", "Thu 24", "Fri 25"];

function labelFromSlug(slug: string) {
  return slug
    .split("-")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}

export function MentorshipBookingClient({ instructorSlug }: { instructorSlug: string }) {
  const [selectedDay, setSelectedDay] = useState(days[0]);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);

  const mentorName = labelFromSlug(instructorSlug);

  function handleConfirmBooking() {
    if (!selectedTime) return;
    // TODO: wire to useBookMentorship() from @saachi/api-client (creates session + payment)
    console.log("book session", { instructorSlug, selectedDay, selectedTime });
  }

  return (
    <div className="mx-auto flex w-full max-w-[860px] flex-col gap-8 px-6 py-12">
      <div className="flex items-center gap-4">
        <span className="relative block h-16 w-16 shrink-0 overflow-hidden rounded-full">
          <Image src="https://i.pravatar.cc/128?img=32" alt={mentorName} fill sizes="64px" className="object-cover" />
        </span>
        <div className="flex flex-col">
          <h1 className="text-2xl font-bold" style={{ color: "var(--token-color-ink)" }}>
            Book a session with {mentorName}
          </h1>
          <p className="flex items-center gap-1 text-sm" style={{ color: "var(--token-color-inkSoft)" }}>
            <Video size={14} />
            45-min video call &bull; $60/session
          </p>
        </div>
      </div>

      <div
        className="flex flex-col gap-6 rounded-xl border p-6"
        style={{ borderColor: "var(--token-color-border)", backgroundColor: "var(--token-color-surface)" }}
      >
        <div className="flex flex-col gap-3">
          <h2 className="flex items-center gap-2 text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
            <CalendarDays size={16} color="var(--token-color-primary)" />
            Select a day
          </h2>
          <div className="flex flex-wrap gap-2">
            {days.map((day) => (
              <button
                key={day}
                type="button"
                onClick={() => setSelectedDay(day)}
                className="rounded-lg border px-4 py-2 text-sm font-medium transition"
                style={{
                  borderColor: day === selectedDay ? "var(--token-color-primary)" : "var(--token-color-border)",
                  backgroundColor: day === selectedDay ? "var(--token-color-primaryTint)" : "var(--token-color-bg)",
                  color: day === selectedDay ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                }}
              >
                {day}
              </button>
            ))}
          </div>
        </div>

        <div className="flex flex-col gap-3">
          <h2 className="flex items-center gap-2 text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
            <Clock size={16} color="var(--token-color-primary)" />
            Select a time
          </h2>
          <div className="flex flex-wrap gap-2">
            {timeSlots.map((time) => (
              <button
                key={time}
                type="button"
                onClick={() => setSelectedTime(time)}
                className="rounded-lg border px-4 py-2 text-sm font-medium transition"
                style={{
                  borderColor: time === selectedTime ? "var(--token-color-primary)" : "var(--token-color-border)",
                  backgroundColor: time === selectedTime ? "var(--token-color-primaryTint)" : "var(--token-color-bg)",
                  color: time === selectedTime ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                }}
              >
                {time}
              </button>
            ))}
          </div>
        </div>

        <div className="flex items-center justify-between border-t pt-4" style={{ borderColor: "var(--token-color-border)" }}>
          <span className="text-sm" style={{ color: "var(--token-color-inkSoft)" }}>
            {selectedTime ? `${selectedDay} at ${selectedTime}` : "Pick a day and time to continue"}
          </span>
          <Button type="primary" disabled={!selectedTime} onClick={handleConfirmBooking}>
            Confirm &amp; Pay $60
          </Button>
        </div>
      </div>
    </div>
  );
}
'@

# ==================================================================
# 4) Course player
# ==================================================================
Write-SaachiFile "apps\web\app\courses\[slug]\learn\page.tsx" @'
import { CoursePlayerClient } from "./CoursePlayerClient";

interface CoursePlayerPageProps {
  params: Promise<{ slug: string }>;
}

export default async function CoursePlayerPage({ params }: CoursePlayerPageProps) {
  const { slug } = await params;
  return <CoursePlayerClient courseSlug={slug} />;
}
'@

Write-SaachiFile "apps\web\app\courses\[slug]\learn\CoursePlayerClient.tsx" @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { Button } from "antd";
import { PlayCircle, CheckCircle2, Circle, ArrowLeft, ChevronRight } from "lucide-react";

// TODO: replace with useCourseCurriculum(courseSlug) + useLessonProgress() hooks
// from @saachi/api-client
interface Lesson {
  id: string;
  title: string;
  durationLabel: string;
  completed: boolean;
}

interface Module {
  id: string;
  title: string;
  lessons: Lesson[];
}

const modules: Module[] = [
  {
    id: "m1",
    title: "Module 1: Introduction to Large Language Models",
    lessons: [
      { id: "l1", title: "What is a Large Language Model?", durationLabel: "8:12", completed: true },
      { id: "l2", title: "Tokens, context windows, and limits", durationLabel: "11:40", completed: true },
      { id: "l3", title: "Setting up your first API call", durationLabel: "14:05", completed: false },
    ],
  },
  {
    id: "m2",
    title: "Module 2: Anatomy of a Perfect Prompt",
    lessons: [
      { id: "l4", title: "Zero-shot vs few-shot prompting", durationLabel: "10:22", completed: false },
      { id: "l5", title: "Chain-of-thought reasoning", durationLabel: "16:48", completed: false },
    ],
  },
];

export function CoursePlayerClient({ courseSlug }: { courseSlug: string }) {
  const allLessons = modules.flatMap((m) => m.lessons);
  const [activeLessonId, setActiveLessonId] = useState(allLessons[0]?.id ?? "");
  const activeLesson = allLessons.find((l) => l.id === activeLessonId) ?? allLessons[0];

  function handleMarkComplete() {
    // TODO: wire to useLessonProgress(courseSlug, activeLessonId).markComplete()
    // from @saachi/api-client
    console.log("mark complete", { courseSlug, lessonId: activeLessonId });
  }

  return (
    <div className="flex min-h-screen" style={{ backgroundColor: "var(--token-color-playerBg)" }}>
      {/* Video + lesson content */}
      <div className="flex flex-1 flex-col">
        <div className="flex items-center gap-3 px-6 py-4">
          <Link href="/dashboard/my-courses" className="flex items-center gap-1 text-sm text-white/70 hover:text-white">
            <ArrowLeft size={14} />
            Back to My Courses
          </Link>
        </div>

        <div className="relative mx-6 flex aspect-video items-center justify-center rounded-xl bg-black/60">
          <PlayCircle size={64} className="text-white/80" />
        </div>

        <div className="flex flex-col gap-3 px-6 py-6">
          <h1 className="text-xl font-semibold text-white">{activeLesson?.title}</h1>
          <p className="text-sm text-white/60">
            Course: {courseSlug.replace(/-/g, " ")}
          </p>

          <div className="pt-2">
            <Button type="primary" icon={<CheckCircle2 size={14} />} onClick={handleMarkComplete}>
              Mark Lesson Complete
            </Button>
          </div>
        </div>
      </div>

      {/* Lesson sidebar */}
      <aside className="hidden w-80 shrink-0 flex-col overflow-y-auto border-l border-white/10 bg-black/20 lg:flex">
        <div className="border-b border-white/10 px-5 py-4">
          <h2 className="text-sm font-semibold text-white">Course Content</h2>
        </div>

        <nav className="flex flex-col">
          {modules.map((module) => (
            <div key={module.id} className="border-b border-white/10">
              <div className="px-5 py-3 text-xs font-semibold uppercase tracking-wide text-white/50">
                {module.title}
              </div>
              <div className="flex flex-col">
                {module.lessons.map((lesson) => {
                  const isActive = lesson.id === activeLessonId;
                  return (
                    <button
                      key={lesson.id}
                      type="button"
                      onClick={() => setActiveLessonId(lesson.id)}
                      className="flex items-center justify-between gap-2 px-5 py-3 text-left transition"
                      style={{
                        backgroundColor: isActive ? "rgba(255,255,255,0.08)" : "transparent",
                      }}
                    >
                      <span className="flex items-center gap-2">
                        {lesson.completed ? (
                          <CheckCircle2 size={14} className="shrink-0 text-emerald-400" />
                        ) : (
                          <Circle size={14} className="shrink-0 text-white/40" />
                        )}
                        <span className={`text-sm ${isActive ? "font-semibold text-white" : "text-white/70"}`}>
                          {lesson.title}
                        </span>
                      </span>
                      <span className="flex items-center gap-1 text-xs text-white/40">
                        {lesson.durationLabel}
                        {isActive && <ChevronRight size={12} />}
                      </span>
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </nav>
      </aside>
    </div>
  );
}
'@

Write-Host ""
Write-Host "=== STEP 7 complete: $writtenCount file(s) written. ==="
if (Test-Path $backupDir) {
    Write-Host "Backups of any overwritten files: $backupDir"
}