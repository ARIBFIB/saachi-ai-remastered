<#
  Dashboard enhancements (no new modules/features - just improving the existing dashboard):

    1) Pie chart with a view-switcher (Revenue by Category / Users by Role /
       Transactions by Gateway) - click a pill to switch what you're looking at.
    2) A small "Recent activity" DataTable on the dashboard with a "View more"
       button that opens a new route (/dashboard/activity) showing the full
       paginated table (search + type filter). Clicking any row (on either
       page) navigates to the related report page.
    3) A Notifications card on the dashboard itself (mirrors the topbar bell).
       Clicking a notification opens a modal with details + a button to jump
       to the related page.
    4) KPI cards are now clickable (navigate to the related report) and each
       has a "?" icon that opens a small info box explaining what the metric
       means, without triggering navigation.
    5) A toast notification (top-right, with a close/cross button) fires when
       the dashboard finishes loading.

  Run from project root (SAI2), same folder as "apps" and "packages".
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$adminApp = Join-Path $root "apps\admin\app"
$adminConsole = Join-Path $adminApp "(console)"

if (-not (Test-Path $adminConsole)) {
    Write-Host "ERROR: Could not find $adminConsole" -ForegroundColor Red
    exit 1
}

function Write-FileUtf8NoBom {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
    Write-Host "  Wrote: $Path" -ForegroundColor Green
}

Write-Host ""
Write-Host "Applying dashboard enhancements..." -ForegroundColor Cyan
Write-Host ""

# ==========================================================================
# 1) providers.tsx - enable the close/cross button on toasts
# ==========================================================================
$providersPath = Join-Path $adminApp "providers.tsx"

$providersContent = @'
"use client";

import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "sonner";

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 30 * 1000,
            refetchOnWindowFocus: true,
            retry: 1
          }
        }
      })
  );

  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <Toaster
        position="top-right"
        closeButton
        toastOptions={{
          style: {
            background: "var(--color-card)",
            color: "var(--color-ink)",
            border: "1px solid var(--color-line)",
            borderRadius: "10px",
            fontSize: "13px"
          }
        }}
      />
    </QueryClientProvider>
  );
}
'@

Write-FileUtf8NoBom -Path $providersPath -Content $providersContent

# ==========================================================================
# 2) Rewrite dashboard/page.tsx
# ==========================================================================
$dashboardPagePath = Join-Path $adminConsole "dashboard\page.tsx"

$dashboardPageContent = @'
"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import {
  Users,
  DollarSign,
  ClipboardCheck,
  LifeBuoy,
  ArrowUpRight,
  HelpCircle,
  Bell,
  ChevronRight
} from "lucide-react";
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  CartesianGrid,
  PieChart,
  Pie,
  Cell,
  Legend
} from "recharts";
import type { ColumnDef } from "@tanstack/react-table";
import { Button, Modal, DataTable, ShimmerKpiCard, ShimmerChart, Shimmer } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const REVENUE_TREND = [
  { day: "Mon", revenue: 1240 },
  { day: "Tue", revenue: 1890 },
  { day: "Wed", revenue: 1510 },
  { day: "Thu", revenue: 2230 },
  { day: "Fri", revenue: 2670 },
  { day: "Sat", revenue: 1980 },
  { day: "Sun", revenue: 2410 }
];

type PieView = "revenue" | "users" | "gateway";

const PIE_COLORS = [
  "var(--color-ink)",
  "var(--color-info)",
  "var(--color-warning)",
  "var(--color-success)",
  "var(--color-error)",
  "var(--color-ink-soft)"
];

const PIE_DATASETS: Record<PieView, { label: string; data: { name: string; value: number }[] }> = {
  revenue: {
    label: "Revenue by category",
    data: [
      { name: "AI Automation & Workflow", value: 12800 },
      { name: "AI Marketing & Sales", value: 8600 },
      { name: "AI Dev Integration", value: 6300 },
      { name: "AI Design & Creative", value: 4100 },
      { name: "Other categories", value: 3400 }
    ]
  },
  users: {
    label: "Users by role",
    data: [
      { name: "Learners", value: 3820 },
      { name: "Instructors", value: 412 },
      { name: "Corporate", value: 38 },
      { name: "Admin / staff", value: 9 }
    ]
  },
  gateway: {
    label: "Transactions by gateway",
    data: [
      { name: "Stripe", value: 210 },
      { name: "PayPal", value: 96 },
      { name: "Easypaisa", value: 74 },
      { name: "JazzCash", value: 61 },
      { name: "Bank transfer", value: 33 }
    ]
  }
};

