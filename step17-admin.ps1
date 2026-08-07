<#
.SYNOPSIS
    SAI2 Admin app ke baaki bache hue pages generate karta hai:
      - Finance: Payouts
      - Analytics: Overview, Cohort Analysis
      - Settings: Platform, Commission Tiers, Payment Gateways, Legal Documents, Roles & Permissions
      - System: Audit Log
      - Fix: users/[id] aur support/tickets/[id] (pehle corrupt/empty export hue the)

.NOTES
    Single-quoted here-strings (@'...'@) use kiye hain — ye PowerShell mein
    $variable expansion aur backtick escaping BILKUL nahi karte, isliye JSX
    ke andar ${} template literals ya backticks corrupt nahi hote.

.USAGE
    SAI2 project root mein rakhein aur run karein:
        .\step17-admin-remaining-pages.ps1
#>

$ErrorActionPreference = "Stop"
$AdminRoot = Join-Path (Resolve-Path ".") "apps\admin\app\(console)"

function New-PageFile {
    param(
        [string]$RelativeDir,
        [string]$Content
    )
    $dir = Join-Path $AdminRoot $RelativeDir
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $path = Join-Path $dir "page.tsx"
    [System.IO.File]::WriteAllText($path, $Content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Created: $path" -ForegroundColor Green
}

Write-Host "SAI2 Admin - remaining pages banaye ja rahe hain..." -ForegroundColor Cyan

# ============================================================
# 1. FINANCE -> PAYOUTS
# ============================================================
$payoutsPage = @'
"use client";

import { useState } from "react";
import { Banknote, CheckCircle2, XCircle, Eye } from "lucide-react";
import { useAdminPayouts, useUpdatePayoutStatus, type AdminPayout } from "@saachi/api-client";
import { Button, Card, Select, StatusPill, ShimmerTableRow, EmptyState, Modal } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Approved", value: "approved" },
  { label: "Processing", value: "processing" },
  { label: "Paid", value: "paid" },
  { label: "Rejected", value: "rejected" }
];

const STATUS_TONE: Record<AdminPayout["status"], "success" | "warning" | "error" | "info" | "neutral"> = {
  pending: "warning",
  approved: "info",
  processing: "info",
  paid: "success",
  rejected: "error"
};

