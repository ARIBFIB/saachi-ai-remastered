<#
============================================================================
 Enhance-Pricing.ps1
 Saachi AI (SAI2) - Pricing Tiers Card Redesign
----------------------------------------------------------------------------
 Run from the repo root:
     PS D:\...\SAI2> .\Enhance-Pricing.ps1

 What it does:
   1. Adds apps\web\components\ui\pricing-tiers.tsx (typed, theme-aware
      version of the check-icon / featured-ring pricing card component)
   2. Backs up apps\web\app\(marketing)\_components\PricingTeaser.tsx
      -> .bak-<timestamp>
   3. Rewrites PricingTeaser.tsx to render the new PricingSection component
      with Saachi AI's Basic / Pro / Business plans.

 Safe to re-run: PricingTeaser.tsx is always backed up first.
============================================================================
#>

$ErrorActionPreference = "Stop"

$Root    = $PSScriptRoot
if (-not $Root) { $Root = Get-Location }

$WebApp  = Join-Path $Root "apps\web"
$AppDir  = Join-Path $WebApp "app"
$MktDir  = Join-Path $AppDir "(marketing)"
$MktComp = Join-Path $MktDir "_components"
$UiDir   = Join-Path $WebApp "components\ui"

foreach ($dir in @($MktComp, $UiDir)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
        Write-Host "Created dir: $dir" -ForegroundColor DarkGray
    }
}

