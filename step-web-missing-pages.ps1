<#
    step-web-missing-pages.ps1

    Creates the 5 missing instructor pages in apps/web:
      1. instructor/courses/[id]/edit/page.tsx
      2. instructor/courses/[id]/curriculum/page.tsx
      3. instructor/courses/[id]/pricing/page.tsx
      4. instructor/courses/[id]/preview/page.tsx
      5. instructor/payouts/methods/page.tsx

    Run from SAI2 root:
      PS D:\...\SAI2> .\step-web-missing-pages.ps1

    PS 5.1 safe: uses [System.IO.Directory]::CreateDirectory and
    [System.IO.File]::WriteAllText directly (no Get-Content/-Encoding cmdlets).
#>

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

$webApp = Join-Path $root "apps\web\app"

function Write-CodeFile {
    param(
        [string]$RelativePath,
        [string]$Content
    )
    $fullPath = Join-Path $webApp $RelativePath
    $dir = Split-Path -Path $fullPath -Parent
    [System.IO.Directory]::CreateDirectory($dir) | Out-Null

    if (Test-Path -LiteralPath $fullPath) {
        Write-Host "SKIP (already exists): $RelativePath" -ForegroundColor Yellow
        return
    }

    [System.IO.File]::WriteAllText($fullPath, $Content, [System.Text.Encoding]::UTF8)
    Write-Host "CREATED: $RelativePath" -ForegroundColor Green
}

# ------------------------------------------------------------------
# 1. instructor/courses/[id]/edit/page.tsx
# ------------------------------------------------------------------
$editPage = @'
"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { Save, ListTree, DollarSign, Eye } from "lucide-react";
import { Button, Input, Select, Textarea, Badge } from "@saachi/ui";
import { CATEGORIES } from "../../../../../lib/categories";

const LEVEL_OPTIONS = [
  { label: "Beginner", value: "beginner" },
  { label: "Intermediate", value: "intermediate" },
  { label: "Advanced", value: "advanced" }
];

const LANGUAGE_OPTIONS = [
  { label: "English", value: "en" },
  { label: "Urdu", value: "ur" }
];

export default function EditCoursePage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();

  // NOTE: demo-only local state, prefilled with placeholders. Replace with
  // useInstructorCourseDetail(params.id) once the backend endpoint and typed
  // hook are available.
  const [title, setTitle] = useState("");
  const [subtitle, setSubtitle] = useState("");
  const [category, setCategory] = useState(CATEGORIES[0]?.id ?? "");
  const [level, setLevel] = useState("beginner");
  const [language, setLanguage] = useState("en");
  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only, no backend course-update mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <div className="mb-1 flex items-center gap-2">
        <h1 className="font-display text-[26px] font-bold text-ink">Edit course</h1>
        <Badge>Draft</Badge>
      </div>
      <p className="mb-8 text-[14px] text-ink-soft">Course ID: {params.id}</p>

      <div className="mb-6 flex flex-wrap gap-2">
        <Link href={`/instructor/courses/${params.id}/curriculum`}>
          <Button size="sm" variant="secondary">
            <ListTree size={14} className="mr-1.5" />
            Curriculum
          </Button>
        </Link>
        <Link href={`/instructor/courses/${params.id}/pricing`}>
          <Button size="sm" variant="secondary">
            <DollarSign size={14} className="mr-1.5" />
            Pricing
          </Button>
        </Link>
        <Link href={`/instructor/courses/${params.id}/preview`}>
          <Button size="sm" variant="secondary">
            <Eye size={14} className="mr-1.5" />
            Preview
          </Button>
        </Link>
      </div>

      <div className="flex flex-col gap-4 rounded-card border border-line bg-card p-6">
        <Input
          label="Course title"
          required
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="e.g. n8n Automation Bootcamp"
        />
        <Input
          label="Subtitle"
          value={subtitle}
          onChange={(e) => setSubtitle(e.target.value)}
          placeholder="A short one-line summary"
        />
        <Select
          label="Category"
          options={CATEGORIES.map((c) => ({ label: c.name, value: c.id }))}
          value={category}
          onChange={(e) => setCategory(e.target.value)}
        />
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Select label="Level" options={LEVEL_OPTIONS} value={level} onChange={(e) => setLevel(e.target.value)} />
          <Select
            label="Language"
            options={LANGUAGE_OPTIONS}
            value={language}
            onChange={(e) => setLanguage(e.target.value)}
          />
        </div>
        <Textarea label="Description" rows={5} placeholder="Full course description" />
      </div>

      <div className="mt-6 flex items-center gap-3">
        <Button size="lg" onClick={handleSave}>
          <Save size={15} className="mr-1.5" />
          {saved ? "Saved" : "Save changes"}
        </Button>
        <Button size="lg" variant="secondary" onClick={() => router.push("/instructor/courses")}>
          Cancel
        </Button>
      </div>
    </div>
  );
}
'@