type NotificationItem = {
  id: string;
  label: string;
  detail: string;
  tone: "warning" | "error" | "info";
  href: string;
};

const NOTIFICATIONS: NotificationItem[] = [
  {
    id: "n1",
    label: "3 courses pending moderation review",
    detail:
      "3 newly submitted courses have been waiting in the moderation queue for over 24 hours. Review and approve or reject them so instructors aren't left blocked.",
    tone: "warning",
    href: "/courses/moderation"
  },
  {
    id: "n2",
    label: "1 refund request awaiting approval",
    detail:
      "A learner has requested a refund on a completed transaction. Approving it will reverse the transaction and clawback the instructor's earned balance.",
    tone: "error",
    href: "/finance/refunds"
  },
  {
    id: "n3",
    label: "2 support tickets breaching SLA",
    detail:
      "2 open support tickets have passed their SLA due time without a response. Prioritize these to avoid further delay for the requester.",
    tone: "error",
    href: "/support/tickets"
  },
  {
    id: "n4",
    label: "Weekly payout batch ready to process",
    detail:
      "This week's instructor payout batch has been calculated and is ready for Finance Officer review and approval.",
    tone: "info",
    href: "/finance/payouts"
  }
];

const TONE_DOT: Record<NotificationItem["tone"], string> = {
  warning: "bg-warning",
  error: "bg-error",
  info: "bg-info"
};

type ActivityRow = {
  id: string;
  type: "transaction" | "course" | "ticket" | "user";
  description: string;
  actor: string;
  createdAt: string;
};

const RECENT_ACTIVITY: ActivityRow[] = [
  { id: "act_1", type: "transaction", description: 'Purchased "AI Automation with n8n"', actor: "Fatima Noor", createdAt: "2026-08-08T02:10:00Z" },
  { id: "act_2", type: "course", description: 'Submitted "Prompt Engineering for Marketers" for review', actor: "Hassan Raza", createdAt: "2026-08-08T01:40:00Z" },
  { id: "act_3", type: "ticket", description: "Opened ticket - payout not received", actor: "Ali Bukhari", createdAt: "2026-08-07T22:15:00Z" },
  { id: "act_4", type: "user", description: "New instructor application submitted", actor: "Sana Iqbal", createdAt: "2026-08-07T19:05:00Z" },
  { id: "act_5", type: "transaction", description: 'Purchased "AI Customer Support Bots"', actor: "Zeeshan Tariq", createdAt: "2026-08-07T17:50:00Z" }
];

const ACTIVITY_ROUTE: Record<ActivityRow["type"], string> = {
  transaction: "/finance/transactions",
  course: "/courses/moderation",
  ticket: "/support/tickets",
  user: "/users"
};

type KpiDef = {
  key: string;
  label: string;
  value: string;
  icon: typeof Users;
  delta: { value: string; direction: "up" | "down" };
  href: string;
  help: string;
};

