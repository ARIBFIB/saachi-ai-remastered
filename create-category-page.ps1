<#
================================================================================
  create-category-page.ps1
  Scaffolds the "Category: AI & Machine Learning" page for apps/web (SAI2).

  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

  Notes:
  - Colors use CSS variables from lib/design-system/tokens.ts (e.g.
    var(--token-color-primary)) instead of hardcoded hex/Tailwind color
    names, so changing tokens.ts + running tokens:sync re-themes this
    page automatically. Do NOT hardcode hex colors in new files.
  - Reuses existing Header / Footer components for consistency.
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

Write-Host "`nScaffolding Category page..." -ForegroundColor Cyan

# ------------------------------------------------------------------------
# 1. components/marketplace/CategoryBanner.tsx
# ------------------------------------------------------------------------
$categoryBanner = @'
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
Write-File (Join-Path $webRoot "components\marketplace\CategoryBanner.tsx") $categoryBanner

# ------------------------------------------------------------------------
# 2. components/marketplace/CategoryChips.tsx
# ------------------------------------------------------------------------
$categoryChips = @'
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
            className={`rounded-full border px-4 py-2 text-sm font-semibold tracking-wide transition ${
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
Write-File (Join-Path $webRoot "components\marketplace\CategoryChips.tsx") $categoryChips

# ------------------------------------------------------------------------
# 3. components/marketplace/CategoryCourseCard.tsx
# ------------------------------------------------------------------------
$categoryCourseCard = @'
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
    <article className="flex flex-1 flex-col overflow-hidden rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
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
Write-File (Join-Path $webRoot "components\marketplace\CategoryCourseCard.tsx") $categoryCourseCard

# ------------------------------------------------------------------------
# 4. app/(marketing)/categories/[slug]/page.tsx
# ------------------------------------------------------------------------
$categoryPage = @'
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { CategoryBanner } from "@/components/marketplace/CategoryBanner";
import { CategoryChips } from "@/components/marketplace/CategoryChips";
import {
  CategoryCourseCard,
  type CategoryCourseCardProps,
} from "@/components/marketplace/CategoryCourseCard";

const subCategories = ["NLP", "Computer Vision", "Robotics", "Deep Learning", "Generative AI"];

const courses: CategoryCourseCardProps[] = [
  {
    title: "Applied Natural Language\u2026",
    description: "Build real-world NLP applications using transformers, BERT, and\u2026",
    levelTag: "Intermediate",
    rating: 4.8,
    reviews: "1.2k",
    price: "$89.99",
    image:
      "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Computer Vision with PyTorch",
    description: "Master object detection, image segmentation, and advanced CNN architectures.",
    levelTag: "Advanced",
    rating: 4.9,
    reviews: "850",
    price: "$99.99",
    image:
      "https://images.unsplash.com/photo-1555255707-c07966088b7b?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Introduction to Robotics",
    description: "Learn the fundamentals of kinematics, control systems, and robotic motion planning.",
    levelTag: "Beginner",
    rating: 4.7,
    reviews: "2.1k",
    price: "$49.99",
    image:
      "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Generative AI Fundamentals",
    description: "Understand GANs, diffusion models, and the architecture behind modern generative\u2026",
    levelTag: "Intermediate",
    rating: 4.9,
    reviews: "3.5k",
    price: "$129.99",
    image:
      "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  },
];

const categoryContent: Record<string, { title: string; description: string }> = {
  "ai-machine-learning": {
    title: "AI & Machine Learning",
    description:
      "Master the foundational concepts and advanced techniques powering the AI revolution. From neural networks to reinforcement learning, build intelligent systems.",
  },
};

export default function CategoryPage({ params }: { params: { slug: string } }) {
  const content = categoryContent[params.slug] ?? categoryContent["ai-machine-learning"];

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-6 px-12 pb-10 pt-24">
        <CategoryBanner title={content.title} description={content.description} />

        <CategoryChips chips={subCategories} />

        <div className="grid grid-cols-1 gap-6 pt-2 sm:grid-cols-2 lg:grid-cols-4">
          {courses.map((course) => (
            <CategoryCourseCard key={course.title} {...course} />
          ))}
        </div>
      </main>

      <CompactFooter />
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "app\(marketing)\categories\[slug]\page.tsx") $categoryPage

Write-Host "`nDone. Category page scaffolded at:" -ForegroundColor Green
Write-Host "  apps\web\app\(marketing)\categories\[slug]\page.tsx"
Write-Host "`nVisit /categories/ai-machine-learning after running 'pnpm --filter web dev'.`n"