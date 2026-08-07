# step14-admin-finance.ps1
# Run from: SAI2 root folder
# Builds: Finance module - Transactions Ledger, Payout Processing Queue,
# Refund Management, Tax / VAT Settings.

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}

function Patch-File {
    param([string]$Path, [string]$OldStr, [string]$NewStr, [string]$Label)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP (file not found): $fullPath" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Path $fullPath -Raw
    if ($content.Contains($OldStr)) {
        $updated = $content.Replace($OldStr, $NewStr)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($fullPath, $updated, $enc)
        Write-Host "  patched ($Label): $fullPath"
    } else {
        Write-Host "  WARNING: pattern for '$Label' not found - skipped." -ForegroundColor Yellow
    }
}

Write-Host "Step 14: Admin Finance (Transactions, Payouts, Refunds, Tax Settings)..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Dummy data - transactions, payouts, refunds, tax rules
# ---------------------------------------------------------------------------
$adminFinanceDummyData = @'
export type TransactionStatus = "completed" | "pending" | "failed" | "refunded";

export type AdminTransaction = {
  id: string;
  courseTitle: string;
  learnerName: string;
  instructorName: string;
  amount: number;
  currency: string;
  commission: number;
  netToInstructor: number;
  gateway: "stripe" | "paypal" | "easypaisa" | "jazzcash" | "bank_transfer";
  status: TransactionStatus;
  createdAt: string;
};

export type PayoutStatus = "pending" | "approved" | "paid" | "rejected";

export type AdminPayout = {
  id: string;
  instructorName: string;
  instructorId: string;
  amount: number;
  currency: string;
  method: "bank_transfer" | "easypaisa" | "jazzcash" | "stripe_connect";
  status: PayoutStatus;
  requestedAt: string;
  processedAt?: string;
};

export type RefundStatus = "pending" | "approved" | "rejected";

export type AdminRefund = {
  id: string;
  transactionId: string;
  courseTitle: string;
  learnerName: string;
  amount: number;
  currency: string;
  reason: string;
  status: RefundStatus;
  requestedAt: string;
};

export type TaxRule = {
  id: string;
  region: string;
  ratePercent: number;
  appliesTo: string;
  active: boolean;
};

