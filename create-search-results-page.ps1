<#
================================================================================
  create-search-results-page.ps1
  Scaffolds the "Search Results" page for apps/web (SAI2).

  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

  Notes:
  - Colors use CSS variables from lib/design-system/tokens.ts.
  - Reuses existing Header and CompactFooter components for consistency.
  - Reads the query from the ?q= search param (App Router searchParams),
    matching the "Machine Learning" query shown in the design.
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

Write-Host "`nScaffolding Search Results page..." -ForegroundColor Cyan

# ------------------------------------------------------------------------
# 1. components/search/ResultFilterTabs.tsx
# ------------------------------------------------------------------------
$resultFilterTabs = @'
"use client";

import { useState } from "react";

export interface FilterTab {
  label: string;
  count: number;
}

interface ResultFilterTabsProps {
  tabs: FilterTab[];
}

export function ResultFilterTabs({ tabs }: ResultFilterTabsProps) {
  const [active, setActive] = useState(tabs[0]?.label);

  return (
    <div className="flex flex-wrap items-center gap-2 pt-4">
      {tabs.map((tab) => {
        const isActive = tab.label === active;
        return (
          <button
            key={tab.label}
            type="button"
            onClick={() => setActive(tab.label)}
            className={`rounded-full px-4 pb-2 pt-1.5 text-xs font-medium transition ${
              isActive
                ? "bg-[var(--token-color-primaryTint)] text-[var(--token-color-primary)] outline outline-1 outline-offset-[-1px] outline-[var(--token-color-primary)]"
                : "bg-zinc-200 text-[var(--token-color-inkSoft)] outline outline-1 outline-offset-[-1px] outline-[var(--token-color-border)]"
            }`}
          >
            {tab.label}
            {tab.count > 0 && ` (${tab.count})`}
          </button>
        );
      })}
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "components\search\ResultFilterTabs.tsx") $resultFilterTabs

# ------------------------------------------------------------------------
# 2. components/search/FeaturedResultCard.tsx
# ------------------------------------------------------------------------
$featuredResultCard = @'
import Image from "next/image";
import { GraduationCap, Star } from "lucide-react";

export interface FeaturedResultCardProps {
  badge?: string;
  pathLabel: string;
  title: string;
  description: string;
  instructorName: string;
  instructorAvatar: string;
  rating: number;
  reviews: string;
  image: string;
}

export function FeaturedResultCard({
  badge,
  pathLabel,
  title,
  description,
  instructorName,
  instructorAvatar,
  rating,
  reviews,
  image,
}: FeaturedResultCardProps) {
  return (
    <article className="flex h-96 overflow-hidden rounded-xl border border-[var(--token-color-border)] bg-[var(--token-color-surface)] shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="relative w-80 shrink-0">
        <Image src={image} alt={title} fill sizes="320px" className="object-cover" />
        {badge && (
          <span className="absolute left-4 top-4 bg-[var(--token-color-primary)] px-2 pb-1 pt-[3px] text-xs font-medium text-white">
            {badge}
          </span>
        )}
      </div>

      <div className="flex flex-1 flex-col justify-between p-6">
        <div className="flex flex-col gap-2 pb-4">
          <div className="flex items-center gap-1">
            <GraduationCap className="h-3 w-3.5 text-[var(--token-color-inkSoft)]" />
            <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">{pathLabel}</span>
          </div>
          <h2 className="text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">{title}</h2>
          <p className="text-base leading-6 text-[var(--token-color-inkSoft)]">{description}</p>
        </div>

        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span className="relative block h-8 w-8 overflow-hidden rounded-full">
              <Image src={instructorAvatar} alt={instructorName} fill sizes="32px" className="object-cover" />
            </span>
            <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">{instructorName}</span>
          </div>

          <div className="flex items-center gap-1">
            <Star className="h-3.5 w-3.5 text-[var(--token-color-primary)]" fill="currentColor" strokeWidth={0} />
            <span className="text-xs font-bold text-[var(--token-color-primary)]">
              {rating} ({reviews})
            </span>
          </div>
        </div>
      </div>
    </article>
  );
}
'@
Write-File (Join-Path $webRoot "components\search\FeaturedResultCard.tsx") $featuredResultCard

# ------------------------------------------------------------------------
# 3. components/search/InstructorResultCard.tsx
# ------------------------------------------------------------------------
$instructorResultCard = @'
import Image from "next/image";

export interface InstructorResultCardProps {
  name: string;
  title: string;
  avatar: string;
  tags: string[];
  bio: string;
  profileUrl?: string;
}

export function InstructorResultCard({
  name,
  title,
  avatar,
  tags,
  bio,
  profileUrl = "#",
}: InstructorResultCardProps) {
  return (
    <div className="flex flex-col items-center justify-between rounded-xl border border-[var(--token-color-border)] bg-[var(--token-color-surface)] p-6 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <span className="relative mb-4 block h-24 w-24 overflow-hidden rounded-full border-4 border-[var(--token-color-surfaceAlt)]">
        <Image src={avatar} alt={name} fill sizes="96px" className="object-cover" />
      </span>

      <h3 className="text-2xl font-semibold text-[var(--token-color-ink)]">{name}</h3>
      <p className="pb-4 text-center text-xs font-medium text-[var(--token-color-primary)]">{title}</p>

      <div className="flex flex-wrap justify-center gap-2 pb-4">
        {tags.map((tag) => (
          <span key={tag} className="bg-[var(--token-color-surfaceAlt)] px-2 pb-1 pt-[3px] text-xs font-medium text-[var(--token-color-inkSoft)]">
            {tag}
          </span>
        ))}
      </div>

      <p className="pb-4 text-center text-sm leading-5 text-[var(--token-color-inkSoft)]">{bio}</p>

      <a
        href={profileUrl}
        className="w-full border border-[var(--token-color-primary)] py-2 text-center text-sm font-semibold tracking-wide text-[var(--token-color-primary)] hover:bg-[var(--token-color-primaryTint)]"
      >
        View Profile
      </a>
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "components\search\InstructorResultCard.tsx") $instructorResultCard

# ------------------------------------------------------------------------
# 4. components/search/StandardResultCard.tsx
# ------------------------------------------------------------------------
$standardResultCard = @'
import Image from "next/image";
import { ImageOff } from "lucide-react";

export interface StandardResultCardProps {
  title: string;
  description: string;
  meta: string;
  price: string;
  image?: string;
}

export function StandardResultCard({ title, description, meta, price, image }: StandardResultCardProps) {
  return (
    <article className="overflow-hidden rounded-xl border border-[var(--token-color-border)] bg-[var(--token-color-surface)] shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="relative h-40 w-full bg-zinc-200">
        {image ? (
          <Image src={image} alt={title} fill sizes="400px" className="object-cover" />
        ) : (
          <div className="flex h-full w-full items-center justify-center">
            <ImageOff className="h-10 w-10 text-[var(--token-color-inkSoft)]/30" />
          </div>
        )}
      </div>

      <div className="flex flex-col gap-2 p-4">
        <h3 className="line-clamp-1 text-lg font-bold leading-7 text-[var(--token-color-ink)]">{title}</h3>
        <p className="line-clamp-2 text-xs font-medium text-[var(--token-color-inkSoft)]">{description}</p>

        <div className="flex items-center justify-between border-t border-[var(--token-color-border)] pt-3">
          <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">{meta}</span>
          <span className="text-xs font-bold text-[var(--token-color-primary)]">{price}</span>
        </div>
      </div>
    </article>
  );
}
'@
Write-File (Join-Path $webRoot "components\search\StandardResultCard.tsx") $standardResultCard

# ------------------------------------------------------------------------
# 5. components/search/ResultsPagination.tsx
# ------------------------------------------------------------------------
$resultsPagination = @'
"use client";

import { useState } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";

interface ResultsPaginationProps {
  totalPages?: number;
}

export function ResultsPagination({ totalPages = 12 }: ResultsPaginationProps) {
  const [page, setPage] = useState(1);
  const pages = [1, 2, 3];

  return (
    <div className="flex items-center justify-center gap-2 pt-4">
      <button
        type="button"
        aria-label="Previous page"
        onClick={() => setPage((p) => Math.max(1, p - 1))}
        className="flex h-10 w-8 items-center justify-center border border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
      >
        <ChevronLeft className="h-3 w-3" />
      </button>

      {pages.map((p) => (
        <button
          key={p}
          type="button"
          onClick={() => setPage(p)}
          className={`flex h-10 w-10 items-center justify-center text-sm font-semibold tracking-wide ${
            page === p
              ? "bg-[var(--token-color-primary)] text-white"
              : "border border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
          }`}
        >
          {p}
        </button>
      ))}

      <span className="px-1 text-base text-[var(--token-color-inkSoft)]">...</span>

      <button
        type="button"
        onClick={() => setPage(totalPages)}
        className={`flex h-10 w-10 items-center justify-center text-sm font-semibold tracking-wide ${
          page === totalPages
            ? "bg-[var(--token-color-primary)] text-white"
            : "border border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
        }`}
      >
        {totalPages}
      </button>

      <button
        type="button"
        aria-label="Next page"
        onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
        className="flex h-10 w-8 items-center justify-center border border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
      >
        <ChevronRight className="h-3 w-3" />
      </button>
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "components\search\ResultsPagination.tsx") $resultsPagination

# ------------------------------------------------------------------------
# 6. app/(marketing)/search/page.tsx
# ------------------------------------------------------------------------
$searchPage = @'
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { ResultFilterTabs, type FilterTab } from "@/components/search/ResultFilterTabs";
import { FeaturedResultCard } from "@/components/search/FeaturedResultCard";
import { InstructorResultCard } from "@/components/search/InstructorResultCard";
import { StandardResultCard } from "@/components/search/StandardResultCard";
import { ResultsPagination } from "@/components/search/ResultsPagination";

const filterTabs: FilterTab[] = [
  { label: "All Results", count: 0 },
  { label: "Courses", count: 120 },
  { label: "Instructors", count: 22 },
];

const standardResults = [
  {
    title: "Practical ML for Product Managers",
    description: "Bridge the gap between business requirements and AI capabilities.",
    meta: "8 Weeks • Intermediate",
    price: "£299",
    image:
      "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Computer Vision Fundamentals",
    description: "Implement image recognition systems from scratch using PyTorch.",
    meta: "12 Weeks • Advanced",
    price: "£450",
    image:
      "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "MLOps: Deploying Models",
    description: "Learn to scale and monitor machine learning pipelines in production.",
    meta: "6 Weeks • Intermediate",
    price: "£199",
    // no image -- design shows a placeholder icon tile for this card
  },
];

interface SearchPageProps {
  searchParams: { q?: string };
}

export default function SearchResultsPage({ searchParams }: SearchPageProps) {
  const query = searchParams.q ?? "Machine Learning";

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-8 px-12 py-10">
        <div className="flex flex-col gap-2">
          <h1 className="text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
            Results for &quot;{query}&quot;
          </h1>
          <p className="text-base text-[var(--token-color-inkSoft)]">Found 142 results across all categories</p>
          <ResultFilterTabs tabs={filterTabs} />
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <FeaturedResultCard
            badge="Bestseller"
            pathLabel="Data Science Path"
            title="Advanced Machine Learning Specialization"
            description="Master deep learning, neural networks, and scalable AI infrastructure with industry-leading mentors."
            instructorName="Dr. Elena Rostova"
            instructorAvatar="https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=100&q=80"
            rating={4.9}
            reviews="2.1k"
            image="https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=800&q=80"
          />

          <InstructorResultCard
            name="Marcus Chen"
            title="Principal AI Engineer @ TechFlow"
            avatar="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80"
            tags={["Python", "TensorFlow"]}
            bio="Helping professionals transition into scalable AI engineering roles."
          />
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {standardResults.map((result) => (
            <StandardResultCard key={result.title} {...result} />
          ))}
        </div>

        <ResultsPagination totalPages={12} />
      </main>

      <CompactFooter />
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "app\(marketing)\search\page.tsx") $searchPage

Write-Host "`nDone. Search Results page scaffolded at:" -ForegroundColor Green
Write-Host "  apps\web\app\(marketing)\search\page.tsx"
Write-Host "`nVisit /search?q=Machine%20Learning after running 'pnpm --filter web dev'.`n"