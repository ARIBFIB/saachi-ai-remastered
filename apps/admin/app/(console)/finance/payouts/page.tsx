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