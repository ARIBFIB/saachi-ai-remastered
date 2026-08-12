# ============================================================================
# step18-fix-broken-routes.ps1
# Regenerates 11 dynamic-route files that came back as
# "!! ERROR reading file" in the code export (empty/corrupt on disk).
#
# Run from SAI2 repo root:
#   PS D:\...\SAI2> .\step18-fix-broken-routes.ps1
#
# PS 5.1 safe: uses [System.IO.File]::WriteAllText with UTF8 (no BOM issues),
# $PSScriptRoot-relative paths, no cmdlet-based file I/O.
# ============================================================================

$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$webApp = Join-Path $root "apps\web\app"

function Write-CodeFile {
    param(
        [string]$RelativePath,
        [string]$Content
    )
    $fullPath = Join-Path $webApp $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $utf8NoBom)
    Write-Host "  [OK] $RelativePath"
}

Write-Host ""
Write-Host "=== Fixing broken dynamic route files ===" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------------------------------
# 1) /courses/[slug] -- Marketing course detail page
# ----------------------------------------------------------------------------
$courseDetailPage = @'
import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { DetailFooter } from "@/components/course-detail/DetailFooter";
import { CourseHero } from "@/components/course-detail/CourseHero";
import { WhatYoullLearn } from "@/components/course-detail/WhatYoullLearn";
import { CourseCurriculum } from "@/components/course-detail/CourseCurriculum";
import { InstructorBio } from "@/components/course-detail/InstructorBio";
import { PurchaseCard } from "@/components/course-detail/PurchaseCard";

// TODO: replace with useCourse(slug) hook from @saachi/api-client
interface CourseDetail {
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

const DUMMY_COURSE_DETAILS: Record<string, CourseDetail> = {
  "prompt-engineering-masterclass": {
    slug: "prompt-engineering-masterclass",
    category: "Generative AI",
    levelBadge: "Intermediate",
    title: "Prompt Engineering Masterclass",
    description:
      "Master the art of crafting precise instructions for large language models, from zero-shot prompting to advanced chain-of-thought reasoning.",
    rating: 4.8,
    ratingsCount: "2.4k",
    studentsCount: "18,204",
    instructorName: "Dr. Sarah Chen",
    instructorAvatar: "https://i.pravatar.cc/128?img=32",
    instructorTitle: "Lead AI Architect",
    instructorBio:
      "Sarah has spent the last decade building and teaching large-scale NLP systems, and has helped thousands of engineers level up their prompting skills.",
    previewImage:
      "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=1200&q=80",
    price: "$89.99",
    includes: ["12 hours on-demand video", "Downloadable resources", "Certificate of completion"],
  },
};

function getCourseBySlug(slug: string): CourseDetail | null {
  return DUMMY_COURSE_DETAILS[slug] ?? null;
}

interface CourseDetailPageProps {
  params: { slug: string };
}

export default async function CourseDetailPage({ params }: CourseDetailPageProps) {
  const { slug } = await params;
  const course = getCourseBySlug(slug);

  if (!course) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
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

      <main className="mx-auto flex w-full max-w-[1280px] flex-col gap-6 px-6 py-12 lg:flex-row lg:items-start">
        <div className="flex flex-1 flex-col gap-6">
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

        <div className="w-full lg:w-80">
          <PurchaseCard price={course.price} includes={course.includes} />
        </div>
      </main>

      <DetailFooter />
    </div>
  );
}
'@
Write-CodeFile "(marketing)\courses\[slug]\page.tsx" $courseDetailPage

# ----------------------------------------------------------------------------
# 2) /instructors/[slug] -- Marketing instructor profile page
# ----------------------------------------------------------------------------
$instructorPage = @'
import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { InstructorProfileCard } from "@/components/instructor/InstructorProfileCard";
import { InstructorStatsGrid } from "@/components/instructor/InstructorStatsGrid";
import { InstructorCourseCard, type InstructorCourseCardProps } from "@/components/instructor/InstructorCourseCard";

// TODO: replace with useInstructor(slug) hook from @saachi/api-client
interface InstructorProfile {
  slug: string;
  name: string;
  title: string;
  bio: string;
  avatar: string;
  tags: string[];
  coursesCount: number;
  studentsCount: string;
  rating: number;
  reviewsCount: string;
  courses: InstructorCourseCardProps[];
}

