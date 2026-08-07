# fix-frontend.ps1
# Run from: PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>
# Fixes: mock login (no real creds needed), dummy course data, missing course detail page,
# missing learner dashboard, missing Navbar/Footer on courses listing.

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}

Write-Host "Fixing Saachi AI web frontend (dummy data + demo login)..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. packages/api-client/src/dummy-data.ts
# ---------------------------------------------------------------------------
$dummyData = @'
import type { Course, CourseDetail, Session } from "./types";

export const DUMMY_SESSION: Session = {
  id: "usr_demo_001",
  fullName: "Ayesha Khan",
  email: "demo@saachi.ai",
  role: "learner"
};

export type DummyCourse = CourseDetail & {
  categoryId: string;
  level: "beginner" | "intermediate" | "advanced";
  language: "en" | "ur";
};

function toCourseSummary(course: DummyCourse): Course {
  return {
    id: course.id,
    slug: course.slug,
    title: course.title,
    subtitle: course.subtitle,
    thumbnailUrl: course.thumbnailUrl,
    price: course.price,
    currency: course.currency,
    rating: course.rating,
    ratingCount: course.ratingCount,
    instructor: course.instructor,
    status: course.status
  };
}

const BASE_COURSES: DummyCourse[] = [
  {
    id: "crs_001",
    slug: "prompt-engineering-fundamentals",
    title: "Prompt Engineering Fundamentals",
    subtitle: "Go from zero to confident with ChatGPT, Claude, and Gemini.",
    price: 29,
    currency: "USD",
    rating: 4.8,
    ratingCount: 1240,
    categoryId: "ai-fundamentals",
    level: "beginner",
    language: "en",
    status: "published",
    instructor: { id: "ins_001", fullName: "Sana Rizvi" },
    description:
      "Learn how to write prompts that actually get useful, reliable output from modern AI models. You will practice on real business tasks - writing, research, summarization, and structured data extraction - and finish with a personal prompt library you can reuse on the job.",
    instructorBio: "AI marketing consultant and instructor with 6+ years teaching applied AI workflows.",
    instructorCourseCount: 4,
    instructorStudentCount: 8300,
    curriculum: [
      {
        id: "mod_1",
        title: "Getting Started",
        lessons: [
          { id: "les_1", title: "Why prompting is a skill", type: "video", durationSeconds: 420, isPreview: true },
          { id: "les_2", title: "Setting up your workspace", type: "text", durationSeconds: 180 }
        ]
      },
      {
        id: "mod_2",
        title: "Core Prompting Techniques",
        lessons: [
          { id: "les_3", title: "Instructions vs. context", type: "video", durationSeconds: 540 },
          { id: "les_4", title: "Few-shot examples", type: "video", durationSeconds: 480 },
          { id: "les_5", title: "Knowledge check", type: "quiz" }
        ]
      },
      {
        id: "mod_3",
        title: "Applying It To Real Work",
        lessons: [
          { id: "les_6", title: "Writing a research prompt", type: "video", durationSeconds: 600 },
          { id: "les_7", title: "Prompt library template", type: "resource" }
        ]
      }
    ],
    ratingBreakdown: { 5: 900, 4: 250, 3: 60, 2: 20, 1: 10 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Bilal Ahmed",
        rating: 5,
        comment: "Clear, practical, and I actually use the prompt library every week now.",
        createdAt: "2026-06-12T10:00:00.000Z",
        verifiedPurchase: true
      },
      {
        id: "rev_2",
        authorName: "Hina Malik",
        rating: 4,
        comment: "Great intro course. Wish there was more on API usage, but perfect for beginners.",
        createdAt: "2026-05-28T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Do I need any prior experience?", answer: "No - this course starts from zero." },
      { id: "faq_2", question: "Which AI tools does it cover?", answer: "ChatGPT, Claude, and Gemini, with transferable techniques for any model." }
    ]
  },
  {
    id: "crs_002",
    slug: "ai-powered-marketing-campaigns",
    title: "AI-Powered Marketing Campaigns",
    subtitle: "Plan, write, and launch full campaigns with AI copilots.",
    price: 49,
    currency: "USD",
    rating: 4.6,
    ratingCount: 812,
    categoryId: "ai-marketing",
    level: "intermediate",
    language: "en",
    status: "published",
    instructor: { id: "ins_002", fullName: "Zara Farooq" },
    description:
      "A hands-on workflow for using AI to plan a campaign calendar, generate ad copy variants, draft email sequences, and analyze performance - the exact process working marketers use for client accounts.",
    instructorBio: "Runs a 4-person AI-first marketing agency serving South Asian SMEs.",
    instructorCourseCount: 2,
    instructorStudentCount: 3100,
    curriculum: [
      {
        id: "mod_1",
        title: "Campaign Planning with AI",
        lessons: [
          { id: "les_1", title: "Building a campaign brief", type: "video", durationSeconds: 500, isPreview: true },
          { id: "les_2", title: "Audience research prompts", type: "video", durationSeconds: 420 }
        ]
      },
      {
        id: "mod_2",
        title: "Content Generation",
        lessons: [
          { id: "les_3", title: "Ad copy variants at scale", type: "video", durationSeconds: 460 },
          { id: "les_4", title: "Email sequence workflow", type: "text", durationSeconds: 300 }
        ]
      }
    ],
    ratingBreakdown: { 5: 560, 4: 180, 3: 50, 2: 15, 1: 7 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Omar Sheikh",
        rating: 5,
        comment: "Cut my campaign prep time in half. Worth every rupee.",
        createdAt: "2026-06-02T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Which AI tools are used?", answer: "ChatGPT and Claude, plus a spreadsheet template - no paid tools required." }
    ]
  },
  {
    id: "crs_003",
    slug: "automate-everything-with-n8n-and-ai",
    title: "Automate Everything with n8n & AI",
    subtitle: "Connect AI models into no-code workflows that run themselves.",
    price: 39,
    currency: "USD",
    rating: 4.7,
    ratingCount: 654,
    categoryId: "ai-automation",
    level: "intermediate",
    language: "en",
    status: "published",
    instructor: { id: "ins_003", fullName: "Ayesha Khan" },
    description:
      "Build five real automations step by step: lead qualification, content repurposing, invoice parsing, support ticket routing, and a daily AI digest - all inside n8n, wired up to OpenAI.",
    instructorBio: "Freelance automation consultant, builds n8n workflows for e-commerce clients.",
    instructorCourseCount: 3,
    instructorStudentCount: 5200,
    curriculum: [
      {
        id: "mod_1",
        title: "n8n Basics",
        lessons: [
          { id: "les_1", title: "Installing and connecting n8n", type: "video", durationSeconds: 380, isPreview: true },
          { id: "les_2", title: "Your first AI node", type: "video", durationSeconds: 340 }
        ]
      },
      {
        id: "mod_2",
        title: "Five Real Automations",
        lessons: [
          { id: "les_3", title: "Lead qualification bot", type: "video", durationSeconds: 620 },
          { id: "les_4", title: "Invoice parsing pipeline", type: "video", durationSeconds: 580 },
          { id: "les_5", title: "Starter workflow files", type: "resource" }
        ]
      }
    ],
    ratingBreakdown: { 5: 460, 4: 140, 3: 35, 2: 12, 1: 7 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Fatima Noor",
        rating: 5,
        comment: "The invoice parsing workflow alone paid for the course.",
        createdAt: "2026-05-15T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Is n8n free to use?", answer: "Yes, the self-hosted version is free and used throughout this course." }
    ]
  },
  {
    id: "crs_004",
    slug: "build-a-whatsapp-ai-auto-responder",
    title: "Build a WhatsApp AI Auto-Responder",
    subtitle: "Ship a working AI customer-support bot on WhatsApp.",
    price: 59,
    currency: "USD",
    rating: 4.9,
    ratingCount: 401,
    categoryId: "ai-support",
    level: "advanced",
    language: "en",
    status: "published",
    instructor: { id: "ins_004", fullName: "Bilal Ahmed" },
    description:
      "A complete build: connect the WhatsApp Business API, wire it to an AI model with your own knowledge base, and deploy a bot that can answer real customer questions and escalate to a human when needed.",
    instructorBio: "Built AI support systems for three Pakistani D2C brands.",
    instructorCourseCount: 1,
    instructorStudentCount: 1450,
    curriculum: [
      {
        id: "mod_1",
        title: "WhatsApp API Setup",
        lessons: [
          { id: "les_1", title: "WhatsApp Business API basics", type: "video", durationSeconds: 400, isPreview: true },
          { id: "les_2", title: "Webhook configuration", type: "text", durationSeconds: 260 }
        ]
      },
      {
        id: "mod_2",
        title: "Building the AI Layer",
        lessons: [
          { id: "les_3", title: "Knowledge base + retrieval", type: "video", durationSeconds: 560 },
          { id: "les_4", title: "Human handoff logic", type: "video", durationSeconds: 400 }
        ]
      }
    ],
    ratingBreakdown: { 5: 360, 4: 30, 3: 6, 2: 3, 1: 2 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Sara Iqbal",
        rating: 5,
        comment: "Most technical course on the platform, but explained really well.",
        createdAt: "2026-06-20T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Do I need coding experience?", answer: "Basic JavaScript helps, but each step is explained from scratch." }
    ]
  },
  {
    id: "crs_005",
    slug: "ship-your-first-ai-powered-web-app",
    title: "Ship Your First AI-Powered Web App",
    subtitle: "From idea to a deployed app using AI-assisted development.",
    price: 45,
    currency: "USD",
    rating: 4.5,
    ratingCount: 588,
    categoryId: "ai-dev",
    level: "intermediate",
    language: "en",
    status: "published",
    instructor: { id: "ins_005", fullName: "Hamza Tariq" },
    description:
      "Use AI coding tools to plan, build, and deploy a small full-stack app in a weekend - covering scaffolding, debugging with AI, and shipping to production.",
    instructorBio: "Full-stack developer teaching AI-assisted development workflows.",
    instructorCourseCount: 2,
    instructorStudentCount: 2700,
    curriculum: [
      {
        id: "mod_1",
        title: "Planning with AI",
        lessons: [
          { id: "les_1", title: "Turning an idea into a spec", type: "video", durationSeconds: 360, isPreview: true }
        ]
      },
      {
        id: "mod_2",
        title: "Build & Deploy",
        lessons: [
          { id: "les_2", title: "Scaffolding the app", type: "video", durationSeconds: 500 },
          { id: "les_3", title: "Deploying to production", type: "video", durationSeconds: 320 }
        ]
      }
    ],
    ratingBreakdown: { 5: 400, 4: 140, 3: 35, 2: 8, 1: 5 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Noor Fatima",
        rating: 4,
        comment: "Fast-paced but I had a working app by the end.",
        createdAt: "2026-04-30T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Which AI coding tool is used?", answer: "The course covers general techniques that work with any modern AI coding assistant." }
    ]
  },
  {
    id: "crs_006",
    slug: "integrating-openai-and-claude-apis-into-node",
    title: "Integrating OpenAI & Claude APIs into Node.js Apps",
    subtitle: "Production patterns for adding AI features to real applications.",
    price: 65,
    currency: "USD",
    rating: 4.9,
    ratingCount: 320,
    categoryId: "ai-integration",
    level: "advanced",
    language: "en",
    status: "published",
    instructor: { id: "ins_006", fullName: "Usman Ali" },
    description:
      "Covers authentication, streaming responses, function/tool calling, error handling, cost control, and testing - everything needed to ship an AI feature that survives production traffic.",
    instructorBio: "Backend engineer, has shipped AI features at two Series-A startups.",
    instructorCourseCount: 3,
    instructorStudentCount: 1900,
    curriculum: [
      {
        id: "mod_1",
        title: "Foundations",
        lessons: [
          { id: "les_1", title: "Auth and API key management", type: "video", durationSeconds: 300, isPreview: true },
          { id: "les_2", title: "Streaming responses", type: "video", durationSeconds: 420 }
        ]
      },
      {
        id: "mod_2",
        title: "Production Concerns",
        lessons: [
          { id: "les_3", title: "Tool calling patterns", type: "video", durationSeconds: 540 },
          { id: "les_4", title: "Cost control and rate limits", type: "text", durationSeconds: 260 }
        ]
      }
    ],
    ratingBreakdown: { 5: 290, 4: 22, 3: 5, 2: 2, 1: 1 },
    reviews: [
      {
        id: "rev_1",
        authorName: "Danish Raza",
        rating: 5,
        comment: "Exactly the production-level detail I couldn't find anywhere else.",
        createdAt: "2026-06-25T10:00:00.000Z",
        verifiedPurchase: true
      }
    ],
    faq: [
      { id: "faq_1", question: "Is this course Python or Node.js?", answer: "Node.js / TypeScript throughout." }
    ]
  }
];

