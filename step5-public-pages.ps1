# step5-public-pages.ps1
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

Write-Host "Step 5: category, instructor profile, search, about, pricing, legal, contact, 404..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Category page
# ---------------------------------------------------------------------------
$categoryPage = @'
"use client";

import { useMemo } from "react";
import { useCourseList } from "@saachi/api-client";
import { CourseCard, SkeletonCard, EmptyState } from "@saachi/ui";
import { Navbar } from "../../_components/Navbar";
import { Footer } from "../../_components/Footer";

const CATEGORY_LABELS: Record<string, string> = {
  "ai-fundamentals": "AI Fundamentals & Prompt Engineering",
  "ai-marketing": "AI for Marketing & Sales",
  "ai-automation": "AI Automation & Workflow Tools",
  "ai-support": "AI Customer Support & Communication",
  "ai-dev": "AI Website & App Development",
  "ai-integration": "AI Integration for Developers"
};

const CATEGORY_DESCRIPTIONS: Record<string, string> = {
  "ai-fundamentals": "Go from zero to confident with practical prompt engineering and everyday AI literacy.",
  "ai-marketing": "AI-powered campaigns, ad copy, and lead generation that actually converts.",
  "ai-automation": "Connect AI models into no-code workflows with n8n, Zapier, and Make.com.",
  "ai-support": "Build WhatsApp auto-responders and AI call-center response systems.",
  "ai-dev": "Build websites and apps faster using AI-assisted development tools.",
  "ai-integration": "Wire OpenAI, Claude, and Gemini APIs into real production applications."
};