const DUMMY_INSTRUCTORS: Record<string, InstructorProfile> = {
  "dr-sarah-chen": {
    slug: "dr-sarah-chen",
    name: "Dr. Sarah Chen",
    title: "Lead AI Architect @ Saachi AI",
    bio: "Sarah has spent the last decade building and teaching large-scale NLP systems, helping thousands of engineers level up their prompting and model-building skills.",
    avatar: "https://i.pravatar.cc/256?img=32",
    tags: ["NLP", "Prompt Engineering", "LLMs"],
    coursesCount: 6,
    studentsCount: "42.1k",
    rating: 4.9,
    reviewsCount: "8.3k",
    courses: [
      {
        title: "Prompt Engineering Masterclass",
        description: "Master the art of crafting precise instructions for large language models.",
        category: "Generative AI",
        price: "$89.99",
        rating: 4.8,
        reviews: "2.4k",
        duration: "12h",
        image:
          "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
        badge: { label: "Bestseller", variant: "light" },
      },
    ],
  },
};

function getInstructorBySlug(slug: string): InstructorProfile | null {
  return DUMMY_INSTRUCTORS[slug] ?? null;
}

interface InstructorPageProps {
  params: { slug: string };
}

export default async function InstructorPage({ params }: InstructorPageProps) {
  const { slug } = await params;
  const instructor = getInstructorBySlug(slug);

  if (!instructor) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-10 px-6 py-10">
        <div className="flex flex-col gap-6 lg:flex-row">
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
        </div>

        <div className="flex flex-col gap-6">
          <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">
            Courses by {instructor.name}
          </h2>
          <div className="flex flex-wrap gap-6">
            {instructor.courses.map((course) => (
              <InstructorCourseCard key={course.title} {...course} />
            ))}
          </div>
        </div>
      </main>

      <CompactFooter />
    </div>
  );
}
'@
Write-CodeFile "(marketing)\instructors\[slug]\page.tsx" $instructorPage

# ----------------------------------------------------------------------------
# 3) /categories/[slug] -- Marketing category listing page
# ----------------------------------------------------------------------------
$categoryPage = @'
import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { CategoryBanner } from "@/components/marketplace/CategoryBanner";
import { CategoryChips } from "@/components/marketplace/CategoryChips";
import { CategoryCourseCard, type CategoryCourseCardProps } from "@/components/marketplace/CategoryCourseCard";

// TODO: replace with useCategory(slug) hook from @saachi/api-client
interface CategoryDetail {
  slug: string;
  title: string;
  description: string;
  image: string;
  chips: string[];
  courses: CategoryCourseCardProps[];
}

const DUMMY_CATEGORIES: Record<string, CategoryDetail> = {
  "nlp": {
    slug: "nlp",
    title: "NLP & Language",
    description:
      "Learn to build, fine-tune, and deploy natural language processing systems -- from tokenizers to production-grade LLM pipelines.",
    image:
      "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [
      {
        title: "Natural Language Processing with Transformers",
        description: "Build production NLP pipelines using modern transformer architectures.",
        levelTag: "Intermediate",
        rating: 4.7,
        reviews: "2.3k",
        price: "$129.99",
        image:
          "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
      },
    ],
  },
  "computer-vision": {
    slug: "computer-vision",
    title: "Computer Vision",
    description: "Implement image recognition and detection systems from first principles.",
    image:
      "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [
      {
        title: "Computer Vision Fundamentals",
        description: "Implement image recognition systems from scratch using PyTorch.",
        levelTag: "Advanced",
        rating: 4.7,
        reviews: "1.1k",
        price: "$149.00",
        image:
          "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80",
      },
    ],
  },
  "robotics": {
    slug: "robotics",
    title: "Robotics",
    description: "From kinematics to reinforcement learning -- build intelligent robotic systems.",
    image:
      "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [],
  },
  "ai-strategy": {
    slug: "ai-strategy",
    title: "AI Strategy",
    description: "Learn how leaders plan, govern, and scale AI initiatives across an organization.",
    image:
      "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [],
  },
};

function getCategoryBySlug(slug: string): CategoryDetail | null {
  return DUMMY_CATEGORIES[slug] ?? null;
}

interface CategoryPageProps {
  params: { slug: string };
}

export default async function CategoryPage({ params }: CategoryPageProps) {
  const { slug } = await params;
  const category = getCategoryBySlug(slug);

  if (!category) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-6 px-6 py-10">
        <CategoryBanner title={category.title} description={category.description} image={category.image} />

        <CategoryChips chips={category.chips} />

        {category.courses.length === 0 ? (
          <div className="flex flex-col items-center gap-2 rounded-xl border border-[var(--token-color-border)] bg-[var(--token-color-surface)] py-20 text-center">
            <p className="text-lg font-semibold text-[var(--token-color-ink)]">
              No courses yet in this category
            </p>
            <p className="text-[var(--token-color-inkSoft)]">Check back soon -- new courses are added weekly.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-6 pt-4 sm:grid-cols-2 lg:grid-cols-3">
            {category.courses.map((course) => (
              <CategoryCourseCard key={course.title} {...course} />
            ))}
          </div>
        )}
      </main>

      <CompactFooter />
    </div>
  );
}
'@
Write-CodeFile "(marketing)\categories\[slug]\page.tsx" $categoryPage

