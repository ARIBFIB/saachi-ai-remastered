<#
================================================================================
Apply-Saachi-Step3-MarketingHome.ps1
STEP 3 of the design-system rollout: marketing homepage
  - components/marketing/BlueprintMark.tsx
  - components/marketing/Header.tsx
  - components/marketing/HeroSection.tsx
  - components/marketing/CourseCard.tsx
  - components/marketing/TrendingCourses.tsx
  - components/marketing/CategoryGrid.tsx
  - components/marketing/WhySaachi.tsx
  - components/marketing/Newsletter.tsx
  - components/marketing/Footer.tsx
  - components/marketing/CompactFooter.tsx
  - app/(marketing)/page.tsx

USAGE:
  1. Save this file into your repo root (same folder as Step 1/2), e.g.:
     D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2\Apply-Saachi-Step3-MarketingHome.ps1
  2. In PowerShell (prompt: PS D:\...\SAI2>) run:
       .\Apply-Saachi-Step3-MarketingHome.ps1
  3. Existing files that would be overwritten are backed up first into
     .\_backup_stepwise\<timestamp>\
================================================================================
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$backupDir = Join-Path $root ("_backup_stepwise\{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$writtenCount = 0

function Write-SaachiFile {
    param(
        [string]$RelativePath,
        [string]$Content
    )

    $fullPath = Join-Path $root $RelativePath
    $dir = Split-Path $fullPath -Parent

    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    if (Test-Path $fullPath) {
        $backupTarget = Join-Path $backupDir $RelativePath
        $backupTargetDir = Split-Path $backupTarget -Parent
        if (-not (Test-Path $backupTargetDir)) {
            New-Item -ItemType Directory -Path $backupTargetDir -Force | Out-Null
        }
        Copy-Item -Path $fullPath -Destination $backupTarget -Force
        Write-Host "  backed up existing: $RelativePath"
    }

    $Content = $Content.TrimStart("`r", "`n")
    Set-Content -Path $fullPath -Value $Content -Encoding UTF8 -NoNewline
    $script:writtenCount++
    Write-Host "  wrote: $RelativePath"
}

Write-Host "=== STEP 3: Marketing homepage ==="
Write-Host "Target repo root: $root"
Write-Host ""

# ------------------------------------------------------------------
# apps/web/components/marketing/BlueprintMark.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\BlueprintMark.tsx" @'
// Signature element for the "Blueprint" design system: a small dimension-line
// crosshair mark, like a corner registration mark on a spec sheet. Used
// sparingly on hero cards and section dividers -- not decoration, it signals
// "this is measured / specified," matching Saachi's outcome-based identity.
interface BlueprintMarkProps {
  className?: string;
  color?: string;
}

export function BlueprintMark({ className = "", color = "var(--token-color-blueprintLine)" }: BlueprintMarkProps) {
  return (
    <svg
      className={className}
      width="20"
      height="20"
      viewBox="0 0 20 20"
      fill="none"
      aria-hidden="true"
    >
      <path d="M10 0V6" stroke={color} strokeWidth="1" />
      <path d="M10 14V20" stroke={color} strokeWidth="1" />
      <path d="M0 10H6" stroke={color} strokeWidth="1" />
      <path d="M14 10H20" stroke={color} strokeWidth="1" />
      <circle cx="10" cy="10" r="2" stroke={color} strokeWidth="1" />
    </svg>
  );
}

interface SpecLabelProps {
  index: string;
  label: string;
}

// Small mono-type "spec field" label -- reused as section eyebrows instead
// of a generic pill badge.
export function SpecLabel({ index, label }: SpecLabelProps) {
  return (
    <div className="flex items-center gap-2">
      <span
        className="text-xs font-medium"
        style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-amberDark)" }}
      >
        {index}
      </span>
      <span
        className="h-px w-6"
        style={{ backgroundColor: "var(--token-color-blueprintLine)" }}
      />
      <span
        className="text-xs font-semibold uppercase tracking-[0.12em]"
        style={{ color: "var(--token-color-inkDeepSoft)" }}
      >
        {label}
      </span>
    </div>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketing/Header.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\Header.tsx" @'
import Link from "next/link";
import { Search, ShoppingCart, Bell } from "lucide-react";

export function Header() {
  return (
    <header
      className="sticky top-0 z-50 w-full border-b"
      style={{
        backgroundColor: "var(--token-color-paper)",
        borderColor: "var(--token-color-blueprintLineSoft)",
      }}
    >
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        <div className="flex items-center gap-10">
          <Link href="/" className="flex items-center gap-2">
            <span
              className="flex h-6 w-6 items-center justify-center text-xs font-bold"
              style={{
                backgroundColor: "var(--token-color-amber)",
                color: "var(--token-color-inkDeep)",
                fontFamily: "var(--token-font-monoFamily)",
              }}
            >
              S
            </span>
            <span
              className="text-xl font-semibold tracking-tight"
              style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
            >
              Saachi AI
            </span>
          </Link>

          <div
            className="flex items-center gap-2 rounded-sm border-2 px-3 py-1.5"
            style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}
          >
            <Search size={14} color="var(--token-color-inkDeepSoft)" />
            <input
              type="text"
              placeholder="Search skills, e.g. 'WhatsApp AI bot'"
              className="w-64 bg-transparent text-sm placeholder:text-[var(--token-color-inkDeepSoft)] focus:outline-none"
              style={{ fontFamily: "var(--token-font-bodyFamily)", color: "var(--token-color-inkDeep)" }}
            />
          </div>
        </div>

        <div className="flex items-center gap-6">
          <nav className="flex items-center gap-5">
            <Link
              href="/courses"
              className="border-b-2 pb-[3px] text-sm font-semibold tracking-wide"
              style={{ borderColor: "var(--token-color-amber)", color: "var(--token-color-inkDeep)" }}
            >
              Marketplace
            </Link>
            <Link
              href="/categories"
              className="text-sm font-semibold tracking-wide hover:opacity-70"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              Categories
            </Link>
            <Link
              href="/become-instructor"
              className="text-sm font-semibold tracking-wide hover:opacity-70"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              Teach
            </Link>
          </nav>

          <div className="flex items-center gap-3">
            <button aria-label="Cart" className="p-2" style={{ color: "var(--token-color-inkDeepSoft)" }}>
              <ShoppingCart size={18} />
            </button>
            <button aria-label="Notifications" className="p-2" style={{ color: "var(--token-color-inkDeepSoft)" }}>
              <Bell size={18} />
            </button>

            <Link
              href="/login"
              className="ml-1 px-5 py-2 text-sm font-semibold tracking-wide"
              style={{ backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }}
            >
              Sign In
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketing/HeroSection.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\HeroSection.tsx" @'
import Link from "next/link";
import { BlueprintMark, SpecLabel } from "./BlueprintMark";

const buildLog = [
  "Certificate issued -- Prompt Engineering Masterclass",
  "Course published -- WhatsApp AI Auto-Responder",
  "Skill verified -- n8n Workflow Automation",
];

export function HeroSection() {
  return (
    <section
      className="w-full border-b"
      style={{ backgroundColor: "var(--token-color-paper)", borderColor: "var(--token-color-blueprintLineSoft)" }}
    >
      <div className="mx-auto grid max-w-[1280px] grid-cols-1 gap-10 px-6 py-20 lg:grid-cols-[1.1fr_0.9fr] lg:items-center">
        {/* Left: copy */}
        <div className="flex flex-col gap-6">
          <SpecLabel index="01" label="Skill Marketplace" />

          <h1
            className="max-w-[560px] text-5xl font-semibold leading-[1.05] tracking-tight"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            Learn to build with AI.
            <br />
            Not just watch it.
          </h1>

          <p
            className="max-w-[460px] text-lg leading-7"
            style={{ fontFamily: "var(--token-font-bodyFamily)", color: "var(--token-color-inkDeepSoft)" }}
          >
            Practical, outcome-verified AI courses -- automations, chatbots, AI-assisted apps --
            taught by people who ship them. No filler, just the skill and the proof you learned it.
          </p>

          <div className="flex items-center gap-4 pt-2">
            <Link
              href="/courses"
              className="px-8 py-3.5 text-sm font-semibold tracking-wide"
              style={{ backgroundColor: "var(--token-color-amber)", color: "var(--token-color-inkDeep)" }}
            >
              Explore Courses
            </Link>
            <Link
              href="/become-instructor"
              className="border-2 px-8 py-3.5 text-sm font-semibold tracking-wide"
              style={{ borderColor: "var(--token-color-inkDeep)", color: "var(--token-color-inkDeep)" }}
            >
              Teach a Skill
            </Link>
          </div>

          {/* Build log ticker -- signature outcome-proof element */}
          <div
            className="mt-4 flex flex-col gap-1.5 border-t pt-4"
            style={{ borderColor: "var(--token-color-blueprintLineSoft)", fontFamily: "var(--token-font-monoFamily)" }}
          >
            {buildLog.map((line) => (
              <div key={line} className="flex items-center gap-2 text-xs" style={{ color: "var(--token-color-inkDeepSoft)" }}>
                <span style={{ color: "var(--token-color-teal)" }}>&#10003;</span>
                {line}
              </div>
            ))}
          </div>
        </div>

        {/* Right: "spec card" -- a labeled artifact instead of a stock photo */}
        <div
          className="relative border-2 p-8"
          style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}
        >
          <BlueprintMark className="absolute -left-2.5 -top-2.5" />
          <BlueprintMark className="absolute -right-2.5 -top-2.5" />
          <BlueprintMark className="absolute -bottom-2.5 -left-2.5" />
          <BlueprintMark className="absolute -bottom-2.5 -right-2.5" />

          <div className="flex items-center justify-between border-b pb-4" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}>
            <span
              className="text-xs font-semibold uppercase tracking-[0.12em]"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              Course Spec
            </span>
            <span
              className="px-2 py-0.5 text-[10px] font-bold uppercase tracking-wide"
              style={{ backgroundColor: "var(--token-color-tealTint)", color: "var(--token-color-teal)" }}
            >
              Verified Outcome
            </span>
          </div>

          <h3
            className="pt-5 text-2xl font-semibold leading-8"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            WhatsApp AI Auto-Responder for Small Business
          </h3>

          <div className="mt-6 grid grid-cols-2 gap-4" style={{ fontFamily: "var(--token-font-monoFamily)" }}>
            <SpecRow label="Duration" value="6h 40m" />
            <SpecRow label="Level" value="Intermediate" />
            <SpecRow label="Modules" value="9" />
            <SpecRow label="Completion" value="94%" />
          </div>

          <div className="mt-6 flex items-center justify-between border-t pt-5" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}>
            <span
              className="text-2xl font-semibold"
              style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-inkDeep)" }}
            >
              Rs 4,999
            </span>
            <Link
              href="/courses/whatsapp-ai-auto-responder"
              className="px-5 py-2 text-xs font-semibold tracking-wide"
              style={{ backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }}
            >
              View Course
            </Link>
          </div>
        </div>
      </div>
    </section>
  );
}

