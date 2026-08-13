"use client";

import Link from "next/link";
import { Wallet, TrendingUp, Clock } from "lucide-react";
import { Button, KpiCard, EmptyState } from "@saachi/ui";

export default function InstructorEarningsPage() {
  return (
    <div>
      <div className="mb-8 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Earnings</h1>
          <p className="text-[14px] text-ink-soft">Your current balance and lifetime earnings breakdown.</p>
        </div>
        <Link href="/instructor/payouts">
          <Button>Request payout</Button>
        </Link>
      </div>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-3">
        <KpiCard label="Available balance" value="$0.00" icon={Wallet} />
        <KpiCard label="Lifetime earnings" value="$0.00" icon={TrendingUp} />
        <KpiCard label="Pending clearance" value="$0.00" icon={Clock} />
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Earnings by course</h2>
      <EmptyState
        title="No earnings yet"
        description="Once learners start purchasing your courses, a per-course earnings breakdown will appear here."
      />
    </div>
  );
}