export default function AdminDashboardPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);
  const [pieView, setPieView] = useState<PieView>("revenue");
  const [openHelp, setOpenHelp] = useState<string | null>(null);
  const [notifTarget, setNotifTarget] = useState<NotificationItem | null>(null);

  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 700);
    return () => clearTimeout(t);
  }, []);

  useEffect(() => {
    if (isLoading) return;
    const id = toast("Dashboard data refreshed", {
      description: "KPIs, charts, and activity are up to date as of just now.",
      duration: 5000
    });
    return () => {
      toast.dismiss(id);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [isLoading]);

  useEffect(() => {
    function handleClickOutside() {
      setOpenHelp(null);
    }
    if (openHelp) {
      document.addEventListener("click", handleClickOutside);
    }
    return () => document.removeEventListener("click", handleClickOutside);
  }, [openHelp]);

  const kpis: KpiDef[] = [
    {
      key: "signups",
      label: "New signups today",
      value: "142",
      icon: Users,
      delta: { value: "+12%", direction: "up" },
      href: "/users",
      help: "Number of new learner and instructor accounts created today across the platform."
    },
    {
      key: "revenue",
      label: "Revenue today",
      value: "$4,380",
      icon: DollarSign,
      delta: { value: "+8%", direction: "up" },
      href: "/finance/transactions",
      help: "Total gross transaction value captured today across all payment gateways."
    },
    {
      key: "approvals",
      label: "Pending approvals",
      value: "3",
      icon: ClipboardCheck,
      delta: { value: "-2", direction: "down" },
      href: "/courses/moderation",
      help: "Courses currently waiting in the moderation queue before they can go live."
    },
    {
      key: "tickets",
      label: "Open tickets",
      value: "7",
      icon: LifeBuoy,
      delta: { value: "+1", direction: "up" },
      href: "/support/tickets",
      help: "Support tickets that are still open or in progress and awaiting resolution."
    }
  ];

  const activityColumns = useMemo<ColumnDef<ActivityRow, any>[]>(
    () => [
      {
        header: "Activity",
        accessorKey: "description",
        cell: ({ row }) => (
          <div className="max-w-[320px]">
            <div className="truncate font-medium text-ink">{row.original.description}</div>
            <div className="text-[12px] text-ink-soft">{row.original.actor}</div>
          </div>
        )
      },
      {
        header: "Type",
        accessorKey: "type",
        cell: ({ getValue }) => <span className="capitalize text-ink-soft">{getValue() as string}</span>
      },
      {
        header: "When",
        accessorKey: "createdAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatRelativeTime(getValue() as string)}</span>
      }
    ],
    []
  );

  const activePie = PIE_DATASETS[pieView];

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-8">
        <h1 className="text-[24px] font-semibold text-ink">Dashboard</h1>
        <p className="mt-1 text-[13px] text-ink-soft">Platform-wide overview and pending operational items.</p>
      </div>

      {/* KPI cards - click to open the related report, "?" opens an info box */}
      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {isLoading
          ? Array.from({ length: 4 }).map((_, i) => <ShimmerKpiCard key={i} />)
          : kpis.map((kpi) => (
              <div
                key={kpi.key}
                role="button"
                tabIndex={0}
                onClick={() => router.push(kpi.href)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") router.push(kpi.href);
                }}
                className="group relative cursor-pointer rounded-card border border-line bg-card p-5 transition-colors duration-150 ease-out hover:border-line-strong"
              >
                <div className="flex items-start justify-between">
                  <div className="flex h-9 w-9 items-center justify-center rounded-control border border-line text-ink">
                    <kpi.icon size={16} strokeWidth={1.75} />
                  </div>
                  <div className="flex items-center gap-1">
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        setOpenHelp((prev) => (prev === kpi.key ? null : kpi.key));
                      }}
                      className="flex h-6 w-6 items-center justify-center rounded-full text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
                      aria-label={`What is ${kpi.label}?`}
                    >
                      <HelpCircle size={14} strokeWidth={1.75} />
                    </button>
                    <ArrowUpRight
                      size={14}
                      strokeWidth={1.75}
                      className="text-ink-soft opacity-0 transition-opacity duration-150 ease-out group-hover:opacity-100"
                    />
                  </div>
                </div>

                <p className="mt-3.5 text-[12px] text-ink-soft">{kpi.label}</p>
                <div className="mt-1 flex items-end justify-between gap-2">
                  <span className="font-mono text-[22px] font-semibold text-ink">{kpi.value}</span>
                  <span
                    className={`mb-0.5 text-[12px] font-medium ${
                      kpi.delta.direction === "up" ? "text-success" : "text-error"
                    }`}
                  >
                    {kpi.delta.value}
                  </span>
                </div>

                {openHelp === kpi.key && (
                  <div
                    onClick={(e) => e.stopPropagation()}
                    className="absolute left-0 top-[calc(100%+6px)] z-20 w-[240px] rounded-control border border-line bg-card p-3 text-[12px] leading-relaxed text-ink-soft shadow-lg"
                  >
                    {kpi.help}
                  </div>
                )}
              </div>
            ))}
      </div>

      {/* Line chart + Pie chart with view switcher */}
      <div className="mb-8 grid grid-cols-1 gap-6 lg:grid-cols-[1.3fr_1fr]">
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

        {isLoading ? (
          <ShimmerChart />
        ) : (
          <div className="rounded-card border border-line bg-card p-6">
            <div className="mb-1 text-[14px] font-semibold text-ink">{activePie.label}</div>
            <p className="mb-4 text-[12px] text-ink-soft">Tap a view below to switch what the chart shows.</p>
            <div className="mb-4 flex flex-wrap gap-1.5">
              {(Object.keys(PIE_DATASETS) as PieView[]).map((key) => (
                <button
                  key={key}
                  type="button"
                  onClick={() => setPieView(key)}
                  className={`rounded-full border px-3 py-1 text-[11.5px] font-medium transition-colors duration-150 ease-out ${
                    pieView === key
                      ? "border-ink bg-ink text-paper"
                      : "border-line text-ink-soft hover:border-line-strong hover:text-ink"
                  }`}
                >
                  {PIE_DATASETS[key].label}
                </button>
              ))}
            </div>
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie data={activePie.data} dataKey="value" nameKey="name" innerRadius={48} outerRadius={78} paddingAngle={2}>
                  {activePie.data.map((_, i) => (
                    <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    background: "var(--color-card)",
                    border: "1px solid var(--color-line)",
                    borderRadius: 10,
                    fontSize: 12,
                    color: "var(--color-ink)"
                  }}
                />
                <Legend wrapperStyle={{ fontSize: 11 }} />
              </PieChart>
            </ResponsiveContainer>
          </div>
        )}
      </div>

      {/* Notifications card - click a notification to see details */}
      <div className="mb-8 rounded-card border border-line bg-card p-6">
        <div className="mb-4 flex items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <Bell size={15} strokeWidth={1.75} className="text-ink" />
            <div className="text-[14px] font-semibold text-ink">Notifications</div>
          </div>
          <span className="text-[11.5px] text-ink-soft">{NOTIFICATIONS.length} active</span>
        </div>
        {isLoading ? (
          <div className="flex flex-col gap-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <Shimmer key={i} className="h-11 w-full" />
            ))}
          </div>
        ) : (
          <div className="flex flex-col gap-2">
            {NOTIFICATIONS.map((n) => (
              <button
                key={n.id}
                type="button"
                onClick={() => setNotifTarget(n)}
                className="flex w-full items-center justify-between gap-3 rounded-control border border-line px-3.5 py-3 text-left text-[13px] text-ink transition-colors duration-150 ease-out hover:bg-paper-dim"
              >
                <div className="flex items-center gap-2.5">
                  <span className={`h-1.5 w-1.5 shrink-0 rounded-full ${TONE_DOT[n.tone]}`} />
                  <span className="text-[12.5px]">{n.label}</span>
                </div>
                <ChevronRight size={14} strokeWidth={1.75} className="shrink-0 text-ink-soft" />
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Recent activity table - "View more" opens the full paginated report */}
      <div className="rounded-card border border-line bg-card p-6">
        <div className="mb-4 flex items-center justify-between gap-2">
          <div>
            <div className="text-[14px] font-semibold text-ink">Recent activity</div>
            <p className="mt-0.5 text-[12px] text-ink-soft">Latest transactions, submissions, and tickets across the platform.</p>
          </div>
          <Button size="sm" variant="secondary" onClick={() => router.push("/dashboard/activity")}>
            View more
          </Button>
        </div>

        {isLoading ? (
          <div className="flex flex-col gap-2">
            {Array.from({ length: 5 }).map((_, i) => (
              <Shimmer key={i} className="h-11 w-full" />
            ))}
          </div>
        ) : (
          <DataTable
            columns={activityColumns}
            data={RECENT_ACTIVITY}
            isLoading={false}
            emptyTitle="No recent activity"
            emptyDescription=""
            onRowClick={(row: ActivityRow) => router.push(ACTIVITY_ROUTE[row.type])}
          />
        )}
      </div>

      <Modal open={Boolean(notifTarget)} onClose={() => setNotifTarget(null)} title={notifTarget?.label ?? ""}>
        <p className="mb-5 text-[13.5px] leading-relaxed text-ink-soft">{notifTarget?.detail}</p>
        <div className="flex justify-end gap-2">
          <Button variant="ghost" onClick={() => setNotifTarget(null)}>
            Close
          </Button>
          <Button
            onClick={() => {
              if (notifTarget) router.push(notifTarget.href);
              setNotifTarget(null);
            }}
          >
            Go to related page
          </Button>
        </div>
      </Modal>
    </main>
  );
}
'@

Write-FileUtf8NoBom -Path $dashboardPagePath -Content $dashboardPageContent

# ==========================================================================
# 3) New file: dashboard/activity/page.tsx - full paginated activity report
# ==========================================================================
$activityPagePath = Join-Path $adminConsole "dashboard\activity\page.tsx"

$activityPageContent = @'
"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, History, ArrowLeft } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable, Select, StatusPill } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

type ActivityRow = {
  id: string;
  type: "transaction" | "course" | "ticket" | "user";
  description: string;
  actor: string;
  createdAt: string;
};

const TYPE_OPTIONS = [
  { label: "Transaction", value: "transaction" },
  { label: "Course", value: "course" },
  { label: "Ticket", value: "ticket" },
  { label: "User", value: "user" }
];

const TYPE_TONE: Record<ActivityRow["type"], "success" | "warning" | "error" | "info" | "neutral"> = {
  transaction: "success",
  course: "info",
  ticket: "warning",
  user: "neutral"
};

const ACTIVITY_ROUTE: Record<ActivityRow["type"], string> = {
  transaction: "/finance/transactions",
  course: "/courses/moderation",
  ticket: "/support/tickets",
  user: "/users"
};

const ACTORS = ["Fatima Noor", "Hassan Raza", "Ali Bukhari", "Sana Iqbal", "Zeeshan Tariq", "Ayesha Malik", "Bilal Ahmed", "Nida Khan"];

const DESCRIPTIONS: Record<ActivityRow["type"], string[]> = {
  transaction: [
    'Purchased "AI Automation with n8n"',
    'Purchased "Prompt Engineering for Marketers"',
    'Purchased "AI Customer Support Bots"',
    "Upgraded to Saachi AI Pro subscription"
  ],
  course: [
    "Submitted a new course for review",
    "Resubmitted course after feedback",
    "Published a free intro lesson"
  ],
  ticket: [
    "Opened ticket - payout not received",
    "Opened ticket - certificate not generated",
    "Opened ticket - refund status inquiry"
  ],
  user: [
    "New instructor application submitted",
    "New learner account registered",
    "Requested account verification"
  ]
};

function buildMockActivity(count: number): ActivityRow[] {
  const types: ActivityRow["type"][] = ["transaction", "course", "ticket", "user"];
  const rows: ActivityRow[] = [];
  for (let i = 0; i < count; i++) {
    const type = types[i % types.length];
    const descPool = DESCRIPTIONS[type];
    rows.push({
      id: `act_${i + 1}`,
      type,
      description: descPool[i % descPool.length],
      actor: ACTORS[i % ACTORS.length],
      createdAt: new Date(Date.now() - i * 3.7 * 60 * 60 * 1000).toISOString()
    });
  }
  return rows;
}

const ALL_ACTIVITY = buildMockActivity(64);

export default function DashboardActivityPage() {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState("");

  const filtered = useMemo(() => {
    return ALL_ACTIVITY.filter((row) => {
      const matchesSearch =
        !search ||
        row.description.toLowerCase().includes(search.toLowerCase()) ||
        row.actor.toLowerCase().includes(search.toLowerCase());
      const matchesType = !typeFilter || row.type === typeFilter;
      return matchesSearch && matchesType;
    });
  }, [search, typeFilter]);

  const columns = useMemo<ColumnDef<ActivityRow, any>[]>(
    () => [
      {
        header: "Activity",
        accessorKey: "description",
        cell: ({ row }) => (
          <div className="max-w-[360px]">
            <div className="truncate font-medium text-ink">{row.original.description}</div>
            <div className="text-[12px] text-ink-soft">{row.original.actor}</div>
          </div>
        )
      },
      {
        header: "Type",
        accessorKey: "type",
        cell: ({ getValue }) => {
          const value = getValue() as ActivityRow["type"];
          return <StatusPill label={value} tone={TYPE_TONE[value]} />;
        }
      },
      {
        header: "When",
        accessorKey: "createdAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatRelativeTime(getValue() as string)}</span>
      }
    ],
    []
  );

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/dashboard")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to dashboard
      </button>

      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <History size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Recent Activity</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Full activity log across transactions, courses, tickets, and users.</p>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={filtered}
        isLoading={false}
        emptyTitle="No activity found"
        emptyDescription="Try adjusting your search or filters."
        onRowClick={(row: ActivityRow) => router.push(ACTIVITY_ROUTE[row.type])}
        toolbar={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by description or actor"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All types" options={TYPE_OPTIONS} value={typeFilter} onChange={(e) => setTypeFilter(e.target.value)} />
            </div>
          </div>
        }
      />
    </main>
  );
}
'@

Write-FileUtf8NoBom -Path $activityPagePath -Content $activityPageContent

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Done. Restart 'pnpm dev' if it doesn't hot-reload cleanly." -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Test:"
Write-Host "  http://localhost:3001/dashboard          (KPI clicks/tooltips, pie switcher, notifications, activity table, toast)"
Write-Host "  http://localhost:3001/dashboard/activity  (full paginated activity report)"
Write-Host ""