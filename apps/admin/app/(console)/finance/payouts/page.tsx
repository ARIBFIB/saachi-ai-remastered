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