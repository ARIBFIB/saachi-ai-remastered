$ErrorActionPreference = "Stop"
$root = Get-Location

$webApp = Join-Path $root "apps\web\app"
$marketingDir = Join-Path $webApp "(marketing)"
$componentsDir = Join-Path $marketingDir "_components"
$globalsPath = Join-Path $webApp "globals.css"
$homePath = Join-Path $marketingDir "page.tsx"

if (-not (Test-Path -LiteralPath $marketingDir)) {
    Write-Error "Could not find $marketingDir -- run this script from the SAI2 root."
    exit 1
}

New-Item -ItemType Directory -Path $componentsDir -Force | Out-Null

$backupDir = Join-Path $root "theme-migration-backup\step7"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
if (Test-Path -LiteralPath $homePath) {
    Copy-Item -LiteralPath $homePath -Destination (Join-Path $backupDir "page.tsx.bak") -Force
}
Copy-Item -LiteralPath $globalsPath -Destination (Join-Path $backupDir "globals.css.bak") -Force
Write-Host "Backups saved to: $backupDir"
Write-Host ""

# ---------------------------------------------------------------------------
# 1. Reveal.tsx -- scroll-triggered fade+slide-up wrapper
# ---------------------------------------------------------------------------
$revealContent = @'
"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";

export function Reveal({
  children,
  delay = 0,
  className = ""
}: {
  children: ReactNode;
  delay?: number;
  className?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setVisible(true);
            observer.disconnect();
          }
        });
      },
      { threshold: 0.15 }
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  return (
    <div
      ref={ref}
      className={className}
      style={{
        opacity: visible ? 1 : 0,
        transform: visible ? "translateY(0)" : "translateY(24px)",
        transition: `opacity 600ms ease-out ${delay}ms, transform 600ms ease-out ${delay}ms`
      }}
    >
      {children}
    </div>
  );
}
'@
Set-Content -LiteralPath (Join-Path $componentsDir "Reveal.tsx") -Value $revealContent -Encoding UTF8
Write-Host "Created: Reveal.tsx"

# ---------------------------------------------------------------------------
# 2. LandingSearch.tsx -- fake search with a dummy dataset + live dropdown
# ---------------------------------------------------------------------------
$searchContent = @'
"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { Search, TrendingUp, Star } from "lucide-react";

type FakeResult = {
  title: string;
  category: string;
  instructor: string;
  rating: number;
  students: number;
};

// NOTE: demo-only dummy dataset for the landing-page search preview.
const FAKE_COURSES: FakeResult[] = [
  { title: "Automate Everything with n8n & AI", category: "Automation", instructor: "Ayesha Khan", rating: 4.8, students: 2140 },
  { title: "Prompt Engineering for Client Work", category: "Fundamentals", instructor: "Hamza Malik", rating: 4.6, students: 980 },
  { title: "AI Chatbots for WhatsApp Support", category: "Automation", instructor: "Ayesha Khan", rating: 4.7, students: 1560 },
  { title: "Cold Outreach with Claude", category: "Marketing", instructor: "Sara Iqbal", rating: 4.5, students: 740 },
  { title: "Build AI Agents with LangChain", category: "Development", instructor: "Omar Sheikh", rating: 4.9, students: 3200 },
  { title: "AI Design Systems in Figma", category: "Design", instructor: "Noor Fatima", rating: 4.7, students: 1120 },
  { title: "Freelancing with AI Tools", category: "Career", instructor: "Bilal S.", rating: 4.4, students: 610 },
  { title: "Voice AI & Call Automation", category: "Automation", instructor: "Hina Malik", rating: 4.6, students: 890 }
];

