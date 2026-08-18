<#
.SYNOPSIS
  Connects Community Q&A to the SAI2 Instructor module (real data, real replies).
  - Replaces packages/store/src/useCommunityStore.ts:
      adds courseTitle field, instructor-tied seed questions
      (crs_i1/crs_i2/crs_i3), and an isInstructor-aware addAnswer()
  - Replaces the Community placeholder with a real Q&A screen:
    apps/web/app/(instructor)/instructor/community/page.tsx
    (filters by All/Unanswered/Answered + by course, search, reply threads,
    upvotes, filtered to the instructor's own courses via
    useInstructorCourseStore)

  Run this from the SAI2 monorepo root:
  PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>
#>

$ErrorActionPreference = "Stop"

function Write-FileUtf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$RelativePath,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $RelativePath
    $dir = Split-Path -Path $fullPath -Parent
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $utf8NoBom)
    Write-Host "  Wrote: $RelativePath"
}

Write-Host ""
Write-Host "== SAI2: Instructor Community Q&A ==" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# 1) Community store (courseTitle field + isInstructor-aware addAnswer)
# ---------------------------------------------------------------------------
$storeContent = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type CommunityAnswer = {
  id: string;
  authorName: string;
  isInstructor: boolean;
  body: string;
  createdAt: string;
};

export type CommunityQuestion = {
  id: string;
  courseId: string;
  courseTitle?: string;
  authorName: string;
  body: string;
  createdAt: string;
  upvotes: number;
  answers: CommunityAnswer[];
};

// NOTE: demo-only seed data. The first two questions mirror the public
// marketplace dummy courses (crs_001 etc.); the ones below are tied to the
// instructor's own demo courses (crs_i1..crs_i3, see
// packages/store/src/useInstructorCourseStore.ts) so the Instructor ->
// Community Q&A screen has realistic unanswered questions to reply to.
const SEED_QUESTIONS: CommunityQuestion[] = [
  {
    id: "q_1",
    courseId: "crs_001",
    courseTitle: "Prompt Engineering Fundamentals",
    authorName: "Hina Malik",
    body: "For few-shot prompting, how many examples is usually enough before it stops improving results?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 30).toISOString(),
    upvotes: 6,
    answers: [
      {
        id: "a_1",
        authorName: "Sana Rizvi",
        isInstructor: true,
        body: "Usually 3-5 well-chosen examples get you most of the benefit - past that you're often better off improving instructions instead.",
        createdAt: new Date(Date.now() - 1000 * 60 * 60 * 20).toISOString(),
        upvotes: 9
      }
    ]
  },
  {
    id: "q_2",
    courseId: "crs_001",
    courseTitle: "Prompt Engineering Fundamentals",
    authorName: "Bilal Ahmed",
    body: "Does the prompt library template work with Claude and Gemini too, or is it ChatGPT-specific?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 10).toISOString(),
    upvotes: 2,
    answers: []
  },
  {
    id: "q_i1",
    courseId: "crs_i1",
    courseTitle: "Automate Everything with n8n & AI",
    authorName: "Omar Sheikh",
    body: "Does the invoice parsing workflow from module 2 work on n8n cloud, or only self-hosted?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 5).toISOString(),
    upvotes: 4,
    answers: []
  },
  {
    id: "q_i2",
    courseId: "crs_i1",
    courseTitle: "Automate Everything with n8n & AI",
    authorName: "Noor Fatima",
    body: "I'm getting a rate-limit error on the OpenAI node when the workflow runs on a schedule. Any tips on handling that gracefully?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 14).toISOString(),
    upvotes: 3,
    answers: []
  },
  {
    id: "q_i3",
    courseId: "crs_i1",
    courseTitle: "Automate Everything with n8n & AI",
    authorName: "Ali Raza",
    body: "Thanks for the lead-qualification workflow, saved me hours already! Quick question - is there a way to route hot leads straight to WhatsApp instead of Slack?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 40).toISOString(),
    upvotes: 7,
    answers: [
      {
        id: "a_i3_1",
        authorName: "Ayesha Khan",
        isInstructor: true,
        body: "Glad it helped! Yes - swap the Slack node for a WhatsApp Business API node and map the same fields, it's a drop-in replacement.",
        createdAt: new Date(Date.now() - 1000 * 60 * 60 * 36).toISOString(),
        upvotes: 5
      }
    ]
  },
  {
    id: "q_i4",
    courseId: "crs_i2",
    courseTitle: "AI Chatbots for WhatsApp Support",
    authorName: "Sara Iqbal",
    body: "How long did WhatsApp Business API approval take for you? Mine has been pending for 4 days.",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 8).toISOString(),
    upvotes: 5,
    answers: []
  },
  {
    id: "q_i5",
    courseId: "crs_i3",
    courseTitle: "Prompt Engineering for Client Work",
    authorName: "Danish Iqbal",
    body: "Is there a template for pitching this to clients who don't know what prompt engineering even is?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 60).toISOString(),
    upvotes: 2,
    answers: []
  }
];

