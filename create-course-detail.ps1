# ============================================================================
# create-course-detail.ps1
# Scaffolds the Course Detail page + components into apps/web
# Compatible with Windows PowerShell 5.1 and PowerShell 7+
# Run this from the SAI2 repo root:
#   PS D:\...\SAI2> .\create-course-detail.ps1
# ============================================================================
$ErrorActionPreference = 'Stop'

function Write-CodeFile($Path, $Content) {
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $fullPath = Join-Path (Get-Location) $Path
    [System.IO.File]::WriteAllText($fullPath, $Content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "Created: $Path"
}

# ---- apps/web/components/course-detail/CourseHero.tsx ----
$content = @'
import Image from "next/image";
import { Star, Play } from "lucide-react";

interface CourseHeroProps {
  category: string;
  levelBadge: string;
  title: string;
  description: string;
  rating: number;
  ratingsCount: string;
  studentsCount: string;
  instructorName: string;
  instructorAvatar: string;
  previewImage: string;
}

export function CourseHero({
  category,
  levelBadge,
  title,
  description,
  rating,
  ratingsCount,
  studentsCount,
  instructorName,
  instructorAvatar,
  previewImage,
}: CourseHeroProps) {
  return (
    <section className="w-full bg-gray-100 px-6 py-12">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-6 lg:flex-row lg:items-start">
        <div className="flex flex-1 flex-col gap-6">
          <div className="flex items-start gap-2">
            <span className="rounded-sm bg-[#E0E7FF] px-2 pb-1 pt-[3px] text-xs font-medium text-gray-500">
              {category}
            </span>
            <span className="rounded-sm bg-zinc-200 px-2 pb-1 pt-[3px] text-xs font-medium text-zinc-900">
              {levelBadge}
            </span>
          </div>

          <h1 className="text-5xl font-bold leading-[52.8px] text-zinc-900">
            {title}
          </h1>

          <p className="max-w-[700px] text-lg leading-7 text-gray-700">
            {description}
          </p>

          <div className="flex items-center gap-4">
            <div className="flex items-center gap-1">
              <Star className="h-5 w-5 text-[#005338]" fill="currentColor" strokeWidth={0} />
              <span className="text-base font-bold text-emerald-900">{rating}</span>
              <span className="pl-1 text-base text-gray-700">({ratingsCount} ratings)</span>
            </div>
            <span className="text-gray-700">•</span>
            <span className="text-base text-gray-700">{studentsCount} Students Enrolled</span>
          </div>

          <div className="flex items-center gap-3">
            <span className="relative block h-10 w-10 overflow-hidden rounded-full">
              <Image src={instructorAvatar} alt={instructorName} fill sizes="40px" className="object-cover" />
            </span>
            <span className="text-sm font-semibold tracking-wide text-zinc-900">
              Created by {instructorName}
            </span>
          </div>
        </div>

        <div className="w-full lg:w-96">
          <button
            type="button"
            className="group relative block aspect-video w-full overflow-hidden rounded-xl shadow-lg"
          >
            <Image
              src={previewImage}
              alt={`${title} preview`}
              fill
              sizes="(max-width: 1024px) 100vw, 384px"
              className="object-cover"
            />
            <span className="absolute inset-0 bg-zinc-900/20 transition group-hover:bg-zinc-900/30" />
            <span className="absolute inset-0 flex items-center justify-center">
              <span className="flex h-[46px] w-[46px] items-center justify-center rounded-full bg-white shadow-lg">
                <Play className="ml-0.5 h-5 w-5 text-zinc-900" fill="currentColor" />
              </span>
            </span>
          </button>
        </div>
      </div>
    </section>
  );
}

'@
Write-CodeFile -Path "apps/web/components/course-detail/CourseHero.tsx" -Content $content

# ---- apps/web/components/course-detail/WhatYoullLearn.tsx ----
$content = @'
import { Check } from "lucide-react";

const learningPoints = [
  "Core principles of LLM architecture",
  "Zero-shot and few-shot prompting techniques",
  "Chain-of-thought reasoning setups",
  "Preventing hallucinations and bias",
];

export function WhatYoullLearn() {
  return (
    <section className="w-full rounded-xl border border-slate-300/30 bg-slate-50 p-6 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]">
      <h2 className="mb-6 text-2xl font-semibold text-zinc-900">
        What you&apos;ll learn
      </h2>
      <div className="grid grid-cols-1 gap-x-8 gap-y-3 sm:grid-cols-2">
        {learningPoints.map((point) => (
          <div key={point} className="flex items-start gap-2">
            <Check className="mt-0.5 h-4 w-4 shrink-0 text-[#3525CD]" strokeWidth={3} />
            <span className="text-base text-zinc-900">{point}</span>
          </div>
        ))}
      </div>
    </section>
  );
}

'@
Write-CodeFile -Path "apps/web/components/course-detail/WhatYoullLearn.tsx" -Content $content

# ---- apps/web/components/course-detail/CourseCurriculum.tsx ----
$content = @'
"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

interface Module {
  title: string;
  meta: string;
}

const modules: Module[] = [
  { title: "Module 1: Introduction to Large Language Models", meta: "3 lessons • 45 mins" },
  { title: "Module 2: Anatomy of a Perfect Prompt", meta: "5 lessons • 1hr 20 mins" },
];

function ModuleRow({ module }: { module: Module }) {
  const [open, setOpen] = useState(false);

  return (
    <div className="overflow-hidden rounded-xl border border-slate-300/30 bg-slate-50 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className="flex w-full items-center gap-4 bg-white p-4 text-left"
      >
        <ChevronDown
          className={`h-3 w-3 shrink-0 text-[#464555] transition-transform ${
            open ? "rotate-180" : ""
          }`}
        />
        <div>
          <h3 className="text-sm font-semibold tracking-wide text-zinc-900">
            {module.title}
          </h3>
          <p className="text-xs font-medium text-gray-700">{module.meta}</p>
        </div>
      </button>

      {open && (
        <div className="border-t border-slate-300/30 p-4 text-sm text-gray-700">
          Lesson content coming soon.
        </div>
      )}
    </div>
  );
}

export function CourseCurriculum() {
  return (
    <section className="flex w-full flex-col gap-6">
      <h2 className="text-2xl font-semibold text-zinc-900">Course Curriculum</h2>
      <div className="flex flex-col gap-4">
        {modules.map((m) => (
          <ModuleRow key={m.title} module={m} />
        ))}
      </div>
    </section>
  );
}

'@
Write-CodeFile -Path "apps/web/components/course-detail/CourseCurriculum.tsx" -Content $content

# ---- apps/web/components/course-detail/InstructorBio.tsx ----
$content = @'
import Image from "next/image";
import { Star, Users } from "lucide-react";

interface InstructorBioProps {
  name: string;
  title: string;
  rating: number;
  studentsCount: string;
  bio: string;
  avatar: string;
}

export function InstructorBio({
  name,
  title,
  rating,
  studentsCount,
  bio,
  avatar,
}: InstructorBioProps) {
  return (
    <section className="flex w-full gap-6 rounded-xl border border-slate-300/30 bg-slate-50 p-6 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]">
      <span className="relative block h-32 w-32 shrink-0 overflow-hidden rounded-full">
        <Image src={avatar} alt={name} fill sizes="128px" className="object-cover" />
      </span>

      <div className="flex flex-col">
        <h2 className="text-2xl font-semibold text-zinc-900">{name}</h2>
        <p className="text-sm font-semibold tracking-wide text-[#3525CD]">{title}</p>

        <div className="mt-4 flex items-center gap-4">
          <div className="flex items-center gap-1.5">
            <Star className="h-[18px] w-[18px] text-[#464555]" fill="currentColor" strokeWidth={0} />
            <span className="text-xs font-medium text-gray-700">
              {rating} Instructor Rating
            </span>
          </div>
          <div className="flex items-center gap-1.5">
            <Users className="h-[18px] w-[18px] text-[#464555]" />
            <span className="text-xs font-medium text-gray-700">
              {studentsCount} Students
            </span>
          </div>
        </div>

        <p className="mt-4 max-w-2xl text-base text-zinc-900">{bio}</p>
      </div>
    </section>
  );
}

'@
Write-CodeFile -Path "apps/web/components/course-detail/InstructorBio.tsx" -Content $content

# ---- apps/web/components/course-detail/PurchaseCard.tsx ----
$content = @'
import { PlayCircle, FileText, Award } from "lucide-react";

interface PurchaseCardProps {
  price: string;
  includes: string[];
}

const icons = [PlayCircle, FileText, Award];

export function PurchaseCard({ price, includes }: PurchaseCardProps) {
  return (
    <div className="sticky top-24 flex w-full flex-col gap-6 rounded-xl border border-slate-300/20 bg-slate-50 px-6 py-6 shadow-[0px_10px_32px_0px_rgba(15,23,42,0.12)]">
      <div className="flex flex-col items-center gap-1">
        <span className="text-5xl font-bold leading-[52.8px] text-zinc-900">{price}</span>
        <span className="text-xs font-medium text-gray-700">
          30-Day Money-Back Guarantee
        </span>
      </div>

      <div className="flex flex-col gap-3">
        <button
          type="button"
          className="w-full rounded-lg bg-[#3525CD] py-3 text-sm font-bold tracking-wide text-white hover:bg-[#2A1DA3]"
        >
          Buy Now
        </button>
        <button
          type="button"
          className="w-full rounded-lg border border-gray-500 bg-white py-3 text-sm font-bold tracking-wide text-zinc-900 hover:bg-gray-50"
        >
          Add to Cart
        </button>
      </div>

      <div className="flex flex-col gap-3 border-t border-slate-300/30 pt-3.5">
        <h4 className="text-sm font-semibold tracking-wide text-zinc-900">
          This course includes:
        </h4>
        {includes.map((item, i) => {
          const Icon = icons[i % icons.length];
          return (
            <div key={item} className="flex items-center gap-3">
              <Icon className="h-5 w-5 shrink-0 text-[#3525CD]" />
              <span className="text-base text-gray-700">{item}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

'@
Write-CodeFile -Path "apps/web/components/course-detail/PurchaseCard.tsx" -Content $content

# ---- apps/web/components/course-detail/DetailFooter.tsx ----
$content = @'
const columns = [
  { links: [{ label: "About Us", href: "/about" }, { label: "Careers", href: "/careers" }] },
  { links: [{ label: "Privacy Policy", href: "/legal/privacy" }, { label: "Terms of Service", href: "/legal/terms" }] },
  { links: [{ label: "Instructor Handbook", href: "/instructor/handbook" }] },
];

export function DetailFooter() {
  return (
    <footer className="w-full bg-zinc-200 px-6 py-10">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-8 sm:flex-row sm:items-end sm:gap-6">
        <div className="flex flex-1 flex-col gap-4">
          <span className="text-base font-bold text-[#3525CD]">Saachi AI</span>
          <p className="text-base text-gray-700">
            © {new Date().getFullYear()} Saachi AI Marketplace.
            <br />
            Empowering the future of skills.
          </p>
        </div>

        {columns.map((col, i) => (
          <div key={i} className="flex flex-1 flex-col gap-1.5">
            {col.links.map((link) => (
              <a
                key={link.label}
                href={link.href}
                className="text-xs font-medium text-gray-700 hover:text-[#3525CD]"
              >
                {link.label}
              </a>
            ))}
          </div>
        ))}
      </div>
    </footer>
  );
}

'@
Write-CodeFile -Path "apps/web/components/course-detail/DetailFooter.tsx" -Content $content

# ---- apps/web/app/(marketing)/courses/[slug]/page.tsx ----
$content = @'
import { Header } from "@/components/marketing/Header";
import { CourseHero } from "@/components/course-detail/CourseHero";
import { WhatYoullLearn } from "@/components/course-detail/WhatYoullLearn";
import { CourseCurriculum } from "@/components/course-detail/CourseCurriculum";
import { InstructorBio } from "@/components/course-detail/InstructorBio";
import { PurchaseCard } from "@/components/course-detail/PurchaseCard";
import { DetailFooter } from "@/components/course-detail/DetailFooter";

export default function CourseDetailPage() {
  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <Header />

      <CourseHero
        category="AI & Machine Learning"
        levelBadge="Beginner Friendly"
        title="Mastering Prompt Engineering"
        description="Unlock the full potential of AI models. Learn advanced techniques to craft effective prompts, optimize outputs, and build AI-driven applications."
        rating={4.8}
        ratingsCount="2,450"
        studentsCount="12,340"
        instructorName="Dr. Sarah Chen"
        instructorAvatar="https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=100&q=80"
        previewImage="https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=900&q=80"
      />

      <main className="mx-auto w-full max-w-[1280px] px-6 py-12">
        <div className="grid grid-cols-1 gap-12 lg:grid-cols-[1fr_360px]">
          <div className="flex flex-col gap-12">
            <WhatYoullLearn />
            <CourseCurriculum />
            <InstructorBio
              name="Dr. Sarah Chen"
              title="Senior AI Researcher & Educator"
              rating={4.9}
              studentsCount="50k+"
              bio="Sarah is a leading researcher in Natural Language Processing with over 10 years of experience building and optimizing AI models for enterprise applications."
              avatar="https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=200&q=80"
            />
          </div>

          <div>
            <PurchaseCard
              price="$99.00"
              includes={[
                "12 hours on-demand video",
                "25 downloadable resources",
                "Certificate of completion",
              ]}
            />
          </div>
        </div>
      </main>

      <DetailFooter />
    </div>
  );
}

'@
Write-CodeFile -Path "apps/web/app/(marketing)/courses/[slug]/page.tsx" -Content $content

Write-Host "`nDone. Visit /courses/mastering-prompt-engineering after restarting dev server." -ForegroundColor Green
Write-Host "  pnpm --filter web dev" -ForegroundColor Green