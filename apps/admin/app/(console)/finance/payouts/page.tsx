"use client";

import { useMemo, useState } from "react";
import { Banknote, CheckCircle2, XCircle, Search } from "lucide-react";
import {
  useAdminPayouts,
  useApprovePayout,
  useRejectPayout,
  useBatchApprovePayouts,
  type AdminPayout
} from "@saachi/api-client";
import { Button, Card, Select, StatusPill, ShimmerTableRow, EmptyState, Modal, Checkbox } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Approved", value: "approved" },
  { label: "Rejected", value: "rejected" },
  { label: "Paid", value: "paid" }
];

const METHOD_OPTIONS = [
  { label: "Bank transfer", value: "bank_transfer" },
  { label: "Easypaisa", value: "easypaisa" },
  { label: "JazzCash", value: "jazzcash" },
  { label: "Stripe Connect", value: "stripe_connect" }
];

const STATUS_TONE: Record<AdminPayout["status"], "success" | "warning" | "error" | "info"> = {
  pending: "warning",
  approved: "info",
  rejected: "error",
  paid: "success"
};

export default function PayoutProcessingQueuePage() {
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("pending");
  const [method, setMethod] = useState("");
  const [selected, setSelected] = useState<string[]>([]);
  const [rejectTarget, setRejectTarget] = useState<AdminPayout | null>(null);

  const { data: payouts, isLoading } = useAdminPayouts({
    search: search || undefined,
    status: status || undefined,
    method: method || undefined
  });

  const approvePayout = useApprovePayout();
  const rejectPayout = useRejectPayout();
  const batchApprove = useBatchApprovePayouts();

  const pendingIds = useMemo(
    () => (payouts ?? []).filter((p) => p.status === "pending").map((p) => p.id),
    [payouts]
  );

  const allSelected = pendingIds.length > 0 && selected.length === pendingIds.length;

  const toggleAll = () => {
    setSelected(allSelected ? [] : pendingIds);
  };

  const toggleOne = (id: string) => {
    setSelected((prev) => (prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]));
  };

  const handleBatchApprove = () => {
    if (selected.length === 0) return;
    batchApprove.mutate({ ids: selected });
    setSelected([]);
  };

  const handleReject = (reason: string) => {
    if (!rejectTarget) return;
    rejectPayout.mutate({ id: rejectTarget.id, reason });
    setRejectTarget(null);
  };

  const selectedTotal = (payouts ?? [])
    .filter((p) => selected.includes(p.id))
    .reduce((sum, p) => sum + p.amount, 0);

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Banknote size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Payout Processing Queue</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">
              Instructor payout requests - approve individually or in batch before disbursement.
            </p>
          </div>
        </div>
        {selected.length > 0 && (
          <Button size="sm" onClick={handleBatchApprove} disabled={batchApprove.isPending}>
            <CheckCircle2 size={14} strokeWidth={1.75} />
            {batchApprove.isPending
              ? "Approving..."
              : `Approve ${selected.length} (${formatCurrency(selectedTotal, "USD")})`}
          </Button>
        )}
      </div>

      <div className="mb-5 flex flex-col gap-3 sm:flex-row sm:items-center">
        <div className="relative flex-1">
          <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
          <input
            placeholder="Search by instructor name"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
          />
        </div>
        <div className="sm:w-[180px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} />
        </div>
        <div className="sm:w-[180px]">
          <Select placeholder="All methods" options={METHOD_OPTIONS} value={method} onChange={(e) => setMethod(e.target.value)} />
        </div>
      </div>

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={5} />
          ))}
        </div>
      ) : !payouts || payouts.length === 0 ? (
        <EmptyState icon={<Banknote size={22} strokeWidth={1.75} />} title="No payout requests found" description="Try a different filter." />
      ) : (
        <div className="flex flex-col gap-3">
          {pendingIds.length > 0 && (
            <label className="flex w-fit items-center gap-2 px-1 text-[12.5px] text-ink-soft">
              <Checkbox checked={allSelected} onChange={toggleAll} />
              Select all pending ({pendingIds.length})
            </label>
          )}

          {payouts.map((payout) => (
            <Card key={payout.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div className="flex items-start gap-3">
                {payout.status === "pending" && (
                  <div className="pt-0.5">
                    <Checkbox checked={selected.includes(payout.id)} onChange={() => toggleOne(payout.id)} />
                  </div>
                )}
                <div className="min-w-0">
                  <div className="flex items-center gap-2.5">
                    <p className="truncate text-[14px] font-semibold text-ink">{payout.instructorName}</p>
                    <StatusPill label={payout.status} tone={STATUS_TONE[payout.status]} />
                  </div>
                  <p className="mt-1 text-[12.5px] text-ink-soft">
                    Requested {formatDate(payout.requestedAt)} - {payout.method.replace("_", " ")} - Balance: {formatCurrency(payout.walletBalance, payout.currency)}
                  </p>
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
                    <Button size="sm" onClick={() => approvePayout.mutate({ id: payout.id })} disabled={approvePayout.isPending}>
                      <CheckCircle2 size={14} strokeWidth={1.75} /> Approve
                    </Button>
                  </div>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal
        open={Boolean(rejectTarget)}
        onClose={() => setRejectTarget(null)}
        title="Reject payout request"
        footer={
          <>
            <Button variant="ghost" onClick={() => setRejectTarget(null)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={() => handleReject("Rejected by finance officer")} disabled={rejectPayout.isPending}>
              {rejectPayout.isPending ? "Rejecting..." : "Reject request"}
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          This will reject the payout request for{" "}
          <span className="font-semibold text-ink">{rejectTarget?.instructorName}</span> and return the amount
          to their wallet balance.
        </p>
      </Modal>
    </main>
  );
}