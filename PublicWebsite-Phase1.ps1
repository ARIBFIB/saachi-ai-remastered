<#
  Build-PublicWebsite-Phase1.ps1
  ---------------------------------------------------------------------------
  Scaffolds Phase 1 of the SAI2 Public Website (apps/web) using the ALREADY
  EXISTING packages: @saachi/ui, @saachi/api-client, @saachi/store, @saachi/utils.

  Does NOT touch apps/admin.

  Pages created:
    /                        Homepage
    /courses                 Marketplace listing (search/filter/sort)
    /courses/[slug]          Course detail
    /categories/[slug]       Category page
    /login                   Login
    /register                Register

  Run from the SAI2 repo root:
    powershell -ExecutionPolicy Bypass -File .\Build-PublicWebsite-Phase1.ps1
#>

$ErrorActionPreference = "Stop"
$Root = (Get-Location).Path

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$Content
    )
    $fullPath = Join-Path $Root $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    [System.IO.File]::WriteAllText($fullPath, $Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  wrote $RelativePath"
}

Write-Host "== SAI2 :: Public Website Phase 1 scaffold ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Shared site chrome — Header / Footer (apps/web/app/_components)
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/_components/SiteHeader.tsx" @'
"use client";

import Link from "next/link";
import { useState } from "react";
import { ShoppingCart, Heart, Menu, X, LogOut } from "lucide-react";
import { Button, ThemeToggle } from "@saachi/ui";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { useSession, useLogout } from "@saachi/api-client";

const NAV_LINKS = [
  { href: "/courses", label: "Courses" },
  { href: "/categories/ai-automation", label: "Automation" },
  { href: "/categories/ai-marketing", label: "Marketing" },
  { href: "/about", label: "About" }
];

export function SiteHeader() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const cartCount = useCartStore((s) => s.items.length);
  const wishlistCount = useWishlistStore((s) => s.items.length);
  const { data: session } = useSession();
  const logout = useLogout();

  return (
    <header className="sticky top-0 z-40 border-b border-line bg-card/90 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 md:px-8">
        <Link href="/" className="font-display text-[20px] font-bold text-ink">
          Saachi<span className="text-gold-dark">AI</span>
        </Link>

        <nav className="hidden items-center gap-6 md:flex">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-[14px] font-medium text-ink-soft transition-colors hover:text-ink"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <ThemeToggle />

          <Link
            href="/wishlist"
            aria-label="Wishlist"
            className="relative flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
          >
            <Heart size={18} />
            {wishlistCount > 0 && (
              <span className="absolute -right-0.5 -top-0.5 flex h-4 w-4 items-center justify-center rounded-full bg-gold text-[10px] font-bold text-ink">
                {wishlistCount}
              </span>
            )}
          </Link>

          <Link
            href="/cart"
            aria-label="Cart"
            className="relative flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
          >
            <ShoppingCart size={18} />
            {cartCount > 0 && (
              <span className="absolute -right-0.5 -top-0.5 flex h-4 w-4 items-center justify-center rounded-full bg-gold text-[10px] font-bold text-ink">
                {cartCount}
              </span>
            )}
          </Link>

          {session ? (
            <div className="hidden items-center gap-2 md:flex">
              <span className="text-[13px] text-ink-soft">{session.fullName}</span>
              <Button
                size="sm"
                variant="ghost"
                onClick={() => logout.mutate()}
                aria-label="Log out"
              >
                <LogOut size={14} />
              </Button>
            </div>
          ) : (
            <div className="hidden items-center gap-2 md:flex">
              <Link href="/login">
                <Button size="sm" variant="secondary">
                  Log in
                </Button>
              </Link>
              <Link href="/register">
                <Button size="sm">Sign up</Button>
              </Link>
            </div>
          )}

          <button
            type="button"
            className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft md:hidden"
            onClick={() => setMobileOpen((v) => !v)}
            aria-label="Toggle menu"
          >
            {mobileOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>
      </div>

      {mobileOpen && (
        <div className="border-t border-line bg-card px-4 py-4 md:hidden">
          <nav className="flex flex-col gap-3">
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
            <div className="mt-2 flex gap-2">
              {session ? (
                <Button size="sm" variant="secondary" onClick={() => logout.mutate()} className="w-full">
                  Log out
                </Button>
              ) : (
                <>
                  <Link href="/login" className="flex-1">
                    <Button size="sm" variant="secondary" className="w-full">
                      Log in
                    </Button>
                  </Link>
                  <Link href="/register" className="flex-1">
                    <Button size="sm" className="w-full">
                      Sign up
                    </Button>
                  </Link>
                </>
              )}
            </div>
          </nav>
        </div>
      )}
    </header>
  );
}
'@

