<#
================================================================================
  create-contact-support-page.ps1
  Scaffolds the "Contact & Support" page for apps/web (SAI2).

  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

  Notes:
  - This page uses a DARK header/footer (bg-zinc-900), unlike the rest of
    the site's light theme. tokens.ts currently has no dark-surface token,
    so the dark chrome uses literal Tailwind zinc/violet classes instead
    of var(--token-color-*). Everything else (form, cards, body content)
    still uses token vars. If you add dark tokens to tokens.ts later,
    swap SupportHeader.tsx / SupportFooter.tsx to use them.
  - This page does NOT reuse the light Header/Footer components, since
    the design calls for a dedicated dark chrome just for this page.
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

Write-Host "`nScaffolding Contact & Support page..." -ForegroundColor Cyan

# ------------------------------------------------------------------------
# 1. components/support/SupportHeader.tsx (dark variant, page-specific)
# ------------------------------------------------------------------------
$supportHeader = @'
import Link from "next/link";
import { Search, ShoppingCart, Bell } from "lucide-react";

export function SupportHeader() {
  return (
    <header className="sticky top-0 z-50 w-full bg-zinc-900 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]">
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        <div className="flex flex-1 items-center gap-6">
          <Link href="/" className="text-2xl font-black text-violet-300">
            Saachi AI
          </Link>

          <div className="relative w-full max-w-96">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[var(--token-color-textMuted)]" />
            <input
              type="text"
              placeholder="Search courses, skills, instructors..."
              className="w-full rounded-none border border-[var(--token-color-border)] bg-[var(--token-color-surface)] py-2.5 pl-10 pr-2 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:outline-none"
            />
          </div>
        </div>

        <nav className="flex items-center gap-6">
          <Link href="/courses" className="text-sm font-semibold tracking-wide text-slate-300 hover:text-white">
            Marketplace
          </Link>
          <Link href="/categories" className="text-sm font-semibold tracking-wide text-slate-300 hover:text-white">
            Categories
          </Link>
        </nav>

        <div className="flex items-center gap-4 pl-6">
          <button aria-label="Cart" className="rounded-full p-2 text-[#BEC6E0] hover:bg-white/10">
            <ShoppingCart className="h-5 w-5" />
          </button>
          <button aria-label="Notifications" className="rounded-full p-2 text-[#BEC6E0] hover:bg-white/10">
            <Bell className="h-5 w-5" />
          </button>
          <Link
            href="/login"
            className="rounded-lg bg-[var(--token-color-primary)] px-4 py-2 text-sm font-semibold tracking-wide text-white hover:bg-[var(--token-color-primaryHover)]"
          >
            Sign In
          </Link>
          <Link href="/settings/profile">
            <span className="block h-8 w-8 overflow-hidden rounded-full border border-[var(--token-color-border)] bg-zinc-200" />
          </Link>
        </div>
      </div>
    </header>
  );
}
'@
Write-File (Join-Path $webRoot "components\support\SupportHeader.tsx") $supportHeader

# ------------------------------------------------------------------------
# 2. components/support/SupportFooter.tsx (dark variant, page-specific)
# ------------------------------------------------------------------------
$supportFooter = @'
import Link from "next/link";

const links = [
  { label: "About Us", href: "/about" },
  { label: "Careers", href: "/careers" },
  { label: "Privacy Policy", href: "/legal/privacy" },
  { label: "Terms of Service", href: "/legal/terms" },
  { label: "Instructor Handbook", href: "/instructor/handbook" },
];

export function SupportFooter() {
  return (
    <footer className="w-full border-t border-[var(--token-color-border)]/20 bg-zinc-900 px-6 py-10">
      <div className="mx-auto flex max-w-[1280px] flex-col justify-between gap-6 sm:flex-row sm:items-start">
        <div className="flex flex-col gap-1">
          <span className="text-base font-bold text-[var(--token-color-primary)]">Saachi AI</span>
          <p className="text-xs font-medium text-zinc-200">
            © {new Date().getFullYear()} Saachi AI Marketplace. Empowering the future of skills.
          </p>
        </div>

        <nav className="flex flex-wrap gap-6">
          {links.map((link) => (
            <Link key={link.label} href={link.href} className="text-base text-zinc-200 hover:text-white">
              {link.label}
            </Link>
          ))}
        </nav>
      </div>
    </footer>
  );
}
'@
Write-File (Join-Path $webRoot "components\support\SupportFooter.tsx") $supportFooter

