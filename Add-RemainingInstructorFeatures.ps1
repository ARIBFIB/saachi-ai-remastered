<#
.SYNOPSIS
    Adds the 3 remaining instructor-portal features to SAI2:
      1. Engagement Status   -> /instructor/students/engagement
      2. Message Students    -> /instructor/students/messages
      3. Onboarding Checklist -> dashboard card

.USAGE
    Run from the SAI2 repo root:
    PS D:\...\SAI2> .\Add-RemainingInstructorFeatures.ps1
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
# 1. ENGAGEMENT STATUS PAGE
# ===========================================================================
Write-Section "Engagement Status page"

$engagementPath = Join-Path $root "apps\web\app\(instructor)\instructor\students\engagement\page.tsx"

$engagementContent = @'
"use client";

import { useMemo, useState } from "react";
import { UserCheck, UserX, UserMinus, GraduationCap, MessageCircle } from "lucide-react";
import { Button, Input, EmptyState, Badge, KpiCard, Select } from "@saachi/ui";

type EngagementCategory = "active" | "inactive" | "dormant" | "completed";

type EngagedStudent = {
  id: string;
  name: string;
  courseTitle: string;
  lastActiveDays: number;
  progressPercent: number;
};

// NOTE: demo-only dummy data. Replace with useInstructorStudentEngagement() once confirmed.
const STUDENTS: EngagedStudent[] = [
  { id: "stu_1", name: "Hina Malik", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 1, progressPercent: 100 },
  { id: "stu_2", name: "Omar Sheikh", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 0, progressPercent: 65 },
  { id: "stu_3", name: "Sara Iqbal", courseTitle: "AI Chatbots for WhatsApp Support", lastActiveDays: 5, progressPercent: 40 },
  { id: "stu_4", name: "Noor Fatima", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 45, progressPercent: 30 },
  { id: "stu_5", name: "Ali Raza", courseTitle: "AI Chatbots for WhatsApp Support", lastActiveDays: 1, progressPercent: 20 },
  { id: "stu_6", name: "Danish Iqbal", courseTitle: "Prompt Engineering for Client Work", lastActiveDays: 12, progressPercent: 55 },
  { id: "stu_7", name: "Zara Ahmed", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 60, progressPercent: 15 },
  { id: "stu_8", name: "Usman Tariq", courseTitle: "AI Chatbots for WhatsApp Support", lastActiveDays: 3, progressPercent: 100 },
  { id: "stu_9", name: "Mahnoor Khalid", courseTitle: "Prompt Engineering for Client Work", lastActiveDays: 90, progressPercent: 10 },
  { id: "stu_10", name: "Bilal S.", courseTitle: "Automate Everything with n8n & AI", lastActiveDays: 2, progressPercent: 80 }
];

function categorize(student: EngagedStudent): EngagementCategory {
  if (student.progressPercent === 100) return "completed";
  if (student.lastActiveDays <= 7) return "active";
  if (student.lastActiveDays <= 30) return "inactive";
  return "dormant";
}

const CATEGORY_META: Record<EngagementCategory, { label: string; variant?: "success" | "gold" | "error" }> = {
  active: { label: "Active", variant: "success" },
  inactive: { label: "Inactive", variant: "gold" },
  dormant: { label: "At risk", variant: "error" },
  completed: { label: "Completed", variant: "success" }
};

const FILTER_OPTIONS = [
  { label: "All students", value: "all" },
  { label: "Active", value: "active" },
  { label: "Inactive", value: "inactive" },
  { label: "At risk / Dormant", value: "dormant" },
  { label: "Completed", value: "completed" }
];

function lastActiveLabel(days: number): string {
  if (days === 0) return "Today";
  if (days === 1) return "Yesterday";
  if (days < 7) return `${days} days ago`;
  if (days < 30) return `${Math.round(days / 7)} weeks ago`;
  return `${Math.round(days / 30)} months ago`;
}

