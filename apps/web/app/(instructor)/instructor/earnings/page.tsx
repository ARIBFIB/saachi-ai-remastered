"use client";

import Link from "next/link";
import { Wallet, TrendingUp, Clock } from "lucide-react";
import { Button, KpiCard, Card } from "@saachi/ui";

// NOTE: demo-only dummy data. Replace with useInstructorEarnings() once
// packages/api-client's earnings hooks are confirmed.
const EARNINGS_BY_COURSE = [
  { id: "crs_i1", title: "Automate Everything with n8n & AI", enrollments: 654, earnings: 8420 }
];

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
        <KpiCard label="Available balance" value="$1,240.00" icon={Wallet} />
        <KpiCard label="Lifetime earnings" value="$8,420.00" icon={TrendingUp} />
        <KpiCard label="Pending clearance" value="$340.00" icon={Clock} />
      </div>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Earnings by course</h2>
      <div className="flex flex-col gap-3">
        {EARNINGS_BY_COURSE.map((c) => (
          <Card key={c.id} className="flex items-center justify-between gap-4 p-5">
            <div>
              <p className="text-[15px] font-semibold text-ink">{c.title}</p>
              <p className="mt-1 text-[13px] text-ink-soft">{c.enrollments} enrollments</p>
            </div>
            <span className="font-mono text-[16px] font-semibold text-ink">
              {new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" }).format(c.earnings)}
            </span>
          </Card>
        ))}
      </div>
    </div>
  );
}
