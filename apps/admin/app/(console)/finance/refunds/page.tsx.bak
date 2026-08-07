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