# ============================================================================
# 03-refactor-marketplace.ps1
# Public Website redesign — Step 3: CompactFooter, FilterSidebar, SortDropdown,
# Pagination, MarketplaceCourseCard, Course Marketplace page.tsx
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
# 1. CompactFooter.tsx — shared by pricing/contact/legal/search pages
# ----------------------------------------------------------------------------
$compactFooterPath = Join-Path $root "components\marketing\CompactFooter.tsx"
$compactFooterContent = @'
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
Write-FileB64 -Path $compactFooterPath -Content $compactFooterContent

# ----------------------------------------------------------------------------
# 2. FilterSidebar.tsx
# ----------------------------------------------------------------------------
$filterPath = Join-Path $root "components\marketplace\FilterSidebar.tsx"
$filterContent = @'
"use client";

import { useState } from "react";
import { Check } from "lucide-react";

const categories = ["Machine Learning", "Deep Learning", "NLP", "Generative AI"];
const levels = ["Beginner", "Intermediate", "Advanced"];

function Checkbox({
  label,
  checked,
  onChange,
}: {
  label: string;
  checked: boolean;
  onChange: () => void;
}) {
  return (
    <label className="flex cursor-pointer items-center gap-2">
      <button
        type="button"
        onClick={onChange}
        className="flex h-4 w-4 items-center justify-center border transition"
        style={{
          borderColor: checked ? "var(--token-color-amberDark)" : "var(--token-color-blueprintLine)",
          backgroundColor: checked ? "var(--token-color-amber)" : "var(--token-color-surface)",
        }}
      >
        {checked && <Check className="h-3 w-3" style={{ color: "var(--token-color-inkDeep)" }} strokeWidth={3} />}
      </button>
      <span className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>{label}</span>
    </label>
  );
}

export function FilterSidebar() {
  const [selectedCategories, setSelectedCategories] = useState<string[]>(["Machine Learning"]);
  const [selectedLevels, setSelectedLevels] = useState<string[]>(["Intermediate"]);

  function toggle(list: string[], setList: (v: string[]) => void, value: string) {
    setList(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]);
  }

  return (
    <aside className="w-56 border p-6" style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}>
      <div className="flex flex-col gap-4">
        <h3
          className="text-xs font-semibold uppercase tracking-[0.1em]"
          style={{ color: "var(--token-color-inkDeep)" }}
        >
          Category
        </h3>
        <div className="flex flex-col gap-2">
          {categories.map((c) => (
            <Checkbox key={c} label={c} checked={selectedCategories.includes(c)} onChange={() => toggle(selectedCategories, setSelectedCategories, c)} />
          ))}
        </div>
      </div>

      <hr className="my-6" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }} />

      <div className="flex flex-col gap-4">
        <h3
          className="text-xs font-semibold uppercase tracking-[0.1em]"
          style={{ color: "var(--token-color-inkDeep)" }}
        >
          Level
        </h3>
        <div className="flex flex-col gap-2">
          {levels.map((l) => (
            <Checkbox key={l} label={l} checked={selectedLevels.includes(l)} onChange={() => toggle(selectedLevels, setSelectedLevels, l)} />
          ))}
        </div>
      </div>

      <hr className="my-6" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }} />

      <div className="flex flex-col gap-4">
        <h3
          className="text-xs font-semibold uppercase tracking-[0.1em]"
          style={{ color: "var(--token-color-inkDeep)" }}
        >
          Price
        </h3>
        <div className="flex flex-col gap-2">
          <input type="range" min={0} max={200} defaultValue={200} className="h-1 w-full" style={{ accentColor: "var(--token-color-amberDark)" }} />
          <div className="flex justify-between text-xs font-medium" style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-inkDeepSoft)" }}>
            <span>$0</span>
            <span>$200+</span>
          </div>
        </div>
      </div>
    </aside>
  );
}
'@
Write-FileB64 -Path $filterPath -Content $filterContent

# ----------------------------------------------------------------------------
# 3. SortDropdown.tsx
# ----------------------------------------------------------------------------
$sortPath = Join-Path $root "components\marketplace\SortDropdown.tsx"
$sortContent = @'
"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

const options = ["Most Popular", "Highest Rated", "Newest", "Price: Low to High", "Price: High to Low"];