function daysAgoIso(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_TRANSACTIONS: AdminTransaction[] = [
  { id: "txn_1001", courseTitle: "Prompt Engineering Fundamentals", learnerName: "Hina Malik", instructorName: "Sana Rizvi", amount: 29, currency: "USD", commission: 8.7, netToInstructor: 20.3, gateway: "stripe", status: "completed", createdAt: daysAgoIso(0) },
  { id: "txn_1002", courseTitle: "AI-Powered Marketing Campaigns", learnerName: "Omar Sheikh", instructorName: "Zara Farooq", amount: 49, currency: "USD", commission: 14.7, netToInstructor: 34.3, gateway: "easypaisa", status: "completed", createdAt: daysAgoIso(0) },
  { id: "txn_1003", courseTitle: "Automate Everything with n8n & AI", learnerName: "Fatima Noor", instructorName: "Ayesha Khan", amount: 39, currency: "USD", commission: 11.7, netToInstructor: 27.3, gateway: "jazzcash", status: "pending", createdAt: daysAgoIso(1) },
  { id: "txn_1004", courseTitle: "Build a WhatsApp AI Auto-Responder", learnerName: "Sara Iqbal", instructorName: "Bilal Ahmed", amount: 59, currency: "USD", commission: 17.7, netToInstructor: 41.3, gateway: "stripe", status: "completed", createdAt: daysAgoIso(1) },
  { id: "txn_1005", courseTitle: "Ship Your First AI-Powered Web App", learnerName: "Noor Fatima", instructorName: "Hamza Tariq", amount: 45, currency: "USD", commission: 13.5, netToInstructor: 31.5, gateway: "paypal", status: "failed", createdAt: daysAgoIso(2) },
  { id: "txn_1006", courseTitle: "Integrating OpenAI & Claude APIs into Node.js Apps", learnerName: "Ali Raza", instructorName: "Usman Ali", amount: 65, currency: "USD", commission: 19.5, netToInstructor: 45.5, gateway: "bank_transfer", status: "completed", createdAt: daysAgoIso(3) },
  { id: "txn_1007", courseTitle: "Prompt Engineering Fundamentals", learnerName: "Mahnoor Fatima", instructorName: "Sana Rizvi", amount: 29, currency: "USD", commission: 8.7, netToInstructor: 20.3, gateway: "stripe", status: "refunded", createdAt: daysAgoIso(5) },
  { id: "txn_1008", courseTitle: "AI-Powered Marketing Campaigns", learnerName: "Danish Raza", instructorName: "Zara Farooq", amount: 49, currency: "USD", commission: 14.7, netToInstructor: 34.3, gateway: "easypaisa", status: "completed", createdAt: daysAgoIso(6) },
  { id: "txn_1009", courseTitle: "Build a WhatsApp AI Auto-Responder", learnerName: "Hina Malik", instructorName: "Bilal Ahmed", amount: 59, currency: "USD", commission: 17.7, netToInstructor: 41.3, gateway: "jazzcash", status: "completed", createdAt: daysAgoIso(7) },
  { id: "txn_1010", courseTitle: "Automate Everything with n8n & AI", learnerName: "Omar Sheikh", instructorName: "Ayesha Khan", amount: 39, currency: "USD", commission: 11.7, netToInstructor: 27.3, gateway: "stripe", status: "pending", createdAt: daysAgoIso(8) }
];

export const ADMIN_DUMMY_PAYOUTS: AdminPayout[] = [
  { id: "po_2001", instructorName: "Ayesha Khan", instructorId: "usr_1001", amount: 420, currency: "USD", method: "bank_transfer", status: "pending", requestedAt: daysAgoIso(1) },
  { id: "po_2002", instructorName: "Sana Rizvi", instructorId: "usr_1005", amount: 890, currency: "USD", method: "stripe_connect", status: "pending", requestedAt: daysAgoIso(2) },
  { id: "po_2003", instructorName: "Bilal Ahmed", instructorId: "usr_1002", amount: 310, currency: "USD", method: "easypaisa", status: "approved", requestedAt: daysAgoIso(3) },
  { id: "po_2004", instructorName: "Zara Farooq", instructorId: "usr_1008", amount: 560, currency: "USD", method: "jazzcash", status: "paid", requestedAt: daysAgoIso(10), processedAt: daysAgoIso(7) },
  { id: "po_2005", instructorName: "Usman Ali", instructorId: "usr_1007", amount: 275, currency: "USD", method: "bank_transfer", status: "paid", requestedAt: daysAgoIso(20), processedAt: daysAgoIso(17) },
  { id: "po_2006", instructorName: "Hamza Tariq", instructorId: "usr_1011", amount: 150, currency: "USD", method: "easypaisa", status: "rejected", requestedAt: daysAgoIso(15) }
];

export const ADMIN_DUMMY_REFUNDS: AdminRefund[] = [
  { id: "rfd_3001", transactionId: "txn_1007", courseTitle: "Prompt Engineering Fundamentals", learnerName: "Mahnoor Fatima", amount: 29, currency: "USD", reason: "Course content did not match the description.", status: "approved", requestedAt: daysAgoIso(5) },
  { id: "rfd_3002", transactionId: "txn_1002", courseTitle: "AI-Powered Marketing Campaigns", learnerName: "Omar Sheikh", amount: 49, currency: "USD", reason: "Purchased by mistake, requesting refund within policy window.", status: "pending", requestedAt: daysAgoIso(0) },
  { id: "rfd_3003", transactionId: "txn_1009", courseTitle: "Build a WhatsApp AI Auto-Responder", learnerName: "Hina Malik", amount: 59, currency: "USD", reason: "Technical issues prevented course access.", status: "pending", requestedAt: daysAgoIso(1) },
  { id: "rfd_3004", transactionId: "txn_1004", courseTitle: "Build a WhatsApp AI Auto-Responder", learnerName: "Sara Iqbal", amount: 59, currency: "USD", reason: "Requesting refund after completing 80% of the course.", status: "rejected", requestedAt: daysAgoIso(12) }
];

export const ADMIN_DUMMY_TAX_RULES: TaxRule[] = [
  { id: "tax_pk", region: "Pakistan", ratePercent: 0, appliesTo: "All course sales", active: true },
  { id: "tax_us", region: "United States", ratePercent: 0, appliesTo: "All course sales", active: true },
  { id: "tax_eu", region: "European Union", ratePercent: 20, appliesTo: "Digital goods (VAT)", active: true },
  { id: "tax_gb", region: "United Kingdom", ratePercent: 20, appliesTo: "Digital goods (VAT)", active: true },
  { id: "tax_in", region: "India", ratePercent: 18, appliesTo: "Digital goods (GST)", active: false }
];
'@
Write-Utf8NoBom -Path "packages\api-client\src\dummy-data-admin-finance.ts" -Content $adminFinanceDummyData

Patch-File -Path "packages\api-client\src\index.ts" `
  -OldStr 'export * from "./hooks/useAdminCourses";' `
  -NewStr @'
export * from "./hooks/useAdminCourses";
export * from "./dummy-data-admin-finance";
export * from "./hooks/useAdminFinance";
'@ `
  -Label "export admin finance dummy data + hooks"

# ---------------------------------------------------------------------------
# 2. useAdminFinance hooks
# ---------------------------------------------------------------------------
$useAdminFinance = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_TRANSACTIONS,
  ADMIN_DUMMY_PAYOUTS,
  ADMIN_DUMMY_REFUNDS,
  ADMIN_DUMMY_TAX_RULES,
  type AdminTransaction,
  type AdminPayout,
  type PayoutStatus,
  type AdminRefund,
  type RefundStatus,
  type TaxRule
} from "../dummy-data-admin-finance";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Finance/Payouts/Refunds/Tax API (Doc 3).
let TRANSACTIONS_STATE: AdminTransaction[] = [...ADMIN_DUMMY_TRANSACTIONS];
let PAYOUTS_STATE: AdminPayout[] = [...ADMIN_DUMMY_PAYOUTS];
let REFUNDS_STATE: AdminRefund[] = [...ADMIN_DUMMY_REFUNDS];
let TAX_RULES_STATE: TaxRule[] = [...ADMIN_DUMMY_TAX_RULES];