export default function CategoryPage({ params }: { params: { slug: string } }) {
  const label = CATEGORY_LABELS[params.slug] ?? "Category";
  const description = CATEGORY_DESCRIPTIONS[params.slug] ?? "Explore courses in this track.";

  const { data, isLoading } = useCourseList({ category: params.slug, sort: "popular" });
  const courses = useMemo(() => data?.items ?? [], [data]);

  return (
    <>
      <Navbar />
      <main>
        <section className="bg-paper-dim px-6 py-16">
          <div className="mx-auto max-w-[1140px]">
            <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
              Category
            </span>
            <h1 className="mt-3 font-display text-[32px] font-semibold leading-[1.2] text-ink md:text-[40px]">
              {label}
            </h1>
            <p className="mt-3 max-w-[640px] text-[16px] leading-relaxed text-ink-soft">{description}</p>
          </div>
        </section>

        <section className="px-6 py-16">
          <div className="mx-auto max-w-[1140px]">
            {isLoading ? (
              <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
                {Array.from({ length: 6 }).map((_, i) => (
                  <SkeletonCard key={i} />
                ))}
              </div>
            ) : courses.length === 0 ? (
              <EmptyState
                title="No courses in this category yet"
                description="Check back soon, or explore the full marketplace."
              />
            ) : (
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
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\categories\[slug]\page.tsx" -Content $categoryPage

# ---------------------------------------------------------------------------
# 2. Instructor public profile page
# ---------------------------------------------------------------------------
$instructorProfilePage = @'
"use client";

import Link from "next/link";
import { Star, Users, BookOpen, MessageSquare } from "lucide-react";
import { DUMMY_COURSES } from "@saachi/api-client";
import { Button, Card, CourseCard, ReviewCard, EmptyState } from "@saachi/ui";
import { Navbar } from "../../_components/Navbar";
import { Footer } from "../../_components/Footer";

function slugifyName(name: string) {
  return name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
}

export default function InstructorProfilePage({ params }: { params: { slug: string } }) {
  const instructorCourses = DUMMY_COURSES.filter(
    (c) => slugifyName(c.instructor.fullName) === params.slug
  );

  if (instructorCourses.length === 0) {
    return (
      <>
        <Navbar />
        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <EmptyState
            title="Instructor not found"
            description="This instructor profile may have been moved."
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

  const instructor = instructorCourses[0].instructor;
  const totalStudents = instructorCourses.reduce(
    (sum, c) => sum + (c.instructorStudentCount ?? 0),
    0
  );
  const avgRating =
    instructorCourses.reduce((sum, c) => sum + c.rating, 0) / instructorCourses.length;
  const allReviews = instructorCourses.flatMap((c) => c.reviews ?? []).slice(0, 4);

  return (
    <>
      <Navbar />
      <main>
        <section className="bg-paper-dim px-6 py-16">
          <div className="mx-auto flex max-w-[1140px] flex-col items-center gap-6 text-center md:flex-row md:items-start md:text-left">
            <div className="flex h-24 w-24 shrink-0 items-center justify-center overflow-hidden rounded-full border-2 border-ink bg-teal-light text-[28px] font-semibold text-teal">
              {instructor.avatarUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={instructor.avatarUrl} alt={instructor.fullName} className="h-full w-full object-cover" />
              ) : (
                instructor.fullName.charAt(0)
              )}
            </div>
            <div className="flex-1">
              <h1 className="font-display text-[30px] font-semibold text-ink">{instructor.fullName}</h1>
              <p className="mt-2 max-w-[560px] text-[15px] leading-relaxed text-ink-soft">
                {instructorCourses[0].instructorBio ?? "Practical AI practitioner and instructor on Saachi AI."}
              </p>
              <div className="mt-4 flex flex-wrap justify-center gap-6 text-[13px] text-ink-soft md:justify-start">
                <span className="flex items-center gap-1.5">
                  <Users size={15} /> {totalStudents.toLocaleString()} students
                </span>
                <span className="flex items-center gap-1.5">
                  <BookOpen size={15} /> {instructorCourses.length} courses
                </span>
                <span className="flex items-center gap-1.5">
                  <Star size={15} className="fill-gold text-gold" /> {avgRating.toFixed(1)} average rating
                </span>
              </div>
              <Link href="/login" className="mt-5 inline-block">
                <Button size="sm" variant="secondary">
                  <MessageSquare size={15} /> Message instructor
                </Button>
              </Link>
            </div>
          </div>
        </section>

        <section className="px-6 py-16">
          <div className="mx-auto max-w-[1140px]">
            <h2 className="mb-6 font-display text-[22px] font-semibold text-ink">Courses by {instructor.fullName}</h2>
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
              {instructorCourses.map((course) => (
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

            {allReviews.length > 0 && (
              <div className="mt-14">
                <h2 className="mb-6 font-display text-[22px] font-semibold text-ink">
                  What students say
                </h2>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  {allReviews.map((review) => (
                    <ReviewCard key={review.id} {...review} />
                  ))}
                </div>
              </div>
            )}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\instructors\[slug]\page.tsx" -Content $instructorProfilePage

# ---------------------------------------------------------------------------
# 3. Global search results page
# ---------------------------------------------------------------------------
$searchPage = @'
"use client";

import { useMemo, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { Search } from "lucide-react";
import Link from "next/link";
import { DUMMY_COURSES } from "@saachi/api-client";
import { CourseCard, Input, EmptyState, Card } from "@saachi/ui";
import { Navbar } from "../_components/Navbar";
import { Footer } from "../_components/Footer";

function slugifyName(name: string) {
  return name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
}

export default function SearchPage() {
  const params = useSearchParams();
  const router = useRouter();
  const initialQuery = params.get("q") ?? "";
  const [query, setQuery] = useState(initialQuery);

  const results = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return { courses: [], instructors: [] };

    const courses = DUMMY_COURSES.filter((c) => c.title.toLowerCase().includes(q));

    const instructorMap = new Map<string, { name: string; slug: string; avatarUrl?: string; courseCount: number }>();
    DUMMY_COURSES.forEach((c) => {
      if (c.instructor.fullName.toLowerCase().includes(q)) {
        const slug = slugifyName(c.instructor.fullName);
        const existing = instructorMap.get(slug);
        if (existing) {
          existing.courseCount += 1;
        } else {
          instructorMap.set(slug, {
            name: c.instructor.fullName,
            slug,
            avatarUrl: c.instructor.avatarUrl,
            courseCount: 1
          });
        }
      }
    });

    return { courses, instructors: Array.from(instructorMap.values()) };
  }, [query]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    router.push(`/search?q=${encodeURIComponent(query)}`);
  };

  const hasResults = results.courses.length > 0 || results.instructors.length > 0;

  return (
    <>
      <Navbar />
      <main className="mx-auto max-w-[1000px] px-6 py-16">
        <h1 className="mb-6 font-display text-[28px] font-semibold text-ink">Search</h1>

        <form onSubmit={handleSubmit} className="relative mb-10 max-w-[520px]">
          <Search size={18} className="pointer-events-none absolute left-3.5 top-1/2 -translate-y-1/2 text-ink-soft/60" />
          <Input
            placeholder="Search courses and instructors"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            className="pl-10"
          />
        </form>

        {!query.trim() ? (
          <EmptyState title="Start typing to search" description="Search across all courses and instructors." />
        ) : !hasResults ? (
          <EmptyState title="No results found" description={`Nothing matched "${query}". Try a different term.`} />
        ) : (
          <div className="flex flex-col gap-14">
            {results.instructors.length > 0 && (
              <div>
                <h2 className="mb-4 text-[16px] font-semibold text-ink">Instructors</h2>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  {results.instructors.map((instructor) => (
                    <Link key={instructor.slug} href={`/instructors/${instructor.slug}`}>
                      <Card className="flex items-center gap-4 p-4">
                        <div className="flex h-12 w-12 shrink-0 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[15px] font-semibold text-teal">
                          {instructor.avatarUrl ? (
                            // eslint-disable-next-line @next/next/no-img-element
                            <img src={instructor.avatarUrl} alt={instructor.name} className="h-full w-full object-cover" />
                          ) : (
                            instructor.name.charAt(0)
                          )}
                        </div>
                        <div>
                          <p className="text-[14px] font-semibold text-ink">{instructor.name}</p>
                          <p className="text-[12px] text-ink-soft">{instructor.courseCount} courses</p>
                        </div>
                      </Card>
                    </Link>
                  ))}
                </div>
              </div>
            )}

            {results.courses.length > 0 && (
              <div>
                <h2 className="mb-4 text-[16px] font-semibold text-ink">Courses</h2>
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
                  {results.courses.map((course) => (
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
              </div>
            )}
          </div>
        )}
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\search\page.tsx" -Content $searchPage

# ---------------------------------------------------------------------------
# 4. Navbar - wire the search bar to /search (small addition, non-breaking)
# ---------------------------------------------------------------------------
# (left as-is intentionally; a search icon/input can be added in a later pass
# without risking a patch-pattern mismatch on the existing Navbar file)

# ---------------------------------------------------------------------------
# 5. About Us page
# ---------------------------------------------------------------------------
$aboutPage = @'
import Link from "next/link";
import { Target, Users, Sparkles, ArrowRight } from "lucide-react";
import { Button } from "@saachi/ui";
import { Navbar } from "../_components/Navbar";
import { Footer } from "../_components/Footer";

const VALUES = [
  {
    icon: Target,
    title: "Outcome over watch-time",
    desc: "Every course exists to produce something real - not to maximize minutes viewed."
  },
  {
    icon: Users,
    title: "Practitioners, not presenters",
    desc: "Our instructors use the exact skills they teach in their own client and business work."
  },
  {
    icon: Sparkles,
    title: "Practical AI, not hype",
    desc: "We're intentionally narrow: applied AI skills you can use at work this week."
  }
];

export default function AboutPage() {
  return (
    <>
      <Navbar />
      <main>
        <section className="px-6 py-20 md:py-28">
          <div className="mx-auto max-w-[760px] text-center">
            <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
              About Saachi AI
            </span>
            <h1 className="mt-4 font-display text-[32px] font-semibold leading-[1.2] text-ink md:text-[44px]">
              A skills exchange for the AI era
            </h1>
            <p className="mt-6 text-[17px] leading-relaxed text-ink-soft">
              Saachi AI exists to close the gap between knowing that AI tools exist and knowing
              how to actually use them to produce real, sellable outcomes - websites, apps,
              automations, marketing campaigns, content pipelines, customer support systems, and
              more. We connect people who've figured this out with people who want to learn it,
              inside a safe, paid, structured environment.
            </p>
          </div>
        </section>

        <section className="bg-paper-dim px-6 py-16 md:py-24">
          <div className="mx-auto max-w-[1140px]">
            <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
              {VALUES.map((v) => (
                <div key={v.title} className="rounded-card border border-line bg-card p-6">
                  <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-control bg-teal-light">
                    <v.icon size={19} className="text-teal" />
                  </div>
                  <h3 className="mb-2 text-[16px] font-semibold text-ink">{v.title}</h3>
                  <p className="text-[14px] leading-relaxed text-ink-soft">{v.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="px-6 py-16 md:py-24">
          <div className="mx-auto max-w-[1140px] text-center">
            <h2 className="font-display text-[26px] font-semibold text-ink md:text-[32px]">
              Have a practical AI skill worth teaching?
            </h2>
            <Link href="/register" className="mt-6 inline-block">
              <Button size="lg">
                Become an Instructor <ArrowRight size={17} />
              </Button>
            </Link>
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\about\page.tsx" -Content $aboutPage

# ---------------------------------------------------------------------------
# 6. Pricing page
# ---------------------------------------------------------------------------
$pricingPage = @'
import Link from "next/link";
import { Check } from "lucide-react";
import { Button, Card, Accordion } from "@saachi/ui";
import { Navbar } from "../_components/Navbar";
import { Footer } from "../_components/Footer";

const PLANS = [
  {
    name: "Basic",
    price: "Free",
    desc: "Browse and buy individual courses.",
    features: ["Buy courses individually", "Lifetime access to purchased courses", "Community Q&A access", "Certificate on completion"],
    cta: "Get started",
    featured: false
  },
  {
    name: "Pro",
    price: "$19/mo",
    desc: "Unlimited access to the Standard course library.",
    features: [
      "Everything in Basic",
      "Unlimited access to all Standard-tier courses",
      "Priority community support",
      "Early access to new courses"
    ],
    cta: "Start Pro",
    featured: true
  },
  {
    name: "Business",
    price: "Custom",
    desc: "Bulk seats and team reporting for organizations.",
    features: [
      "Everything in Pro",
      "Bulk seat licenses for your team",
      "Team completion & compliance reports",
      "Custom invoicing / PO billing"
    ],
    cta: "Contact sales",
    featured: false
  }
];

const FAQ_ITEMS = [
  {
    id: "f1",
    title: "Can I cancel my Pro subscription anytime?",
    content: "Yes, Pro is billed monthly or yearly and can be cancelled anytime from your billing settings."
  },
  {
    id: "f2",
    title: "Do Basic (pay-per-course) purchases expire?",
    content: "No, courses you purchase individually are yours for life, regardless of your subscription status."
  },
  {
    id: "f3",
    title: "What's included in Business/Team plans?",
    content: "Bulk seat purchasing, a team roster dashboard, course assignment, and completion reporting for your organization."
  }
];

export default function PricingPage() {
  return (
    <>
      <Navbar />
      <main>
        <section className="px-6 py-16 text-center md:py-24">
          <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
            Pricing
          </span>
          <h1 className="mx-auto mt-3 max-w-[640px] font-display text-[30px] font-semibold leading-[1.2] text-ink md:text-[40px]">
            Simple pricing, built around how you learn
          </h1>
        </section>

        <section className="px-6 pb-20">
          <div className="mx-auto grid max-w-[1100px] grid-cols-1 gap-6 md:grid-cols-3">
            {PLANS.map((plan) => (
              <Card
                key={plan.name}
                featured={plan.featured}
                className={plan.featured ? "flex flex-col border-2 border-ink p-8" : "flex flex-col p-8"}
              >
                {plan.featured && (
                  <span className="mb-4 w-fit rounded-full bg-gold px-3 py-1 text-[11px] font-bold uppercase tracking-[0.05em] text-ink">
                    Most popular
                  </span>
                )}
                <h3 className="text-[18px] font-semibold text-ink">{plan.name}</h3>
                <p className="mt-1 font-mono text-[28px] font-semibold text-ink">{plan.price}</p>
                <p className="mt-2 text-[13px] text-ink-soft">{plan.desc}</p>
                <ul className="mt-6 flex flex-1 flex-col gap-3">
                  {plan.features.map((f) => (
                    <li key={f} className="flex items-start gap-2 text-[13px] text-ink-soft">
                      <Check size={15} className="mt-0.5 shrink-0 text-teal" />
                      {f}
                    </li>
                  ))}
                </ul>
                <Link href={plan.name === "Business" ? "/contact" : "/register"} className="mt-6">
                  <Button size="lg" variant={plan.featured ? "primary" : "secondary"} className="w-full">
                    {plan.cta}
                  </Button>
                </Link>
              </Card>
            ))}
          </div>
        </section>

        <section className="bg-paper-dim px-6 py-16 md:py-24">
          <div className="mx-auto max-w-[720px]">
            <h2 className="mb-8 text-center font-display text-[24px] font-semibold text-ink">
              Frequently asked questions
            </h2>
            <Accordion items={FAQ_ITEMS} />
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\pricing\page.tsx" -Content $pricingPage

# ---------------------------------------------------------------------------
# 7. Legal pages (Terms, Privacy, Refund Policy, Instructor Agreement)
# ---------------------------------------------------------------------------
$legalPage = @'
import { Navbar } from "../../_components/Navbar";
import { Footer } from "../../_components/Footer";

const LEGAL_DOCS: Record<string, { title: string; updated: string; body: string[] }> = {
  terms: {
    title: "Terms & Conditions",
    updated: "November 2025",
    body: [
      "These Terms & Conditions govern your use of the Saachi AI platform, including the public website, learner portal, and instructor portal.",
      "By creating an account, you agree to use the platform only for lawful purposes and in accordance with our content and community guidelines.",
      "Course content is owned by the instructor who created it. Saachi AI is granted a license to host, stream, and sell access to that content on the instructor's behalf.",
      "This is placeholder legal text for demo purposes. Final legal copy will be supplied by the client's legal counsel before production launch, per Doc 1, Section 20."
    ]
  },
  privacy: {
    title: "Privacy Policy",
    updated: "November 2025",
    body: [
      "Saachi AI collects account information, course activity, and payment metadata necessary to operate the marketplace.",
      "We do not sell personal data to third parties. Data may be shared with payment processors and infrastructure providers strictly to deliver the service.",
      "Users may request data export or account deletion at any time from Settings - Privacy, in line with GDPR-aligned data rights described in Doc 1.",
      "This is placeholder legal text for demo purposes and will be replaced with final counsel-approved copy."
    ]
  },
  "refund-policy": {
    title: "Refund Policy",
    updated: "November 2025",
    body: [
      "Learners may request a refund within a defined policy window after purchase, subject to a completion-percentage threshold.",
      "Approved refunds reverse the transaction and adjust the instructor's payout balance accordingly.",
      "Refund requests are reviewed by the Finance/Payout Officer role in the Admin Portal.",
      "This is placeholder legal text for demo purposes; final refund window and thresholds are pending client confirmation."
    ]
  },
  "instructor-agreement": {
    title: "Instructor Agreement",
    updated: "November 2025",
    body: [
      "By applying to become an instructor, you agree to submit only original content that you have the rights to distribute.",
      "Saachi AI retains a configurable commission on each course sale, varying by instructor trust tier (New, Verified, Top-Rated, Partner).",
      "Instructors are responsible for responding to learner Q&A and maintaining course quality standards set by the Admin content moderation policy.",
      "This is placeholder legal text for demo purposes and will be finalized with the client's legal counsel."
    ]
  }
};

export default function LegalDocPage({ params }: { params: { doc: string } }) {
  const doc = LEGAL_DOCS[params.doc] ?? {
    title: "Document not found",
    updated: "",
    body: ["This legal document doesn't exist yet."]
  };

  return (
    <>
      <Navbar />
      <main className="mx-auto max-w-[760px] px-6 py-16">
        <h1 className="font-display text-[28px] font-semibold text-ink">{doc.title}</h1>
        {doc.updated && <p className="mt-2 text-[13px] text-ink-soft">Last updated: {doc.updated}</p>}
        <div className="mt-8 flex flex-col gap-4">
          {doc.body.map((para, i) => (
            <p key={i} className="text-[15px] leading-relaxed text-ink-soft">
              {para}
            </p>
          ))}
        </div>
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\legal\[doc]\page.tsx" -Content $legalPage

# ---------------------------------------------------------------------------
# 8. Contact page
# ---------------------------------------------------------------------------
$contactPage = @'
"use client";

import { useState } from "react";
import { Mail, MessageCircle } from "lucide-react";
import { Button, Card, Input, Textarea } from "@saachi/ui";
import { Navbar } from "../_components/Navbar";
import { Footer } from "../_components/Footer";

export default function ContactPage() {
  const [sent, setSent] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // NOTE: demo-only. Replace with real Support/Helpdesk API call once backend exists.
    setSent(true);
  };

  return (
    <>
      <Navbar />
      <main className="mx-auto max-w-[900px] px-6 py-16">
        <div className="mb-10 text-center">
          <h1 className="font-display text-[28px] font-semibold text-ink">Get in touch</h1>
          <p className="mt-2 text-[15px] text-ink-soft">
            Questions about courses, instructor applications, or your account? We're here to help.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-[1fr_320px]">
          <Card className="p-6">
            {sent ? (
              <div className="py-8 text-center">
                <h2 className="text-[18px] font-semibold text-ink">Message sent</h2>
                <p className="mt-2 text-[14px] text-ink-soft">
                  This is a demo form - no message was actually delivered. We'll typically reply
                  within 1 business day once live support is connected.
                </p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="flex flex-col gap-4">
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <Input label="Your name" placeholder="Full name" required />
                  <Input label="Email" type="email" placeholder="you@example.com" required />
                </div>
                <Input label="Subject" placeholder="What's this about?" required />
                <Textarea label="Message" placeholder="Tell us more..." rows={6} required />
                <Button type="submit" size="lg" className="mt-2 w-fit">
                  Send message
                </Button>
              </form>
            )}
          </Card>

          <div className="flex flex-col gap-4">
            <Card className="flex items-start gap-3 p-5">
              <Mail size={18} className="mt-0.5 shrink-0 text-teal" />
              <div>
                <p className="text-[14px] font-semibold text-ink">Email support</p>
                <p className="mt-1 text-[13px] text-ink-soft">support@saachi.ai</p>
              </div>
            </Card>
            <Card className="flex items-start gap-3 p-5">
              <MessageCircle size={18} className="mt-0.5 shrink-0 text-teal" />
              <div>
                <p className="text-[14px] font-semibold text-ink">Community</p>
                <p className="mt-1 text-[13px] text-ink-soft">
                  Enrolled learners can ask questions directly in any course's Q&A tab.
                </p>
              </div>
            </Card>
          </div>
        </div>
      </main>
      <Footer />
    </>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\contact\page.tsx" -Content $contactPage

# ---------------------------------------------------------------------------
# 9. Global 404 page (App Router not-found.tsx)
# ---------------------------------------------------------------------------
$notFoundPage = @'
import Link from "next/link";
import { Button } from "@saachi/ui";

export default function NotFound() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-paper px-6 text-center">
      <span className="font-display text-[80px] font-semibold leading-none text-gold-tint">404</span>
      <h1 className="mt-4 font-display text-[24px] font-semibold text-ink">Page not found</h1>
      <p className="mt-2 max-w-[420px] text-[14px] text-ink-soft">
        The page you're looking for doesn't exist or may have moved.
      </p>
      <Link href="/" className="mt-6">
        <Button>Back to homepage</Button>
      </Link>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\not-found.tsx" -Content $notFoundPage

Write-Host ""
Write-Host "Step 5 done." -ForegroundColor Green
Write-Host "Run: pnpm dev:web" -ForegroundColor Green
Write-Host "Test: /categories/ai-automation, /instructors/ayesha-khan, /search?q=prompt, /about, /pricing, /legal/terms, /legal/privacy, /contact, and any bad URL for 404" -ForegroundColor Green