Write-CodeFile -RelativePath "(instructor)\instructor\courses\[id]\edit\page.tsx" -Content $editPage

# ------------------------------------------------------------------
# 2. instructor/courses/[id]/curriculum/page.tsx
# ------------------------------------------------------------------
$curriculumPage = @'
"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { Plus, GripVertical, Trash2, Video, FileText, HelpCircle, Paperclip, ArrowLeft } from "lucide-react";
import { Button, Input, EmptyState } from "@saachi/ui";

type LessonType = "video" | "text" | "quiz" | "resource";
type Lesson = { id: string; title: string; type: LessonType };
type Module = { id: string; title: string; lessons: Lesson[] };

let idCounter = 0;
function nextId() {
  idCounter += 1;
  return `m${idCounter}`;
}

const LESSON_ICONS: Record<LessonType, typeof Video> = {
  video: Video,
  text: FileText,
  quiz: HelpCircle,
  resource: Paperclip
};

export default function CourseCurriculumPage() {
  const params = useParams<{ id: string }>();

  // NOTE: demo-only local state. Replace with useCourseCurriculum(params.id)
  // once the backend curriculum endpoint and typed hook are available.
  const [modules, setModules] = useState<Module[]>([]);
  const [saved, setSaved] = useState(false);

  function addModule() {
    setModules((prev) => [...prev, { id: nextId(), title: `Module ${prev.length + 1}`, lessons: [] }]);
  }

  function renameModule(moduleId: string, title: string) {
    setModules((prev) => prev.map((m) => (m.id === moduleId ? { ...m, title } : m)));
  }

  function removeModule(moduleId: string) {
    setModules((prev) => prev.filter((m) => m.id !== moduleId));
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

  function removeLesson(moduleId: string, lessonId: string) {
    setModules((prev) =>
      prev.map((m) => (m.id === moduleId ? { ...m, lessons: m.lessons.filter((l) => l.id !== lessonId) } : m))
    );
  }

  function handleSave() {
    // NOTE: demo-only, no backend curriculum-save mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  function lessonEditorHref(lessonId: string, type: LessonType) {
    if (type === "video") return `/instructor/courses/${params.id}/lessons/${lessonId}/video`;
    if (type === "text") return `/instructor/courses/${params.id}/lessons/${lessonId}/text`;
    if (type === "quiz") return `/instructor/courses/${params.id}/lessons/${lessonId}/quiz`;
    return `/instructor/courses/${params.id}/lessons/${lessonId}/video`;
  }

  return (
    <div className="mx-auto max-w-2xl">
      <Link
        href={`/instructor/courses/${params.id}/edit`}
        className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} />
        Back to course
      </Link>

      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Curriculum</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Course ID: {params.id}</p>

      {modules.length === 0 ? (
        <EmptyState title="No modules yet" description="Add your first module to start building the curriculum." />
      ) : (
        <div className="flex flex-col gap-4">
          {modules.map((m) => (
            <div key={m.id} className="rounded-card border border-line bg-card p-4">
              <div className="mb-3 flex items-center gap-2">
                <GripVertical size={16} className="shrink-0 text-ink-soft/50" />
                <Input
                  value={m.title}
                  onChange={(e) => renameModule(m.id, e.target.value)}
                  className="flex-1"
                />
                <button
                  type="button"
                  onClick={() => removeModule(m.id)}
                  aria-label="Remove module"
                  className="shrink-0 text-ink-soft hover:text-error"
                >
                  <Trash2 size={15} />
                </button>
              </div>

              {m.lessons.length > 0 && (
                <ul className="mb-3 flex flex-col gap-1.5">
                  {m.lessons.map((l) => {
                    const Icon = LESSON_ICONS[l.type];
                    return (
                      <li
                        key={l.id}
                        className="flex items-center gap-2 rounded-control bg-paper-dim px-3 py-2 text-[13px] text-ink"
                      >
                        <Icon size={13} className="shrink-0 text-ink-soft" />
                        <Link href={lessonEditorHref(l.id, l.type)} className="flex-1 truncate hover:underline">
                          {l.title}
                        </Link>
                        <span className="shrink-0 rounded bg-card px-1.5 py-0.5 text-[10px] uppercase text-ink-soft">
                          {l.type}
                        </span>
                        <button
                          type="button"
                          onClick={() => removeLesson(m.id, l.id)}
                          aria-label="Remove lesson"
                          className="shrink-0 text-ink-soft hover:text-error"
                        >
                          <Trash2 size={12} />
                        </button>
                      </li>
                    );
                  })}
                </ul>
              )}

              <div className="flex flex-wrap gap-2">
                <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "video")}>
                  + Video
                </Button>
                <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "text")}>
                  + Text
                </Button>
                <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "quiz")}>
                  + Quiz
                </Button>
                <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "resource")}>
                  + Resource
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}

      <Button variant="secondary" className="mt-4" onClick={addModule}>
        <Plus size={14} className="mr-1.5" />
        Add module
      </Button>

      <div className="mt-6">
        <Button size="lg" onClick={handleSave}>
          {saved ? "Saved" : "Save curriculum"}
        </Button>
      </div>
    </div>
  );
}
'@