export const DUMMY_COURSES: DummyCourse[] = BASE_COURSES.map((course, index) => {
  const others = BASE_COURSES.filter((c) => c.id !== course.id);
  const related = [others[index % others.length], others[(index + 1) % others.length]].filter(Boolean);
  return { ...course, relatedCourses: related.map(toCourseSummary) };
});
'@
Write-Utf8NoBom -Path "packages\api-client\src\dummy-data.ts" -Content $dummyData

# ---------------------------------------------------------------------------
# 2. packages/api-client/src/hooks/useAuth.ts (mock auth, no backend needed)
# ---------------------------------------------------------------------------
$useAuth = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { authKeys } from "../query-keys";
import type { Session } from "../types";
import type { LoginInput, RegisterInput } from "@saachi/utils";
import { DUMMY_SESSION } from "../dummy-data";

const SESSION_COOKIE = "saachi_session";
const SESSION_STORAGE_KEY = "saachi_demo_session";

function setSessionCookie() {
  if (typeof document === "undefined") return;
  document.cookie = `${SESSION_COOKIE}=demo_token; path=/; max-age=${60 * 60 * 24 * 7}`;
}

function clearSessionCookie() {
  if (typeof document === "undefined") return;
  document.cookie = `${SESSION_COOKIE}=; path=/; max-age=0`;
}