export default function PayoutProcessingQueuePage() {
  const [statusFilter, setStatusFilter] = useState("pending");
  const { data: payouts, isLoading } = useAdminPayouts({ status: statusFilter || undefined });
  const updateStatus = useUpdatePayoutStatus();
  const [viewTarget, setViewTarget] = useState<AdminPayout | null>(null);
  const [selected, setSelected] = useState<string[]>([]);

  const pendingIds = (payouts ?? []).filter((p) => p.status === "pending").map((p) => p.id);
  const allSelected = pendingIds.length > 0 && pendingIds.every((id) => selected.includes(id));

  const toggleAll = () => {
    setSelected(allSelected ? [] : pendingIds);
  };

  const toggleOne = (id: string) => {
    setSelected((prev) => (prev.includes(id) ? prev.filter((s) => s !== id) : [...prev, id]));
  };

  const handleBatchApprove = () => {
    selected.forEach((id) => updateStatus.mutate({ id, status: "approved" }));
    setSelected([]);
  };

  const totalSelectedAmount = (payouts ?? [])
    .filter((p) => selected.includes(p.id))
    .reduce((sum, p) => sum + p.amount, 0);

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Banknote size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Payout Processing Queue</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Instructor payout requests awaiting Finance review and disbursement.</p>
          </div>
        </div>
        <div className="w-[180px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
      </div>

      {selected.length > 0 && (
        <div className="mb-4 flex items-center justify-between rounded-control border border-line-strong bg-paper-dim px-4 py-3">
          <span className="text-[13px] font-medium text-ink">
            {selected.length} selected - {formatCurrency(totalSelectedAmount, "USD")}
          </span>
          <Button size="sm" onClick={handleBatchApprove} disabled={updateStatus.isPending}>
            <CheckCircle2 size={14} strokeWidth={1.75} /> Batch approve
          </Button>
        </div>
      )}

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={4} />
          ))}
        </div>
      ) : !payouts || payouts.length === 0 ? (
        <EmptyState icon={<Banknote size={22} strokeWidth={1.75} />} title="No payout requests found" description="Try a different status filter." />
      ) : (
        <div className="flex flex-col gap-3">
          {pendingIds.length > 0 && (
            <label className="flex w-fit items-center gap-2 px-1 text-[12.5px] text-ink-soft">
              <input type="checkbox" checked={allSelected} onChange={toggleAll} className="h-4 w-4 rounded border-line-strong" />
              Select all pending
            </label>
          )}
          {payouts.map((payout) => (
            <Card key={payout.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div className="flex items-center gap-3">
                {payout.status === "pending" && (
                  <input
                    type="checkbox"
                    checked={selected.includes(payout.id)}
                    onChange={() => toggleOne(payout.id)}
                    className="h-4 w-4 shrink-0 rounded border-line-strong"
                  />
                )}
                <div>
                  <div className="flex items-center gap-2.5">
                    <p className="text-[14px] font-semibold text-ink">{payout.instructorName}</p>
                    <StatusPill label={payout.status} tone={STATUS_TONE[payout.status]} />
                  </div>
                  <p className="mt-1 text-[12.5px] text-ink-soft">
                    {payout.method} - Requested {formatDate(payout.requestedAt)} - {payout.id}
                  </p>
                </div>
              </div>

              <div className="flex shrink-0 items-center gap-4">
                <span className="font-mono text-[16px] font-semibold text-ink">
                  {formatCurrency(payout.amount, payout.currency)}
                </span>
                <button
                  type="button"
                  onClick={() => setViewTarget(payout)}
                  className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
                >
                  <Eye size={14} strokeWidth={1.75} />
                </button>
                {payout.status === "pending" && (
                  <div className="flex gap-2">
                    <Button size="sm" variant="secondary" onClick={() => updateStatus.mutate({ id: payout.id, status: "rejected" })}>
                      <XCircle size={14} strokeWidth={1.75} /> Reject
                    </Button>
                    <Button size="sm" onClick={() => updateStatus.mutate({ id: payout.id, status: "approved" })}>
                      <CheckCircle2 size={14} strokeWidth={1.75} /> Approve
                    </Button>
                  </div>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal open={Boolean(viewTarget)} onClose={() => setViewTarget(null)} title="Payout details">
        {viewTarget && (
          <div className="flex flex-col gap-3 text-[13.5px]">
            <div className="flex justify-between"><span className="text-ink-soft">Instructor</span><span className="font-medium text-ink">{viewTarget.instructorName}</span></div>
            <div className="flex justify-between"><span className="text-ink-soft">Amount</span><span className="font-mono font-medium text-ink">{formatCurrency(viewTarget.amount, viewTarget.currency)}</span></div>
            <div className="flex justify-between"><span className="text-ink-soft">Method</span><span className="font-medium text-ink">{viewTarget.method}</span></div>
            <div className="flex justify-between"><span className="text-ink-soft">Requested</span><span className="font-medium text-ink">{formatDate(viewTarget.requestedAt)}</span></div>
            <div className="flex justify-between"><span className="text-ink-soft">Reference</span><span className="font-mono text-[12px] text-ink-soft">{viewTarget.id}</span></div>
          </div>
        )}
      </Modal>
    </main>
  );
}
'@
New-PageFile -RelativeDir "finance\payouts" -Content $payoutsPage

# ============================================================
# 2. ANALYTICS -> OVERVIEW
# ============================================================
$analyticsOverviewPage = @'
"use client";

import { useEffect, useState } from "react";
import { DollarSign, Repeat, GraduationCap, Undo2 } from "lucide-react";
import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";
import { KpiCard, ShimmerKpiCard, ShimmerChart } from "@saachi/ui";
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
        <h1 className="text-[22px] font-semibold text-ink">Analytics Overview</h1>
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
'@
New-PageFile -RelativeDir "analytics\overview" -Content $analyticsOverviewPage

# ============================================================
# 3. ANALYTICS -> COHORTS
# ============================================================
$analyticsCohortsPage = @'
"use client";

import { useEffect, useState } from "react";
import { Layers } from "lucide-react";
import { Shimmer } from "@saachi/ui";

type CohortRow = {
  cohort: string;
  size: number;
  weeks: number[];
};

const COHORT_DATA: CohortRow[] = [
  { cohort: "Jun 2026", size: 420, weeks: [100, 68, 54, 47, 41, 38] },
  { cohort: "Jul 2026", size: 512, weeks: [100, 71, 58, 50, 44, 0] },
  { cohort: "Aug 2026", size: 389, weeks: [100, 74, 61, 0, 0, 0] }
];

function heatColor(pct: number) {
  if (pct === 0) return "transparent";
  const alpha = Math.max(0.08, pct / 100);
  return `rgba(20, 23, 26, ${alpha})`;
}

export default function CohortAnalysisPage() {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 600);
    return () => clearTimeout(t);
  }, []);

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <Layers size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Cohort Analysis</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Weekly retention percentage by learner signup cohort.</p>
        </div>
      </div>

      {isLoading ? (
        <div className="flex flex-col gap-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <Shimmer key={i} className="h-14 w-full rounded-control" />
          ))}
        </div>
      ) : (
        <div className="overflow-x-auto rounded-card border border-line bg-card">
          <table className="w-full min-w-[640px] border-collapse text-[13px]">
            <thead>
              <tr className="border-b border-line text-left text-ink-soft">
                <th className="px-4 py-3 font-medium">Cohort</th>
                <th className="px-4 py-3 font-medium">Size</th>
                {Array.from({ length: 6 }).map((_, i) => (
                  <th key={i} className="px-4 py-3 font-medium">Wk {i}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {COHORT_DATA.map((row) => (
                <tr key={row.cohort} className="border-b border-line last:border-0">
                  <td className="px-4 py-3 font-medium text-ink">{row.cohort}</td>
                  <td className="px-4 py-3 text-ink-soft">{row.size}</td>
                  {row.weeks.map((pct, i) => (
                    <td key={i} className="px-4 py-3">
                      {pct > 0 ? (
                        <span
                          className="inline-flex h-8 w-14 items-center justify-center rounded-control text-[12px] font-medium text-ink"
                          style={{ backgroundColor: heatColor(pct) }}
                        >
                          {pct}%
                        </span>
                      ) : (
                        <span className="text-ink-soft/40">-</span>
                      )}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </main>
  );
}
'@
New-PageFile -RelativeDir "analytics\cohorts" -Content $analyticsCohortsPage

# ============================================================
# 4. SETTINGS -> PLATFORM
# ============================================================
$settingsPlatformPage = @'
"use client";

import { useState } from "react";
import { SlidersHorizontal, Save } from "lucide-react";
import { Button, Card, Input, Select } from "@saachi/ui";

const CURRENCY_OPTIONS = [
  { label: "USD - US Dollar", value: "USD" },
  { label: "PKR - Pakistani Rupee", value: "PKR" },
  { label: "GBP - British Pound", value: "GBP" }
];

type FeatureFlag = { key: string; label: string; description: string; enabled: boolean };

const INITIAL_FLAGS: FeatureFlag[] = [
  { key: "corporate_accounts", label: "Corporate / Team Accounts", description: "Enable bulk seat purchase and team dashboards.", enabled: false },
  { key: "mentorship", label: "Mentorship Bookings", description: "Allow instructors to offer paid 1-on-1 sessions.", enabled: true },
  { key: "affiliate_program", label: "Affiliate Program", description: "Enable referral links and affiliate payouts.", enabled: false },
  { key: "ai_recommendations", label: "AI Recommendation Engine", description: "Personalized course suggestions on the homepage.", enabled: false }
];

export default function PlatformSettingsPage() {
  const [siteName, setSiteName] = useState("Saachi AI");
  const [defaultCurrency, setDefaultCurrency] = useState("USD");
  const [flags, setFlags] = useState(INITIAL_FLAGS);
  const [saving, setSaving] = useState(false);

  const toggleFlag = (key: string) => {
    setFlags((prev) => prev.map((f) => (f.key === key ? { ...f, enabled: !f.enabled } : f)));
  };

  const handleSave = () => {
    setSaving(true);
    setTimeout(() => setSaving(false), 700);
  };

  return (
    <main className="mx-auto max-w-[800px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <SlidersHorizontal size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Platform Settings</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Site identity, default currency, and feature flags.</p>
          </div>
        </div>
        <Button size="sm" onClick={handleSave} disabled={saving}>
          <Save size={14} strokeWidth={1.75} /> {saving ? "Saving..." : "Save changes"}
        </Button>
      </div>

      <Card className="mb-5 flex flex-col gap-4 p-5">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Input label="Site name" value={siteName} onChange={(e) => setSiteName(e.target.value)} />
          <Select label="Default currency" options={CURRENCY_OPTIONS} value={defaultCurrency} onChange={(e) => setDefaultCurrency(e.target.value)} />
        </div>
      </Card>

      <Card className="p-5">
        <p className="mb-4 text-[14px] font-semibold text-ink">Feature flags</p>
        <div className="flex flex-col gap-1">
          {flags.map((flag, i) => (
            <div key={flag.key} className={`flex items-center justify-between gap-4 py-3 ${i > 0 ? "border-t border-line" : ""}`}>
              <div>
                <p className="text-[13.5px] font-medium text-ink">{flag.label}</p>
                <p className="mt-0.5 text-[12px] text-ink-soft">{flag.description}</p>
              </div>
              <button
                type="button"
                onClick={() => toggleFlag(flag.key)}
                className={`relative h-6 w-11 shrink-0 rounded-full transition-colors duration-150 ease-out ${
                  flag.enabled ? "bg-ink" : "bg-paper-dim"
                }`}
              >
                <span
                  className={`absolute top-0.5 h-5 w-5 rounded-full bg-paper transition-transform duration-150 ease-out ${
                    flag.enabled ? "translate-x-[22px]" : "translate-x-0.5"
                  }`}
                />
              </button>
            </div>
          ))}
        </div>
      </Card>
    </main>
  );
}
'@
New-PageFile -RelativeDir "settings\platform" -Content $settingsPlatformPage

# ============================================================
# 5. SETTINGS -> COMMISSION TIERS
# ============================================================
$settingsCommissionPage = @'
"use client";

import { useState } from "react";
import { Landmark, Save } from "lucide-react";
import { Button, Card, Input } from "@saachi/ui";

type Tier = {
  id: string;
  name: string;
  criteria: string;
  ratePercent: number;
};

const INITIAL_TIERS: Tier[] = [
  { id: "new", name: "New Instructor", criteria: "Just approved, 0-2 published courses", ratePercent: 30 },
  { id: "verified", name: "Verified Instructor", criteria: "Identity verified, 3+ courses, 4.0+ rating", ratePercent: 25 },
  { id: "top_rated", name: "Top-Rated Instructor", criteria: "10+ courses, 4.5+ rating, consistent sales", ratePercent: 20 },
  { id: "partner", name: "Partner Instructor", criteria: "Invited/negotiated status", ratePercent: 15 }
];

export default function CommissionTierConfigurationPage() {
  const [tiers, setTiers] = useState(INITIAL_TIERS);
  const [saving, setSaving] = useState(false);

  const updateRate = (id: string, value: number) => {
    setTiers((prev) => prev.map((t) => (t.id === id ? { ...t, ratePercent: value } : t)));
  };

  const handleSave = () => {
    setSaving(true);
    setTimeout(() => setSaving(false), 700);
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Landmark size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Commission Tier Configuration</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Trust-tier commission rates applied to instructor course sales.</p>
          </div>
        </div>
        <Button size="sm" onClick={handleSave} disabled={saving}>
          <Save size={14} strokeWidth={1.75} /> {saving ? "Saving..." : "Save changes"}
        </Button>
      </div>

      <div className="flex flex-col gap-3">
        {tiers.map((tier) => (
          <Card key={tier.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-[14px] font-semibold text-ink">{tier.name}</p>
              <p className="mt-1 text-[12.5px] text-ink-soft">{tier.criteria}</p>
            </div>
            <div className="w-full sm:w-[140px]">
              <Input
                label="Commission %"
                type="number"
                min={0}
                max={100}
                value={tier.ratePercent}
                onChange={(e) => updateRate(tier.id, Number(e.target.value))}
              />
            </div>
          </Card>
        ))}
      </div>
    </main>
  );
}
'@
New-PageFile -RelativeDir "settings\commission-tiers" -Content $settingsCommissionPage

# ============================================================
# 6. SETTINGS -> PAYMENT GATEWAYS
# ============================================================
$settingsGatewaysPage = @'
"use client";

import { useState } from "react";
import { CreditCard, Pencil, Eye, EyeOff } from "lucide-react";
import { Button, Card, Input, Modal } from "@saachi/ui";

type Gateway = {
  id: string;
  name: string;
  region: string;
  enabled: boolean;
  apiKeyMasked: string;
};

const INITIAL_GATEWAYS: Gateway[] = [
  { id: "stripe", name: "Stripe", region: "International", enabled: true, apiKeyMasked: "sk_live_••••••••4f21" },
  { id: "paypal", name: "PayPal", region: "International", enabled: true, apiKeyMasked: "client_••••••••a9e0" },
  { id: "easypaisa", name: "Easypaisa", region: "Pakistan", enabled: false, apiKeyMasked: "not configured" },
  { id: "jazzcash", name: "JazzCash", region: "Pakistan", enabled: false, apiKeyMasked: "not configured" },
  { id: "bank_transfer", name: "Bank Transfer", region: "Pakistan", enabled: true, apiKeyMasked: "manual - no key" }
];

export default function PaymentGatewayConfigurationPage() {
  const [gateways, setGateways] = useState(INITIAL_GATEWAYS);
  const [editing, setEditing] = useState<Gateway | null>(null);
  const [newKey, setNewKey] = useState("");
  const [showKey, setShowKey] = useState(false);

  const toggleEnabled = (id: string) => {
    setGateways((prev) => prev.map((g) => (g.id === id ? { ...g, enabled: !g.enabled } : g)));
  };

  const openEdit = (gateway: Gateway) => {
    setEditing(gateway);
    setNewKey("");
    setShowKey(false);
  };

  const handleSaveKey = () => {
    if (!editing || !newKey.trim()) return;
    const masked = `••••••••${newKey.trim().slice(-4)}`;
    setGateways((prev) => prev.map((g) => (g.id === editing.id ? { ...g, apiKeyMasked: masked } : g)));
    setEditing(null);
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <CreditCard size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Payment Gateway Configuration</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Enable gateways and manage API keys (masked at rest).</p>
        </div>
      </div>

      <div className="flex flex-col gap-3">
        {gateways.map((gateway) => (
          <Card key={gateway.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <div className="flex items-center gap-2.5">
                <p className="text-[14px] font-semibold text-ink">{gateway.name}</p>
                <span className="rounded-full border border-line-strong px-2 py-0.5 text-[11px] text-ink-soft">{gateway.region}</span>
              </div>
              <p className="mt-1 font-mono text-[12.5px] text-ink-soft">{gateway.apiKeyMasked}</p>
            </div>
            <div className="flex shrink-0 items-center gap-3">
              <button
                type="button"
                onClick={() => toggleEnabled(gateway.id)}
                className={`relative h-6 w-11 shrink-0 rounded-full transition-colors duration-150 ease-out ${
                  gateway.enabled ? "bg-ink" : "bg-paper-dim"
                }`}
              >
                <span
                  className={`absolute top-0.5 h-5 w-5 rounded-full bg-paper transition-transform duration-150 ease-out ${
                    gateway.enabled ? "translate-x-[22px]" : "translate-x-0.5"
                  }`}
                />
              </button>
              <button
                type="button"
                onClick={() => openEdit(gateway)}
                className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
              >
                <Pencil size={14} strokeWidth={1.75} />
              </button>
            </div>
          </Card>
        ))}
      </div>

      <Modal
        open={Boolean(editing)}
        onClose={() => setEditing(null)}
        title={`Update API key - ${editing?.name ?? ""}`}
        footer={
          <>
            <Button variant="ghost" onClick={() => setEditing(null)}>Cancel</Button>
            <Button onClick={handleSaveKey} disabled={!newKey.trim()}>Save key</Button>
          </>
        }
      >
        <div className="relative">
          <Input
            label="New API key / secret"
            type={showKey ? "text" : "password"}
            value={newKey}
            onChange={(e) => setNewKey(e.target.value)}
            placeholder="Paste the new secret key"
          />
          <button
            type="button"
            onClick={() => setShowKey((v) => !v)}
            className="absolute right-3 top-[34px] text-ink-soft hover:text-ink"
          >
            {showKey ? <EyeOff size={15} strokeWidth={1.75} /> : <Eye size={15} strokeWidth={1.75} />}
          </button>
        </div>
      </Modal>
    </main>
  );
}
'@
New-PageFile -RelativeDir "settings\payment-gateways" -Content $settingsGatewaysPage

# ============================================================
# 7. SETTINGS -> LEGAL DOCUMENTS
# ============================================================
$settingsLegalPage = @'
"use client";

import { useState } from "react";
import { ScrollText, Pencil, History } from "lucide-react";
import { Button, Card, Textarea, Modal } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

type LegalDoc = {
  id: string;
  title: string;
  version: string;
  updatedAt: string;
  content: string;
};

const INITIAL_DOCS: LegalDoc[] = [
  { id: "terms", title: "Terms & Conditions", version: "v1.0", updatedAt: "2026-06-01T00:00:00Z", content: "Draft pending client legal counsel review." },
  { id: "privacy", title: "Privacy Policy", version: "v1.0", updatedAt: "2026-06-01T00:00:00Z", content: "Draft pending client legal counsel review." },
  { id: "refund", title: "Refund Policy", version: "v1.0", updatedAt: "2026-06-01T00:00:00Z", content: "7-day / 30% completion threshold refund window - to be finalized." },
  { id: "instructor_agreement", title: "Instructor Agreement", version: "v1.0", updatedAt: "2026-06-01T00:00:00Z", content: "Draft pending client legal counsel review." }
];

export default function LegalDocumentManagementPage() {
  const [docs, setDocs] = useState(INITIAL_DOCS);
  const [editing, setEditing] = useState<LegalDoc | null>(null);
  const [draft, setDraft] = useState("");

  const openEdit = (doc: LegalDoc) => {
    setEditing(doc);
    setDraft(doc.content);
  };

  const handlePublish = () => {
    if (!editing) return;
    const [major, minor] = editing.version.replace("v", "").split(".").map(Number);
    const nextVersion = `v${major}.${minor + 1}`;
    setDocs((prev) =>
      prev.map((d) =>
        d.id === editing.id ? { ...d, content: draft, version: nextVersion, updatedAt: new Date().toISOString() } : d
      )
    );
    setEditing(null);
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <ScrollText size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Legal Document Management</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Versioned editor for Terms, Privacy, Refund Policy, and Instructor Agreement.</p>
        </div>
      </div>

      <div className="flex flex-col gap-3">
        {docs.map((doc) => (
          <Card key={doc.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <div className="flex items-center gap-2.5">
                <p className="text-[14px] font-semibold text-ink">{doc.title}</p>
                <span className="rounded-full border border-line-strong px-2 py-0.5 font-mono text-[11px] text-ink-soft">{doc.version}</span>
              </div>
              <p className="mt-1 flex items-center gap-1.5 text-[12px] text-ink-soft">
                <History size={12} strokeWidth={1.75} /> Last updated {formatDate(doc.updatedAt)}
              </p>
            </div>
            <Button size="sm" variant="secondary" onClick={() => openEdit(doc)}>
              <Pencil size={14} strokeWidth={1.75} /> Edit
            </Button>
          </Card>
        ))}
      </div>

      <Modal
        open={Boolean(editing)}
        onClose={() => setEditing(null)}
        title={`Edit - ${editing?.title ?? ""}`}
        size="lg"
        footer={
          <>
            <Button variant="ghost" onClick={() => setEditing(null)}>Cancel</Button>
            <Button onClick={handlePublish}>Publish new version</Button>
          </>
        }
      >
        <Textarea label="Document content" rows={12} value={draft} onChange={(e) => setDraft(e.target.value)} />
      </Modal>
    </main>
  );
}
'@
New-PageFile -RelativeDir "settings\legal-documents" -Content $settingsLegalPage

# ============================================================
# 8. SETTINGS -> ROLES & PERMISSIONS
# ============================================================
$settingsRolesPage = @'
"use client";

import { useState } from "react";
import { ShieldCheck, Plus, Check, X } from "lucide-react";
import { Button, Card, Input, Select, Modal, Badge } from "@saachi/ui";

type StaffRole = "super_admin" | "admin" | "finance_officer" | "support_officer";

type StaffAccount = {
  id: string;
  name: string;
  email: string;
  role: StaffRole;
};

const ROLE_OPTIONS = [
  { label: "Super Admin", value: "super_admin" },
  { label: "Admin", value: "admin" },
  { label: "Finance Officer", value: "finance_officer" },
  { label: "Support Officer", value: "support_officer" }
];

const ROLE_LABEL: Record<StaffRole, string> = {
  super_admin: "Super Admin",
  admin: "Admin",
  finance_officer: "Finance Officer",
  support_officer: "Support Officer"
};

const PERMISSION_MATRIX: { capability: string; roles: Record<StaffRole, boolean> }[] = [
  { capability: "Manage internal admin accounts", roles: { super_admin: true, admin: false, finance_officer: false, support_officer: false } },
  { capability: "Approve/reject courses", roles: { super_admin: true, admin: true, finance_officer: false, support_officer: false } },
  { capability: "Process payouts", roles: { super_admin: true, admin: true, finance_officer: true, support_officer: false } },
  { capability: "Issue refunds", roles: { super_admin: true, admin: true, finance_officer: true, support_officer: false } },
  { capability: "Ban/suspend users", roles: { super_admin: true, admin: true, finance_officer: false, support_officer: true } },
  { capability: "Handle support tickets", roles: { super_admin: true, admin: true, finance_officer: false, support_officer: true } },
  { capability: "Configure commission rates", roles: { super_admin: true, admin: false, finance_officer: false, support_officer: false } },
  { capability: "View financial reports", roles: { super_admin: true, admin: true, finance_officer: true, support_officer: false } },
  { capability: "Configure payment gateways", roles: { super_admin: true, admin: false, finance_officer: false, support_officer: false } }
];

const INITIAL_STAFF: StaffAccount[] = [
  { id: "1", name: "Abdul Rehman Irfan", email: "abdulrehman@saachi.ai", role: "super_admin" },
  { id: "2", name: "Finance Desk", email: "finance@saachi.ai", role: "finance_officer" },
  { id: "3", name: "Support Desk", email: "support@saachi.ai", role: "support_officer" }
];

export default function RolesPermissionsPage() {
  const [staff, setStaff] = useState(INITIAL_STAFF);
  const [showCreate, setShowCreate] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [role, setRole] = useState<StaffRole>("support_officer");

  const handleCreate = () => {
    if (!name.trim() || !email.trim()) return;
    setStaff((prev) => [...prev, { id: String(Date.now()), name: name.trim(), email: email.trim(), role }]);
    setShowCreate(false);
    setName("");
    setEmail("");
    setRole("support_officer");
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <ShieldCheck size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Roles & Permissions</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Internal staff accounts and their permission scope.</p>
          </div>
        </div>
        <Button size="sm" onClick={() => setShowCreate(true)}>
          <Plus size={14} strokeWidth={1.75} /> New staff account
        </Button>
      </div>

      <div className="mb-8 flex flex-col gap-3">
        {staff.map((account) => (
          <Card key={account.id} className="flex items-center justify-between gap-4 p-4">
            <div>
              <p className="text-[14px] font-semibold text-ink">{account.name}</p>
              <p className="mt-0.5 text-[12.5px] text-ink-soft">{account.email}</p>
            </div>
            <Badge>{ROLE_LABEL[account.role]}</Badge>
          </Card>
        ))}
      </div>

      <p className="mb-3 text-[14px] font-semibold text-ink">Permission matrix</p>
      <div className="overflow-x-auto rounded-card border border-line bg-card">
        <table className="w-full min-w-[720px] border-collapse text-[13px]">
          <thead>
            <tr className="border-b border-line text-left text-ink-soft">
              <th className="px-4 py-3 font-medium">Capability</th>
              <th className="px-4 py-3 font-medium">Super Admin</th>
              <th className="px-4 py-3 font-medium">Admin</th>
              <th className="px-4 py-3 font-medium">Finance Officer</th>
              <th className="px-4 py-3 font-medium">Support Officer</th>
            </tr>
          </thead>
          <tbody>
            {PERMISSION_MATRIX.map((row) => (
              <tr key={row.capability} className="border-b border-line last:border-0">
                <td className="px-4 py-3 font-medium text-ink">{row.capability}</td>
                {(["super_admin", "admin", "finance_officer", "support_officer"] as StaffRole[]).map((r) => (
                  <td key={r} className="px-4 py-3">
                    {row.roles[r] ? (
                      <Check size={15} strokeWidth={2} className="text-success" />
                    ) : (
                      <X size={15} strokeWidth={2} className="text-ink-soft/40" />
                    )}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Modal
        open={showCreate}
        onClose={() => setShowCreate(false)}
        title="New staff account"
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowCreate(false)}>Cancel</Button>
            <Button onClick={handleCreate} disabled={!name.trim() || !email.trim()}>Create account</Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input label="Full name" value={name} onChange={(e) => setName(e.target.value)} />
          <Input label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <Select label="Role" options={ROLE_OPTIONS} value={role} onChange={(e) => setRole(e.target.value as StaffRole)} />
        </div>
      </Modal>
    </main>
  );
}
'@
New-PageFile -RelativeDir "settings\roles" -Content $settingsRolesPage

# ============================================================
# 9. SYSTEM -> AUDIT LOG
# ============================================================
$auditLogPage = @'
"use client";

import { useMemo, useState } from "react";
import { Search, History } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable, Select } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

type AuditEntry = {
  id: string;
  actorName: string;
  actorRole: string;
  action: string;
  target: string;
  module: string;
  createdAt: string;
};

const MODULE_OPTIONS = [
  { label: "Users", value: "users" },
  { label: "Courses", value: "courses" },
  { label: "Finance", value: "finance" },
  { label: "Marketing", value: "marketing" },
  { label: "Settings", value: "settings" }
];

const AUDIT_LOG: AuditEntry[] = [
  { id: "log_1", actorName: "Abdul Rehman Irfan", actorRole: "Super Admin", action: "Approved payout batch", target: "PAYOUT-2026-0912", module: "finance", createdAt: "2026-08-06T14:20:00Z" },
  { id: "log_2", actorName: "Support Desk", actorRole: "Support Officer", action: "Resolved ticket", target: "TCK-4471", module: "users", createdAt: "2026-08-06T11:05:00Z" },
  { id: "log_3", actorName: "Finance Desk", actorRole: "Finance Officer", action: "Approved refund", target: "TXN-88213", module: "finance", createdAt: "2026-08-05T18:42:00Z" },
  { id: "log_4", actorName: "Abdul Rehman Irfan", actorRole: "Super Admin", action: "Updated commission tier", target: "Verified Instructor -> 25%", module: "settings", createdAt: "2026-08-05T09:15:00Z" },
  { id: "log_5", actorName: "Abdul Rehman Irfan", actorRole: "Super Admin", action: "Published homepage banner", target: "Founding Instructor Spots Open", module: "marketing", createdAt: "2026-08-04T16:30:00Z" },
  { id: "log_6", actorName: "Support Desk", actorRole: "Support Officer", action: "Suspended user account", target: "user_9910", module: "users", createdAt: "2026-08-03T10:02:00Z" },
  { id: "log_7", actorName: "Abdul Rehman Irfan", actorRole: "Super Admin", action: "Approved course for publish", target: "AI Automation with n8n", module: "courses", createdAt: "2026-08-02T13:48:00Z" }
];

export default function AuditLogViewerPage() {
  const [search, setSearch] = useState("");
  const [moduleFilter, setModuleFilter] = useState("");

  const filtered = useMemo(() => {
    return AUDIT_LOG.filter((entry) => {
      const matchesSearch =
        !search ||
        entry.actorName.toLowerCase().includes(search.toLowerCase()) ||
        entry.action.toLowerCase().includes(search.toLowerCase()) ||
        entry.target.toLowerCase().includes(search.toLowerCase());
      const matchesModule = !moduleFilter || entry.module === moduleFilter;
      return matchesSearch && matchesModule;
    });
  }, [search, moduleFilter]);

  const columns = useMemo<ColumnDef<AuditEntry, any>[]>(
    () => [
      {
        header: "Actor",
        accessorKey: "actorName",
        cell: ({ row }) => (
          <div>
            <div className="font-medium text-ink">{row.original.actorName}</div>
            <div className="text-[12px] text-ink-soft">{row.original.actorRole}</div>
          </div>
        )
      },
      { header: "Action", accessorKey: "action", cell: ({ getValue }) => <span className="text-ink">{getValue()}</span> },
      { header: "Target", accessorKey: "target", cell: ({ getValue }) => <span className="font-mono text-[12.5px] text-ink-soft">{getValue()}</span> },
      { header: "Module", accessorKey: "module", cell: ({ getValue }) => <span className="capitalize text-ink-soft">{getValue() as string}</span> },
      { header: "Timestamp", accessorKey: "createdAt", cell: ({ getValue }) => <span className="text-ink-soft">{formatDate(getValue() as string)}</span> }
    ],
    []
  );

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <History size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Audit Log</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Searchable system-wide record of internal staff actions.</p>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={filtered}
        isLoading={false}
        emptyTitle="No log entries found"
        emptyDescription="Try adjusting your search or filters."
        toolbar={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by actor, action, or target"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All modules" options={MODULE_OPTIONS} value={moduleFilter} onChange={(e) => setModuleFilter(e.target.value)} />
            </div>
          </div>
        }
      />
    </main>
  );
}
'@
New-PageFile -RelativeDir "logs\audit" -Content $auditLogPage

# ============================================================
# 10. FIX: USERS -> [id] DETAIL (previously corrupt/empty)
# ============================================================
$userDetailPage = @'
"use client";

import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Ban, ShieldCheck, History } from "lucide-react";
import {
  useAdminUserDetail,
  useAdminUserActivity,
  useAdminUserAudit,
  useUpdateUserStatus,
  type AdminUser
} from "@saachi/api-client";
import { Button, Card, StatusPill, Shimmer, EmptyState } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

const STATUS_TONE: Record<AdminUser["status"], "success" | "warning" | "error" | "info"> = {
  active: "success",
  suspended: "warning",
  banned: "error",
  pending: "info"
};

export default function AdminUserDetailPage() {
  const router = useRouter();
  const params = useParams<{ id: string }>();
  const userId = params.id;

  const { data: user, isLoading } = useAdminUserDetail(userId);
  const { data: activity, isLoading: activityLoading } = useAdminUserActivity(userId);
  const { data: audit, isLoading: auditLoading } = useAdminUserAudit(userId);
  const updateStatus = useUpdateUserStatus();

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <Shimmer className="mb-6 h-8 w-48" />
        <Shimmer className="h-40 w-full rounded-card" />
      </main>
    );
  }

  if (!user) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <EmptyState title="User not found" description="This account may have been removed." />
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/users")}
        className="mb-5 flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to users
      </button>

      <Card className="mb-6 flex flex-col gap-4 p-6 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-4">
          <div className="flex h-14 w-14 shrink-0 items-center justify-center overflow-hidden rounded-full border border-line bg-paper-dim text-[18px] font-semibold text-ink-soft">
            {user.avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={user.avatarUrl} alt={user.fullName} className="h-full w-full object-cover" />
            ) : (
              user.fullName.charAt(0)
            )}
          </div>
          <div>
            <div className="flex items-center gap-2.5">
              <h1 className="text-[19px] font-semibold text-ink">{user.fullName}</h1>
              <StatusPill label={user.status} tone={STATUS_TONE[user.status]} />
            </div>
            <p className="mt-0.5 text-[13px] text-ink-soft">{user.email}</p>
            <p className="mt-0.5 text-[12px] capitalize text-ink-soft">{user.role} - joined {formatDate(user.joinedAt)}</p>
          </div>
        </div>
        <div className="flex shrink-0 gap-2">
          {user.status !== "suspended" && (
            <Button size="sm" variant="secondary" onClick={() => updateStatus.mutate({ id: userId, status: "suspended" })}>
              <Ban size={14} strokeWidth={1.75} /> Suspend
            </Button>
          )}
          {user.status !== "active" && (
            <Button size="sm" onClick={() => updateStatus.mutate({ id: userId, status: "active" })}>
              <ShieldCheck size={14} strokeWidth={1.75} /> Reactivate
            </Button>
          )}
        </div>
      </Card>

      <div className="mb-6">
        <p className="mb-3 text-[14px] font-semibold text-ink">Recent activity</p>
        {activityLoading ? (
          <Shimmer className="h-24 w-full rounded-card" />
        ) : !activity || activity.length === 0 ? (
          <EmptyState title="No activity yet" description="This user has no recorded activity." />
        ) : (
          <Card className="divide-y divide-line p-0">
            {activity.map((item) => (
              <div key={item.id} className="flex items-center justify-between px-5 py-3 text-[13px]">
                <span className="text-ink">{item.description}</span>
                <span className="text-ink-soft">{formatRelativeTime(item.createdAt)}</span>
              </div>
            ))}
          </Card>
        )}
      </div>

      <div>
        <p className="mb-3 flex items-center gap-1.5 text-[14px] font-semibold text-ink">
          <History size={14} strokeWidth={1.75} /> Audit trail
        </p>
        {auditLoading ? (
          <Shimmer className="h-24 w-full rounded-card" />
        ) : !audit || audit.length === 0 ? (
          <EmptyState title="No audit entries" description="No admin actions recorded for this account." />
        ) : (
          <Card className="divide-y divide-line p-0">
            {audit.map((entry) => (
              <div key={entry.id} className="flex items-center justify-between px-5 py-3 text-[13px]">
                <div>
                  <span className="text-ink">{entry.action}</span>
                  <span className="ml-2 text-[12px] text-ink-soft">by {entry.actorName}</span>
                </div>
                <span className="text-ink-soft">{formatDate(entry.createdAt)}</span>
              </div>
            ))}
          </Card>
        )}
      </div>
    </main>
  );
}
'@
New-PageFile -RelativeDir "users\[id]" -Content $userDetailPage

# ============================================================
# 11. FIX: SUPPORT/TICKETS -> [id] DETAIL (previously corrupt/empty)
# ============================================================
$ticketDetailPage = @'
"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Send, CheckCircle2, UserPlus } from "lucide-react";
import {
  useAdminTicketDetail,
  useAssignTicket,
  useAddTicketMessage,
  useUpdateTicketStatus,
  type SupportTicket
} from "@saachi/api-client";
import { Button, Card, Textarea, StatusPill, Shimmer, EmptyState } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const STATUS_TONE: Record<SupportTicket["status"], "warning" | "info" | "success" | "neutral"> = {
  open: "warning",
  in_progress: "info",
  resolved: "success",
  closed: "neutral"
};

const CANNED_RESPONSES = [
  "Thanks for reaching out - we're looking into this and will follow up shortly.",
  "This has been resolved. Please let us know if the issue persists.",
  "Could you share a screenshot or more detail so we can investigate further?"
];

export default function AdminTicketDetailPage() {
  const router = useRouter();
  const params = useParams<{ id: string }>();
  const ticketId = params.id;

  const { data: ticket, isLoading } = useAdminTicketDetail(ticketId);
  const assignTicket = useAssignTicket();
  const addMessage = useAddTicketMessage();
  const updateStatus = useUpdateTicketStatus();

  const [reply, setReply] = useState("");
  const [internalNote, setInternalNote] = useState("");

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <Shimmer className="mb-6 h-8 w-48" />
        <Shimmer className="h-64 w-full rounded-card" />
      </main>
    );
  }

  if (!ticket) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <EmptyState title="Ticket not found" description="This ticket may have been removed." />
      </main>
    );
  }

  const handleSendReply = () => {
    if (!reply.trim()) return;
    addMessage.mutate({ ticketId, body: reply.trim(), internal: false });
    setReply("");
  };

  const handleAddNote = () => {
    if (!internalNote.trim()) return;
    addMessage.mutate({ ticketId, body: internalNote.trim(), internal: true });
    setInternalNote("");
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/support/tickets")}
        className="mb-5 flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to queue
      </button>

      <Card className="mb-6 flex flex-col gap-3 p-6">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <div className="flex items-center gap-2.5">
              <h1 className="text-[18px] font-semibold text-ink">{ticket.subject}</h1>
              <StatusPill label={ticket.status.replace("_", " ")} tone={STATUS_TONE[ticket.status]} />
            </div>
            <p className="mt-1 text-[12.5px] text-ink-soft">
              {ticket.requesterName} - {ticket.category} - opened {formatRelativeTime(ticket.createdAt)}
            </p>
          </div>
          <div className="flex gap-2">
            <Button size="sm" variant="secondary" onClick={() => assignTicket.mutate({ id: ticketId, assignee: "me" })}>
              <UserPlus size={14} strokeWidth={1.75} /> {ticket.assignedTo ? ticket.assignedTo : "Assign to me"}
            </Button>
            {ticket.status !== "resolved" && (
              <Button size="sm" onClick={() => updateStatus.mutate({ id: ticketId, status: "resolved" })} disabled={updateStatus.isPending}>
                <CheckCircle2 size={14} strokeWidth={1.75} /> Resolve
              </Button>
            )}
          </div>
        </div>
      </Card>

      <div className="mb-6">
        <p className="mb-3 text-[14px] font-semibold text-ink">Conversation</p>
        <Card className="divide-y divide-line p-0">
          {(ticket.messages ?? []).map((msg) => (
            <div key={msg.id} className={`px-5 py-4 ${msg.internal ? "bg-warning-tint" : ""}`}>
              <div className="mb-1 flex items-center justify-between">
                <span className="text-[13px] font-semibold text-ink">
                  {msg.authorName} {msg.internal && <span className="ml-1.5 text-[11px] font-medium text-warning">Internal note</span>}
                </span>
                <span className="text-[12px] text-ink-soft">{formatRelativeTime(msg.createdAt)}</span>
              </div>
              <p className="text-[13.5px] leading-relaxed text-ink-soft">{msg.body}</p>
            </div>
          ))}
        </Card>
      </div>

      <div className="mb-6">
        <p className="mb-2 text-[14px] font-semibold text-ink">Reply to requester</p>
        <Textarea rows={4} value={reply} onChange={(e) => setReply(e.target.value)} placeholder="Type a reply..." />
        <div className="mt-2 flex flex-wrap items-center justify-between gap-2">
          <div className="flex flex-wrap gap-1.5">
            {CANNED_RESPONSES.map((canned, i) => (
              <button
                key={i}
                type="button"
                onClick={() => setReply(canned)}
                className="rounded-full border border-line-strong px-3 py-1 text-[11.5px] text-ink-soft hover:border-ink hover:text-ink"
              >
                Canned reply {i + 1}
              </button>
            ))}
          </div>
          <Button size="sm" onClick={handleSendReply} disabled={!reply.trim() || addMessage.isPending}>
            <Send size={14} strokeWidth={1.75} /> Send reply
          </Button>
        </div>
      </div>

      <div>
        <p className="mb-2 text-[14px] font-semibold text-ink">Internal note</p>
        <Textarea rows={3} value={internalNote} onChange={(e) => setInternalNote(e.target.value)} placeholder="Visible to staff only..." />
        <div className="mt-2 flex justify-end">
          <Button size="sm" variant="secondary" onClick={handleAddNote} disabled={!internalNote.trim() || addMessage.isPending}>
            Add note
          </Button>
        </div>
      </div>
    </main>
  );
}
'@
New-PageFile -RelativeDir "support\tickets\[id]" -Content $ticketDetailPage

Write-Host ""
Write-Host "=== SAARE 11 FILES BAN GAYE (9 naye + 2 fixed) ===" -ForegroundColor Magenta
Write-Host "Ab type-check chalayein: pnpm --filter admin type-check" -ForegroundColor Yellow