# ============================================================================
# fix-colors-and-images.ps1
# 1) Replaces var(--token-...) arbitrary classes with literal hex/shadow values
#    (guarantees Tailwind renders colors even if the token CSS pipeline has issues)
# 2) Swaps placehold.co placeholder images for real Unsplash photos
# 3) Adds images.unsplash.com to next.config.js remotePatterns
#
# Run this from the SAI2 repo root:
#   PS D:\...\SAI2> .\fix-colors-and-images.ps1
# ============================================================================
$ErrorActionPreference = 'Stop'

function Write-CodeFile($Path, $Content) {
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $Path -Value $Content -Encoding UTF8 -NoNewline
    Write-Host "Updated: $Path"
}

# ---- apps/web/components/marketing/Header.tsx ----
$content = @'
import Link from "next/link";
import { Search, ShoppingCart, Bell, Zap } from "lucide-react";

export function Header() {
  return (
    <header className="sticky top-0 z-50 w-full bg-[#F8FAFC] shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]">
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        {/* Left: Logo + Search */}
        <div className="flex items-center gap-10">
          <Link href="/" className="flex items-center gap-2">
            <Zap
              className="h-[18px] w-[18px] text-[#3525CD]"
              fill="currentColor"
              strokeWidth={0}
            />
            <span className="text-2xl font-black text-[#3525CD]">
              Saachi AI
            </span>
          </Link>

          <div className="flex items-center gap-1 rounded-sm border border-[#CBD5E1] bg-gray-100 px-2 py-1">
            <Search className="h-[15px] w-[15px] text-slate-500" />
            <input
              type="text"
              placeholder="Search courses, skills..."
              className="w-64 bg-transparent px-3 py-2 text-sm font-semibold tracking-wide text-slate-600 placeholder:text-slate-600 focus:outline-none"
            />
          </div>
        </div>

        {/* Right: Nav links + actions */}
        <div className="flex items-center gap-6">
          <nav className="flex items-center gap-5">
            <Link
              href="/courses"
              className="border-b-2 border-[#3525CD] pb-[3px] text-sm font-bold tracking-wide text-[#3525CD]"
            >
              Marketplace
            </Link>
            <Link
              href="/categories"
              className="text-sm font-semibold tracking-wide text-slate-600 hover:text-[#3525CD]"
            >
              Categories
            </Link>
          </nav>

          <div className="flex items-center gap-2">
            <button
              aria-label="Cart"
              className="rounded-full p-2 text-slate-600 hover:bg-gray-100"
            >
              <ShoppingCart className="h-5 w-5" />
            </button>
            <button
              aria-label="Notifications"
              className="rounded-full p-2 text-slate-600 hover:bg-gray-100"
            >
              <Bell className="h-5 w-5" />
            </button>

            <Link
              href="/login"
              className="ml-2 rounded-sm bg-[#3525CD] px-6 py-2 text-sm font-semibold tracking-wide text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[#2A1DA3]"
            >
              Sign In
            </Link>

            <Link href="/settings/profile" className="ml-2">
              <span className="block h-8 w-8 overflow-hidden rounded-full border border-[#CBD5E1] bg-gray-200" />
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketing/Header.tsx" -Content $content

# ---- apps/web/components/marketing/HeroSection.tsx ----
$content = @'
import Link from "next/link";
import { Sparkles } from "lucide-react";
import Image from "next/image";

export function HeroSection() {
  return (
    <section className="w-full border-b border-[#CBD5E1] bg-[#FFFFFF]">
      <div className="mx-auto flex min-h-[640px] max-w-[1280px] items-center justify-center gap-10 px-6 py-12">
        {/* Left: copy */}
        <div className="relative h-96 flex-1">
          <div className="inline-flex items-center gap-1 rounded-sm bg-[#E0E7FF] px-2 py-1">
            <Sparkles className="h-3.5 w-3.5 text-gray-500" />
            <span className="text-xs font-medium text-gray-500">
              New: Advanced Generative Models Path
            </span>
          </div>

          <h1 className="mt-6 w-[596px] max-w-full text-5xl font-bold leading-[52.8px] text-[#18181B]">
            Master AI,
            <br />
            Master the Future
          </h1>

          <p className="mt-6 max-w-96 text-lg leading-7 text-[#3F3F46]">
            The world&apos;s leading AI-skills marketplace. Join thousands of
            professionals accelerating their careers with cutting-edge,
            expert-led artificial intelligence courses.
          </p>

          <div className="mt-8 flex items-center gap-4">
            <Link
              href="/courses"
              className="rounded-lg bg-[#3525CD] px-10 py-4 text-sm font-semibold tracking-wide text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[#2A1DA3]"
            >
              Explore Courses
            </Link>
            <Link
              href="/pricing"
              className="rounded-lg border border-[#CBD5E1] bg-[#F8FAFC] px-10 py-4 text-sm font-semibold tracking-wide text-slate-600 hover:bg-gray-100"
            >
              For Enterprise
            </Link>
          </div>
        </div>

        {/* Right: image */}
        <div className="relative min-h-96 flex-1 self-stretch overflow-hidden rounded-xl shadow-[0px_10px_32px_0px_rgba(15,23,42,0.12)]">
          <Image
            src="https://images.unsplash.com/photo-1620712943543-95fc69b12dcc?auto=format&fit=crop&w=1200&q=80"
            alt="AI Learning Concept"
            fill
            className="object-cover"
            priority
          />
          <div className="absolute inset-0 mix-blend-overlay bg-gradient-to-br from-[#3525CD]/10 to-transparent" />
        </div>
      </div>
    </section>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketing/HeroSection.tsx" -Content $content

# ---- apps/web/components/marketing/CourseCard.tsx ----
$content = @'
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

const tagStyles: Record<NonNullable<CourseCardProps["tagVariant"]>, string> = {
  default: "bg-[#E0E7FF] text-gray-500",
  highlight: "bg-[#3525CD]/10 text-[#3525CD]",
  neutral: "bg-zinc-200 text-zinc-900",
};

export function CourseCard({
  title,
  instructor,
  rating,
  reviews,
  tag,
  tagVariant = "default",
  image,
}: CourseCardProps) {
  return (
    <article className="flex flex-1 flex-col overflow-hidden rounded-xl bg-[#FFFFFF] shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="relative h-40 w-full overflow-hidden bg-gray-100">
        <Image src={image} alt={title} fill className="object-cover" />
      </div>

      <div className="flex flex-col gap-4 p-6">
        <span
          className={`inline-block w-fit rounded-sm px-2 pb-1 pt-[3px] text-xs font-medium ${tagStyles[tagVariant]}`}
        >
          {tag}
        </span>

        <h3 className="text-2xl font-semibold leading-8 text-[#18181B]">
          {title}
        </h3>

        <div className="flex flex-col gap-1">
          <p className="text-sm text-[#3F3F46]">{instructor}</p>
          <div className="flex items-center gap-2">
            <div className="flex items-center gap-1">
              <Star className="h-3.5 w-3.5 text-[#005338]" fill="currentColor" strokeWidth={0} />
              <span className="text-sm font-semibold tracking-wide text-[#005338]">
                {rating}
              </span>
            </div>
            <span className="text-sm text-gray-500">({reviews} reviews)</span>
          </div>
        </div>
      </div>
    </article>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketing/CourseCard.tsx" -Content $content

# ---- apps/web/components/marketing/TrendingCourses.tsx ----
$content = @'
import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { CourseCard, type CourseCardProps } from "./CourseCard";

const courses: CourseCardProps[] = [
  {
    title: "AI Ethics & Responsible…",
    instructor: "Dr. Sarah Jenkins",
    rating: 4.9,
    reviews: "2.4k",
    tag: "Foundational",
    tagVariant: "default",
    image: "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Mastering Prompt Engineering",
    instructor: "Alex Chen",
    rating: 4.8,
    reviews: "8.1k",
    tag: "Bestseller",
    tagVariant: "highlight",
    image: "https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Generative AI & Digital Art",
    instructor: "Elena Rodriguez",
    rating: 4.7,
    reviews: "1.2k",
    tag: "Creative",
    tagVariant: "default",
    image: "https://images.unsplash.com/photo-1550439062-609e1531270e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "LLM Ops & Deployment…",
    instructor: "David Kim, PhD",
    rating: 4.9,
    reviews: "940",
    tag: "Advanced",
    tagVariant: "neutral",
    image: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
];

export function TrendingCourses() {
  return (
    <section className="w-full bg-[#F8FAFC] py-12">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="flex items-end justify-between">
          <div className="flex flex-col gap-1">
            <h2 className="text-2xl font-semibold text-[#18181B]">
              Trending Courses
            </h2>
            <p className="text-base text-[#3F3F46]">
              Highly rated programs to start your journey.
            </p>
          </div>
          <Link
            href="/courses"
            className="flex items-center gap-1 text-sm font-semibold tracking-wide text-[#3525CD]"
          >
            View all
            <ArrowRight className="h-3 w-3" />
          </Link>
        </div>

        <div className="flex justify-center gap-6">
          {courses.map((course) => (
            <CourseCard key={course.title} {...course} />
          ))}
        </div>
      </div>
    </section>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketing/TrendingCourses.tsx" -Content $content

# ---- apps/web/components/marketing/CategoryGrid.tsx ----
$content = @'
import Link from "next/link";
import { MessageSquare, Eye, Bot, LineChart } from "lucide-react";

const categories = [
  { label: "NLP & Language", icon: MessageSquare, href: "/categories/nlp" },
  { label: "Computer Vision", icon: Eye, href: "/categories/computer-vision" },
  { label: "Robotics", icon: Bot, href: "/categories/robotics" },
  { label: "AI Strategy", icon: LineChart, href: "/categories/ai-strategy" },
];

export function CategoryGrid() {
  return (
    <section className="w-full border-b border-t border-[#CBD5E1] bg-[#FFFFFF] py-12">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="mx-auto flex max-w-[672px] flex-col items-center gap-2 text-center">
          <h2 className="text-2xl font-semibold text-[#18181B]">
            Explore by Category
          </h2>
          <p className="text-base text-[#3F3F46]">
            Find specialized tracks tailored to your career goals.
          </p>
        </div>

        <div className="flex justify-center gap-4">
          {categories.map(({ label, icon: Icon, href }) => (
            <Link
              key={label}
              href={href}
              className="flex flex-1 flex-col items-center gap-3.5 rounded-xl border border-[#CBD5E1] bg-[#F8FAFC] p-10 transition hover:border-[#3525CD]"
            >
              <span className="flex h-16 w-16 items-center justify-center rounded-full bg-[#3525CD]/10">
                <Icon className="h-7 w-7 text-[#3525CD]" />
              </span>
              <span className="text-sm font-semibold tracking-wide text-[#18181B]">
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
Write-CodeFile -Path "apps/web/components/marketing/CategoryGrid.tsx" -Content $content

# ---- apps/web/components/marketing/WhySaachi.tsx ----
$content = @'
import { GraduationCap, Wrench, BadgeCheck } from "lucide-react";

const reasons = [
  {
    icon: GraduationCap,
    title: "Industry Experts",
    description:
      "Learn directly from senior engineers and researchers from top tech companies.",
  },
  {
    icon: Wrench,
    title: "Hands-on Projects",
    description:
      "Build real-world AI applications in cloud environments straight from your browser.",
  },
  {
    icon: BadgeCheck,
    title: "AI-Verified Certificates",
    description:
      "Earn credentials verified on the blockchain, trusted by top employers globally.",
  },
];

export function WhySaachi() {
  return (
    <section className="w-full bg-[#F8FAFC] pb-20 pt-12">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <h2 className="text-center text-2xl font-semibold text-[#18181B]">
          Why Learn with Saachi?
        </h2>

        <div className="flex justify-center gap-10 pt-6">
          {reasons.map(({ icon: Icon, title, description }) => (
            <div
              key={title}
              className="flex flex-1 flex-col items-center gap-4 p-6 text-center"
            >
              <span className="flex h-12 w-12 items-center justify-center rounded-sm bg-gray-200">
                <Icon className="h-6 w-6 text-[#3525CD]" />
              </span>
              <h3 className="text-lg font-semibold text-[#18181B]">
                {title}
              </h3>
              <p className="max-w-[280px] text-base text-[#3F3F46]">
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
Write-CodeFile -Path "apps/web/components/marketing/WhySaachi.tsx" -Content $content

# ---- apps/web/components/marketing/Newsletter.tsx ----
$content = @'
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
    <div className="mx-auto flex w-full max-w-[896px] flex-col items-center justify-between gap-6 rounded-xl bg-[#3525CD] p-10 shadow-[0px_10px_32px_0px_rgba(15,23,42,0.12)] md:flex-row">
      <div className="flex max-w-96 flex-col gap-2">
        <h2 className="text-2xl font-semibold text-white">
          Stay ahead of the curve.
        </h2>
        <p className="text-base text-violet-300">
          Join our newsletter for weekly AI insights, course updates, and
          exclusive discounts.
        </p>
      </div>

      <form
        onSubmit={handleSubmit}
        className="flex h-12 w-full max-w-96 items-center overflow-hidden rounded-sm bg-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"
      >
        <input
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Enter your email"
          className="h-full flex-1 px-4 py-2.5 text-base text-[#18181B] placeholder:text-gray-500 focus:outline-none"
        />
        <button
          type="submit"
          className="m-1 rounded-sm bg-slate-600 px-6 py-2 text-sm font-semibold tracking-wide text-white hover:bg-slate-700"
        >
          Subscribe
        </button>
      </form>
    </div>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketing/Newsletter.tsx" -Content $content

# ---- apps/web/components/marketing/Footer.tsx ----
$content = @'
import Link from "next/link";
import { Zap, Globe, Share2 } from "lucide-react";

const columns = [
  {
    title: "Platform",
    links: [
      { label: "Marketplace", href: "/courses" },
      { label: "Enterprise", href: "/pricing" },
      { label: "Instructor Handbook", href: "/instructor/handbook" },
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
    <footer className="w-full bg-zinc-200">
      <div className="mx-auto grid max-w-[1280px] grid-cols-1 gap-8 px-6 py-10 md:grid-cols-4">
        <div className="flex flex-col gap-4">
          <Link href="/" className="flex items-center gap-1">
            <Zap
              className="h-[18px] w-[18px] text-[#3525CD]"
              fill="currentColor"
              strokeWidth={0}
            />
            <span className="text-base font-bold text-[#3525CD]">
              Saachi AI
            </span>
          </Link>
          <p className="text-sm text-[#3F3F46]">
            Empowering the next generation of builders with cutting-edge
            artificial intelligence skills.
          </p>
        </div>

        {columns.map((col) => (
          <div key={col.title} className="flex flex-col gap-4">
            <h4 className="text-sm font-bold tracking-wide text-[#18181B]">
              {col.title}
            </h4>
            <nav className="flex flex-col gap-2">
              {col.links.map((link) => (
                <Link
                  key={link.label}
                  href={link.href}
                  className="text-sm text-[#3F3F46] hover:text-[#3525CD]"
                >
                  {link.label}
                </Link>
              ))}
            </nav>
          </div>
        ))}
      </div>

      <div className="mx-auto flex max-w-[1280px] items-center justify-between border-t border-[#CBD5E1] px-6 py-6">
        <p className="text-xs font-medium text-[#3F3F46]">
          © {new Date().getFullYear()} Saachi AI Marketplace. Empowering the
          future of skills.
        </p>
        <div className="flex items-center gap-4 text-slate-600">
          <Globe className="h-[18px] w-[18px]" />
          <Share2 className="h-[18px] w-[18px]" />
        </div>
      </div>
    </footer>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketing/Footer.tsx" -Content $content

# ---- apps/web/next.config.js: add images.unsplash.com ----
$ncPath = "apps\web\next.config.js"
if (Test-Path $ncPath) {
    $nc = Get-Content -Path $ncPath -Raw
    if ($nc -notmatch 'images\.unsplash\.com') {
        $search = '{ protocol: "https", hostname: "picsum.photos" }'
        $replace = '{ protocol: "https", hostname: "picsum.photos" },' + "`n      " + '{ protocol: "https", hostname: "images.unsplash.com" }'
        if ($nc -match [regex]::Escape($search)) {
            $nc = $nc -replace [regex]::Escape($search), $replace
            Set-Content -Path $ncPath -Value $nc -Encoding UTF8 -NoNewline
            Write-Host "Updated: $ncPath (added images.unsplash.com)" -ForegroundColor Green
        } else {
            Write-Host "Could not auto-patch $ncPath -- add manually: { protocol: 'https', hostname: 'images.unsplash.com' }" -ForegroundColor Yellow
        }
    } else {
        Write-Host "images.unsplash.com already configured." -ForegroundColor Yellow
    }
} else {
    Write-Host "WARNING: $ncPath not found, skipping." -ForegroundColor Yellow
}

Write-Host "`nDone. Restart your dev server:" -ForegroundColor Cyan
Write-Host "  Ctrl+C, then: pnpm --filter web dev"