Write-CodeFile -RelativePath "(instructor)\instructor\courses\[id]\curriculum\page.tsx" -Content $curriculumPage

# ------------------------------------------------------------------
# 3. instructor/courses/[id]/pricing/page.tsx
# ------------------------------------------------------------------
$pricingPage = @'
"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, Save } from "lucide-react";
import { Button, Input, Select } from "@saachi/ui";

const CURRENCY_OPTIONS = [
  { label: "USD", value: "USD" },
  { label: "PKR", value: "PKR" }
];

export default function CoursePricingPage() {
  const params = useParams<{ id: string }>();

  // NOTE: demo-only local state. Replace with useInstructorCoursePricing(params.id)
  // once the backend pricing endpoint and typed hook are available.
  const [price, setPrice] = useState("");
  const [currency, setCurrency] = useState("USD");
  const [includeInSubscription, setIncludeInSubscription] = useState(false);
  const [couponEligible, setCouponEligible] = useState(true);
  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only, no backend pricing-update mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <Link
        href={`/instructor/courses/${params.id}/edit`}
        className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} />
        Back to course
      </Link>

      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Pricing</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Course ID: {params.id}</p>

      <div className="flex flex-col gap-4 rounded-card border border-line bg-card p-6">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Input
            label="Price"
            type="number"
            required
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            placeholder="49.00"
          />
          <Select
            label="Currency"
            options={CURRENCY_OPTIONS}
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

        <label className="flex items-center gap-2 text-[13px] text-ink-soft">
          <input
            type="checkbox"
            checked={couponEligible}
            onChange={(e) => setCouponEligible(e.target.checked)}
            className="h-4 w-4 accent-gold-dark"
          />
          Allow coupons and promotional codes on this course
        </label>
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        <Save size={15} className="mr-1.5" />
        {saved ? "Saved" : "Save pricing"}
      </Button>
    </div>
  );
}
'@

Write-CodeFile -RelativePath "(instructor)\instructor\courses\[id]\pricing\page.tsx" -Content $pricingPage

# ------------------------------------------------------------------
# 4. instructor/courses/[id]/preview/page.tsx
# ------------------------------------------------------------------
$previewPage = @'
"use client";

import { useParams } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, Send, Star, Clock, BarChart3, Globe2, PlayCircle } from "lucide-react";
import { Button, EmptyState } from "@saachi/ui";

export default function CoursePreviewPage() {
  const params = useParams<{ id: string }>();

  // NOTE: demo-only preview shell. Replace with useInstructorCourseDetail(params.id)
  // once the backend endpoint and typed hook are available, to render the
  // real title/curriculum/pricing exactly as learners will see it.

  function handleSubmitForReview() {
    // NOTE: demo-only, no backend submit-for-review mutation wired up yet.
  }

  return (
    <div className="mx-auto max-w-3xl">
      <Link
        href={`/instructor/courses/${params.id}/edit`}
        className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} />
        Back to course
      </Link>

      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="font-display text-[26px] font-bold text-ink">Preview</h1>
          <p className="text-[14px] text-ink-soft">Course ID: {params.id}</p>
        </div>
        <Button onClick={handleSubmitForReview}>
          <Send size={14} className="mr-1.5" />
          Submit for review
        </Button>
      </div>

      <div className="rounded-card border border-line bg-card p-8">
        <p className="mb-2 text-[13px] font-medium text-gold-dark">Preview mode</p>
        <h2 className="mb-3 font-display text-[26px] font-bold text-ink">Untitled course</h2>

        <div className="mb-6 flex flex-wrap items-center gap-4 text-[13px] text-ink-soft">
          <span className="flex items-center gap-1.5">
            <Star size={14} className="text-gold-dark" fill="currentColor" />
            New
          </span>
          <span className="flex items-center gap-1.5">
            <BarChart3 size={14} /> Beginner
          </span>
          <span className="flex items-center gap-1.5">
            <Globe2 size={14} /> English
          </span>
          <span className="flex items-center gap-1.5">
            <Clock size={14} /> 0h total
          </span>
        </div>

        <div className="mb-8 flex aspect-video w-full items-center justify-center rounded-card border border-line bg-paper-dim text-ink-soft">
          <PlayCircle size={48} strokeWidth={1.25} />
        </div>

        <EmptyState
          title="Nothing to preview yet"
          description="Add a title, description, and curriculum to see how learners will view this course."
        />
      </div>
    </div>
  );
}
'@

