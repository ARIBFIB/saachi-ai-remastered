<#
================================================================================
  create-pricing-page.ps1
  Scaffolds the "Pricing & Plans" page for apps/web (SAI2).

  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

  Notes:
  - Colors use CSS variables from lib/design-system/tokens.ts so theme
    changes stay driven by tokens.ts.
  - Reuses existing Header and DetailFooter components for consistency.
================================================================================
#>

$ErrorActionPreference = "Stop"

$webRoot = Join-Path $PSScriptRoot "apps\web"
if (-not (Test-Path $webRoot)) {
    Write-Error "Could not find apps\web under $PSScriptRoot. Run this script from the SAI2 repo root."
}

function New-Dir($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

function Write-File($path, [string]$content) {
    New-Dir (Split-Path $path -Parent)
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
    Write-Host "  [written] $path"
}

Write-Host "`nScaffolding Pricing & Plans page..." -ForegroundColor Cyan

# ------------------------------------------------------------------------
# 1. components/pricing/BillingToggle.tsx
# ------------------------------------------------------------------------
$billingToggle = @'
"use client";

import { useState } from "react";

export type BillingCycle = "monthly" | "annually";

interface BillingToggleProps {
  onChange?: (cycle: BillingCycle) => void;
}

export function BillingToggle({ onChange }: BillingToggleProps) {
  const [cycle, setCycle] = useState<BillingCycle>("monthly");

  function toggle() {
    const next = cycle === "monthly" ? "annually" : "monthly";
    setCycle(next);
    onChange?.(next);
  }

  const isAnnual = cycle === "annually";

  return (
    <div className="flex items-center justify-center gap-4 pt-4">
      <span className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">Monthly</span>

      <button
        type="button"
        role="switch"
        aria-checked={isAnnual}
        onClick={toggle}
        className={`relative h-6 w-11 shrink-0 rounded-full transition ${
          isAnnual ? "bg-[var(--token-color-primary)]" : "bg-[var(--token-color-border)]"
        }`}
      >
        <span
          className={`absolute top-0.5 h-5 w-5 rounded-full bg-[var(--token-color-surface)] shadow transition-transform ${
            isAnnual ? "translate-x-[22px]" : "translate-x-0.5"
          }`}
        />
      </button>

      <span className="flex items-end gap-1 pb-px">
        <span className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">Annually</span>
        <span className="text-xs font-bold tracking-wide text-[var(--token-color-primary)]">(Save 20%)</span>
      </span>
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "components\pricing\BillingToggle.tsx") $billingToggle

# ------------------------------------------------------------------------
# 2. components/pricing/PricingCard.tsx
# ------------------------------------------------------------------------
$pricingCard = @'
import { CheckCircle2 } from "lucide-react";

export interface PricingCardProps {
  tier: string;
  description: string;
  price: string;
  priceSuffix?: string;
  features: string[];
  ctaLabel: string;
  highlighted?: boolean;
  badge?: string;
}

export function PricingCard({
  tier,
  description,
  price,
  priceSuffix,
  features,
  ctaLabel,
  highlighted = false,
  badge,
}: PricingCardProps) {
  return (
    <div
      className={`relative flex w-96 flex-col justify-between rounded-xl border bg-[var(--token-color-surface)]/90 p-6 backdrop-blur-[6px] ${
        highlighted
          ? "border-[var(--token-color-primary)]/30 shadow-[0px_0px_40px_0px_rgba(79,70,229,0.15)]"
          : "border-[var(--token-color-border)]/60"
      }`}
    >
      {badge && (
        <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-[var(--token-color-primary)] px-3 py-1 text-xs font-bold uppercase tracking-wide text-white">
          {badge}
        </span>
      )}

      <div className="flex flex-col gap-1 pb-6">
        <h3
          className={`text-2xl font-semibold leading-8 ${
            highlighted ? "text-[var(--token-color-primary)]" : "text-[var(--token-color-ink)]"
          }`}
        >
          {tier}
        </h3>
        <p className="text-base text-[var(--token-color-inkSoft)]">{description}</p>

        <div className="flex items-baseline gap-1 pt-5">
          <span className="text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">{price}</span>
          {priceSuffix && <span className="text-base text-[var(--token-color-inkSoft)]">{priceSuffix}</span>}
        </div>

        <ul className="flex flex-col gap-4 pt-5">
          {features.map((feature) => (
            <li key={feature} className="flex items-center gap-2">
              <CheckCircle2 className="h-3 w-3 shrink-0 text-[var(--token-color-primary)]" />
              <span className="text-base text-[var(--token-color-inkSoft)]">{feature}</span>
            </li>
          ))}
        </ul>
      </div>

      <button
        type="button"
        className={`w-full rounded-lg py-3 text-sm font-semibold tracking-wide transition ${
          highlighted
            ? "bg-[var(--token-color-primary)] text-white shadow-md hover:bg-[var(--token-color-primaryHover)]"
            : "border border-[var(--token-color-textMuted)] text-[var(--token-color-ink)] hover:bg-[var(--token-color-surfaceAlt)]"
        }`}
      >
        {ctaLabel}
      </button>
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "components\pricing\PricingCard.tsx") $pricingCard

# ------------------------------------------------------------------------
# 3. components/pricing/FeatureComparisonTable.tsx
# ------------------------------------------------------------------------
$featureComparisonTable = @'
import { X } from "lucide-react";

interface ComparisonRow {
  feature: string;
  free: string | null;
  pro: string;
  enterprise: string;
}

const rows: ComparisonRow[] = [
  { feature: "Course Access", free: "Free only", pro: "Unlimited Premium", enterprise: "Unlimited Premium" },
  { feature: "AI Mentorship", free: null, pro: "1-on-1 Sessions", enterprise: "Priority Scheduling" },
  { feature: "Analytics", free: "Basic", pro: "Detailed", enterprise: "Custom Organization" },
  { feature: "Support", free: "Community", pro: "Priority Email", enterprise: "24/7 Dedicated" },
];

export function FeatureComparisonTable() {
  return (
    <section className="w-full overflow-hidden rounded-xl border border-[var(--token-color-border)] bg-[var(--token-color-surface)] p-6 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]">
      <h2 className="pb-6 text-center text-3xl font-bold leading-10 text-[var(--token-color-ink)]">
        Compare Features
      </h2>

      <div className="min-w-[800px] overflow-x-auto">
        <div className="grid grid-cols-[1.5fr_1fr_1fr_1fr] border-b border-[var(--token-color-border)]">
          <div className="p-4 text-sm font-medium tracking-wide text-[var(--token-color-inkSoft)]">Feature</div>
          <div className="p-4 text-center text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">Free</div>
          <div className="p-4 text-center text-sm font-bold tracking-wide text-[var(--token-color-primary)]">Pro</div>
          <div className="p-4 text-center text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">Enterprise</div>
        </div>

        {rows.map((row, i) => (
          <div
            key={row.feature}
            className={`grid grid-cols-[1.5fr_1fr_1fr_1fr] ${
              i < rows.length - 1 ? "border-b border-[var(--token-color-border)]/40" : ""
            }`}
          >
            <div className="p-4 text-base text-[var(--token-color-inkSoft)]">{row.feature}</div>
            <div className="flex items-center justify-center p-4 text-center text-base text-[var(--token-color-inkSoft)]">
              {row.free ?? <X className="h-3 w-3 text-[var(--token-color-textMuted)]" />}
            </div>
            <div className="p-4 text-center text-base font-medium text-[var(--token-color-primary)]">{row.pro}</div>
            <div className="p-4 text-center text-base text-[var(--token-color-inkSoft)]">{row.enterprise}</div>
          </div>
        ))}
      </div>
    </section>
  );
}
'@
Write-File (Join-Path $webRoot "components\pricing\FeatureComparisonTable.tsx") $featureComparisonTable

# ------------------------------------------------------------------------
# 4. components/pricing/FaqAccordion.tsx
# ------------------------------------------------------------------------
$faqAccordion = @'
"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

interface FaqItem {
  question: string;
  answer: string;
}

const faqs: FaqItem[] = [
  {
    question: "Can I cancel my subscription at any time?",
    answer: "Yes, you can cancel your subscription at any time from your account settings. You'll retain access until the end of your current billing period.",
  },
  {
    question: "Do you offer refunds?",
    answer: "We offer a 30-day money-back guarantee on all paid plans. Contact support if you're not satisfied.",
  },
  {
    question: "Can I switch plans later?",
    answer: "Absolutely. You can upgrade or downgrade your plan at any time, and we'll prorate the difference.",
  },
];

export function FaqAccordion() {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  return (
    <section className="mx-auto flex w-full max-w-[768px] flex-col gap-6">
      <h2 className="text-center text-3xl font-bold leading-10 text-[var(--token-color-ink)]">
        Frequently Asked Questions
      </h2>

      <div className="flex flex-col gap-4">
        {faqs.map((faq, index) => {
          const isOpen = openIndex === index;
          return (
            <div
              key={faq.question}
              className="overflow-hidden rounded-lg border border-[var(--token-color-border)] bg-[var(--token-color-surface)]"
            >
              <button
                type="button"
                onClick={() => setOpenIndex(isOpen ? null : index)}
                className="flex w-full items-center justify-between px-6 py-4 text-left"
              >
                <span className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
                  {faq.question}
                </span>
                <ChevronDown
                  className={`h-3 w-3 shrink-0 text-[var(--token-color-inkSoft)] transition-transform ${
                    isOpen ? "rotate-180" : ""
                  }`}
                />
              </button>

              {isOpen && (
                <div className="border-t border-[var(--token-color-border)]/50 px-6 py-4 text-sm text-[var(--token-color-inkSoft)]">
                  {faq.answer}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </section>
  );
}
'@
Write-File (Join-Path $webRoot "components\pricing\FaqAccordion.tsx") $faqAccordion

# ------------------------------------------------------------------------
# 5. app/(marketing)/pricing/page.tsx
# ------------------------------------------------------------------------
$pricingPage = @'
import { Header } from "@/components/marketing/Header";
import { DetailFooter } from "@/components/course-detail/DetailFooter";
import { BillingToggle } from "@/components/pricing/BillingToggle";
import { PricingCard, type PricingCardProps } from "@/components/pricing/PricingCard";
import { FeatureComparisonTable } from "@/components/pricing/FeatureComparisonTable";
import { FaqAccordion } from "@/components/pricing/FaqAccordion";

const tiers: PricingCardProps[] = [
  {
    tier: "Free",
    description: "For curious learners starting their journey.",
    price: "$0",
    priceSuffix: "/month",
    features: ["Access to free courses", "Community forums", "Basic progress tracking"],
    ctaLabel: "Get Started",
  },
  {
    tier: "Pro",
    description: "For dedicated professionals accelerating their skills.",
    price: "$29",
    priceSuffix: "/month",
    features: [
      "Everything in Free",
      "Unlimited premium courses",
      "1-on-1 AI Mentorship",
      "Certificate of completion",
    ],
    ctaLabel: "Select Pro",
    highlighted: true,
    badge: "Most Popular",
  },
  {
    tier: "Enterprise",
    description: "Custom solutions for teams and organizations.",
    price: "Custom",
    features: [
      "Dedicated success manager",
      "Custom learning paths",
      "Advanced analytics dashboard",
      "SSO & API access",
    ],
    ctaLabel: "Contact Sales",
  },
];

export default function PricingPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-col items-center gap-10 px-6 pb-20 pt-24">
        <section className="flex w-full flex-col items-center gap-1.5">
          <h1 className="text-center text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
            Simple, transparent pricing
          </h1>
          <p className="max-w-[672px] text-center text-lg leading-7 text-[var(--token-color-inkSoft)]">
            Choose the plan that best fits your learning or teaching goals. No hidden fees, ever.
          </p>
          <BillingToggle />
        </section>

        <section className="flex flex-wrap items-start justify-center gap-6 pt-6">
          {tiers.map((tier) => (
            <PricingCard key={tier.tier} {...tier} />
          ))}
        </section>

        <FeatureComparisonTable />

        <FaqAccordion />
      </main>

      <DetailFooter />
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "app\(marketing)\pricing\page.tsx") $pricingPage

Write-Host "`nDone. Pricing page scaffolded at:" -ForegroundColor Green
Write-Host "  apps\web\app\(marketing)\pricing\page.tsx"
Write-Host "`nVisit /pricing after running 'pnpm --filter web dev'.`n"