type CommunityState = {
  questions: CommunityQuestion[];
  addQuestion: (courseId: string, authorName: string, body: string, courseTitle?: string) => void;
  addAnswer: (questionId: string, authorName: string, body: string, isInstructor?: boolean) => void;
  upvoteQuestion: (questionId: string) => void;
};

function genId(prefix: string) {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

export const useCommunityStore = create<CommunityState>()(
  persist(
    (set, get) => ({
      questions: SEED_QUESTIONS,

      addQuestion: (courseId, authorName, body, courseTitle) => {
        const newQuestion: CommunityQuestion = {
          id: genId("q"),
          courseId,
          courseTitle,
          authorName,
          body,
          createdAt: new Date().toISOString(),
          upvotes: 0,
          answers: []
        };
        set({ questions: [newQuestion, ...get().questions] });
      },

      addAnswer: (questionId, authorName, body, isInstructor = false) => {
        set({
          questions: get().questions.map((q) =>
            q.id === questionId
              ? {
                  ...q,
                  answers: [
                    ...q.answers,
                    {
                      id: genId("a"),
                      authorName,
                      isInstructor,
                      body,
                      createdAt: new Date().toISOString(),
                      upvotes: 0
                    }
                  ]
                }
              : q
          )
        });
      },

      upvoteQuestion: (questionId) => {
        set({
          questions: get().questions.map((q) =>
            q.id === questionId ? { ...q, upvotes: q.upvotes + 1 } : q
          )
        });
      }
    }),
    { name: "saachi-community" }
  )
);

'@
Write-FileUtf8NoBom -RelativePath "packages\store\src\useCommunityStore.ts" -Content $storeContent

# ---------------------------------------------------------------------------
# 2) Instructor Community Q&A page
# ---------------------------------------------------------------------------
$pageContent = @'
"use client";

import { useMemo, useState } from "react";
import { MessageSquare, ArrowBigUp, CheckCircle2, Search } from "lucide-react";
import { useCommunityStore, type CommunityQuestion } from "@saachi/store";
import { useInstructorCourseStore } from "@saachi/store";
import { Button, Input, Select, EmptyState, Badge, Textarea, cn } from "@saachi/ui";

const FILTER_OPTIONS = [
  { label: "All questions", value: "all" },
  { label: "Unanswered", value: "unanswered" },
  { label: "Answered", value: "answered" }
];

// NOTE: demo-only "current instructor" identity used when posting a reply.
// Replace with the real authenticated instructor's name once auth/session
// (useSession from @saachi/api-client) is wired through this screen.
const CURRENT_INSTRUCTOR_NAME = "Ayesha Khan";

export default function InstructorCommunityPage() {
  const questions = useCommunityStore((s) => s.questions);
  const myCourses = useInstructorCourseStore((s) => s.courses);

  const [filter, setFilter] = useState("all");
  const [search, setSearch] = useState("");
  const [courseFilter, setCourseFilter] = useState("all");

  const myCourseIds = useMemo(() => new Set(myCourses.map((c) => c.id)), [myCourses]);

  const myQuestions = useMemo(
    () => questions.filter((q) => myCourseIds.has(q.courseId)),
    [questions, myCourseIds]
  );

  const filtered = useMemo(() => {
    let items = [...myQuestions];
    if (filter === "unanswered") items = items.filter((q) => q.answers.length === 0);
    if (filter === "answered") items = items.filter((q) => q.answers.length > 0);
    if (courseFilter !== "all") items = items.filter((q) => q.courseId === courseFilter);
    if (search.trim()) {
      const s = search.toLowerCase();
      items = items.filter((q) => q.body.toLowerCase().includes(s) || q.authorName.toLowerCase().includes(s));
    }
    return items.sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
  }, [myQuestions, filter, courseFilter, search]);

  const unansweredCount = myQuestions.filter((q) => q.answers.length === 0).length;

  const courseOptions = [
    { label: "All courses", value: "all" },
    ...myCourses.map((c) => ({ label: c.title, value: c.id }))
  ];

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Community Q&amp;A</h1>
          <p className="text-[14px] text-ink-soft">
            Answer learner questions across all of your courses.
            {unansweredCount > 0 && (
              <span className="ml-2 font-semibold text-gold-dark">{unansweredCount} awaiting a reply</span>
            )}
          </p>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <div className="relative">
            <Search size={14} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search questions..."
              className="h-10 w-56 rounded-control border border-line-strong bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/50 focus:border-gold"
            />
          </div>
          <Select options={courseOptions} value={courseFilter} onChange={(e) => setCourseFilter(e.target.value)} className="w-52" />
        </div>
      </div>

      <div className="mb-6 flex gap-1.5">
        {FILTER_OPTIONS.map((opt) => (
          <button
            key={opt.value}
            type="button"
            onClick={() => setFilter(opt.value)}
            className={cn(
              "rounded-full px-3.5 py-1.5 text-[12.5px] font-semibold transition-colors duration-150 ease-out",
              filter === opt.value ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
            )}
          >
            {opt.label}
          </button>
        ))}
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No questions here"
          description="Once learners ask questions on your courses, they'll show up here."
        />
      ) : (
        <div className="flex flex-col gap-4">
          {filtered.map((q) => (
            <QuestionCard key={q.id} question={q} />
          ))}
        </div>
      )}
    </div>
  );
}

