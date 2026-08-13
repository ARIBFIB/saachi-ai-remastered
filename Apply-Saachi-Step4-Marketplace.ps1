<#
================================================================================
Apply-Saachi-Step4-Marketplace.ps1
STEP 4 of the design-system rollout: course marketplace listing page
  - components/marketplace/FilterSidebar.tsx
  - components/marketplace/SortDropdown.tsx
  - components/marketplace/Pagination.tsx
  - components/marketplace/MarketplaceCourseCard.tsx
  - components/marketplace/CategoryBanner.tsx
  - components/marketplace/CategoryChips.tsx
  - components/marketplace/CategoryCourseCard.tsx
  - app/(marketing)/courses/page.tsx

USAGE:
  1. Save this file into your repo root (same folder as previous steps), e.g.:
     D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2\Apply-Saachi-Step4-Marketplace.ps1
  2. In PowerShell (prompt: PS D:\...\SAI2>) run:
       .\Apply-Saachi-Step4-Marketplace.ps1
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

Write-Host "=== STEP 4: Marketplace listing page ==="
Write-Host "Target repo root: $root"
Write-Host ""

# ------------------------------------------------------------------
# apps/web/components/marketplace/FilterSidebar.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketplace\FilterSidebar.tsx" @'
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
        className="flex h-4 w-4 items-center justify-center border-2 transition"
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
    <aside className="w-56 border-2 p-6" style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}>
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

# ------------------------------------------------------------------
# apps/web/components/marketplace/SortDropdown.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketplace\SortDropdown.tsx" @'
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
        className="flex items-center gap-8 border-2 px-3 py-2 text-sm"
        style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)", color: "var(--token-color-inkDeep)" }}
      >
        {value}
        <ChevronDown className="h-4 w-4" style={{ color: "var(--token-color-inkDeepSoft)" }} />
      </button>

      {open && (
        <ul
          className="absolute right-0 top-full z-10 mt-1 w-48 border-2 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.08)]"
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

# ------------------------------------------------------------------
# apps/web/components/marketplace/Pagination.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketplace\Pagination.tsx" @'
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
        className="flex h-10 w-8 items-center justify-center border-2"
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
              : { borderWidth: "1px", borderStyle: "solid", borderColor: lineColor, color: inkSoft }
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
            : { borderWidth: "1px", borderStyle: "solid", borderColor: lineColor, color: inkSoft }
        }
      >
        {totalPages}
      </button>

      <button
        aria-label="Next page"
        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
        className="flex h-10 w-8 items-center justify-center border-2"
        style={{ borderColor: lineColor, color: inkSoft }}
      >
        <ChevronRight className="h-3 w-3" />
      </button>
    </div>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketplace/MarketplaceCourseCard.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketplace\MarketplaceCourseCard.tsx" @'
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
    <article className="group flex flex-1 flex-col overflow-hidden border-2" style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}>
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

# ------------------------------------------------------------------
# apps/web/components/marketplace/CategoryBanner.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketplace\CategoryBanner.tsx" @'
interface CategoryBannerProps {
  title: string;
  description: string;
  image?: string;
}

export function CategoryBanner({ title, description, image }: CategoryBannerProps) {
  return (
    <div className="relative self-stretch overflow-hidden rounded-xl bg-[var(--token-color-surfaceAlt)]">
      <img
        src={image ?? "https://placehold.co/1184x320"}
        alt=""
        className="absolute left-0 top-0 h-80 w-full object-cover opacity-20"
      />

      <div className="relative flex min-h-80 flex-col justify-end gap-4 px-10 pb-10 pt-32">
        <h1 className="max-w-[1104px] text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
          {title}
        </h1>
        <p className="max-w-[672px] text-lg leading-7 text-[var(--token-color-inkSoft)]">
          {description}
        </p>
      </div>
    </div>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketplace/CategoryChips.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketplace\CategoryChips.tsx" @'
"use client";

import { useState } from "react";

interface CategoryChipsProps {
  chips: string[];
  defaultActive?: string;
  onChange?: (chip: string) => void;
}

export function CategoryChips({ chips, defaultActive, onChange }: CategoryChipsProps) {
  const [active, setActive] = useState(defaultActive ?? chips[0]);

  function handleSelect(chip: string) {
    setActive(chip);
    onChange?.(chip);
  }

  return (
    <div className="flex flex-wrap items-start gap-2 self-stretch pt-4">
      {chips.map((chip) => {
        const isActive = chip === active;
        return (
          <button
            key={chip}
            type="button"
            onClick={() => handleSelect(chip)}
            className={`rounded-full border-2 px-4 py-2 text-sm font-semibold tracking-wide transition ${
              isActive
                ? "border-[var(--token-color-primary)]/20 bg-[var(--token-color-primary)]/10 text-[var(--token-color-primary)]"
                : "border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] text-[var(--token-color-inkSoft)]"
            }`}
          >
            {chip}
          </button>
        );
      })}
    </div>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/components/marketplace/CategoryCourseCard.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\components\marketplace\CategoryCourseCard.tsx" @'
import Image from "next/image";
import { Star } from "lucide-react";

export interface CategoryCourseCardProps {
  title: string;
  description: string;
  levelTag: string;
  rating: number;
  reviews: string;
  price: string;
  image: string;
}

export function CategoryCourseCard({
  title,
  description,
  levelTag,
  rating,
  reviews,
  price,
  image,
}: CategoryCourseCardProps) {
  return (
    <article className="flex flex-1 flex-col overflow-hidden rounded-xl border-2 border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] shadow-[var(--token-shadow-sm)]">
      <div className="relative h-40 w-full shrink-0 overflow-hidden bg-[var(--token-color-surfaceAlt)]">
        <Image
          src={image}
          alt={title}
          fill
          sizes="(max-width: 768px) 100vw, 320px"
          className="object-cover"
        />
        <span className="absolute right-2 top-2 bg-[var(--token-color-bg)]/90 px-2 pb-1 pt-[3px] text-xs font-medium text-[var(--token-color-ink)] backdrop-blur-[2px]">
          {levelTag}
        </span>
      </div>

      <div className="flex flex-1 flex-col justify-between p-6">
        <div className="flex flex-col gap-1 pb-4">
          <h3 className="line-clamp-2 text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">
            {title}
          </h3>
          <p className="line-clamp-3 text-base text-[var(--token-color-inkSoft)]">
            {description}
          </p>
        </div>

        <div className="flex items-center justify-between border-t border-[var(--token-color-border)]/50 pt-4">
          <div className="flex items-center gap-1">
            <Star className="h-3.5 w-3.5 text-[var(--token-color-textMuted)]" fill="currentColor" strokeWidth={0} />
            <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">
              {rating} ({reviews})
            </span>
          </div>
          <span className="text-sm font-bold tracking-wide text-[var(--token-color-primary)]">
            {price}
          </span>
        </div>
      </div>
    </article>
  );
}
'@

# ------------------------------------------------------------------
# apps/web/app/(marketing)/courses/page.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\(marketing)\courses\page.tsx" @'
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
            <SpecLabel index="--" label="Marketplace" />
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

Write-Host ""
Write-Host "=== STEP 4 complete: $writtenCount file(s) written. ==="
if (Test-Path $backupDir) {
    Write-Host "Backups of any overwritten files: $backupDir"
}