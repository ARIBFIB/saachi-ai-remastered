<#
================================================================================
Apply-Saachi-Step6-DynamicMarketing.ps1
STEP 6: Missing marketing dynamic-route pages (these were empty/corrupt in
the last export -- "ERROR reading file"). Reuses components already built
in Steps 1-4:
  - app\(marketing)\courses\[slug]\page.tsx        (course detail/landing)
  - app\(marketing)\categories\[slug]\page.tsx      (category listing)
  - app\(marketing)\instructors\[slug]\page.tsx     (instructor public profile)

USAGE:
  1. Save into repo root: D:\...\SAI2\Apply-Saachi-Step6-DynamicMarketing.ps1
  2. Run:  .\Apply-Saachi-Step6-DynamicMarketing.ps1
  3. Existing files are backed up first into .\_backup_stepwise\<timestamp>\
================================================================================
#>

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
if (-not $root) { $root = Get-Location }

$backupDir = Join-Path $root ("_backup_stepwise\{0}" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
$writtenCount = 0

function Write-SaachiFile {
    param([string]$RelativePath, [string]$Content)

    $fullPath = Join-Path $root $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    if (Test-Path $fullPath) {
        $backupTarget = Join-Path $backupDir $RelativePath
        $backupTargetDir = Split-Path $backupTarget -Parent
        if (-not (Test-Path $backupTargetDir)) { New-Item -ItemType Directory -Path $backupTargetDir -Force | Out-Null }
        Copy-Item -Path $fullPath -Destination $backupTarget -Force
        Write-Host "  backed up existing: $RelativePath"
    }

    $Content = $Content.TrimStart("`r", "`n")
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $utf8NoBom)
    $script:writtenCount++
    Write-Host "  wrote: $RelativePath"
}

Write-Host "=== STEP 6: Marketing dynamic routes ==="
Write-Host "Target repo root: $root"
Write-Host ""

# ------------------------------------------------------------------
# app/(marketing)/courses/[slug]/page.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\(marketing)\courses\[slug]\page.tsx" @'
import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { DetailFooter } from "@/components/course-detail/DetailFooter";
import { CourseHero } from "@/components/course-detail/CourseHero";
import { WhatYoullLearn } from "@/components/course-detail/WhatYoullLearn";
import { CourseCurriculum } from "@/components/course-detail/CourseCurriculum";
import { InstructorBio } from "@/components/course-detail/InstructorBio";
import { PurchaseCard } from "@/components/course-detail/PurchaseCard";

// TODO: replace with useCourseDetail(slug) hook from @saachi/api-client
interface CourseDetailData {
  slug: string;
  category: string;
  levelBadge: string;
  title: string;
  description: string;
  rating: number;
  ratingsCount: string;
  studentsCount: string;
  instructorName: string;
  instructorAvatar: string;
  instructorTitle: string;
  instructorBio: string;
  previewImage: string;
  price: string;
  includes: string[];
}

const DUMMY_COURSES: Record<string, CourseDetailData> = {
  "prompt-engineering-masterclass": {
    slug: "prompt-engineering-masterclass",
    category: "Prompt Engineering",
    levelBadge: "Intermediate",
    title: "Prompt Engineering Masterclass",
    description:
      "Master the art of crafting precise instructions for large language models -- from zero-shot prompting to advanced chain-of-thought reasoning.",
    rating: 4.8,
    ratingsCount: "3.2k",
    studentsCount: "18,400",
    instructorName: "Dr. Sarah Chen",
    instructorAvatar: "https://i.pravatar.cc/128?img=32",
    instructorTitle: "Lead AI Architect",
    instructorBio:
      "Sarah has spent the last 6 years building production LLM systems and has taught prompt engineering to over 20,000 students worldwide.",
    previewImage:
      "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=800&q=80",
    price: "$89.99",
    includes: ["8 hours on-demand video", "Downloadable resources", "Certificate of completion"],
  },
  "whatsapp-ai-auto-responder": {
    slug: "whatsapp-ai-auto-responder",
    category: "AI Automation",
    levelBadge: "Intermediate",
    title: "WhatsApp AI Auto-Responder for Small Business",
    description:
      "Build a working AI-powered WhatsApp auto-responder from scratch using n8n and an LLM API -- ship a real automation, not just a demo.",
    rating: 4.9,
    ratingsCount: "940",
    studentsCount: "6,100",
    instructorName: "Marcus Johnson",
    instructorAvatar: "https://i.pravatar.cc/128?img=13",
    instructorTitle: "Automation Engineer",
    instructorBio:
      "Marcus builds automation systems for small businesses across South Asia and has shipped over 40 production WhatsApp bots.",
    previewImage:
      "https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=800&q=80",
    price: "Rs 4,999",
    includes: ["6h 40m on-demand video", "Starter n8n workflow file", "Certificate of completion"],
  },
};

interface CoursePageProps {
  params: Promise<{ slug: string }>;
}

export default async function CourseDetailPage({ params }: CoursePageProps) {
  const { slug } = await params;
  const course = DUMMY_COURSES[slug];

  if (!course) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-white">
      <Header />

      <CourseHero
        category={course.category}
        levelBadge={course.levelBadge}
        title={course.title}
        description={course.description}
        rating={course.rating}
        ratingsCount={course.ratingsCount}
        studentsCount={course.studentsCount}
        instructorName={course.instructorName}
        instructorAvatar={course.instructorAvatar}
        previewImage={course.previewImage}
      />

      <main className="mx-auto flex w-full max-w-[1280px] flex-col gap-10 px-6 py-12 lg:flex-row lg:items-start">
        <div className="flex flex-1 flex-col gap-10">
          <WhatYoullLearn />
          <CourseCurriculum />
          <InstructorBio
            name={course.instructorName}
            title={course.instructorTitle}
            rating={course.rating}
            studentsCount={course.studentsCount}
            bio={course.instructorBio}
            avatar={course.instructorAvatar}
          />
        </div>

        <div className="w-full lg:w-80 lg:shrink-0">
          <PurchaseCard price={course.price} includes={course.includes} />
        </div>
      </main>

      <DetailFooter />
    </div>
  );
}
'@

