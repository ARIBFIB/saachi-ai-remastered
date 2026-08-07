<#
  Fixes:
    1) Renames the Payouts hooks to avoid a naming collision with an existing
       hooks/useAdminFinance.ts file that already exports "useAdminPayouts".
    2) Adds the missing hooks used by users/[id]/page.tsx:
         useAdminUserDetail, useUpdateUserStatus, useUpdateUserRole
    3) Adds the missing hooks used by support/tickets/[id]/page.tsx (pre-emptive fix,
       same class of error would appear there next):
         useAdminTicketDetail, useReplyToTicket, useAddInternalNote,
         useResolveTicket, useAdminCannedResponses
    4) Makes clickable table rows (User Management, Ticket Queue) show a pointer
       cursor + hover highlight, without needing to touch the shared DataTable
       component source.

  Run from project root (SAI2), same folder as "apps" and "packages".
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$apiClientSrc = Join-Path $root "packages\api-client\src"
$adminApp = Join-Path $root "apps\admin\app"
$adminConsole = Join-Path $adminApp "(console)"

if (-not (Test-Path $apiClientSrc)) {
    Write-Host "ERROR: Could not find $apiClientSrc" -ForegroundColor Red
    exit 1
}

function Write-FileUtf8NoBom {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
    Write-Host "  Wrote: $Path" -ForegroundColor Green
}

function Add-IndexExport {
    param([string]$IndexPath, [string]$ExportLine)
    if (-not (Test-Path $IndexPath)) {
        Write-Host "  WARNING: $IndexPath not found - add manually: $ExportLine" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Raw -Path $IndexPath
    if ($content -notmatch [regex]::Escape($ExportLine)) {
        $newContent = $content.TrimEnd() + "`r`n" + $ExportLine + "`r`n"
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($IndexPath, $newContent, $utf8NoBom)
        Write-Host "  Appended export: $ExportLine" -ForegroundColor Green
    } else {
        Write-Host "  Export already present - skipped: $ExportLine" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Applying fixes..." -ForegroundColor Cyan
Write-Host ""

# ==========================================================================
# 1) RENAME payout hooks to avoid collision with useAdminFinance.ts
# ==========================================================================
$payoutHookPath = Join-Path $apiClientSrc "hooks\useAdminPayouts.ts"

$payoutHookContent = @'
"use client";

import { useMemo } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

export type AdminPayoutRequestStatus = "pending" | "approved" | "paid" | "rejected";
export type AdminPayoutRequestMethod = "bank_transfer" | "stripe_connect" | "easypaisa" | "jazzcash";

export type AdminPayoutRequest = {
  id: string;
  instructorId: string;
  instructorName: string;
  amount: number;
  currency: string;
  method: AdminPayoutRequestMethod;
  status: AdminPayoutRequestStatus;
  requestedAt: string;
  processedAt?: string;
  rejectionReason?: string;
};

const MOCK_PAYOUT_REQUESTS: AdminPayoutRequest[] = [
  {
    id: "PAYOUT-2026-0913",
    instructorId: "inst_1",
    instructorName: "Hassan Raza",
    amount: 1240,
    currency: "USD",
    method: "bank_transfer",
    status: "pending",
    requestedAt: "2026-08-05T10:12:00Z"
  },
  {
    id: "PAYOUT-2026-0914",
    instructorId: "inst_2",
    instructorName: "Fatima Noor",
    amount: 860,
    currency: "USD",
    method: "easypaisa",
    status: "pending",
    requestedAt: "2026-08-06T08:40:00Z"
  },
  {
    id: "PAYOUT-2026-0912",
    instructorId: "inst_3",
    instructorName: "Ali Bukhari",
    amount: 2100,
    currency: "USD",
    method: "stripe_connect",
    status: "approved",
    requestedAt: "2026-08-01T09:00:00Z"
  },
  {
    id: "PAYOUT-2026-0908",
    instructorId: "inst_4",
    instructorName: "Sana Iqbal",
    amount: 540,
    currency: "USD",
    method: "jazzcash",
    status: "paid",
    requestedAt: "2026-07-28T14:20:00Z",
    processedAt: "2026-07-30T11:00:00Z"
  },
  {
    id: "PAYOUT-2026-0902",
    instructorId: "inst_5",
    instructorName: "Zeeshan Tariq",
    amount: 310,
    currency: "USD",
    method: "bank_transfer",
    status: "rejected",
    requestedAt: "2026-07-20T12:00:00Z",
    processedAt: "2026-07-21T10:00:00Z",
    rejectionReason: "Bank details on file could not be verified."
  }
];

let payoutRequestStore: AdminPayoutRequest[] = [...MOCK_PAYOUT_REQUESTS];

const PAYOUT_QUEUE_KEY = ["admin", "payout-queue"] as const;

type PayoutQueueFilters = {
  status?: string;
  method?: string;
  search?: string;
};

async function fetchPayoutQueue(filters: PayoutQueueFilters): Promise<AdminPayoutRequest[]> {
  await new Promise((r) => setTimeout(r, 350));
  return payoutRequestStore.filter((p) => {
    const matchesStatus = !filters.status || p.status === filters.status;
    const matchesMethod = !filters.method || p.method === filters.method;
    const matchesSearch =
      !filters.search ||
      p.instructorName.toLowerCase().includes(filters.search.toLowerCase()) ||
      p.id.toLowerCase().includes(filters.search.toLowerCase());
    return matchesStatus && matchesMethod && matchesSearch;
  });
}

export function useAdminPayoutQueue(filters: PayoutQueueFilters = {}) {
  const key = useMemo(
    () => [...PAYOUT_QUEUE_KEY, filters.status ?? "", filters.method ?? "", filters.search ?? ""],
    [filters.status, filters.method, filters.search]
  );
  return useQuery({
    queryKey: key,
    queryFn: () => fetchPayoutQueue(filters)
  });
}

export function useProcessPayoutRequest() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; decision: "approved" | "paid" | "rejected"; reason?: string }) => {
      await new Promise((r) => setTimeout(r, 300));
      payoutRequestStore = payoutRequestStore.map((p) =>
        p.id === input.id
          ? {
              ...p,
              status: input.decision,
              processedAt: new Date().toISOString(),
              rejectionReason: input.decision === "rejected" ? input.reason : undefined
            }
          : p
      );
      return payoutRequestStore.find((p) => p.id === input.id);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PAYOUT_QUEUE_KEY });
    }
  });
}

