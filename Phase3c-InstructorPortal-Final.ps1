# Phase3c-InstructorPortal-Final.ps1
# Run from: SAI2/ root
# Creates Instructor Portal Phase 3c screens (Doc 2, Section 12, items 15-20):
#   15. Promotions / Boost Courses
#   16. Mentorship Settings (instructor side)
#   17. Reviews Management
#   18. Students List
#   19. Instructor Settings
#   20. Verification Status Page
#
# Completes all 20 Instructor Portal screens per Doc 2 spec.
# Safety note: only verified-safe @saachi/ui components used (Button, Input,
# Select, Textarea, EmptyState, Badge (gold|success|error only), KpiCard, cn).

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
# 15. Promotions / Boost Courses — (instructor)/instructor/promotions/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\promotions\page.tsx" @'
"use client";

import { useState } from "react";
import { Rocket, Check } from "lucide-react";
import { Button, Select, EmptyState, Badge, cn } from "@saachi/ui";

type PackageTier = "bronze" | "silver" | "gold";

const PACKAGES: {
  tier: PackageTier;
  name: string;
  price: string;
  perks: string[];
}[] = [
  { tier: "bronze", name: "Bronze Boost", price: "$19", perks: ["Category page pinning (7 days)", "Basic visibility badge"] },
  { tier: "silver", name: "Silver Boost", price: "$49", perks: ["Everything in Bronze", "Top-of-search placement (7 days)", "Silver visibility badge"] },
  { tier: "gold", name: "Gold Boost", price: "$99", perks: ["Everything in Silver", "Homepage featured slot (7 days)", "Gold visibility badge"] }
];

// NOTE: demo-only dummy data. Replace with useInstructorCourses() once confirmed.
const COURSE_OPTIONS = [{ label: "Select a course...", value: "" }];

