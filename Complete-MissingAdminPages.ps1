# ============================================================
# Complete-MissingAdminPages.ps1
# Creates all missing/unverified admin pages:
#   1) users/[id]/page.tsx        - editable user detail
#   2) support/tickets/[id]/page.tsx - ticket detail w/ reply thread
#   3) finance/payouts/page.tsx   - payout batch management
#   4) moderation/content/page.tsx - generic content moderation queue
# Safe to re-run - backs up existing files before overwriting.
# ============================================================

param(
    [string]$ProjectRoot = (Get-Location).Path
)

$consoleRoot = Join-Path $ProjectRoot "apps\admin\app\(console)"

function Write-PageFile {
    param(
        [string]$RelativeDir,
        [string]$Content
    )
    $dir = Join-Path $consoleRoot $RelativeDir
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $filePath = Join-Path $dir "page.tsx"
    if (Test-Path $filePath) {
        Copy-Item $filePath "$filePath.bak" -Force
        Write-Host "[BACKUP] $filePath -> $filePath.bak" -ForegroundColor Yellow
    }
    Set-Content -LiteralPath $filePath -Value $Content -NoNewline
    Write-Host "[OK] Written -> $filePath" -ForegroundColor Green
}

# ------------------------------------------------------------
# 1) users/[id]/page.tsx
# ------------------------------------------------------------
$usersDetail = @'
"use client";

import { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { toast } from "sonner";
import {
  ArrowLeft,
  Pencil,
  Save,
  X,
  Mail,
  MapPin,
  Calendar,
  Clock,
  ShieldAlert,
  Ban,
  CheckCircle2,
  History
} from "lucide-react";
import { Button, Card, Input, Select, StatusPill, Modal, Textarea, ShimmerKpiCard } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

type UserRole = "learner" | "instructor" | "corporate" | "admin";
type UserStatus = "active" | "suspended" | "banned" | "pending";

type UserDetail = {
  id: string;
  fullName: string;
  email: string;
  role: UserRole;
  status: UserStatus;
  location: string;
  joinedAt: string;
  lastActiveAt: string;
  coursesEnrolled: number;
  coursesPublished: number;
  totalSpent: number;
  notes: string;
};

const ROLE_OPTIONS = [
  { label: "Learner", value: "learner" },
  { label: "Instructor", value: "instructor" },
  { label: "Corporate", value: "corporate" },
  { label: "Admin", value: "admin" }
];

const STATUS_OPTIONS = [
  { label: "Active", value: "active" },
  { label: "Suspended", value: "suspended" },
  { label: "Banned", value: "banned" },
  { label: "Pending", value: "pending" }
];

const STATUS_TONE: Record<UserStatus, "success" | "warning" | "error" | "info"> = {
  active: "success",
  suspended: "warning",
  banned: "error",
  pending: "info"
};

const MOCK_ACTIVITY = [
  { id: "a1", label: "Logged in", createdAt: "2026-08-08T06:10:00Z" },
  { id: "a2", label: "Enrolled in \"AI Automation with n8n\"", createdAt: "2026-08-06T14:22:00Z" },
  { id: "a3", label: "Updated profile information", createdAt: "2026-08-02T09:15:00Z" },
  { id: "a4", label: "Account created", createdAt: "2026-06-14T11:00:00Z" }
];

function buildMockUser(id: string): UserDetail {
  return {
    id,
    fullName: "Fatima Noor",
    email: "fatima.noor@example.com",
    role: "learner",
    status: "active",
    location: "Lahore, Pakistan",
    joinedAt: "2026-06-14T11:00:00Z",
    lastActiveAt: "2026-08-08T06:10:00Z",
    coursesEnrolled: 6,
    coursesPublished: 0,
    totalSpent: 214,
    notes: ""
  };
}

export default function UserDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const userId = params?.id ?? "";

  const [isLoading, setIsLoading] = useState(true);
  const [user, setUser] = useState<UserDetail | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [draft, setDraft] = useState<UserDetail | null>(null);
  const [saving, setSaving] = useState(false);
  const [suspendModalOpen, setSuspendModalOpen] = useState(false);
  const [banModalOpen, setBanModalOpen] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => {
      const mock = buildMockUser(userId);
      setUser(mock);
      setDraft(mock);
      setIsLoading(false);
    }, 500);
    return () => clearTimeout(t);
  }, [userId]);

  const startEdit = () => {
    setDraft(user);
    setIsEditing(true);
  };

  const cancelEdit = () => {
    setDraft(user);
    setIsEditing(false);
  };

  const handleSave = () => {
    if (!draft) return;
    setSaving(true);
    setTimeout(() => {
      setUser(draft);
      setSaving(false);
      setIsEditing(false);
      toast.success("Profile updated", { description: "Changes have been saved successfully." });
    }, 600);
  };

  const handleSuspend = () => {
    if (!user) return;
    const updated = { ...user, status: "suspended" as UserStatus };
    setUser(updated);
    setDraft(updated);
    setSuspendModalOpen(false);
    toast.success("User suspended", { description: `${user.fullName} can no longer log in until reactivated.` });
  };

  const handleBan = () => {
    if (!user) return;
    const updated = { ...user, status: "banned" as UserStatus };
    setUser(updated);
    setDraft(updated);
    setBanModalOpen(false);
    toast.success("User banned", { description: `${user.fullName} has been permanently banned from the platform.` });
  };

  const handleReactivate = () => {
    if (!user) return;
    const updated = { ...user, status: "active" as UserStatus };
    setUser(updated);
    setDraft(updated);
    toast.success("User reactivated", { description: `${user.fullName} can log in again.` });
  };

  if (isLoading || !user || !draft) {
    return (
      <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
        <div className="mb-6 flex flex-col gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/users")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to Users
      </button>

      <Card className="mb-6 flex flex-col gap-5 p-6 sm:flex-row sm:items-start sm:justify-between">
        <div className="flex items-start gap-4">
          <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-full border border-line bg-paper-dim text-[18px] font-semibold text-ink-soft">
            {user.fullName.charAt(0)}
          </div>
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[19px] font-semibold text-ink">{user.fullName}</h1>
              <StatusPill label={user.status} tone={STATUS_TONE[user.status]} />
            </div>
            <div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-[12.5px] text-ink-soft">
              <span className="flex items-center gap-1.5">
                <Mail size={13} strokeWidth={1.75} /> {user.email}
              </span>
              <span className="flex items-center gap-1.5">
                <MapPin size={13} strokeWidth={1.75} /> {user.location}
              </span>
              <span className="flex items-center gap-1.5">
                <Calendar size={13} strokeWidth={1.75} /> Joined {formatDate(user.joinedAt)}
              </span>
              <span className="flex items-center gap-1.5">
                <Clock size={13} strokeWidth={1.75} /> Active {formatRelativeTime(user.lastActiveAt)}
              </span>
            </div>
          </div>
        </div>

        <div className="flex shrink-0 flex-wrap gap-2">
          {!isEditing ? (
            <Button size="sm" variant="secondary" onClick={startEdit}>
              <Pencil size={14} strokeWidth={1.75} /> Edit profile
            </Button>
          ) : (
            <>
              <Button size="sm" variant="ghost" onClick={cancelEdit} disabled={saving}>
                <X size={14} strokeWidth={1.75} /> Cancel
              </Button>
              <Button size="sm" onClick={handleSave} disabled={saving}>
                <Save size={14} strokeWidth={1.75} /> {saving ? "Saving..." : "Save changes"}
              </Button>
            </>
          )}
        </div>
      </Card>

      <div className="mb-6 grid grid-cols-3 gap-4">
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Courses enrolled</p>
          <p className="mt-1 font-mono text-[20px] font-semibold text-ink">{user.coursesEnrolled}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Courses published</p>
          <p className="mt-1 font-mono text-[20px] font-semibold text-ink">{user.coursesPublished}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Total spent</p>
          <p className="mt-1 font-mono text-[20px] font-semibold text-ink">${user.totalSpent}</p>
        </Card>
      </div>

      <Card className="mb-6 p-6">
        <p className="mb-4 text-[14px] font-semibold text-ink">Profile details</p>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Input
            label="Full name"
            value={draft.fullName}
            disabled={!isEditing}
            onChange={(e) => setDraft({ ...draft, fullName: e.target.value })}
          />
          <Input
            label="Email"
            type="email"
            value={draft.email}
            disabled={!isEditing}
            onChange={(e) => setDraft({ ...draft, email: e.target.value })}
          />
          <Select
            label="Role"
            options={ROLE_OPTIONS}
            value={draft.role}
            onChange={(e) => setDraft({ ...draft, role: e.target.value as UserRole })}
          />
          <Select
            label="Status"
            options={STATUS_OPTIONS}
            value={draft.status}
            onChange={(e) => setDraft({ ...draft, status: e.target.value as UserStatus })}
          />
          <Input
            label="Location"
            value={draft.location}
            disabled={!isEditing}
            onChange={(e) => setDraft({ ...draft, location: e.target.value })}
          />
        </div>
        <div className="mt-4">
          <Textarea
            label="Internal notes"
            placeholder="Add internal notes about this user (not visible to them)..."
            rows={3}
            value={draft.notes}
            disabled={!isEditing}
            onChange={(e) => setDraft({ ...draft, notes: e.target.value })}
          />
        </div>
      </Card>

      <Card className="mb-6 p-6">
        <p className="mb-4 text-[14px] font-semibold text-ink">Account actions</p>
        <div className="flex flex-wrap gap-2">
          {user.status !== "active" && (
            <Button size="sm" variant="secondary" onClick={handleReactivate}>
              <CheckCircle2 size={14} strokeWidth={1.75} /> Reactivate account
            </Button>
          )}
          {user.status !== "suspended" && user.status !== "banned" && (
            <Button size="sm" variant="secondary" onClick={() => setSuspendModalOpen(true)}>
              <ShieldAlert size={14} strokeWidth={1.75} /> Suspend account
            </Button>
          )}
          {user.status !== "banned" && (
            <Button size="sm" variant="danger" onClick={() => setBanModalOpen(true)}>
              <Ban size={14} strokeWidth={1.75} /> Ban account
            </Button>
          )}
        </div>
      </Card>

      <Card className="p-6">
        <div className="mb-4 flex items-center gap-2">
          <History size={15} strokeWidth={1.75} className="text-ink" />
          <p className="text-[14px] font-semibold text-ink">Activity log</p>
        </div>
        <div className="flex flex-col gap-3">
          {MOCK_ACTIVITY.map((a) => (
            <div key={a.id} className="flex items-center justify-between gap-3 border-b border-line pb-3 last:border-0 last:pb-0">
              <span className="text-[13px] text-ink">{a.label}</span>
              <span className="shrink-0 text-[12px] text-ink-soft">{formatRelativeTime(a.createdAt)}</span>
            </div>
          ))}
        </div>
      </Card>

      <Modal
        open={suspendModalOpen}
        onClose={() => setSuspendModalOpen(false)}
        title="Suspend this account?"
        footer={
          <>
            <Button variant="ghost" onClick={() => setSuspendModalOpen(false)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleSuspend}>
              Suspend account
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          <span className="font-semibold text-ink">{user.fullName}</span> will be temporarily unable to log in. You
          can reactivate their account at any time.
        </p>
      </Modal>

      <Modal
        open={banModalOpen}
        onClose={() => setBanModalOpen(false)}
        title="Ban this account?"
        footer={
          <>
            <Button variant="ghost" onClick={() => setBanModalOpen(false)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleBan}>
              Ban account
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          This is a more severe action than suspension. <span className="font-semibold text-ink">{user.fullName}</span>{" "}
          will be permanently banned from the platform unless manually reactivated by a Super Admin.
        </p>
      </Modal>
    </main>
  );
}
'@

Write-PageFile -RelativeDir "users\[id]" -Content $usersDetail

# ------------------------------------------------------------
# 2) support/tickets/[id]/page.tsx
# ------------------------------------------------------------
$ticketDetail = @'
"use client";

import { useEffect, useRef, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { toast } from "sonner";
import {
  ArrowLeft,
  Send,
  User,
  Headset,
  AlertTriangle,
  CheckCircle2,
  Clock,
  Tag,
  UserCog
} from "lucide-react";
import { Button, Card, Select, StatusPill, Textarea, ShimmerKpiCard } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

type TicketStatus = "open" | "in_progress" | "resolved" | "closed";
type TicketPriority = "low" | "medium" | "high" | "urgent";

type ThreadEntry = {
  id: string;
  author: string;
  authorType: "requester" | "staff";
  body: string;
  createdAt: string;
};

type TicketDetail = {
  id: string;
  subject: string;
  requesterName: string;
  requesterEmail: string;
  category: string;
  status: TicketStatus;
  priority: TicketPriority;
  assignedTo: string | null;
  slaDueAt: string;
  createdAt: string;
  thread: ThreadEntry[];
};

const STATUS_OPTIONS = [
  { label: "Open", value: "open" },
  { label: "In progress", value: "in_progress" },
  { label: "Resolved", value: "resolved" },
  { label: "Closed", value: "closed" }
];

const PRIORITY_OPTIONS = [
  { label: "Low", value: "low" },
  { label: "Medium", value: "medium" },
  { label: "High", value: "high" },
  { label: "Urgent", value: "urgent" }
];

const ASSIGNEE_OPTIONS = [
  { label: "Unassigned", value: "" },
  { label: "Support Desk", value: "Support Desk" },
  { label: "Finance Desk", value: "Finance Desk" },
  { label: "Abdul Rehman Irfan", value: "Abdul Rehman Irfan" }
];

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
  "Thanks for reaching out - we're looking into this and will update you shortly.",
  "This has been resolved on our end. Please let us know if the issue persists.",
  "Could you share a screenshot or transaction ID so we can investigate further?"
];

function buildMockTicket(id: string): TicketDetail {
  return {
    id,
    subject: "Payout not received for July batch",
    requesterName: "Hassan Raza",
    requesterEmail: "hassan.raza@example.com",
    category: "Payouts",
    status: "open",
    priority: "high",
    assignedTo: "Finance Desk",
    slaDueAt: "2026-08-11T12:00:00Z",
    createdAt: "2026-08-08T09:30:00Z",
    thread: [
      {
        id: "t1",
        author: "Hassan Raza",
        authorType: "requester",
        body: "Hi, I still haven't received my payout for the July batch. My payout method is set up correctly and my balance shows as paid out, but nothing has arrived in my bank account. Can someone check this?",
        createdAt: "2026-08-08T09:30:00Z"
      },
      {
        id: "t2",
        author: "Finance Desk",
        authorType: "staff",
        body: "Thanks for flagging this, Hassan. We're checking with our payment processor for the July batch and will get back to you within 24 hours.",
        createdAt: "2026-08-08T11:15:00Z"
      }
    ]
  };
}

export default function SupportTicketDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const ticketId = params?.id ?? "";

  const [isLoading, setIsLoading] = useState(true);
  const [ticket, setTicket] = useState<TicketDetail | null>(null);
  const [reply, setReply] = useState("");
  const [sending, setSending] = useState(false);
  const threadEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const t = setTimeout(() => {
      setTicket(buildMockTicket(ticketId));
      setIsLoading(false);
    }, 500);
    return () => clearTimeout(t);
  }, [ticketId]);

  useEffect(() => {
    threadEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [ticket?.thread.length]);

  const updateField = <K extends keyof TicketDetail>(key: K, value: TicketDetail[K]) => {
    setTicket((prev) => (prev ? { ...prev, [key]: value } : prev));
  };

  const handleSendReply = () => {
    if (!ticket || !reply.trim()) return;
    setSending(true);
    setTimeout(() => {
      const entry: ThreadEntry = {
        id: `t${ticket.thread.length + 1}`,
        author: "Support Desk",
        authorType: "staff",
        body: reply.trim(),
        createdAt: new Date().toISOString()
      };
      setTicket({ ...ticket, thread: [...ticket.thread, entry], status: ticket.status === "open" ? "in_progress" : ticket.status });
      setReply("");
      setSending(false);
      toast.success("Reply sent", { description: `${ticket.requesterName} will be notified by email.` });
    }, 500);
  };

  const handleResolve = () => {
    if (!ticket) return;
    updateField("status", "resolved");
    toast.success("Ticket marked as resolved");
  };

  if (isLoading || !ticket) {
    return (
      <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
        <div className="flex flex-col gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      </main>
    );
  }

  const overdue =
    new Date(ticket.slaDueAt).getTime() < Date.now() && ticket.status !== "resolved" && ticket.status !== "closed";

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/support/tickets")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to Ticket Queue
      </button>

      <Card className="mb-6 flex flex-col gap-4 p-6">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[19px] font-semibold text-ink">{ticket.subject}</h1>
              <StatusPill label={ticket.status.replace("_", " ")} tone={STATUS_TONE[ticket.status]} />
              <StatusPill label={ticket.priority} tone={PRIORITY_TONE[ticket.priority]} />
            </div>
            <div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-[12.5px] text-ink-soft">
              <span className="flex items-center gap-1.5">
                <User size={13} strokeWidth={1.75} /> {ticket.requesterName} ({ticket.requesterEmail})
              </span>
              <span className="flex items-center gap-1.5">
                <Tag size={13} strokeWidth={1.75} /> {ticket.category}
              </span>
              <span className="flex items-center gap-1.5">
                <Clock size={13} strokeWidth={1.75} /> Opened {formatRelativeTime(ticket.createdAt)}
              </span>
              {overdue ? (
                <span className="flex items-center gap-1.5 font-medium text-error">
                  <AlertTriangle size={13} strokeWidth={1.75} /> SLA overdue
                </span>
              ) : (
                <span>SLA due {formatDate(ticket.slaDueAt)}</span>
              )}
            </div>
          </div>
          {ticket.status !== "resolved" && ticket.status !== "closed" && (
            <Button size="sm" variant="secondary" onClick={handleResolve}>
              <CheckCircle2 size={14} strokeWidth={1.75} /> Mark resolved
            </Button>
          )}
        </div>

        <div className="grid grid-cols-1 gap-3 border-t border-line pt-4 sm:grid-cols-3">
          <Select
            label="Status"
            options={STATUS_OPTIONS}
            value={ticket.status}
            onChange={(e) => updateField("status", e.target.value as TicketStatus)}
          />
          <Select
            label="Priority"
            options={PRIORITY_OPTIONS}
            value={ticket.priority}
            onChange={(e) => updateField("priority", e.target.value as TicketPriority)}
          />
          <Select
            label="Assigned to"
            options={ASSIGNEE_OPTIONS}
            value={ticket.assignedTo ?? ""}
            onChange={(e) => updateField("assignedTo", e.target.value || null)}
          />
        </div>
      </Card>

      <Card className="mb-6 p-6">
        <p className="mb-4 flex items-center gap-2 text-[14px] font-semibold text-ink">
          <Headset size={15} strokeWidth={1.75} /> Conversation
        </p>
        <div className="mb-6 flex flex-col gap-3">
          {ticket.thread.map((entry) => (
            <div
              key={entry.id}
              className={`max-w-[85%] rounded-card border p-4 ${
                entry.authorType === "staff" ? "ml-auto border-line-strong bg-paper-dim" : "border-line bg-card"
              }`}
            >
              <div className="mb-1.5 flex items-center justify-between gap-3">
                <span className="flex items-center gap-1.5 text-[12.5px] font-semibold text-ink">
                  {entry.authorType === "staff" ? (
                    <UserCog size={13} strokeWidth={1.75} />
                  ) : (
                    <User size={13} strokeWidth={1.75} />
                  )}
                  {entry.author}
                </span>
                <span className="text-[11px] text-ink-soft">{formatRelativeTime(entry.createdAt)}</span>
              </div>
              <p className="text-[13.5px] leading-relaxed text-ink">{entry.body}</p>
            </div>
          ))}
          <div ref={threadEndRef} />
        </div>

        <div className="mb-3 flex flex-wrap gap-1.5">
          {CANNED_RESPONSES.map((canned, i) => (
            <button
              key={i}
              type="button"
              onClick={() => setReply(canned)}
              className="rounded-full border border-line px-3 py-1 text-[11.5px] text-ink-soft transition-colors duration-150 ease-out hover:border-line-strong hover:text-ink"
            >
              {canned.length > 40 ? `${canned.slice(0, 40)}...` : canned}
            </button>
          ))}
        </div>

        <Textarea
          label="Reply to requester"
          placeholder="Type your reply..."
          rows={4}
          value={reply}
          onChange={(e) => setReply(e.target.value)}
        />
        <div className="mt-3 flex justify-end">
          <Button onClick={handleSendReply} disabled={!reply.trim() || sending}>
            <Send size={14} strokeWidth={1.75} /> {sending ? "Sending..." : "Send reply"}
          </Button>
        </div>
      </Card>
    </main>
  );
}
'@

