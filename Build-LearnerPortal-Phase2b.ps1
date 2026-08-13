<#
  Build-LearnerPortal-Phase2b.ps1
  ---------------------------------------------------------------------------
  Completes the remaining Learner Portal pages from Doc 2 (Section 11) that
  Phase 2a did not cover. Uses local component state + dummy data for new
  pages (mentorship, community Q&A) since their store shape is not yet known
  — avoids repeating the /orders-style build break. Reuses @saachi/ui only.

  Does NOT touch apps/admin. Does NOT modify existing Phase 2a pages.

  Pages created (all under apps/web/app/(learner)/):
    /certificates/[id]           -> Certificate Detail / Verification View
    /mentorship                  -> Mentorship Booking Page
    /mentorship/sessions         -> My Mentorship Sessions
    /community/[courseId]        -> Community / Course Q&A
    /settings/security           -> Settings - Security
    /settings/billing            -> Settings - Billing
    /settings/privacy            -> Settings - Privacy
    /become-instructor           -> Become an Instructor application

  Run from the SAI2 repo root:
    powershell -ExecutionPolicy Bypass -File .\Build-LearnerPortal-Phase2b.ps1
#>

$ErrorActionPreference = "Stop"
$Root = (Get-Location).Path

function Write-Utf8NoBom {
    param([string]$RelativePath, [string]$Content)
    $fullPath = Join-Path $Root $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($fullPath, $Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  wrote $RelativePath"
}

Write-Host "== SAI2 :: Learner Portal Phase 2b scaffold ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Certificate Detail / Verification View
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/certificates/[id]/page.tsx" @'
"use client";

import { useParams } from "next/navigation";
import { Award, CheckCircle2, Download } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState } from "@saachi/ui";