# ----------------------------------------------------------------------------
# 4) /courses/[slug]/learn -- Course player (server) + client
# ----------------------------------------------------------------------------
$coursePlayerPage = @'
import { notFound } from "next/navigation";
import { CoursePlayerClient } from "./CoursePlayerClient";

// TODO: replace with useCoursePlayer(slug) hook from @saachi/api-client
export interface PlayerLesson {
  id: string;
  title: string;
  durationLabel: string;
  completed: boolean;
}

export interface PlayerModule {
  id: string;
  title: string;
  lessons: PlayerLesson[];
}

export interface PlayerCourse {
  slug: string;
  title: string;
  videoUrl: string;
  modules: PlayerModule[];
}

const DUMMY_PLAYER_COURSES: Record<string, PlayerCourse> = {
  "prompt-engineering-masterclass": {
    slug: "prompt-engineering-masterclass",
    title: "Prompt Engineering Masterclass",
    videoUrl: "",
    modules: [
      {
        id: "m1",
        title: "Module 1: Introduction to Large Language Models",
        lessons: [
          { id: "l1", title: "What is a Large Language Model?", durationLabel: "8:12", completed: true },
          { id: "l2", title: "Tokens, Context Windows & Limits", durationLabel: "11:45", completed: true },
          { id: "l3", title: "Zero-shot vs Few-shot Prompting", durationLabel: "14:03", completed: false },
        ],
      },
      {
        id: "m2",
        title: "Module 2: Anatomy of a Perfect Prompt",
        lessons: [
          { id: "l4", title: "Structuring Instructions", durationLabel: "9:30", completed: false },
          { id: "l5", title: "Chain-of-Thought Reasoning", durationLabel: "16:20", completed: false },
        ],
      },
    ],
  },
};

function getPlayerCourseBySlug(slug: string): PlayerCourse | null {
  return DUMMY_PLAYER_COURSES[slug] ?? null;
}

interface CoursePlayerPageProps {
  params: { slug: string };
}

export default async function CoursePlayerPage({ params }: CoursePlayerPageProps) {
  const { slug } = await params;
  const course = getPlayerCourseBySlug(slug);

  if (!course) {
    notFound();
  }

  return <CoursePlayerClient course={course} />;
}
'@
Write-CodeFile "courses\[slug]\learn\page.tsx" $coursePlayerPage

$coursePlayerClient = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { CheckCircle2, Circle, PlayCircle, ArrowLeft, ChevronLeft, ChevronRight } from "lucide-react";
import type { PlayerCourse, PlayerLesson } from "./page";

interface CoursePlayerClientProps {
  course: PlayerCourse;
}

