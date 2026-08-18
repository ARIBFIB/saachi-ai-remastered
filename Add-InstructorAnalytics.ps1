<#
.SYNOPSIS
  Adds real Analytics charts to the SAI2 Instructor module (Recharts).
  - New mock hook: packages/api-client/src/hooks/useInstructorAnalytics.ts
  - Replaces the Analytics placeholder with real charts:
    apps/web/app/(instructor)/instructor/analytics/page.tsx
    (enrollment vs completion trend, revenue trend, traffic sources donut,
    weekly engagement heatmap bar chart, course performance comparison table)
  - Appends the new hook export to packages/api-client/src/index.ts

  Run this from the SAI2 monorepo root:
  PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>
#>

$ErrorActionPreference = "Stop"

function Write-FileUtf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$RelativePath,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $RelativePath
    $dir = Split-Path -Path $fullPath -Parent
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $utf8NoBom)
    Write-Host "  Wrote: $RelativePath"
}

Write-Host ""
Write-Host "== SAI2: Instructor Analytics charts ==" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# 1) Mock analytics hook
# ---------------------------------------------------------------------------
$hookContent = @'
"use client";

import { useQuery } from "@tanstack/react-query";

// NOTE: demo-only, in-memory dummy analytics data. Replace with real
// Instructor Analytics API (aggregation endpoints) once the backend is
// available. Follows the same delay()-based mock pattern as the other
// api-client hooks (see useAdminFinance.ts, useInstructorPayouts.ts).

export type AnalyticsPeriod = "7d" | "30d" | "90d";

export type EnrollmentTrendPoint = { label: string; enrollments: number; completions: number };
export type RevenueTrendPoint = { label: string; revenue: number };
export type TrafficSourceSlice = { name: string; value: number };
export type EngagementDayPoint = { day: string; activeMinutes: number };

export type InstructorAnalyticsSnapshot = {
  totalEnrollments: number;
  completionRate: number;
  revenue30d: number;
  topTrafficSource: string;
  enrollmentTrend: EnrollmentTrendPoint[];
  revenueTrend: RevenueTrendPoint[];
  trafficSources: TrafficSourceSlice[];
  engagementByDay: EngagementDayPoint[];
  topCourses: { id: string; title: string; enrollments: number; completionRate: number; revenue: number }[];
};

function delay<T>(value: T, ms = 400): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

const TRAFFIC_SOURCES: TrafficSourceSlice[] = [
  { name: "Search", value: 38 },
  { name: "Direct", value: 24 },
  { name: "Social", value: 16 },
  { name: "Referral", value: 13 },
  { name: "Email", value: 9 }
];

const ENGAGEMENT_BY_DAY: EngagementDayPoint[] = [
  { day: "Mon", activeMinutes: 420 },
  { day: "Tue", activeMinutes: 510 },
  { day: "Wed", activeMinutes: 380 },
  { day: "Thu", activeMinutes: 610 },
  { day: "Fri", activeMinutes: 540 },
  { day: "Sat", activeMinutes: 720 },
  { day: "Sun", activeMinutes: 660 }
];

const TOP_COURSES = [
  { id: "crs_i1", title: "Automate Everything with n8n & AI", enrollments: 654, completionRate: 58, revenue: 8420 },
  { id: "crs_i2", title: "AI Chatbots for WhatsApp Support", enrollments: 128, completionRate: 41, revenue: 1450 },
  { id: "crs_i3", title: "Prompt Engineering for Client Work", enrollments: 96, completionRate: 63, revenue: 980 }
];

