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
  ChevronRight,
  CheckCircle2,
  Banknote,
  Download,
  Ticket as TicketIcon,
  Activity,
  Calendar
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
  Legend,
  BarChart,
  Bar
} from "recharts";
import type { ColumnDef } from "@tanstack/react-table";
import { Button, Modal, DataTable, ShimmerKpiCard, ShimmerChart, Shimmer, EmptyState } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";
import { getCurrentRole, canAccessModule, type StaffRole } from "../../../lib/permissions";
import {
  KPI_MODULE_MAP,
  QUICK_ACTION_MODULE_MAP,
  NOTIFICATION_MODULE_MAP,
  ACTIVITY_TYPE_MODULE_MAP,
  REVENUE_CHART_MODULE,
  PIE_CHART_MODULE,
  ENROLLMENT_CHART_MODULE
} from "../../../lib/dashboard-config";

const REVENUE_TREND: Record<string, { day: string; revenue: number }[]> = {
  today: [
    { day: "12am", revenue: 120 },
    { day: "4am", revenue: 80 },
    { day: "8am", revenue: 340 },
    { day: "12pm", revenue: 610 },
    { day: "4pm", revenue: 890 },
    { day: "8pm", revenue: 720 }
  ],
  "7d": [
    { day: "Mon", revenue: 1240 },
    { day: "Tue", revenue: 1890 },
    { day: "Wed", revenue: 1510 },
    { day: "Thu", revenue: 2230 },
    { day: "Fri", revenue: 2670 },
    { day: "Sat", revenue: 1980 },
    { day: "Sun", revenue: 2410 }
  ],
  "30d": [
    { day: "W1", revenue: 9800 },
    { day: "W2", revenue: 11200 },
    { day: "W3", revenue: 10400 },
    { day: "W4", revenue: 13600 }
  ],
  "90d": [
    { day: "Jun", revenue: 28400 },
    { day: "Jul", revenue: 31800 },
    { day: "Aug", revenue: 35200 }
  ]
};

const ENROLLMENTS_BY_CATEGORY = [
  { category: "AI Automation", enrollments: 412 },
  { category: "AI Marketing", enrollments: 318 },
  { category: "AI Dev", enrollments: 276 },
  { category: "AI Design", enrollments: 189 },
  { category: "AI Careers", enrollments: 143 },
  { category: "Prompt Eng.", enrollments: 224 }
];

type DateRange = "today" | "7d" | "30d" | "90d";

const RANGE_LABEL: Record<DateRange, string> = {
  today: "Today",
  "7d": "Last 7 days",
  "30d": "Last 30 days",
  "90d": "Last 90 days"
};

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

type QuickAction = {
  id: string;
  label: string;
  icon: typeof CheckCircle2;
  description: string;
  confirmLabel: string;
  href: string;
};

const QUICK_ACTIONS: QuickAction[] = [
  {
    id: "approve_queue",
    label: "Approve Queue",
    icon: CheckCircle2,
    description: "Jump into the course moderation queue and review the 3 courses currently pending approval.",
    confirmLabel: "Go to Moderation Queue",
    href: "/courses/moderation"
  },
  {
    id: "process_payouts",
    label: "Process Payouts",
    icon: Banknote,
    description: "This week's instructor payout batch is calculated and ready for your review and approval.",
    confirmLabel: "Go to Payouts",
    href: "/finance/payouts"
  },
  {
    id: "view_tickets",
    label: "View Tickets",
    icon: TicketIcon,
    description: "2 support tickets have breached their SLA and need immediate attention.",
    confirmLabel: "Go to Ticket Queue",
    href: "/support/tickets"
  },
  {
    id: "export_report",
    label: "Export Report",
    icon: Download,
    description: "Export a CSV snapshot of today's platform-wide KPIs, revenue, and activity for offline reporting.",
    confirmLabel: "Download CSV",
    href: ""
  }
];

