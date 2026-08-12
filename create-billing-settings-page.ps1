# ============================================================================
# create-billing-settings-page.ps1
# Creates the Billing & Payments (Subscription) page for the Saachi AI web app.
# Route: /dashboard/settings/billing
# Reuses the shared SettingsNav component (apps/web/components/settings/SettingsNav.tsx)
# created by create-security-settings-page.ps1 -- run that script first if you
# haven't already, otherwise this page's import will fail.
# ============================================================================
# USAGE:
#   Run this from the SAI2 repo root, i.e.:
#   PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2> .\create-billing-settings-page.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

$RepoRoot = (Get-Location).Path

# ----------------------------------------------------------------------------
# Check SettingsNav dependency exists
# ----------------------------------------------------------------------------
$SettingsNavFile = Join-Path $RepoRoot "apps\web\components\settings\SettingsNav.tsx"
if (-not (Test-Path $SettingsNavFile)) {
    Write-Host "[create-billing-settings-page] WARNING: SettingsNav.tsx not found at:" -ForegroundColor Yellow
    Write-Host "  $SettingsNavFile" -ForegroundColor Yellow
    Write-Host "  Run create-security-settings-page.ps1 first, or this page's import will fail." -ForegroundColor Yellow
    Write-Host ""
}

# ----------------------------------------------------------------------------
# Billing Settings page
# ----------------------------------------------------------------------------
$BillingPageDir = Join-Path $RepoRoot "apps\web\app\(learner)\dashboard\settings\billing"
$BillingPageFile = Join-Path $BillingPageDir "page.tsx"

if (-not (Test-Path $BillingPageDir)) {
    New-Item -ItemType Directory -Path $BillingPageDir -Force | Out-Null
    Write-Host "[create-billing-settings-page] Created directory: $BillingPageDir" -ForegroundColor Cyan
}

$BillingPageContent = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button as AntButton, Dropdown, Tag, message } from "antd";
import type { MenuProps } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  Award,
  ArrowUp,
  XCircle,
  Plus,
  CreditCard,
  MoreVertical,
  FileText,
  Download,
} from "lucide-react";
import { SettingsNav } from "@/components/settings/SettingsNav";

// TODO: replace with useBilling() / useSubscription() hooks from @saachi/api-client
interface PaymentMethod {
  id: string;
  brand: "Visa" | "Mastercard";
  last4: string;
  expiry: string;
  isDefault: boolean;
}

interface Invoice {
  id: string;
  invoiceNumber: string;
  date: string;
  amount: number;
}

const initialPaymentMethods: PaymentMethod[] = [
  { id: "pm-1", brand: "Visa", last4: "4242", expiry: "12/25", isDefault: true },
  { id: "pm-2", brand: "Mastercard", last4: "8899", expiry: "08/24", isDefault: false },
];

const invoices: Invoice[] = [
  { id: "inv-1", invoiceNumber: "#INV-2024-09", date: "Sep 15, 2024", amount: 29.0 },
  { id: "inv-2", invoiceNumber: "#INV-2024-08", date: "Aug 15, 2024", amount: 29.0 },
  { id: "inv-3", invoiceNumber: "#INV-2024-07", date: "Jul 15, 2024", amount: 29.0 },
];

const accountSummary = {
  memberSince: "Jan 2023",
  totalSaved: 120.0,
  dataUsedGb: 15,
  dataLimitGb: 50,
};

const currentPlan = {
  name: "Pro Plan",
  status: "Active" as const,
  description: "Premium access to advanced AI learning modules.",
  price: 29.0,
  billingCycle: "month" as const,
  nextPaymentDate: "October 15, 2024",
};

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