function buildTrend(period: AnalyticsPeriod): { enrollmentTrend: EnrollmentTrendPoint[]; revenueTrend: RevenueTrendPoint[] } {
  const config: Record<AnalyticsPeriod, { points: number; labelFn: (i: number) => string; base: number; rev: number }> = {
    "7d": {
      points: 7,
      labelFn: (i) => ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][i],
      base: 12,
      rev: 140
    },
    "30d": {
      points: 10,
      labelFn: (i) => `Day ${i * 3 + 1}`,
      base: 40,
      rev: 480
    },
    "90d": {
      points: 12,
      labelFn: (i) => ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][i],
      base: 90,
      rev: 1100
    }
  };

  const { points, labelFn, base, rev } = config[period];
  const enrollmentTrend: EnrollmentTrendPoint[] = [];
  const revenueTrend: RevenueTrendPoint[] = [];

  let enroll = base;
  let revenue = rev;
  for (let i = 0; i < points; i++) {
    // gentle upward-trending pseudo-random walk, deterministic per index
    const wiggle = Math.sin(i * 1.3) * base * 0.25;
    enroll = Math.max(4, Math.round(base + i * (base * 0.18) + wiggle));
    const completions = Math.round(enroll * (0.45 + Math.sin(i * 0.7) * 0.08));
    revenue = Math.max(20, Math.round(rev + i * (rev * 0.16) + Math.cos(i * 1.1) * rev * 0.2));

    enrollmentTrend.push({ label: labelFn(i), enrollments: enroll, completions });
    revenueTrend.push({ label: labelFn(i), revenue });
  }

  return { enrollmentTrend, revenueTrend };
}

export function useInstructorAnalytics(period: AnalyticsPeriod = "30d") {
  return useQuery({
    queryKey: ["instructor", "analytics", period],
    queryFn: async () => {
      const { enrollmentTrend, revenueTrend } = buildTrend(period);
      const totalEnrollments = enrollmentTrend.reduce((sum, p) => sum + p.enrollments, 0);
      const totalCompletions = enrollmentTrend.reduce((sum, p) => sum + p.completions, 0);
      const completionRate = totalEnrollments > 0 ? Math.round((totalCompletions / totalEnrollments) * 100) : 0;
      const revenue30d = revenueTrend.reduce((sum, p) => sum + p.revenue, 0);

      const snapshot: InstructorAnalyticsSnapshot = {
        totalEnrollments,
        completionRate,
        revenue30d,
        topTrafficSource: TRAFFIC_SOURCES[0].name,
        enrollmentTrend,
        revenueTrend,
        trafficSources: TRAFFIC_SOURCES,
        engagementByDay: ENGAGEMENT_BY_DAY,
        topCourses: TOP_COURSES
      };

      return delay(snapshot);
    }
  });
}

'@
Write-FileUtf8NoBom -RelativePath "packages\api-client\src\hooks\useInstructorAnalytics.ts" -Content $hookContent

# ---------------------------------------------------------------------------
# 2) Analytics page with real charts
# ---------------------------------------------------------------------------
$pageContent = @'
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

'@
Write-FileUtf8NoBom -RelativePath "apps\web\app\(instructor)\instructor\analytics\page.tsx" -Content $pageContent

# ---------------------------------------------------------------------------
# 3) Wire up the new hook export in packages/api-client/src/index.ts
# ---------------------------------------------------------------------------
$indexPath = Join-Path -Path (Get-Location).Path -ChildPath "packages\api-client\src\index.ts"
if (Test-Path -Path $indexPath) {
    $indexContent = Get-Content -Path $indexPath -Raw
    $exportLine = 'export * from "./hooks/useInstructorAnalytics";'
    if ($indexContent -notmatch [regex]::Escape($exportLine)) {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        $newContent = $indexContent.TrimEnd() + "`r`n" + $exportLine + "`r`n"
        [System.IO.File]::WriteAllText($indexPath, $newContent, $utf8NoBom)
        Write-Host "  Updated: packages\api-client\src\index.ts (added export)"
    } else {
        Write-Host "  Skipped: packages\api-client\src\index.ts (export already present)"
    }
} else {
    Write-Host "  WARNING: packages\api-client\src\index.ts not found - add manually:" -ForegroundColor Yellow
    Write-Host '    export * from "./hooks/useInstructorAnalytics";'
}

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Charts use 'recharts', which is already in apps/web/package.json."
Write-Host "Next: restart 'npm run dev' inside apps/web if it was already running."
Write-Host ""