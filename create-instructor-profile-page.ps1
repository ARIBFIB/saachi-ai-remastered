<#
================================================================================
  create-instructor-profile-page.ps1
  Scaffolds the "Instructor Profile" page for apps/web (SAI2).

  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2

  Notes:
  - Colors use CSS variables from lib/design-system/tokens.ts (e.g.
    var(--token-color-primary)) instead of hardcoded hex/Tailwind color
    names, so changing tokens.ts + running tokens:sync re-themes this
    page automatically.
  - Reuses existing Header and DetailFooter components for consistency.
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

Write-Host "`nScaffolding Instructor Profile page..." -ForegroundColor Cyan

# ------------------------------------------------------------------------
# 1. components/instructor/InstructorProfileCard.tsx
# ------------------------------------------------------------------------
$instructorProfileCard = @'
import Image from "next/image";
import { Mail } from "lucide-react";

interface InstructorProfileCardProps {
  name: string;
  title: string;
  bio: string;
  avatar: string;
  tags: string[];
}

export function InstructorProfileCard({
  name,
  title,
  bio,
  avatar,
  tags,
}: InstructorProfileCardProps) {
  return (
    <div className="flex flex-1 items-start gap-6 rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-6 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <span className="relative block h-32 w-32 shrink-0 overflow-hidden rounded-full ring-4 ring-[var(--token-color-surfaceAlt)]">
        <Image src={avatar} alt={name} fill sizes="128px" className="object-cover" />
      </span>

      <div className="flex flex-1 flex-col gap-4">
        <div className="flex items-start justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold leading-10 text-[var(--token-color-ink)]">{name}</h1>
            <p className="text-lg leading-7 text-[var(--token-color-inkSoft)]">{title}</p>
          </div>

          <button
            type="button"
            className="flex shrink-0 items-center gap-2 rounded-lg bg-[var(--token-color-primary)] px-4 py-2 text-sm font-semibold tracking-wide text-white hover:bg-[var(--token-color-primaryHover)]"
          >
            <Mail className="h-3.5 w-3.5" />
            Message Instructor
          </button>
        </div>

        <div className="flex flex-wrap gap-2">
          {tags.map((tag) => (
            <span
              key={tag}
              className="rounded-sm bg-[var(--token-color-primaryTint)] px-3 pb-1 pt-[3px] text-xs font-medium text-[var(--token-color-primary)]"
            >
              {tag}
            </span>
          ))}
        </div>

        <p className="max-w-2xl text-base text-[var(--token-color-inkSoft)]">{bio}</p>
      </div>
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "components\instructor\InstructorProfileCard.tsx") $instructorProfileCard

# ------------------------------------------------------------------------
# 2. components/instructor/InstructorStatsGrid.tsx
# ------------------------------------------------------------------------
$instructorStatsGrid = @'
import { GraduationCap, Users, Star } from "lucide-react";

interface InstructorStatsGridProps {
  coursesCount: number;
  studentsCount: string;
  rating: number;
  reviewsCount: string;
}

export function InstructorStatsGrid({
  coursesCount,
  studentsCount,
  rating,
  reviewsCount,
}: InstructorStatsGridProps) {
  return (
    <div className="flex w-64 shrink-0 flex-col gap-4">
      <div className="flex gap-4">
        <StatCard
          icon={<GraduationCap className="h-[30px] w-[30px] text-[var(--token-color-primary)]" />}
          value={coursesCount}
          label="Courses"
        />
        <StatCard
          icon={<Users className="h-[26px] w-[30px] text-[var(--token-color-primary)]" />}
          value={studentsCount}
          label="Students"
        />
      </div>

      <div className="flex flex-col items-center gap-2 rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] px-4 py-8 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
        <div className="flex items-center gap-2">
          <Star className="h-[19px] w-5 text-[var(--token-color-warning)]" fill="currentColor" strokeWidth={0} />
          <span className="text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">{rating}</span>
        </div>
        <span className="text-center text-xs font-medium uppercase tracking-wide text-[var(--token-color-inkSoft)]">
          Instructor Rating ({reviewsCount} reviews)
        </span>
      </div>
    </div>
  );
}

function StatCard({
  icon,
  value,
  label,
}: {
  icon: React.ReactNode;
  value: string | number;
  label: string;
}) {
  return (
    <div className="flex flex-1 flex-col items-center justify-center gap-2 rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] py-8 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      {icon}
      <span className="text-2xl font-semibold leading-8 text-[var(--token-color-ink)]">{value}</span>
      <span className="text-xs font-medium uppercase tracking-wide text-[var(--token-color-inkSoft)]">{label}</span>
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "components\instructor\InstructorStatsGrid.tsx") $instructorStatsGrid

# ------------------------------------------------------------------------
# 3. components/instructor/InstructorCourseCard.tsx
# ------------------------------------------------------------------------
$instructorCourseCard = @'
import Image from "next/image";
import { Star } from "lucide-react";

export interface InstructorCourseCardProps {
  title: string;
  description: string;
  category: string;
  price: string;
  rating: number;
  reviews: string;
  duration: string;
  image: string;
  badge?: { label: string; variant: "light" | "dark" };
}

export function InstructorCourseCard({
  title,
  description,
  category,
  price,
  rating,
  reviews,
  duration,
  image,
  badge,
}: InstructorCourseCardProps) {
  return (
    <article className="flex w-96 flex-col overflow-hidden rounded-xl border border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="relative h-48 w-full bg-[var(--token-color-surfaceAlt)]">
        <Image src={image} alt={title} fill sizes="384px" className="object-cover" />
        {badge && (
          <span
            className={`absolute right-4 top-4 rounded-sm px-2 pb-1 pt-[3px] text-xs font-bold ${
              badge.variant === "dark"
                ? "bg-[var(--token-color-success)] text-white"
                : "bg-[var(--token-color-surface)]/90 text-[var(--token-color-ink)] backdrop-blur-[2px]"
            }`}
          >
            {badge.label}
          </span>
        )}
      </div>

      <div className="flex flex-col gap-4 p-6">
        <div className="flex items-center justify-between">
          <span className="text-xs font-medium uppercase tracking-wide text-[var(--token-color-primary)]">
            {category}
          </span>
          <span className="text-sm font-bold tracking-wide text-[var(--token-color-ink)]">{price}</span>
        </div>

        <div className="flex flex-col gap-2">
          <h3 className="line-clamp-2 text-lg font-semibold leading-7 text-[var(--token-color-ink)]">
            {title}
          </h3>
          <p className="line-clamp-2 text-base text-[var(--token-color-inkSoft)]">{description}</p>
        </div>

        <div className="flex items-center gap-2">
          <Star className="h-3.5 w-3.5 text-[var(--token-color-warning)]" fill="currentColor" strokeWidth={0} />
          <span className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
            {rating} <span className="text-[var(--token-color-inkSoft)]">({reviews})</span>
          </span>
          <span className="text-[var(--token-color-inkSoft)]">&bull;</span>
          <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">{duration} Total</span>
        </div>

        <button
          type="button"
          className="w-full rounded-lg border border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] py-2 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-border)]/20"
        >
          View Course
        </button>
      </div>
    </article>
  );
}
'@
Write-File (Join-Path $webRoot "components\instructor\InstructorCourseCard.tsx") $instructorCourseCard

# ------------------------------------------------------------------------
# 4. app/(marketing)/instructors/[slug]/page.tsx
# ------------------------------------------------------------------------
$instructorPage = @'
import { ChevronLeft, ChevronRight } from "lucide-react";
import { Header } from "@/components/marketing/Header";
import { DetailFooter } from "@/components/course-detail/DetailFooter";
import { InstructorProfileCard } from "@/components/instructor/InstructorProfileCard";
import { InstructorStatsGrid } from "@/components/instructor/InstructorStatsGrid";
import {
  InstructorCourseCard,
  type InstructorCourseCardProps,
} from "@/components/instructor/InstructorCourseCard";

const courses: InstructorCourseCardProps[] = [
  {
    title: "Deep Learning Foundations: From Math to PyTorch",
    description: "Master the underlying mathematics of deep learning and build practical models\u2026",
    category: "Machine Learning",
    price: "$129.99",
    rating: 4.9,
    reviews: "8,241",
    duration: "32h",
    badge: { label: "Best Seller", variant: "light" },
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=800&q=80",
  },
  {
    title: "Advanced NLP with Transformers & Hugging Face",
    description: "Build state-of-the-art language models and deploy them to production environments.",
    category: "NLP",
    price: "$99.99",
    rating: 4.8,
    reviews: "4,102",
    duration: "24h",
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=800&q=80",
  },
  {
    title: "MLOps Engineering: Deploying Models at Scale",
    description: "Learn the complete lifecycle of deploying, monitoring, and maintaining machine\u2026",
    category: "MLOps",
    price: "$149.99",
    rating: 5.0,
    reviews: "128",
    duration: "40h",
    badge: { label: "New", variant: "dark" },
    image:
      "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=800&q=80",
  },
];

const instructorContent = {
  name: "Dr. Sarah Chen",
  title: "Senior AI Researcher & Lead Educator",
  bio: "Former Lead AI Researcher at TechGlobal with 10+ years of experience in deploying scalable machine learning models. I specialize in breaking down complex neural network architectures into digestible, practical lessons for working professionals. Passionate about ethical AI and real-world applications.",
  avatar:
    "https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=240&q=80",
  tags: ["Machine Learning", "Neural Networks", "Data Science"],
  coursesCount: 14,
  studentsCount: "125k+",
  rating: 4.9,
  reviewsCount: "15k",
};

export default function InstructorProfilePage({ params }: { params: { slug: string } }) {
  const instructor = instructorContent;

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-10 px-12 py-10">
        <section className="flex items-stretch gap-6">
          <InstructorProfileCard
            name={instructor.name}
            title={instructor.title}
            bio={instructor.bio}
            avatar={instructor.avatar}
            tags={instructor.tags}
          />
          <InstructorStatsGrid
            coursesCount={instructor.coursesCount}
            studentsCount={instructor.studentsCount}
            rating={instructor.rating}
            reviewsCount={instructor.reviewsCount}
          />
        </section>

        <section className="flex flex-col gap-6">
          <div className="flex items-end justify-between">
            <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">
              More Courses by {instructor.name.split(" ").slice(-1)}
            </h2>
            <div className="flex gap-2">
              <button
                type="button"
                aria-label="Previous"
                className="flex h-10 w-8 items-center justify-center rounded-lg border border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
              >
                <ChevronLeft className="h-3 w-3" />
              </button>
              <button
                type="button"
                aria-label="Next"
                className="flex h-10 w-8 items-center justify-center rounded-lg border border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
              >
                <ChevronRight className="h-3 w-3" />
              </button>
            </div>
          </div>

          <div className="flex justify-center gap-6">
            {courses.map((course) => (
              <InstructorCourseCard key={course.title} {...course} />
            ))}
          </div>
        </section>
      </main>

      <DetailFooter />
    </div>
  );
}
'@
Write-File (Join-Path $webRoot "app\(marketing)\instructors\[slug]\page.tsx") $instructorPage

Write-Host "`nDone. Instructor Profile page scaffolded at:" -ForegroundColor Green
Write-Host "  apps\web\app\(marketing)\instructors\[slug]\page.tsx"
Write-Host "`nVisit /instructors/sarah-chen after running 'pnpm --filter web dev'.`n"