<#
.SYNOPSIS
  Adds the Instructor Payouts module (Payout Requests + Payout Methods) to SAI2.
  - New mock hook: packages/api-client/src/hooks/useInstructorPayouts.ts
  - New page: apps/web/app/(instructor)/instructor/payouts/page.tsx
  - New page: apps/web/app/(instructor)/instructor/payouts/methods/page.tsx
  - Appends the new hook export to packages/api-client/src/index.ts

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
Write-Host "== SAI2: Instructor Payouts module ==" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# 1) Mock API hook
# ---------------------------------------------------------------------------
$hookContent = @'
"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

// NOTE: demo-only, in-memory. Replace with real Instructor Payouts API (Doc 3)
// once the backend is available. Follows the same delay()/module-state pattern
// used across the other api-client hooks (see useAdminFinance.ts, useAuth.ts).

export type PayoutMethodType = "bank_transfer" | "easypaisa" | "jazzcash" | "stripe_connect";

export type InstructorPayoutMethod = {
  id: string;
  type: PayoutMethodType;
  label: string;
  accountName: string;
  accountNumber: string; // masked for display
  isDefault: boolean;
  addedAt: string;
};

export type InstructorPayoutStatus = "pending" | "processing" | "paid" | "rejected";

export type InstructorPayoutRequest = {
  id: string;
  amount: number;
  currency: string;
  methodId: string;
  methodLabel: string;
  status: InstructorPayoutStatus;
  requestedAt: string;
  processedAt?: string;
  note?: string;
};

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

function daysAgoIso(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

function genId(prefix: string) {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

// ---------------------------------------------------------------------------
// Seed / module-level state
// ---------------------------------------------------------------------------

let METHODS_STATE: InstructorPayoutMethod[] = [
  {
    id: "pm_1",
    type: "bank_transfer",
    label: "Meezan Bank",
    accountName: "Ayesha Khan",
    accountNumber: "•••• •••• 4821",
    isDefault: true,
    addedAt: daysAgoIso(120)
  },
  {
    id: "pm_2",
    type: "easypaisa",
    label: "Easypaisa",
    accountName: "Ayesha Khan",
    accountNumber: "0301 •••• 219",
    isDefault: false,
    addedAt: daysAgoIso(60)
  }
];

let REQUESTS_STATE: InstructorPayoutRequest[] = [
  {
    id: "po_9001",
    amount: 420,
    currency: "USD",
    methodId: "pm_1",
    methodLabel: "Meezan Bank •••• 4821",
    status: "pending",
    requestedAt: daysAgoIso(1)
  },
  {
    id: "po_9002",
    amount: 610,
    currency: "USD",
    methodId: "pm_1",
    methodLabel: "Meezan Bank •••• 4821",
    status: "paid",
    requestedAt: daysAgoIso(20),
    processedAt: daysAgoIso(17)
  },
  {
    id: "po_9003",
    amount: 275,
    currency: "USD",
    methodId: "pm_2",
    methodLabel: "Easypaisa 0301 •••• 219",
    status: "paid",
    requestedAt: daysAgoIso(45),
    processedAt: daysAgoIso(42)
  },
  {
    id: "po_9004",
    amount: 150,
    currency: "USD",
    methodId: "pm_2",
    methodLabel: "Easypaisa 0301 •••• 219",
    status: "rejected",
    requestedAt: daysAgoIso(60),
    processedAt: daysAgoIso(58),
    note: "Account name mismatch - please update payout method details."
  }
];

// Demo-only balance figures, mirrors the KPI cards on /instructor/earnings.
const AVAILABLE_BALANCE = 1240;
const MIN_PAYOUT_AMOUNT = 20;

export const instructorPayoutKeys = {
  methods: ["instructor", "payouts", "methods"] as const,
  requests: (filters?: Record<string, unknown>) => ["instructor", "payouts", "requests", filters] as const,
  balance: ["instructor", "payouts", "balance"] as const
};

// ---------------------------------------------------------------------------
// Balance
// ---------------------------------------------------------------------------

export function useInstructorPayoutBalance() {
  return useQuery({
    queryKey: instructorPayoutKeys.balance,
    queryFn: async () => {
      const pendingTotal = REQUESTS_STATE.filter((r) => r.status === "pending" || r.status === "processing").reduce(
        (sum, r) => sum + r.amount,
        0
      );
      return delay({
        availableBalance: AVAILABLE_BALANCE,
        pendingTotal,
        minPayoutAmount: MIN_PAYOUT_AMOUNT,
        currency: "USD"
      });
    }
  });
}

// ---------------------------------------------------------------------------
// Payout methods
// ---------------------------------------------------------------------------

export function useInstructorPayoutMethods() {
  return useQuery({
    queryKey: instructorPayoutKeys.methods,
    queryFn: async () => delay([...METHODS_STATE])
  });
}

export function useAddPayoutMethod() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: {
      type: PayoutMethodType;
      label: string;
      accountName: string;
      accountNumber: string;
    }) => {
      const masked =
        input.accountNumber.length > 4
          ? `•••• ${input.accountNumber.slice(-4)}`
          : input.accountNumber;
      const created: InstructorPayoutMethod = {
        id: genId("pm"),
        type: input.type,
        label: input.label,
        accountName: input.accountName,
        accountNumber: masked,
        isDefault: METHODS_STATE.length === 0,
        addedAt: new Date().toISOString()
      };
      METHODS_STATE = [...METHODS_STATE, created];
      return delay(created, 400);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: instructorPayoutKeys.methods });
    }
  });
}