function readStoredSession(): Session | null {
  if (typeof window === "undefined") return null;
  const raw = window.localStorage.getItem(SESSION_STORAGE_KEY);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as Session;
  } catch {
    return null;
  }
}

function storeSession(session: Session) {
  if (typeof window === "undefined") return;
  window.localStorage.setItem(SESSION_STORAGE_KEY, JSON.stringify(session));
}

function clearStoredSession() {
  if (typeof window === "undefined") return;
  window.localStorage.removeItem(SESSION_STORAGE_KEY);
}

function delay<T>(value: T, ms = 500): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: Demo mode. There is no backend yet, so login/register accept ANY
// email/password and create a local mock session. Swap these mutationFns
// for real apiRequest(...) calls once the NestJS backend is available.

export function useSession() {
  return useQuery({
    queryKey: authKeys.session,
    queryFn: async () => readStoredSession(),
    staleTime: 60 * 1000
  });
}

export function useLogin() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: LoginInput) => {
      const session: Session = {
        ...DUMMY_SESSION,
        email: input.email || DUMMY_SESSION.email
      };
      return delay(session);
    },
    onSuccess: (session) => {
      storeSession(session);
      setSessionCookie();
      queryClient.setQueryData(authKeys.session, session);
    }
  });
}

export function useRegister() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: RegisterInput) => {
      const session: Session = {
        ...DUMMY_SESSION,
        fullName: input.fullName,
        email: input.email,
        role: input.role === "instructor" ? "instructor" : "learner"
      };
      return delay(session);
    },
    onSuccess: (session) => {
      storeSession(session);
      setSessionCookie();
      queryClient.setQueryData(authKeys.session, session);
    }
  });
}

