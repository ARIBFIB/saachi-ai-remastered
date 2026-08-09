# ============================================================================
# apply-missing-admin-pages.ps1
# Adds: Payouts queue, User Detail, Ticket Detail, Mandatory 2FA on login
# Run from: SAI2 root
# ============================================================================

# ============================================================================
# apply-missing-admin-pages.ps1  (fixed Write-File function)
# ============================================================================

$ErrorActionPreference = "Stop"
$root = Get-Location
$adminApp = Join-Path $root "apps\admin"

if (-not (Test-Path $adminApp)) {
    Write-Error "apps\admin not found under current directory ($root). Run from SAI2 root."
    exit 1
}

Write-Host "Saachi Admin - adding missing pages (dummy data)..." -ForegroundColor Cyan

function Write-File {
    param(
        [Parameter(Mandatory=$true)][string]$RelativePath,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $fullPath = Join-Path $adminApp $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($fullPath, $Content, [System.Text.Encoding]::UTF8)
    Write-Host "  [OK] $RelativePath" -ForegroundColor Green
}
# ----------------------------------------------------------------------------
# 1. finance/payouts/page.tsx
# ----------------------------------------------------------------------------
$payoutsPage = @'
"use client";

import { useState } from "react";
import { Banknote, CheckCircle2, XCircle, Download } from "lucide-react";
import { Button, Card, Select, StatusPill, EmptyState, HelpTooltip } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

type PayoutStatus = "pending" | "approved" | "processing" | "paid" | "failed";

type PayoutRequest = {
  id: string;
  instructorName: string;
  instructorEmail: string;
  amount: number;
  currency: string;
  method: string;
  requestedAt: string;
  status: PayoutStatus;
  batchId: string;
};

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Approved", value: "approved" },
  { label: "Processing", value: "processing" },
  { label: "Paid", value: "paid" },
  { label: "Failed", value: "failed" }
];

const STATUS_TONE: Record<PayoutStatus, "success" | "warning" | "error" | "info" | "neutral"> = {
  pending: "warning",
  approved: "info",
  processing: "info",
  paid: "success",
  failed: "error"
};

const INITIAL_PAYOUTS: PayoutRequest[] = [
  { id: "po_1", instructorName: "Zeeshan Tariq", instructorEmail: "zeeshan@example.com", amount: 842.5, currency: "USD", method: "Bank Transfer", requestedAt: "2026-08-08T09:00:00Z", status: "pending", batchId: "PAYOUT-2026-0913" },
  { id: "po_2", instructorName: "Bilal Ahmed", instructorEmail: "bilal@example.com", amount: 1290, currency: "USD", method: "Stripe Connect", requestedAt: "2026-08-08T09:00:00Z", status: "pending", batchId: "PAYOUT-2026-0913" },
  { id: "po_3", instructorName: "Fatima Noor", instructorEmail: "fatima@example.com", amount: 315.75, currency: "USD", method: "Easypaisa", requestedAt: "2026-08-08T09:00:00Z", status: "pending", batchId: "PAYOUT-2026-0913" },
  { id: "po_4", instructorName: "Hassan Raza", instructorEmail: "hassan@example.com", amount: 560, currency: "USD", method: "JazzCash", requestedAt: "2026-08-01T09:00:00Z", status: "paid", batchId: "PAYOUT-2026-0906" },
  { id: "po_5", instructorName: "Ayesha Malik", instructorEmail: "ayesha@example.com", amount: 220, currency: "USD", method: "Bank Transfer", requestedAt: "2026-08-01T09:00:00Z", status: "failed", batchId: "PAYOUT-2026-0906" }
];