export function useBatchProcessPayoutRequests() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { ids: string[]; decision: "approved" | "paid" | "rejected" }) => {
      await new Promise((r) => setTimeout(r, 400));
      payoutRequestStore = payoutRequestStore.map((p) =>
        input.ids.includes(p.id) ? { ...p, status: input.decision, processedAt: new Date().toISOString() } : p
      );
      return payoutRequestStore.filter((p) => input.ids.includes(p.id));
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PAYOUT_QUEUE_KEY });
    }
  });
}
'@

Write-FileUtf8NoBom -Path $payoutHookPath -Content $payoutHookContent

# Rewrite the Payouts page to use the renamed hooks/types
$payoutsPagePath = Join-Path $adminConsole "finance\payouts\page.tsx"

$payoutsPageContent = @'
"use client";

import { useMemo, useState } from "react";
import { toast } from "sonner";
import { Banknote, CheckCircle2, XCircle, Search, Layers } from "lucide-react";
import {
  useAdminPayoutQueue,
  useProcessPayoutRequest,
  useBatchProcessPayoutRequests,
  type AdminPayoutRequest
} from "@saachi/api-client";
import { Button, Card, Select, StatusPill, Modal, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";
import { LoadingSpinner } from "../../../_components/LoadingSpinner";

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Approved", value: "approved" },
  { label: "Paid", value: "paid" },
  { label: "Rejected", value: "rejected" }
];

const METHOD_OPTIONS = [
  { label: "Bank Transfer", value: "bank_transfer" },
  { label: "Stripe Connect", value: "stripe_connect" },
  { label: "Easypaisa", value: "easypaisa" },
  { label: "JazzCash", value: "jazzcash" }
];

const STATUS_TONE: Record<AdminPayoutRequest["status"], "success" | "warning" | "error" | "info"> = {
  pending: "warning",
  approved: "info",
  paid: "success",
  rejected: "error"
};