export function useLogout() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async () => {
      clearStoredSession();
      clearSessionCookie();
      return delay(undefined, 200);
    },
    onSuccess: () => {
      queryClient.clear();
    }
  });
}
'@
Write-Utf8NoBom -Path "packages\api-client\src\hooks\useAuth.ts" -Content $useAuth

# ---------------------------------------------------------------------------
# 3. packages/api-client/src/hooks/useCourses.ts (dummy-data backed)
# ---------------------------------------------------------------------------
$useCourses = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { courseKeys } from "../query-keys";
import type { Course, CourseDetail, Paginated } from "../types";
import { DUMMY_COURSES, type DummyCourse } from "../dummy-data";

export type CourseListFilters = {
  category?: string;
  search?: string;
  priceMin?: number;
  priceMax?: number;
  level?: string;
  language?: string;
  sort?: string;
  page?: number;
};

function delay<T>(value: T, ms = 400): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

function toSummary(course: DummyCourse): Course {
  return {
    id: course.id,
    slug: course.slug,
    title: course.title,
    subtitle: course.subtitle,
    thumbnailUrl: course.thumbnailUrl,
    price: course.price,
    currency: course.currency,
    rating: course.rating,
    ratingCount: course.ratingCount,
    instructor: course.instructor,
    status: course.status
  };
}

