# ============================================================================
# 02-refactor-homepage-sections.ps1
# Public Website redesign — Step 2: CourseCard, TrendingCourses, CategoryGrid,
# WhySaachi, Newsletter, Footer (same "Blueprint" design system as Step 1)
# Run from: SAI2 root
# ============================================================================

function Write-FileB64 {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path $PSScriptRoot $Path
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Content)
    $b64 = [Convert]::ToBase64String($bytes)
    $decoded = [Convert]::FromBase64String($b64)
    $dir = Split-Path -Path $fullPath -Parent
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllBytes($fullPath, $decoded)
    Write-Host "Written: $Path"
}

$root = "apps\web"

# ----------------------------------------------------------------------------
# 1. CourseCard.tsx — redesigned to match spec-sheet system
# ----------------------------------------------------------------------------
$cardPath = Join-Path $root "components\marketing\CourseCard.tsx"
$cardContent = @'
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
      className="group flex flex-1 flex-col overflow-hidden border transition-colors"
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
Write-FileB64 -Path $cardPath -Content $cardContent

# ----------------------------------------------------------------------------
# 2. TrendingCourses.tsx
# ----------------------------------------------------------------------------
$trendingPath = Join-Path $root "components\marketing\TrendingCourses.tsx"
$trendingContent = @'
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
Write-FileB64 -Path $trendingPath -Content $trendingContent

# ----------------------------------------------------------------------------
# 3. CategoryGrid.tsx
# ----------------------------------------------------------------------------
$categoryPath = Join-Path $root "components\marketing\CategoryGrid.tsx"
$categoryContent = @'
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
              className="group flex flex-col items-start gap-6 border p-6 transition-colors"
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
Write-FileB64 -Path $categoryPath -Content $categoryContent

# ----------------------------------------------------------------------------
# 4. WhySaachi.tsx
# ----------------------------------------------------------------------------
$whyPath = Join-Path $root "components\marketing\WhySaachi.tsx"
$whyContent = @'
import { GraduationCap, Wrench, BadgeCheck } from "lucide-react";
import { SpecLabel } from "./BlueprintMark";

const reasons = [
  {
    icon: GraduationCap,
    title: "Taught by people who ship",
    description:
      "Instructors are practitioners with real, demonstrable work — not narrators reading slides.",
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
Write-FileB64 -Path $whyPath -Content $whyContent

# ----------------------------------------------------------------------------
# 5. Newsletter.tsx
# ----------------------------------------------------------------------------
$newsletterPath = Join-Path $root "components\marketing\Newsletter.tsx"
$newsletterContent = @'
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
        className="flex flex-col items-center justify-between gap-6 border p-10 md:flex-row"
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
            className="h-11 flex-1 border px-4 text-sm focus:outline-none"
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
Write-FileB64 -Path $newsletterPath -Content $newsletterContent

# ----------------------------------------------------------------------------
# 6. Footer.tsx
# ----------------------------------------------------------------------------
$footerPath = Join-Path $root "components\marketing\Footer.tsx"
$footerContent = @'
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
Write-FileB64 -Path $footerPath -Content $footerContent

Write-Host ""
Write-Host "Step 2 done: CourseCard, TrendingCourses, CategoryGrid, WhySaachi, Newsletter, Footer refactored."
Write-Host "Homepage is now fully in the Blueprint system. Next candidates: CompactFooter (shared by other marketing pages) and the Course Marketplace listing page."