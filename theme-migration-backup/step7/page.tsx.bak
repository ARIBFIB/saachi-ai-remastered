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
          <h1 className="font-display text-[38px] font-bold leading-[1.05] text-ink md:text-[64px]">
            Learn AI Skills.
            <br />
            <span className="text-gradient-brand">Build Real Projects.</span>
          </h1>
          <p className="mt-5 text-[16px] leading-relaxed text-ink-soft md:text-[18px]">
            Not another watch-time platform. Saachi AI is a skills exchange for the AI era - structured, practical, and paid.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses">
              <Button size="lg" variant="brand">Browse courses</Button>
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