export default function PayoutProcessingQueuePage() {
  const [payouts, setPayouts] = useState(INITIAL_PAYOUTS);
  const [statusFilter, setStatusFilter] = useState("pending");
  const [processing, setProcessing] = useState(false);

  const filtered = payouts.filter((p) => !statusFilter || p.status === statusFilter);
  const pendingBatch = payouts.filter((p) => p.status === "pending");
  const pendingTotal = pendingBatch.reduce((sum, p) => sum + p.amount, 0);

  const approveOne = (id: string) => {
    setPayouts((prev) => prev.map((p) => (p.id === id ? { ...p, status: "approved" } : p)));
  };

  const rejectOne = (id: string) => {
    setPayouts((prev) => prev.map((p) => (p.id === id ? { ...p, status: "failed" } : p)));
  };

  const approveBatch = () => {
    setProcessing(true);
    setTimeout(() => {
      setPayouts((prev) => prev.map((p) => (p.status === "pending" ? { ...p, status: "approved" } : p)));
      setProcessing(false);
    }, 700);
  };

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Banknote size={17} strokeWidth={1.75} />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <h1 className="text-[22px] font-semibold text-ink">Payout Processing Queue</h1>
              <HelpTooltip text="Instructor payout requests awaiting review. Approve individually or process the entire pending batch at once." />
            </div>
            <p className="mt-0.5 text-[13px] text-ink-soft">Pending instructor payout requests, batched weekly.</p>
          </div>
        </div>
        <Button size="sm" variant="secondary">
          <Download size={14} strokeWidth={1.75} /> Export CSV
        </Button>
      </div>

      {pendingBatch.length > 0 && (
        <Card className="mb-6 flex flex-col gap-3 p-5 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <p className="text-[13px] text-ink-soft">Current batch - PAYOUT-2026-0913</p>
            <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{formatCurrency(pendingTotal, "USD")}</p>
            <p className="mt-0.5 text-[12px] text-ink-soft">{pendingBatch.length} instructors awaiting approval</p>
          </div>
          <Button onClick={approveBatch} disabled={processing}>
            <CheckCircle2 size={14} strokeWidth={1.75} /> {processing ? "Processing..." : "Approve entire batch"}
          </Button>
        </Card>
      )}

      <div className="mb-5 w-[180px]">
        <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
      </div>

      {filtered.length === 0 ? (
        <EmptyState icon={<Banknote size={22} strokeWidth={1.75} />} title="No payouts found" description="Try a different status filter." />
      ) : (
        <div className="flex flex-col gap-3">
          {filtered.map((payout) => (
            <Card key={payout.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div className="min-w-0">
                <div className="flex items-center gap-2.5">
                  <p className="truncate text-[14px] font-semibold text-ink">{payout.instructorName}</p>
                  <StatusPill label={payout.status} tone={STATUS_TONE[payout.status]} />
                </div>
                <p className="mt-1 text-[12.5px] text-ink-soft">
                  {payout.instructorEmail} - {payout.method} - Requested {formatDate(payout.requestedAt)}
                </p>
              </div>
              <div className="flex shrink-0 items-center gap-4">
                <span className="font-mono text-[16px] font-semibold text-ink">
                  {formatCurrency(payout.amount, payout.currency)}
                </span>
                {payout.status === "pending" && (
                  <div className="flex gap-2">
                    <Button size="sm" variant="secondary" onClick={() => rejectOne(payout.id)}>
                      <XCircle size={14} strokeWidth={1.75} /> Reject
                    </Button>
                    <Button size="sm" onClick={() => approveOne(payout.id)}>
                      <CheckCircle2 size={14} strokeWidth={1.75} /> Approve
                    </Button>
                  </div>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-File "app\(console)\finance\payouts\page.tsx" $payoutsPage

# ----------------------------------------------------------------------------
# 2. users/[id]/page.tsx
# ----------------------------------------------------------------------------
$userDetailPage = @'
"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Ban, ShieldCheck, History, Mail, MapPin, Calendar } from "lucide-react";
import { Button, Card, StatusPill, Modal, Select, Textarea, Badge } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

type UserStatus = "active" | "suspended" | "banned" | "pending";
type UserRole = "learner" | "instructor" | "corporate" | "admin";

const STATUS_TONE: Record<UserStatus, "success" | "warning" | "error" | "info"> = {
  active: "success",
  suspended: "warning",
  banned: "error",
  pending: "info"
};

const ROLE_OPTIONS = [
  { label: "Learner", value: "learner" },
  { label: "Instructor", value: "instructor" },
  { label: "Corporate", value: "corporate" },
  { label: "Admin", value: "admin" }
];

// Dummy user record - keyed by the [id] param, falls back to a generic profile.
const DUMMY_USER = {
  fullName: "Fatima Noor",
  email: "fatima.noor@example.com",
  role: "learner" as UserRole,
  status: "active" as UserStatus,
  location: "Lahore, Pakistan",
  joinedAt: "2026-03-14T00:00:00Z",
  lastActiveAt: "2026-08-09T18:20:00Z",
  coursesEnrolled: 6,
  coursesCompleted: 3,
  totalSpent: 214.5
};

const ACTIVITY_LOG = [
  { id: "a1", action: "Purchased \"AI Automation with n8n\"", createdAt: "2026-08-08T02:10:00Z" },
  { id: "a2", action: "Completed \"Prompt Engineering Basics\"", createdAt: "2026-08-05T14:30:00Z" },
  { id: "a3", action: "Left a 5-star review on \"AI Customer Support Bots\"", createdAt: "2026-08-02T11:00:00Z" },
  { id: "a4", action: "Updated profile picture", createdAt: "2026-07-28T09:15:00Z" },
  { id: "a5", action: "Account created", createdAt: "2026-03-14T00:00:00Z" }
];

const AUDIT_TRAIL = [
  { id: "au1", actor: "Support Desk", action: "Reset password on user request", createdAt: "2026-06-01T10:00:00Z" },
  { id: "au2", actor: "System", action: "Email verified", createdAt: "2026-03-14T00:05:00Z" }
];

export default function UserDetailPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params?.id as string;

  const [role, setRole] = useState<UserRole>(DUMMY_USER.role);
  const [status, setStatus] = useState<UserStatus>(DUMMY_USER.status);
  const [showSuspend, setShowSuspend] = useState(false);
  const [showBan, setShowBan] = useState(false);
  const [reason, setReason] = useState("");

  const handleSuspend = () => {
    setStatus("suspended");
    setShowSuspend(false);
    setReason("");
  };

  const handleBan = () => {
    setStatus("banned");
    setShowBan(false);
    setReason("");
  };

  const handleReinstate = () => {
    setStatus("active");
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/users")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to users
      </button>

      <Card className="mb-6 flex flex-col gap-5 p-6 sm:flex-row sm:items-start sm:justify-between">
        <div className="flex items-start gap-4">
          <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-full border border-line bg-paper-dim text-[18px] font-semibold text-ink-soft">
            {DUMMY_USER.fullName.charAt(0)}
          </div>
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[20px] font-semibold text-ink">{DUMMY_USER.fullName}</h1>
              <StatusPill label={status} tone={STATUS_TONE[status]} />
            </div>
            <p className="mt-1 flex items-center gap-1.5 text-[12.5px] text-ink-soft">
              <Mail size={12} strokeWidth={1.75} /> {DUMMY_USER.email}
            </p>
            <p className="mt-1 flex items-center gap-1.5 text-[12.5px] text-ink-soft">
              <MapPin size={12} strokeWidth={1.75} /> {DUMMY_USER.location}
            </p>
            <p className="mt-1 flex items-center gap-1.5 text-[12.5px] text-ink-soft">
              <Calendar size={12} strokeWidth={1.75} /> Joined {formatDate(DUMMY_USER.joinedAt)} - last active {formatRelativeTime(DUMMY_USER.lastActiveAt)}
            </p>
            <p className="mt-1.5 text-[11px] text-ink-soft/70">User ID: {userId}</p>
          </div>
        </div>

        <div className="flex shrink-0 flex-wrap gap-2">
          {status !== "active" && (
            <Button size="sm" variant="secondary" onClick={handleReinstate}>
              <ShieldCheck size={14} strokeWidth={1.75} /> Reinstate
            </Button>
          )}
          {status === "active" && (
            <Button size="sm" variant="secondary" onClick={() => setShowSuspend(true)}>
              Suspend
            </Button>
          )}
          {status !== "banned" && (
            <Button size="sm" variant="danger" onClick={() => setShowBan(true)}>
              <Ban size={14} strokeWidth={1.75} /> Ban
            </Button>
          )}
        </div>
      </Card>

      <div className="mb-6 grid grid-cols-2 gap-4 lg:grid-cols-4">
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Courses enrolled</p>
          <p className="mt-1.5 font-mono text-[20px] font-semibold text-ink">{DUMMY_USER.coursesEnrolled}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Courses completed</p>
          <p className="mt-1.5 font-mono text-[20px] font-semibold text-ink">{DUMMY_USER.coursesCompleted}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Total spent</p>
          <p className="mt-1.5 font-mono text-[20px] font-semibold text-ink">${DUMMY_USER.totalSpent.toFixed(2)}</p>
        </Card>
        <Card className="p-5">
          <div className="mb-1.5 text-[12px] text-ink-soft">Role</div>
          <Select
            options={ROLE_OPTIONS}
            value={role}
            onChange={(e) => setRole(e.target.value as UserRole)}
          />
        </Card>
      </div>

      <div className="mb-6">
        <p className="mb-3 flex items-center gap-1.5 text-[14px] font-semibold text-ink">
          <History size={15} strokeWidth={1.75} /> Activity log
        </p>
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {ACTIVITY_LOG.map((entry, i) => (
            <div key={entry.id} className={`flex items-center justify-between gap-4 px-5 py-3.5 ${i > 0 ? "border-t border-line" : ""}`}>
              <span className="text-[13px] text-ink">{entry.action}</span>
              <span className="shrink-0 text-[12px] text-ink-soft">{formatRelativeTime(entry.createdAt)}</span>
            </div>
          ))}
        </div>
      </div>

      <div>
        <p className="mb-3 text-[14px] font-semibold text-ink">Moderation audit trail</p>
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {AUDIT_TRAIL.map((entry, i) => (
            <div key={entry.id} className={`flex flex-col gap-1 px-5 py-3.5 sm:flex-row sm:items-center sm:justify-between ${i > 0 ? "border-t border-line" : ""}`}>
              <div>
                <span className="text-[13px] text-ink">{entry.action}</span>
                <span className="ml-2 text-[12px] text-ink-soft">by {entry.actor}</span>
              </div>
              <span className="shrink-0 text-[12px] text-ink-soft">{formatDate(entry.createdAt)}</span>
            </div>
          ))}
        </div>
      </div>

      <Modal
        open={showSuspend}
        onClose={() => setShowSuspend(false)}
        title={`Suspend ${DUMMY_USER.fullName}?`}
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowSuspend(false)}>Cancel</Button>
            <Button variant="danger" onClick={handleSuspend} disabled={!reason.trim()}>Suspend account</Button>
          </>
        }
      >
        <Textarea label="Reason for suspension" rows={4} value={reason} onChange={(e) => setReason(e.target.value)} placeholder="This is logged in the audit trail..." />
      </Modal>

      <Modal
        open={showBan}
        onClose={() => setShowBan(false)}
        title={`Ban ${DUMMY_USER.fullName}?`}
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowBan(false)}>Cancel</Button>
            <Button variant="danger" onClick={handleBan} disabled={!reason.trim()}>Ban account</Button>
          </>
        }
      >
        <p className="mb-3 text-[13px] text-ink-soft">This is a more severe action than suspension and will revoke platform access entirely.</p>
        <Textarea label="Reason for ban" rows={4} value={reason} onChange={(e) => setReason(e.target.value)} placeholder="This is logged in the audit trail..." />
      </Modal>
    </main>
  );
}
'@
Write-File "app\(console)\users\[id]\page.tsx" $userDetailPage

# ----------------------------------------------------------------------------
# 3. support/tickets/[id]/page.tsx
# ----------------------------------------------------------------------------
$ticketDetailPage = @'
"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Send, CheckCircle2, Clock, AlertTriangle, StickyNote } from "lucide-react";
import { Button, Card, StatusPill, Select, Textarea, Badge } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

type TicketStatus = "open" | "in_progress" | "resolved" | "closed";
type TicketPriority = "low" | "medium" | "high" | "urgent";

const STATUS_TONE: Record<TicketStatus, "warning" | "info" | "success" | "neutral"> = {
  open: "warning",
  in_progress: "info",
  resolved: "success",
  closed: "neutral"
};

const PRIORITY_TONE: Record<TicketPriority, "neutral" | "info" | "warning" | "error"> = {
  low: "neutral",
  medium: "info",
  high: "warning",
  urgent: "error"
};

const CANNED_RESPONSES = [
  { label: "Payout timing explanation", value: "Payouts are processed weekly in batches. Your request has been received and will be included in the next scheduled batch, typically disbursed within 3-5 business days after approval." },
  { label: "Refund policy info", value: "Our refund policy allows requests within 7 days of purchase, provided less than 30% of the course has been completed. I've forwarded your request to our Finance team for review." },
  { label: "Certificate not generated", value: "Certificates are generated automatically once all lessons and quizzes in a course are marked complete. Please confirm all sections show 100% and let us know if the issue persists." }
];

type Message = {
  id: string;
  author: string;
  role: "requester" | "staff";
  body: string;
  createdAt: string;
};

const INITIAL_THREAD: Message[] = [
  { id: "m1", author: "Ali Bukhari", role: "requester", body: "Hi, I requested a payout 5 days ago and haven't received it yet. Can someone check the status?", createdAt: "2026-08-07T22:15:00Z" },
  { id: "m2", author: "Support Desk", role: "staff", body: "Thanks for reaching out - I can see your request in the queue. Let me check with the Finance team and get back to you shortly.", createdAt: "2026-08-08T08:30:00Z" }
];

const INTERNAL_NOTES_INITIAL = [
  { id: "n1", author: "Support Desk", body: "Verified payout request PO-4471 is in this week's batch, pending Finance approval.", createdAt: "2026-08-08T08:32:00Z" }
];

// Dummy ticket - would normally be fetched by params.id
const DUMMY_TICKET = {
  subject: "Payout not received",
  requesterName: "Ali Bukhari",
  requesterEmail: "ali.bukhari@example.com",
  category: "Payments",
  priority: "high" as TicketPriority,
  slaDueAt: "2026-08-10T22:15:00Z",
  createdAt: "2026-08-07T22:15:00Z"
};

export default function SupportTicketDetailPage() {
  const params = useParams();
  const router = useRouter();
  const ticketId = params?.id as string;

  const [status, setStatus] = useState<TicketStatus>("in_progress");
  const [thread, setThread] = useState(INITIAL_THREAD);
  const [notes, setNotes] = useState(INTERNAL_NOTES_INITIAL);
  const [replyText, setReplyText] = useState("");
  const [noteText, setNoteText] = useState("");
  const [cannedValue, setCannedValue] = useState("");

  const isOverdue = new Date(DUMMY_TICKET.slaDueAt).getTime() < Date.now() && status !== "resolved" && status !== "closed";

  const sendReply = () => {
    if (!replyText.trim()) return;
    setThread((prev) => [
      ...prev,
      { id: `m${prev.length + 1}`, author: "Support Desk", role: "staff", body: replyText.trim(), createdAt: new Date().toISOString() }
    ]);
    setReplyText("");
    setCannedValue("");
    if (status === "open") setStatus("in_progress");
  };

  const addNote = () => {
    if (!noteText.trim()) return;
    setNotes((prev) => [...prev, { id: `n${prev.length + 1}`, author: "Support Desk", body: noteText.trim(), createdAt: new Date().toISOString() }]);
    setNoteText("");
  };

  const resolveTicket = () => {
    setStatus("resolved");
  };

  const applyCanned = (value: string) => {
    setCannedValue(value);
    const found = CANNED_RESPONSES.find((c) => c.value === value);
    if (found) setReplyText(found.value);
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/support/tickets")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to ticket queue
      </button>

      <Card className="mb-6 flex flex-col gap-4 p-6">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[19px] font-semibold text-ink">{DUMMY_TICKET.subject}</h1>
              <StatusPill label={status.replace("_", " ")} tone={STATUS_TONE[status]} />
              <StatusPill label={DUMMY_TICKET.priority} tone={PRIORITY_TONE[DUMMY_TICKET.priority]} />
            </div>
            <p className="mt-1.5 text-[12.5px] text-ink-soft">
              {DUMMY_TICKET.requesterName} ({DUMMY_TICKET.requesterEmail}) - {DUMMY_TICKET.category} - Ticket #{ticketId}
            </p>
          </div>
          <div className="flex shrink-0 items-center gap-2">
            <div className="w-[160px]">
              <Select
                options={[
                  { label: "Open", value: "open" },
                  { label: "In progress", value: "in_progress" },
                  { label: "Resolved", value: "resolved" },
                  { label: "Closed", value: "closed" }
                ]}
                value={status}
                onChange={(e) => setStatus(e.target.value as TicketStatus)}
              />
            </div>
            {status !== "resolved" && status !== "closed" && (
              <Button size="sm" onClick={resolveTicket}>
                <CheckCircle2 size={14} strokeWidth={1.75} /> Resolve
              </Button>
            )}
          </div>
        </div>

        <div className={`flex items-center gap-2 rounded-control border px-3.5 py-2.5 text-[12.5px] ${isOverdue ? "border-error bg-error-tint text-error" : "border-line text-ink-soft"}`}>
          {isOverdue ? <AlertTriangle size={14} strokeWidth={1.75} /> : <Clock size={14} strokeWidth={1.75} />}
          SLA due {formatDate(DUMMY_TICKET.slaDueAt)} - {isOverdue ? "overdue" : formatRelativeTime(DUMMY_TICKET.slaDueAt)}
        </div>
      </Card>

      <div className="mb-6">
        <p className="mb-3 text-[14px] font-semibold text-ink">Conversation</p>
        <div className="flex flex-col gap-3">
          {thread.map((msg) => (
            <div
              key={msg.id}
              className={`max-w-[85%] rounded-card border p-4 ${
                msg.role === "staff" ? "ml-auto border-ink bg-paper-dim" : "border-line bg-card"
              }`}
            >
              <div className="mb-1.5 flex items-center justify-between gap-3">
                <span className="text-[12.5px] font-semibold text-ink">{msg.author}</span>
                <span className="text-[11px] text-ink-soft">{formatRelativeTime(msg.createdAt)}</span>
              </div>
              <p className="text-[13px] leading-relaxed text-ink">{msg.body}</p>
            </div>
          ))}
        </div>

        <Card className="mt-4 flex flex-col gap-3 p-4">
          <Select
            placeholder="Insert a canned response..."
            options={CANNED_RESPONSES.map((c) => ({ label: c.label, value: c.value }))}
            value={cannedValue}
            onChange={(e) => applyCanned(e.target.value)}
          />
          <Textarea rows={4} placeholder="Type your reply..." value={replyText} onChange={(e) => setReplyText(e.target.value)} />
          <div className="flex justify-end">
            <Button size="sm" onClick={sendReply} disabled={!replyText.trim()}>
              <Send size={14} strokeWidth={1.75} /> Send reply
            </Button>
          </div>
        </Card>
      </div>

      <div>
        <p className="mb-3 flex items-center gap-1.5 text-[14px] font-semibold text-ink">
          <StickyNote size={15} strokeWidth={1.75} /> Internal notes
        </p>
        <p className="mb-3 text-[12px] text-ink-soft">Only visible to admin staff - never shown to the requester.</p>
        <div className="mb-3 flex flex-col gap-2">
          {notes.map((note) => (
            <div key={note.id} className="rounded-control border border-warning bg-warning-tint px-3.5 py-3">
              <div className="mb-1 flex items-center justify-between gap-3">
                <span className="text-[12px] font-semibold text-ink">{note.author}</span>
                <span className="text-[11px] text-ink-soft">{formatRelativeTime(note.createdAt)}</span>
              </div>
              <p className="text-[12.5px] text-ink">{note.body}</p>
            </div>
          ))}
        </div>
        <div className="flex gap-2">
          <Textarea rows={2} placeholder="Add an internal note..." value={noteText} onChange={(e) => setNoteText(e.target.value)} className="flex-1" />
          <Button size="sm" variant="secondary" onClick={addNote} disabled={!noteText.trim()}>
            Add note
          </Button>
        </div>
      </div>
    </main>
  );
}
'@
Write-File "app\(console)\support\tickets\[id]\page.tsx" $ticketDetailPage

# ----------------------------------------------------------------------------
# 4. login/page.tsx - add mandatory 2FA step
# ----------------------------------------------------------------------------
$loginPage = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ShieldCheck, AlertCircle, ArrowLeft } from "lucide-react";
import { Button, Card, Input, ThemeToggle } from "@saachi/ui";
import { findStaffUser, setAuthCookies, ROLE_LABEL, type StaffRole, type StaffUser } from "../../lib/permissions";

const DEMO_CREDENTIALS: { role: StaffRole; email: string; password: string }[] = [
  { role: "super_admin", email: "superadmin@saachi.ai", password: "super123" },
  { role: "admin", email: "admin@saachi.ai", password: "admin123" },
  { role: "finance_officer", email: "finance@saachi.ai", password: "finance123" },
  { role: "support_officer", email: "support@saachi.ai", password: "support123" }
];

// Demo-only fixed code - a real backend would generate/verify this server-side (TOTP or SMS/email OTP).
const DEMO_2FA_CODE = "123456";

export default function AdminLoginPage() {
  const router = useRouter();
  const [step, setStep] = useState<"credentials" | "2fa">("credentials");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [code, setCode] = useState("");
  const [pendingUser, setPendingUser] = useState<StaffUser | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleCredentialsSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    const user = findStaffUser(email, password);
    if (!user) {
      setError("Invalid email or password. Check the demo credentials below.");
      return;
    }

    setPendingUser(user);
    setStep("2fa");
  };

  const handle2faSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (!pendingUser) {
      setStep("credentials");
      return;
    }

    if (code.trim() !== DEMO_2FA_CODE) {
      setError(`Invalid code. For this demo, use ${DEMO_2FA_CODE}.`);
      return;
    }

    setLoading(true);
    setAuthCookies(pendingUser);
    setTimeout(() => router.push("/dashboard"), 500);
  };

  const backToCredentials = () => {
    setStep("credentials");
    setCode("");
    setError("");
  };

  const fillDemo = (cred: (typeof DEMO_CREDENTIALS)[number]) => {
    setEmail(cred.email);
    setPassword(cred.password);
    setError("");
  };

  return (
    <main className="flex min-h-screen items-center justify-center bg-paper px-4 py-10">
      <div className="absolute right-5 top-5">
        <ThemeToggle />
      </div>

      <div className="flex w-full max-w-[860px] flex-col gap-6 lg:flex-row lg:items-start">
        <Card className="w-full max-w-[400px] p-8 lg:mx-auto">
          <div className="mb-6 flex flex-col items-center text-center">
            <span className="mb-4 flex h-11 w-11 items-center justify-center rounded-full border border-ink text-[15px] font-bold text-ink">
              S
            </span>
            <h1 className="text-[20px] font-semibold text-ink">Saachi AI - Admin</h1>
            <p className="mt-1.5 text-[13px] text-ink-soft">
              {step === "credentials" ? "Internal staff access only." : "Enter your verification code."}
            </p>
          </div>

          {step === "credentials" ? (
            <form onSubmit={handleCredentialsSubmit} className="flex flex-col gap-4">
              <Input
                label="Email"
                type="email"
                placeholder="you@saachi.ai"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
              <Input
                label="Password"
                type="password"
                placeholder="********"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />

              {error && (
                <div className="flex items-start gap-2 rounded-control border border-error bg-error-tint px-3 py-2.5 text-[12.5px] text-error">
                  <AlertCircle size={14} strokeWidth={1.75} className="mt-0.5 shrink-0" />
                  <span>{error}</span>
                </div>
              )}

              <Button type="submit" size="lg">
                Continue
              </Button>
            </form>
          ) : (
            <form onSubmit={handle2faSubmit} className="flex flex-col gap-4">
              <div className="rounded-control border border-line bg-paper-dim px-3.5 py-3 text-[12.5px] text-ink-soft">
                A 6-digit verification code has been sent to <span className="font-medium text-ink">{pendingUser?.email}</span>.
                For this demo, use <span className="font-mono font-semibold text-ink">{DEMO_2FA_CODE}</span>.
              </div>

              <Input
                label="Verification code"
                type="text"
                inputMode="numeric"
                maxLength={6}
                placeholder="000000"
                value={code}
                onChange={(e) => setCode(e.target.value.replace(/\D/g, ""))}
                required
                className="text-center font-mono text-[18px] tracking-[0.3em]"
              />

              {error && (
                <div className="flex items-start gap-2 rounded-control border border-error bg-error-tint px-3 py-2.5 text-[12.5px] text-error">
                  <AlertCircle size={14} strokeWidth={1.75} className="mt-0.5 shrink-0" />
                  <span>{error}</span>
                </div>
              )}

              <Button type="submit" size="lg" disabled={loading || code.length < 6}>
                {loading ? "Verifying..." : "Verify & continue"}
              </Button>

              <button
                type="button"
                onClick={backToCredentials}
                className="flex items-center justify-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
              >
                <ArrowLeft size={13} strokeWidth={1.75} /> Back to login
              </button>
            </form>
          )}

          <div className="mt-5 flex items-center justify-center gap-1.5 text-[12px] text-ink-soft">
            <ShieldCheck size={13} strokeWidth={1.75} />
            Role-based access control demo - 2FA required
          </div>
        </Card>

        <Card className="w-full max-w-[400px] p-6 lg:mx-auto">
          <p className="mb-1 text-[13px] font-semibold text-ink">Demo credentials</p>
          <p className="mb-4 text-[12px] text-ink-soft">
            No backend yet - click a role below to auto-fill and try each access level. 2FA code: <span className="font-mono font-semibold text-ink">{DEMO_2FA_CODE}</span>.
          </p>
          <div className="flex flex-col gap-2">
            {DEMO_CREDENTIALS.map((cred) => (
              <button
                key={cred.role}
                type="button"
                onClick={() => fillDemo(cred)}
                disabled={step === "2fa"}
                className="flex flex-col items-start rounded-control border border-line px-3.5 py-2.5 text-left transition-colors duration-150 ease-out hover:border-line-strong hover:bg-paper-dim disabled:cursor-not-allowed disabled:opacity-40"
              >
                <span className="text-[13px] font-semibold text-ink">{ROLE_LABEL[cred.role]}</span>
                <span className="mt-0.5 font-mono text-[11.5px] text-ink-soft">{cred.email}</span>
                <span className="font-mono text-[11.5px] text-ink-soft">{cred.password}</span>
              </button>
            ))}
          </div>
        </Card>
      </div>
    </main>
  );
}
'@
Write-File "app\login\page.tsx" $loginPage

Write-Host ""
Write-Host "Done. Summary:" -ForegroundColor Cyan
Write-Host "  - finance/payouts/page.tsx        : NEW - payout queue with batch approve"
Write-Host "  - users/[id]/page.tsx              : NEW - profile, activity log, suspend/ban, role"
Write-Host "  - support/tickets/[id]/page.tsx    : NEW - conversation thread, internal notes, canned responses"
Write-Host "  - login/page.tsx                   : UPDATED - mandatory 2FA step (demo code: 123456)"
Write-Host ""
Write-Host "All new pages use in-memory dummy data (no backend calls) - consistent with the" -ForegroundColor Yellow
Write-Host "rest of the admin app's current mock-data approach." -ForegroundColor Yellow