export function LandingSearch() {
  const [query, setQuery] = useState("");
  const [focused, setFocused] = useState(false);

  const results = useMemo(() => {
    if (!query.trim()) return [];
    const q = query.toLowerCase();
    return FAKE_COURSES.filter(
      (c) =>
        c.title.toLowerCase().includes(q) ||
        c.category.toLowerCase().includes(q) ||
        c.instructor.toLowerCase().includes(q)
    ).slice(0, 5);
  }, [query]);

  const showDropdown = focused && query.trim().length > 0;

  return (
    <div className="relative mx-auto w-full max-w-xl">
      <div className="flex items-center gap-3 rounded-full border border-line bg-card px-5 py-3.5 shadow-sm transition-shadow focus-within:shadow-md">
        <Search size={18} className="shrink-0 text-ink-soft" />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onFocus={() => setFocused(true)}
          onBlur={() => setTimeout(() => setFocused(false), 150)}
          placeholder="Search courses, skills, or instructors..."
          className="w-full bg-transparent text-[14px] text-ink placeholder:text-ink-soft focus:outline-none"
        />
        {query && (
          <span className="shrink-0 rounded-full bg-paper-dim px-2.5 py-1 text-[11px] font-semibold text-ink-soft">
            {results.length} results
          </span>
        )}
      </div>

      {showDropdown && (
        <div className="absolute left-0 right-0 top-[calc(100%+8px)] z-30 overflow-hidden rounded-card border border-line bg-card shadow-lg">
          {results.length === 0 ? (
            <div className="px-5 py-6 text-center text-[13px] text-ink-soft">
              No matches for &quot;{query}&quot; -- try &quot;automation&quot; or &quot;design&quot;.
            </div>
          ) : (
            <ul className="flex flex-col divide-y divide-line">
              {results.map((r) => (
                <li key={r.title}>
                  <Link
                    href="/courses"
                    className="flex items-center justify-between gap-3 px-5 py-3 transition-colors hover:bg-paper-dim"
                  >
                    <div className="min-w-0">
                      <p className="truncate text-[13.5px] font-semibold text-ink">{r.title}</p>
                      <p className="text-[12px] text-ink-soft">
                        {r.category} - {r.instructor}
                      </p>
                    </div>
                    <div className="flex shrink-0 items-center gap-1 text-[12px] font-medium text-ink-soft">
                      <Star size={12} className="fill-current text-accent-pink" />
                      {r.rating}
                    </div>
                  </Link>
                </li>
              ))}
            </ul>
          )}
          <Link
            href="/courses"
            className="flex items-center justify-center gap-2 border-t border-line bg-paper-dim px-5 py-3 text-[12.5px] font-semibold text-accent-violet hover:underline"
          >
            <TrendingUp size={13} />
            See all courses matching &quot;{query}&quot;
          </Link>
        </div>
      )}
    </div>
  );
}
'@
Set-Content -LiteralPath (Join-Path $componentsDir "LandingSearch.tsx") -Value $searchContent -Encoding UTF8
Write-Host "Created: LandingSearch.tsx"

# ---------------------------------------------------------------------------
# 3. FaqAccordion.tsx
# ---------------------------------------------------------------------------
$faqContent = @'
"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

const FAQS = [
  {
    q: "Do I need any prior AI experience?",
    a: "No. Courses are organized by level -- Beginner, Intermediate, and Advanced -- so you can start exactly where you are."
  },
  {
    q: "Can I really earn money teaching on Saachi AI?",
    a: "Yes. Instructors set their own pricing and keep the majority of each sale after the platform commission, disclosed upfront at course submission."
  },
  {
    q: "Are certificates recognized?",
    a: "Every completed course issues a shareable completion certificate you can add to LinkedIn or your portfolio."
  },
  {
    q: "What if a course isn't what I expected?",
    a: "We offer refunds within 7 days of purchase, as long as you haven't completed more than 30% of the content."
  },
  {
    q: "Can I book 1-on-1 time with an instructor?",
    a: "Many instructors offer paid mentorship sessions -- book directly from their profile once you're enrolled."
  }
];

export function FaqAccordion() {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  return (
    <div className="flex flex-col divide-y divide-line rounded-card border border-line bg-card">
      {FAQS.map((item, i) => {
        const open = openIndex === i;
        return (
          <div key={item.q}>
            <button
              type="button"
              onClick={() => setOpenIndex(open ? null : i)}
              className="flex w-full items-center justify-between gap-4 px-5 py-4 text-left"
            >
              <span className="text-[14.5px] font-semibold text-ink">{item.q}</span>
              <ChevronDown
                size={17}
                className="shrink-0 text-ink-soft transition-transform duration-200"
                style={{ transform: open ? "rotate(180deg)" : "rotate(0deg)" }}
              />
            </button>
            <div
              className="overflow-hidden px-5 text-[13.5px] leading-relaxed text-ink-soft transition-all duration-200 ease-out"
              style={{
                maxHeight: open ? "200px" : "0px",
                paddingBottom: open ? "16px" : "0px",
                opacity: open ? 1 : 0
              }}
            >
              {item.a}
            </div>
          </div>
        );
      })}
    </div>
  );
}
'@
Set-Content -LiteralPath (Join-Path $componentsDir "FaqAccordion.tsx") -Value $faqContent -Encoding UTF8
Write-Host "Created: FaqAccordion.tsx"

