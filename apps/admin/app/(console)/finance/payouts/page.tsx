"use client";

import { useMemo, useState } from "react";
import { Banknote, CheckCircle2, XCircle, Search, Layers } from "lucide-react";
import {
  useAdminPayouts,
  useProcessPayout,
  useBatchProcessPayouts,
  type AdminPayout
} from "@saachi/api-client";
import { Button, Card, Select, StatusPill, Modal, EmptyState, ShimmerKpiCard, ShimmerTableRow } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

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

const STATUS_TONE: Record<AdminPayout["status"], "success" | "warning" | "error" | "info"> = {
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
  const [rejectTarget, setRejectTarget] = useState<AdminPayout | null>(null);

  const { data: payouts, isLoading } = useAdminPayouts({
    status: statusFilter || undefined,
    method: methodFilter || undefined,
    search: search || undefined
  });
  const processPayout = useProcessPayout();
  const batchProcess = useBatchProcessPayouts();

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
    batchProcess.mutate({ ids: selectedIds, decision: "approved" });
    setSelected({});
  };

  const handleApproveSingle = (payout: AdminPayout) => {
    processPayout.mutate({ id: payout.id, decision: "approved" });
  };

  const handleMarkPaid = (payout: AdminPayout) => {
    processPayout.mutate({ id: payout.id, decision: "paid" });
  };

  const handleRejectSubmit = (reason: string) => {
    if (!rejectTarget) return;
    processPayout.mutate({ id: rejectTarget.id, decision: "rejected", reason });
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
        <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      ) : (
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
      )}

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

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 5 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={5} />
          ))}
        </div>
      ) : !payouts || payouts.length === 0 ? (
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
  target: AdminPayout | null;
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