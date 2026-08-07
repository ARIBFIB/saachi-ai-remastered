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