export default function PayoutProcessingQueuePage() {
  const [statusFilter, setStatusFilter] = useState("pending");
  const [methodFilter, setMethodFilter] = useState("");
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState<Record<string, boolean>>({});
  const [rejectTarget, setRejectTarget] = useState<AdminPayoutRequest | null>(null);

  const { data: payouts, isLoading } = useAdminPayoutQueue({
    status: statusFilter || undefined,
    method: methodFilter || undefined,
    search: search || undefined
  });
  const processPayout = useProcessPayoutRequest();
  const batchProcess = useBatchProcessPayoutRequests();

  const selectedIds = useMemo(
    () => Object.entries(selected).filter(([, v]) => v).map(([id]) => id),
    [selected]
  );

  const pendingList = useMemo(() => (payouts ?? []).filter((p) => p.status === "pending"), [payouts]);

  const totals = useMemo(() => {
    const list = payouts ?? [];
    return {
      pendingAmount: list.filter((p) => p.status === "pending").reduce((sum, p) => sum + p.amount, 0),
      pendingCount: list.filter((p) => p.status === "pending").length,
      paidThisBatch: list.filter((p) => p.status === "paid").length,
      totalCount: list.length
    };
  }, [payouts]);

  const toggleOne = (id: string) => setSelected((prev) => ({ ...prev, [id]: !prev[id] }));

  const toggleAllPending = () => {
    const allSelected = pendingList.length > 0 && pendingList.every((p) => selected[p.id]);
    const next: Record<string, boolean> = { ...selected };
    pendingList.forEach((p) => {
      next[p.id] = !allSelected;
    });
    setSelected(next);
  };

  const handleBatchApprove = () => {
    if (selectedIds.length === 0) return;
    batchProcess.mutate(
      { ids: selectedIds, decision: "approved" },
      {
        onSuccess: () => toast.success(`Approved ${selectedIds.length} payout${selectedIds.length > 1 ? "s" : ""}`),
        onError: () => toast.error("Could not approve the selected payouts")
      }
    );
    setSelected({});
  };

  const handleApproveSingle = (payout: AdminPayoutRequest) => {
    processPayout.mutate(
      { id: payout.id, decision: "approved" },
      {
        onSuccess: () => toast.success(`Approved payout for ${payout.instructorName}`),
        onError: () => toast.error("Could not approve this payout")
      }
    );
  };

  const handleMarkPaid = (payout: AdminPayoutRequest) => {
    processPayout.mutate(
      { id: payout.id, decision: "paid" },
      {
        onSuccess: () => toast.success(`Marked payout for ${payout.instructorName} as paid`),
        onError: () => toast.error("Could not update this payout")
      }
    );
  };

  const handleRejectSubmit = (reason: string) => {
    if (!rejectTarget) return;
    processPayout.mutate(
      { id: rejectTarget.id, decision: "rejected", reason },
      {
        onSuccess: () => toast.success(`Rejected payout for ${rejectTarget.instructorName}`),
        onError: () => toast.error("Could not reject this payout")
      }
    );
    setRejectTarget(null);
  };

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Banknote size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Payout Processing Queue</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">
              Review and process instructor payout requests against the transaction ledger.
            </p>
          </div>
        </div>
        {selectedIds.length > 0 && (
          <Button size="sm" onClick={handleBatchApprove} disabled={batchProcess.isPending}>
            <Layers size={14} strokeWidth={1.75} />
            {batchProcess.isPending ? "Processing..." : `Approve ${selectedIds.length} selected`}
          </Button>
        )}
      </div>

      {isLoading ? (
        <div className="mb-10 flex justify-center py-6">
          <LoadingSpinner size={64} label="Loading payout requests..." />
        </div>
      ) : (
        <>
          <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <Card className="p-5">
              <p className="text-[12px] text-ink-soft">Pending amount</p>
              <p className="mt-1 font-mono text-[22px] font-semibold text-ink">
                {formatCurrency(totals.pendingAmount, "USD")}
              </p>
            </Card>
            <Card className="p-5">
              <p className="text-[12px] text-ink-soft">Pending requests</p>
              <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{totals.pendingCount}</p>
            </Card>
            <Card className="p-5">
              <p className="text-[12px] text-ink-soft">Paid this batch</p>
              <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{totals.paidThisBatch}</p>
            </Card>
            <Card className="p-5">
              <p className="text-[12px] text-ink-soft">Total requests</p>
              <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{totals.totalCount}</p>
            </Card>
          </div>

          <div className="mb-5 flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by instructor or payout ID"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All methods" options={METHOD_OPTIONS} value={methodFilter} onChange={(e) => setMethodFilter(e.target.value)} />
            </div>
            {pendingList.length > 0 && (
              <button
                type="button"
                onClick={toggleAllPending}
                className="whitespace-nowrap text-[12.5px] font-medium text-ink underline decoration-line-strong underline-offset-2 hover:decoration-ink"
              >
                {pendingList.every((p) => selected[p.id]) ? "Deselect all pending" : "Select all pending"}
              </button>
            )}
          </div>

          {!payouts || payouts.length === 0 ? (
            <EmptyState icon={<Banknote size={22} strokeWidth={1.75} />} title="No payout requests found" description="Try a different filter." />
          ) : (
            <div className="flex flex-col gap-3">
              {payouts.map((payout) => (
                <Card key={payout.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
                  <div className="flex items-start gap-3">
                    {payout.status === "pending" && (
                      <input
                        type="checkbox"
                        checked={Boolean(selected[payout.id])}
                        onChange={() => toggleOne(payout.id)}
                        className="mt-1 h-4 w-4 shrink-0 accent-ink"
                      />
                    )}
                    <div>
                      <div className="flex flex-wrap items-center gap-2.5">
                        <p className="text-[14px] font-semibold text-ink">{payout.instructorName}</p>
                        <StatusPill label={payout.status} tone={STATUS_TONE[payout.status]} />
                      </div>
                      <p className="mt-1 text-[12.5px] text-ink-soft">
                        {payout.id} - requested {formatDate(payout.requestedAt)} - via {payout.method.replace("_", " ")}
                      </p>
                      {payout.status === "rejected" && payout.rejectionReason && (
                        <p className="mt-1 text-[12px] text-error">Reason: {payout.rejectionReason}</p>
                      )}
                    </div>
                  </div>

                  <div className="flex shrink-0 items-center gap-4">
                    <span className="font-mono text-[16px] font-semibold text-ink">
                      {formatCurrency(payout.amount, payout.currency)}
                    </span>
                    {payout.status === "pending" && (
                      <div className="flex gap-2">
                        <Button size="sm" variant="secondary" onClick={() => setRejectTarget(payout)}>
                          <XCircle size={14} strokeWidth={1.75} /> Reject
                        </Button>
                        <Button size="sm" onClick={() => handleApproveSingle(payout)} disabled={processPayout.isPending}>
                          <CheckCircle2 size={14} strokeWidth={1.75} /> Approve
                        </Button>
                      </div>
                    )}
                    {payout.status === "approved" && (
                      <Button size="sm" onClick={() => handleMarkPaid(payout)} disabled={processPayout.isPending}>
                        Mark as paid
                      </Button>
                    )}
                  </div>
                </Card>
              ))}
            </div>
          )}
        </>
      )}

      <PayoutRejectModal target={rejectTarget} onClose={() => setRejectTarget(null)} onSubmit={handleRejectSubmit} pending={processPayout.isPending} />
    </main>
  );
}