function QuestionCard({ question }: { question: CommunityQuestion }) {
  const addAnswer = useCommunityStore((s) => s.addAnswer);
  const upvoteQuestion = useCommunityStore((s) => s.upvoteQuestion);

  const [replying, setReplying] = useState(false);
  const [reply, setReply] = useState("");

  const isAnswered = question.answers.length > 0;

  function handleSubmitReply() {
    if (!reply.trim()) return;
    addAnswer(question.id, CURRENT_INSTRUCTOR_NAME, reply.trim(), true);
    setReply("");
    setReplying(false);
  }

  return (
    <div className="rounded-card border border-line bg-card p-5">
      <div className="flex gap-4">
        <div className="flex shrink-0 flex-col items-center gap-1 pt-1">
          <button
            type="button"
            onClick={() => upvoteQuestion(question.id)}
            aria-label="Upvote question"
            className="flex flex-col items-center gap-0.5 text-ink-soft transition-colors hover:text-gold-dark"
          >
            <ArrowBigUp size={18} />
            <span className="text-[12px] font-semibold">{question.upvotes}</span>
          </button>
        </div>

        <div className="min-w-0 flex-1">
          <div className="mb-1.5 flex flex-wrap items-center gap-2">
            {question.courseTitle && (
              <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">
                {question.courseTitle}
              </span>
            )}
            {isAnswered ? (
              <Badge variant="success">
                <CheckCircle2 size={11} className="mr-1" />
                Answered
              </Badge>
            ) : (
              <Badge variant="gold">Needs reply</Badge>
            )}
            <span className="text-[11.5px] text-ink-soft/60">
              {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(question.createdAt))}
            </span>
          </div>

          <p className="mb-1 text-[13px] font-semibold text-ink">{question.authorName}</p>
          <p className="mb-3 text-[14px] leading-relaxed text-ink">{question.body}</p>

          {question.answers.length > 0 && (
            <div className="mb-3 flex flex-col gap-2.5 border-l-2 border-line pl-4">
              {question.answers.map((a) => (
                <div key={a.id}>
                  <div className="mb-0.5 flex items-center gap-1.5">
                    <span className="text-[12.5px] font-semibold text-ink">{a.authorName}</span>
                    {a.isInstructor && (
                      <span className="rounded-full bg-teal-light px-1.5 py-0.5 text-[10px] font-semibold text-teal">
                        Instructor
                      </span>
                    )}
                  </div>
                  <p className="text-[13px] text-ink-soft">{a.body}</p>
                </div>
              ))}
            </div>
          )}

          {replying ? (
            <div className="flex flex-col gap-2">
              <Textarea
                autoFocus
                rows={3}
                placeholder="Write a reply..."
                value={reply}
                onChange={(e) => setReply(e.target.value)}
              />
              <div className="flex gap-2">
                <Button size="sm" disabled={!reply.trim()} onClick={handleSubmitReply}>
                  Post reply
                </Button>
                <Button size="sm" variant="secondary" onClick={() => setReplying(false)}>
                  Cancel
                </Button>
              </div>
            </div>
          ) : (
            <Button size="sm" variant="secondary" onClick={() => setReplying(true)}>
              <MessageSquare size={13} className="mr-1.5" />
              {isAnswered ? "Add another reply" : "Reply"}
            </Button>
          )}
        </div>
      </div>
    </div>
  );
}

'@
Write-FileUtf8NoBom -RelativePath "apps\web\app\(instructor)\instructor\community\page.tsx" -Content $pageContent

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Note: both useCommunityStore and useInstructorCourseStore persist to"
Write-Host "localStorage. If you already have stale data from earlier runs under"
Write-Host "the 'saachi-community' or 'saachi-instructor-courses' keys, clear them"
Write-Host "(DevTools -> Application -> Local Storage) to see the new seed data."
Write-Host ""
Write-Host "Next: restart 'npm run dev' inside apps/web if it was already running."
Write-Host ""