<#
================================================================================
  create-legal-terms-page.ps1
  Scaffolds the "Terms of Service" legal page for apps/web (SAI2).

  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

  Notes:
  - Colors use CSS variables from lib/design-system/tokens.ts.
  - Reuses existing Header and CompactFooter components for consistency.
  - LegalSidebar is shared -- built so /legal/privacy, /legal/refund, and
    /legal/cookies can reuse it later and get correct active-state
    highlighting automatically (via usePathname).
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

Write-Host "`nScaffolding Terms of Service (legal) page..." -ForegroundColor Cyan

# ------------------------------------------------------------------------
# 1. components/legal/LegalSidebar.tsx
# ------------------------------------------------------------------------
$legalSidebar = @'
"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { ScrollText, Shield, RefreshCcw, Cookie } from "lucide-react";
import type { LucideIcon } from "lucide-react";

interface LegalNavItem {
  label: string;
  href: string;
  icon: LucideIcon;
}

const navItems: LegalNavItem[] = [
  { label: "Terms of Service", href: "/legal/terms", icon: ScrollText },
  { label: "Privacy Policy", href: "/legal/privacy", icon: Shield },
  { label: "Refund Policy", href: "/legal/refund", icon: RefreshCcw },
  { label: "Cookie Policy", href: "/legal/cookies", icon: Cookie },
];

