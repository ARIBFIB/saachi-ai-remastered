# Phase3b-InstructorPortal-Content-Payouts.ps1
# Run from: SAI2/ root
# Creates Instructor Portal Phase 3b screens (Doc 2, Section 12, items 8-14):
#   8. Lesson Editor (Video)
#   9. Lesson Editor (Text)
#   10. Quiz Builder
#   13. Payout Requests
#   14. Payout Method Settings
#
# Safety note: only verified-safe @saachi/ui components used (Button, Input,
# Select, Textarea, EmptyState, Badge (gold|success|error only, no "neutral"),
# KpiCard, cn). Dummy/local state used where store hooks aren't confirmed.

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
# 8. Lesson Editor (Video) — (instructor)/instructor/courses/[id]/lessons/[lessonId]/video/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\courses\[id]\lessons\[lessonId]\video\page.tsx" @'
"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { UploadCloud, FileText, Trash2 } from "lucide-react";
import { Button, Input, EmptyState } from "@saachi/ui";

type ResourceFile = { id: string; name: string };

export default function VideoLessonEditorPage() {
  const router = useRouter();
  const params = useParams<{ id: string; lessonId: string }>();

  const [title, setTitle] = useState("");
  const [videoFileName, setVideoFileName] = useState<string | null>(null);
  const [captionsFileName, setCaptionsFileName] = useState<string | null>(null);
  const [resources, setResources] = useState<ResourceFile[]>([]);
  const [uploadProgress, setUploadProgress] = useState<number | null>(null);
  const [saved, setSaved] = useState(false);

  function handleVideoSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setVideoFileName(file.name);
    // NOTE: demo-only progress simulation. Real implementation needs the
    // resumable/chunked signed-URL upload flow described in Doc 2 Section 8.1/16.
    setUploadProgress(0);
    const interval = setInterval(() => {
      setUploadProgress((p) => {
        if (p === null) return null;
        if (p >= 100) {
          clearInterval(interval);
          return 100;
        }
        return p + 20;
      });
    }, 250);
  }

  function handleCaptionsSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) setCaptionsFileName(file.name);
  }

  function handleResourceSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const files = e.target.files;
    if (!files) return;
    const added: ResourceFile[] = Array.from(files).map((f, i) => ({
      id: `${Date.now()}-${i}`,
      name: f.name
    }));
    setResources((prev) => [...prev, ...added]);
  }

  function removeResource(id: string) {
    setResources((prev) => prev.filter((r) => r.id !== id));
  }

  function handleSave() {
    // NOTE: demo-only, no backend lesson-save mutation wired up yet.
    setSaved(true);
  }

  if (saved) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Lesson saved"
          description="Your video lesson has been saved to the curriculum."
          action={
            <Button onClick={() => router.push(`/instructor/courses/${params.id}/curriculum`)}>
              Back to curriculum
            </Button>
          }
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Video Lesson Editor</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Lesson ID: {params.lessonId}</p>

      <div className="flex flex-col gap-6">
        <Input label="Lesson title" required value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. Setting up your first workflow" />

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Video file</p>
          <label className="flex cursor-pointer flex-col items-center gap-2 rounded-card border-2 border-dashed border-line px-6 py-8 text-center hover:border-gold-dark/40">
            <UploadCloud size={22} className="text-ink-soft" />
            <span className="text-[13px] text-ink-soft">
              {videoFileName ?? "Click to select a video file (mp4, mov)"}
            </span>
            <input type="file" accept="video/*" className="hidden" onChange={handleVideoSelect} />
          </label>
          {uploadProgress !== null && (
            <div className="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-paper-dim">
              <div
                className="h-full rounded-full bg-gold transition-all"
                style={{ width: `${uploadProgress}%` }}
              />
            </div>
          )}
        </div>

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Captions (optional)</p>
          <label className="flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
            <FileText size={16} />
            {captionsFileName ?? "Upload .vtt or .srt file"}
            <input type="file" accept=".vtt,.srt" className="hidden" onChange={handleCaptionsSelect} />
          </label>
        </div>

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Resource attachments</p>
          <label className="mb-3 flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
            <UploadCloud size={16} />
            Attach PDF, ZIP, or code files
            <input type="file" multiple className="hidden" onChange={handleResourceSelect} />
          </label>
          {resources.length > 0 && (
            <ul className="flex flex-col gap-1.5">
              {resources.map((r) => (
                <li key={r.id} className="flex items-center justify-between rounded-control bg-paper-dim px-3 py-2 text-[13px] text-ink">
                  {r.name}
                  <button type="button" onClick={() => removeResource(r.id)} aria-label="Remove file" className="text-ink-soft hover:text-error">
                    <Trash2 size={14} />
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        <Button size="lg" className="self-start" disabled={!title.trim()} onClick={handleSave}>
          Save lesson
        </Button>
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 9. Lesson Editor (Text) — (instructor)/instructor/courses/[id]/lessons/[lessonId]/text/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\courses\[id]\lessons\[lessonId]\text\page.tsx" @'
"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Bold, Italic, List, Heading2, Link as LinkIcon } from "lucide-react";
import { Button, Input, EmptyState } from "@saachi/ui";

export default function TextLessonEditorPage() {
  const router = useRouter();
  const params = useParams<{ id: string; lessonId: string }>();

  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [saved, setSaved] = useState(false);

  // NOTE: demo-only plain textarea editor. Doc 2 Section 2/12 specifies Tiptap
  // as the rich text editor — swap this out once @tiptap/react wiring is confirmed
  // to work cleanly in this build (it's already a dependency in package.json).

  function insertMarker(marker: string) {
    setContent((prev) => `${prev}${marker}`);
  }

  function handleSave() {
    // NOTE: demo-only, no backend lesson-save mutation wired up yet.
    setSaved(true);
  }

  if (saved) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Lesson saved"
          description="Your text lesson has been saved to the curriculum."
          action={
            <Button onClick={() => router.push(`/instructor/courses/${params.id}/curriculum`)}>
              Back to curriculum
            </Button>
          }
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Text Lesson Editor</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Lesson ID: {params.lessonId}</p>

      <div className="flex flex-col gap-4">
        <Input label="Lesson title" required value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. Understanding prompt structure" />

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Content</p>
          <div className="mb-2 flex gap-1 rounded-control border border-line bg-paper-dim p-1">
            <button type="button" onClick={() => insertMarker("**bold**")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="Bold">
              <Bold size={14} />
            </button>
            <button type="button" onClick={() => insertMarker("*italic*")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="Italic">
              <Italic size={14} />
            </button>
            <button type="button" onClick={() => insertMarker("\n## Heading\n")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="Heading">
              <Heading2 size={14} />
            </button>
            <button type="button" onClick={() => insertMarker("\n- list item\n")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="List">
              <List size={14} />
            </button>
            <button type="button" onClick={() => insertMarker("[link text](https://)")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="Link">
              <LinkIcon size={14} />
            </button>
          </div>
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            rows={14}
            placeholder="Write your lesson content in Markdown..."
            className="w-full rounded-control border border-line bg-card p-4 font-mono text-[13px] text-ink outline-none focus:border-gold-dark/50"
          />
        </div>

        <Button size="lg" className="self-start" disabled={!title.trim()} onClick={handleSave}>
          Save lesson
        </Button>
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 10. Quiz Builder — (instructor)/instructor/courses/[id]/lessons/[lessonId]/quiz/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\courses\[id]\lessons\[lessonId]\quiz\page.tsx" @'
"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Plus, Trash2 } from "lucide-react";
import { Button, Input, Select, EmptyState } from "@saachi/ui";

type QuestionType = "multiple_choice" | "short_answer";

type Question = {
  id: string;
  type: QuestionType;
  prompt: string;
  options: string[];
  correctOptionIndex: number;
  correctAnswerText: string;
};

let qCounter = 0;
function newQuestion(type: QuestionType): Question {
  qCounter += 1;
  return {
    id: `q${qCounter}`,
    type,
    prompt: "",
    options: type === "multiple_choice" ? ["", "", "", ""] : [],
    correctOptionIndex: 0,
    correctAnswerText: ""
  };
}

const TYPE_OPTIONS = [
  { label: "Multiple choice", value: "multiple_choice" },
  { label: "Short answer", value: "short_answer" }
];

export default function QuizBuilderPage() {
  const router = useRouter();
  const params = useParams<{ id: string; lessonId: string }>();

  const [passingScore, setPassingScore] = useState("70");
  const [questions, setQuestions] = useState<Question[]>([]);
  const [saved, setSaved] = useState(false);

  function addQuestion(type: QuestionType) {
    setQuestions((prev) => [...prev, newQuestion(type)]);
  }

  function updateQuestion(id: string, patch: Partial<Question>) {
    setQuestions((prev) => prev.map((q) => (q.id === id ? { ...q, ...patch } : q)));
  }

  function updateOption(questionId: string, optionIndex: number, value: string) {
    setQuestions((prev) =>
      prev.map((q) =>
        q.id === questionId
          ? { ...q, options: q.options.map((o, i) => (i === optionIndex ? value : o)) }
          : q
      )
    );
  }

  function removeQuestion(id: string) {
    setQuestions((prev) => prev.filter((q) => q.id !== id));
  }

  function handleSave() {
    // NOTE: demo-only, no backend quiz-save mutation wired up yet.
    setSaved(true);
  }

  if (saved) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Quiz saved"
          description="Your quiz has been saved to the curriculum."
          action={
            <Button onClick={() => router.push(`/instructor/courses/${params.id}/curriculum`)}>
              Back to curriculum
            </Button>
          }
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Quiz Builder</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Lesson ID: {params.lessonId}</p>

      <div className="mb-6 max-w-xs">
        <Input
          label="Passing score (%)"
          type="number"
          value={passingScore}
          onChange={(e) => setPassingScore(e.target.value)}
        />
      </div>

      {questions.length === 0 ? (
        <EmptyState title="No questions yet" description="Add your first question to the question bank." />
      ) : (
        <div className="flex flex-col gap-5">
          {questions.map((q, qi) => (
            <div key={q.id} className="rounded-card border border-line bg-card p-5">
              <div className="mb-3 flex items-center justify-between gap-3">
                <span className="text-[13px] font-semibold text-ink-soft">Question {qi + 1}</span>
                <div className="flex items-center gap-2">
                  <Select
                    options={TYPE_OPTIONS}
                    value={q.type}
                    onChange={(e) => updateQuestion(q.id, { type: e.target.value as QuestionType, options: e.target.value === "multiple_choice" ? ["", "", "", ""] : [] })}
                    className="w-44"
                  />
                  <button type="button" onClick={() => removeQuestion(q.id)} aria-label="Remove question" className="text-ink-soft hover:text-error">
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>

              <Input
                label="Question prompt"
                value={q.prompt}
                onChange={(e) => updateQuestion(q.id, { prompt: e.target.value })}
                placeholder="e.g. What does the 'trigger' node do in n8n?"
                className="mb-4"
              />

              {q.type === "multiple_choice" ? (
                <div className="flex flex-col gap-2">
                  {q.options.map((opt, oi) => (
                    <label key={oi} className="flex items-center gap-2">
                      <input
                        type="radio"
                        name={`correct-${q.id}`}
                        checked={q.correctOptionIndex === oi}
                        onChange={() => updateQuestion(q.id, { correctOptionIndex: oi })}
                        className="h-4 w-4 accent-gold-dark"
                        aria-label={`Mark option ${oi + 1} as correct`}
                      />
                      <Input
                        value={opt}
                        onChange={(e) => updateOption(q.id, oi, e.target.value)}
                        placeholder={`Option ${oi + 1}`}
                        className="flex-1"
                      />
                    </label>
                  ))}
                </div>
              ) : (
                <Input
                  label="Correct answer"
                  value={q.correctAnswerText}
                  onChange={(e) => updateQuestion(q.id, { correctAnswerText: e.target.value })}
                  placeholder="Expected short answer"
                />
              )}
            </div>
          ))}
        </div>
      )}

      <div className="mt-4 flex flex-wrap gap-2">
        <Button variant="secondary" onClick={() => addQuestion("multiple_choice")}>
          <Plus size={14} className="mr-1.5" />
          Multiple choice
        </Button>
        <Button variant="secondary" onClick={() => addQuestion("short_answer")}>
          <Plus size={14} className="mr-1.5" />
          Short answer
        </Button>
      </div>

      <Button size="lg" className="mt-6" disabled={questions.length === 0} onClick={handleSave}>
        Save quiz
      </Button>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 13. Payout Requests — (instructor)/instructor/payouts/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\payouts\page.tsx" @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { Wallet, Settings } from "lucide-react";
import { Button, KpiCard, EmptyState, Badge } from "@saachi/ui";

type PayoutStatus = "pending" | "processing" | "paid" | "failed";

type PayoutRecord = {
  id: string;
  amount: number;
  currency: string;
  status: PayoutStatus;
  requestedAt: string;
};

// NOTE: demo-only dummy data. Replace with useInstructorPayouts() once
// packages/api-client hooks for payouts are confirmed.
const PAYOUTS: PayoutRecord[] = [];

const STATUS_VARIANT: Partial<Record<PayoutStatus, "gold" | "success" | "error">> = {
  pending: "gold",
  processing: "gold",
  paid: "success",
  failed: "error"
};

const STATUS_LABEL: Record<PayoutStatus, string> = {
  pending: "Pending",
  processing: "Processing",
  paid: "Paid",
  failed: "Failed"
};

export default function InstructorPayoutRequestsPage() {
  const [requesting, setRequesting] = useState(false);
  const [requested, setRequested] = useState(false);

  function handleRequestPayout() {
    setRequesting(true);
    // NOTE: demo-only, no backend payout-request mutation wired up yet.
    setTimeout(() => {
      setRequesting(false);
      setRequested(true);
    }, 600);
  }

  return (
    <div>
      <div className="mb-8 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Payout Requests</h1>
          <p className="text-[14px] text-ink-soft">Request a payout or review your payout history.</p>
        </div>
        <Link href="/instructor/payouts/methods">
          <Button variant="secondary">
            <Settings size={14} className="mr-1.5" />
            Payout method
          </Button>
        </Link>
      </div>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2">
        <KpiCard label="Available balance" value="$0.00" icon={Wallet} />
        <div className="flex items-center rounded-card border border-line bg-card p-5">
          <Button size="lg" disabled={requesting || requested} onClick={handleRequestPayout} className="w-full">
            {requested ? "Payout requested" : requesting ? "Requesting..." : "Request payout"}
          </Button>
        </div>
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Payout history</h2>
      {PAYOUTS.length === 0 ? (
        <EmptyState title="No payouts yet" description="Your payout history will show up here once you request your first payout." />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Payout ID</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Amount</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Requested</th>
              </tr>
            </thead>
            <tbody>
              {PAYOUTS.map((p) => (
                <tr key={p.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3.5 font-medium text-ink">{p.id}</td>
                  <td className="px-4 py-3.5 font-mono text-ink">
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

# ---------------------------------------------------------------------------
# 14. Payout Method Settings — (instructor)/instructor/payouts/methods/page.tsx
# ---------------------------------------------------------------------------
New-PageFile "(instructor)\instructor\payouts\methods\page.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import { Button, Input, Select } from "@saachi/ui";

const METHOD_OPTIONS = [
  { label: "Bank transfer", value: "bank" },
  { label: "Mobile wallet (Easypaisa / JazzCash)", value: "wallet" },
  { label: "Stripe Connect", value: "stripe" }
];

export default function PayoutMethodSettingsPage() {
  const [method, setMethod] = useState("bank");

  // Bank fields
  const [bankName, setBankName] = useState("");
  const [accountTitle, setAccountTitle] = useState("");
  const [accountNumber, setAccountNumber] = useState("");
  const [iban, setIban] = useState("");

  // Wallet fields
  const [walletProvider, setWalletProvider] = useState("easypaisa");
  const [walletNumber, setWalletNumber] = useState("");

  const [saved, setSaved] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend payout-method mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-lg">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Payout Method</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Configure how you receive your earnings.</p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Select label="Payout method" options={METHOD_OPTIONS} value={method} onChange={(e) => setMethod(e.target.value)} />

        {method === "bank" && (
          <>
            <Input label="Bank name" required value={bankName} onChange={(e) => setBankName(e.target.value)} placeholder="e.g. UBL, HBL, Allied Bank" />
            <Input label="Account title" required value={accountTitle} onChange={(e) => setAccountTitle(e.target.value)} />
            <Input label="Account number" required value={accountNumber} onChange={(e) => setAccountNumber(e.target.value)} />
            <Input label="IBAN (optional)" value={iban} onChange={(e) => setIban(e.target.value)} />
          </>
        )}

        {method === "wallet" && (
          <>
            <Select
              label="Wallet provider"
              options={[
                { label: "Easypaisa", value: "easypaisa" },
                { label: "JazzCash", value: "jazzcash" }
              ]}
              value={walletProvider}
              onChange={(e) => setWalletProvider(e.target.value)}
            />
            <Input label="Wallet number" required value={walletNumber} onChange={(e) => setWalletNumber(e.target.value)} placeholder="03XXXXXXXXX" />
          </>
        )}

        {method === "stripe" && (
          <p className="rounded-control border border-line bg-paper-dim p-4 text-[13px] text-ink-soft">
            You&apos;ll be redirected to Stripe Connect to link your account once this integration is wired up.
          </p>
        )}

        <Button type="submit" size="lg" className="self-start">
          {saved ? "Saved" : "Save payout method"}
        </Button>
      </form>
    </div>
  );
}
'@

Write-Host ""
Write-Host "Phase 3b done. Now verify locally before pushing:" -ForegroundColor Cyan
Write-Host "  pnpm --filter web build"
Write-Host ""
Write-Host "If clean, then:" -ForegroundColor Cyan
Write-Host "  git add ."
Write-Host "  git commit -m `"feat: Phase 3b Instructor Portal (lesson editors, quiz builder, payouts)`""
Write-Host "  git push"
Write-Host ""
Write-Host "Test routes after deploy (must be logged in, use any placeholder IDs):" -ForegroundColor Cyan
Write-Host "  /instructor/courses/c1/lessons/l1/video"
Write-Host "  /instructor/courses/c1/lessons/l1/text"
Write-Host "  /instructor/courses/c1/lessons/l1/quiz"
Write-Host "  /instructor/payouts"
Write-Host "  /instructor/payouts/methods"