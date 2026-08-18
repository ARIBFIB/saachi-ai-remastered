"use client";

import { useState } from "react";
import { TrendingUp, Users, CheckCircle2, Globe } from "lucide-react";
import {
  ResponsiveContainer,
  LineChart,
  Line,
  AreaChart,
  Area,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend
} from "recharts";
import { useInstructorAnalytics, type AnalyticsPeriod } from "@saachi/api-client";
import { KpiCard, Loading } from "@saachi/ui";

const PERIODS: { key: AnalyticsPeriod; label: string }[] = [
  { key: "7d", label: "Last 7 days" },
  { key: "30d", label: "Last 30 days" },
  { key: "90d", label: "Last 12 months" }
];

const PIE_COLORS = ["#7c3aed", "#c026d3", "#ec4899", "#22c7d9", "#f59e0b"];

const CHART_TOOLTIP_STYLE = {
  borderRadius: 10,
  border: "1px solid var(--color-line)",
  backgroundColor: "var(--color-card)",
  fontSize: 12.5,
  color: "var(--color-ink)"
};

export default function InstructorAnalyticsPage() {
  const [period, setPeriod] = useState<AnalyticsPeriod>("30d");
  const { data, isLoading } = useInstructorAnalytics(period);

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Analytics</h1>
          <p className="text-[14px] text-ink-soft">Enrollment, completion, and revenue trends across your courses.</p>
        </div>
        <div className="flex gap-1.5">
          {PERIODS.map((p) => (
            <button
              key={p.key}
              type="button"
              onClick={() => setPeriod(p.key)}
              className={`rounded-full px-3.5 py-1.5 text-[12.5px] font-semibold transition-colors duration-150 ease-out ${
                period === p.key ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
              }`}
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>

      {isLoading || !data ? (
        <Loading label="Loading analytics..." />
      ) : (
        <>
          <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
            <KpiCard label="Total enrollments" value={String(data.totalEnrollments)} icon={Users} />
            <KpiCard label="Completion rate" value={`${data.completionRate}%`} icon={CheckCircle2} />
            <KpiCard label={`Revenue (${period})`} value={`$${data.revenue30d.toLocaleString()}`} icon={TrendingUp} />
            <KpiCard label="Top traffic source" value={data.topTrafficSource} icon={Globe} />
          </div>

          <div className="mb-8 grid grid-cols-1 gap-5 lg:grid-cols-3">
            <div className="rounded-card border border-line bg-card p-5 lg:col-span-2">
              <h2 className="mb-4 text-[14px] font-semibold text-ink">Enrollments vs. completions</h2>
              <div className="h-[260px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={data.enrollmentTrend} margin={{ top: 4, right: 8, left: -16, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" vertical={false} />
                    <XAxis dataKey="label" tick={{ fontSize: 11, fill: "var(--color-ink-soft)" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 11, fill: "var(--color-ink-soft)" }} axisLine={false} tickLine={false} width={32} />
                    <Tooltip contentStyle={CHART_TOOLTIP_STYLE} />
                    <Legend wrapperStyle={{ fontSize: 12 }} />
                    <Line type="monotone" dataKey="enrollments" name="Enrollments" stroke="#7c3aed" strokeWidth={2.5} dot={false} />
                    <Line type="monotone" dataKey="completions" name="Completions" stroke="#22c7d9" strokeWidth={2.5} dot={false} />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>

            <div className="rounded-card border border-line bg-card p-5">
              <h2 className="mb-4 text-[14px] font-semibold text-ink">Traffic sources</h2>
              <div className="h-[200px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={data.trafficSources}
                      dataKey="value"
                      nameKey="name"
                      innerRadius={48}
                      outerRadius={78}
                      paddingAngle={2}
                    >
                      {data.trafficSources.map((_, i) => (
                        <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} stroke="var(--color-card)" strokeWidth={2} />
                      ))}
                    </Pie>
                    <Tooltip contentStyle={CHART_TOOLTIP_STYLE} formatter={(v: number) => `${v}%`} />
                  </PieChart>
                </ResponsiveContainer>
              </div>
              <div className="mt-2 flex flex-col gap-1.5">
                {data.trafficSources.map((s, i) => (
                  <div key={s.name} className="flex items-center justify-between text-[12px]">
                    <span className="flex items-center gap-1.5 text-ink-soft">
                      <span className="h-2 w-2 rounded-full" style={{ backgroundColor: PIE_COLORS[i % PIE_COLORS.length] }} />
                      {s.name}
                    </span>
                    <span className="font-mono text-ink">{s.value}%</span>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="mb-8 grid grid-cols-1 gap-5 lg:grid-cols-3">
            <div className="rounded-card border border-line bg-card p-5 lg:col-span-2">
              <h2 className="mb-4 text-[14px] font-semibold text-ink">Revenue trend</h2>
              <div className="h-[220px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <AreaChart data={data.revenueTrend} margin={{ top: 4, right: 8, left: -16, bottom: 0 }}>
                    <defs>
                      <linearGradient id="revenueFill" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="0%" stopColor="#7c3aed" stopOpacity={0.35} />
                        <stop offset="100%" stopColor="#7c3aed" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" vertical={false} />
                    <XAxis dataKey="label" tick={{ fontSize: 11, fill: "var(--color-ink-soft)" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 11, fill: "var(--color-ink-soft)" }} axisLine={false} tickLine={false} width={40} tickFormatter={(v) => `$${v}`} />
                    <Tooltip contentStyle={CHART_TOOLTIP_STYLE} formatter={(v: number) => `$${v.toLocaleString()}`} />
                    <Area type="monotone" dataKey="revenue" name="Revenue" stroke="#7c3aed" strokeWidth={2.5} fill="url(#revenueFill)" />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </div>

            <div className="rounded-card border border-line bg-card p-5">
              <h2 className="mb-4 text-[14px] font-semibold text-ink">Engagement heatmap (weekly)</h2>
              <div className="h-[220px] w-full">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={data.engagementByDay} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" vertical={false} />
                    <XAxis dataKey="day" tick={{ fontSize: 11, fill: "var(--color-ink-soft)" }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 11, fill: "var(--color-ink-soft)" }} axisLine={false} tickLine={false} width={32} />
                    <Tooltip contentStyle={CHART_TOOLTIP_STYLE} formatter={(v: number) => `${v} min`} />
                    <Bar dataKey="activeMinutes" name="Active minutes" fill="#ec4899" radius={[6, 6, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>
          </div>

          <h2 className="mb-4 font-display text-[18px] font-semibold text-ink">Course performance comparison</h2>
          <div className="overflow-hidden rounded-card border border-line bg-card">
            <table className="w-full text-left text-[13px]">
              <thead className="border-b border-line bg-paper-dim">
                <tr>
                  <th className="px-4 py-3 font-semibold text-ink-soft">Course</th>
                  <th className="px-4 py-3 font-semibold text-ink-soft">Enrollments</th>
                  <th className="px-4 py-3 font-semibold text-ink-soft">Completion rate</th>
                  <th className="px-4 py-3 font-semibold text-ink-soft">Revenue</th>
                </tr>
              </thead>
              <tbody>
                {data.topCourses.map((c) => (
                  <tr key={c.id} className="border-b border-line last:border-0">
                    <td className="px-4 py-3.5 font-medium text-ink">{c.title}</td>
                    <td className="px-4 py-3.5 text-ink-soft">{c.enrollments}</td>
                    <td className="px-4 py-3.5">
                      <div className="flex items-center gap-2">
                        <div className="h-1.5 w-20 overflow-hidden rounded-full bg-paper-dim">
                          <div className="h-full rounded-full bg-gold" style={{ width: `${c.completionRate}%` }} />
                        </div>
                        <span className="text-ink-soft">{c.completionRate}%</span>
                      </div>
                    </td>
                    <td className="px-4 py-3.5 font-mono text-ink">${c.revenue.toLocaleString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