# ---------------------------------------------------------------------------
# 4. Append marquee + fade keyframes to globals.css (only if not already there)
# ---------------------------------------------------------------------------
$globalsContent = Get-Content -LiteralPath $globalsPath -Raw
if (-not $globalsContent.Contains(".marquee-track")) {
    $marqueeCss = @'

/* Landing page: logo/avatar marquee + reveal keyframes */
.marquee-track {
  display: flex;
  width: max-content;
  animation: marquee-scroll 28s linear infinite;
}
@keyframes marquee-scroll {
  from { transform: translateX(0); }
  to { transform: translateX(-50%); }
}
'@
    Add-Content -LiteralPath $globalsPath -Value $marqueeCss -Encoding UTF8
    Write-Host "Appended marquee keyframes to globals.css"
} else {
    Write-Host "SKIPPED -- marquee keyframes already present in globals.css"
}

# ---------------------------------------------------------------------------
# 5. Full landing page rewrite
# ---------------------------------------------------------------------------
$pageContent = @'
"use client";

import Link from "next/link";
import { useCourseList } from "@saachi/api-client";
import { Button, CourseCard, Loading } from "@saachi/ui";
import {
  Sparkles,
  Users,
  BookOpen,
  Award,
  Star,
  ShieldCheck,
  Zap,
  TrendingUp,
  PlayCircle,
  Quote,
  BadgeCheck
} from "lucide-react";
import { CATEGORIES } from "../../lib/categories";
import { Reveal } from "./_components/Reveal";
import { LandingSearch } from "./_components/LandingSearch";
import { FaqAccordion } from "./_components/FaqAccordion";

const STATS = [
  { label: "Active students", value: "42,000+", icon: Users },
  { label: "Courses live", value: "1,280+", icon: BookOpen },
  { label: "Instructor payouts", value: "$2.1M+", icon: TrendingUp },
  { label: "Avg. rating", value: "4.8 / 5", icon: Star }
];

const TRUST_BADGES = ["Featured on ProductHunt", "AI Weekly Pick", "TechCrunch Mentioned", "500+ 5-star reviews", "SSL Secured Checkout", "7-Day Refunds"];

const INSTRUCTORS = [
  { name: "Ayesha Khan", role: "Automation & n8n", students: "6.2k", avatar: "https://i.pravatar.cc/96?img=47" },
  { name: "Hamza Malik", role: "AI Integration", students: "4.8k", avatar: "https://i.pravatar.cc/96?img=12" },
  { name: "Sara Iqbal", role: "AI Marketing", students: "3.1k", avatar: "https://i.pravatar.cc/96?img=32" },
  { name: "Omar Sheikh", role: "AI Development", students: "5.5k", avatar: "https://i.pravatar.cc/96?img=15" },
  { name: "Noor Fatima", role: "AI Design", students: "2.7k", avatar: "https://i.pravatar.cc/96?img=44" },
  { name: "Bilal S.", role: "Career & Freelancing", students: "1.9k", avatar: "https://i.pravatar.cc/96?img=8" }
];

const TESTIMONIALS = [
  {
    name: "Fatima R.",
    role: "Freelance automation consultant",
    avatar: "https://i.pravatar.cc/64?img=5",
    rating: 5,
    quote: "I landed 3 client projects within a month of finishing the n8n automation course. The invoice-parsing workflow alone paid for the course ten times over."
  },
  {
    name: "Ali Raza",
    role: "Support team lead",
    avatar: "https://i.pravatar.cc/64?img=22",
    rating: 5,
    quote: "Our WhatsApp response time dropped by 70% after building the chatbot from the course. Practical, no fluff, straight to the point."
  },
  {
    name: "Hina Malik",
    role: "Marketing manager",
    avatar: "https://i.pravatar.cc/64?img=25",
    rating: 4,
    quote: "Best structured AI marketing content I have found anywhere. Wish there were a couple more advanced modules, but genuinely worth it."
  },
  {
    name: "Omar Sheikh",
    role: "Indie developer",
    avatar: "https://i.pravatar.cc/64?img=15",
    rating: 5,
    quote: "Went from zero to shipping my own AI agent product in six weeks. The instructor actually answers Q&A -- that made all the difference."
  }
];

const HOW_IT_WORKS = [
  { title: "Pick a skill", desc: "Browse 1,200+ practical AI courses across automation, marketing, design, and development.", icon: Sparkles },
  { title: "Learn by building", desc: "Every course ships real projects and templates, not just watch-and-forget video.", icon: PlayCircle },
  { title: "Get certified & earn", desc: "Finish, get certified, and turn what you learned into freelance work -- or teach it yourself.", icon: Award }
];