export function useCourseList(filters: CourseListFilters = {}) {
  return useQuery({
    queryKey: courseKeys.list(filters),
    queryFn: async () => {
      let items = [...DUMMY_COURSES];

      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter(
          (c) => c.title.toLowerCase().includes(q) || c.instructor.fullName.toLowerCase().includes(q)
        );
      }
      if (filters.category) {
        items = items.filter((c) => c.categoryId === filters.category);
      }
      if (filters.level) {
        items = items.filter((c) => c.level === filters.level);
      }
      if (filters.language) {
        items = items.filter((c) => c.language === filters.language);
      }
      if (typeof filters.priceMin === "number") {
        items = items.filter((c) => c.price >= (filters.priceMin as number));
      }
      if (typeof filters.priceMax === "number") {
        items = items.filter((c) => c.price <= (filters.priceMax as number));
      }

      switch (filters.sort) {
        case "newest":
          items = [...items].reverse();
          break;
        case "price_asc":
          items = [...items].sort((a, b) => a.price - b.price);
          break;
        case "price_desc":
          items = [...items].sort((a, b) => b.price - a.price);
          break;
        case "rating":
          items = [...items].sort((a, b) => b.rating - a.rating);
          break;
        case "popular":
        default:
          items = [...items].sort((a, b) => b.ratingCount - a.ratingCount);
      }

      const page = filters.page ?? 1;
      const pageSize = 12;
      const start = (page - 1) * pageSize;
      const pageItems = items.slice(start, start + pageSize).map(toSummary);

      return delay<Paginated<Course>>({
        items: pageItems,
        total: items.length,
        page,
        pageSize
      });
    }
  });
}

export function useCourseDetail(idOrSlug: string) {
  return useQuery({
    queryKey: courseKeys.detail(idOrSlug),
    queryFn: async () => {
      const found = DUMMY_COURSES.find((c) => c.slug === idOrSlug || c.id === idOrSlug);
      if (!found) throw new Error("Course not found");
      const { categoryId, level, language, ...detail } = found;
      return delay<CourseDetail>(detail);
    },
    enabled: Boolean(idOrSlug)
  });
}

export function useCreateCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: Partial<Course>) => {
      const created: Course = {
        id: `crs_${Math.random().toString(36).slice(2, 8)}`,
        slug: (input.slug as string) ?? "new-course",
        title: input.title ?? "Untitled course",
        price: input.price ?? 0,
        currency: input.currency ?? "USD",
        rating: 0,
        ratingCount: 0,
        instructor: input.instructor ?? { id: "ins_demo", fullName: "Demo Instructor" },
        status: "draft"
      };
      return delay(created);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: courseKeys.all });
    }
  });
}

export function useUpdateCourse(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: Partial<Course>) => {
      const existing = DUMMY_COURSES.find((c) => c.id === id);
      const base: Course = existing
        ? toSummary(existing)
        : {
            id,
            slug: id,
            title: "Untitled",
            price: 0,
            currency: "USD",
            rating: 0,
            ratingCount: 0,
            instructor: { id: "ins_demo", fullName: "Demo Instructor" },
            status: "draft"
          };
      const updated: Course = { ...base, ...input };
      return delay(updated);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: courseKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: courseKeys.all });
    }
  });
}
'@
Write-Utf8NoBom -Path "packages\api-client\src\hooks\useCourses.ts" -Content $useCourses

# ---------------------------------------------------------------------------
# 4. packages/api-client/src/index.ts (export dummy-data too)
# ---------------------------------------------------------------------------
$apiClientIndex = @'
export * from "./http-client";
export * from "./query-keys";
export * from "./types";
export * from "./dummy-data";
export * from "./hooks/useAuth";
export * from "./hooks/useCourses";
'@
Write-Utf8NoBom -Path "packages\api-client\src\index.ts" -Content $apiClientIndex

# ---------------------------------------------------------------------------
# 5. apps/web/app/(marketing)/courses/[slug]/page.tsx (was corrupted, rebuilt)
# ---------------------------------------------------------------------------
$courseDetailPage = @'
"use client";

import { useState } from "react";
import Link from "next/link";
import { Star, Clock, PlayCircle, CheckCircle2, Globe, BarChart3 } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import {
  Button,
  Card,
  Badge,
  Accordion,
  ReviewCard,
  CourseCard,
  SkeletonText,
  EmptyState
} from "@saachi/ui";
import { formatDuration } from "@saachi/utils";
import { Navbar } from "../../_components/Navbar";
import { Footer } from "../../_components/Footer";