export function LegalSidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-72 shrink-0 self-start rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] px-4 pb-4 pt-3.5 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <h3 className="px-2 pb-4 text-xs font-medium uppercase tracking-wide text-[var(--token-color-inkSoft)]">
        Legal Policies
      </h3>

      <nav className="flex flex-col gap-2">
        {navItems.map(({ label, href, icon: Icon }) => {
          const isActive = pathname === href;
          return (
            <Link
              key={href}
              href={href}
              className={`flex h-12 items-center gap-3 rounded-lg border-l-4 pl-4 pr-2 text-sm font-semibold tracking-wide transition ${
                isActive
                  ? "border-[var(--token-color-primary)] bg-[var(--token-color-primaryTint)] text-[var(--token-color-primary)]"
                  : "border-transparent text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
              }`}
            >
              <Icon className="h-4 w-4 shrink-0" />
              {label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}
'@
Write-File (Join-Path $webRoot "components\legal\LegalSidebar.tsx") $legalSidebar

# ------------------------------------------------------------------------
# 2. components/legal/LegalSection.tsx
# ------------------------------------------------------------------------
$legalSection = @'
import { Info } from "lucide-react";

interface LegalSectionProps {
  heading: string;
  paragraphs?: string[];
  eyebrow?: string;
  listItems?: string[];
  callout?: { title: string; body: string };
}

export function LegalSection({ heading, paragraphs, eyebrow, listItems, callout }: LegalSectionProps) {
  return (
    <section className="flex flex-col gap-3.5">
      <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">{heading}</h2>

      {eyebrow && (
        <p className="text-xs font-semibold uppercase tracking-tight text-[var(--token-color-inkSoft)]">
          {eyebrow}
        </p>
      )}

      {paragraphs?.map((p) => (
        <p key={p.slice(0, 40)} className="text-lg leading-7 text-gray-700">
          {p}
        </p>
      ))}

      {listItems && (
        <ul className="flex list-disc flex-col gap-2 pl-6 text-base leading-6 text-gray-700">
          {listItems.map((item) => (
            <li key={item.slice(0, 40)}>{item}</li>
          ))}
        </ul>
      )}

      {callout && (
        <div className="flex flex-col gap-1 rounded-lg border border-[var(--token-color-border)]/20 bg-[var(--token-color-surfaceAlt)] px-4 py-4">
          <h4 className="flex items-center gap-1.5 text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
            <Info className="h-3 w-3 text-[var(--token-color-primary)]" />
            {callout.title}
          </h4>
          <p className="text-base text-[var(--token-color-inkSoft)]">{callout.body}</p>
        </div>
      )}
    </section>
  );
}
'@
Write-File (Join-Path $webRoot "components\legal\LegalSection.tsx") $legalSection

# ------------------------------------------------------------------------
# 3. app/(marketing)/legal/terms/page.tsx
# ------------------------------------------------------------------------
$termsPage = @'
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { LegalSidebar } from "@/components/legal/LegalSidebar";
import { LegalSection } from "@/components/legal/LegalSection";

export default function TermsOfServicePage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-surface)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] items-start gap-10 px-6 py-10">
        <LegalSidebar />

        <article className="flex flex-1 flex-col gap-10 rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-10 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
          <header className="flex flex-col gap-1 border-b border-[var(--token-color-border)]/30 pb-6">
            <h1 className="text-3xl font-bold text-[var(--token-color-ink)]">Terms of Service</h1>
            <p className="text-base text-[var(--token-color-inkSoft)]">Last Updated: October 24, 2023</p>
          </header>

          <div className="flex flex-col gap-10">
            <LegalSection
              heading="1. Acceptance of Terms"
              paragraphs={[
                "By accessing or using the Saachi AI platform, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not access the service. These terms apply to all visitors, users, instructors, and others who access or use the Service.",
                "We reserve the right to update or change our Terms at any time, and you should check this page periodically. Your continued use of the Service after we post any modifications will constitute your acknowledgment of the modifications and your consent to abide and be bound by the modified Terms.",
              ]}
            />

            <LegalSection
              heading="2. User Accounts"
              paragraphs={[
                "When you create an account with us, you must provide information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service.",
              ]}
              listItems={[
                "You are responsible for safeguarding the password that you use to access the Service.",
                "You agree not to disclose your password to any third party.",
                "You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.",
              ]}
            />

            <LegalSection
              heading="3. Intellectual Property"
              paragraphs={[
                "The Service and its original content (excluding Content provided by users or instructors), features, and functionality are and will remain the exclusive property of Saachi AI and its licensors. The Service is protected by copyright, trademark, and other laws of both the United States and foreign countries.",
              ]}
              callout={{
                title: "Instructor Content Note",
                body: "Instructors retain ownership of the course materials they create and upload to the platform, granting Saachi AI a license to distribute and display said materials as outlined in the Instructor Handbook.",
              }}
            />

            <LegalSection
              heading="4. Acceptable Use Policy"
              paragraphs={["You agree not to use the Service to:"]}
              listItems={[
                "Upload, post, or transmit any content that is unlawful, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, or invasive of another's privacy.",
                "Impersonate any person or entity, or falsely state or otherwise misrepresent your affiliation with a person or entity.",
                "Interfere with or disrupt the Service or servers or networks connected to the Service.",
                "Attempt to gain unauthorized access to any portion of the Service or any other accounts, computer systems, or networks.",
              ]}
            />

            <LegalSection
              heading="5. Limitation of Liability"
              eyebrow="PLEASE READ THIS SECTION CAREFULLY AS IT LIMITS OUR LIABILITY TO YOU."
              paragraphs={[
                "In no event shall Saachi AI, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from (i) your access to or use of or inability to access or use the Service; (ii) any conduct or content of any third party on the Service; (iii) any content obtained from the Service; and (iv) unauthorized access, use or alteration of your transmissions or content, whether based on warranty, contract, tort (including negligence) or any other legal theory, whether or not we have been informed of the possibility of such damage.",
              ]}
            />
          </div>

          <footer className="flex flex-col items-center gap-4 border-t border-[var(--token-color-border)]/30 pt-6">
            <p className="text-center text-base text-[var(--token-color-inkSoft)]">
              Questions about the Terms of Service? Please contact our legal team.
            </p>
            <a
              href="/contact"
              className="rounded-lg border border-[var(--token-color-border)] bg-[var(--token-color-bg)] px-4 py-2 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
            >
              Contact Legal Support
            </a>
          </footer>
        </article>
      </main>

      <CompactFooter />
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "app\(marketing)\legal\terms\page.tsx") $termsPage

Write-Host "`nDone. Terms of Service page scaffolded at:" -ForegroundColor Green
Write-Host "  apps\web\app\(marketing)\legal\terms\page.tsx"
Write-Host "`nNOTE: LegalSidebar links to /legal/privacy, /legal/refund, /legal/cookies -- those pages don't exist yet and will 404 until scaffolded."
Write-Host "`nVisit /legal/terms after running 'pnpm --filter web dev'.`n"