# ------------------------------------------------------------------
# app/(marketing)/categories/[slug]/page.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\(marketing)\categories\[slug]\page.tsx" @'
import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { CategoryBanner } from "@/components/marketplace/CategoryBanner";
import { CategoryChips } from "@/components/marketplace/CategoryChips";
import {
  CategoryCourseCard,
  type CategoryCourseCardProps,
} from "@/components/marketplace/CategoryCourseCard";

// TODO: replace with useCategory(slug) + useCourseList({category: slug}) from @saachi/api-client
interface CategoryData {
  slug: string;
  title: string;
  description: string;
  image: string;
  chips: string[];
  courses: CategoryCourseCardProps[];
}

const DUMMY_CATEGORIES: Record<string, CategoryData> = {
  nlp: {
    slug: "nlp",
    title: "NLP & Language",
    description:
      "Courses on natural language processing, transformers, prompt engineering, and language-model application building.",
    image:
      "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [
      {
        title: "Natural Language Processing with Transformers",
        description: "Fine-tune transformer models for real-world NLP tasks using Hugging Face.",
        levelTag: "Intermediate",
        rating: 4.7,
        reviews: "2.3k",
        price: "$129.99",
        image:
          "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
      },
      {
        title: "Prompt Engineering Masterclass",
        description: "Master zero-shot, few-shot, and chain-of-thought prompting techniques.",
        levelTag: "Beginner",
        rating: 4.8,
        reviews: "3.2k",
        price: "$89.99",
        image:
          "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
      },
    ],
  },
  "computer-vision": {
    slug: "computer-vision",
    title: "Computer Vision",
    description: "Build image recognition, object detection, and generative vision applications.",
    image:
      "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [
      {
        title: "Computer Vision Fundamentals",
        description: "Implement image recognition systems from scratch using PyTorch.",
        levelTag: "Advanced",
        rating: 4.6,
        reviews: "1.1k",
        price: "$149.00",
        image:
          "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80",
      },
    ],
  },
};

interface CategoryPageProps {
  params: Promise<{ slug: string }>;
}

export default async function CategoryPage({ params }: CategoryPageProps) {
  const { slug } = await params;
  const category = DUMMY_CATEGORIES[slug];

  if (!category) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-8 px-6 py-10">
        <CategoryBanner title={category.title} description={category.description} image={category.image} />

        <CategoryChips chips={category.chips} />

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {category.courses.map((course) => (
            <CategoryCourseCard key={course.title} {...course} />
          ))}
        </div>
      </main>

      <CompactFooter />
    </div>
  );
}
'@

# ------------------------------------------------------------------
# app/(marketing)/instructors/[slug]/page.tsx
# ------------------------------------------------------------------
Write-SaachiFile "apps\web\app\(marketing)\instructors\[slug]\page.tsx" @'
import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { InstructorProfileCard } from "@/components/instructor/InstructorProfileCard";
import { InstructorStatsGrid } from "@/components/instructor/InstructorStatsGrid";
import {
  InstructorCourseCard,
  type InstructorCourseCardProps,
} from "@/components/instructor/InstructorCourseCard";
import { findInstructorBySlug } from "@/lib/instructor-lookup";

// TODO: replace with useInstructor(slug) hook from @saachi/api-client once available.
// findInstructorBySlug currently derives instructor data from DUMMY_COURSES
// (packages/api-client) so instructor pages stay in sync with course data.

interface InstructorPageProps {
  params: Promise<{ slug: string }>;
}

export default async function InstructorProfilePage({ params }: InstructorPageProps) {
  const { slug } = await params;
  const instructor = findInstructorBySlug(slug);

  if (!instructor) {
    notFound();
  }

  const courseCards: InstructorCourseCardProps[] = instructor.courses.map((c) => ({
    title: c.title,
    description: c.shortDescription ?? c.description ?? "",
    category: c.category ?? "AI",
    price: c.price ?? "$0",
    rating: c.rating ?? 4.8,
    reviews: c.reviewsCount ?? "0",
    duration: c.durationLabel ?? "Self-paced",
    image: c.thumbnailUrl ?? "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  }));

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-10 px-6 py-12">
        <div className="flex flex-col gap-6 lg:flex-row">
          <InstructorProfileCard
            name={instructor.fullName}
            title="Instructor"
            bio={instructor.bio || "This instructor hasn't added a bio yet."}
            avatar={instructor.avatarUrl ?? "https://i.pravatar.cc/256?img=12"}
            tags={["AI", "Automation"]}
          />
          <InstructorStatsGrid
            coursesCount={instructor.courses.length}
            studentsCount="12,400"
            rating={4.8}
            reviewsCount="1.9k"
          />
        </div>

        <section className="flex flex-col gap-6">
          <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">
            Courses by {instructor.fullName}
          </h2>
          <div className="flex flex-wrap gap-6">
            {courseCards.map((course) => (
              <InstructorCourseCard key={course.title} {...course} />
            ))}
          </div>
        </section>
      </main>

      <CompactFooter />
    </div>
  );
}
'@

Write-Host ""
Write-Host "=== STEP 6 complete: $writtenCount file(s) written. ==="
if (Test-Path $backupDir) {
    Write-Host "Backups of any overwritten files: $backupDir"
}