export default function InstructorPromotionsPage() {
  const [selectedCourse, setSelectedCourse] = useState("");
  const [purchasing, setPurchasing] = useState<PackageTier | null>(null);
  const [purchased, setPurchased] = useState<PackageTier | null>(null);

  function handlePurchase(tier: PackageTier) {
    if (!selectedCourse) return;
    setPurchasing(tier);
    // NOTE: demo-only, no backend promotion-purchase mutation wired up yet.
    setTimeout(() => {
      setPurchasing(null);
      setPurchased(tier);
    }, 700);
  }

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Promotions</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Boost your course visibility with a promotion package.</p>

      <div className="mb-8 max-w-sm">
        <Select
          label="Course to promote"
          options={COURSE_OPTIONS}
          value={selectedCourse}
          onChange={(e) => setSelectedCourse(e.target.value)}
        />
        {COURSE_OPTIONS.length === 1 && (
          <p className="mt-2 text-[12px] text-ink-soft">
            You don&apos;t have any published courses to promote yet.
          </p>
        )}
      </div>

      <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
        {PACKAGES.map((pkg) => (
          <div
            key={pkg.tier}
            className={cn(
              "flex flex-col rounded-card border p-6",
              pkg.tier === "gold" ? "border-gold-dark/50 bg-gold-tint" : "border-line bg-card"
            )}
          >
            {pkg.tier === "gold" && (
              <Badge variant="gold" className="mb-3 self-start">
                Best value
              </Badge>
            )}
            <h2 className="font-display text-[18px] font-semibold text-ink">{pkg.name}</h2>
            <p className="mt-1 font-mono text-[24px] font-bold text-ink">{pkg.price}</p>
            <ul className="my-5 flex flex-1 flex-col gap-2 text-[13px] text-ink-soft">
              {pkg.perks.map((perk) => (
                <li key={perk} className="flex items-start gap-2">
                  <Check size={14} className="mt-0.5 shrink-0 text-teal" />
                  {perk}
                </li>
              ))}
            </ul>
            <Button
              variant={pkg.tier === "gold" ? "primary" : "secondary"}
              disabled={!selectedCourse || purchasing !== null}
              onClick={() => handlePurchase(pkg.tier)}
              className="w-full"
            >
              <Rocket size={14} className="mr-1.5" />
              {purchased === pkg.tier ? "Purchased" : purchasing === pkg.tier ? "Processing..." : "Boost course"}
            </Button>
          </div>
        ))}
      </div>

      <h2 className="mb-4 mt-12 font-display text-[20px] font-semibold text-ink">Active promotions</h2>
      <EmptyState title="No active promotions" description="Purchased boost packages will appear here." />
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 16. Mentorship Settings (instructor side) — (instructor)/instructor/mentorship/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\mentorship\page.tsx" @'
"use client";

import { useState } from "react";
import { CalendarDays, Plus, Trash2 } from "lucide-react";
import { Button, Input, Select, EmptyState } from "@saachi/ui";

type Slot = { id: string; day: string; time: string };

const DAY_OPTIONS = [
  { label: "Monday", value: "Mon" },
  { label: "Tuesday", value: "Tue" },
  { label: "Wednesday", value: "Wed" },
  { label: "Thursday", value: "Thu" },
  { label: "Friday", value: "Fri" },
  { label: "Saturday", value: "Sat" },
  { label: "Sunday", value: "Sun" }
];

let slotCounter = 0;

export default function InstructorMentorshipSettingsPage() {
  const [enabled, setEnabled] = useState(false);
  const [hourlyRate, setHourlyRate] = useState("40");
  const [sessionLength, setSessionLength] = useState("30");
  const [day, setDay] = useState("Mon");
  const [time, setTime] = useState("");
  const [slots, setSlots] = useState<Slot[]>([]);
  const [saved, setSaved] = useState(false);

  function addSlot() {
    if (!time.trim()) return;
    slotCounter += 1;
    setSlots((prev) => [...prev, { id: `slot${slotCounter}`, day, time }]);
    setTime("");
  }

  function removeSlot(id: string) {
    setSlots((prev) => prev.filter((s) => s.id !== id));
  }

  function handleSave() {
    // NOTE: demo-only, no backend mentorship-settings mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Mentorship Settings</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Offer paid 1-on-1 mentorship sessions to learners.</p>

      <div className="mb-6 flex items-center justify-between rounded-card border border-line bg-card p-5">
        <div>
          <p className="text-[14px] font-semibold text-ink">Enable mentorship</p>
          <p className="text-[13px] text-ink-soft">Allow learners to book paid sessions with you.</p>
        </div>
        <input
          type="checkbox"
          checked={enabled}
          onChange={(e) => setEnabled(e.target.checked)}
          aria-label="Toggle mentorship availability"
          className="h-4 w-4 accent-gold-dark"
        />
      </div>

      {enabled && (
        <>
          <div className="mb-6 grid grid-cols-1 gap-4 rounded-card border border-line bg-card p-5 sm:grid-cols-2">
            <Input label="Hourly rate (USD)" type="number" value={hourlyRate} onChange={(e) => setHourlyRate(e.target.value)} />
            <Select
              label="Session length (minutes)"
              options={[
                { label: "30 minutes", value: "30" },
                { label: "45 minutes", value: "45" },
                { label: "60 minutes", value: "60" }
              ]}
              value={sessionLength}
              onChange={(e) => setSessionLength(e.target.value)}
            />
          </div>

          <div className="rounded-card border border-line bg-card p-5">
            <h2 className="mb-3 flex items-center gap-2 text-[15px] font-semibold text-ink">
              <CalendarDays size={16} />
              Weekly availability
            </h2>

            {slots.length === 0 ? (
              <EmptyState title="No availability set" description="Add time slots when learners can book you." />
            ) : (
              <ul className="mb-4 flex flex-col gap-2">
                {slots.map((s) => (
                  <li key={s.id} className="flex items-center justify-between rounded-control bg-paper-dim px-3 py-2 text-[13px] text-ink">
                    {s.day} — {s.time}
                    <button type="button" onClick={() => removeSlot(s.id)} aria-label="Remove slot" className="text-ink-soft hover:text-error">
                      <Trash2 size={14} />
                    </button>
                  </li>
                ))}
              </ul>
            )}

            <div className="flex flex-wrap items-end gap-2">
              <Select options={DAY_OPTIONS} value={day} onChange={(e) => setDay(e.target.value)} className="w-36" />
              <Input value={time} onChange={(e) => setTime(e.target.value)} placeholder="e.g. 10:00 AM" className="w-40" />
              <Button variant="secondary" onClick={addSlot}>
                <Plus size={14} className="mr-1.5" />
                Add slot
              </Button>
            </div>
          </div>
        </>
      )}

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save settings"}
      </Button>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 17. Reviews Management — (instructor)/instructor/reviews/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\reviews\page.tsx" @'
"use client";

import { useState } from "react";
import { Star } from "lucide-react";
import { Button, Textarea, EmptyState } from "@saachi/ui";

type Review = {
  id: string;
  courseTitle: string;
  author: string;
  rating: number;
  comment: string;
  reply?: string;
};

// NOTE: demo-only dummy data. Replace with useInstructorReviews() once confirmed.
const REVIEWS: Review[] = [];

export default function InstructorReviewsPage() {
  const [replies, setReplies] = useState<Record<string, string>>({});
  const [submittedIds, setSubmittedIds] = useState<Set<string>>(new Set());

  function handleReplyChange(id: string, value: string) {
    setReplies((prev) => ({ ...prev, [id]: value }));
  }

  function handleSubmitReply(id: string) {
    // NOTE: demo-only, no backend review-reply mutation wired up yet.
    setSubmittedIds((prev) => new Set(prev).add(id));
  }

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Reviews</h1>
      <p className="mb-8 text-[14px] text-ink-soft">View and respond to reviews on your courses.</p>

      {REVIEWS.length === 0 ? (
        <EmptyState title="No reviews yet" description="Reviews from learners on your courses will appear here." />
      ) : (
        <div className="flex flex-col gap-4">
          {REVIEWS.map((r) => (
            <div key={r.id} className="rounded-card border border-line bg-card p-5">
              <div className="mb-1 flex items-center justify-between">
                <p className="text-[14px] font-semibold text-ink">{r.courseTitle}</p>
                <span className="flex items-center gap-0.5 text-gold-dark">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Star key={i} size={13} fill={i < r.rating ? "currentColor" : "none"} />
                  ))}
                </span>
              </div>
              <p className="mb-1 text-[13px] font-medium text-ink-soft">{r.author}</p>
              <p className="mb-3 text-[14px] text-ink">{r.comment}</p>

              {r.reply || submittedIds.has(r.id) ? (
                <div className="rounded-control bg-paper-dim px-3 py-2 text-[13px] text-ink-soft">
                  <span className="font-semibold text-ink">Your reply: </span>
                  {r.reply ?? replies[r.id]}
                </div>
              ) : (
                <div className="flex flex-col gap-2">
                  <Textarea
                    rows={2}
                    placeholder="Write a reply..."
                    value={replies[r.id] ?? ""}
                    onChange={(e) => handleReplyChange(r.id, e.target.value)}
                  />
                  <Button size="sm" className="self-start" disabled={!replies[r.id]?.trim()} onClick={() => handleSubmitReply(r.id)}>
                    Post reply
                  </Button>
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

# ---------------------------------------------------------------------------
# 18. Students List — (instructor)/instructor/students/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\students\page.tsx" @'
"use client";

import { useState } from "react";
import { MessageCircle } from "lucide-react";
import { Button, Input, EmptyState, Badge } from "@saachi/ui";

type Student = {
  id: string;
  name: string;
  courseTitle: string;
  progressPercent: number;
  lastActive: string;
};

// NOTE: demo-only dummy data. Replace with useInstructorStudents() once confirmed.
const STUDENTS: Student[] = [];

export default function InstructorStudentsPage() {
  const [search, setSearch] = useState("");

  const filtered = STUDENTS.filter((s) =>
    s.name.toLowerCase().includes(search.toLowerCase()) || s.courseTitle.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <h1 className="font-display text-[26px] font-bold text-ink">Students</h1>
        <Input
          placeholder="Search students or courses..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-64"
        />
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          title="No students yet"
          description="Once learners enroll in your courses, they'll appear here."
        />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Student</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Course</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Progress</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Last active</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Actions</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((s) => (
                <tr key={s.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3.5 font-medium text-ink">{s.name}</td>
                  <td className="px-4 py-3.5 text-ink-soft">{s.courseTitle}</td>
                  <td className="px-4 py-3.5">
                    <div className="flex items-center gap-2">
                      <div className="h-1.5 w-24 overflow-hidden rounded-full bg-paper-dim">
                        <div className="h-full rounded-full bg-gold" style={{ width: `${s.progressPercent}%` }} />
                      </div>
                      <span className="text-ink-soft">{s.progressPercent}%</span>
                      {s.progressPercent === 100 && <Badge variant="success">Done</Badge>}
                    </div>
                  </td>
                  <td className="px-4 py-3.5 text-ink-soft">{s.lastActive}</td>
                  <td className="px-4 py-3.5">
                    <Button size="sm" variant="secondary">
                      <MessageCircle size={13} className="mr-1.5" />
                      Message
                    </Button>
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
# 19. Instructor Settings — (instructor)/instructor/settings/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\settings\page.tsx" @'
"use client";

import { useState } from "react";
import { useSession } from "@saachi/api-client";
import { Button, Input, Textarea, EmptyState } from "@saachi/ui";

export default function InstructorSettingsPage() {
  const { data: session } = useSession();

  const [bio, setBio] = useState("");
  const [portfolioUrl, setPortfolioUrl] = useState("");
  const [taxId, setTaxId] = useState("");
  const [emailNotifs, setEmailNotifs] = useState(true);
  const [qaNotifs, setQaNotifs] = useState(true);
  const [saved, setSaved] = useState(false);

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your instructor settings." />;
  }

  function handleSave() {
    // NOTE: demo-only, no backend instructor-settings mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Instructor Settings</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Profile</h2>
        <div className="flex flex-col gap-4">
          <Input label="Full name" defaultValue={session.fullName} />
          <Textarea label="Instructor bio" rows={4} value={bio} onChange={(e) => setBio(e.target.value)} placeholder="Tell learners about your background and expertise" />
          <Input label="Portfolio link" value={portfolioUrl} onChange={(e) => setPortfolioUrl(e.target.value)} placeholder="GitHub, LinkedIn, or personal site" />
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Payout tax info</h2>
        <Input label="Tax ID / NTN (optional)" value={taxId} onChange={(e) => setTaxId(e.target.value)} />
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Notification preferences</h2>
        <div className="flex flex-col gap-3">
          <label className="flex items-center justify-between">
            <span className="text-[13px] text-ink-soft">Email me about new sales</span>
            <input
              type="checkbox"
              checked={emailNotifs}
              onChange={(e) => setEmailNotifs(e.target.checked)}
              aria-label="Toggle sales email notifications"
              className="h-4 w-4 accent-gold-dark"
            />
          </label>
          <label className="flex items-center justify-between">
            <span className="text-[13px] text-ink-soft">Email me about new Q&amp;A questions</span>
            <input
              type="checkbox"
              checked={qaNotifs}
              onChange={(e) => setQaNotifs(e.target.checked)}
              aria-label="Toggle Q&A email notifications"
              className="h-4 w-4 accent-gold-dark"
            />
          </label>
        </div>
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save changes"}
      </Button>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 20. Verification Status Page — (instructor)/instructor/verification/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\verification\page.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import { ShieldCheck, UploadCloud, Clock, CheckCircle2, XCircle } from "lucide-react";
import { Button, Input, Badge, cn } from "@saachi/ui";

type VerificationStatus = "not_submitted" | "pending" | "verified" | "rejected";

export default function InstructorVerificationPage() {
  // NOTE: demo-only local state. Replace with useInstructorVerification() once confirmed.
  const [status, setStatus] = useState<VerificationStatus>("not_submitted");
  const [idFileName, setIdFileName] = useState<string | null>(null);
  const [portfolioUrl, setPortfolioUrl] = useState("");
  const [introVideoUrl, setIntroVideoUrl] = useState("");

  function handleIdSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) setIdFileName(file.name);
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend verification-submission mutation wired up yet.
    setStatus("pending");
  }

  const STATUS_META: Record<VerificationStatus, { label: string; variant?: "gold" | "success" | "error"; icon: typeof Clock }> = {
    not_submitted: { label: "Not submitted", icon: ShieldCheck },
    pending: { label: "Pending review", variant: "gold", icon: Clock },
    verified: { label: "Verified", variant: "success", icon: CheckCircle2 },
    rejected: { label: "Rejected", variant: "error", icon: XCircle }
  };

  const meta = STATUS_META[status];
  const Icon = meta.icon;

  return (
    <div className="mx-auto max-w-lg">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Verification Status</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Get verified to unlock a lower commission tier and a trust badge.</p>

      <div
        className={cn(
          "mb-8 flex items-center gap-3 rounded-card border p-5",
          status === "verified" ? "border-success/30 bg-success-tint" :
          status === "rejected" ? "border-error/30 bg-error-tint" :
          status === "pending" ? "border-gold-dark/30 bg-gold-tint" :
          "border-line bg-card"
        )}
      >
        <Icon size={22} className="shrink-0 text-ink" />
        <div className="flex-1">
          <p className="text-[14px] font-semibold text-ink">Current status</p>
          {meta.variant ? (
            <Badge variant={meta.variant} className="mt-1">{meta.label}</Badge>
          ) : (
            <Badge className="mt-1">{meta.label}</Badge>
          )}
        </div>
      </div>

      {(status === "not_submitted" || status === "rejected") && (
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div>
            <p className="mb-2 text-[13px] font-medium text-ink">Government ID or business registration</p>
            <label className="flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
              <UploadCloud size={16} />
              {idFileName ?? "Upload ID document"}
              <input type="file" accept="image/*,.pdf" className="hidden" onChange={handleIdSelect} required />
            </label>
          </div>

          <Input
            label="Portfolio / proof-of-work link"
            required
            value={portfolioUrl}
            onChange={(e) => setPortfolioUrl(e.target.value)}
            placeholder="GitHub, LinkedIn, or past project samples"
          />

          <Input
            label="Intro video link (optional)"
            value={introVideoUrl}
            onChange={(e) => setIntroVideoUrl(e.target.value)}
            placeholder="A short video introducing yourself"
          />

          <Button type="submit" size="lg" className="self-start" disabled={!idFileName || !portfolioUrl.trim()}>
            Submit for verification
          </Button>
        </form>
      )}

      {status === "pending" && (
        <p className="text-[13px] text-ink-soft">
          Your submission is under review. This typically takes 2-3 business days.
        </p>
      )}
    </div>
  );
}
'@

Write-Host ""
Write-Host "Phase 3c done - Instructor Portal is now 20/20 complete." -ForegroundColor Cyan
Write-Host "Now verify locally before pushing:" -ForegroundColor Cyan
Write-Host "  pnpm --filter web build"
Write-Host ""
Write-Host "If clean, then:" -ForegroundColor Cyan
Write-Host "  git add ."
Write-Host "  git commit -m `"feat: Phase 3c Instructor Portal final (promotions, mentorship, reviews, students, settings, verification) - 20/20 complete`""
Write-Host "  git push"
Write-Host ""
Write-Host "Test routes after deploy (must be logged in):" -ForegroundColor Cyan
Write-Host "  /instructor/promotions"
Write-Host "  /instructor/mentorship"
Write-Host "  /instructor/reviews"
Write-Host "  /instructor/students"
Write-Host "  /instructor/settings"
Write-Host "  /instructor/verification"