export const adminFinanceKeys = {
  all: ["admin", "finance"] as const,
  transactions: (filters?: Record<string, unknown>) => ["admin", "finance", "transactions", filters] as const,
  payouts: (filters?: Record<string, unknown>) => ["admin", "finance", "payouts", filters] as const,
  refunds: (filters?: Record<string, unknown>) => ["admin", "finance", "refunds", filters] as const,
  taxRules: ["admin", "finance", "tax-rules"] as const
};

export type TransactionFilters = {
  search?: string;
  status?: string;
  gateway?: string;
};

export function useAdminTransactions(filters: TransactionFilters = {}) {
  return useQuery({
    queryKey: adminFinanceKeys.transactions(filters),
    queryFn: async () => {
      let items = [...TRANSACTIONS_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter(
          (t) =>
            t.courseTitle.toLowerCase().includes(q) ||
            t.learnerName.toLowerCase().includes(q) ||
            t.instructorName.toLowerCase().includes(q) ||
            t.id.toLowerCase().includes(q)
        );
      }
      if (filters.status) items = items.filter((t) => t.status === filters.status);
      if (filters.gateway) items = items.filter((t) => t.gateway === filters.gateway);
      return delay(items);
    }
  });
}

export type PayoutFilters = {
  status?: string;
};

