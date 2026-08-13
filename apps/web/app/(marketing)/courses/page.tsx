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