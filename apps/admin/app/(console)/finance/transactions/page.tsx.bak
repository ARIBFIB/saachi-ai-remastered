"use client";

import { useMemo, useState } from "react";
import { Search, Receipt, Download } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { useAdminTransactions, type AdminTransaction } from "@saachi/api-client";
import { DataTable, StatusPill, Select, Button , RefreshButton } from "@saachi/ui";
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
      <div className="mb-3 flex justify-end"><RefreshButton /></div>

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