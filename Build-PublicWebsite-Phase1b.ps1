<#
  Build-PublicWebsite-Phase1b.ps1
  ---------------------------------------------------------------------------
  Small remaining Public Website pages:
    /about
    /contact
    /pricing
    /legal/terms
    /legal/privacy
    /legal/refund-policy

  Simple, static, dynamic where it makes sense (contact form is functional
  in-memory, no backend yet). Does NOT touch apps/admin.

  Run from the SAI2 repo root:
    powershell -ExecutionPolicy Bypass -File .\Build-PublicWebsite-Phase1b.ps1
#>

$ErrorActionPreference = "Stop"
$Root = (Get-Location).Path

function Write-Utf8NoBom {
    param([string]$RelativePath, [string]$Content)
    $fullPath = Join-Path $Root $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($fullPath, $Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  wrote $RelativePath"
}

Write-Host "== SAI2 :: Public Website Phase 1b (About/Contact/Pricing/Legal) ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# About
# ---------------------------------------------------------------------------
Write-Utf8NoBom "apps/web/app/(marketing)/about/page.tsx" @'
export default function AboutPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
      <h1 className="mb-4 font-display text-[32px] font-bold text-ink">About Saachi AI</h1>
      <p className="mb-6 text-[16px] leading-relaxed text-ink-soft">
        Saachi AI is not a video platform. It is a skills exchange for the AI era - where you
        don&apos;t just watch AI in action, you learn to build with it, and you can sell what you know.
      </p>

      <h2 className="mb-3 mt-10 font-display text-[22px] font-semibold text-ink">Our mission</h2>
      <p className="mb-6 leading-relaxed text-ink-soft">
        We exist to close the gap between knowing that AI tools exist and knowing how to actually
        use them to produce real, sellable outcomes - websites, apps, automations, marketing
        campaigns, content pipelines, and customer support systems - by connecting people who have
        figured this out with people who want to learn it, inside a safe, paid, structured
        environment.
      </p>

      <h2 className="mb-3 mt-10 font-display text-[22px] font-semibold text-ink">What makes us different</h2>
      <ul className="flex flex-col gap-2 text-ink-soft">
        <li>- Outcome-based learning, not watch-time</li>
        <li>- Practical AI application skills only - no unrelated content</li>
        <li>- Local payment support for the Pakistani market</li>
        <li>- Verified instructors and certified completion</li>
      </ul>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# Contact
# ---------------------------------------------------------------------------
Write-Utf8NoBom "apps/web/app/(marketing)/contact/page.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import { Button, Input, Textarea, EmptyState } from "@saachi/ui";

export default function ContactPage() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend yet. Replace with a real Support/Contact API call.
    setSubmitted(true);
  }

  return (
    <div className="mx-auto max-w-2xl px-4 py-16 md:px-0">
      <h1 className="mb-2 font-display text-[32px] font-bold text-ink">Contact us</h1>
      <p className="mb-8 text-[15px] text-ink-soft">
        Questions about courses, instructor applications, or anything else - send us a message.
      </p>

      {submitted ? (
        <EmptyState
          title="Message sent"
          description="Thanks for reaching out. We typically respond within 1-2 business days."
        />
      ) : (
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input label="Your name" required value={name} onChange={(e) => setName(e.target.value)} />
          <Input
            label="Email"
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <Textarea
            label="Message"
            required
            rows={6}
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="How can we help?"
          />
          <Button type="submit" size="lg" className="self-start">
            Send message
          </Button>
        </form>
      )}

      <div className="mt-10 border-t border-line pt-6 text-[14px] text-ink-soft">
        <p>Support email: support@saachi.ai</p>
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# Pricing
# ---------------------------------------------------------------------------
Write-Utf8NoBom "apps/web/app/(marketing)/pricing/page.tsx" @'
import Link from "next/link";
import { Button, Badge } from "@saachi/ui";

const PLANS = [
  {
    name: "Basic",
    price: "Free",
    description: "Browse the marketplace and buy individual courses.",
    features: ["Buy any course individually", "Course completion certificates", "Community Q&A access"],
    cta: "Get started",
    href: "/register"
  },
  {
    name: "Pro",
    price: "$19/mo",
    description: "Unlimited access to all Standard-tier courses.",
    features: [
      "Unlimited Standard-tier courses",
      "Everything in Basic",
      "Priority support",
      "Verified certificates included"
    ],
    cta: "Start Pro",
    href: "/register",
    highlighted: true
  },
  {
    name: "Business",
    price: "Contact us",
    description: "Bulk seats and team management for organizations.",
    features: [
      "Everything in Pro",
      "Bulk seat licenses",
      "Team completion dashboards",
      "Custom invoicing"
    ],
    cta: "Contact sales",
    href: "/contact"
  }
];

export default function PricingPage() {
  return (
    <div className="mx-auto max-w-6xl px-4 py-16 md:px-8">
      <div className="mb-12 text-center">
        <h1 className="mb-3 font-display text-[32px] font-bold text-ink">Simple, transparent pricing</h1>
        <p className="text-[15px] text-ink-soft">Buy individual courses, or go unlimited with Saachi AI Pro.</p>
      </div>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
        {PLANS.map((plan) => (
          <div
            key={plan.name}
            className={`flex flex-col rounded-card border p-6 ${
              plan.highlighted ? "border-gold-dark/50 bg-gold-tint" : "border-line bg-card"
            }`}
          >
            {plan.highlighted && (
              <Badge variant="gold" className="mb-3 self-start">
                Most popular
              </Badge>
            )}
            <h2 className="font-display text-[20px] font-semibold text-ink">{plan.name}</h2>
            <p className="mt-1 font-mono text-[26px] font-bold text-ink">{plan.price}</p>
            <p className="mt-2 text-[13px] text-ink-soft">{plan.description}</p>

            <ul className="my-6 flex flex-1 flex-col gap-2 text-[14px] text-ink-soft">
              {plan.features.map((f) => (
                <li key={f}>- {f}</li>
              ))}
            </ul>

            <Link href={plan.href}>
              <Button className="w-full" variant={plan.highlighted ? "primary" : "secondary"}>
                {plan.cta}
              </Button>
            </Link>
          </div>
        ))}
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# Legal pages — shared layout via a simple content component
# ---------------------------------------------------------------------------
Write-Utf8NoBom "apps/web/app/(marketing)/legal/terms/page.tsx" @'
export default function TermsPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
      <h1 className="mb-6 font-display text-[30px] font-bold text-ink">Terms &amp; Conditions</h1>
      <div className="flex flex-col gap-5 text-[15px] leading-relaxed text-ink-soft">
        <p>
          These Terms &amp; Conditions govern your use of the Saachi AI platform, including the
          website, admin portal, and any mobile applications (collectively, the &quot;Platform&quot;).
          By creating an account or using the Platform, you agree to these terms.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">1. Accounts</h2>
        <p>
          You are responsible for maintaining the confidentiality of your account credentials and
          for all activity that occurs under your account.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">2. Course content</h2>
        <p>
          Instructors retain ownership of the content they publish, subject to the license granted
          to Saachi AI to host and deliver that content to enrolled learners.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">3. Payments</h2>
        <p>
          All purchases are processed through our supported payment gateways. Platform commission
          rates are disclosed to instructors at the time of course submission.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">4. Prohibited conduct</h2>
        <p>
          Plagiarism, unverifiable claims, and use of copyrighted third-party material without
          rights are not permitted in any course content.
        </p>
        <p className="mt-6 text-[13px] text-ink-soft/70">
          This is placeholder legal text. Replace with content reviewed by legal counsel before
          launch.
        </p>
      </div>
    </div>
  );
}
'@

Write-Utf8NoBom "apps/web/app/(marketing)/legal/privacy/page.tsx" @'
export default function PrivacyPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
      <h1 className="mb-6 font-display text-[30px] font-bold text-ink">Privacy Policy</h1>
      <div className="flex flex-col gap-5 text-[15px] leading-relaxed text-ink-soft">
        <p>
          This Privacy Policy explains how Saachi AI collects, uses, and protects your personal
          information when you use the Platform.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">1. Information we collect</h2>
        <p>
          Account information (name, email), course activity (progress, completions), and payment
          metadata (never raw card details - those are handled by our PCI-DSS-compliant payment
          gateways).
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">2. How we use your data</h2>
        <p>
          To operate your account, process payments, deliver course content, and improve the
          Platform. We do not sell personal data to third parties.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">3. Your rights</h2>
        <p>
          You may request a copy of your data or request account/data deletion at any time from
          your account settings.
        </p>
        <p className="mt-6 text-[13px] text-ink-soft/70">
          This is placeholder legal text. Replace with content reviewed by legal counsel before
          launch.
        </p>
      </div>
    </div>
  );
}
'@