Write-PageFile -RelativeDir "support\tickets\[id]" -Content $ticketDetail

# ------------------------------------------------------------
# 3) finance/payouts/page.tsx
# ------------------------------------------------------------
$payoutsPage = @'
"use client";

import { useMemo, useState } from "react";
import { toast } from "sonner";
import { Banknote, CheckCircle2, Clock3, Download } from "lucide-react";
import { Button, Card, Select, StatusPill, Modal, ShimmerKpiCard, HelpTooltip, RefreshButton } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

type PayoutStatus = "pending" | "processing" | "paid" | "failed";

type PayoutRow = {
  id: string;
  instructorName: string;
  method: string;
  amount: number;
  currency: string;
  status: PayoutStatus;
  requestedAt: string;
};

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Processing", value: "processing" },
  { label: "Paid", value: "paid" },
  { label: "Failed", value: "failed" }
];

const STATUS_TONE: Record<PayoutStatus, "warning" | "info" | "success" | "error"> = {
  pending: "warning",
  processing: "info",
  paid: "success",
  failed: "error"
};

const INITIAL_PAYOUTS: PayoutRow[] = [
  { id: "PO-2026-0912-1", instructorName: "Zeeshan Tariq", method: "Bank Transfer", amount: 842, currency: "USD", status: "pending", requestedAt: "2026-08-07T10:00:00Z" },
  { id: "PO-2026-0912-2", instructorName: "Ayesha Malik", method: "JazzCash", amount: 315, currency: "USD", status: "pending", requestedAt: "2026-08-07T10:00:00Z" },
  { id: "PO-2026-0912-3", instructorName: "Bilal Ahmed", method: "Stripe Connect", amount: 1204, currency: "USD", status: "pending", requestedAt: "2026-08-07T10:00:00Z" },
  { id: "PO-2026-0905-1", instructorName: "Nida Khan", method: "Bank Transfer", amount: 620, currency: "USD", status: "paid", requestedAt: "2026-07-31T10:00:00Z" },
  { id: "PO-2026-0905-2", instructorName: "Hassan Raza", method: "Easypaisa", amount: 190, currency: "USD", status: "paid", requestedAt: "2026-07-31T10:00:00Z" }
];