export function useAdminPayouts(filters: PayoutFilters = {}) {
  return useQuery({
    queryKey: adminFinanceKeys.payouts(filters),
    queryFn: async () => {
      let items = [...PAYOUTS_STATE];
      if (filters.status) items = items.filter((p) => p.status === filters.status);
      return delay(items);
    }
  });
}

export function useUpdatePayoutStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: PayoutStatus }) => {
      PAYOUTS_STATE = PAYOUTS_STATE.map((p) =>
        p.id === id
          ? { ...p, status, processedAt: status === "paid" ? new Date().toISOString() : p.processedAt }
          : p
      );
      return delay({ id, status }, 400);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminFinanceKeys.all });
    }
  });
}

export type RefundFilters = {
  status?: string;
};

export function useAdminRefunds(filters: RefundFilters = {}) {
  return useQuery({
    queryKey: adminFinanceKeys.refunds(filters),
    queryFn: async () => {
      let items = [...REFUNDS_STATE];
      if (filters.status) items = items.filter((r) => r.status === filters.status);
      return delay(items);
    }
  });
}

export function useResolveRefund() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: RefundStatus }) => {
      REFUNDS_STATE = REFUNDS_STATE.map((r) => (r.id === id ? { ...r, status } : r));
      if (status === "approved") {
        const refund = REFUNDS_STATE.find((r) => r.id === id);
        if (refund) {
          TRANSACTIONS_STATE = TRANSACTIONS_STATE.map((t) =>
            t.id === refund.transactionId ? { ...t, status: "refunded" as const } : t
          );
        }
      }
      return delay({ id, status }, 400);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminFinanceKeys.all });
    }
  });
}

export function useAdminTaxRules() {
  return useQuery({
    queryKey: adminFinanceKeys.taxRules,
    queryFn: async () => delay([...TAX_RULES_STATE])
  });
}

export function useUpdateTaxRule() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ratePercent, active }: { id: string; ratePercent: number; active: boolean }) => {
      TAX_RULES_STATE = TAX_RULES_STATE.map((r) => (r.id === id ? { ...r, ratePercent, active } : r));
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminFinanceKeys.taxRules });
    }
  });
}

export function useCreateTaxRule() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { region: string; ratePercent: number; appliesTo: string }) => {
      const created: TaxRule = {
        id: `tax_${Math.random().toString(36).slice(2, 8)}`,
        region: input.region,
        ratePercent: input.ratePercent,
        appliesTo: input.appliesTo,
        active: true
      };
      TAX_RULES_STATE = [...TAX_RULES_STATE, created];
      return delay(created, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminFinanceKeys.taxRules });
    }
  });
}
'@
Write-Utf8NoBom -Path "packages\api-client\src\hooks\useAdminFinance.ts" -Content $useAdminFinance

# ---------------------------------------------------------------------------
# 3. Transactions Ledger page
# ---------------------------------------------------------------------------
$transactionsPage = @'
"use client";

import { useMemo, useState } from "react";
import { Search, Receipt, Download } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { useAdminTransactions, type AdminTransaction } from "@saachi/api-client";
import { DataTable, StatusPill, Select, Button } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Completed", value: "completed" },
  { label: "Pending", value: "pending" },
  { label: "Failed", value: "failed" },
  { label: "Refunded", value: "refunded" }
];

const GATEWAY_OPTIONS = [
  { label: "Stripe", value: "stripe" },
  { label: "PayPal", value: "paypal" },
  { label: "Easypaisa", value: "easypaisa" },
  { label: "JazzCash", value: "jazzcash" },
  { label: "Bank Transfer", value: "bank_transfer" }
];

const STATUS_TONE: Record<AdminTransaction["status"], "success" | "warning" | "error" | "info"> = {
  completed: "success",
  pending: "warning",
  failed: "error",
  refunded: "info"
};