Write-CodeFile -RelativePath "(instructor)\instructor\courses\[id]\preview\page.tsx" -Content $previewPage

# ------------------------------------------------------------------
# 5. instructor/payouts/methods/page.tsx
# ------------------------------------------------------------------
$payoutMethodsPage = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { ArrowLeft, Landmark, Smartphone, CreditCard, Check } from "lucide-react";
import { Button, Input, Select } from "@saachi/ui";

type PayoutMethod = "bank" | "mobile_wallet" | "stripe_connect";

const METHOD_OPTIONS: { value: PayoutMethod; label: string; icon: typeof Landmark }[] = [
  { value: "bank", label: "Direct bank transfer", icon: Landmark },
  { value: "mobile_wallet", label: "Mobile wallet (Easypaisa / JazzCash)", icon: Smartphone },
  { value: "stripe_connect", label: "Stripe Connect", icon: CreditCard }
];

const BANK_OPTIONS = [
  { label: "UBL", value: "ubl" },
  { label: "Allied Bank", value: "allied" },
  { label: "HBL", value: "hbl" },
  { label: "Other", value: "other" }
];

const WALLET_OPTIONS = [
  { label: "Easypaisa", value: "easypaisa" },
  { label: "JazzCash", value: "jazzcash" }
];

export default function PayoutMethodSettingsPage() {
  const [selected, setSelected] = useState<PayoutMethod>("bank");

  // Bank fields
  const [bank, setBank] = useState(BANK_OPTIONS[0].value);
  const [accountTitle, setAccountTitle] = useState("");
  const [accountNumber, setAccountNumber] = useState("");
  const [iban, setIban] = useState("");

  // Mobile wallet fields
  const [wallet, setWallet] = useState(WALLET_OPTIONS[0].value);
  const [walletNumber, setWalletNumber] = useState("");

  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only, no backend payout-method mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <Link
        href="/instructor/payouts"
        className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} />
        Back to payouts
      </Link>

      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Payout method</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Choose how you want to receive your earnings.</p>

      <div className="mb-6 grid grid-cols-1 gap-3 sm:grid-cols-3">
        {METHOD_OPTIONS.map((opt) => {
          const Icon = opt.icon;
          const isActive = selected === opt.value;
          return (
            <button
              key={opt.value}
              type="button"
              onClick={() => setSelected(opt.value)}
              className={`flex flex-col items-start gap-2 rounded-card border p-4 text-left transition-colors ${
                isActive ? "border-gold-dark bg-gold-tint" : "border-line bg-card hover:border-gold-dark/40"
              }`}
            >
              <div className="flex w-full items-center justify-between">
                <Icon size={18} className="text-ink-soft" />
                {isActive && <Check size={15} className="text-gold-dark" />}
              </div>
              <span className="text-[13px] font-medium text-ink">{opt.label}</span>
            </button>
          );
        })}
      </div>

      <div className="rounded-card border border-line bg-card p-6">
        {selected === "bank" && (
          <div className="flex flex-col gap-4">
            <Select label="Bank" options={BANK_OPTIONS} value={bank} onChange={(e) => setBank(e.target.value)} />
            <Input
              label="Account title"
              value={accountTitle}
              onChange={(e) => setAccountTitle(e.target.value)}
              placeholder="Full name as per bank records"
            />
            <Input
              label="Account number"
              value={accountNumber}
              onChange={(e) => setAccountNumber(e.target.value)}
            />
            <Input label="IBAN (optional)" value={iban} onChange={(e) => setIban(e.target.value)} />
          </div>
        )}

        {selected === "mobile_wallet" && (
          <div className="flex flex-col gap-4">
            <Select
              label="Wallet provider"
              options={WALLET_OPTIONS}
              value={wallet}
              onChange={(e) => setWallet(e.target.value)}
            />
            <Input
              label="Wallet number"
              value={walletNumber}
              onChange={(e) => setWalletNumber(e.target.value)}
              placeholder="03XXXXXXXXX"
            />
          </div>
        )}

        {selected === "stripe_connect" && (
          <div className="flex flex-col gap-3">
            <p className="text-[13px] text-ink-soft">
              Connect your Stripe account to receive payouts directly. You&apos;ll be redirected to
              Stripe to complete onboarding.
            </p>
            <Button variant="secondary" className="self-start">
              <CreditCard size={14} className="mr-1.5" />
              Connect with Stripe
            </Button>
          </div>
        )}
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save payout method"}
      </Button>
    </div>
  );
}
'@

Write-CodeFile -RelativePath "(instructor)\instructor\payouts\methods\page.tsx" -Content $payoutMethodsPage

Write-Host ""
Write-Host "Done. All missing instructor pages have been generated (existing files were skipped, not overwritten)." -ForegroundColor Cyan