export default function PayoutsPage() {
  const [payouts, setPayouts] = useState(INITIAL_PAYOUTS);
  const [statusFilter, setStatusFilter] = useState("");
  const [batchModalOpen, setBatchModalOpen] = useState(false);
  const [processing, setProcessing] = useState(false);

  const filtered = useMemo(() => {
    if (!statusFilter) return payouts;
    return payouts.filter((p) => p.status === statusFilter);
  }, [payouts, statusFilter]);

  const summary = useMemo(() => {
    const pending = payouts.filter((p) => p.status === "pending");
    const paid = payouts.filter((p) => p.status === "paid");
    return {
      pendingCount: pending.length,
      pendingTotal: pending.reduce((sum, p) => sum + p.amount, 0),
      paidThisMonth: paid.reduce((sum, p) => sum + p.amount, 0)
    };
  }, [payouts]);

  const handleProcessBatch = () => {
    setProcessing(true);
    setTimeout(() => {
      setPayouts((prev) => prev.map((p) => (p.status === "pending" ? { ...p, status: "paid" as PayoutStatus } : p)));
      setProcessing(false);
      setBatchModalOpen(false);
      toast.success("Payout batch processed", {
        description: `${summary.pendingCount} payouts totaling ${formatCurrency(summary.pendingTotal, "USD")} have been marked as paid.`
      });
    }, 900);
  };

  const handleExport = () => {
    const header = ["Payout ID", "Instructor", "Method", "Amount", "Status", "Requested"];
    const rows = payouts.map((p) => [p.id, p.instructorName, p.method, p.amount.toString(), p.status, formatDate(p.requestedAt)]);
    const csv = [header, ...rows].map((r) => r.map((v) => `"${String(v).replace(/"/g, '""')}"`).join(",")).join("\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `saachi-payouts-${new Date().toISOString().slice(0, 10)}.csv`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
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
              <h1 className="text-[22px] font-semibold text-ink">Payouts</h1>
              <HelpTooltip text="Instructor payout requests awaiting processing. Process the batch to mark all pending payouts as paid via each instructor's configured method." />
            </div>
            <p className="mt-0.5 text-[13px] text-ink-soft">Review and process instructor payout batches.</p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <Button size="sm" variant="secondary" onClick={handleExport}>
            <Download size={14} strokeWidth={1.75} /> Export CSV
          </Button>
          <RefreshButton />
        </div>
      </div>

      <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <Card className="p-5">
          <p className="flex items-center gap-1.5 text-[12px] text-ink-soft">
            <Clock3 size={13} strokeWidth={1.75} /> Pending payouts
          </p>
          <p className="mt-1.5 font-mono text-[22px] font-semibold text-ink">{summary.pendingCount}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Pending amount</p>
          <p className="mt-1.5 font-mono text-[22px] font-semibold text-ink">{formatCurrency(summary.pendingTotal, "USD")}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[12px] text-ink-soft">Paid this batch</p>
          <p className="mt-1.5 font-mono text-[22px] font-semibold text-ink">{formatCurrency(summary.paidThisMonth, "USD")}</p>
        </Card>
      </div>

      <div className="mb-5 flex flex-wrap items-center justify-between gap-3">
        <div className="w-[200px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
        {summary.pendingCount > 0 && (
          <Button size="sm" onClick={() => setBatchModalOpen(true)}>
            <CheckCircle2 size={14} strokeWidth={1.75} /> Process pending batch
          </Button>
        )}
      </div>

      <div className="overflow-hidden rounded-card border border-line bg-card">
        {filtered.map((p) => (
          <div key={p.id} className="flex flex-col gap-3 border-b border-line px-5 py-4 last:border-0 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <div className="flex items-center gap-2.5">
                <p className="text-[14px] font-semibold text-ink">{p.instructorName}</p>
                <StatusPill label={p.status} tone={STATUS_TONE[p.status]} />
              </div>
              <p className="mt-1 text-[12.5px] text-ink-soft">
                {p.id} - {p.method} - requested {formatDate(p.requestedAt)}
              </p>
            </div>
            <span className="shrink-0 font-mono text-[16px] font-semibold text-ink">{formatCurrency(p.amount, p.currency)}</span>
          </div>
        ))}
        {filtered.length === 0 && (
          <div className="px-5 py-10 text-center text-[13px] text-ink-soft">No payouts match this filter.</div>
        )}
      </div>

      <Modal
        open={batchModalOpen}
        onClose={() => setBatchModalOpen(false)}
        title="Process pending payout batch?"
        footer={
          <>
            <Button variant="ghost" onClick={() => setBatchModalOpen(false)} disabled={processing}>
              Cancel
            </Button>
            <Button onClick={handleProcessBatch} disabled={processing}>
              {processing ? "Processing..." : "Process batch"}
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          This will mark <span className="font-semibold text-ink">{summary.pendingCount} pending payouts</span>{" "}
          totaling <span className="font-semibold text-ink">{formatCurrency(summary.pendingTotal, "USD")}</span> as paid,
          disbursed via each instructor's configured payout method.
        </p>
      </Modal>
    </main>
  );
}
'@

Write-PageFile -RelativeDir "finance\payouts" -Content $payoutsPage

# ------------------------------------------------------------
# 4) moderation/content/page.tsx
# ------------------------------------------------------------
$moderationContent = @'
"use client";

import { useState } from "react";
import { ShieldCheck, FileWarning, CheckCircle2, Trash2, ShieldAlert } from "lucide-react";
import { Button, Card, Select, StatusPill, EmptyState, HelpTooltip } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

type ContentType = "course_description" | "instructor_bio" | "banner_copy" | "certificate_note";
type FlagStatus = "pending" | "removed" | "dismissed" | "warned";

type FlaggedContent = {
  id: string;
  type: ContentType;
  title: string;
  body: string;
  author: string;
  flaggedBy: string;
  flagReason: string;
  status: FlagStatus;
  createdAt: string;
};

const TYPE_LABEL: Record<ContentType, string> = {
  course_description: "Course description",
  instructor_bio: "Instructor bio",
  banner_copy: "Banner copy",
  certificate_note: "Certificate note"
};

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Removed", value: "removed" },
  { label: "Dismissed", value: "dismissed" },
  { label: "Warned", value: "warned" }
];

const STATUS_TONE: Record<FlagStatus, "warning" | "error" | "neutral" | "info"> = {
  pending: "warning",
  removed: "error",
  dismissed: "neutral",
  warned: "info"
};

const INITIAL_CONTENT: FlaggedContent[] = [
  {
    id: "c1",
    type: "course_description",
    title: "AI Automation with n8n",
    body: "This course guarantees you will make $10,000 in your first month using these automation secrets nobody talks about.",
    author: "Zeeshan Tariq",
    flaggedBy: "Automated filter",
    flagReason: "Unverifiable earnings claim",
    status: "pending",
    createdAt: "2026-08-08T08:20:00Z"
  },
  {
    id: "c2",
    type: "instructor_bio",
    title: "Bilal Ahmed - Instructor Bio",
    body: "Ex-Google, ex-Meta, ex-OpenAI senior engineer with 15 years building production AI systems at scale.",
    author: "Bilal Ahmed",
    flaggedBy: "Fatima Noor",
    flagReason: "Unverified employment claims",
    status: "pending",
    createdAt: "2026-08-07T15:10:00Z"
  }
];

export default function ContentModerationPage() {
  const [content, setContent] = useState(INITIAL_CONTENT);
  const [statusFilter, setStatusFilter] = useState("pending");

  const filtered = content.filter((c) => !statusFilter || c.status === statusFilter);

  const resolve = (id: string, status: FlagStatus) => {
    setContent((prev) => prev.map((c) => (c.id === id ? { ...c, status } : c)));
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <ShieldCheck size={17} strokeWidth={1.75} />
          </div>
          <div>
            <div className="flex items-center gap-1.5">
              <h1 className="text-[22px] font-semibold text-ink">Content Moderation</h1>
              <HelpTooltip text="Flagged platform content outside of reviews and forum posts - course descriptions, instructor bios, banner copy, and certificate notes." />
            </div>
            <p className="mt-0.5 text-[13px] text-ink-soft">Miscellaneous platform content flagged for policy review.</p>
          </div>
        </div>
        <div className="w-[180px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
      </div>

      {filtered.length === 0 ? (
        <EmptyState icon={<FileWarning size={22} strokeWidth={1.75} />} title="Nothing flagged" description="No content matches this filter." />
      ) : (
        <div className="flex flex-col gap-4">
          {filtered.map((c) => (
            <Card key={c.id} className="flex flex-col gap-4 p-5">
              <div>
                <div className="flex flex-wrap items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{c.title}</p>
                  <span className="rounded-full border border-line-strong px-2 py-0.5 text-[11px] text-ink-soft">
                    {TYPE_LABEL[c.type]}
                  </span>
                  <StatusPill label={c.status} tone={STATUS_TONE[c.status]} />
                </div>
                <p className="mt-1 text-[12.5px] text-ink-soft">
                  by {c.author} - {formatRelativeTime(c.createdAt)}
                </p>
              </div>

              <p className="rounded-control border border-line bg-paper-dim p-3.5 text-[13.5px] leading-relaxed text-ink">
                {c.body}
              </p>

              <div className="flex items-center gap-2 text-[12.5px] text-ink-soft">
                <ShieldAlert size={13} strokeWidth={1.75} className="shrink-0 text-error" />
                Flagged by {c.flaggedBy} - reason: {c.flagReason}
              </div>

              {c.status === "pending" && (
                <div className="flex flex-wrap gap-2">
                  <Button size="sm" variant="secondary" onClick={() => resolve(c.id, "dismissed")}>
                    <CheckCircle2 size={14} strokeWidth={1.75} /> Dismiss flag
                  </Button>
                  <Button size="sm" variant="secondary" onClick={() => resolve(c.id, "warned")}>
                    Warn author
                  </Button>
                  <Button size="sm" variant="danger" onClick={() => resolve(c.id, "removed")}>
                    <Trash2 size={14} strokeWidth={1.75} /> Remove content
                  </Button>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@

Write-PageFile -RelativeDir "moderation\content" -Content $moderationContent

Write-Host ""
Write-Host "Done. All 4 pages written." -ForegroundColor Cyan
Write-Host "Restart your dev server, then verify:" -ForegroundColor Cyan
Write-Host "  http://localhost:3001/users/usr_1001" -ForegroundColor Cyan
Write-Host "  http://localhost:3001/support/tickets/tkt_1001" -ForegroundColor Cyan
Write-Host "  http://localhost:3001/finance/payouts" -ForegroundColor Cyan
Write-Host "  http://localhost:3001/moderation/content" -ForegroundColor Cyan