function PayoutRejectModal({
  target,
  onClose,
  onSubmit,
  pending
}: {
  target: AdminPayoutRequest | null;
  onClose: () => void;
  onSubmit: (reason: string) => void;
  pending: boolean;
}) {
  const [reason, setReason] = useState("");

  return (
    <Modal
      open={Boolean(target)}
      onClose={() => {
        setReason("");
        onClose();
      }}
      title="Reject payout request"
      footer={
        <>
          <Button variant="ghost" onClick={onClose}>
            Cancel
          </Button>
          <Button
            variant="danger"
            disabled={!reason.trim() || pending}
            onClick={() => {
              onSubmit(reason.trim());
              setReason("");
            }}
          >
            {pending ? "Sending..." : "Reject payout"}
          </Button>
        </>
      }
    >
      <p className="mb-4 text-[13px] text-ink-soft">
        Rejecting the payout request from <span className="font-semibold text-ink">{target?.instructorName}</span>.
        The instructor will be notified with this reason and funds remain in their balance.
      </p>
      <textarea
        placeholder="Explain why this payout is being rejected..."
        rows={4}
        value={reason}
        onChange={(e) => setReason(e.target.value)}
        className="w-full rounded-control border border-line bg-card p-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
      />
    </Modal>
  );
}
'@

