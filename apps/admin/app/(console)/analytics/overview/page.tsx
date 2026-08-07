"use client";

import { useEffect, useState } from "react";
import { DollarSign, Repeat, GraduationCap, Undo2 } from "lucide-react";
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";
import { KpiCard, ShimmerKpiCard, ShimmerChart , HelpTooltip } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

const GMV_TREND = [
  { month: "Mar", gmv: 18400 },
  { month: "Apr", gmv: 21200 },
  { month: "May", gmv: 24900 },
  { month: "Jun", gmv: 27600 },
  { month: "Jul", gmv: 31800 },
  { month: "Aug", gmv: 35200 }
];

export default function AnalyticsOverviewPage() {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 600);
    return () => clearTimeout(t);
  }, []);

  const kpis = [
    { label: "Gross Merchandise Value", value: formatCurrency(35200, "USD"), icon: DollarSign, delta: { value: "+10.7%", direction: "up" as const } },
    { label: "Subscription MRR", value: formatCurrency(6840, "USD"), icon: Repeat, delta: { value: "+4.2%", direction: "up" as const } },
    { label: "Completion rate", value: "62%", icon: GraduationCap, delta: { value: "+3pts", direction: "up" as const } },
    { label: "Refund rate", value: "2.4%", icon: Undo2, delta: { value: "-0.3pts", direction: "down" as const } }
  ];

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-8">
        <div className="flex items-center gap-1.5"><h1 className="text-[22px] font-semibold text-ink">Analytics Overview</h1><HelpTooltip text="Platform-wide financial and engagement metrics: Gross Merchandise Value, subscription revenue, course completion, and refund rates." /></div>
        <p className="mt-1 text-[13px] text-ink-soft">Platform-wide GMV, subscription revenue, completion, and refund metrics.</p>
      </div>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {isLoading
          ? Array.from({ length: 4 }).map((_, i) => <ShimmerKpiCard key={i} />)
          : kpis.map((kpi) => <KpiCard key={kpi.label} {...kpi} />)}
      </div>

      {isLoading ? (
        <ShimmerChart />
      ) : (
        <div className="rounded-card border border-line bg-card p-6">
          <div className="mb-1 text-[14px] font-semibold text-ink">GMV - last 6 months</div>
          <p className="mb-5 text-[12px] text-ink-soft">Gross transaction value across all courses and subscriptions.</p>
          <ResponsiveContainer width="100%" height={260}>
            <LineChart data={GMV_TREND}>
              <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" />
              <XAxis dataKey="month" stroke="var(--color-ink-soft)" fontSize={12} tickLine={false} axisLine={false} />
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
              <Line type="monotone" dataKey="gmv" stroke="var(--color-ink)" strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </div>
      )}
    </main>
  );
}