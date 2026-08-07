# step1-images-nav-learner-shell.ps1
# Run from: SAI2 root folder

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

function Patch-File {
    param([string]$Path, [string]$OldStr, [string]$NewStr, [string]$Label)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP (file not found): $fullPath" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Path $fullPath -Raw
    if ($content.Contains($OldStr)) {
        $updated = $content.Replace($OldStr, $NewStr)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($fullPath, $updated, $enc)
        Write-Host "  patched ($Label): $fullPath"
    } else {
        Write-Host "  WARNING: pattern for '$Label' not found in $fullPath - skipped, no changes made to this file." -ForegroundColor Yellow
    }
}

Write-Host "Step 1: images + session-aware nav + learner portal shell..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. dummy-data.ts - add real images (course thumbnails, avatars)
# ---------------------------------------------------------------------------
$dummyData = @'
import type { Course, CourseDetail, Session } from "./types";

function img(seed: string, w: number, h: number): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/${w}/${h}`;
}

export const DUMMY_SESSION: Session = {
  id: "usr_demo_001",
  fullName: "Ayesha Khan",
  email: "demo@saachi.ai",
  role: "learner",
  avatarUrl: img("ayesha-khan-demo", 150, 150)
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
    thumbnailUrl: img("prompt-engineering-fundamentals", 800, 450),
    instructor: { id: "ins_001", fullName: "Sana Rizvi", avatarUrl: img("sana-rizvi", 150, 150) },
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
        authorAvatarUrl: img("bilal-ahmed", 100, 100),
        rating: 5,
        comment: "Clear, practical, and I actually use the prompt library every week now.",
        createdAt: "2026-06-12T10:00:00.000Z",
        verifiedPurchase: true
      },
      {
        id: "rev_2",
        authorName: "Hina Malik",
        authorAvatarUrl: img("hina-malik", 100, 100),
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
    thumbnailUrl: img("ai-powered-marketing-campaigns", 800, 450),
    instructor: { id: "ins_002", fullName: "Zara Farooq", avatarUrl: img("zara-farooq", 150, 150) },
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
        authorAvatarUrl: img("omar-sheikh", 100, 100),
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
    thumbnailUrl: img("automate-everything-with-n8n-and-ai", 800, 450),
    instructor: { id: "ins_003", fullName: "Ayesha Khan", avatarUrl: img("ayesha-khan-instructor", 150, 150) },
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
        authorAvatarUrl: img("fatima-noor", 100, 100),
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
    thumbnailUrl: img("build-a-whatsapp-ai-auto-responder", 800, 450),
    instructor: { id: "ins_004", fullName: "Bilal Ahmed", avatarUrl: img("bilal-ahmed-instructor", 150, 150) },
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
        authorAvatarUrl: img("sara-iqbal", 100, 100),
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
    thumbnailUrl: img("ship-your-first-ai-powered-web-app", 800, 450),
    instructor: { id: "ins_005", fullName: "Hamza Tariq", avatarUrl: img("hamza-tariq", 150, 150) },
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
        authorAvatarUrl: img("noor-fatima", 100, 100),
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
    thumbnailUrl: img("integrating-openai-and-claude-apis-into-node", 800, 450),
    instructor: { id: "ins_006", fullName: "Usman Ali", avatarUrl: img("usman-ali", 150, 150) },
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
        authorAvatarUrl: img("danish-raza", 100, 100),
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
# 2. Navbar.tsx - session-aware (Dashboard/Cart/Logout when logged in)
# ---------------------------------------------------------------------------
$navbar = @'
"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { Menu, X, ShoppingCart } from "lucide-react";
import { Button } from "@saachi/ui";
import { useSession, useLogout } from "@saachi/api-client";

const NAV_LINKS = [
  { label: "Explore Courses", href: "/courses" },
  { label: "Become an Instructor", href: "/register" },
  { label: "Pricing", href: "/pricing" },
  { label: "About", href: "/about" }
];

export function Navbar() {
  const router = useRouter();
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const { data: session } = useSession();
  const logout = useLogout();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const handleLogout = async () => {
    await logout.mutateAsync();
    setMobileOpen(false);
    router.push("/");
  };

  return (
    <header
      className={[
        "sticky top-0 z-50 w-full border-b transition-colors duration-200 ease-out",
        scrolled ? "border-line bg-paper/95 backdrop-blur-sm" : "border-transparent bg-paper"
      ].join(" ")}
    >
      <div className="mx-auto flex h-[72px] max-w-[1140px] items-center justify-between px-6">
        <Link href="/" className="flex items-center gap-2.5">
          <span className="flex h-9 w-9 items-center justify-center rounded-full border-2 border-ink bg-gold font-display text-[15px] font-bold text-ink">
            S
          </span>
          <span className="font-display text-[18px] font-semibold tracking-[-0.01em] text-ink">
            Saachi AI
          </span>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-[14px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="hidden items-center gap-3 md:flex">
          {session ? (
            <>
              <Link
                href="/cart"
                aria-label="Cart"
                className="flex h-10 w-10 items-center justify-center rounded-full text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
              >
                <ShoppingCart size={19} />
              </Link>
              <Link
                href="/dashboard"
                className="flex items-center gap-2 rounded-full border border-line-strong bg-card py-1.5 pl-1.5 pr-4 transition-colors duration-150 ease-out hover:border-ink"
              >
                <span className="flex h-7 w-7 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[12px] font-semibold text-teal">
                  {session.avatarUrl ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={session.avatarUrl} alt={session.fullName} className="h-full w-full object-cover" />
                  ) : (
                    session.fullName.charAt(0)
                  )}
                </span>
                <span className="text-[13px] font-semibold text-ink">{session.fullName.split(" ")[0]}</span>
              </Link>
              <Button variant="ghost" size="sm" onClick={handleLogout} disabled={logout.isPending}>
                {logout.isPending ? "..." : "Log out"}
              </Button>
            </>
          ) : (
            <>
              <Link href="/login">
                <Button variant="ghost" size="sm">
                  Log in
                </Button>
              </Link>
              <Link href="/register">
                <Button variant="primary" size="sm">
                  Get Started
                </Button>
              </Link>
            </>
          )}
        </div>

        <button
          type="button"
          onClick={() => setMobileOpen((v) => !v)}
          className="flex h-10 w-10 items-center justify-center rounded-control text-ink md:hidden"
          aria-label="Toggle menu"
        >
          {mobileOpen ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {mobileOpen && (
        <div className="border-t border-line bg-paper px-6 py-6 md:hidden">
          <nav className="flex flex-col gap-4">
            {NAV_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={() => setMobileOpen(false)}
                className="text-[15px] font-medium text-ink"
              >
                {link.label}
              </Link>
            ))}
          </nav>
          <div className="mt-6 flex flex-col gap-3">
            {session ? (
              <>
                <Link href="/dashboard" onClick={() => setMobileOpen(false)}>
                  <Button variant="secondary" size="md" className="w-full">
                    Dashboard
                  </Button>
                </Link>
                <Link href="/cart" onClick={() => setMobileOpen(false)}>
                  <Button variant="secondary" size="md" className="w-full">
                    Cart
                  </Button>
                </Link>
                <Button
                  variant="ghost"
                  size="md"
                  className="w-full"
                  onClick={handleLogout}
                  disabled={logout.isPending}
                >
                  {logout.isPending ? "Logging out..." : "Log out"}
                </Button>
              </>
            ) : (
              <>
                <Link href="/login" onClick={() => setMobileOpen(false)}>
                  <Button variant="secondary" size="md" className="w-full">
                    Log in
                  </Button>
                </Link>
                <Link href="/register" onClick={() => setMobileOpen(false)}>
                  <Button variant="primary" size="md" className="w-full">
                    Get Started
                  </Button>
                </Link>
              </>
            )}
          </div>
        </div>
      )}
    </header>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\_components\Navbar.tsx" -Content $navbar

# ---------------------------------------------------------------------------
# 3. Learner portal shell (sidebar nav for dashboard/my-courses/cart/etc.)
# ---------------------------------------------------------------------------
$learnerShell = @'
"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState, type ReactNode } from "react";
import {
  LayoutDashboard,
  BookOpen,
  Heart,
  ShoppingCart,
  Award,
  Bell,
  Settings,
  LogOut,
  Menu,
  X
} from "lucide-react";
import { useSession, useLogout } from "@saachi/api-client";
import { cn } from "@saachi/ui";

const NAV_ITEMS = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { label: "My Courses", href: "/my-courses", icon: BookOpen },
  { label: "Wishlist", href: "/wishlist", icon: Heart },
  { label: "Cart", href: "/cart", icon: ShoppingCart },
  { label: "Certificates", href: "/certificates", icon: Award },
  { label: "Notifications", href: "/notifications", icon: Bell },
  { label: "Settings", href: "/settings/profile", icon: Settings }
];

export function LearnerShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const [mobileOpen, setMobileOpen] = useState(false);

  const handleLogout = async () => {
    await logout.mutateAsync();
    router.push("/");
  };

  const sidebarContent = (
    <div className="flex h-full flex-col">
      <Link href="/" className="flex items-center gap-2.5 px-6 py-6">
        <span className="flex h-9 w-9 items-center justify-center rounded-full border-2 border-ink bg-gold font-display text-[15px] font-bold text-ink">
          S
        </span>
        <span className="font-display text-[17px] font-semibold text-ink">Saachi AI</span>
      </Link>

      <nav className="flex flex-1 flex-col gap-1 px-3">
        {NAV_ITEMS.map((item) => {
          const active = pathname === item.href || Boolean(pathname && pathname.startsWith(`${item.href}/`));
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setMobileOpen(false)}
              className={cn(
                "flex items-center gap-3 rounded-control px-3.5 py-2.5 text-[14px] font-medium transition-colors duration-150 ease-out",
                active ? "bg-gold-tint text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
              )}
            >
              <item.icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-line px-3 py-4">
        <div className="mb-3 flex items-center gap-3 px-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[13px] font-semibold text-teal">
            {session?.avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={session.avatarUrl} alt={session.fullName} className="h-full w-full object-cover" />
            ) : (
              session?.fullName?.charAt(0) ?? "?"
            )}
          </div>
          <div className="min-w-0">
            <div className="truncate text-[13px] font-semibold text-ink">{session?.fullName ?? "Guest"}</div>
            <div className="truncate text-[12px] text-ink-soft">{session?.email ?? ""}</div>
          </div>
        </div>
        <button
          type="button"
          onClick={handleLogout}
          disabled={logout.isPending}
          className="flex w-full items-center gap-3 rounded-control px-3.5 py-2.5 text-[14px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-error"
        >
          <LogOut size={18} />
          {logout.isPending ? "Logging out..." : "Log out"}
        </button>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-paper">
      <div className="hidden w-[260px] shrink-0 border-r border-line bg-card md:fixed md:inset-y-0 md:flex">
        {sidebarContent}
      </div>

      <div className="flex items-center justify-between border-b border-line bg-card px-4 py-3 md:hidden">
        <Link href="/" className="flex items-center gap-2">
          <span className="flex h-8 w-8 items-center justify-center rounded-full border-2 border-ink bg-gold font-display text-[13px] font-bold text-ink">
            S
          </span>
          <span className="font-display text-[15px] font-semibold text-ink">Saachi AI</span>
        </Link>
        <button
          type="button"
          onClick={() => setMobileOpen(true)}
          aria-label="Open menu"
          className="flex h-9 w-9 items-center justify-center rounded-control text-ink"
        >
          <Menu size={20} />
        </button>
      </div>

      {mobileOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div className="absolute inset-0 bg-ink/40" onClick={() => setMobileOpen(false)} />
          <div className="relative flex h-full w-[280px] flex-col bg-card">
            <button
              type="button"
              onClick={() => setMobileOpen(false)}
              aria-label="Close menu"
              className="absolute right-3 top-3 flex h-9 w-9 items-center justify-center rounded-control text-ink"
            >
              <X size={20} />
            </button>
            {sidebarContent}
          </div>
        </div>
      )}

      <div className="md:pl-[260px]">{children}</div>
    </div>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\_components\LearnerShell.tsx" -Content $learnerShell

$learnerLayout = @'
import type { ReactNode } from "react";
import { LearnerShell } from "./_components/LearnerShell";

export default function LearnerLayout({ children }: { children: ReactNode }) {
  return <LearnerShell>{children}</LearnerShell>;
}
'@
Write-Utf8NoBom -Path "apps\web\app\(learner)\layout.tsx" -Content $learnerLayout

# ---------------------------------------------------------------------------
# 4. Dashboard page - simplified (logout now lives in the sidebar)
# ---------------------------------------------------------------------------
$dashboardPage = @'
"use client";

import Link from "next/link";
import { useSession, useCourseList } from "@saachi/api-client";
import { Button, Card, CourseCard, SkeletonCard } from "@saachi/ui";

export default function LearnerDashboardPage() {
  const { data: session } = useSession();
  const { data, isLoading } = useCourseList({ sort: "popular" });

  const courses = data?.items ?? [];

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-10">
        <h1 className="font-display text-[28px] font-semibold text-ink">
          Welcome back{session?.fullName ? `, ${session.fullName.split(" ")[0]}` : ""}
        </h1>
        <p className="mt-1 text-[14px] text-ink-soft">
          Pick up where you left off, or explore something new.
        </p>
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
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
        {isLoading
          ? Array.from({ length: 4 }).map((_, i) => <SkeletonCard key={i} />)
          : courses.slice(0, 4).map((course) => (
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
# 5. Homepage testimonials - real avatar photos instead of initials
#    (targeted patch - only touches this one block, rest of homepage untouched)
# ---------------------------------------------------------------------------
$oldAvatarBlock = @'
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-teal-light text-[14px] font-semibold text-teal">
                    {t.name.charAt(0)}
                  </div>
'@

$newAvatarBlock = @'
                  <div className="flex h-10 w-10 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[14px] font-semibold text-teal">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={`https://picsum.photos/seed/${encodeURIComponent(t.name)}/100/100`}
                      alt={t.name}
                      className="h-full w-full object-cover"
                    />
                  </div>
'@

Patch-File -Path "apps\web\app\(marketing)\page.tsx" -OldStr $oldAvatarBlock -NewStr $newAvatarBlock -Label "testimonial avatars"

Write-Host ""
Write-Host "Step 1 done. Run: pnpm dev:web" -ForegroundColor Green
Write-Host "Check: homepage testimonials, /courses grid, course detail page, and log in to see the sidebar under /dashboard." -ForegroundColor Green