export default function CertificateVerificationPage() {
  const params = useParams<{ id: string }>();
  const enrollments = useEnrollmentStore((s) => s.enrollments);
  const certificate = enrollments.find(
    (e) => e.courseId === params.id && e.progressPercent === 100
  );

  if (!certificate) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Certificate not found"
          description="This certificate ID doesn't match a completed course, or has been revoked."
        />
      </div>
    );
  }

  const verificationId = `SAI-CERT-${certificate.courseId.slice(0, 8).toUpperCase()}`;

  return (
    <div className="mx-auto max-w-2xl py-10">
      <div className="rounded-card border border-gold-dark/30 bg-gold-tint p-8 text-center">
        <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-card text-gold-dark">
          <Award size={30} />
        </div>
        <p className="text-[13px] font-semibold uppercase tracking-[0.08em] text-gold-dark">
          Certificate of Completion
        </p>
        <h1 className="mt-3 font-display text-[26px] font-bold text-ink">{certificate.title}</h1>
        <p className="mt-2 text-[14px] text-ink-soft">Instructed by {certificate.instructorName}</p>

        <div className="mx-auto mt-6 flex max-w-xs items-center justify-center gap-2 rounded-control bg-card px-4 py-2 text-[13px] text-ink-soft">
          <CheckCircle2 size={15} className="text-teal" />
          Verified - ID {verificationId}
        </div>

        <Button className="mt-6">
          <Download size={14} className="mr-1.5" />
          Download PDF
        </Button>
      </div>

      <p className="mt-6 text-center text-[12px] text-ink-soft/70">
        This certificate can be verified by anyone with this link. No login required.
      </p>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 2. Mentorship Booking Page (local dummy data - no dedicated store yet)
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/mentorship/page.tsx" @'
"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { CalendarDays, Clock } from "lucide-react";
import { Button, Card, EmptyState } from "@saachi/ui";

type MentorSlot = {
  id: string;
  instructorName: string;
  expertise: string;
  rate: string;
  slots: string[];
};

const MENTORS: MentorSlot[] = [
  {
    id: "m1",
    instructorName: "Ayesha Khan",
    expertise: "AI Automation & Workflow Tools",
    rate: "$40 / 30 min",
    slots: ["Mon 10:00 AM", "Wed 2:00 PM", "Fri 11:00 AM"]
  },
  {
    id: "m2",
    instructorName: "Hamza Malik",
    expertise: "AI Integration for Developers",
    rate: "$55 / 45 min",
    slots: ["Tue 4:00 PM", "Thu 9:00 AM"]
  }
];

export default function MentorshipBookingPage() {
  const [selectedMentor, setSelectedMentor] = useState<string | null>(null);
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);
  const [booked, setBooked] = useState(false);

  const mentor = useMemo(() => MENTORS.find((m) => m.id === selectedMentor), [selectedMentor]);

  function handleBook() {
    if (!mentor || !selectedSlot) return;
    // NOTE: demo-only booking, no payment/calendar integration wired up yet.
    setBooked(true);
  }

  if (booked && mentor) {
    return (
      <div className="mx-auto max-w-lg py-16 text-center">
        <EmptyState
          title="Session booked"
          description={`Your session with ${mentor.instructorName} on ${selectedSlot} is confirmed. Check My Mentorship Sessions for the call link.`}
          action={
            <Link href="/mentorship/sessions">
              <Button>View my sessions</Button>
            </Link>
          }
        />
      </div>
    );
  }

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Book mentorship</h1>
      <p className="mb-8 text-[14px] text-ink-soft">1-on-1 sessions with verified instructors.</p>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        {MENTORS.map((m) => (
          <Card
            key={m.id}
            className={`cursor-pointer p-5 transition-colors ${
              selectedMentor === m.id ? "border-gold-dark/60" : ""
            }`}
            onClick={() => {
              setSelectedMentor(m.id);
              setSelectedSlot(null);
            }}
          >
            <h3 className="text-[15px] font-semibold text-ink">{m.instructorName}</h3>
            <p className="mt-1 text-[13px] text-ink-soft">{m.expertise}</p>
            <p className="mt-2 font-mono text-[14px] font-semibold text-ink">{m.rate}</p>
          </Card>
        ))}
      </div>

      {mentor && (
        <div className="mt-8 rounded-card border border-line bg-card p-6">
          <h2 className="mb-4 flex items-center gap-2 text-[15px] font-semibold text-ink">
            <CalendarDays size={16} />
            Available slots with {mentor.instructorName}
          </h2>
          <div className="flex flex-wrap gap-2">
            {mentor.slots.map((slot) => (
              <button
                key={slot}
                type="button"
                onClick={() => setSelectedSlot(slot)}
                className={`flex items-center gap-1.5 rounded-control border px-3 py-2 text-[13px] font-medium transition-colors ${
                  selectedSlot === slot
                    ? "border-gold-dark bg-gold-tint text-ink"
                    : "border-line text-ink-soft hover:bg-paper-dim"
                }`}
              >
                <Clock size={13} />
                {slot}
              </button>
            ))}
          </div>

          <Button className="mt-6" disabled={!selectedSlot} onClick={handleBook}>
            Confirm booking
          </Button>
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 3. My Mentorship Sessions (local dummy data)
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/mentorship/sessions/page.tsx" @'
"use client";

import { Video, CalendarDays } from "lucide-react";
import { Button, EmptyState, StatusPill } from "@saachi/ui";

type Session = {
  id: string;
  instructorName: string;
  topic: string;
  when: string;
  status: "upcoming" | "past";
};

const SESSIONS: Session[] = [
  { id: "s1", instructorName: "Ayesha Khan", topic: "n8n workflow review", when: "Mon, 10:00 AM", status: "upcoming" },
  { id: "s2", instructorName: "Hamza Malik", topic: "API integration Q&A", when: "Last Thu, 9:00 AM", status: "past" }
];

export default function MyMentorshipSessionsPage() {
  const upcoming = SESSIONS.filter((s) => s.status === "upcoming");
  const past = SESSIONS.filter((s) => s.status === "past");

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">My Mentorship Sessions</h1>

      <h2 className="mb-3 text-[15px] font-semibold text-ink">Upcoming</h2>
      {upcoming.length === 0 ? (
        <EmptyState title="No upcoming sessions" description="Book a mentorship session to see it here." />
      ) : (
        <div className="mb-8 flex flex-col gap-3">
          {upcoming.map((s) => (
            <div key={s.id} className="flex items-center gap-4 rounded-card border border-line bg-card p-4">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-gold-tint text-gold-dark">
                <CalendarDays size={16} />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[14px] font-semibold text-ink">{s.topic}</p>
                <p className="text-[13px] text-ink-soft">
                  with {s.instructorName} - {s.when}
                </p>
              </div>
              <StatusPill status="active">Upcoming</StatusPill>
              <Button size="sm">
                <Video size={14} className="mr-1.5" />
                Join call
              </Button>
            </div>
          ))}
        </div>
      )}

      <h2 className="mb-3 text-[15px] font-semibold text-ink">Past</h2>
      {past.length === 0 ? (
        <EmptyState title="No past sessions" description="Completed sessions will show up here." />
      ) : (
        <div className="flex flex-col gap-3">
          {past.map((s) => (
            <div key={s.id} className="flex items-center gap-4 rounded-card border border-line bg-card p-4 opacity-80">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-paper-dim text-ink-soft">
                <CalendarDays size={16} />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[14px] font-semibold text-ink">{s.topic}</p>
                <p className="text-[13px] text-ink-soft">
                  with {s.instructorName} - {s.when}
                </p>
              </div>
              <StatusPill status="neutral">Completed</StatusPill>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 4. Community / Course Q&A (local state, keyed by courseId)
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/community/[courseId]/page.tsx" @'
"use client";

import { useParams } from "next/navigation";
import { useState, type FormEvent } from "react";
import { ArrowBigUp, MessageCircle } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { Button, EmptyState, Loading, Textarea } from "@saachi/ui";

type Question = {
  id: string;
  author: string;
  body: string;
  upvotes: number;
  instructorAnswer?: string;
};

const SEED_QUESTIONS: Question[] = [
  {
    id: "q1",
    author: "Fatima R.",
    body: "Does this course cover the latest API version?",
    upvotes: 4,
    instructorAnswer: "Yes, updated for the current API as of this course's last revision."
  },
  { id: "q2", author: "Bilal S.", body: "Any prerequisites before lesson 3?", upvotes: 1 }
];

export default function CourseCommunityPage() {
  const params = useParams<{ courseId: string }>();
  const { data: course, isLoading } = useCourseDetail(params.courseId);
  const [questions, setQuestions] = useState<Question[]>(SEED_QUESTIONS);
  const [newQuestion, setNewQuestion] = useState("");

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!newQuestion.trim()) return;
    setQuestions((prev) => [
      { id: `q${Date.now()}`, author: "You", body: newQuestion.trim(), upvotes: 0 },
      ...prev
    ]);
    setNewQuestion("");
  }

  function handleUpvote(id: string) {
    setQuestions((prev) => prev.map((q) => (q.id === id ? { ...q, upvotes: q.upvotes + 1 } : q)));
  }

  if (isLoading) {
    return <Loading label="Loading discussion..." />;
  }

  return (
    <div className="mx-auto max-w-3xl">
      <p className="mb-1 text-[13px] font-medium text-gold-dark">{course?.title ?? "Course"}</p>
      <h1 className="mb-6 flex items-center gap-2 font-display text-[24px] font-bold text-ink">
        <MessageCircle size={22} />
        Community Q&A
      </h1>

      <form onSubmit={handleSubmit} className="mb-8 flex flex-col gap-3">
        <Textarea
          label="Ask a question"
          rows={3}
          value={newQuestion}
          onChange={(e) => setNewQuestion(e.target.value)}
          placeholder="What would you like to ask?"
        />
        <Button type="submit" className="self-start">
          Post question
        </Button>
      </form>

      {questions.length === 0 ? (
        <EmptyState title="No questions yet" description="Be the first to ask something." />
      ) : (
        <div className="flex flex-col gap-4">
          {questions.map((q) => (
            <div key={q.id} className="rounded-card border border-line bg-card p-4">
              <div className="flex items-start gap-3">
                <button
                  type="button"
                  onClick={() => handleUpvote(q.id)}
                  className="flex flex-col items-center gap-0.5 rounded-control border border-line px-2 py-1 text-ink-soft hover:bg-paper-dim"
                  aria-label="Upvote"
                >
                  <ArrowBigUp size={15} />
                  <span className="text-[11px] font-semibold">{q.upvotes}</span>
                </button>
                <div className="min-w-0 flex-1">
                  <p className="text-[13px] font-semibold text-ink">{q.author}</p>
                  <p className="mt-1 text-[14px] text-ink-soft">{q.body}</p>

                  {q.instructorAnswer && (
                    <div className="mt-3 rounded-control bg-gold-tint px-3 py-2">
                      <p className="text-[12px] font-semibold text-gold-dark">Instructor answer</p>
                      <p className="mt-0.5 text-[13px] text-ink">{q.instructorAnswer}</p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 5. Settings - Security
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/settings/security/page.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import { ShieldCheck, Smartphone } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState, Input, Switch } from "@saachi/ui";

export default function SettingsSecurityPage() {
  const { data: session } = useSession();
  const [twoFactorEnabled, setTwoFactorEnabled] = useState(false);
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your security settings." />;
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend auth mutation wired up yet.
    setCurrentPassword("");
    setNewPassword("");
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Security</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <ShieldCheck size={16} />
          Change password
        </h2>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input
            label="Current password"
            type="password"
            value={currentPassword}
            onChange={(e) => setCurrentPassword(e.target.value)}
          />
          <Input
            label="New password"
            type="password"
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
          />
          <Button type="submit" className="self-start">
            Update password
          </Button>
        </form>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Smartphone size={16} className="text-ink-soft" />
            <div>
              <p className="text-[14px] font-semibold text-ink">Two-factor authentication</p>
              <p className="text-[13px] text-ink-soft">Add an extra layer of security to your account.</p>
            </div>
          </div>
          <Switch checked={twoFactorEnabled} onChange={setTwoFactorEnabled} aria-label="Toggle two-factor authentication" />
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-2 text-[15px] font-semibold text-ink">Active sessions</h2>
        <p className="text-[13px] text-ink-soft">This device - {session.email}</p>
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 6. Settings - Billing
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/settings/billing/page.tsx" @'
"use client";

import { CreditCard } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState, Input } from "@saachi/ui";

export default function SettingsBillingPage() {
  const { data: session } = useSession();

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your billing settings." />;
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Billing</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <CreditCard size={16} />
          Saved payment methods
        </h2>
        <EmptyState
          title="No saved payment methods"
          description="Payment methods you use at checkout can be saved here for next time."
        />
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Billing address</h2>
        <div className="flex flex-col gap-4">
          <Input label="Full name" defaultValue={session.fullName} />
          <Input label="Address line 1" placeholder="Street address" />
          <Input label="City" placeholder="City" />
          <Button className="self-start">Save address</Button>
        </div>
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 7. Settings - Privacy
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/settings/privacy/page.tsx" @'
"use client";

import { useState } from "react";
import { Download, ShieldAlert, Trash2 } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState, Switch } from "@saachi/ui";

export default function SettingsPrivacyPage() {
  const { data: session } = useSession();
  const [cookiePrefs, setCookiePrefs] = useState({ analytics: true, marketing: false });
  const [exportRequested, setExportRequested] = useState(false);

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your privacy settings." />;
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Privacy</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-3 text-[15px] font-semibold text-ink">Cookie preferences</h2>
        <div className="flex flex-col gap-3">
          <div className="flex items-center justify-between">
            <p className="text-[13px] text-ink-soft">Analytics cookies</p>
            <Switch
              checked={cookiePrefs.analytics}
              onChange={(v) => setCookiePrefs((p) => ({ ...p, analytics: v }))}
              aria-label="Toggle analytics cookies"
            />
          </div>
          <div className="flex items-center justify-between">
            <p className="text-[13px] text-ink-soft">Marketing cookies</p>
            <Switch
              checked={cookiePrefs.marketing}
              onChange={(v) => setCookiePrefs((p) => ({ ...p, marketing: v }))}
              aria-label="Toggle marketing cookies"
            />
          </div>
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-2 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <Download size={16} />
          Data export
        </h2>
        <p className="mb-4 text-[13px] text-ink-soft">
          Request a copy of the personal data associated with your account.
        </p>
        <Button variant="secondary" disabled={exportRequested} onClick={() => setExportRequested(true)}>
          {exportRequested ? "Export requested" : "Request data export"}
        </Button>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-error/30 bg-error-tint p-6">
        <h2 className="mb-2 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <ShieldAlert size={16} />
          Delete account
        </h2>
        <p className="mb-4 text-[13px] text-ink-soft">
          Permanently delete your account and all associated data. This cannot be undone.
        </p>
        <Button variant="danger">
          <Trash2 size={14} className="mr-1.5" />
          Request account deletion
        </Button>
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 8. Become an Instructor - Application Page
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(learner)/become-instructor/page.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { GraduationCap } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState, Input, Textarea } from "@saachi/ui";

export default function BecomeInstructorPage() {
  const router = useRouter();
  const { data: session } = useSession();
  const [bio, setBio] = useState("");
  const [expertise, setExpertise] = useState("");
  const [portfolioUrl, setPortfolioUrl] = useState("");
  const [submitted, setSubmitted] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to apply as an instructor." />;
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    // NOTE: demo-only, no backend application-review workflow wired up yet.
    setTimeout(() => {
      setSubmitting(false);
      setSubmitted(true);
    }, 600);
  }

  if (submitted) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Application submitted"
          description="Our team will review your instructor application and get back to you by email."
          action={<Button onClick={() => router.push("/dashboard")}>Back to dashboard</Button>}
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 flex items-center gap-2 font-display text-[26px] font-bold text-ink">
        <GraduationCap size={24} />
        Become an instructor
      </h1>
      <p className="mb-8 text-[14px] text-ink-soft">
        Tell us about your expertise. Applications are reviewed manually before approval.
      </p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Textarea
          label="Bio"
          required
          rows={4}
          value={bio}
          onChange={(e) => setBio(e.target.value)}
          placeholder="Tell learners about your background and experience"
        />
        <Input
          label="Area of expertise"
          required
          value={expertise}
          onChange={(e) => setExpertise(e.target.value)}
          placeholder="e.g. AI Automation & Workflow Tools"
        />
        <Input
          label="Portfolio link"
          value={portfolioUrl}
          onChange={(e) => setPortfolioUrl(e.target.value)}
          placeholder="GitHub, LinkedIn, or personal site"
        />
        <Button type="submit" size="lg" loading={submitting} className="self-start">
          Submit application
        </Button>
      </form>
    </div>
  );
}
'@

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Pages created under apps/web/app/(learner)/:"
Write-Host "  certificates/[id]/page.tsx     -> /certificates/[id]  (verification view)"
Write-Host "  mentorship/page.tsx            -> /mentorship  (booking)"
Write-Host "  mentorship/sessions/page.tsx   -> /mentorship/sessions"
Write-Host "  community/[courseId]/page.tsx  -> /community/[courseId]"
Write-Host "  settings/security/page.tsx     -> /settings/security"
Write-Host "  settings/billing/page.tsx      -> /settings/billing"
Write-Host "  settings/privacy/page.tsx      -> /settings/privacy"
Write-Host "  become-instructor/page.tsx     -> /become-instructor"
Write-Host ""
Write-Host "apps/admin was NOT touched. Existing Phase 2a pages were NOT modified."
Write-Host ""
Write-Host "NOTE: mentorship and community pages use local component state + dummy"
Write-Host "data (no dedicated store yet) to avoid guessing unknown store shapes."
Write-Host ""
Write-Host "Now run: pnpm --filter web build"