Write-FileUtf8NoBom -Path $payoutsPagePath -Content $payoutsPageContent

# ==========================================================================
# 2) useAdminUserDetail.ts - user detail, status, role hooks
# ==========================================================================
$userDetailHookPath = Join-Path $apiClientSrc "hooks\useAdminUserDetail.ts"

$userDetailHookContent = @'
"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

type UserDetailRole = "learner" | "instructor" | "corporate" | "admin";
type UserDetailStatus = "active" | "suspended" | "banned" | "pending";

type UserActivityLogEntry = {
  id: string;
  description: string;
  createdAt: string;
};

type UserDetailRecord = {
  id: string;
  fullName: string;
  email: string;
  avatarUrl?: string;
  role: UserDetailRole;
  status: UserDetailStatus;
  location?: string;
  joinedAt: string;
  lastActiveAt: string;
  activityLog: UserActivityLogEntry[];
};

const MOCK_USER_DETAILS: Record<string, UserDetailRecord> = {
  usr_1001: {
    id: "usr_1001",
    fullName: "Hassan Raza",
    email: "hassan.raza@example.com",
    role: "instructor",
    status: "active",
    location: "Lahore, Pakistan",
    joinedAt: "2026-02-14T00:00:00Z",
    lastActiveAt: "2026-08-07T09:30:00Z",
    activityLog: [
      { id: "act_1", description: "Published course \"AI Automation with n8n\"", createdAt: "2026-07-30T10:00:00Z" },
      { id: "act_2", description: "Requested payout PAYOUT-2026-0913", createdAt: "2026-08-05T10:12:00Z" },
      { id: "act_3", description: "Responded to a learner review", createdAt: "2026-08-01T14:20:00Z" }
    ]
  }
};

function buildFallbackUser(id: string): UserDetailRecord {
  return {
    id,
    fullName: "Demo User",
    email: `${id}@example.com`,
    role: "learner",
    status: "active",
    location: "Unknown",
    joinedAt: "2026-01-01T00:00:00Z",
    lastActiveAt: new Date().toISOString(),
    activityLog: []
  };
}

let userDetailStore: Record<string, UserDetailRecord> = { ...MOCK_USER_DETAILS };

async function fetchUserDetail(id: string): Promise<UserDetailRecord> {
  await new Promise((r) => setTimeout(r, 350));
  if (!userDetailStore[id]) {
    userDetailStore[id] = buildFallbackUser(id);
  }
  return userDetailStore[id];
}

export function useAdminUserDetail(id: string) {
  return useQuery({
    queryKey: ["admin", "user-detail", id],
    queryFn: () => fetchUserDetail(id),
    enabled: Boolean(id)
  });
}

export function useUpdateUserStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; status: UserDetailStatus }) => {
      await new Promise((r) => setTimeout(r, 300));
      const current = userDetailStore[input.id] ?? buildFallbackUser(input.id);
      const updated: UserDetailRecord = {
        ...current,
        status: input.status,
        activityLog: [
          {
            id: `act_${Date.now()}`,
            description: `Status changed to "${input.status}"`,
            createdAt: new Date().toISOString()
          },
          ...current.activityLog
        ]
      };
      userDetailStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "user-detail", data.id] });
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
    }
  });
}

export function useUpdateUserRole() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; role: UserDetailRole }) => {
      await new Promise((r) => setTimeout(r, 300));
      const current = userDetailStore[input.id] ?? buildFallbackUser(input.id);
      const updated: UserDetailRecord = {
        ...current,
        role: input.role,
        activityLog: [
          {
            id: `act_${Date.now()}`,
            description: `Role changed to "${input.role}"`,
            createdAt: new Date().toISOString()
          },
          ...current.activityLog
        ]
      };
      userDetailStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "user-detail", data.id] });
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
    }
  });
}
'@

Write-FileUtf8NoBom -Path $userDetailHookPath -Content $userDetailHookContent

# ==========================================================================
# 3) useAdminTicketDetail.ts - pre-emptive fix for the ticket detail page
# ==========================================================================
$ticketDetailHookPath = Join-Path $apiClientSrc "hooks\useAdminTicketDetail.ts"

$ticketDetailHookContent = @'
"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

