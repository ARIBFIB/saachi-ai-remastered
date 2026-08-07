"use client";

import { useEffect, useState } from "react";
import {
  Users,
  DollarSign,
  ClipboardCheck,
  LifeBuoy,
  ArrowRight
} from "lucide-react";
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";
import Link from "next/link";
import { KpiCard, StatusPill, ShimmerKpiCard, ShimmerChart, Shimmer } from "@saachi/ui";

const REVENUE_TREND = [
  { day: "Mon", revenue: 1240 },
  { day: "Tue", revenue: 1890 },
  { day: "Wed", revenue: 1510 },
  { day: "Thu", revenue: 2230 },
  { day: "Fri", revenue: 2670 },
  { day: "Sat", revenue: 1980 },
  { day: "Sun", revenue: 2410 }
];

const ALERT_FEED = [
  { id: "al_1", label: "3 courses pending moderation review", tone: "warning" as const, href: "/courses/moderation" },
  { id: "al_2", label: "1 refund request awaiting approval", tone: "error" as const, href: "/finance/refunds" },
  { id: "al_3", label: "2 support tickets breaching SLA", tone: "error" as const, href: "/support/tickets" },
  { id: "al_4", label: "Weekly payout batch ready to process", tone: "info" as const, href: "/finance/payouts" }
];

export default function AdminDashboardPage() {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 700);
    return () => clearTimeout(t);
  }, []);

  const kpis = [
    { label: "New signups today", value: "142", icon: Users, delta: { value: "+12%", direction: "up" as const } },
    { label: "Revenue today", value: "$4,380", icon: DollarSign, delta: { value: "+8%", direction: "up" as const } },
    { label: "Pending approvals", value: "3", icon: ClipboardCheck, delta: { value: "-2", direction: "down" as const } },
    { label: "Open tickets", value: "7", icon: LifeBuoy, delta: { value: "+1", direction: "up" as const } }
  ];

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-8">
        <h1 className="text-[24px] font-semibold text-ink">Dashboard</h1>
        <p className="mt-1 text-[13px] text-ink-soft">Platform-wide overview and pending operational items.</p>
      </div>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {isLoading
          ? Array.from({ length: 4 }).map((_, i) => <ShimmerKpiCard key={i} />)
          : kpis.map((kpi) => <KpiCard key={kpi.label} {...kpi} />)}
      </div>

      <div className="mb-8 grid grid-cols-1 gap-6 lg:grid-cols-[1.4fr_1fr]">
        {isLoading ? (
          <ShimmerChart />
        ) : (
          <div className="rounded-card border border-line bg-card p-6">
            <div className="mb-1 text-[14px] font-semibold text-ink">Revenue - last 7 days</div>
            <p className="mb-5 text-[12px] text-ink-soft">Gross transaction volume across all payment gateways.</p>
            <ResponsiveContainer width="100%" height={220}>
              <LineChart data={REVENUE_TREND}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" />
                <XAxis dataKey="day" stroke="var(--color-ink-soft)" fontSize={12} tickLine={false} axisLine={false} />
                <YAxis stroke="var(--color-ink-soft)" fontSize={12} tickLine={false} axisLine={false} />
                <Tooltip
                  contentStyle={{
                    background: "var(--color-card)",
                    border: "1px solid var(--color-line)",
                    borderRadius: 10,
                    fontSize: 12,
                    color: "var(--color-ink)"
                  }}
                />
                <Line type="monotone" dataKey="revenue" stroke="var(--color-ink)" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>
        )}

        <div className="rounded-card border border-line bg-card p-6">
          <div className="mb-4 text-[14px] font-semibold text-ink">Needs attention</div>
          {isLoading ? (
            <div className="flex flex-col gap-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <Shimmer key={i} className="h-11 w-full" />
              ))}
            </div>
          ) : (
            <div className="flex flex-col gap-2">
              {ALERT_FEED.map((alert) => (
                <Link
                  key={alert.id}
                  href={alert.href}
                  className="flex items-center justify-between gap-3 rounded-control border border-line px-3.5 py-3 text-[13px] text-ink transition-colors duration-150 ease-out hover:bg-paper-dim"
                >
                  <div className="flex items-center gap-2.5">
                    <StatusPill label={alert.tone} tone={alert.tone} />
                    <span className="text-[12.5px]">{alert.label}</span>
                  </div>
                  <ArrowRight size={14} strokeWidth={1.75} className="shrink-0 text-ink-soft" />
                </Link>
              ))}
            </div>
          )}
        </div>
      </div>
    </main>
  );
}