const SYSTEM_STATUS = [
  { id: "api", label: "API", ok: true, detail: "All admin API endpoints are responding normally. Average latency 118ms." },
  { id: "db", label: "Database", ok: true, detail: "MongoDB cluster healthy. Read/write operations within normal thresholds." },
  { id: "payments", label: "Payments", ok: true, detail: "Stripe, PayPal, Easypaisa, and JazzCash gateways are all reachable and processing." },
  { id: "queue", label: "Job Queue", ok: true, detail: "Background jobs (payout batching, notification delivery) are processing with no backlog." }
];

export default function AdminDashboardPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);
  const [pieView, setPieView] = useState<PieView>("revenue");
  const [dateRange, setDateRange] = useState<DateRange>("7d");
  const [openHelp, setOpenHelp] = useState<string | null>(null);
  const [notifTarget, setNotifTarget] = useState<NotificationItem | null>(null);
  const [actionTarget, setActionTarget] = useState<QuickAction | null>(null);
  const [statusTarget, setStatusTarget] = useState<(typeof SYSTEM_STATUS)[number] | null>(null);
  const [currentRole, setCurrentRoleState] = useState<StaffRole>("super_admin");
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setCurrentRoleState(getCurrentRole());
    setMounted(true);
  }, []);

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

  const allKpis: KpiDef[] = [
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

  // ---- Role-aware filtering (single source of truth: lib/permissions.ts) ----
  const kpis = useMemo(
    () => (mounted ? allKpis.filter((k) => canAccessModule(KPI_MODULE_MAP[k.key], currentRole)) : allKpis),
    [mounted, currentRole]
  );

  const quickActions = useMemo(
    () =>
      mounted
        ? QUICK_ACTIONS.filter((a) => canAccessModule(QUICK_ACTION_MODULE_MAP[a.id], currentRole))
        : QUICK_ACTIONS,
    [mounted, currentRole]
  );

  const notifications = useMemo(
    () =>
      mounted
        ? NOTIFICATIONS.filter((n) => canAccessModule(NOTIFICATION_MODULE_MAP[n.id], currentRole))
        : NOTIFICATIONS,
    [mounted, currentRole]
  );

  const recentActivity = useMemo(
    () =>
      mounted
        ? RECENT_ACTIVITY.filter((a) => canAccessModule(ACTIVITY_TYPE_MODULE_MAP[a.type], currentRole))
        : RECENT_ACTIVITY,
    [mounted, currentRole]
  );

  const showRevenueChart = !mounted || canAccessModule(REVENUE_CHART_MODULE, currentRole);
  const showPieChart = !mounted || canAccessModule(PIE_CHART_MODULE, currentRole);
  const showEnrollmentChart = !mounted || canAccessModule(ENROLLMENT_CHART_MODULE, currentRole);
  const showSystemStatus = !mounted || canAccessModule("/settings/commission-tiers", currentRole);

  const hasAnyWidgets =
    kpis.length > 0 ||
    quickActions.length > 0 ||
    showRevenueChart ||
    showPieChart ||
    showEnrollmentChart ||
    notifications.length > 0 ||
    recentActivity.length > 0;

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
  const activeRevenue = REVENUE_TREND[dateRange];

  const handleActionConfirm = () => {
    if (!actionTarget) return;
    if (actionTarget.id === "export_report") {
      toast.success("Report export started", { description: "Your CSV will download shortly." });
    } else if (actionTarget.href) {
      router.push(actionTarget.href);
    }
    setActionTarget(null);
  };

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex flex-wrap items-start justify-between gap-4">
        <div>
          <h1 className="text-[24px] font-semibold text-ink">Dashboard</h1>
          <p className="mt-1 text-[13px] text-ink-soft">Platform-wide overview and pending operational items.</p>
        </div>

        {showRevenueChart && (
          <div className="flex items-center gap-1.5 rounded-control border border-line bg-card p-1">
            <Calendar size={14} strokeWidth={1.75} className="ml-1.5 text-ink-soft" />
            {(Object.keys(RANGE_LABEL) as DateRange[]).map((range) => (
              <button
                key={range}
                type="button"
                onClick={() => setDateRange(range)}
                className={`rounded-control px-2.5 py-1.5 text-[12px] font-medium transition-colors duration-150 ease-out ${
                  dateRange === range ? "bg-ink text-paper" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                }`}
              >
                {RANGE_LABEL[range]}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* System status strip - Super Admin only (ties to platform-wide config access) */}
      {showSystemStatus && (
        <div className="mb-6 flex flex-wrap items-center gap-2 rounded-control border border-line bg-card px-4 py-2.5">
          <span className="flex items-center gap-1.5 text-[12px] font-semibold text-ink-soft">
            <Activity size={13} strokeWidth={1.75} /> System status
          </span>
          <span className="h-4 w-px bg-line" />
          {SYSTEM_STATUS.map((s) => (
            <button
              key={s.id}
              type="button"
              onClick={() => setStatusTarget(s)}
              className="flex items-center gap-1.5 rounded-full border border-line px-2.5 py-1 text-[11.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:border-line-strong hover:text-ink"
            >
              <span className={`h-1.5 w-1.5 rounded-full ${s.ok ? "bg-success" : "bg-error"}`} />
              {s.label}
            </button>
          ))}
        </div>
      )}

      {/* KPI cards - filtered by role's accessible modules */}
      {(isLoading || kpis.length > 0) && (
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
      )}

      {/* Quick actions row - filtered by role's accessible modules */}
      {(isLoading || quickActions.length > 0) && (
        <div className="mb-8 rounded-card border border-line bg-card p-6">
          <div className="mb-4 text-[14px] font-semibold text-ink">Quick actions</div>
          <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
            {(isLoading ? QUICK_ACTIONS : quickActions).map((action) => (
              <button
                key={action.id}
                type="button"
                onClick={() => setActionTarget(action)}
                className="flex flex-col items-start gap-2.5 rounded-control border border-line p-4 text-left transition-colors duration-150 ease-out hover:border-line-strong hover:bg-paper-dim"
              >
                <div className="flex h-9 w-9 items-center justify-center rounded-control border border-line text-ink">
                  <action.icon size={16} strokeWidth={1.75} />
                </div>
                <span className="text-[12.5px] font-medium text-ink">{action.label}</span>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Line chart + Pie chart - both gated behind /finance access */}
      {(showRevenueChart || showPieChart) && (
        <div className="mb-8 grid grid-cols-1 gap-6 lg:grid-cols-[1.3fr_1fr]">
          {showRevenueChart &&
            (isLoading ? (
              <ShimmerChart />
            ) : (
              <div className="rounded-card border border-line bg-card p-6">
                <div className="mb-1 text-[14px] font-semibold text-ink">Revenue - {RANGE_LABEL[dateRange].toLowerCase()}</div>
                <p className="mb-5 text-[12px] text-ink-soft">Gross transaction volume across all payment gateways.</p>
                <ResponsiveContainer width="100%" height={220}>
                  <LineChart data={activeRevenue}>
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
            ))}

          {showPieChart &&
            (isLoading ? (
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
            ))}
        </div>
      )}

      {/* Bar chart - enrollments by category (analytics access) */}
      {showEnrollmentChart &&
        (isLoading ? (
          <div className="mb-8">
            <ShimmerChart />
          </div>
        ) : (
          <div className="mb-8 rounded-card border border-line bg-card p-6">
            <div className="mb-1 text-[14px] font-semibold text-ink">Enrollments by category</div>
            <p className="mb-5 text-[12px] text-ink-soft">New course enrollments this period, grouped by top-level category.</p>
            <ResponsiveContainer width="100%" height={240}>
              <BarChart data={ENROLLMENTS_BY_CATEGORY}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--color-line)" vertical={false} />
                <XAxis dataKey="category" stroke="var(--color-ink-soft)" fontSize={11} tickLine={false} axisLine={false} />
                <YAxis stroke="var(--color-ink-soft)" fontSize={12} tickLine={false} axisLine={false} />
                <Tooltip
                  cursor={{ fill: "var(--color-paper-dim)" }}
                  contentStyle={{
                    background: "var(--color-card)",
                    border: "1px solid var(--color-line)",
                    borderRadius: 10,
                    fontSize: 12,
                    color: "var(--color-ink)"
                  }}
                />
                <Bar dataKey="enrollments" fill="var(--color-ink)" radius={[6, 6, 0, 0]} maxBarSize={48} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        ))}

      {/* Notifications card - filtered by role's accessible modules */}
      {(isLoading || notifications.length > 0) && (
        <div className="mb-8 rounded-card border border-line bg-card p-6">
          <div className="mb-4 flex items-center justify-between gap-2">
            <div className="flex items-center gap-2">
              <Bell size={15} strokeWidth={1.75} className="text-ink" />
              <div className="text-[14px] font-semibold text-ink">Notifications</div>
            </div>
            <span className="text-[11.5px] text-ink-soft">{notifications.length} active</span>
          </div>
          {isLoading ? (
            <div className="flex flex-col gap-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <Shimmer key={i} className="h-11 w-full" />
              ))}
            </div>
          ) : (
            <div className="flex flex-col gap-2">
              {notifications.map((n) => (
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
      )}

      {/* Recent activity table - filtered by role's accessible activity types */}
      {(isLoading || recentActivity.length > 0) && (
        <div className="rounded-card border border-line bg-card p-6">
          <div className="mb-4 flex items-center justify-between gap-2">
            <div>
              <div className="text-[14px] font-semibold text-ink">Recent activity</div>
              <p className="mt-0.5 text-[12px] text-ink-soft">Latest activity across the modules you have access to.</p>
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
              data={recentActivity}
              isLoading={false}
              emptyTitle="No recent activity"
              emptyDescription=""
              onRowClick={(row: ActivityRow) => router.push(ACTIVITY_ROUTE[row.type])}
            />
          )}
        </div>
      )}

      {/* Edge case: role has no accessible dashboard widgets at all */}
      {!isLoading && !hasAnyWidgets && (
        <EmptyState
          icon={<LifeBuoy size={22} strokeWidth={1.75} />}
          title="No dashboard widgets available"
          description="Your current role does not have access to any dashboard modules. Use the sidebar to navigate to a page you have permission for."
        />
      )}

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

      <Modal open={Boolean(actionTarget)} onClose={() => setActionTarget(null)} title={actionTarget?.label ?? ""}>
        <p className="mb-5 text-[13.5px] leading-relaxed text-ink-soft">{actionTarget?.description}</p>
        <div className="flex justify-end gap-2">
          <Button variant="ghost" onClick={() => setActionTarget(null)}>
            Cancel
          </Button>
          <Button onClick={handleActionConfirm}>{actionTarget?.confirmLabel}</Button>
        </div>
      </Modal>

      <Modal open={Boolean(statusTarget)} onClose={() => setStatusTarget(null)} title={statusTarget?.label ?? ""}>
        <div className="mb-5 flex items-center gap-2">
          <span className={`h-2 w-2 rounded-full ${statusTarget?.ok ? "bg-success" : "bg-error"}`} />
          <span className="text-[13px] font-medium text-ink">{statusTarget?.ok ? "Operational" : "Degraded"}</span>
        </div>
        <p className="text-[13.5px] leading-relaxed text-ink-soft">{statusTarget?.detail}</p>
        <div className="mt-5 flex justify-end">
          <Button variant="ghost" onClick={() => setStatusTarget(null)}>
            Close
          </Button>
        </div>
      </Modal>
    </main>
  );
}