Write-Utf8NoBom "apps/web/app/(marketing)/legal/refund-policy/page.tsx" @'
export default function RefundPolicyPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
      <h1 className="mb-6 font-display text-[30px] font-bold text-ink">Refund Policy</h1>
      <div className="flex flex-col gap-5 text-[15px] leading-relaxed text-ink-soft">
        <p>
          We want you to be satisfied with every course you purchase on Saachi AI. If a course
          doesn&apos;t meet your expectations, you may be eligible for a refund under the terms
          below.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">Eligibility window</h2>
        <p>
          Refund requests must be submitted within 7 days of purchase, and before completing more
          than 30% of the course content.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">How to request a refund</h2>
        <p>
          Go to Order History in your account settings and select &quot;Request refund&quot; on the
          relevant order, or contact support directly.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">Processing time</h2>
        <p>Approved refunds are typically processed within 5-7 business days.</p>
        <p className="mt-6 text-[13px] text-ink-soft/70">
          This is placeholder legal text. Replace with content reviewed by legal counsel before
          launch.
        </p>
      </div>
    </div>
  );
}
'@

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Pages created:"
Write-Host "  /about"
Write-Host "  /contact"
Write-Host "  /pricing"
Write-Host "  /legal/terms"
Write-Host "  /legal/privacy"
Write-Host "  /legal/refund-policy"
Write-Host ""
Write-Host "Now run: pnpm --filter web dev"