# ------------------------------------------------------------------------
# 3. components/support/ContactForm.tsx
# ------------------------------------------------------------------------
$contactForm = @'
"use client";

import { useState } from "react";
import { Mail, Send } from "lucide-react";

const subjects = ["Technical Support", "Billing Question", "Instructor Application", "Partnership", "Other"];

export function ContactForm() {
  const [subject, setSubject] = useState(subjects[0]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // TODO: wire to support ticket API (packages/api-client)
    console.log("submit inquiry", { subject });
  }

  return (
    <div className="flex flex-1 flex-col rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-10 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="flex flex-col gap-1 pb-6">
        <h2 className="flex items-center gap-2 text-2xl font-semibold text-[var(--token-color-ink)]">
          <Mail className="h-5 w-4 text-[var(--token-color-primary)]" />
          Send us a Message
        </h2>
        <p className="text-base text-[var(--token-color-inkSoft)]">
          We aim to respond to all inquiries within 24 hours.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col gap-3.5">
        <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2">
          <div className="flex flex-col gap-1">
            <label htmlFor="name" className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
              Full Name
            </label>
            <input
              id="name"
              type="text"
              required
              placeholder="Jane Doe"
              className="border border-[var(--token-color-border)] bg-[var(--token-color-surface)] px-4 py-2.5 text-base text-[var(--token-color-ink)] placeholder:text-[var(--token-color-inkSoft)]/50 focus:outline-none"
            />
          </div>

          <div className="flex flex-col gap-1">
            <label htmlFor="email" className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
              Email Address
            </label>
            <input
              id="email"
              type="email"
              required
              placeholder="jane@example.com"
              className="border border-[var(--token-color-border)] bg-[var(--token-color-surface)] px-4 py-2.5 text-base text-[var(--token-color-ink)] placeholder:text-[var(--token-color-inkSoft)]/50 focus:outline-none"
            />
          </div>
        </div>

        <div className="flex flex-col gap-1">
          <label htmlFor="subject" className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
            Subject
          </label>
          <select
            id="subject"
            value={subject}
            onChange={(e) => setSubject(e.target.value)}
            className="border border-[var(--token-color-border)] bg-[var(--token-color-surface)] px-4 py-2 text-base text-[var(--token-color-ink)] focus:outline-none"
          >
            {subjects.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        </div>

        <div className="flex flex-col gap-1 pb-2.5">
          <label htmlFor="message" className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
            Message
          </label>
          <textarea
            id="message"
            required
            rows={6}
            placeholder="How can we help you today?"
            className="resize-none border border-[var(--token-color-border)] bg-[var(--token-color-surface)] px-4 py-2 text-base text-[var(--token-color-ink)] placeholder:text-[var(--token-color-inkSoft)]/50 focus:outline-none"
          />
        </div>

        <div className="flex justify-end pt-2">
          <button
            type="submit"
            className="flex w-48 items-center justify-center gap-2 rounded-lg bg-[var(--token-color-primary)] py-3 text-sm font-semibold tracking-wide text-white hover:bg-[var(--token-color-primaryHover)]"
          >
            Submit Inquiry
            <Send className="h-3.5 w-4" />
          </button>
        </div>
      </form>
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "components\support\ContactForm.tsx") $contactForm

# ------------------------------------------------------------------------
# 4. components/support/DirectContactCard.tsx
# ------------------------------------------------------------------------
$directContactCard = @'
import { Headset, Phone, Building2 } from "lucide-react";

export function DirectContactCard() {
  return (
    <div className="flex flex-col gap-4 rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-6 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <h3 className="text-2xl font-semibold text-[var(--token-color-ink)]">Direct Contact</h3>

      <div className="flex flex-col gap-6">
        <ContactItem icon={<Headset className="h-5 w-4 text-[var(--token-color-primary)]" />} label="Support Email">
          <a href="mailto:support@saachi.ai" className="text-base text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
            support@saachi.ai
          </a>
        </ContactItem>

        <ContactItem icon={<Phone className="h-5 w-[18px] text-[var(--token-color-primary)]" />} label="Phone Support">
          <p className="text-base text-[var(--token-color-inkSoft)]">+1 (800) 555-0199</p>
          <p className="text-xs font-medium text-gray-500">Mon-Fri, 9am - 6pm EST</p>
        </ContactItem>

        <ContactItem icon={<Building2 className="h-5 w-5 text-[var(--token-color-primary)]" />} label="Headquarters">
          <p className="text-base leading-6 text-[var(--token-color-inkSoft)]">
            100 Innovation Way
            <br />
            Suite 400
            <br />
            San Francisco, CA 94105
          </p>
        </ContactItem>
      </div>
    </div>
  );
}

function ContactItem({
  icon,
  label,
  children,
}: {
  icon: React.ReactNode;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex items-start gap-4">
      <span className="flex h-10 w-9 shrink-0 items-center justify-center rounded bg-[var(--token-color-primaryTint)]">
        {icon}
      </span>
      <div>
        <p className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">{label}</p>
        {children}
      </div>
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "components\support\DirectContactCard.tsx") $directContactCard

# ------------------------------------------------------------------------
# 5. components/support/OfficeMapCard.tsx
# ------------------------------------------------------------------------
$officeMapCard = @'
import { Map } from "lucide-react";

interface OfficeMapCardProps {
  image?: string;
  mapUrl?: string;
}

export function OfficeMapCard({ image, mapUrl = "#" }: OfficeMapCardProps) {
  return (
    <a
      href={mapUrl}
      className="relative block h-48 overflow-hidden rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]"
    >
      <img
        src={image ?? "https://placehold.co/393x190"}
        alt="Office location map"
        className="h-full w-full object-cover"
      />
      <div className="absolute inset-0 flex items-end justify-start bg-gradient-to-r from-white/80 to-transparent p-4">
        <span className="flex items-center gap-1 bg-[var(--token-color-surface)]/90 px-2 pb-1 pt-[3px] text-sm font-semibold text-[var(--token-color-ink)]">
          <Map className="h-3 w-3" />
          View on Map
        </span>
      </div>
    </a>
  );
}
'@
Write-File (Join-Path $webRoot "components\support\OfficeMapCard.tsx") $officeMapCard

# ------------------------------------------------------------------------
# 6. app/(marketing)/contact/page.tsx
# ------------------------------------------------------------------------
$contactPage = @'
import { SupportHeader } from "@/components/support/SupportHeader";
import { SupportFooter } from "@/components/support/SupportFooter";
import { ContactForm } from "@/components/support/ContactForm";
import { DirectContactCard } from "@/components/support/DirectContactCard";
import { OfficeMapCard } from "@/components/support/OfficeMapCard";

export default function ContactPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <SupportHeader />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-10 px-6 py-10">
        <div className="flex max-w-[768px] flex-col gap-1.5">
          <h1 className="text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">Get in Touch</h1>
          <p className="text-lg leading-7 text-[var(--token-color-inkSoft)]">
            Our team is here to support your learning journey. Reach out with questions, technical issues, or
            feedback.
          </p>
        </div>

        <div className="grid grid-cols-1 items-start gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2">
            <ContactForm />
          </div>

          <div className="flex flex-col gap-6">
            <DirectContactCard />
            <OfficeMapCard />
          </div>
        </div>
      </main>

      <SupportFooter />
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "app\(marketing)\contact\page.tsx") $contactPage

Write-Host "`nDone. Contact & Support page scaffolded at:" -ForegroundColor Green
Write-Host "  apps\web\app\(marketing)\contact\page.tsx"
Write-Host "`nNOTE: SupportHeader/SupportFooter are DARK, page-specific variants -- they don't reuse the light Header/Footer used elsewhere."
Write-Host "`nVisit /contact after running 'pnpm --filter web dev'.`n"