export default function TransactionsLedgerPage() {
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [gateway, setGateway] = useState("");

  const { data, isLoading } = useAdminTransactions({
    search: search || undefined,
    status: status || undefined,
    gateway: gateway || undefined
  });

  const columns = useMemo<ColumnDef<AdminTransaction, any>[]>(
    () => [
      {
        header: "Transaction",
        accessorKey: "id",
        cell: ({ row }) => (
          <div>
            <div className="font-mono text-[12px] text-ink-soft">{row.original.id}</div>
            <div className="max-w-[220px] truncate font-medium text-ink">{row.original.courseTitle}</div>
          </div>
        )
      },
      {
        header: "Learner",
        accessorKey: "learnerName",
        cell: ({ getValue }) => <span className="text-ink-soft">{getValue()}</span>
      },
      {
        header: "Instructor",
        accessorKey: "instructorName",
        cell: ({ getValue }) => <span className="text-ink-soft">{getValue()}</span>
      },
      {
        header: "Amount",
        accessorKey: "amount",
        cell: ({ row }) => (
          <span className="font-mono font-semibold text-ink">
            {formatCurrency(row.original.amount, row.original.currency)}
          </span>
        )
      },
      {
        header: "Commission",
        accessorKey: "commission",
        cell: ({ row }) => (
          <span className="font-mono text-ink-soft">
            {formatCurrency(row.original.commission, row.original.currency)}
          </span>
        )
      },
      {
        header: "Gateway",
        accessorKey: "gateway",
        cell: ({ getValue }) => <span className="capitalize text-ink-soft">{(getValue() as string).replace("_", " ")}</span>
      },
      {
        header: "Status",
        accessorKey: "status",
        cell: ({ getValue }) => {
          const value = getValue() as AdminTransaction["status"];
          return <StatusPill label={value} tone={STATUS_TONE[value]} />;
        }
      },
      {
        header: "Date",
        accessorKey: "createdAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatDate(getValue() as string)}</span>
      }
    ],
    []
  );

  return (
    <main className="mx-auto max-w-[1240px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Receipt size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Transactions Ledger</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Full financial transaction history across all payment gateways.</p>
          </div>
        </div>
        <Button size="sm" variant="secondary">
          <Download size={14} strokeWidth={1.75} /> Export CSV
        </Button>
      </div>

      <DataTable
        columns={columns}
        data={data ?? []}
        isLoading={isLoading}
        emptyTitle="No transactions found"
        emptyDescription="Try adjusting your search or filters."
        toolbar={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by ID, course, learner, or instructor"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All statuses" options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All gateways" options={GATEWAY_OPTIONS} value={gateway} onChange={(e) => setGateway(e.target.value)} />
            </div>
          </div>
        }
      />
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\finance\transactions\page.tsx" -Content $transactionsPage

# ---------------------------------------------------------------------------
# 4. Payout Processing Queue page
# ---------------------------------------------------------------------------
$payoutsPage = @'
"use client";

import { useState } from "react";
import { Banknote, CheckCircle2, XCircle, Send } from "lucide-react";
import { useAdminPayouts, useUpdatePayoutStatus, type AdminPayout } from "@saachi/api-client";
import { Button, Card, Select, StatusPill, ShimmerTableRow, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Approved", value: "approved" },
  { label: "Paid", value: "paid" },
  { label: "Rejected", value: "rejected" }
];

const STATUS_TONE: Record<AdminPayout["status"], "success" | "warning" | "error" | "info"> = {
  pending: "warning",
  approved: "info",
  paid: "success",
  rejected: "error"
};

export default function PayoutProcessingQueuePage() {
  const [statusFilter, setStatusFilter] = useState("");
  const { data: payouts, isLoading } = useAdminPayouts({ status: statusFilter || undefined });
  const updateStatus = useUpdatePayoutStatus();

  const pendingTotal = (payouts ?? [])
    .filter((p) => p.status === "pending")
    .reduce((sum, p) => sum + p.amount, 0);

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <Banknote size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Payout Processing Queue</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Instructor payout requests awaiting review.</p>
        </div>
      </div>

      <Card className="mb-6 flex items-center justify-between p-5">
        <div>
          <p className="text-[12px] text-ink-soft">Pending payouts (visible below)</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{formatCurrency(pendingTotal, "USD")}</p>
        </div>
        <div className="w-[200px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
      </Card>

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={4} />
          ))}
        </div>
      ) : !payouts || payouts.length === 0 ? (
        <EmptyState icon={<Banknote size={22} strokeWidth={1.75} />} title="No payouts found" description="Try a different status filter." />
      ) : (
        <div className="flex flex-col gap-3">
          {payouts.map((payout) => (
            <Card key={payout.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <div className="flex items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{payout.instructorName}</p>
                  <StatusPill label={payout.status} tone={STATUS_TONE[payout.status]} />
                </div>
                <p className="mt-1 text-[12.5px] text-ink-soft">
                  {payout.method.replace("_", " ")} - Requested {formatDate(payout.requestedAt)}
                  {payout.processedAt ? ` - Processed ${formatDate(payout.processedAt)}` : ""}
                </p>
              </div>

              <div className="flex shrink-0 items-center gap-4">
                <span className="font-mono text-[16px] font-semibold text-ink">
                  {formatCurrency(payout.amount, payout.currency)}
                </span>
                {payout.status === "pending" && (
                  <div className="flex gap-2">
                    <Button size="sm" variant="secondary" onClick={() => updateStatus.mutate({ id: payout.id, status: "rejected" })}>
                      <XCircle size={14} strokeWidth={1.75} /> Reject
                    </Button>
                    <Button size="sm" onClick={() => updateStatus.mutate({ id: payout.id, status: "approved" })}>
                      <CheckCircle2 size={14} strokeWidth={1.75} /> Approve
                    </Button>
                  </div>
                )}
                {payout.status === "approved" && (
                  <Button size="sm" onClick={() => updateStatus.mutate({ id: payout.id, status: "paid" })}>
                    <Send size={14} strokeWidth={1.75} /> Mark as paid
                  </Button>
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
Write-Utf8NoBom -Path "apps\admin\app\(console)\finance\payouts\page.tsx" -Content $payoutsPage

# ---------------------------------------------------------------------------
# 5. Refund Management page
# ---------------------------------------------------------------------------
$refundsPage = @'
"use client";

import { useState } from "react";
import { Undo2, CheckCircle2, XCircle } from "lucide-react";
import { useAdminRefunds, useResolveRefund, type AdminRefund } from "@saachi/api-client";
import { Button, Card, Select, StatusPill, ShimmerTableRow, EmptyState, Modal } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Approved", value: "approved" },
  { label: "Rejected", value: "rejected" }
];

const STATUS_TONE: Record<AdminRefund["status"], "success" | "warning" | "error"> = {
  pending: "warning",
  approved: "success",
  rejected: "error"
};

export default function RefundManagementPage() {
  const [statusFilter, setStatusFilter] = useState("");
  const { data: refunds, isLoading } = useAdminRefunds({ status: statusFilter || undefined });
  const resolveRefund = useResolveRefund();
  const [viewTarget, setViewTarget] = useState<AdminRefund | null>(null);

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Undo2 size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Refund Management</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Learner refund requests - approving reverses the transaction and clawbacks instructor earnings.</p>
          </div>
        </div>
        <div className="w-[180px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
      </div>

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={4} />
          ))}
        </div>
      ) : !refunds || refunds.length === 0 ? (
        <EmptyState icon={<Undo2 size={22} strokeWidth={1.75} />} title="No refund requests found" description="Try a different status filter." />
      ) : (
        <div className="flex flex-col gap-3">
          {refunds.map((refund) => (
            <Card key={refund.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div className="min-w-0">
                <div className="flex items-center gap-2.5">
                  <p className="truncate text-[14px] font-semibold text-ink">{refund.courseTitle}</p>
                  <StatusPill label={refund.status} tone={STATUS_TONE[refund.status]} />
                </div>
                <p className="mt-1 text-[12.5px] text-ink-soft">
                  {refund.learnerName} - Requested {formatDate(refund.requestedAt)} - {refund.transactionId}
                </p>
                <button
                  type="button"
                  onClick={() => setViewTarget(refund)}
                  className="mt-1 text-[12px] font-medium text-ink underline decoration-line-strong underline-offset-2 hover:decoration-ink"
                >
                  View reason
                </button>
              </div>

              <div className="flex shrink-0 items-center gap-4">
                <span className="font-mono text-[16px] font-semibold text-ink">
                  {formatCurrency(refund.amount, refund.currency)}
                </span>
                {refund.status === "pending" && (
                  <div className="flex gap-2">
                    <Button size="sm" variant="secondary" onClick={() => resolveRefund.mutate({ id: refund.id, status: "rejected" })}>
                      <XCircle size={14} strokeWidth={1.75} /> Reject
                    </Button>
                    <Button size="sm" onClick={() => resolveRefund.mutate({ id: refund.id, status: "approved" })}>
                      <CheckCircle2 size={14} strokeWidth={1.75} /> Approve
                    </Button>
                  </div>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal open={Boolean(viewTarget)} onClose={() => setViewTarget(null)} title="Refund reason">
        <p className="mb-1 text-[13px] font-semibold text-ink">{viewTarget?.courseTitle}</p>
        <p className="text-[14px] text-ink-soft">{viewTarget?.reason}</p>
      </Modal>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\finance\refunds\page.tsx" -Content $refundsPage

# ---------------------------------------------------------------------------
# 6. Tax / VAT Settings page
# ---------------------------------------------------------------------------
$taxSettingsPage = @'
"use client";

import { useState } from "react";
import { Percent, Plus, Pencil, Check, X } from "lucide-react";
import { useAdminTaxRules, useUpdateTaxRule, useCreateTaxRule, type TaxRule } from "@saachi/api-client";
import { Button, Card, Input, Modal, ShimmerTableRow } from "@saachi/ui";

export default function TaxSettingsPage() {
  const { data: rules, isLoading } = useAdminTaxRules();
  const updateRule = useUpdateTaxRule();
  const createRule = useCreateTaxRule();

  const [editing, setEditing] = useState<TaxRule | null>(null);
  const [editRate, setEditRate] = useState(0);
  const [editActive, setEditActive] = useState(true);

  const [showCreate, setShowCreate] = useState(false);
  const [newRegion, setNewRegion] = useState("");
  const [newRate, setNewRate] = useState(0);
  const [newAppliesTo, setNewAppliesTo] = useState("");

  const openEdit = (rule: TaxRule) => {
    setEditing(rule);
    setEditRate(rule.ratePercent);
    setEditActive(rule.active);
  };

  const handleSaveEdit = () => {
    if (!editing) return;
    updateRule.mutate({ id: editing.id, ratePercent: editRate, active: editActive });
    setEditing(null);
  };

  const handleCreate = () => {
    if (!newRegion.trim()) return;
    createRule.mutate({ region: newRegion.trim(), ratePercent: newRate, appliesTo: newAppliesTo.trim() || "All course sales" });
    setShowCreate(false);
    setNewRegion("");
    setNewRate(0);
    setNewAppliesTo("");
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Percent size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Tax / VAT Settings</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Region-based tax rules applied at checkout.</p>
          </div>
        </div>
        <Button size="sm" onClick={() => setShowCreate(true)}>
          <Plus size={14} strokeWidth={1.75} /> New rule
        </Button>
      </div>

      <div className="overflow-hidden rounded-card border border-line bg-card">
        {isLoading ? (
          Array.from({ length: 5 }).map((_, i) => <ShimmerTableRow key={i} columns={3} />)
        ) : (
          rules?.map((rule) => (
            <div key={rule.id} className="flex flex-col gap-3 border-b border-line px-5 py-4 last:border-0 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <div className="flex items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{rule.region}</p>
                  <span
                    className={
                      rule.active
                        ? "rounded-full bg-success-tint px-2.5 py-0.5 text-[11px] font-semibold text-success"
                        : "rounded-full bg-paper-dim px-2.5 py-0.5 text-[11px] font-semibold text-ink-soft"
                    }
                  >
                    {rule.active ? "Active" : "Inactive"}
                  </span>
                </div>
                <p className="mt-1 text-[12px] text-ink-soft">{rule.appliesTo}</p>
              </div>
              <div className="flex shrink-0 items-center gap-4">
                <span className="font-mono text-[16px] font-semibold text-ink">{rule.ratePercent}%</span>
                <button
                  type="button"
                  onClick={() => openEdit(rule)}
                  className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
                >
                  <Pencil size={14} strokeWidth={1.75} />
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      <Modal
        open={Boolean(editing)}
        onClose={() => setEditing(null)}
        title={`Edit tax rule - ${editing?.region ?? ""}`}
        footer={
          <>
            <Button variant="ghost" onClick={() => setEditing(null)}>
              Cancel
            </Button>
            <Button onClick={handleSaveEdit} disabled={updateRule.isPending}>
              Save changes
            </Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input
            label="Rate (%)"
            type="number"
            min={0}
            max={100}
            value={editRate}
            onChange={(e) => setEditRate(Number(e.target.value))}
          />
          <button
            type="button"
            onClick={() => setEditActive((v) => !v)}
            className="flex w-fit items-center gap-2 rounded-control border border-line-strong px-3.5 py-2 text-[13px] font-medium text-ink hover:border-ink"
          >
            {editActive ? <Check size={14} strokeWidth={2} className="text-success" /> : <X size={14} strokeWidth={2} className="text-ink-soft" />}
            {editActive ? "Active" : "Inactive"} - click to toggle
          </button>
        </div>
      </Modal>

      <Modal
        open={showCreate}
        onClose={() => setShowCreate(false)}
        title="New tax rule"
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowCreate(false)}>
              Cancel
            </Button>
            <Button onClick={handleCreate} disabled={!newRegion.trim() || createRule.isPending}>
              Create rule
            </Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input label="Region" placeholder="e.g. Canada" value={newRegion} onChange={(e) => setNewRegion(e.target.value)} />
          <Input label="Rate (%)" type="number" min={0} max={100} value={newRate} onChange={(e) => setNewRate(Number(e.target.value))} />
          <Input label="Applies to" placeholder="e.g. Digital goods (GST)" value={newAppliesTo} onChange={(e) => setNewAppliesTo(e.target.value)} />
        </div>
      </Modal>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\finance\tax-settings\page.tsx" -Content $taxSettingsPage

Write-Host ""
Write-Host "Step 14 done." -ForegroundColor Green
Write-Host "Run: pnpm install" -ForegroundColor Yellow
Write-Host "Then: pnpm dev:admin" -ForegroundColor Green
Write-Host ""
Write-Host "What this step built:" -ForegroundColor Cyan
Write-Host "  - Admin finance dummy data (10 transactions, 6 payouts, 4 refunds, 5 tax rules)"
Write-Host "  - useAdminFinance hooks: transactions (search/status/gateway filters), payouts (approve/reject/mark paid),"
Write-Host "    refunds (approve/reject with transaction clawback), tax rules (create/edit rate + active toggle)"
Write-Host "  - /finance/transactions - full ledger DataTable with export button (UI only)"
Write-Host "  - /finance/payouts - queue cards, pending total, Approve/Reject, Mark as paid flow"
Write-Host "  - /finance/refunds - request cards with 'View reason' modal, Approve/Reject"
Write-Host "  - /finance/tax-settings - region rule list, edit rate/active modal, create new rule modal"
Write-Host ""
Write-Host "Next: Step 15 - Marketing (Homepage Banners, Coupons, Promotion Sales Tracking)" -ForegroundColor Cyan