export default function CourseDetailPage({ params }: { params: { slug: string } }) {
  const { data: course, isLoading, isError } = useCourseDetail(params.slug);
  const [enrolled, setEnrolled] = useState(false);

  if (isLoading) {
    return (
      <>
        <Navbar />
        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <SkeletonText lines={4} />
        </main>
        <Footer />
      </>
    );
  }

  if (isError || !course) {
    return (
      <>
        <Navbar />
        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <EmptyState
            title="Course not found"
            description="This course may have been moved or is no longer available."
            action={
              <Link href="/courses">
                <Button>Browse courses</Button>
              </Link>
            }
          />
        </main>
        <Footer />
      </>
    );
  }

  const formattedPrice = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: course.currency,
    minimumFractionDigits: course.price % 1 === 0 ? 0 : 2
  }).format(course.price);

  const curriculumItems = (course.curriculum ?? []).map((mod) => ({
    id: mod.id,
    title: mod.title,
    meta: <span className="text-[12px] text-ink-soft/60">{mod.lessons.length} lessons</span>,
    content: (
      <ul className="flex flex-col gap-2">
        {mod.lessons.map((lesson) => (
          <li key={lesson.id} className="flex items-center justify-between text-[14px] text-ink">
            <span className="flex items-center gap-2">
              <PlayCircle size={15} className="text-ink-soft" />
              {lesson.title}
              {lesson.isPreview && <Badge variant="gold">Preview</Badge>}
            </span>
            {lesson.durationSeconds && (
              <span className="text-[12px] text-ink-soft/60">{formatDuration(lesson.durationSeconds)}</span>
            )}
          </li>
        ))}
      </ul>
    )
  }));

  const faqItems = (course.faq ?? []).map((item) => ({
    id: item.id,
    title: item.question,
    content: item.answer
  }));

  return (
    <>
      <Navbar />
      <main className="mx-auto max-w-[1140px] px-6 py-12">
        <div className="grid grid-cols-1 gap-10 lg:grid-cols-[1fr_360px]">
          <div>
            <div className="mb-3 flex flex-wrap items-center gap-2">
              <Badge variant="gold">{course.status === "published" ? "Published" : course.status}</Badge>
              <span className="flex items-center gap-1 text-[13px] text-ink-soft">
                <Star size={14} className="fill-gold text-gold" />
                <strong className="text-ink">{course.rating.toFixed(1)}</strong>
                ({course.ratingCount.toLocaleString()} ratings)
              </span>
            </div>

            <h1 className="font-display text-[32px] font-semibold leading-tight text-ink md:text-[40px]">
              {course.title}
            </h1>
            {course.subtitle && (
              <p className="mt-3 text-[16px] leading-relaxed text-ink-soft">{course.subtitle}</p>
            )}

            <div className="mt-6 flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-teal-light text-[14px] font-semibold text-teal">
                {course.instructor.fullName.charAt(0)}
              </div>
              <div>
                <div className="text-[14px] font-semibold text-ink">{course.instructor.fullName}</div>
                <div className="text-[12px] text-ink-soft">
                  {course.instructorCourseCount ?? 1} courses &middot;{" "}
                  {(course.instructorStudentCount ?? 0).toLocaleString()} students
                </div>
              </div>
            </div>

            {course.description && (
              <div className="mt-8">
                <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">About this course</h2>
                <p className="whitespace-pre-line text-[15px] leading-relaxed text-ink-soft">
                  {course.description}
                </p>
              </div>
            )}

            {curriculumItems.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">Curriculum</h2>
                <Accordion items={curriculumItems} defaultOpenId={curriculumItems[0]?.id} />
              </div>
            )}

            {course.reviews && course.reviews.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Reviews</h2>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  {course.reviews.map((review) => (
                    <ReviewCard key={review.id} {...review} />
                  ))}
                </div>
              </div>
            )}

            {faqItems.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">FAQ</h2>
                <Accordion items={faqItems} />
              </div>
            )}

            {course.relatedCourses && course.relatedCourses.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Related courses</h2>
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                  {course.relatedCourses.map((related) => (
                    <CourseCard
                      key={related.id}
                      slug={related.slug}
                      title={related.title}
                      thumbnailUrl={related.thumbnailUrl}
                      instructorName={related.instructor.fullName}
                      price={related.price}
                      currency={related.currency}
                      rating={related.rating}
                      ratingCount={related.ratingCount}
                    />
                  ))}
                </div>
              </div>
            )}
          </div>

          <div className="lg:sticky lg:top-24 lg:self-start">
            <Card className="p-6">
              <div className="mb-4 aspect-video w-full overflow-hidden rounded-control bg-paper-dim">
                {course.thumbnailUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.thumbnailUrl} alt={course.title} className="h-full w-full object-cover" />
                ) : (
                  <div className="flex h-full w-full items-center justify-center text-[13px] text-ink-soft/60">
                    No preview
                  </div>
                )}
              </div>

              <div className="mb-5 font-mono text-[28px] font-semibold text-ink">{formattedPrice}</div>

              {enrolled ? (
                <div className="flex items-center gap-2 rounded-control bg-teal-light px-4 py-3 text-[14px] font-semibold text-teal">
                  <CheckCircle2 size={18} /> Enrolled
                </div>
              ) : (
                <Button size="lg" className="w-full" onClick={() => setEnrolled(true)}>
                  Enroll now
                </Button>
              )}

              {enrolled && (
                <Link href="/dashboard" className="mt-3 block">
                  <Button size="lg" variant="secondary" className="w-full">
                    Go to dashboard
                  </Button>
                </Link>
              )}

              <ul className="mt-6 flex flex-col gap-3 text-[13px] text-ink-soft">
                <li className="flex items-center gap-2">
                  <Globe size={15} /> Language: English
                </li>
                <li className="flex items-center gap-2">
                  <BarChart3 size={15} /> Level: All levels
                </li>
                <li className="flex items-center gap-2">
                  <Clock size={15} /> Lifetime access
                </li>
              </ul>
            </Card>
          </div>
        </div>
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\courses\[slug]\page.tsx" -Content $courseDetailPage