function Write-File {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $encoding = New-Object System.Text.UTF8Encoding($false)
    $stream = New-Object System.IO.FileStream($fullPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
    try {
        $writer = New-Object System.IO.StreamWriter($stream, $encoding)
        try {
            $writer.Write($Content)
        }
        finally {
            $writer.Flush()
            $writer.Dispose()
        }
    }
    finally {
        $stream.Dispose()
    }
    Write-Host "Wrote: $fullPath" -ForegroundColor Green
}

# ---------------------------------------------------------------------------
# 0. Backup existing PricingTeaser.tsx (if present)
# ---------------------------------------------------------------------------
$TeaserPath = Join-Path $MktComp "PricingTeaser.tsx"
if (Test-Path $TeaserPath) {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = Join-Path $MktComp "PricingTeaser.tsx.bak-$stamp"
    Copy-Item $TeaserPath $backup
    Write-Host "Backed up PricingTeaser.tsx -> $backup" -ForegroundColor Yellow
} else {
    Write-Host "No existing PricingTeaser.tsx found - creating fresh." -ForegroundColor DarkGray
}

# ---------------------------------------------------------------------------
# 1. components/ui/pricing-tiers.tsx
# ---------------------------------------------------------------------------
$pricingTiers = @'
import type { ReactNode } from "react";
import Link from "next/link";
import { Check } from "lucide-react";
import { cn } from "@/lib/utils";

export type PricingPlan = {
  id: string;
  name: string;
  price: string;
  frequency?: string;
  description: string;
  features: string[];
  buttonText: string;
  buttonLink: string;
  isFeatured?: boolean;
  badge?: string;
};

export type PricingSectionData = {
  title: string;
  subtitle?: string;
  plans: PricingPlan[];
};

function PricingTier({
  name,
  price,
  frequency,
  description,
  features,
  buttonText,
  buttonLink,
  isFeatured = false,
  badge
}: PricingPlan) {
  return (
    <div
      className={cn(
        "flex w-full max-w-sm flex-col rounded-card border p-8 transition-transform duration-200",
        isFeatured
          ? "border-accent-violet/50 bg-gold-tint shadow-xl ring-1 ring-accent-violet/30 md:-translate-y-2"
          : "border-line bg-card shadow-sm hover:-translate-y-1"
      )}
    >
      {isFeatured && badge && (
        <span className="mb-3 w-fit self-center rounded-full bg-gold-dark px-3 py-1 text-[11px] font-bold uppercase tracking-wide text-white">
          {badge}
        </span>
      )}

      <h3 className="text-center font-display text-[22px] font-bold text-ink">{name}</h3>

      <div className="mt-4 flex items-baseline justify-center gap-1">
        <span className="font-mono text-[42px] font-extrabold leading-none text-ink">{price}</span>
        {frequency && <span className="text-[14px] font-medium text-ink-soft">{frequency}</span>}
      </div>

      <p className="mt-4 text-center text-[13.5px] leading-relaxed text-ink-soft">{description}</p>

      <ul className="mt-8 flex flex-1 flex-col gap-3.5">
        {features.map((feature) => (
          <li key={feature} className="flex items-start gap-3 text-[13.5px] text-ink">
            <span
              className={cn(
                "mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full",
                isFeatured ? "bg-accent-violet text-white" : "bg-teal-light text-teal"
              )}
            >
              <Check size={12} strokeWidth={3} />
            </span>
            {feature}
          </li>
        ))}
      </ul>

      <Link
        href={buttonLink}
        className={cn(
          "mt-8 w-full rounded-full py-3 text-center text-[13.5px] font-semibold transition-transform hover:scale-[1.02]",
          isFeatured ? "bg-ink text-paper" : "border border-line text-ink hover:bg-paper-dim"
        )}
      >
        {buttonText}
      </Link>
    </div>
  );
}

export function PricingSection({
  data,
  className,
  header
}: {
  data: PricingSectionData;
  className?: string;
  header?: ReactNode;
}) {
  return (
    <div className={className}>
      {header ?? (
        <div className="mb-10 text-center">
          <h2 className="font-display text-[26px] font-bold text-ink md:text-[32px]">{data.title}</h2>
          {data.subtitle && (
            <p className="mx-auto mt-3 max-w-xl text-[14.5px] text-ink-soft">{data.subtitle}</p>
          )}
        </div>
      )}
      <div className="flex flex-col items-stretch justify-center gap-6 md:flex-row md:items-center">
        {data.plans.map((plan) => (
          <PricingTier key={plan.id} {...plan} />
        ))}
      </div>
    </div>
  );
}

export default PricingSection;
'@
Write-File (Join-Path $UiDir "pricing-tiers.tsx") $pricingTiers

# ---------------------------------------------------------------------------
# 2. app/(marketing)/_components/PricingTeaser.tsx (rewrite)
# ---------------------------------------------------------------------------
$pricingTeaser = @'
import { PricingSection, type PricingSectionData } from "@/components/ui/pricing-tiers";

const PRICING_DATA: PricingSectionData = {
  title: "Simple, transparent pricing",
  subtitle: "Buy individual courses, or go unlimited with Pro.",
  plans: [
    {
      id: "basic",
      name: "Basic",
      price: "Free",
      description: "Browse the marketplace and buy individual courses.",
      features: ["Buy any course individually", "Completion certificates", "Community Q&A access"],
      buttonText: "Get started",
      buttonLink: "/register",
      isFeatured: false
    },
    {
      id: "pro",
      name: "Pro",
      price: "$19",
      frequency: "/ mo",
      description: "Unlimited access to all Standard-tier courses.",
      features: [
        "Unlimited standard courses",
        "Everything in Basic",
        "Priority support",
        "Verified certificates included"
      ],
      buttonText: "Start Pro",
      buttonLink: "/register",
      isFeatured: true,
      badge: "Most popular"
    },
    {
      id: "business",
      name: "Business",
      price: "Custom",
      description: "Bulk seats and team management for organizations.",
      features: [
        "Everything in Pro",
        "Bulk seat licenses",
        "Team completion dashboards",
        "Custom invoicing"
      ],
      buttonText: "Contact sales",
      buttonLink: "/contact",
      isFeatured: false
    }
  ]
};

export function PricingTeaser() {
  return (
    <PricingSection
      data={PRICING_DATA}
      header={
        <>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">{PRICING_DATA.title}</h2>
          <p className="mb-8 text-[14px] text-ink-soft">{PRICING_DATA.subtitle}</p>
        </>
      }
    />
  );
}
'@
Write-File $TeaserPath $pricingTeaser

Write-Host ""
Write-Host "Done. New/updated files:" -ForegroundColor Cyan
Write-Host "  apps\web\components\ui\pricing-tiers.tsx"
Write-Host "  apps\web\app\(marketing)\_components\PricingTeaser.tsx  (backup saved alongside)"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  cd apps\web"
Write-Host "  pnpm dev"