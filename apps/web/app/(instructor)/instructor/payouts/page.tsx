"use client";

import Link from "next/link";
import { useState } from "react";
import { Wallet, Settings } from "lucide-react";
import { Button, KpiCard, EmptyState, Badge } from "@saachi/ui";

type PayoutStatus = "pending" | "processing" | "paid" | "failed";

type PayoutRecord = {
  id: string;
  amount: number;
  currency: string;
  status: PayoutStatus;
  requestedAt: string;
};

// NOTE: demo-only dummy data. Replace with useInstructorPayouts() once
// packages/api-client hooks for payouts are confirmed.
const PAYOUTS: PayoutRecord[] = [];

const STATUS_VARIANT: Partial<Record<PayoutStatus, "gold" | "success" | "error">> = {
  pending: "gold",
  processing: "gold",
  paid: "success",
  failed: "error"
};

const STATUS_LABEL: Record<PayoutStatus, string> = {
  pending: "Pending",
  processing: "Processing",
  paid: "Paid",
  failed: "Failed"
};

export default function InstructorPayoutRequestsPage() {
  const [requesting, setRequesting] = useState(false);
  const [requested, setRequested] = useState(false);

  function handleRequestPayout() {
    setRequesting(true);
    // NOTE: demo-only, no backend payout-request mutation wired up yet.
    setTimeout(() => {
      setRequesting(false);
      setRequested(true);
    }, 600);
  }

  return (
    <div>
      <div className="mb-8 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Payout Requests</h1>
          <p className="text-[14px] text-ink-soft">Request a payout or review your payout history.</p>
        </div>
        <Link href="/instructor/payouts/methods">
          <Button variant="secondary">
            <Settings size={14} className="mr-1.5" />
            Payout method
          </Button>
        </Link>
      </div>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2">
        <KpiCard label="Available balance" value="$0.00" icon={Wallet} />
        <div className="flex items-center rounded-card border border-line bg-card p-5">
          <Button size="lg" disabled={requesting || requested} onClick={handleRequestPayout} className="w-full">
            {requested ? "Payout requested" : requesting ? "Requesting..." : "Request payout"}
          </Button>
        </div>
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Payout history</h2>
      {PAYOUTS.length === 0 ? (
        <EmptyState title="No payouts yet" description="Your payout history will show up here once you request your first payout." />
      ) : (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <table className="w-full text-left text-[13px]">
            <thead className="border-b border-line bg-paper-dim">
              <tr>
                <th className="px-4 py-3 font-semibold text-ink-soft">Payout ID</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Amount</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
                <th className="px-4 py-3 font-semibold text-ink-soft">Requested</th>
              </tr>
            </thead>
            <tbody>
              {PAYOUTS.map((p) => (
                <tr key={p.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3.5 font-medium text-ink">{p.id}</td>
                  <td className="px-4 py-3.5 font-mono text-ink">
                    {new Intl.NumberFormat("en-US", { style: "currency", currency: p.currency }).format(p.amount)}
                  </td>
                  <td className="px-4 py-3.5">
                    {STATUS_VARIANT[p.status] ? (
                      <Badge variant={STATUS_VARIANT[p.status]}>{STATUS_LABEL[p.status]}</Badge>
                    ) : (
                      <Badge>{STATUS_LABEL[p.status]}</Badge>
                    )}
                  </td>
                  <td className="px-4 py-3.5 text-ink-soft">
                    {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(p.requestedAt))}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}