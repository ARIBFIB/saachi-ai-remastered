"use client";

import { useState } from "react";
import { Banknote, CheckCircle2, XCircle, Eye } from "lucide-react";
import { useAdminPayouts, useUpdatePayoutStatus, type AdminPayout } from "@saachi/api-client";
import { Button, Card, Select, StatusPill, ShimmerTableRow, EmptyState, Modal } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Approved", value: "approved" },
  { label: "Processing", value: "processing" },
  { label: "Paid", value: "paid" },
  { label: "Rejected", value: "rejected" }
];

const STATUS_TONE: Record<AdminPayout["status"], "success" | "warning" | "error" | "info" | "neutral"> = {
  pending: "warning",
  approved: "info",
  processing: "info",
  paid: "success",
  rejected: "error"
};

export default function PayoutProcessingQueuePage() {
  const [statusFilter, setStatusFilter] = useState("pending");
  const { data: payouts, isLoading } = useAdminPayouts({ status: statusFilter || undefined });
  const updateStatus = useUpdatePayoutStatus();
  const [viewTarget, setViewTarget] = useState<AdminPayout | null>(null);
  const [selected, setSelected] = useState<string[]>([]);

  const pendingIds = (payouts ?? []).filter((p) => p.status === "pending").map((p) => p.id);
  const allSelected = pendingIds.length > 0 && pendingIds.every((id) => selected.includes(id));

  const toggleAll = () => {
    setSelected(allSelected ? [] : pendingIds);
  };

  const toggleOne = (id: string) => {
    setSelected((prev) => (prev.includes(id) ? prev.filter((s) => s !== id) : [...prev, id]));
  };

  const handleBatchApprove = () => {
    selected.forEach((id) => updateStatus.mutate({ id, status: "approved" }));
    setSelected([]);
  };

  const totalSelectedAmount = (payouts ?? [])
    .filter((p) => selected.includes(p.id))
    .reduce((sum, p) => sum + p.amount, 0);

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Banknote size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Payout Processing Queue</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Instructor payout requests awaiting Finance review and disbursement.</p>
          </div>
        </div>
        <div className="w-[180px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
      </div>

      {selected.length > 0 && (
        <div className="mb-4 flex items-center justify-between rounded-control border border-line-strong bg-paper-dim px-4 py-3">
          <span className="text-[13px] font-medium text-ink">
            {selected.length} selected - {formatCurrency(totalSelectedAmount, "USD")}
          </span>
          <Button size="sm" onClick={handleBatchApprove} disabled={updateStatus.isPending}>
            <CheckCircle2 size={14} strokeWidth={1.75} /> Batch approve
          </Button>
        </div>
      )}

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={4} />
          ))}
        </div>
      ) : !payouts || payouts.length === 0 ? (
        <EmptyState icon={<Banknote size={22} strokeWidth={1.75} />} title="No payout requests found" description="Try a different status filter." />
      ) : (
        <div className="flex flex-col gap-3">
          {pendingIds.length > 0 && (
            <label className="flex w-fit items-center gap-2 px-1 text-[12.5px] text-ink-soft">
              <input type="checkbox" checked={allSelected} onChange={toggleAll} className="h-4 w-4 rounded border-line-strong" />
              Select all pending
            </label>
          )}
          {payouts.map((payout) => (
            <Card key={payout.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div className="flex items-center gap-3">
                {payout.status === "pending" && (
                  <input
                    type="checkbox"
                    checked={selected.includes(payout.id)}
                    onChange={() => toggleOne(payout.id)}
                    className="h-4 w-4 shrink-0 rounded border-line-strong"
                  />
                )}
                <div>
                  <div className="flex items-center gap-2.5">
                    <p className="text-[14px] font-semibold text-ink">{payout.instructorName}</p>
                    <StatusPill label={payout.status} tone={STATUS_TONE[payout.status]} />
                  </div>
                  <p className="mt-1 text-[12.5px] text-ink-soft">
                    {payout.method} - Requested {formatDate(payout.requestedAt)} - {payout.id}
                  </p>
                </div>
              </div>

              <div className="flex shrink-0 items-center gap-4">
                <span className="font-mono text-[16px] font-semibold text-ink">
                  {formatCurrency(payout.amount, payout.currency)}
                </span>
                <button
                  type="button"
                  onClick={() => setViewTarget(payout)}
                  className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
                >
                  <Eye size={14} strokeWidth={1.75} />
                </button>
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
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal open={Boolean(viewTarget)} onClose={() => setViewTarget(null)} title="Payout details">
        {viewTarget && (
          <div className="flex flex-col gap-3 text-[13.5px]">
            <div className="flex justify-between"><span className="text-ink-soft">Instructor</span><span className="font-medium text-ink">{viewTarget.instructorName}</span></div>
            <div className="flex justify-between"><span className="text-ink-soft">Amount</span><span className="font-mono font-medium text-ink">{formatCurrency(viewTarget.amount, viewTarget.currency)}</span></div>
            <div className="flex justify-between"><span className="text-ink-soft">Method</span><span className="font-medium text-ink">{viewTarget.method}</span></div>
            <div className="flex justify-between"><span className="text-ink-soft">Requested</span><span className="font-medium text-ink">{formatDate(viewTarget.requestedAt)}</span></div>
            <div className="flex justify-between"><span className="text-ink-soft">Reference</span><span className="font-mono text-[12px] text-ink-soft">{viewTarget.id}</span></div>
          </div>
        )}
      </Modal>
    </main>
  );
}