Write-Utf8NoBom "apps/web/app/_components/SiteFooter.tsx" @'
import Link from "next/link";

const FOOTER_COLUMNS = [
  {
    title: "Platform",
    links: [
      { href: "/courses", label: "Browse courses" },
      { href: "/pricing", label: "Pricing" },
      { href: "/register", label: "Become an instructor" }
    ]
  },
  {
    title: "Company",
    links: [
      { href: "/about", label: "About us" },
      { href: "/contact", label: "Contact" }
    ]
  },
  {
    title: "Legal",
    links: [
      { href: "/legal/terms", label: "Terms & Conditions" },
      { href: "/legal/privacy", label: "Privacy Policy" },
      { href: "/legal/refund-policy", label: "Refund Policy" }
    ]
  }
];

export function SiteFooter() {
  return (
    <footer className="mt-24 border-t border-line bg-card">
      <div className="mx-auto grid max-w-7xl gap-10 px-4 py-14 md:grid-cols-4 md:px-8">
        <div>
          <span className="font-display text-[20px] font-bold text-ink">
            Saachi<span className="text-gold-dark">AI</span>
          </span>
          <p className="mt-3 max-w-[240px] text-[13px] leading-relaxed text-ink-soft">
            A skills exchange for the AI era. Learn practical AI skills, and sell what you know.
          </p>
        </div>

        {FOOTER_COLUMNS.map((col) => (
          <div key={col.title}>
            <h4 className="mb-3 text-[13px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
              {col.title}
            </h4>
            <ul className="flex flex-col gap-2">
              {col.links.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-[13px] text-ink-soft hover:text-ink">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      <div className="border-t border-line px-4 py-5 text-center text-[12px] text-ink-soft/60 md:px-8">
        (c) {new Date().getFullYear()} Saachi AI. All rights reserved.
      </div>
    </footer>
  );
}
'@

# ---------------------------------------------------------------------------
# 2. Category taxonomy shared constant (used by home + marketplace + category)
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/lib/categories.ts" @'
export type CategoryDef = {
  id: string;
  name: string;
  slug: string;
};

export const CATEGORIES: CategoryDef[] = [
  { id: "ai-fundamentals", name: "AI Fundamentals & Prompt Engineering", slug: "ai-fundamentals" },
  { id: "ai-marketing", name: "AI for Marketing & Sales", slug: "ai-marketing" },
  { id: "ai-automation", name: "AI Automation & Workflow Tools", slug: "ai-automation" },
  { id: "ai-support", name: "AI Customer Support & Communication", slug: "ai-support" },
  { id: "ai-dev", name: "AI Website & App Development", slug: "ai-dev" },
  { id: "ai-integration", name: "AI Integration for Developers", slug: "ai-integration" },
  { id: "ai-design", name: "AI Design & Creative Tools", slug: "ai-design" },
  { id: "ai-career", name: "AI for Careers & Job Search", slug: "ai-career" }
];

export function getCategoryBySlug(slug: string): CategoryDef | undefined {
  return CATEGORIES.find((c) => c.slug === slug);
}
'@

# ---------------------------------------------------------------------------
# 3. Root layout + providers (only created if missing — will NOT overwrite)
# ---------------------------------------------------------------------------

$layoutPath = Join-Path $Root "apps/web/app/layout.tsx"
if (-not (Test-Path $layoutPath)) {
    Write-Utf8NoBom "apps/web/app/layout.tsx" @'
import type { Metadata } from "next";
import type { ReactNode } from "react";
import "./globals.css";
import { Providers } from "./providers";
import { SiteHeader } from "./_components/SiteHeader";
import { SiteFooter } from "./_components/SiteFooter";

export const metadata: Metadata = {
  title: "Saachi AI — Learn practical AI skills",
  description: "A skills exchange for the AI era. Learn practical AI application skills and sell what you know."
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-paper text-ink antialiased">
        <Providers>
          <SiteHeader />
          <main>{children}</main>
          <SiteFooter />
        </Providers>
      </body>
    </html>
  );
}
'@
} else {
    Write-Host "  skipped apps/web/app/layout.tsx (already exists)"
}

$providersPath = Join-Path $Root "apps/web/app/providers.tsx"
if (-not (Test-Path $providersPath)) {
    Write-Utf8NoBom "apps/web/app/providers.tsx" @'
"use client";

import { useState, type ReactNode } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

export function Providers({ children }: { children: ReactNode }) {
  const [client] = useState(() => new QueryClient({
    defaultOptions: { queries: { staleTime: 30_000, refetchOnWindowFocus: false } }
  }));

  return <QueryClientProvider client={client}>{children}</QueryClientProvider>;
}
'@
} else {
    Write-Host "  skipped apps/web/app/providers.tsx (already exists)"
}

$globalsPath = Join-Path $Root "apps/web/app/globals.css"
if (-not (Test-Path $globalsPath)) {
    Write-Utf8NoBom "apps/web/app/globals.css" @'
@tailwind base;
@tailwind components;
@tailwind utilities;
'@
} else {
    Write-Host "  skipped apps/web/app/globals.css (already exists)"
}

# ---------------------------------------------------------------------------
# 4. Homepage
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(marketing)/page.tsx" @'
"use client";

import Link from "next/link";
import { useCourseList } from "@saachi/api-client";
import { Button, CourseCard, Loading } from "@saachi/ui";
import { CATEGORIES } from "../../lib/categories";

export default function HomePage() {
  const { data: featured, isLoading } = useCourseList({ sort: "popular", page: 1 });

  return (
    <div>
      {/* Hero */}
      <section className="mx-auto max-w-7xl px-4 pb-14 pt-16 md:px-8 md:pt-24">
        <div className="max-w-2xl">
          <h1 className="font-display text-[38px] font-bold leading-[1.1] text-ink md:text-[52px]">
            Learn practical AI skills. Sell what you know.
          </h1>
          <p className="mt-5 text-[16px] leading-relaxed text-ink-soft md:text-[18px]">
            Not another watch-time platform. Saachi AI is a skills exchange for the AI era —
            structured, practical, and paid.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses">
              <Button size="lg">Browse courses</Button>
            </Link>
            <Link href="/register">
              <Button size="lg" variant="secondary">
                Become an instructor
              </Button>
            </Link>
          </div>
        </div>
      </section>

      {/* Category grid */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <h2 className="mb-5 font-display text-[22px] font-semibold text-ink">Browse by category</h2>
        <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
          {CATEGORIES.map((cat) => (
            <Link
              key={cat.id}
              href={`/categories/${cat.slug}`}
              className="rounded-card border border-line bg-card p-4 text-[14px] font-medium text-ink transition-colors hover:border-gold-dark/40"
            >
              {cat.name}
            </Link>
          ))}
        </div>
      </section>

      {/* Featured courses */}
      <section className="mx-auto max-w-7xl px-4 pb-20 md:px-8">
        <div className="mb-5 flex items-center justify-between">
          <h2 className="font-display text-[22px] font-semibold text-ink">Featured courses</h2>
          <Link href="/courses" className="text-[14px] font-medium text-gold-dark hover:underline">
            View all
          </Link>
        </div>

        {isLoading ? (
          <Loading label="Loading courses..." />
        ) : (
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {featured?.items.map((course) => (
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
  );
}
'@

# ---------------------------------------------------------------------------
# 5. Marketplace listing
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(marketing)/courses/page.tsx" @'
"use client";

import { useMemo, useState } from "react";
import { useCourseList, type CourseListFilters } from "@saachi/api-client";
import { CourseCard, EmptyState, FilterSidebar, Input, Select, Loading, type FilterSidebarValue } from "@saachi/ui";
import { CATEGORIES } from "../../../lib/categories";

const SORT_OPTIONS = [
  { label: "Most popular", value: "popular" },
  { label: "Newest", value: "newest" },
  { label: "Price: low to high", value: "price_asc" },
  { label: "Price: high to low", value: "price_desc" },
  { label: "Highest rated", value: "rating" }
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

export default function CoursesPage() {
  const [search, setSearch] = useState("");
  const [sort, setSort] = useState("popular");
  const [filters, setFilters] = useState<FilterSidebarValue>({ categories: [], level: undefined, language: undefined });

  const queryFilters: CourseListFilters = useMemo(
    () => ({
      search: search || undefined,
      category: filters.categories[0],
      level: filters.level,
      language: filters.language,
      sort
    }),
    [search, filters, sort]
  );

  const { data, isLoading } = useCourseList(queryFilters);

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      <h1 className="mb-6 font-display text-[28px] font-bold text-ink">Course Marketplace</h1>

      <div className="mb-6 flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <Input
          placeholder="Search courses or instructors..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="md:max-w-sm"
        />
        <Select
          options={SORT_OPTIONS}
          value={sort}
          onChange={(e) => setSort(e.target.value)}
          className="md:w-56"
        />
      </div>

      <div className="grid grid-cols-1 gap-8 md:grid-cols-[260px_1fr]">
        <FilterSidebar
          categoryOptions={CATEGORIES.map((c) => ({ label: c.name, value: c.id }))}
          levelOptions={LEVEL_OPTIONS}
          languageOptions={LANGUAGE_OPTIONS}
          value={filters}
          onChange={setFilters}
        />

        <div>
          {isLoading ? (
            <Loading label="Loading courses..." />
          ) : !data || data.items.length === 0 ? (
            <EmptyState title="No courses found" description="Try adjusting your filters or search term." />
          ) : (
            <>
              <p className="mb-4 text-[13px] text-ink-soft">{data.total} courses found</p>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
                {data.items.map((course) => (
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
            </>
          )}
        </div>
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 6. Course detail page
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(marketing)/courses/[slug]/page.tsx" @'
"use client";

import { useParams } from "next/navigation";
import { Star, PlayCircle, FileText, HelpCircle, Paperclip } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { Accordion, Badge, Button, CourseCard, Loading, ReviewCard } from "@saachi/ui";

const LESSON_ICON = {
  video: PlayCircle,
  text: FileText,
  quiz: HelpCircle,
  resource: Paperclip
} as const;

export default function CourseDetailPage() {
  const params = useParams<{ slug: string }>();
  const { data: course, isLoading } = useCourseDetail(params.slug);
  const addToCart = useCartStore((s) => s.addItem);
  const isInCart = useCartStore((s) => s.isInCart);
  const toggleWishlist = useWishlistStore((s) => s.toggle);
  const isWishlisted = useWishlistStore((s) => s.isWishlisted);

  if (isLoading || !course) {
    return <Loading fullScreen label="Loading course..." />;
  }

  const inCart = isInCart(course.id);
  const wishlisted = isWishlisted(course.id);

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      <div className="grid grid-cols-1 gap-10 lg:grid-cols-[1fr_360px]">
        <div>
          {/* Hero */}
          <Badge variant="gold">{course.status === "published" ? "Published course" : course.status}</Badge>
          <h1 className="mt-3 font-display text-[30px] font-bold leading-tight text-ink">{course.title}</h1>
          {course.subtitle && <p className="mt-2 text-[16px] text-ink-soft">{course.subtitle}</p>}

          <div className="mt-4 flex flex-wrap items-center gap-4 text-[14px] text-ink-soft">
            <span className="flex items-center gap-1.5">
              <Star size={15} className="fill-gold text-gold" />
              <span className="font-semibold text-ink">{course.rating.toFixed(1)}</span>
              <span>({course.ratingCount.toLocaleString()} ratings)</span>
            </span>
            <span>By {course.instructor.fullName}</span>
          </div>

          {course.thumbnailUrl && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={course.thumbnailUrl}
              alt={course.title}
              className="mt-6 aspect-video w-full rounded-card object-cover"
            />
          )}

          {course.description && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">About this course</h2>
              <p className="leading-relaxed text-ink-soft">{course.description}</p>
            </section>
          )}

          {course.curriculum && course.curriculum.length > 0 && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">Curriculum</h2>
              <Accordion
                items={course.curriculum.map((mod) => ({
                  id: mod.id,
                  title: mod.title,
                  meta: <span className="text-[12px] text-ink-soft">{mod.lessons.length} lessons</span>,
                  content: (
                    <ul className="flex flex-col gap-2">
                      {mod.lessons.map((lesson) => {
                        const Icon = LESSON_ICON[lesson.type];
                        return (
                          <li key={lesson.id} className="flex items-center gap-2 text-[14px] text-ink">
                            <Icon size={15} className="text-ink-soft" />
                            {lesson.title}
                            {lesson.isPreview && (
                              <span className="ml-1 text-[12px] font-semibold text-gold-dark">Preview</span>
                            )}
                          </li>
                        );
                      })}
                    </ul>
                  )
                }))}
              />
            </section>
          )}

          {course.instructorBio && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">About the instructor</h2>
              <div className="rounded-card border border-line bg-card p-5">
                <h3 className="font-semibold text-ink">{course.instructor.fullName}</h3>
                <p className="mt-2 text-[14px] text-ink-soft">{course.instructorBio}</p>
                <p className="mt-2 text-[13px] text-ink-soft/70">
                  {course.instructorCourseCount ?? 0} courses - {(course.instructorStudentCount ?? 0).toLocaleString()} students
                </p>
              </div>
            </section>
          )}

          {course.reviews && course.reviews.length > 0 && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">Reviews</h2>
              <div className="flex flex-col gap-4">
                {course.reviews.map((review) => (
                  <ReviewCard key={review.id} {...review} />
                ))}
              </div>
            </section>
          )}

          {course.faq && course.faq.length > 0 && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">FAQ</h2>
              <Accordion
                items={course.faq.map((item) => ({ id: item.id, title: item.question, content: item.answer }))}
              />
            </section>
          )}

          {course.relatedCourses && course.relatedCourses.length > 0 && (
            <section className="mt-10">
              <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Related courses</h2>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
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
            </section>
          )}
        </div>

        {/* Sticky purchase card */}
        <aside className="h-fit rounded-card border border-line bg-card p-6 lg:sticky lg:top-24">
          <div className="font-mono text-[28px] font-bold text-ink">
            {new Intl.NumberFormat("en-US", { style: "currency", currency: course.currency }).format(course.price)}
          </div>
          <Button
            className="mt-5 w-full"
            size="lg"
            onClick={() =>
              addToCart({
                courseId: course.id,
                slug: course.slug,
                title: course.title,
                thumbnailUrl: course.thumbnailUrl,
                instructorName: course.instructor.fullName,
                price: course.price,
                currency: course.currency
              })
            }
          >
            {inCart ? "Added to cart" : "Add to cart"}
          </Button>
          <Button
            className="mt-3 w-full"
            size="lg"
            variant="secondary"
            onClick={() =>
              toggleWishlist({
                courseId: course.id,
                slug: course.slug,
                title: course.title,
                thumbnailUrl: course.thumbnailUrl,
                instructorName: course.instructor.fullName,
                price: course.price,
                currency: course.currency,
                rating: course.rating,
                ratingCount: course.ratingCount
              })
            }
          >
            {wishlisted ? "Remove from wishlist" : "Add to wishlist"}
          </Button>
        </aside>
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 7. Category page (reuses marketplace grid, pre-filtered)
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(marketing)/categories/[slug]/page.tsx" @'
"use client";

import { useParams } from "next/navigation";
import { useCourseList } from "@saachi/api-client";
import { CourseCard, EmptyState, Loading } from "@saachi/ui";
import { getCategoryBySlug } from "../../../../lib/categories";

export default function CategoryPage() {
  const params = useParams<{ slug: string }>();
  const category = getCategoryBySlug(params.slug);
  const { data, isLoading } = useCourseList({ category: category?.id, sort: "popular" });

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      <h1 className="mb-2 font-display text-[28px] font-bold text-ink">
        {category?.name ?? "Category"}
      </h1>
      <p className="mb-8 text-[14px] text-ink-soft">
        {data?.total ?? 0} courses in this category
      </p>

      {isLoading ? (
        <Loading label="Loading courses..." />
      ) : !data || data.items.length === 0 ? (
        <EmptyState title="No courses in this category yet" description="Check back soon, or browse all courses." />
      ) : (
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {data.items.map((course) => (
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
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 8. Auth — Login / Register
# ---------------------------------------------------------------------------

Write-Utf8NoBom "apps/web/app/(auth)/login/page.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Button, Input, SocialLoginButtons } from "@saachi/ui";
import { useLogin } from "@saachi/api-client";

export default function LoginPage() {
  const router = useRouter();
  const login = useLogin();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    login.mutate(
      { email, password },
      { onSuccess: () => router.push("/dashboard") }
    );
  }

  return (
    <div className="mx-auto flex max-w-md flex-col px-4 py-16 md:px-0">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Log in</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Welcome back to Saachi AI.</p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Input
          label="Email"
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@example.com"
        />
        <Input
          label="Password"
          type="password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="At least 8 characters"
        />
        <Button type="submit" size="lg" loading={login.isPending}>
          Log in
        </Button>
      </form>

      <div className="mt-6">
        <SocialLoginButtons />
      </div>

      <p className="mt-8 text-center text-[14px] text-ink-soft">
        Don&apos;t have an account?{" "}
        <Link href="/register" className="font-semibold text-gold-dark hover:underline">
          Sign up
        </Link>
      </p>
    </div>
  );
}
'@

Write-Utf8NoBom "apps/web/app/(auth)/register/page.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Button, Input, Select, SocialLoginButtons } from "@saachi/ui";
import { useRegister } from "@saachi/api-client";

const ROLE_OPTIONS = [
  { label: "Learner - I want to learn AI skills", value: "learner" },
  { label: "Instructor - I want to teach and sell courses", value: "instructor" }
];

export default function RegisterPage() {
  const router = useRouter();
  const register = useRegister();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [role, setRole] = useState("learner");

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (password !== confirmPassword) return;
    register.mutate(
      { fullName, email, password, confirmPassword, role: role as "learner" | "instructor" },
      { onSuccess: () => router.push("/dashboard") }
    );
  }

  return (
    <div className="mx-auto flex max-w-md flex-col px-4 py-16 md:px-0">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Create your account</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Join the Saachi AI marketplace.</p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Input
          label="Full name"
          required
          value={fullName}
          onChange={(e) => setFullName(e.target.value)}
          placeholder="Your full name"
        />
        <Input
          label="Email"
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="you@example.com"
        />
        <Select label="I am joining as" options={ROLE_OPTIONS} value={role} onChange={(e) => setRole(e.target.value)} />
        <Input
          label="Password"
          type="password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="At least 8 characters"
        />
        <Input
          label="Confirm password"
          type="password"
          required
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          error={confirmPassword && password !== confirmPassword ? "Passwords do not match" : undefined}
        />
        <Button type="submit" size="lg" loading={register.isPending}>
          Create account
        </Button>
      </form>

      <div className="mt-6">
        <SocialLoginButtons />
      </div>

      <p className="mt-8 text-center text-[14px] text-ink-soft">
        Already have an account?{" "}
        <Link href="/login" className="font-semibold text-gold-dark hover:underline">
          Log in
        </Link>
      </p>
    </div>
  );
}
'@

Write-Host ""
Write-Host "== Done. Next steps ==" -ForegroundColor Green
Write-Host "  1. cd into the repo root (if not already)"
Write-Host "  2. pnpm install"
Write-Host "  3. pnpm --filter web dev"
Write-Host ""
Write-Host "Pages created under apps/web/app:"
Write-Host "  (marketing)/page.tsx                    -> /"
Write-Host "  (marketing)/courses/page.tsx             -> /courses"
Write-Host "  (marketing)/courses/[slug]/page.tsx      -> /courses/[slug]"
Write-Host "  (marketing)/categories/[slug]/page.tsx   -> /categories/[slug]"
Write-Host "  (auth)/login/page.tsx                    -> /login"
Write-Host "  (auth)/register/page.tsx                 -> /register"
Write-Host "apps/admin was NOT touched."