export default function HomePage() {
  const { data: featured, isLoading } = useCourseList({ sort: "popular", page: 1 });

  return (
    <div className="overflow-hidden">
      {/* Hero */}
      <section className="relative mx-auto max-w-7xl px-4 pb-14 pt-16 md:px-8 md:pt-24">
        <div
          className="pointer-events-none absolute -left-32 -top-32 h-96 w-96 rounded-full opacity-30 blur-3xl"
          style={{ backgroundImage: "var(--color-accent-gradient)" }}
        />
        <div className="relative max-w-2xl">
          <div className="mb-5 inline-flex items-center gap-2 rounded-full border border-line bg-card px-3.5 py-1.5 text-[12.5px] font-semibold text-accent-violet">
            <Zap size={13} />
            42,000+ learners already building with AI
          </div>
          <h1 className="font-display text-[38px] font-bold leading-[1.05] text-ink md:text-[64px]">
            Learn AI Skills.
            <br />
            <span className="text-gradient-brand">Build Real Projects.</span>
          </h1>
          <p className="mt-5 text-[16px] leading-relaxed text-ink-soft md:text-[18px]">
            Not another watch-time platform. Saachi AI is a skills exchange for the AI era -
            structured, practical, and paid.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses">
              <Button size="lg" variant="brand">Browse courses</Button>
            </Link>
            <Link href="/register">
              <Button size="lg" variant="secondary">
                Become an instructor
              </Button>
            </Link>
          </div>

          <div className="mt-10">
            <LandingSearch />
          </div>
        </div>
      </section>

      {/* Trust badges marquee */}
      <section className="border-y border-line bg-paper-dim py-4">
        <div className="marquee-track">
          {[...TRUST_BADGES, ...TRUST_BADGES].map((badge, i) => (
            <span
              key={`${badge}-${i}`}
              className="mx-4 flex shrink-0 items-center gap-2 text-[13px] font-medium text-ink-soft"
            >
              <BadgeCheck size={14} className="text-accent-violet" />
              {badge}
            </span>
          ))}
        </div>
      </section>

      {/* Stats */}
      <section className="mx-auto max-w-7xl px-4 py-16 md:px-8">
        <Reveal>
          <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
            {STATS.map((s) => (
              <div key={s.label} className="rounded-card border border-line bg-card p-5 text-center">
                <s.icon size={20} className="mx-auto mb-2 text-accent-violet" />
                <p className="font-display text-[24px] font-bold text-ink">{s.value}</p>
                <p className="mt-1 text-[12.5px] text-ink-soft">{s.label}</p>
              </div>
            ))}
          </div>
        </Reveal>
      </section>

      {/* Category grid */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-5 font-display text-[22px] font-semibold text-ink">Browse by category</h2>
        </Reveal>
        <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
          {CATEGORIES.map((cat, i) => (
            <Reveal key={cat.id} delay={i * 40}>
              <Link
                href={`/categories/${cat.slug}`}
                className="group flex h-full flex-col justify-between rounded-card border border-line bg-card p-4 text-[14px] font-medium text-ink transition-all hover:-translate-y-1 hover:border-accent-violet/50 hover:shadow-md"
              >
                <span>{cat.name}</span>
                <span className="mt-3 text-[11px] font-semibold text-ink-soft group-hover:text-accent-violet">
                  Explore &rarr;
                </span>
              </Link>
            </Reveal>
          ))}
        </div>
      </section>

      {/* How it works */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">How Saachi AI works</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Three steps from curious to capable.</p>
        </Reveal>
        <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
          {HOW_IT_WORKS.map((step, i) => (
            <Reveal key={step.title} delay={i * 100}>
              <div className="h-full rounded-card border border-line bg-card p-6">
                <div
                  className="mb-4 flex h-11 w-11 items-center justify-center rounded-full text-white"
                  style={{ backgroundImage: "var(--color-accent-gradient)" }}
                >
                  <step.icon size={20} />
                </div>
                <h3 className="mb-1.5 text-[16px] font-semibold text-ink">{step.title}</h3>
                <p className="text-[13.5px] leading-relaxed text-ink-soft">{step.desc}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      {/* Featured courses */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <div className="mb-5 flex items-center justify-between">
            <h2 className="font-display text-[22px] font-semibold text-ink">Featured courses</h2>
            <Link href="/courses" className="text-[14px] font-medium text-accent-violet hover:underline">
              View all
            </Link>
          </div>
        </Reveal>

        {isLoading ? (
          <Loading label="Loading courses..." />
        ) : (
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {featured?.items.map((course, i) => (
              <Reveal key={course.id} delay={i * 60}>
                <CourseCard
                  slug={course.slug}
                  title={course.title}
                  thumbnailUrl={course.thumbnailUrl}
                  instructorName={course.instructor.fullName}
                  price={course.price}
                  currency={course.currency}
                  rating={course.rating}
                  ratingCount={course.ratingCount}
                />
              </Reveal>
            ))}
          </div>
        )}
      </section>

      {/* Popular instructors */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Learn from top instructors</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Verified practitioners, not just presenters.</p>
        </Reveal>
        <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-6">
          {INSTRUCTORS.map((inst, i) => (
            <Reveal key={inst.name} delay={i * 50}>
              <div className="flex flex-col items-center rounded-card border border-line bg-card p-4 text-center transition-transform hover:-translate-y-1">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={inst.avatar}
                  alt={inst.name}
                  className="mb-3 h-16 w-16 rounded-full border-2 border-line object-cover"
                />
                <p className="truncate text-[13px] font-semibold text-ink">{inst.name}</p>
                <p className="truncate text-[11.5px] text-ink-soft">{inst.role}</p>
                <span className="mt-2 flex items-center gap-1 text-[11px] font-medium text-accent-violet">
                  <Users size={11} />
                  {inst.students} students
                </span>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      {/* Testimonials */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">What learners are saying</h2>
          <p className="mb-8 text-[14px] text-ink-soft">4.8 average rating across 12,000+ reviews.</p>
        </Reveal>
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
          {TESTIMONIALS.map((t, i) => (
            <Reveal key={t.name} delay={i * 80}>
              <div className="relative h-full rounded-card border border-line bg-card p-6">
                <Quote size={28} className="absolute right-5 top-5 text-line-strong" />
                <div className="mb-3 flex items-center gap-3">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={t.avatar} alt={t.name} className="h-11 w-11 rounded-full object-cover" />
                  <div>
                    <p className="text-[13.5px] font-semibold text-ink">{t.name}</p>
                    <p className="text-[12px] text-ink-soft">{t.role}</p>
                  </div>
                </div>
                <div className="mb-2 flex items-center gap-0.5 text-accent-pink">
                  {Array.from({ length: 5 }).map((_, idx) => (
                    <Star key={idx} size={13} fill={idx < t.rating ? "currentColor" : "none"} />
                  ))}
                </div>
                <p className="text-[13.5px] leading-relaxed text-ink-soft">&quot;{t.quote}&quot;</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      {/* FAQ */}
      <section className="mx-auto max-w-4xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Frequently asked questions</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Everything you need to know before you start.</p>
        </Reveal>
        <Reveal delay={100}>
          <FaqAccordion />
        </Reveal>
      </section>

      {/* Final CTA */}
      <section className="mx-auto max-w-7xl px-4 pb-24 md:px-8">
        <Reveal>
          <div
            className="relative overflow-hidden rounded-card p-10 text-center md:p-16"
            style={{ backgroundImage: "var(--color-accent-gradient)" }}
          >
            <ShieldCheck size={28} className="mx-auto mb-4 text-white/90" />
            <h2 className="font-display text-[26px] font-bold text-white md:text-[34px]">
              Your next skill is one course away.
            </h2>
            <p className="mx-auto mt-3 max-w-lg text-[14.5px] text-white/85">
              Join 42,000+ learners already building real AI projects. 7-day refund window, no risk.
            </p>
            <div className="mt-7 flex flex-wrap items-center justify-center gap-3">
              <Link href="/courses">
                <button className="rounded-full bg-white px-6 py-3 text-[14px] font-semibold text-accent-violet transition-transform hover:scale-105">
                  Start learning free
                </button>
              </Link>
              <Link href="/register">
                <button className="rounded-full border border-white/40 px-6 py-3 text-[14px] font-semibold text-white transition-colors hover:bg-white/10">
                  Become an instructor
                </button>
              </Link>
            </div>
          </div>
        </Reveal>
      </section>
    </div>
  );
}
'@
Set-Content -LiteralPath $homePath -Value $pageContent -Encoding UTF8
Write-Host "Updated: $homePath"

Write-Host ""
Write-Host "Step 7 complete. Landing page now includes:"
Write-Host " - fake live search dropdown (LandingSearch)"
Write-Host " - scrolling trust-badge marquee"
Write-Host " - animated stats row"
Write-Host " - category cards with hover lift"
Write-Host " - How it works (3 steps)"
Write-Host " - featured courses (live data, unchanged)"
Write-Host " - popular instructors grid (fake avatars via pravatar.cc)"
Write-Host " - testimonials grid (fake reviews + star ratings)"
Write-Host " - FAQ accordion"
Write-Host " - gradient final CTA banner"
Write-Host " - scroll-reveal animation on every section (IntersectionObserver)"
Write-Host ""
Write-Host "Run: pnpm --filter web build"