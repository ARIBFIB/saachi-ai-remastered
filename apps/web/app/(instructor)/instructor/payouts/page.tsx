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
          value={balanceLoading ? "â€¦" : `$${(balance?.availableBalance ?? 0).toLocaleString()}`}
          icon={Wallet}
        />
        <KpiCard
          label="Pending requests"
          value={balanceLoading ? "â€¦" : `$${(balance?.pendingTotal ?? 0).toLocaleString()}`}
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