# ---------------------------------------------------------------------------
# 6. apps/web/app/(marketing)/courses/page.tsx (add missing Navbar/Footer)
# ---------------------------------------------------------------------------
$courseListPage = @'
"use client";

import { useMemo, useState } from "react";
import { Search } from "lucide-react";
import { useCourseList } from "@saachi/api-client";
import { Input, Select, EmptyState, SkeletonCard, CourseCard, FilterSidebar } from "@saachi/ui";
import type { FilterSidebarValue } from "@saachi/ui";
import { Navbar } from "../_components/Navbar";
import { Footer } from "../_components/Footer";

const CATEGORY_OPTIONS = [
  { label: "AI Fundamentals & Prompt Engineering", value: "ai-fundamentals" },
  { label: "AI for Marketing & Sales", value: "ai-marketing" },
  { label: "AI Automation & Workflow Tools", value: "ai-automation" },
  { label: "AI Customer Support & Communication", value: "ai-support" },
  { label: "AI Website & App Development", value: "ai-dev" },
  { label: "AI Integration for Developers", value: "ai-integration" }
];

const LEVEL_OPTIONS = [
  { label: "Beginner", value: "beginner" },
  { label: "Intermediate", value: "intermediate" },
  { label: "Advanced", value: "advanced" }
];

const LANGUAGE_OPTIONS = [
  { label: "English", value: "en" },
  { label: "Urdu", value: "ur" }
];

const SORT_OPTIONS = [
  { label: "Most popular", value: "popular" },
  { label: "Newest", value: "newest" },
  { label: "Price: Low to High", value: "price_asc" },
  { label: "Price: High to Low", value: "price_desc" },
  { label: "Highest rated", value: "rating" }
];

