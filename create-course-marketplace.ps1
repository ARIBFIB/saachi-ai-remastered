# ============================================================================
# create-course-marketplace.ps1
# Scaffolds the Course Marketplace page + components into apps/web
# Run this from the SAI2 repo root:
#   PS D:\...\SAI2> .\create-course-marketplace.ps1
# ============================================================================
$ErrorActionPreference = 'Stop'

function Write-CodeFile($Path, $Content) {
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $Path -Value $Content -Encoding UTF8 -NoNewline
    Write-Host "Created: $Path"
}

# ---- apps/web/components/marketplace/FilterSidebar.tsx ----
$content = @'
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
        className={`flex h-4 w-4 items-center justify-center rounded-sm border transition ${
          checked
            ? "border-[#3525CD] bg-[#3525CD]"
            : "border-[#C7C4D8] bg-white"
        }`}
      >
        {checked && <Check className="h-3 w-3 text-white" strokeWidth={3} />}
      </button>
      <span className="text-base text-slate-600">{label}</span>
    </label>
  );
}

export function FilterSidebar() {
  const [selectedCategories, setSelectedCategories] = useState<string[]>([
    "Machine Learning",
  ]);
  const [selectedLevels, setSelectedLevels] = useState<string[]>([
    "Intermediate",
  ]);

  function toggle(
    list: string[],
    setList: (v: string[]) => void,
    value: string
  ) {
    setList(
      list.includes(value) ? list.filter((v) => v !== value) : [...list, value]
    );
  }

  return (
    <aside className="w-56 rounded-xl border border-slate-300/30 bg-white p-6 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="flex flex-col gap-4">
        <h3 className="text-sm font-semibold tracking-wide text-zinc-900">
          Category
        </h3>
        <div className="flex flex-col gap-2">
          {categories.map((c) => (
            <Checkbox
              key={c}
              label={c}
              checked={selectedCategories.includes(c)}
              onChange={() => toggle(selectedCategories, setSelectedCategories, c)}
            />
          ))}
        </div>
      </div>

      <hr className="my-6 border-slate-300/50" />

      <div className="flex flex-col gap-4">
        <h3 className="text-sm font-semibold tracking-wide text-zinc-900">
          Level
        </h3>
        <div className="flex flex-col gap-2">
          {levels.map((l) => (
            <Checkbox
              key={l}
              label={l}
              checked={selectedLevels.includes(l)}
              onChange={() => toggle(selectedLevels, setSelectedLevels, l)}
            />
          ))}
        </div>
      </div>

      <hr className="my-6 border-slate-300/50" />

      <div className="flex flex-col gap-4">
        <h3 className="text-sm font-semibold tracking-wide text-zinc-900">
          Price
        </h3>
        <div className="flex flex-col gap-2">
          <input
            type="range"
            min={0}
            max={200}
            defaultValue={200}
            className="h-1 w-full accent-[#3525CD]"
          />
          <div className="flex justify-between text-xs font-medium text-gray-500">
            <span>$0</span>
            <span>$200+</span>
          </div>
        </div>
      </div>
    </aside>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketplace/FilterSidebar.tsx" -Content $content

# ---- apps/web/components/marketplace/MarketplaceCourseCard.tsx ----
$content = @'
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
    <article className="flex flex-1 flex-col overflow-hidden rounded-xl border border-slate-300/30 bg-white shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="relative h-40 w-full overflow-hidden bg-zinc-200">
        <Image
          src={image}
          alt={title}
          fill
          sizes="(max-width: 768px) 100vw, 400px"
          className="object-cover"
        />
        {badge && (
          <span
            className={`absolute left-2 top-2 rounded-sm px-2 pb-1 pt-[3px] text-xs font-medium shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] ${
              badge.variant === "dark"
                ? "bg-emerald-700 text-emerald-300"
                : "bg-white/90 text-zinc-900 backdrop-blur-[2px]"
            }`}
          >
            {badge.label}
          </span>
        )}
      </div>

      <div className="flex flex-1 flex-col justify-between p-6">
        <div className="flex flex-col gap-2">
          <div className="flex items-start gap-2">
            <span className="bg-[#E0E7FF] px-2 pb-[2.39px] pt-px text-xs font-medium text-gray-500">
              {categoryTag}
            </span>
            <span className="bg-gray-200 px-2 pb-[2.39px] pt-px text-xs font-medium text-slate-600">
              {levelTag}
            </span>
          </div>

          <h3 className="line-clamp-2 text-lg font-bold leading-7 text-zinc-900">
            {title}
          </h3>

          <p className="text-sm text-slate-600">{provider}</p>
        </div>

        <div className="mt-4 flex flex-col gap-1">
          <div className="flex items-center gap-1">
            <Star className="h-[15px] w-[15px] text-[#3525CD]" fill="currentColor" strokeWidth={0} />
            <span className="text-sm font-semibold tracking-wide text-zinc-900">
              {rating}
            </span>
            <span className="text-xs font-medium text-gray-500">({reviews})</span>
          </div>

          <div className="flex items-baseline gap-1">
            <span className="text-2xl font-bold text-zinc-900">{price}</span>
            {priceSuffix && (
              <span className="text-base text-slate-600">{priceSuffix}</span>
            )}
          </div>
        </div>
      </div>
    </article>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketplace/MarketplaceCourseCard.tsx" -Content $content

# ---- apps/web/components/marketplace/Pagination.tsx ----
$content = @'
"use client";

import { useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

export function Pagination({ totalPages = 12 }: { totalPages?: number }) {
  const [page, setPage] = useState(1);

  const pages = [1, 2, 3];

  return (
    <div className="flex items-center justify-center gap-2">
      <button
        aria-label="Previous page"
        onClick={() => setPage((p) => Math.max(1, p - 1))}
        className="flex h-10 w-8 items-center justify-center border border-slate-300 text-slate-600 hover:bg-gray-100"
      >
        <ChevronLeft className="h-3 w-3" />
      </button>

      {pages.map((p) => (
        <button
          key={p}
          onClick={() => setPage(p)}
          className={`flex h-10 w-10 items-center justify-center text-sm font-semibold tracking-wide ${
            page === p
              ? "bg-[#3525CD] font-bold text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"
              : "border border-slate-300 text-slate-600 hover:bg-gray-100"
          }`}
        >
          {p}
        </button>
      ))}

      <span className="px-1 text-base text-gray-500">...</span>

      <button
        onClick={() => setPage(totalPages)}
        className={`flex h-10 w-10 items-center justify-center text-sm font-semibold tracking-wide ${
          page === totalPages
            ? "bg-[#3525CD] font-bold text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"
            : "border border-slate-300 text-slate-600 hover:bg-gray-100"
        }`}
      >
        {totalPages}
      </button>

      <button
        aria-label="Next page"
        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
        className="flex h-10 w-8 items-center justify-center border border-slate-300 text-slate-600 hover:bg-gray-100"
      >
        <ChevronRight className="h-3 w-3" />
      </button>
    </div>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketplace/Pagination.tsx" -Content $content

# ---- apps/web/components/marketplace/SortDropdown.tsx ----
$content = @'
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
        className="flex items-center gap-8 border border-slate-300 bg-white px-3 py-2 text-base text-zinc-900 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"
      >
        {value}
        <ChevronDown className="h-4 w-4 text-gray-500" />
      </button>

      {open && (
        <ul className="absolute right-0 top-full z-10 mt-1 w-48 border border-slate-300 bg-white shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
          {options.map((opt) => (
            <li key={opt}>
              <button
                onClick={() => {
                  setValue(opt);
                  setOpen(false);
                }}
                className="block w-full px-3 py-2 text-left text-sm text-zinc-900 hover:bg-gray-100"
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
Write-CodeFile -Path "apps/web/components/marketplace/SortDropdown.tsx" -Content $content

# ---- apps/web/components/marketing/CompactFooter.tsx ----
$content = @'
import Link from "next/link";

const links = [
  { label: "About Us", href: "/about" },
  { label: "Careers", href: "/careers" },
  { label: "Privacy Policy", href: "/legal/privacy" },
  { label: "Terms of Service", href: "/legal/terms" },
  { label: "Instructor Handbook", href: "/instructor/handbook" },
];

export function CompactFooter() {
  return (
    <footer className="w-full bg-zinc-200">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-6 px-6 py-10">
        <div className="flex items-center justify-between border-b border-slate-300 pb-6">
          <span className="text-base font-bold text-[#3525CD]">Saachi AI</span>
          <nav className="flex gap-4">
            {links.map((link) => (
              <Link
                key={link.label}
                href={link.href}
                className="text-xs font-medium text-gray-700 hover:text-[#3525CD]"
              >
                {link.label}
              </Link>
            ))}
          </nav>
        </div>

        <p className="text-center text-base text-gray-700">
          © {new Date().getFullYear()} Saachi AI Marketplace. Empowering the
          future of skills.
        </p>
      </div>
    </footer>
  );
}

'@
Write-CodeFile -Path "apps/web/components/marketing/CompactFooter.tsx" -Content $content

# ---- apps/web/app/(marketing)/courses/page.tsx ----
$content = @'
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { FilterSidebar } from "@/components/marketplace/FilterSidebar";
import { SortDropdown } from "@/components/marketplace/SortDropdown";
import { Pagination } from "@/components/marketplace/Pagination";
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
    image:
      "https://images.unsplash.com/photo-1550439062-609e1531270e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Deep Learning Specialization (Andrew…",
    provider: "DeepLearning.AI",
    rating: 4.9,
    reviews: "89.1k",
    price: "$49.00",
    priceSuffix: "/mo",
    categoryTag: "Deep Learning",
    levelTag: "Advanced",
    image:
      "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Natural Language Processing with…",
    provider: "Hugging Face",
    rating: 4.7,
    reviews: "2.3k",
    price: "$129.99",
    categoryTag: "NLP",
    levelTag: "Intermediate",
    badge: { label: "New", variant: "dark" },
    image:
      "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
];

export default function CourseMarketplacePage() {
  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-6 px-12 pb-40 pt-20 md:flex-row md:gap-8">
        <div className="w-full shrink-0 md:w-56">
          <FilterSidebar />
        </div>

        <div className="flex flex-1 flex-col gap-6">
          <div className="flex items-center justify-between pb-4">
            <div className="flex items-baseline gap-3">
              <h1 className="text-2xl font-semibold text-zinc-900">
                Explore Courses
              </h1>
              <span className="text-base text-slate-600">
                (1,204 results)
              </span>
            </div>
            <SortDropdown />
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
Write-CodeFile -Path "apps/web/app/(marketing)/courses/page.tsx" -Content $content

Write-Host "`nDone. Visit /courses after restarting the dev server." -ForegroundColor Green
Write-Host "  pnpm --filter web dev" -ForegroundColor Green