export function useSetDefaultPayoutMethod() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      METHODS_STATE = METHODS_STATE.map((m) => ({ ...m, isDefault: m.id === id }));
      return delay({ id }, 250);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: instructorPayoutKeys.methods });
    }
  });
}

export function useRemovePayoutMethod() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const wasDefault = METHODS_STATE.find((m) => m.id === id)?.isDefault;
      METHODS_STATE = METHODS_STATE.filter((m) => m.id !== id);
      if (wasDefault && METHODS_STATE.length > 0) {
        METHODS_STATE = METHODS_STATE.map((m, i) => ({ ...m, isDefault: i === 0 }));
      }
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: instructorPayoutKeys.methods });
    }
  });
}

// ---------------------------------------------------------------------------
// Payout requests
// ---------------------------------------------------------------------------

export type InstructorPayoutFilters = {
  status?: string;
};

export function useInstructorPayoutRequests(filters: InstructorPayoutFilters = {}) {
  return useQuery({
    queryKey: instructorPayoutKeys.requests(filters),
    queryFn: async () => {
      let items = [...REQUESTS_STATE];
      if (filters.status) items = items.filter((r) => r.status === filters.status);
      return delay(items.sort((a, b) => new Date(b.requestedAt).getTime() - new Date(a.requestedAt).getTime()));
    }
  });
}

export function useRequestPayout() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { amount: number; methodId: string }) => {
      const method = METHODS_STATE.find((m) => m.id === input.methodId);
      if (!method) throw new Error("Select a payout method");
      if (input.amount < MIN_PAYOUT_AMOUNT) throw new Error(`Minimum payout is $${MIN_PAYOUT_AMOUNT}`);
      if (input.amount > AVAILABLE_BALANCE) throw new Error("Amount exceeds available balance");

      const created: InstructorPayoutRequest = {
        id: genId("po"),
        amount: input.amount,
        currency: "USD",
        methodId: method.id,
        methodLabel: `${method.label} ${method.accountNumber}`,
        status: "pending",
        requestedAt: new Date().toISOString()
      };
      REQUESTS_STATE = [created, ...REQUESTS_STATE];
      return delay(created, 500);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["instructor", "payouts"] });
    }
  });
}

'@
Write-FileUtf8NoBom -RelativePath "packages\api-client\src\hooks\useInstructorPayouts.ts" -Content $hookContent

# ---------------------------------------------------------------------------
# 2) Payout Requests page
# ---------------------------------------------------------------------------
$payoutsPageContent = @'
"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { Wallet, Clock, CheckCircle2, XCircle, Loader2, Settings } from "lucide-react";
import {
  useInstructorPayoutBalance,
  useInstructorPayoutMethods,
  useInstructorPayoutRequests,
  useRequestPayout,
  type InstructorPayoutStatus
} from "@saachi/api-client";
import { Button, Input, Select, Badge, KpiCard, EmptyState, Modal } from "@saachi/ui";

const STATUS_META: Record<InstructorPayoutStatus, { label: string; variant?: "gold" | "success" | "error"; icon: typeof Clock }> = {
  pending: { label: "Pending", variant: "gold", icon: Clock },
  processing: { label: "Processing", variant: "gold", icon: Loader2 },
  paid: { label: "Paid", variant: "success", icon: CheckCircle2 },
  rejected: { label: "Rejected", variant: "error", icon: XCircle }
};

const STATUS_OPTIONS = [
  { label: "All requests", value: "all" },
  { label: "Pending", value: "pending" },
  { label: "Processing", value: "processing" },
  { label: "Paid", value: "paid" },
  { label: "Rejected", value: "rejected" }
];