export default function BillingSettingsPage() {
  const [paymentMethods, setPaymentMethods] = useState(initialPaymentMethods);

  function handleChangePlan() {
    // TODO: wire to /dashboard/settings/billing/change-plan or a plan-selection modal
    console.log("change plan");
  }

  function handleCancelSubscription() {
    // TODO: wire to useSubscription().cancel() from @saachi/api-client
    console.log("cancel subscription");
  }

  function handleAddPaymentMethod() {
    // TODO: wire to useBilling().addPaymentMethod() -- likely a Stripe Elements modal
    console.log("add payment method");
  }

  function handleSetDefault(id: string) {
    // TODO: wire to useBilling().setDefaultPaymentMethod(id) from @saachi/api-client
    setPaymentMethods((prev) => prev.map((pm) => ({ ...pm, isDefault: pm.id === id })));
    message.success("Default payment method updated.");
  }

  function handleRemovePaymentMethod(id: string) {
    // TODO: wire to useBilling().removePaymentMethod(id) from @saachi/api-client
    setPaymentMethods((prev) => prev.filter((pm) => pm.id !== id));
  }

  function handleDownloadInvoice(invoiceId: string) {
    // TODO: wire to useBilling().downloadInvoice(invoiceId) from @saachi/api-client
    console.log("download invoice", invoiceId);
  }

  function getPaymentMenuItems(pm: PaymentMethod): MenuProps["items"] {
    const items: MenuProps["items"] = [];
    if (!pm.isDefault) {
      items.push({ key: "default", label: "Set as Default", onClick: () => handleSetDefault(pm.id) });
    }
    items.push({
      key: "remove",
      label: "Remove Card",
      danger: true,
      onClick: () => handleRemovePaymentMethod(pm.id),
    });
    return items;
  }

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col justify-between border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex flex-col">
          <div className="flex items-center gap-4 border-b border-[var(--token-color-border)] p-6">
            <span className="relative block h-12 w-12 shrink-0 overflow-hidden rounded-full">
              <Image
                src="https://i.pravatar.cc/96?img=47"
                alt="Learner avatar"
                fill
                sizes="48px"
                className="object-cover"
              />
            </span>
            <div className="flex flex-col">
              <span className="text-lg font-bold" style={{ color: "var(--token-color-ink)" }}>
                Learner Portal
              </span>
              <span
                style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}
              >
                Manage your skills
              </span>
            </div>
          </div>

          <nav className="flex flex-col gap-2 p-4">
            {navItems.map(({ icon: Icon, label, href }) => {
              const isActive = label === "Settings";
              return (
                <Link
                  key={label}
                  href={href}
                  className="flex items-center gap-4 rounded-lg border-l-4 px-4 py-3 text-sm font-semibold tracking-wide transition"
                  style={{
                    borderColor: isActive ? "var(--token-color-primary)" : "transparent",
                    backgroundColor: isActive ? "var(--token-color-primaryTint)" : "transparent",
                    color: isActive ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                  }}
                >
                  <Icon size={18} />
                  {label}
                </Link>
              );
            })}
          </nav>
        </div>

        <div className="border-t border-[var(--token-color-border)] p-4">
          <Link
            href="/support"
            className="flex h-12 items-center gap-4 rounded-lg pl-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surface)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main column */}
      <div className="flex w-full flex-col lg:pl-72">
        <main className="flex-1 px-12 py-12">
          <div className="mx-auto flex w-full max-w-[1280px] flex-col gap-10">
            {/* Header */}
            <div className="flex flex-col gap-1.5">
              <h1 className="text-3xl font-bold leading-10" style={{ color: "var(--token-color-ink)" }}>
                Subscription &amp; Billing
              </h1>
              <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-lg)" }}>
                Manage your payment methods and subscription plan.
              </p>
            </div>

            <div className="flex flex-col gap-10 lg:flex-row lg:items-start">
              <SettingsNav />

              <div className="grid w-full flex-1 grid-cols-1 items-start gap-6 lg:grid-cols-[2fr_1fr]">
                {/* Left column: Current Plan & Payment Methods */}
                <div className="flex flex-col gap-6">
                  {/* Current Plan */}
                  <div
                    className="relative flex flex-col gap-6 overflow-hidden rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
                    style={{ border: "1px solid var(--token-color-border)" }}
                  >
                    <div
                      className="pointer-events-none absolute -right-8 -top-16 h-32 w-32 rounded-bl-full"
                      style={{ backgroundColor: "var(--token-color-primaryTint)" }}
                    />

                    <div className="relative flex items-start justify-between">
                      <div className="flex flex-col gap-1">
                        <div className="flex items-center gap-2">
                          <h2 className="text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                            {currentPlan.name}
                          </h2>
                          <Tag
                            bordered={false}
                            style={{
                              backgroundColor: "var(--token-color-primaryTint)",
                              color: "var(--token-color-primary)",
                              margin: 0,
                            }}
                          >
                            {currentPlan.status}
                          </Tag>
                        </div>
                        <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                          {currentPlan.description}
                        </p>
                      </div>

                      <Award size={28} color="var(--token-color-primary)" />
                    </div>

                    <div className="relative flex flex-col gap-4 sm:flex-row">
                      <div
                        className="flex flex-1 flex-col gap-1 rounded-lg p-4"
                        style={{
                          backgroundColor: "var(--token-color-surfaceAlt)",
                          border: "1px solid color-mix(in srgb, var(--token-color-border) 50%, transparent)",
                        }}
                      >
                        <span
                          className="text-xs font-medium uppercase tracking-wide"
                          style={{ color: "var(--token-color-inkSoft)" }}
                        >
                          Billing Cycle
                        </span>
                        <span className="text-lg font-semibold leading-7" style={{ color: "var(--token-color-ink)" }}>
                          ${currentPlan.price.toFixed(2)} / {currentPlan.billingCycle}
                        </span>
                      </div>

                      <div
                        className="flex flex-1 flex-col gap-1 rounded-lg p-4"
                        style={{
                          backgroundColor: "var(--token-color-surfaceAlt)",
                          border: "1px solid color-mix(in srgb, var(--token-color-border) 50%, transparent)",
                        }}
                      >
                        <span
                          className="text-xs font-medium uppercase tracking-wide"
                          style={{ color: "var(--token-color-inkSoft)" }}
                        >
                          Next Payment
                        </span>
                        <span className="text-lg font-semibold leading-7" style={{ color: "var(--token-color-ink)" }}>
                          {currentPlan.nextPaymentDate}
                        </span>
                      </div>
                    </div>

                    <div
                      className="relative flex items-center justify-between pt-6"
                      style={{ borderTop: "1px solid color-mix(in srgb, var(--token-color-border) 50%, transparent)" }}
                    >
                      <AntButton type="primary" icon={<ArrowUp size={14} />} onClick={handleChangePlan}>
                        Change Plan
                      </AntButton>

                      <button
                        type="button"
                        onClick={handleCancelSubscription}
                        className="flex items-center gap-2 rounded-lg px-4 py-2 text-sm font-semibold tracking-wide"
                        style={{ color: "var(--token-color-error)" }}
                      >
                        <XCircle size={15} />
                        Cancel Subscription
                      </button>
                    </div>
                  </div>

                  {/* Payment Methods */}
                  <div
                    className="flex flex-col gap-6 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
                    style={{ border: "1px solid var(--token-color-border)" }}
                  >
                    <div className="flex items-center justify-between">
                      <h2 className="text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                        Payment Methods
                      </h2>
                      <button
                        type="button"
                        onClick={handleAddPaymentMethod}
                        className="flex items-center gap-1 text-sm font-semibold tracking-wide"
                        style={{ color: "var(--token-color-primary)" }}
                      >
                        <Plus size={15} />
                        Add New
                      </button>
                    </div>

                    <div className="flex flex-col gap-4">
                      {paymentMethods.map((pm) => (
                        <div
                          key={pm.id}
                          className="flex items-center justify-between rounded-lg p-4"
                          style={{
                            backgroundColor: pm.isDefault
                              ? "color-mix(in srgb, var(--token-color-primary) 5%, transparent)"
                              : "var(--token-color-bg)",
                            border: pm.isDefault
                              ? "1px solid var(--token-color-primary)"
                              : "1px solid var(--token-color-border)",
                          }}
                        >
                          <div className="flex items-center gap-4">
                            <span
                              className="flex h-8 w-12 items-center justify-center rounded-sm"
                              style={{
                                backgroundColor: "var(--token-color-surfaceAlt)",
                                border: "1px solid var(--token-color-border)",
                              }}
                            >
                              <CreditCard size={18} color="var(--token-color-inkSoft)" />
                            </span>

                            <div className="flex flex-col">
                              <div className="flex items-center gap-2">
                                <span className="text-base font-semibold leading-6" style={{ color: "var(--token-color-ink)" }}>
                                  {pm.brand} ending in {pm.last4}
                                </span>
                                {pm.isDefault && (
                                  <span
                                    className="rounded-full px-2 py-0.5 text-[10px] font-bold uppercase"
                                    style={{
                                      backgroundColor: "var(--token-color-primaryTint)",
                                      color: "var(--token-color-primary)",
                                    }}
                                  >
                                    Default
                                  </span>
                                )}
                              </div>
                              <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                                Expires {pm.expiry}
                              </span>
                            </div>
                          </div>

                          <Dropdown menu={{ items: getPaymentMenuItems(pm) }} trigger={["click"]}>
                            <button
                              type="button"
                              aria-label="Payment method options"
                              className="flex h-9 w-9 items-center justify-center rounded-full transition hover:bg-[var(--token-color-surfaceAlt)]"
                            >
                              <MoreVertical size={16} color="var(--token-color-inkSoft)" />
                            </button>
                          </Dropdown>
                        </div>
                      ))}

                      {paymentMethods.length === 0 && (
                        <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-sm)" }}>
                          No payment methods on file.
                        </p>
                      )}
                    </div>
                  </div>
                </div>

                {/* Right column: Account Summary & Billing History */}
                <div className="flex flex-col gap-6">
                  {/* Account Summary */}
                  <div
                    className="flex flex-col gap-4 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
                    style={{ border: "1px solid var(--token-color-border)" }}
                  >
                    <h3
                      className="text-sm font-semibold uppercase tracking-wide"
                      style={{ color: "var(--token-color-inkSoft)" }}
                    >
                      Account Summary
                    </h3>

                    <div className="flex flex-col gap-2">
                      <div
                        className="flex items-center justify-between py-2"
                        style={{ borderBottom: "1px solid var(--token-color-border)" }}
                      >
                        <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                          Member since
                        </span>
                        <span className="font-medium" style={{ color: "var(--token-color-ink)" }}>
                          {accountSummary.memberSince}
                        </span>
                      </div>

                      <div
                        className="flex items-center justify-between py-2"
                        style={{ borderBottom: "1px solid var(--token-color-border)" }}
                      >
                        <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                          Total saved
                        </span>
                        <span className="font-medium" style={{ color: "var(--token-color-success)" }}>
                          ${accountSummary.totalSaved.toFixed(2)}
                        </span>
                      </div>

                      <div className="flex items-center justify-between py-2">
                        <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                          Data storage
                        </span>
                        <span className="font-medium" style={{ color: "var(--token-color-ink)" }}>
                          {accountSummary.dataUsedGb}GB / {accountSummary.dataLimitGb}GB
                        </span>
                      </div>
                    </div>
                  </div>

                  {/* Recent Invoices */}
                  <div
                    className="flex flex-col gap-4 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
                    style={{ border: "1px solid var(--token-color-border)" }}
                  >
                    <div className="flex items-center justify-between">
                      <h3 className="text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                        Recent Invoices
                      </h3>
                      <Link
                        href="/dashboard/settings/billing/invoices"
                        className="text-xs font-medium"
                        style={{ color: "var(--token-color-primary)" }}
                      >
                        View All
                      </Link>
                    </div>

                    <div className="flex flex-col">
                      {invoices.map((invoice, idx) => (
                        <div
                          key={invoice.id}
                          className="flex items-center justify-between px-2 py-3"
                          style={
                            idx < invoices.length - 1
                              ? { borderBottom: "1px solid var(--token-color-border)" }
                              : undefined
                          }
                        >
                          <div className="flex items-center gap-2">
                            <FileText size={16} color="var(--token-color-inkSoft)" />
                            <div className="flex flex-col">
                              <span className="text-sm font-semibold tracking-wide" style={{ color: "var(--token-color-ink)" }}>
                                {invoice.date}
                              </span>
                              <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                                {invoice.invoiceNumber}
                              </span>
                            </div>
                          </div>

                          <div className="flex items-center gap-4">
                            <span className="text-base font-medium" style={{ color: "var(--token-color-ink)" }}>
                              ${invoice.amount.toFixed(2)}
                            </span>
                            <button
                              type="button"
                              aria-label={`Download invoice ${invoice.invoiceNumber}`}
                              onClick={() => handleDownloadInvoice(invoice.id)}
                              className="flex h-7 w-7 items-center justify-center rounded-full transition hover:bg-[var(--token-color-surfaceAlt)]"
                            >
                              <Download size={14} color="var(--token-color-inkSoft)" />
                            </button>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}

'@

Write-Utf8NoBom -Path $BillingPageFile -Content $BillingPageContent
Write-Host "[create-billing-settings-page] Written: $BillingPageFile" -ForegroundColor Green

Write-Host ""
Write-Host "Route available at: /dashboard/settings/billing" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. cd apps\web"
Write-Host "  2. pnpm dev"
Write-Host "  3. Visit http://localhost:3000/dashboard/settings/billing"
Write-Host ""
Write-Host "Notes:" -ForegroundColor Yellow
Write-Host "  - Reuses shared SettingsNav.tsx (Billing & Payments auto-highlights via usePathname)."
Write-Host "  - Payment method card has a working antd Dropdown: Set as Default / Remove Card."
Write-Host "  - Setting a new default updates state immediately (optimistic) -- wire the actual"
Write-Host "    API call in handleSetDefault() / handleRemovePaymentMethod()."
Write-Host "  - Change Plan / Cancel Subscription / Add New / Download Invoice are all"
Write-Host "    // TODO stubs -> wire to useBilling() / useSubscription() hooks once added"
Write-Host "    to @saachi/api-client."
Write-Host "  - 'View All' invoices links to /dashboard/settings/billing/invoices -- build"
Write-Host "    that page separately when ready."
Write-Host "  - All colors use var(--token-color-*) from packages/ui design tokens (tokens.ts)."