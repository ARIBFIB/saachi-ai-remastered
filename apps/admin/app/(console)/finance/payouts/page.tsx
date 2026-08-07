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