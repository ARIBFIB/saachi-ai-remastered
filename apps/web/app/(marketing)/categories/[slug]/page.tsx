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