export default function InstructorPayoutsPage() {
  const [status, setStatus] = useState("all");
  const [modalOpen, setModalOpen] = useState(false);

  const { data: balance, isLoading: balanceLoading } = useInstructorPayoutBalance();
  const { data: methods } = useInstructorPayoutMethods();
  const { data: requests, isLoading: requestsLoading } = useInstructorPayoutRequests({
    status: status === "all" ? undefined : status
  });

  const hasMethod = (methods?.length ?? 0) > 0;

  return (
    <div>
      <div className="mb-8 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Payout Requests</h1>
          <p className="text-[14px] text-ink-soft">Request a payout and track the status of past requests.</p>
        </div>
        <div className="flex items-center gap-2">
          <Link href="/instructor/payouts/methods">
            <Button variant="secondary">
              <Settings size={14} className="mr-1.5" />
              Payout methods
            </Button>
          </Link>
          <Button onClick={() => setModalOpen(true)} disabled={!hasMethod}>
            <Wallet size={14} className="mr-1.5" />
            Request payout
          </Button>
        </div>
      </div>

      {!hasMethod && (
        <div className="mb-6 rounded-card border border-gold-dark/30 bg-gold-tint px-4 py-3 text-[13.5px] text-ink">
          You haven&apos;t added a payout method yet.{" "}
          <Link href="/instructor/payouts/methods" className="font-semibold text-gold-dark hover:underline">
            Add one now
          </Link>{" "}
          to request a payout.
        </div>
      )}

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <KpiCard
          label="Available balance"
          value={balanceLoading ? "…" : `$${(balance?.availableBalance ?? 0).toLocaleString()}`}
          icon={Wallet}
        />
        <KpiCard
          label="Pending requests"
          value={balanceLoading ? "…" : `$${(balance?.pendingTotal ?? 0).toLocaleString()}`}
          icon={Clock}
        />
        <KpiCard label="Minimum payout" value={`$${balance?.minPayoutAmount ?? 20}`} icon={CheckCircle2} />
      </div>

      <div className="mb-6 flex items-center justify-between">
        <h2 className="font-display text-[18px] font-semibold text-ink">Request history</h2>
        <Select options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} className="w-52" />
      </div>

      {requestsLoading ? (
        <div className="rounded-card border border-line bg-card p-10 text-center text-[13px] text-ink-soft">
          Loading payout requests...
        </div>
      ) : !requests || requests.length === 0 ? (
        <EmptyState
          title="No payout requests"
          description="Once you request a payout, it will show up here with its status."
        />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Request</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Method</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Amount</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Requested</th>
              </tr>
            </thead>
            <tbody>
              {requests.map((r) => {
                const meta = STATUS_META[r.status];
                const Icon = meta.icon;
                return (
                  <tr key={r.id} className="border-b border-line last:border-0">
                    <td className="px-4 py-3.5 font-medium text-ink">{r.id.toUpperCase()}</td>
                    <td className="px-4 py-3.5 text-ink-soft">{r.methodLabel}</td>
                    <td className="px-4 py-3.5 font-mono text-ink">
                      {new Intl.NumberFormat("en-US", { style: "currency", currency: r.currency }).format(r.amount)}
                    </td>
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-1.5">
                        {meta.variant ? <Badge variant={meta.variant}>{meta.label}</Badge> : <Badge>{meta.label}</Badge>}
                      </div>
                      {r.status === "rejected" && r.note && (
                        <p className="mt-1 max-w-xs text-[11.5px] text-ink-soft">{r.note}</p>
                      )}
                    </td>
                    <td className="px-4 py-3.5 text-ink-soft">
                      {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(r.requestedAt))}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}

      <RequestPayoutModal open={modalOpen} onClose={() => setModalOpen(false)} />
    </div>
  );
}

function RequestPayoutModal({ open, onClose }: { open: boolean; onClose: () => void }) {
  const { data: methods } = useInstructorPayoutMethods();
  const { data: balance } = useInstructorPayoutBalance();
  const requestPayout = useRequestPayout();

  const [amount, setAmount] = useState("");
  const [methodId, setMethodId] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState(false);

  const methodOptions = useMemo(
    () => (methods ?? []).map((m) => ({ label: `${m.label} ${m.accountNumber}${m.isDefault ? " (default)" : ""}`, value: m.id })),
    [methods]
  );

  const effectiveMethodId = methodId || methods?.find((m) => m.isDefault)?.id || methods?.[0]?.id || "";

  function handleClose() {
    setAmount("");
    setError(null);
    setSuccess(false);
    onClose();
  }

  function handleSubmit() {
    setError(null);
    const numeric = Number(amount);
    if (!numeric || numeric <= 0) {
      setError("Enter a valid amount");
      return;
    }
    if (!effectiveMethodId) {
      setError("Select a payout method");
      return;
    }
    requestPayout.mutate(
      { amount: numeric, methodId: effectiveMethodId },
      {
        onSuccess: () => setSuccess(true),
        onError: (err) => setError(err instanceof Error ? err.message : "Something went wrong")
      }
    );
  }

  return (
    <Modal open={open} onClose={handleClose} title={success ? "Payout requested" : "Request a payout"}>
      {success ? (
        <div className="flex flex-col gap-4">
          <p className="text-[14px] text-ink-soft">
            Your payout request for <span className="font-semibold text-ink">${amount}</span> has been submitted and is
            now pending review. You can track its status on this page.
          </p>
          <Button onClick={handleClose} className="self-start">
            Done
          </Button>
        </div>
      ) : (
        <div className="flex flex-col gap-4">
          <Input
            label={`Amount (available: $${balance?.availableBalance ?? 0})`}
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="0.00"
          />
          <Select
            label="Payout method"
            options={methodOptions}
            value={effectiveMethodId}
            onChange={(e) => setMethodId(e.target.value)}
            placeholder="Select a method"
          />
          {error && <p className="text-[13px] text-error">{error}</p>}
          <Button onClick={handleSubmit} loading={requestPayout.isPending} className="self-start">
            Submit request
          </Button>
        </div>
      )}
    </Modal>
  );
}

'@
Write-FileUtf8NoBom -RelativePath "apps\web\app\(instructor)\instructor\payouts\page.tsx" -Content $payoutsPageContent

# ---------------------------------------------------------------------------
# 3) Payout Methods page
# ---------------------------------------------------------------------------
$methodsPageContent = @'
"use client";

import { useState, type FormEvent } from "react";
import Link from "next/link";
import { ArrowLeft, Landmark, Smartphone, CreditCard, Star, Trash2, Plus } from "lucide-react";
import {
  useInstructorPayoutMethods,
  useAddPayoutMethod,
  useSetDefaultPayoutMethod,
  useRemovePayoutMethod,
  type PayoutMethodType
} from "@saachi/api-client";
import { Button, Input, Select, EmptyState, Badge } from "@saachi/ui";

const METHOD_TYPE_OPTIONS: { label: string; value: PayoutMethodType }[] = [
  { label: "Bank transfer", value: "bank_transfer" },
  { label: "Easypaisa", value: "easypaisa" },
  { label: "JazzCash", value: "jazzcash" },
  { label: "Stripe Connect", value: "stripe_connect" }
];

const METHOD_ICON: Record<PayoutMethodType, typeof Landmark> = {
  bank_transfer: Landmark,
  easypaisa: Smartphone,
  jazzcash: Smartphone,
  stripe_connect: CreditCard
};

export default function InstructorPayoutMethodsPage() {
  const { data: methods, isLoading } = useInstructorPayoutMethods();
  const setDefault = useSetDefaultPayoutMethod();
  const removeMethod = useRemovePayoutMethod();

  const [formOpen, setFormOpen] = useState(false);

  return (
    <div className="mx-auto max-w-2xl">
      <Link href="/instructor/payouts" className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink">
        <ArrowLeft size={14} />
        Back to payouts
      </Link>

      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Payout Methods</h1>
          <p className="text-[14px] text-ink-soft">Manage where your earnings are sent.</p>
        </div>
        {!formOpen && (
          <Button onClick={() => setFormOpen(true)}>
            <Plus size={14} className="mr-1.5" />
            Add method
          </Button>
        )}
      </div>

      {formOpen && <AddMethodForm onDone={() => setFormOpen(false)} />}

      {isLoading ? (
        <div className="mt-6 rounded-card border border-line bg-card p-10 text-center text-[13px] text-ink-soft">
          Loading payout methods...
        </div>
      ) : !methods || methods.length === 0 ? (
        <div className="mt-6">
          <EmptyState
            title="No payout methods yet"
            description="Add a bank account or mobile wallet to start requesting payouts."
          />
        </div>
      ) : (
        <div className="mt-6 flex flex-col gap-3">
          {methods.map((m) => {
            const Icon = METHOD_ICON[m.type];
            return (
              <div key={m.id} className="flex items-center gap-4 rounded-card border border-line bg-card p-5">
                <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-gold-tint text-gold-dark">
                  <Icon size={18} />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="flex items-center gap-2">
                    <p className="text-[14px] font-semibold text-ink">{m.label}</p>
                    {m.isDefault && <Badge variant="gold">Default</Badge>}
                  </div>
                  <p className="mt-0.5 text-[13px] text-ink-soft">
                    {m.accountName} · {m.accountNumber}
                  </p>
                </div>
                <div className="flex shrink-0 items-center gap-2">
                  {!m.isDefault && (
                    <Button
                      size="sm"
                      variant="secondary"
                      onClick={() => setDefault.mutate(m.id)}
                      disabled={setDefault.isPending}
                    >
                      <Star size={13} className="mr-1.5" />
                      Make default
                    </Button>
                  )}
                  <button
                    type="button"
                    aria-label="Remove payout method"
                    onClick={() => removeMethod.mutate(m.id)}
                    disabled={removeMethod.isPending}
                    className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft transition-colors hover:bg-error-tint hover:text-error"
                  >
                    <Trash2 size={15} />
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}

function AddMethodForm({ onDone }: { onDone: () => void }) {
  const addMethod = useAddPayoutMethod();

  const [type, setType] = useState<PayoutMethodType>("bank_transfer");
  const [label, setLabel] = useState("");
  const [accountName, setAccountName] = useState("");
  const [accountNumber, setAccountNumber] = useState("");
  const [error, setError] = useState<string | null>(null);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    if (!label.trim() || !accountName.trim() || !accountNumber.trim()) {
      setError("All fields are required");
      return;
    }
    addMethod.mutate(
      { type, label: label.trim(), accountName: accountName.trim(), accountNumber: accountNumber.trim() },
      {
        onSuccess: () => {
          setLabel("");
          setAccountName("");
          setAccountNumber("");
          onDone();
        }
      }
    );
  }

  return (
    <form onSubmit={handleSubmit} className="mb-2 flex flex-col gap-4 rounded-card border border-line bg-card p-6">
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Select
          label="Method type"
          options={METHOD_TYPE_OPTIONS}
          value={type}
          onChange={(e) => setType(e.target.value as PayoutMethodType)}
        />
        <Input
          label="Label"
          value={label}
          onChange={(e) => setLabel(e.target.value)}
          placeholder="e.g. Meezan Bank"
        />
      </div>
      <Input
        label="Account holder name"
        value={accountName}
        onChange={(e) => setAccountName(e.target.value)}
        placeholder="Full name on the account"
      />
      <Input
        label="Account / mobile number"
        value={accountNumber}
        onChange={(e) => setAccountNumber(e.target.value)}
        placeholder="Only the last 4 digits will be shown after saving"
      />
      {error && <p className="text-[13px] text-error">{error}</p>}
      <div className="flex gap-2">
        <Button type="submit" loading={addMethod.isPending}>
          Save method
        </Button>
        <Button type="button" variant="secondary" onClick={onDone}>
          Cancel
        </Button>
      </div>
    </form>
  );
}

'@
Write-FileUtf8NoBom -RelativePath "apps\web\app\(instructor)\instructor\payouts\methods\page.tsx" -Content $methodsPageContent

# ---------------------------------------------------------------------------
# 4) Wire up the new hook export in packages/api-client/src/index.ts
# ---------------------------------------------------------------------------
$indexPath = Join-Path -Path (Get-Location).Path -ChildPath "packages\api-client\src\index.ts"
if (Test-Path -Path $indexPath) {
    $indexContent = Get-Content -Path $indexPath -Raw
    $exportLine = 'export * from "./hooks/useInstructorPayouts";'
    if ($indexContent -notmatch [regex]::Escape($exportLine)) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        $newContent = $indexContent.TrimEnd() + "`r`n" + $exportLine + "`r`n"
        [System.IO.File]::WriteAllText($indexPath, $newContent, $utf8NoBom)
        Write-Host "  Updated: packages\api-client\src\index.ts (added export)"
    } else {
        Write-Host "  Skipped: packages\api-client\src\index.ts (export already present)"
    }
} else {
    Write-Host "  WARNING: packages\api-client\src\index.ts not found - add manually:" -ForegroundColor Yellow
    Write-Host '    export * from "./hooks/useInstructorPayouts";'
}

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Sidebar links for these pages already exist in:"
Write-Host "  apps\web\components\ui\instructor-sidebar-v2.tsx (Finance group -> Payout Requests / Payout Methods)"
Write-Host ""
Write-Host "Next: restart 'npm run dev' inside apps/web if it was already running."
Write-Host ""