export default function InstructorStudentsEngagementPage() {
  const [category, setCategory] = useState<string>("all");
  const [search, setSearch] = useState("");

  const categorized = useMemo(
    () => STUDENTS.map((s) => ({ ...s, category: categorize(s) })),
    []
  );

  const counts = useMemo(() => {
    return {
      active: categorized.filter((s) => s.category === "active").length,
      inactive: categorized.filter((s) => s.category === "inactive").length,
      dormant: categorized.filter((s) => s.category === "dormant").length,
      completed: categorized.filter((s) => s.category === "completed").length
    };
  }, [categorized]);

  const filtered = useMemo(() => {
    let items = [...categorized];
    if (category !== "all") items = items.filter((s) => s.category === category);
    if (search.trim()) {
      const q = search.toLowerCase();
      items = items.filter(
        (s) => s.name.toLowerCase().includes(q) || s.courseTitle.toLowerCase().includes(q)
      );
    }
    return items.sort((a, b) => a.lastActiveDays - b.lastActiveDays);
  }, [categorized, category, search]);

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Engagement Status</h1>
          <p className="text-[14px] text-ink-soft">
            See which students are active, inactive, or at risk of dropping off.
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <Input
            placeholder="Search students or courses..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-64"
          />
          <Select options={FILTER_OPTIONS} value={category} onChange={(e) => setCategory(e.target.value)} className="w-48" />
        </div>
      </div>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <KpiCard label="Active (last 7 days)" value={String(counts.active)} icon={UserCheck} />
        <KpiCard label="Inactive (7-30 days)" value={String(counts.inactive)} icon={UserMinus} />
        <KpiCard label="At risk / Dormant" value={String(counts.dormant)} icon={UserX} />
        <KpiCard label="Completed course" value={String(counts.completed)} icon={GraduationCap} />
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No students in this view"
          description="Try a different filter or search term."
        />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Student</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Course</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Last active</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Progress</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((s) => {
                const meta = CATEGORY_META[s.category];
                return (
                  <tr key={s.id} className="border-b border-line last:border-0">
                    <td className="px-4 py-3.5 font-medium text-ink">{s.name}</td>
                    <td className="px-4 py-3.5 text-ink-soft">{s.courseTitle}</td>
                    <td className="px-4 py-3.5">
                      {meta.variant ? <Badge variant={meta.variant}>{meta.label}</Badge> : <Badge>{meta.label}</Badge>}
                    </td>
                    <td className="px-4 py-3.5 text-ink-soft">{lastActiveLabel(s.lastActiveDays)}</td>
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 w-24 overflow-hidden rounded-full bg-paper-dim">
                          <div className="h-full rounded-full bg-gold" style={{ width: `${s.progressPercent}%` }} />
                        </div>
                        <span className="text-ink-soft">{s.progressPercent}%</span>
                      </div>
                    </td>
                    <td className="px-4 py-3.5">
                      <Button
                        size="sm"
                        variant="secondary"
                        onClick={() =>
                          (window.location.href = `/instructor/students/messages?to=${encodeURIComponent(s.name)}`)
                        }
                      >
                        <MessageCircle size={13} className="mr-1.5" />
                        Send nudge
                      </Button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
'@

Write-FileSafe -path $engagementPath -content $engagementContent

# ===========================================================================
# 2. INSTRUCTOR MESSAGES STORE
# ===========================================================================
Write-Section "Instructor Messages store"

$storePath = Join-Path $root "packages\store\src\useInstructorMessagesStore.ts"

$storeContent = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type SentMessage = {
  id: string;
  mode: "broadcast" | "direct";
  target: string; // course title (broadcast) or student name (direct)
  body: string;
  sentAt: string;
};

// NOTE: demo-only seed data. Replace with real Messaging API once available.
const SEED_MESSAGES: SentMessage[] = [
  {
    id: "msg_1",
    mode: "broadcast",
    target: "Automate Everything with n8n & AI",
    body: "New bonus module on error handling just went live - check it out!",
    sentAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 3).toISOString()
  },
  {
    id: "msg_2",
    mode: "direct",
    target: "Sara Iqbal",
    body: "Hey Sara, noticed you paused at module 2 - let me know if you're stuck on anything!",
    sentAt: new Date(Date.now() - 1000 * 60 * 60 * 24).toISOString()
  }
];

type InstructorMessagesState = {
  messages: SentMessage[];
  sendMessage: (mode: "broadcast" | "direct", target: string, body: string) => void;
};

export const useInstructorMessagesStore = create<InstructorMessagesState>()(
  persist(
    (set, get) => ({
      messages: SEED_MESSAGES,
      sendMessage: (mode, target, body) => {
        const newMessage: SentMessage = {
          id: `msg_${Math.random().toString(36).slice(2, 9)}`,
          mode,
          target,
          body,
          sentAt: new Date().toISOString()
        };
        set({ messages: [newMessage, ...get().messages] });
      }
    }),
    { name: "saachi-instructor-messages" }
  )
);
'@

Write-FileSafe -path $storePath -content $storeContent

# Add export to packages/store/src/index.ts (idempotent)
$storeIndexPath = Join-Path $root "packages\store\src\index.ts"
if (Test-Path $storeIndexPath) {
    $indexContent = Get-Content -Path $storeIndexPath -Raw
    $exportLine = 'export * from "./useInstructorMessagesStore";'
    if ($indexContent -notmatch [regex]::Escape($exportLine)) {
        $indexContent = $indexContent.TrimEnd() + "`n" + $exportLine + "`n"
        Set-Content -Path $storeIndexPath -Value $indexContent -NoNewline -Encoding UTF8
        Write-Host "  [OK] Added export to packages/store/src/index.ts" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] Export already present in packages/store/src/index.ts" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [WARN] Could not find packages/store/src/index.ts - add the export manually:" -ForegroundColor Yellow
    Write-Host "         export * from `"./useInstructorMessagesStore`";" -ForegroundColor Yellow
}

# ===========================================================================
# 3. MESSAGE STUDENTS PAGE
# ===========================================================================
Write-Section "Message Students page"

$messagesPath = Join-Path $root "apps\web\app\(instructor)\instructor\students\messages\page.tsx"

$messagesContent = @'
"use client";

import { Suspense, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { Send, Radio, User, Clock } from "lucide-react";
import { useInstructorMessagesStore, useInstructorCourseStore } from "@saachi/store";
import { Button, Select, Textarea, EmptyState, cn } from "@saachi/ui";

// NOTE: demo-only dummy student list. Replace with useInstructorStudents() once confirmed.
const STUDENT_OPTIONS = [
  "Hina Malik",
  "Omar Sheikh",
  "Sara Iqbal",
  "Noor Fatima",
  "Ali Raza",
  "Danish Iqbal",
  "Zara Ahmed",
  "Usman Tariq"
];

type Mode = "broadcast" | "direct";

function MessageStudentsContent() {
  const searchParams = useSearchParams();
  const prefilledStudent = searchParams.get("to");

  const courses = useInstructorCourseStore((s) => s.courses);
  const messages = useInstructorMessagesStore((s) => s.messages);
  const sendMessage = useInstructorMessagesStore((s) => s.sendMessage);

  const [mode, setMode] = useState<Mode>(prefilledStudent ? "direct" : "broadcast");
  const [courseId, setCourseId] = useState(courses[0]?.id ?? "");
  const [studentName, setStudentName] = useState(prefilledStudent ?? STUDENT_OPTIONS[0]);
  const [body, setBody] = useState("");
  const [sentTick, setSentTick] = useState(0);

  const courseOptions = courses.map((c) => ({ label: c.title, value: c.id }));
  const studentOptions = STUDENT_OPTIONS.map((s) => ({ label: s, value: s }));

  const selectedCourseTitle = useMemo(
    () => courses.find((c) => c.id === courseId)?.title ?? "",
    [courses, courseId]
  );

  function handleSend() {
    if (!body.trim()) return;
    const target = mode === "broadcast" ? selectedCourseTitle : studentName;
    if (!target) return;
    sendMessage(mode, target, body.trim());
    setBody("");
    setSentTick((t) => t + 1);
    setTimeout(() => setSentTick(0), 2500);
  }

  return (
    <div>
      <div className="mb-6">
        <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Message Students</h1>
        <p className="text-[14px] text-ink-soft">
          Broadcast an update to a whole course, or message a student directly.
        </p>
      </div>

      <div className="mb-6 flex gap-1.5">
        <button
          type="button"
          onClick={() => setMode("broadcast")}
          className={cn(
            "flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-[12.5px] font-semibold transition-colors duration-150 ease-out",
            mode === "broadcast" ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
          )}
        >
          <Radio size={13} />
          Broadcast to course
        </button>
        <button
          type="button"
          onClick={() => setMode("direct")}
          className={cn(
            "flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-[12.5px] font-semibold transition-colors duration-150 ease-out",
            mode === "direct" ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
          )}
        >
          <User size={13} />
          Direct message
        </button>
      </div>

      <div className="mb-8 rounded-card border border-line bg-card p-6">
        <div className="mb-4 max-w-sm">
          {mode === "broadcast" ? (
            <Select
              label="Course"
              options={courseOptions}
              value={courseId}
              onChange={(e) => setCourseId(e.target.value)}
            />
          ) : (
            <Select
              label="Student"
              options={studentOptions}
              value={studentName}
              onChange={(e) => setStudentName(e.target.value)}
            />
          )}
        </div>

        <Textarea
          label="Message"
          rows={5}
          value={body}
          onChange={(e) => setBody(e.target.value)}
          placeholder={
            mode === "broadcast"
              ? "Write an update for everyone enrolled in this course..."
              : "Write a direct message to this student..."
          }
        />

        <div className="mt-4 flex items-center gap-3">
          <Button disabled={!body.trim()} onClick={handleSend}>
            <Send size={14} className="mr-1.5" />
            {mode === "broadcast" ? "Send to course" : "Send message"}
          </Button>
          {sentTick > 0 && <span className="text-[12.5px] font-medium text-teal">Sent</span>}
        </div>
      </div>

      <h2 className="mb-4 font-display text-[18px] font-semibold text-ink">Sent messages</h2>
      {messages.length === 0 ? (
        <EmptyState title="No messages sent yet" description="Messages you send will show up here." />
      ) : (
        <div className="flex flex-col gap-3">
          {messages.map((m) => (
            <div key={m.id} className="rounded-card border border-line bg-card p-4">
              <div className="mb-1.5 flex flex-wrap items-center gap-2">
                <span
                  className={cn(
                    "flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[10.5px] font-semibold",
                    m.mode === "broadcast" ? "bg-gold-tint text-gold-dark" : "bg-teal-light text-teal"
                  )}
                >
                  {m.mode === "broadcast" ? <Radio size={10} /> : <User size={10} />}
                  {m.mode === "broadcast" ? "Broadcast" : "Direct"}
                </span>
                <span className="text-[13px] font-semibold text-ink">{m.target}</span>
                <span className="ml-auto flex items-center gap-1 text-[11.5px] text-ink-soft/60">
                  <Clock size={11} />
                  {new Intl.DateTimeFormat("en-US", { dateStyle: "medium", timeStyle: "short" }).format(
                    new Date(m.sentAt)
                  )}
                </span>
              </div>
              <p className="text-[13.5px] text-ink-soft">{m.body}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default function InstructorStudentsMessagesPage() {
  return (
    <Suspense fallback={null}>
      <MessageStudentsContent />
    </Suspense>
  );
}
'@

Write-FileSafe -path $messagesPath -content $messagesContent

# ===========================================================================
# 4. ONBOARDING CHECKLIST COMPONENT
# ===========================================================================
Write-Section "Onboarding Checklist component"

$checklistPath = Join-Path $root "apps\web\components\ui\instructor-onboarding-checklist.tsx"

$checklistContent = @'
"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ChevronDown, X, CircleCheck, Circle } from "lucide-react";
import { useInstructorCourseStore } from "@saachi/store";
import { Button, cn } from "@saachi/ui";

const DISMISS_KEY = "saachi-instructor-onboarding-dismissed";

type ChecklistItem = {
  id: string;
  label: string;
  description: string;
  href: string;
  done: boolean;
};

export function InstructorOnboardingChecklist() {
  const courses = useInstructorCourseStore((s) => s.courses);

  const [dismissed, setDismissed] = useState(true); // default true until we check localStorage (avoids flash)
  const [expanded, setExpanded] = useState(true);
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    setHydrated(true);
    const stored = window.localStorage.getItem(DISMISS_KEY);
    setDismissed(stored === "true");
  }, []);

  // NOTE: demo-only heuristics. Replace with real profile/payout/mentorship
  // status flags from the backend once available.
  const hasPublishedCourse = courses.some((c) => c.status === "published");
  const hasAnyCourse = courses.length > 0;

  const items: ChecklistItem[] = [
    {
      id: "profile",
      label: "Complete your profile",
      description: "Add a bio and portfolio link so learners know who's teaching.",
      href: "/instructor/settings",
      done: true // NOTE: demo-only, assume complete since session always has a name
    },
    {
      id: "payout",
      label: "Add a payout method",
      description: "Connect a bank or wallet account so you can withdraw earnings.",
      href: "/instructor/payouts/methods",
      done: false
    },
    {
      id: "publish",
      label: "Publish your first course",
      description: "Get your course live and start accepting enrollments.",
      href: "/instructor/courses",
      done: hasPublishedCourse
    },
    {
      id: "mentorship",
      label: "Enable mentorship",
      description: "Offer paid 1-on-1 sessions to learners who finish your courses.",
      href: "/instructor/mentorship",
      done: false
    }
  ];

  const completedCount = items.filter((i) => i.done).length;
  const allDone = completedCount === items.length;

  function handleDismiss() {
    window.localStorage.setItem(DISMISS_KEY, "true");
    setDismissed(true);
  }

  if (!hydrated || dismissed || !hasAnyCourse === false) {
    // still render normally once hydrated; this branch only prevents SSR flash
  }
  if (!hydrated) return null;
  if (dismissed) return null;

  return (
    <div className="mb-10 overflow-hidden rounded-card border border-line bg-card">
      <div className="flex items-center gap-3 px-5 py-4">
        <div className="flex-1">
          <div className="mb-1.5 flex items-center gap-2">
            <h2 className="text-[15px] font-semibold text-ink">Get set up on Saachi AI</h2>
            <span className="rounded-full bg-paper-dim px-2 py-0.5 text-[11px] font-semibold text-ink-soft">
              {completedCount} of {items.length} complete
            </span>
          </div>
          <div className="h-1.5 w-full max-w-xs overflow-hidden rounded-full bg-paper-dim">
            <div
              className="h-full rounded-full bg-gold transition-all duration-300 ease-out"
              style={{ width: `${(completedCount / items.length) * 100}%` }}
            />
          </div>
        </div>

        <button
          type="button"
          onClick={() => setExpanded((v) => !v)}
          aria-label={expanded ? "Collapse checklist" : "Expand checklist"}
          className="flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
        >
          <ChevronDown
            size={16}
            className="transition-transform duration-200 ease-out"
            style={{ transform: expanded ? "rotate(180deg)" : "rotate(0deg)" }}
          />
        </button>

        {allDone && (
          <button
            type="button"
            onClick={handleDismiss}
            aria-label="Dismiss checklist"
            className="flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
          >
            <X size={16} />
          </button>
        )}
      </div>

      {expanded && (
        <div className="border-t border-line px-5 py-2">
          {items.map((item) => (
            <div
              key={item.id}
              className="flex items-center gap-3 border-b border-line py-3 last:border-0"
            >
              <span className={cn("shrink-0", item.done ? "text-teal" : "text-ink-soft/40")}>
                {item.done ? <CircleCheck size={18} /> : <Circle size={18} />}
              </span>
              <div className="min-w-0 flex-1">
                <p
                  className={cn(
                    "text-[13.5px] font-semibold",
                    item.done ? "text-ink-soft line-through" : "text-ink"
                  )}
                >
                  {item.label}
                </p>
                <p className="text-[12px] text-ink-soft">{item.description}</p>
              </div>
              {!item.done && (
                <Link href={item.href} className="shrink-0">
                  <Button size="sm" variant="secondary">
                    Go
                  </Button>
                </Link>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default InstructorOnboardingChecklist;
'@

Write-FileSafe -path $checklistPath -content $checklistContent

# ===========================================================================
# 5. WIRE CHECKLIST INTO DASHBOARD PAGE
# ===========================================================================
Write-Section "Wiring checklist into instructor dashboard"

$dashboardPath = Join-Path $root "apps\web\app\(instructor)\instructor\dashboard\page.tsx"

if (Test-Path $dashboardPath) {
    $dashContent = Get-Content -Path $dashboardPath -Raw

    $importLine = 'import { InstructorBentoCard } from "@/components/ui/instructor-bento-card";'
    $newImportBlock = @'
import { InstructorBentoCard } from "@/components/ui/instructor-bento-card";
import { InstructorOnboardingChecklist } from "@/components/ui/instructor-onboarding-checklist";
'@

    $anchor = 'p-8 text-[14px] text-ink-soft">Here is how your courses are performing.</p>'
    # Fallback anchor: match the subtitle paragraph regardless of exact class list
    $subtitleAnchor = 'Here is how your courses are performing.</p>'

    if ($dashContent.Contains($importLine) -and -not $dashContent.Contains("InstructorOnboardingChecklist")) {
        $dashContent = $dashContent.Replace($importLine, $newImportBlock)
        Write-Host "  [OK] Added checklist import to dashboard page." -ForegroundColor Green
    } elseif ($dashContent.Contains("InstructorOnboardingChecklist")) {
        Write-Host "  [SKIP] Dashboard already imports InstructorOnboardingChecklist." -ForegroundColor Yellow
    } else {
        Write-Host "  [WARN] Could not find expected import line in dashboard page.tsx. Add manually:" -ForegroundColor Yellow
        Write-Host '         import { InstructorOnboardingChecklist } from "@/components/ui/instructor-onboarding-checklist";' -ForegroundColor Yellow
    }

    if ($dashContent.Contains($subtitleAnchor) -and -not $dashContent.Contains("<InstructorOnboardingChecklist")) {
        $replacement = $subtitleAnchor + "`n`n      <InstructorOnboardingChecklist />"
        $dashContent = $dashContent.Replace($subtitleAnchor, $replacement)
        Write-Host "  [OK] Inserted <InstructorOnboardingChecklist /> into dashboard JSX." -ForegroundColor Green
    } elseif ($dashContent.Contains("<InstructorOnboardingChecklist")) {
        Write-Host "  [SKIP] Dashboard JSX already renders InstructorOnboardingChecklist." -ForegroundColor Yellow
    } else {
        Write-Host "  [WARN] Could not find expected subtitle anchor text in dashboard page.tsx." -ForegroundColor Yellow
        Write-Host "         Manually add <InstructorOnboardingChecklist /> right after the page subtitle <p> tag." -ForegroundColor Yellow
    }

    Set-Content -Path $dashboardPath -Value $dashContent -NoNewline -Encoding UTF8
} else {
    Write-Host "  [WARN] Could not find dashboard page at: $dashboardPath" -ForegroundColor Yellow
    Write-Host "         Add <InstructorOnboardingChecklist /> to it manually." -ForegroundColor Yellow
}

# ===========================================================================
# DONE
# ===========================================================================
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " All 3 features written." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Next steps:"
Write-Host "  1. git status / git diff  -> review changes"
Write-Host "  2. pnpm turbo run build   -> verify it compiles"
Write-Host "  3. Commit and push"
Write-Host ""
Write-Host "Note: sidebar routes for these two pages already exist in" -ForegroundColor Yellow
Write-Host "      instructor-sidebar-v2.tsx (Engagement Status / Message Students)," -ForegroundColor Yellow
Write-Host "      so no sidebar changes were needed." -ForegroundColor Yellow