export default function CourseMarketplacePage() {
  const [search, setSearch] = useState("");
  const [sort, setSort] = useState("popular");
  const [filters, setFilters] = useState<FilterSidebarValue>({
    categories: [],
    level: undefined,
    language: undefined
  });

  const queryFilters = useMemo(
    () => ({
      search: search || undefined,
      category: filters.categories[0],
      level: filters.level,
      language: filters.language,
      sort
    }),
    [search, filters, sort]
  );

  const { data, isLoading, isError } = useCourseList(queryFilters);

  const courses = data?.items ?? [];

  return (
    <>
      <Navbar />
      <main className="mx-auto max-w-[1140px] px-6 py-16">
        <div className="mb-10">
          <h1 className="font-display text-[32px] font-semibold text-ink">Explore courses</h1>
          <p className="mt-2 text-[15px] text-ink-soft">
            Practical AI skills, taught by practitioners who use them every day.
          </p>
        </div>

        <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center">
          <div className="relative flex-1">
            <Search
              size={18}
              className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-ink-soft/60"
            />
            <Input
              placeholder="Search courses, e.g. 'n8n automation'"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-10"
            />
          </div>
          <div className="sm:w-[240px]">
            <Select options={SORT_OPTIONS} value={sort} onChange={(e) => setSort(e.target.value)} />
          </div>
        </div>

        <div className="grid grid-cols-1 gap-8 lg:grid-cols-[260px_1fr]">
          <FilterSidebar
            categoryOptions={CATEGORY_OPTIONS}
            levelOptions={LEVEL_OPTIONS}
            languageOptions={LANGUAGE_OPTIONS}
            value={filters}
            onChange={setFilters}
          />

          <section>
            {isLoading && (
              <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
                {Array.from({ length: 6 }).map((_, i) => (
                  <SkeletonCard key={i} />
                ))}
              </div>
            )}

            {isError && (
              <EmptyState
                title="Couldn't load courses"
                description="Something went wrong while fetching the course list. Please try again."
              />
            )}

            {!isLoading && !isError && courses.length === 0 && (
              <EmptyState
                title="No courses found"
                description="Try adjusting your filters or search terms."
              />
            )}

            {!isLoading && !isError && courses.length > 0 && (
              <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
                {courses.map((course) => (
                  <CourseCard
                    key={course.id}
                    slug={course.slug}
                    title={course.title}
                    thumbnailUrl={course.thumbnailUrl}
                    instructorName={course.instructor.fullName}
                    price={course.price}
                    currency={course.currency}
                    rating={course.rating}
                    ratingCount={course.ratingCount}
                  />
                ))}
              </div>
            )}
          </section>
        </div>
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\courses\page.tsx" -Content $courseListPage

# ---------------------------------------------------------------------------
# 7. apps/web/app/(learner)/dashboard/page.tsx (login redirect target, was missing)
# ---------------------------------------------------------------------------
$dashboardPage = @'
"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useSession, useLogout, useCourseList } from "@saachi/api-client";
import { Button, Card, CourseCard, SkeletonCard } from "@saachi/ui";

export default function LearnerDashboardPage() {
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const { data, isLoading } = useCourseList({ sort: "popular" });

  const courses = data?.items ?? [];

  const handleLogout = async () => {
    await logout.mutateAsync();
    router.push("/");
  };

  return (
    <main className="mx-auto max-w-[1140px] px-6 py-12">
      <div className="mb-10 flex items-center justify-between">
        <div>
          <h1 className="font-display text-[28px] font-semibold text-ink">
            Welcome back{session?.fullName ? `, ${session.fullName.split(" ")[0]}` : ""}
          </h1>
          <p className="mt-1 text-[14px] text-ink-soft">
            Pick up where you left off, or explore something new.
          </p>
        </div>
        <Button variant="secondary" onClick={handleLogout} disabled={logout.isPending}>
          {logout.isPending ? "Logging out..." : "Log out"}
        </Button>
      </div>

      <Card className="mb-10 flex flex-col items-start gap-4 p-6 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-[16px] font-semibold text-ink">This is demo data</h2>
          <p className="mt-1 text-[14px] text-ink-soft">
            You are signed in with a local demo session - no backend or real account required yet.
          </p>
        </div>
        <Link href="/courses">
          <Button>Browse courses</Button>
        </Link>
      </Card>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Recommended for you</h2>
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
        {isLoading
          ? Array.from({ length: 3 }).map((_, i) => <SkeletonCard key={i} />)
          : courses.slice(0, 6).map((course) => (
              <CourseCard
                key={course.id}
                slug={course.slug}
                title={course.title}
                thumbnailUrl={course.thumbnailUrl}
                instructorName={course.instructor.fullName}
                price={course.price}
                currency={course.currency}
                rating={course.rating}
                ratingCount={course.ratingCount}
              />
            ))}
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\dashboard\page.tsx" -Content $dashboardPage

# ---------------------------------------------------------------------------
# 8. apps/web/.env.local (placeholder, not used by mocked hooks, but present for later)
# ---------------------------------------------------------------------------
$envLocal = @'
NEXT_PUBLIC_API_URL=http://localhost:4000
'@
Write-Utf8NoBom -Path "apps\web\.env.local" -Content $envLocal

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Green
Write-Host "  pnpm install"
Write-Host "  pnpm dev:web"
Write-Host "  Open http://localhost:3000/register or /login - any email/password works."