export function SortDropdown() {
  const [value, setValue] = useState(options[0]);
  const [open, setOpen] = useState(false);

  return (
    <div className="relative">
      <button
        onClick={() => setOpen((o) => !o)}
        className="flex items-center gap-8 border px-3 py-2 text-sm"
        style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)", color: "var(--token-color-inkDeep)" }}
      >
        {value}
        <ChevronDown className="h-4 w-4" style={{ color: "var(--token-color-inkDeepSoft)" }} />
      </button>

      {open && (
        <ul
          className="absolute right-0 top-full z-10 mt-1 w-48 border shadow-[0px_4px_20px_0px_rgba(15,23,42,0.08)]"
          style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}
        >
          {options.map((opt) => (
            <li key={opt}>
              <button
                onClick={() => { setValue(opt); setOpen(false); }}
                className="block w-full px-3 py-2 text-left text-sm hover:opacity-70"
                style={{ color: "var(--token-color-inkDeep)" }}
              >
                {opt}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
'@
Write-FileB64 -Path $sortPath -Content $sortContent

# ----------------------------------------------------------------------------
# 4. Pagination.tsx
# ----------------------------------------------------------------------------
$paginationPath = Join-Path $root "components\marketplace\Pagination.tsx"
$paginationContent = @'
"use client";

import { useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

export function Pagination({ totalPages = 12 }: { totalPages?: number }) {
  const [page, setPage] = useState(1);
  const pages = [1, 2, 3];

  const lineColor = "var(--token-color-blueprintLine)";
  const inkSoft = "var(--token-color-inkDeepSoft)";

  return (
    <div className="flex items-center justify-center gap-2" style={{ fontFamily: "var(--token-font-monoFamily)" }}>
      <button
        aria-label="Previous page"
        onClick={() => setPage((p) => Math.max(1, p - 1))}
        className="flex h-10 w-8 items-center justify-center border"
        style={{ borderColor: lineColor, color: inkSoft }}
      >
        <ChevronLeft className="h-3 w-3" />
      </button>

      {pages.map((p) => (
        <button
          key={p}
          onClick={() => setPage(p)}
          className="flex h-10 w-10 items-center justify-center text-sm font-semibold"
          style={
            page === p
              ? { backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }
              : { border: `1px solid ${lineColor}`, color: inkSoft }
          }
        >
          {p}
        </button>
      ))}

      <span className="px-1 text-base" style={{ color: inkSoft }}>...</span>

      <button
        onClick={() => setPage(totalPages)}
        className="flex h-10 w-10 items-center justify-center text-sm font-semibold"
        style={
          page === totalPages
            ? { backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }
            : { border: `1px solid ${lineColor}`, color: inkSoft }
        }
      >
        {totalPages}
      </button>

      <button
        aria-label="Next page"
        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
        className="flex h-10 w-8 items-center justify-center border"
        style={{ borderColor: lineColor, color: inkSoft }}
      >
        <ChevronRight className="h-3 w-3" />
      </button>
    </div>
  );
}
'@
Write-FileB64 -Path $paginationPath -Content $paginationContent

# ----------------------------------------------------------------------------
# 5. MarketplaceCourseCard.tsx
# ----------------------------------------------------------------------------
$mktCardPath = Join-Path $root "components\marketplace\MarketplaceCourseCard.tsx"
$mktCardContent = @'
import Image from "next/image";
import { Star } from "lucide-react";

export interface MarketplaceCourseCardProps {
  title: string;
  provider: string;
  rating: number;
  reviews: string;
  price: string;
  priceSuffix?: string;
  categoryTag: string;
  levelTag: string;
  badge?: { label: string; variant: "dark" | "light" };
  image: string;
}

export function MarketplaceCourseCard({
  title,
  provider,
  rating,
  reviews,
  price,
  priceSuffix,
  categoryTag,
  levelTag,
  badge,
  image,
}: MarketplaceCourseCardProps) {
  return (
    <article className="group flex flex-1 flex-col overflow-hidden border" style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}>
      <div className="relative h-40 w-full overflow-hidden" style={{ backgroundColor: "var(--token-color-blueprintLineSoft)" }}>
        <Image src={image} alt={title} fill sizes="(max-width: 768px) 100vw, 400px" className="object-cover transition-transform duration-300 group-hover:scale-[1.03]" />
        {badge && (
          <span
            className="absolute left-0 top-0 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-wide"
            style={
              badge.variant === "dark"
                ? { backgroundColor: "var(--token-color-teal)", color: "var(--token-color-tealTint)" }
                : { backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }
            }
          >
            {badge.label}
          </span>
        )}
      </div>

      <div className="flex flex-1 flex-col justify-between p-6">
        <div className="flex flex-col gap-2">
          <div className="flex items-start gap-2" style={{ fontFamily: "var(--token-font-monoFamily)" }}>
            <span className="px-2 py-0.5 text-[10px] font-medium" style={{ backgroundColor: "var(--token-color-amberTint)", color: "var(--token-color-amberDark)" }}>
              {categoryTag}
            </span>
            <span className="px-2 py-0.5 text-[10px] font-medium" style={{ backgroundColor: "var(--token-color-bg)", color: "var(--token-color-inkDeepSoft)" }}>
              {levelTag}
            </span>
          </div>

          <h3
            className="line-clamp-2 text-lg font-semibold leading-7"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            {title}
          </h3>

          <p className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>{provider}</p>
        </div>

        <div className="mt-4 flex flex-col gap-1 border-t pt-4" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}>
          <div className="flex items-center gap-1">
            <Star className="h-[15px] w-[15px]" style={{ color: "var(--token-color-amberDark)" }} fill="currentColor" strokeWidth={0} />
            <span className="text-sm font-semibold" style={{ color: "var(--token-color-inkDeep)" }}>{rating}</span>
            <span className="text-xs" style={{ color: "var(--token-color-inkDeepSoft)" }}>({reviews})</span>
          </div>

          <div className="flex items-baseline gap-1" style={{ fontFamily: "var(--token-font-monoFamily)" }}>
            <span className="text-2xl font-semibold" style={{ color: "var(--token-color-inkDeep)" }}>{price}</span>
            {priceSuffix && <span className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>{priceSuffix}</span>}
          </div>
        </div>
      </div>
    </article>
  );
}
'@
Write-FileB64 -Path $mktCardPath -Content $mktCardContent

# ----------------------------------------------------------------------------
# 6. Course Marketplace page.tsx
# ----------------------------------------------------------------------------
$marketplacePagePath = Join-Path $root "app\(marketing)\courses\page.tsx"
$marketplacePageContent = @'
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { FilterSidebar } from "@/components/marketplace/FilterSidebar";
import { SortDropdown } from "@/components/marketplace/SortDropdown";
import { Pagination } from "@/components/marketplace/Pagination";
import { SpecLabel } from "@/components/marketing/BlueprintMark";
import {
  MarketplaceCourseCard,
  type MarketplaceCourseCardProps,
} from "@/components/marketplace/MarketplaceCourseCard";

const courses: MarketplaceCourseCardProps[] = [
  {
    title: "Complete A.I. & Machine Learning Bootcamp",
    provider: "Dr. Angela Yu",
    rating: 4.8,
    reviews: "12.4k",
    price: "$89.99",
    categoryTag: "Machine Learning",
    levelTag: "Beginner",
    badge: { label: "Bestseller", variant: "light" },
    image: "https://images.unsplash.com/photo-1550439062-609e1531270e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Deep Learning Specialization",
    provider: "DeepLearning.AI",
    rating: 4.9,
    reviews: "89.1k",
    price: "$49.00",
    priceSuffix: "/mo",
    categoryTag: "Deep Learning",
    levelTag: "Advanced",
    image: "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Natural Language Processing with Transformers",
    provider: "Hugging Face",
    rating: 4.7,
    reviews: "2.3k",
    price: "$129.99",
    categoryTag: "NLP",
    levelTag: "Intermediate",
    badge: { label: "New", variant: "dark" },
    image: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
];

export default function CourseMarketplacePage() {
  return (
    <div className="flex min-h-screen flex-col" style={{ backgroundColor: "var(--token-color-bg)" }}>
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-6 px-12 pb-40 pt-16 md:flex-row md:gap-8">
        <div className="w-full shrink-0 md:w-56">
          <FilterSidebar />
        </div>

        <div className="flex flex-1 flex-col gap-6">
          <div className="flex flex-col gap-3 pb-2">
            <SpecLabel index="—" label="Marketplace" />
            <div className="flex items-center justify-between">
              <div className="flex items-baseline gap-3">
                <h1
                  className="text-2xl font-semibold"
                  style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
                >
                  Explore Courses
                </h1>
                <span className="text-sm" style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-inkDeepSoft)" }}>
                  (1,204 results)
                </span>
              </div>
              <SortDropdown />
            </div>
          </div>

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {courses.map((course) => (
              <MarketplaceCourseCard key={course.title} {...course} />
            ))}
          </div>

          <div className="pt-10">
            <Pagination totalPages={12} />
          </div>
        </div>
      </main>

      <CompactFooter />
    </div>
  );
}
'@
Write-FileB64 -Path $marketplacePagePath -Content $marketplacePageContent

Write-Host ""
Write-Host "Step 3 done: CompactFooter + Course Marketplace listing (FilterSidebar, SortDropdown, Pagination, MarketplaceCourseCard, page.tsx) refactored."
Write-Host "Next candidates: Course Detail page, Cart/Checkout, or Login/Register."