function SpecRow({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-[10px] uppercase tracking-wide" style={{ color: "var(--token-color-inkDeepSoft)" }}>
        {label}
      </span>
      <span className="text-sm font-medium" style={{ color: "var(--token-color-inkDeep)" }}>
        {value}
      </span>
    </div>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketing/CourseCard.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\CourseCard.tsx" @'
import Image from "next/image";
import { Star } from "lucide-react";

export interface CourseCardProps {
  title: string;
  instructor: string;
  rating: number;
  reviews: string;
  tag: string;
  tagVariant?: "default" | "highlight" | "neutral";
  image: string;
}

export function CourseCard({
  title,
  instructor,
  rating,
  reviews,
  tag,
  image,
}: CourseCardProps) {
  return (
    <article
      className="group flex flex-1 flex-col overflow-hidden border-2 transition-colors"
      style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}
    >
      <div className="relative h-40 w-full overflow-hidden" style={{ backgroundColor: "var(--token-color-blueprintLineSoft)" }}>
        <Image
          src={image}
          alt={title}
          fill
          sizes="(max-width: 768px) 100vw, 288px"
          className="object-cover transition-transform duration-300 group-hover:scale-[1.03]"
        />
        <span
          className="absolute left-0 top-0 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wide"
          style={{ backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }}
        >
          {tag}
        </span>
      </div>

      <div className="flex flex-col gap-3 border-t p-5" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}>
        <h3
          className="line-clamp-2 text-lg font-semibold leading-6"
          style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
        >
          {title}
        </h3>

        <p className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>
          {instructor}
        </p>

        <div
          className="flex items-center justify-between border-t pt-3"
          style={{ borderColor: "var(--token-color-blueprintLineSoft)", fontFamily: "var(--token-font-monoFamily)" }}
        >
          <div className="flex items-center gap-1.5">
            <Star className="h-3.5 w-3.5" style={{ color: "var(--token-color-amberDark)" }} fill="currentColor" strokeWidth={0} />
            <span className="text-sm font-medium" style={{ color: "var(--token-color-inkDeep)" }}>
              {rating}
            </span>
            <span className="text-xs" style={{ color: "var(--token-color-inkDeepSoft)" }}>
              ({reviews})
            </span>
          </div>
        </div>
      </div>
    </article>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketing/TrendingCourses.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\TrendingCourses.tsx" @'
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { CourseCard, type CourseCardProps } from "./CourseCard";
import { SpecLabel } from "./BlueprintMark";

const courses: CourseCardProps[] = [
  {
    title: "AI Ethics & Responsible Deployment",
    instructor: "Dr. Sarah Jenkins",
    rating: 4.9,
    reviews: "2.4k",
    tag: "Foundational",
    image: "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Mastering Prompt Engineering",
    instructor: "Alex Chen",
    rating: 4.8,
    reviews: "8.1k",
    tag: "Bestseller",
    image: "https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Generative AI & Digital Art",
    instructor: "Elena Rodriguez",
    rating: 4.7,
    reviews: "1.2k",
    tag: "Creative",
    image: "https://images.unsplash.com/photo-1550439062-609e1531270e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "LLM Ops & Production Deployment",
    instructor: "David Kim, PhD",
    rating: 4.9,
    reviews: "940",
    tag: "Advanced",
    image: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
];

export function TrendingCourses() {
  return (
    <section className="w-full py-16" style={{ backgroundColor: "var(--token-color-bg)" }}>
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="flex items-end justify-between">
          <div className="flex flex-col gap-3">
            <SpecLabel index="02" label="Trending" />
            <h2
              className="text-3xl font-semibold"
              style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
            >
              Courses learners are shipping right now
            </h2>
          </div>
          <Link
            href="/courses"
            className="flex items-center gap-1 text-sm font-semibold tracking-wide"
            style={{ color: "var(--token-color-teal)" }}
          >
            View all
            <ArrowRight className="h-3 w-3" />
          </Link>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {courses.map((course) => (
            <CourseCard key={course.title} {...course} />
          ))}
        </div>
      </div>
    </section>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketing/CategoryGrid.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\CategoryGrid.tsx" @'
import Link from "next/link";
import { MessageSquare, Eye, Bot, LineChart } from "lucide-react";
import { SpecLabel } from "./BlueprintMark";

const categories = [
  { label: "NLP & Language", icon: MessageSquare, href: "/categories/nlp" },
  { label: "Computer Vision", icon: Eye, href: "/categories/computer-vision" },
  { label: "Automation & Workflows", icon: Bot, href: "/categories/robotics" },
  { label: "AI Strategy", icon: LineChart, href: "/categories/ai-strategy" },
];

export function CategoryGrid() {
  return (
    <section className="w-full border-y py-16" style={{ borderColor: "var(--token-color-blueprintLineSoft)", backgroundColor: "var(--token-color-surface)" }}>
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="flex flex-col gap-3">
          <SpecLabel index="03" label="Categories" />
          <h2
            className="text-3xl font-semibold"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            Pick a track, not a rabbit hole
          </h2>
        </div>

        <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
          {categories.map(({ label, icon: Icon, href }) => (
            <Link
              key={label}
              href={href}
              className="group flex flex-col items-start gap-6 border-2 p-6 transition-colors"
              style={{ borderColor: "var(--token-color-blueprintLine)" }}
            >
              <span
                className="flex h-11 w-11 items-center justify-center transition-colors group-hover:text-white"
                style={{ backgroundColor: "var(--token-color-amberTint)" }}
              >
                <Icon className="h-5 w-5" style={{ color: "var(--token-color-amberDark)" }} />
              </span>
              <span
                className="text-sm font-semibold leading-5"
                style={{ fontFamily: "var(--token-font-bodyFamily)", color: "var(--token-color-inkDeep)" }}
              >
                {label}
              </span>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketing/WhySaachi.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\WhySaachi.tsx" @'
import { GraduationCap, Wrench, BadgeCheck } from "lucide-react";
import { SpecLabel } from "./BlueprintMark";

const reasons = [
  {
    icon: GraduationCap,
    title: "Taught by people who ship",
    description:
      "Instructors are practitioners with real, demonstrable work -- not narrators reading slides.",
  },
  {
    icon: Wrench,
    title: "Hands-on, from lesson one",
    description:
      "Every course ends in a working artifact: a bot, an automation, a deployed feature.",
  },
  {
    icon: BadgeCheck,
    title: "Verified, not just watched",
    description:
      "Certificates carry a verification ID tied to actual completion, not video runtime.",
  },
];

export function WhySaachi() {
  return (
    <section className="w-full py-16" style={{ backgroundColor: "var(--token-color-bg)" }}>
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="flex flex-col gap-3">
          <SpecLabel index="04" label="Why Saachi" />
          <h2
            className="text-3xl font-semibold"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            Built for outcomes, not watch-time
          </h2>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-3">
          {reasons.map(({ icon: Icon, title, description }) => (
            <div
              key={title}
              className="flex flex-col gap-4 border-t-2 p-6"
              style={{ borderColor: "var(--token-color-teal)", backgroundColor: "var(--token-color-surface)" }}
            >
              <Icon className="h-6 w-6" style={{ color: "var(--token-color-teal)" }} />
              <h3
                className="text-lg font-semibold"
                style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
              >
                {title}
              </h3>
              <p className="text-sm leading-6" style={{ color: "var(--token-color-inkDeepSoft)" }}>
                {description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketing/Newsletter.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\Newsletter.tsx" @'
"use client";

import { useState } from "react";

export function Newsletter() {
  const [email, setEmail] = useState("");

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // TODO: wire to Newsletter API (packages/api-client)
    console.log("subscribe:", email);
  }

  return (
    <div className="mx-auto w-full max-w-[1280px] px-6 pb-16">
      <div
        className="flex flex-col items-center justify-between gap-6 border-2 p-10 md:flex-row"
        style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-inkDeep)" }}
      >
        <div className="flex max-w-96 flex-col gap-2">
          <h2
            className="text-2xl font-semibold"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-paper)" }}
          >
            Get one practical AI tip a week.
          </h2>
          <p className="text-sm" style={{ color: "var(--token-color-blueprintLine)" }}>
            New courses, real build breakdowns, no hype.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="flex w-full max-w-96 gap-2">
          <input
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            className="h-11 flex-1 border-2 px-4 text-sm focus:outline-none"
            style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-paper)", color: "var(--token-color-inkDeep)" }}
          />
          <button
            type="submit"
            className="h-11 shrink-0 px-6 text-sm font-semibold tracking-wide"
            style={{ backgroundColor: "var(--token-color-amber)", color: "var(--token-color-inkDeep)" }}
          >
            Subscribe
          </button>
        </form>
      </div>
    </div>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketing/Footer.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\Footer.tsx" @'
import Link from "next/link";

const columns = [
  {
    title: "Platform",
    links: [
      { label: "Marketplace", href: "/courses" },
      { label: "Enterprise", href: "/pricing" },
      { label: "Teach a Skill", href: "/become-instructor" },
    ],
  },
  {
    title: "Company",
    links: [
      { label: "About Us", href: "/about" },
      { label: "Careers", href: "/careers" },
      { label: "Contact", href: "/contact" },
    ],
  },
  {
    title: "Legal",
    links: [
      { label: "Privacy Policy", href: "/legal/privacy" },
      { label: "Terms of Service", href: "/legal/terms" },
    ],
  },
];

export function Footer() {
  return (
    <footer className="w-full border-t" style={{ borderColor: "var(--token-color-blueprintLineSoft)", backgroundColor: "var(--token-color-paper)" }}>
      <div className="mx-auto grid max-w-[1280px] grid-cols-1 gap-8 px-6 py-12 md:grid-cols-4">
        <div className="flex flex-col gap-4">
          <div className="flex items-center gap-2">
            <span
              className="flex h-6 w-6 items-center justify-center text-xs font-bold"
              style={{ backgroundColor: "var(--token-color-amber)", color: "var(--token-color-inkDeep)", fontFamily: "var(--token-font-monoFamily)" }}
            >
              S
            </span>
            <span
              className="text-base font-semibold"
              style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
            >
              Saachi AI
            </span>
          </div>
          <p className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>
            A skills exchange for the AI era. Learn to build, not just watch.
          </p>
        </div>

        {columns.map((col) => (
          <div key={col.title} className="flex flex-col gap-4">
            <h4
              className="text-xs font-semibold uppercase tracking-[0.12em]"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              {col.title}
            </h4>
            <nav className="flex flex-col gap-2">
              {col.links.map((link) => (
                <Link
                  key={link.label}
                  href={link.href}
                  className="text-sm hover:opacity-70"
                  style={{ color: "var(--token-color-inkDeep)" }}
                >
                  {link.label}
                </Link>
              ))}
            </nav>
          </div>
        ))}
      </div>

      <div
        className="mx-auto flex max-w-[1280px] items-center justify-between border-t px-6 py-5"
        style={{ borderColor: "var(--token-color-blueprintLineSoft)", fontFamily: "var(--token-font-monoFamily)" }}
      >
        <p className="text-xs" style={{ color: "var(--token-color-inkDeepSoft)" }}>
          &copy; {new Date().getFullYear()} Saachi AI Marketplace
        </p>
      </div>
    </footer>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketing/CompactFooter.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketing\CompactFooter.tsx" @'
import Link from "next/link";

const links = [
  { label: "About Us", href: "/about" },
  { label: "Careers", href: "/careers" },
  { label: "Privacy Policy", href: "/legal/privacy" },
  { label: "Terms of Service", href: "/legal/terms" },
  { label: "Teach a Skill", href: "/become-instructor" },
];

export function CompactFooter() {
  return (
    <footer className="w-full border-t" style={{ borderColor: "var(--token-color-blueprintLineSoft)", backgroundColor: "var(--token-color-paper)" }}>
      <div className="mx-auto flex max-w-[1280px] flex-col gap-6 px-6 py-10">
        <div
          className="flex flex-wrap items-center justify-between gap-4 border-b pb-6"
          style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}
        >
          <span
            className="text-base font-semibold"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            Saachi AI
          </span>
          <nav className="flex flex-wrap gap-5">
            {links.map((link) => (
              <Link
                key={link.label}
                href={link.href}
                className="text-xs font-medium hover:opacity-70"
                style={{ color: "var(--token-color-inkDeepSoft)" }}
              >
                {link.label}
              </Link>
            ))}
          </nav>
        </div>

        <p
          className="text-center text-xs"
          style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-inkDeepSoft)" }}
        >
          &copy; {new Date().getFullYear()} Saachi AI Marketplace
        </p>
      </div>
    </footer>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/app/(marketing)/page.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\(marketing)\page.tsx" @'
import { Header } from "@/components/marketing/Header";
import { HeroSection } from "@/components/marketing/HeroSection";
import { TrendingCourses } from "@/components/marketing/TrendingCourses";
import { CategoryGrid } from "@/components/marketing/CategoryGrid";
import { WhySaachi } from "@/components/marketing/WhySaachi";
import { Newsletter } from "@/components/marketing/Newsletter";
import { Footer } from "@/components/marketing/Footer";

export default function HomePage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="flex flex-1 flex-col items-center pb-10">
        <HeroSection />
        <TrendingCourses />
        <CategoryGrid />
        <WhySaachi />
        <Newsletter />
      </main>

      <Footer />
    </div>
  );
}
'@

Write-Host ""
Write-Host "=== STEP 3 complete: $writtenCount file(s) written. ==="
if (Test-Path $backupDir) {
    Write-Host "Backups of any overwritten files: $backupDir"
}