type TicketDetailStatus = "open" | "in_progress" | "resolved" | "closed";
type TicketDetailPriority = "low" | "medium" | "high" | "urgent";
type ThreadAuthorType = "requester" | "staff" | "internal_note";

type TicketThreadEntry = {
  id: string;
  authorType: ThreadAuthorType;
  authorName: string;
  message: string;
  createdAt: string;
};

type TicketDetailRecord = {
  id: string;
  subject: string;
  requesterName: string;
  category: string;
  status: TicketDetailStatus;
  priority: TicketDetailPriority;
  assignedTo?: string;
  slaDueAt: string;
  createdAt: string;
  thread: TicketThreadEntry[];
};

type CannedResponse = { title: string; body: string };

const CANNED_RESPONSES: CannedResponse[] = [
  { title: "Ack - looking into it", body: "Thanks for reaching out - we're looking into this now and will update you shortly." },
  { title: "Resolved - closing", body: "This issue has been resolved on our end. Let us know if you run into it again." },
  { title: "Need more info", body: "Could you share a bit more detail (screenshots, steps to reproduce) so we can help faster?" }
];

const MOCK_TICKETS: Record<string, TicketDetailRecord> = {};

function buildFallbackTicket(id: string): TicketDetailRecord {
  return {
    id,
    subject: "Support request",
    requesterName: "Demo Requester",
    category: "General",
    status: "open",
    priority: "medium",
    slaDueAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    createdAt: new Date().toISOString(),
    thread: []
  };
}

let ticketStore: Record<string, TicketDetailRecord> = { ...MOCK_TICKETS };

async function fetchTicketDetail(id: string): Promise<TicketDetailRecord> {
  await new Promise((r) => setTimeout(r, 300));
  if (!ticketStore[id]) {
    ticketStore[id] = buildFallbackTicket(id);
  }
  return ticketStore[id];
}

export function useAdminTicketDetail(id: string) {
  return useQuery({
    queryKey: ["admin", "ticket-detail", id],
    queryFn: () => fetchTicketDetail(id),
    enabled: Boolean(id)
  });
}

export function useAdminCannedResponses() {
  return useQuery({
    queryKey: ["admin", "canned-responses"],
    queryFn: async () => {
      await new Promise((r) => setTimeout(r, 100));
      return CANNED_RESPONSES;
    }
  });
}

export function useReplyToTicket() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; message: string }) => {
      await new Promise((r) => setTimeout(r, 300));
      const current = ticketStore[input.id] ?? buildFallbackTicket(input.id);
      const updated: TicketDetailRecord = {
        ...current,
        status: current.status === "open" ? "in_progress" : current.status,
        thread: [
          ...current.thread,
          { id: `msg_${Date.now()}`, authorType: "staff", authorName: "Admin", message: input.message, createdAt: new Date().toISOString() }
        ]
      };
      ticketStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "ticket-detail", data.id] });
      queryClient.invalidateQueries({ queryKey: ["admin", "tickets"] });
    }
  });
}

export function useAddInternalNote() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; note: string }) => {
      await new Promise((r) => setTimeout(r, 300));
      const current = ticketStore[input.id] ?? buildFallbackTicket(input.id);
      const updated: TicketDetailRecord = {
        ...current,
        thread: [
          ...current.thread,
          { id: `note_${Date.now()}`, authorType: "internal_note", authorName: "Admin", message: input.note, createdAt: new Date().toISOString() }
        ]
      };
      ticketStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "ticket-detail", data.id] });
    }
  });
}

export function useResolveTicket() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; status: TicketDetailStatus }) => {
      await new Promise((r) => setTimeout(r, 250));
      const current = ticketStore[input.id] ?? buildFallbackTicket(input.id);
      const updated: TicketDetailRecord = { ...current, status: input.status };
      ticketStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "ticket-detail", data.id] });
      queryClient.invalidateQueries({ queryKey: ["admin", "tickets"] });
    }
  });
}
'@

Write-FileUtf8NoBom -Path $ticketDetailHookPath -Content $ticketDetailHookContent

# ==========================================================================
# Append index.ts exports (idempotent)
# ==========================================================================
$indexPath = Join-Path $apiClientSrc "index.ts"
Add-IndexExport -IndexPath $indexPath -ExportLine 'export * from "./hooks/useAdminUserDetail";'
Add-IndexExport -IndexPath $indexPath -ExportLine 'export * from "./hooks/useAdminTicketDetail";'