export function CoursePlayerClient({ course }: CoursePlayerClientProps) {
  const allLessons = course.modules.flatMap((m) => m.lessons);
  const [activeLessonId, setActiveLessonId] = useState<string>(
    allLessons.find((l) => !l.completed)?.id ?? allLessons[0]?.id ?? ""
  );
  const [lessons, setLessons] = useState<PlayerLesson[]>(allLessons);

  const activeIndex = lessons.findIndex((l) => l.id === activeLessonId);
  const activeLesson = lessons[activeIndex];

  function handleSelectLesson(id: string) {
    setActiveLessonId(id);
  }

  function handleMarkComplete() {
    // TODO: wire to useLessonProgress().markComplete(lessonId) from @saachi/api-client
    setLessons((prev) => prev.map((l) => (l.id === activeLessonId ? { ...l, completed: true } : l)));
  }

  function goToLesson(offset: number) {
    const nextIndex = activeIndex + offset;
    if (nextIndex >= 0 && nextIndex < lessons.length) {
      setActiveLessonId(lessons[nextIndex].id);
    }
  }

  const completedCount = lessons.filter((l) => l.completed).length;
  const progressPercent = lessons.length > 0 ? Math.round((completedCount / lessons.length) * 100) : 0;

  return (
    <div className="flex min-h-screen bg-[var(--token-color-playerBg)]">
      {/* Sidebar: curriculum */}
      <aside className="fixed inset-y-0 left-0 hidden w-80 flex-col overflow-y-auto border-r border-white/10 bg-[var(--token-color-ink)] lg:flex">
        <div className="flex flex-col gap-1 border-b border-white/10 p-6">
          <Link href={`/courses/${course.slug}`} className="flex items-center gap-2 text-sm font-semibold text-white/70 hover:text-white">
            <ArrowLeft size={14} />
            Back to Course
          </Link>
          <h1 className="pt-2 text-lg font-semibold text-white">{course.title}</h1>
          <span className="text-xs font-medium text-white/50">{progressPercent}% complete</span>
        </div>

        <nav className="flex flex-col gap-2 p-4">
          {course.modules.map((module) => (
            <div key={module.id} className="flex flex-col gap-1">
              <h3 className="px-2 pb-1 text-xs font-semibold uppercase tracking-wide text-white/40">
                {module.title}
              </h3>
              {module.lessons.map((lessonMeta) => {
                const lesson = lessons.find((l) => l.id === lessonMeta.id) ?? lessonMeta;
                const isActive = lesson.id === activeLessonId;
                return (
                  <button
                    key={lesson.id}
                    type="button"
                    onClick={() => handleSelectLesson(lesson.id)}
                    className={`flex items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm transition ${
                      isActive ? "bg-white/10 text-white" : "text-white/70 hover:bg-white/5"
                    }`}
                  >
                    {lesson.completed ? (
                      <CheckCircle2 size={16} className="shrink-0 text-[var(--token-color-completedGreen)]" />
                    ) : (
                      <Circle size={16} className="shrink-0 text-white/30" />
                    )}
                    <span className="flex-1 truncate font-medium">{lesson.title}</span>
                    <span className="shrink-0 text-xs text-white/40">{lesson.durationLabel}</span>
                  </button>
                );
              })}
            </div>
          ))}
        </nav>
      </aside>

      {/* Main player */}
      <div className="flex w-full flex-col lg:pl-80">
        <div className="flex aspect-video w-full items-center justify-center bg-black">
          <PlayCircle size={64} className="text-white/30" />
        </div>

        <div className="flex flex-1 flex-col gap-6 px-8 py-8">
          <div className="flex items-start justify-between gap-6">
            <div className="flex flex-col gap-1">
              <h2 className="text-2xl font-semibold text-white">
                {activeLesson?.title ?? "Select a lesson"}
              </h2>
              <span className="text-sm text-white/50">{activeLesson?.durationLabel}</span>
            </div>

            <button
              type="button"
              onClick={handleMarkComplete}
              disabled={!activeLesson || activeLesson.completed}
              className="flex shrink-0 items-center gap-2 rounded-lg bg-[var(--token-color-primary)] px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-[var(--token-color-primaryHover)] disabled:cursor-not-allowed disabled:opacity-50"
            >
              <CheckCircle2 size={16} />
              {activeLesson?.completed ? "Completed" : "Mark as Complete"}
            </button>
          </div>

          <div className="flex items-center justify-between border-t border-white/10 pt-6">
            <button
              type="button"
              onClick={() => goToLesson(-1)}
              disabled={activeIndex <= 0}
              className="flex items-center gap-2 rounded-lg border border-white/10 px-4 py-2 text-sm font-semibold text-white/70 transition hover:bg-white/5 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <ChevronLeft size={14} />
              Previous
            </button>

            <button
              type="button"
              onClick={() => goToLesson(1)}
              disabled={activeIndex >= lessons.length - 1}
              className="flex items-center gap-2 rounded-lg border border-white/10 px-4 py-2 text-sm font-semibold text-white/70 transition hover:bg-white/5 disabled:cursor-not-allowed disabled:opacity-40"
            >
              Next
              <ChevronRight size={14} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
'@
Write-CodeFile "courses\[slug]\learn\CoursePlayerClient.tsx" $coursePlayerClient

# ----------------------------------------------------------------------------
# 5) /dashboard/certificates/[certificateId] -- server + client
# ----------------------------------------------------------------------------
$certDetailPage = @'
import { notFound } from "next/navigation";
import { CertificateDetailClient } from "./CertificateDetailClient";

// TODO: replace with useCertificate(certificateId) hook from @saachi/api-client
export interface CertificateDetail {
  id: string;
  title: string;
  category: string;
  issuedDate: string;
  recipientName: string;
  instructorName: string;
  credentialId: string;
  image: string;
}

const DUMMY_CERTIFICATES: Record<string, CertificateDetail> = {
  cert1: {
    id: "cert1",
    title: "Advanced Machine Learning Architectures",
    category: "AI & Data",
    issuedDate: "Oct 12, 2024",
    recipientName: "Alex Morgan",
    instructorName: "Dr. Sarah Chen",
    credentialId: "SAI-CERT-88213",
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=800&q=80",
  },
  cert2: {
    id: "cert2",
    title: "Ethical AI Governance & Policy",
    category: "Ethics",
    issuedDate: "Sep 05, 2024",
    recipientName: "Alex Morgan",
    instructorName: "Marcus Johnson",
    credentialId: "SAI-CERT-77104",
    image:
      "https://images.unsplash.com/photo-1450101499163-c8848c66ca85?auto=format&fit=crop&w=800&q=80",
  },
  cert3: {
    id: "cert3",
    title: "Python for Data Science Bootcamp",
    category: "Programming",
    issuedDate: "Jul 22, 2024",
    recipientName: "Alex Morgan",
    instructorName: "David Kim",
    credentialId: "SAI-CERT-65590",
    image:
      "https://images.unsplash.com/photo-1526379879527-8559ecfcaec0?auto=format&fit=crop&w=800&q=80",
  },
};

function getCertificateById(certificateId: string): CertificateDetail | null {
  return DUMMY_CERTIFICATES[certificateId] ?? null;
}

interface CertificateDetailPageProps {
  params: { certificateId: string };
}

export default async function CertificateDetailPage({ params }: CertificateDetailPageProps) {
  const { certificateId } = await params;
  const certificate = getCertificateById(certificateId);

  if (!certificate) {
    notFound();
  }

  return <CertificateDetailClient certificate={certificate} />;
}
'@
Write-CodeFile "(learner)\dashboard\certificates\[certificateId]\page.tsx" $certDetailPage

$certDetailClient = @'
"use client";

import Link from "next/link";
import Image from "next/image";
import { Button } from "antd";
import { ArrowLeft, Download, Share2, BadgeCheck } from "lucide-react";
import type { CertificateDetail } from "./page";

interface CertificateDetailClientProps {
  certificate: CertificateDetail;
}

export function CertificateDetailClient({ certificate }: CertificateDetailClientProps) {
  function handleDownload() {
    // TODO: wire to useCertificates().download(certificate.id) from @saachi/api-client
    console.log("download certificate", certificate.id);
  }

  function handleShare() {
    // TODO: wire to share sheet / copy public credential link
    console.log("share certificate", certificate.id);
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)] px-6 py-10">
      <div className="mx-auto flex w-full max-w-[900px] flex-col gap-6">
        <Link
          href="/dashboard/certificates"
          className="flex w-fit items-center gap-2 text-sm font-semibold text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
        >
          <ArrowLeft size={14} />
          Back to Certificates
        </Link>

        <div className="overflow-hidden rounded-2xl border bg-[var(--token-color-surface)] shadow-[var(--token-shadow-lg)]" style={{ borderColor: "var(--token-color-border)" }}>
          <div className="relative h-72 w-full bg-[var(--token-color-surfaceAlt)]">
            <Image src={certificate.image} alt={certificate.title} fill sizes="900px" className="object-cover" />
          </div>

          <div className="flex flex-col gap-6 p-8">
            <div className="flex items-start justify-between gap-4">
              <div className="flex flex-col gap-1">
                <span className="flex items-center gap-1.5 text-xs font-semibold uppercase tracking-wide" style={{ color: "var(--token-color-primary)" }}>
                  <BadgeCheck size={14} />
                  {certificate.category}
                </span>
                <h1 className="text-3xl font-bold" style={{ color: "var(--token-color-ink)" }}>
                  {certificate.title}
                </h1>
              </div>
            </div>

            <div className="grid grid-cols-1 gap-4 rounded-lg p-4 sm:grid-cols-3" style={{ backgroundColor: "var(--token-color-surfaceAlt)" }}>
              <DetailField label="Recipient" value={certificate.recipientName} />
              <DetailField label="Instructor" value={certificate.instructorName} />
              <DetailField label="Issued" value={certificate.issuedDate} />
            </div>

            <div className="flex items-center justify-between border-t pt-4" style={{ borderColor: "var(--token-color-border)" }}>
              <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                Credential ID: {certificate.credentialId}
              </span>

              <div className="flex gap-2">
                <Button icon={<Share2 size={14} />} onClick={handleShare}>
                  Share
                </Button>
                <Button type="primary" icon={<Download size={14} />} onClick={handleDownload}>
                  Download PDF
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function DetailField({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex flex-col gap-0.5">
      <span className="text-xs font-medium uppercase tracking-wide" style={{ color: "var(--token-color-inkSoft)" }}>
        {label}
      </span>
      <span className="text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
        {value}
      </span>
    </div>
  );
}
'@
Write-CodeFile "(learner)\dashboard\certificates\[certificateId]\CertificateDetailClient.tsx" $certDetailClient

# ----------------------------------------------------------------------------
# 6) /dashboard/community/[courseSlug] -- server + client
# ----------------------------------------------------------------------------
$communityPage = @'
import { notFound } from "next/navigation";
import { CommunityQAClient } from "./CommunityQAClient";

// TODO: replace with useCourseCommunity(courseSlug) hook from @saachi/api-client
export interface QAThread {
  id: string;
  authorName: string;
  authorAvatar: string;
  question: string;
  timestamp: string;
  replyCount: number;
  upvotes: number;
}

export interface CommunityCourse {
  slug: string;
  title: string;
  threads: QAThread[];
}

const DUMMY_COMMUNITIES: Record<string, CommunityCourse> = {
  "prompt-engineering-masterclass": {
    slug: "prompt-engineering-masterclass",
    title: "Prompt Engineering Masterclass",
    threads: [
      {
        id: "t1",
        authorName: "Jordan Lee",
        authorAvatar: "https://i.pravatar.cc/64?img=15",
        question: "What's the difference between few-shot and chain-of-thought prompting in practice?",
        timestamp: "2 hours ago",
        replyCount: 4,
        upvotes: 12,
      },
      {
        id: "t2",
        authorName: "Priya Nair",
        authorAvatar: "https://i.pravatar.cc/64?img=25",
        question: "Anyone have a good template for reducing hallucinations in factual Q&A prompts?",
        timestamp: "Yesterday",
        replyCount: 7,
        upvotes: 21,
      },
    ],
  },
};

function getCommunityBySlug(slug: string): CommunityCourse | null {
  return DUMMY_COMMUNITIES[slug] ?? null;
}

interface CommunityPageProps {
  params: { courseSlug: string };
}

export default async function CommunityPage({ params }: CommunityPageProps) {
  const { courseSlug } = await params;
  const community = getCommunityBySlug(courseSlug);

  if (!community) {
    notFound();
  }

  return <CommunityQAClient community={community} />;
}
'@
Write-CodeFile "(learner)\dashboard\community\[courseSlug]\page.tsx" $communityPage

$communityClient = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button, Input } from "antd";
import { ArrowLeft, MessageCircle, ThumbsUp, Send } from "lucide-react";
import type { CommunityCourse, QAThread } from "./page";

interface CommunityQAClientProps {
  community: CommunityCourse;
}

export function CommunityQAClient({ community }: CommunityQAClientProps) {
  const [threads, setThreads] = useState<QAThread[]>(community.threads);
  const [newQuestion, setNewQuestion] = useState("");

  function handlePostQuestion() {
    if (!newQuestion.trim()) return;
    // TODO: wire to useCourseCommunity().postQuestion(courseSlug, text) from @saachi/api-client
    const thread: QAThread = {
      id: `local-${Date.now()}`,
      authorName: "You",
      authorAvatar: "https://i.pravatar.cc/64?img=47",
      question: newQuestion.trim(),
      timestamp: "Just now",
      replyCount: 0,
      upvotes: 0,
    };
    setThreads((prev) => [thread, ...prev]);
    setNewQuestion("");
  }

  function handleUpvote(threadId: string) {
    setThreads((prev) =>
      prev.map((t) => (t.id === threadId ? { ...t, upvotes: t.upvotes + 1 } : t))
    );
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)] px-6 py-10 lg:px-12">
      <div className="mx-auto flex w-full max-w-[800px] flex-col gap-8">
        <div className="flex flex-col gap-1">
          <Link
            href="/dashboard/my-courses"
            className="flex w-fit items-center gap-2 text-sm font-semibold text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
          >
            <ArrowLeft size={14} />
            Back to My Courses
          </Link>
          <h1 className="pt-2 text-3xl font-bold" style={{ color: "var(--token-color-ink)" }}>
            Community Q&amp;A
          </h1>
          <p style={{ color: "var(--token-color-inkSoft)" }}>{community.title}</p>
        </div>

        <div className="flex flex-col gap-3 rounded-xl border bg-[var(--token-color-surface)] p-4 shadow-[var(--token-shadow-sm)]" style={{ borderColor: "var(--token-color-border)" }}>
          <Input.TextArea
            rows={3}
            value={newQuestion}
            onChange={(e) => setNewQuestion(e.target.value)}
            placeholder="Ask a question about this course..."
          />
          <div className="flex justify-end">
            <Button type="primary" icon={<Send size={14} />} onClick={handlePostQuestion}>
              Post Question
            </Button>
          </div>
        </div>

        <div className="flex flex-col gap-4">
          {threads.map((thread) => (
            <div
              key={thread.id}
              className="flex gap-4 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
              style={{ borderColor: "var(--token-color-border)" }}
            >
              <span className="relative block h-10 w-10 shrink-0 overflow-hidden rounded-full">
                <Image src={thread.authorAvatar} alt={thread.authorName} fill sizes="40px" className="object-cover" />
              </span>

              <div className="flex flex-1 flex-col gap-2">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
                    {thread.authorName}
                  </span>
                  <span className="text-xs" style={{ color: "var(--token-color-inkSoft)" }}>
                    {thread.timestamp}
                  </span>
                </div>

                <p style={{ color: "var(--token-color-ink)" }}>{thread.question}</p>

                <div className="flex items-center gap-4 pt-1">
                  <button
                    type="button"
                    onClick={() => handleUpvote(thread.id)}
                    className="flex items-center gap-1 text-xs font-semibold"
                    style={{ color: "var(--token-color-inkSoft)" }}
                  >
                    <ThumbsUp size={13} />
                    {thread.upvotes}
                  </button>
                  <span className="flex items-center gap-1 text-xs font-semibold" style={{ color: "var(--token-color-inkSoft)" }}>
                    <MessageCircle size={13} />
                    {thread.replyCount} replies
                  </span>
                </div>
              </div>
            </div>
          ))}

          {threads.length === 0 && (
            <p className="py-10 text-center" style={{ color: "var(--token-color-inkSoft)" }}>
              No questions yet -- be the first to ask.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}
'@
Write-CodeFile "(learner)\dashboard\community\[courseSlug]\CommunityQAClient.tsx" $communityClient

# ----------------------------------------------------------------------------
# 7) /dashboard/mentorship/[instructorSlug] -- server + client (booking)
# ----------------------------------------------------------------------------
$mentorshipBookingPage = @'
import { notFound } from "next/navigation";
import { MentorshipBookingClient } from "./MentorshipBookingClient";

// TODO: replace with useMentor(instructorSlug) hook from @saachi/api-client
export interface MentorTimeSlot {
  id: string;
  label: string;
}

export interface MentorProfile {
  slug: string;
  name: string;
  title: string;
  avatar: string;
  bio: string;
  rate: string;
  availableSlots: MentorTimeSlot[];
}

const DUMMY_MENTORS: Record<string, MentorProfile> = {
  "dr-sarah-chen": {
    slug: "dr-sarah-chen",
    name: "Dr. Sarah Chen",
    title: "Lead AI Architect",
    avatar: "https://i.pravatar.cc/128?img=32",
    bio: "Sarah offers 1:1 mentorship on LLM architecture, RAG systems, and prompt engineering best practices.",
    rate: "$120 / session",
    availableSlots: [
      { id: "s1", label: "Tomorrow, 10:00 AM EST" },
      { id: "s2", label: "Tomorrow, 2:00 PM EST" },
      { id: "s3", label: "Thursday, 11:30 AM EST" },
    ],
  },
  "marcus-johnson": {
    slug: "marcus-johnson",
    name: "Marcus Johnson",
    title: "Sr. Data Scientist",
    avatar: "https://i.pravatar.cc/128?img=13",
    bio: "Marcus specializes in model fine-tuning strategies and helping teams choose between LoRA and full fine-tuning.",
    rate: "$95 / session",
    availableSlots: [
      { id: "s1", label: "Friday, 9:00 AM EST" },
      { id: "s2", label: "Friday, 1:00 PM EST" },
    ],
  },
};

function getMentorBySlug(slug: string): MentorProfile | null {
  return DUMMY_MENTORS[slug] ?? null;
}

interface MentorshipBookingPageProps {
  params: { instructorSlug: string };
}

export default async function MentorshipBookingPage({ params }: MentorshipBookingPageProps) {
  const { instructorSlug } = await params;
  const mentor = getMentorBySlug(instructorSlug);

  if (!mentor) {
    notFound();
  }

  return <MentorshipBookingClient mentor={mentor} />;
}
'@
Write-CodeFile "(learner)\dashboard\mentorship\[instructorSlug]\page.tsx" $mentorshipBookingPage

$mentorshipBookingClient = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button, message } from "antd";
import { ArrowLeft, Calendar, CheckCircle2 } from "lucide-react";
import type { MentorProfile } from "./page";

interface MentorshipBookingClientProps {
  mentor: MentorProfile;
}

export function MentorshipBookingClient({ mentor }: MentorshipBookingClientProps) {
  const [selectedSlotId, setSelectedSlotId] = useState<string | null>(null);
  const [booked, setBooked] = useState(false);

  function handleConfirmBooking() {
    if (!selectedSlotId) return;
    // TODO: wire to useMentorshipSessions().book(mentor.slug, selectedSlotId) from @saachi/api-client
    setBooked(true);
    message.success("Session booked! Check your dashboard for details.");
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)] px-6 py-10 lg:px-12">
      <div className="mx-auto flex w-full max-w-[720px] flex-col gap-8">
        <Link
          href="/dashboard/mentorship"
          className="flex w-fit items-center gap-2 text-sm font-semibold text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
        >
          <ArrowLeft size={14} />
          Back to Mentorship
        </Link>

        <div className="flex items-center gap-6 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]" style={{ borderColor: "var(--token-color-border)" }}>
          <span className="relative block h-20 w-20 shrink-0 overflow-hidden rounded-full">
            <Image src={mentor.avatar} alt={mentor.name} fill sizes="80px" className="object-cover" />
          </span>
          <div className="flex flex-col gap-1">
            <h1 className="text-2xl font-bold" style={{ color: "var(--token-color-ink)" }}>
              {mentor.name}
            </h1>
            <span className="text-sm font-semibold" style={{ color: "var(--token-color-primary)" }}>
              {mentor.title}
            </span>
            <p className="pt-1 text-sm" style={{ color: "var(--token-color-inkSoft)" }}>
              {mentor.bio}
            </p>
          </div>
        </div>

        {booked ? (
          <div className="flex flex-col items-center gap-3 rounded-xl border bg-[var(--token-color-surface)] p-10 text-center shadow-[var(--token-shadow-sm)]" style={{ borderColor: "var(--token-color-border)" }}>
            <CheckCircle2 size={40} color="var(--token-color-success)" />
            <h2 className="text-xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
              Session Confirmed
            </h2>
            <p style={{ color: "var(--token-color-inkSoft)" }}>
              Your session with {mentor.name} is booked. A calendar invite will be sent shortly.
            </p>
            <Link href="/dashboard/mentorship">
              <Button type="primary">Back to Mentorship</Button>
            </Link>
          </div>
        ) : (
          <div className="flex flex-col gap-4 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]" style={{ borderColor: "var(--token-color-border)" }}>
            <div className="flex items-center justify-between">
              <h2 className="flex items-center gap-2 text-xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
                <Calendar size={18} color="var(--token-color-primary)" />
                Choose a Time
              </h2>
              <span className="text-sm font-bold" style={{ color: "var(--token-color-primary)" }}>
                {mentor.rate}
              </span>
            </div>

            <div className="flex flex-col gap-2">
              {mentor.availableSlots.map((slot) => {
                const isSelected = slot.id === selectedSlotId;
                return (
                  <button
                    key={slot.id}
                    type="button"
                    onClick={() => setSelectedSlotId(slot.id)}
                    className="flex items-center justify-between rounded-lg border px-4 py-3 text-left text-sm font-semibold transition"
                    style={{
                      borderColor: isSelected ? "var(--token-color-primary)" : "var(--token-color-border)",
                      backgroundColor: isSelected ? "var(--token-color-primaryTint)" : "var(--token-color-bg)",
                      color: isSelected ? "var(--token-color-primary)" : "var(--token-color-ink)",
                    }}
                  >
                    {slot.label}
                    {isSelected && <CheckCircle2 size={16} />}
                  </button>
                );
              })}
            </div>

            <Button
              type="primary"
              size="large"
              disabled={!selectedSlotId}
              onClick={handleConfirmBooking}
              block
            >
              Confirm Booking
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}
'@
Write-CodeFile "(learner)\dashboard\mentorship\[instructorSlug]\MentorshipBookingClient.tsx" $mentorshipBookingClient

Write-Host ""
Write-Host "=== Done. 11 files written. ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. cd apps\web"
Write-Host "  2. pnpm run type-check   (or: pnpm --filter web run type-check)"
Write-Host "  3. pnpm run dev"
Write-Host ""
Write-Host "Note: dummy data only covers a few slugs (e.g. 'prompt-engineering-masterclass',"
Write-Host "'dr-sarah-chen', 'cert1'/'cert2'/'cert3', 'nlp'/'computer-vision'). Visiting an"
Write-Host "unknown slug will correctly render the 404 page via notFound()." -ForegroundColor DarkYellow
Write-Host ""