# ==========================================================================
# 4) Cursor pointer fix for clickable table rows
# ==========================================================================

# 4a. Global CSS rule (safe: scoped to a wrapper class we control)
$cssPath = Join-Path $adminApp "globals.css"
if (Test-Path $cssPath) {
    $cssContent = Get-Content -Raw -Path $cssPath
    $marker = "/* admin-clickable-table rules"
    if ($cssContent -notmatch [regex]::Escape($marker)) {
        $cssAddition = @"


/* admin-clickable-table rules - added by fix-userdetail-hooks-and-cursor.ps1 */
.admin-clickable-table table tbody tr {
  cursor: pointer;
  transition: background-color 120ms ease-out;
}
.admin-clickable-table table tbody tr:hover {
  background-color: var(--color-paper-dim);
}
"@
        $newCss = $cssContent.TrimEnd() + "`r`n" + $cssAddition
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($cssPath, $newCss, $utf8NoBom)
        Write-Host "  Appended CSS rules to: $cssPath" -ForegroundColor Green
    } else {
        Write-Host "  CSS rules already present - skipped." -ForegroundColor Yellow
    }
} else {
    Write-Host "  WARNING: $cssPath not found - add the CSS rules manually." -ForegroundColor Yellow
}

# 4b. Wrap <DataTable ... /> with the wrapper class in users/page.tsx
$usersPagePath = Join-Path $adminConsole "users\page.tsx"
if (Test-Path $usersPagePath) {
    $usersContent = Get-Content -Raw -Path $usersPagePath
    if ($usersContent -match "onRowClick=" -and $usersContent -notmatch "admin-clickable-table") {
        $usersContent = $usersContent -replace `
            '(\s*)<DataTable\s', '$1<div className="admin-clickable-table"><DataTable ' `
        # Close the wrapping div right after the DataTable's closing "/>" that follows onRowClick usage.
        # Simplest reliable approach: replace the final "/>\n    </main>" pattern to close div before </main>.
        $usersContent = $usersContent -replace '(\s*)\/>\s*\n(\s*)<\/main>', "`$1/></div>`$2</main>"
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($usersPagePath, $usersContent, $utf8NoBom)
        Write-Host "  Wrapped DataTable with clickable-cursor class in: $usersPagePath" -ForegroundColor Green
    } else {
        Write-Host "  users/page.tsx already wrapped or no onRowClick found - skipped." -ForegroundColor Yellow
    }
} else {
    Write-Host "  WARNING: $usersPagePath not found." -ForegroundColor Yellow
}

# 4c. Same wrap for support/tickets/page.tsx
$ticketsPagePath = Join-Path $adminConsole "support\tickets\page.tsx"
if (Test-Path $ticketsPagePath) {
    $ticketsContent = Get-Content -Raw -Path $ticketsPagePath
    if ($ticketsContent -match "onRowClick=" -and $ticketsContent -notmatch "admin-clickable-table") {
        $ticketsContent = $ticketsContent -replace `
            '(\s*)<DataTable\s', '$1<div className="admin-clickable-table"><DataTable '
        $ticketsContent = $ticketsContent -replace '(\s*)\/>\s*\n(\s*)<\/main>', "`$1/></div>`$2</main>"
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($ticketsPagePath, $ticketsContent, $utf8NoBom)
        Write-Host "  Wrapped DataTable with clickable-cursor class in: $ticketsPagePath" -ForegroundColor Green
    } else {
        Write-Host "  support/tickets/page.tsx already wrapped or no onRowClick found - skipped." -ForegroundColor Yellow
    }
} else {
    Write-Host "  WARNING: $ticketsPagePath not found." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Done. Restart 'pnpm dev' if it doesn't hot-reload cleanly." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Test:"
Write-Host "  http://localhost:3001/finance/payouts       (renamed hooks, no more collision)"
Write-Host "  http://localhost:3001/users/usr_1001          (user detail now loads + actions work)"
Write-Host "  http://localhost:3001/users                   (row hover shows pointer cursor)"
Write-Host "  http://localhost:3001/support/tickets          (row hover shows pointer cursor)"
Write-Host "  http://localhost:3001/support/tickets/TCK-1     (ticket detail hooks pre-added)"
Write-Host ""