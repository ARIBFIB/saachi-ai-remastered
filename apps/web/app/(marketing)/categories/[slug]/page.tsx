"use client";

import { useMemo, useState } from "react";
import { useParams } from "next/navigation";
import { useCourseList, type CourseListFilters } from "@saachi/api-client";
import { CourseCard, EmptyState, FilterSidebar, Select, Loading, type FilterSidebarValue } from "@saachi/ui";
import { CATEGORIES, getCategoryBySlug } from "../../../../lib/categories";

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

export default function CategoryPage() {
  const params = useParams<{ slug: string }>();
  const category = getCategoryBySlug(params.slug);

  const [sort, setSort] = useState("popular");
  const [filters, setFilters] = useState<FilterSidebarValue>({
    categories: category ? [category.id] : [],
    level: undefined,
    language: undefined
  });

  const queryFilters: CourseListFilters = useMemo(
    () => ({
      category: filters.categories[0] ?? category?.id,
      level: filters.level,
      language: filters.language,
      sort
    }),
    [filters, sort, category]
  );

  const { data, isLoading } = useCourseList(queryFilters);

  if (!category) {
    return (
      <div className="mx-auto max-w-7xl px-4 py-16 md:px-8">
        <EmptyState title="Category not found" description="This category doesn't exist." />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      <div className="mb-6">
        <p className="mb-1 text-[13px] font-medium text-gold-dark">Category</p>
        <h1 className="font-display text-[28px] font-bold text-ink">{category.name}</h1>
      </div>

      <div className="mb-6 flex justify-end">
        <Select options={SORT_OPTIONS} value={sort} onChange={(e) => setSort(e.target.value)} className="w-56" />
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
            <EmptyState title="No courses found" description="Try adjusting your filters." />
          ) : (
            <>
              <p className="mb-4 text-[13px] text-ink-soft">{data.total} courses found</p>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
                {data.items.map((c) => (
                  <CourseCard
                    key={c.id}
                    slug={c.slug}
                    title={c.title}
                    thumbnailUrl={c.thumbnailUrl}
                    instructorName={c.instructor.fullName}
                    price={c.price}
                    currency={c.currency}
                    rating={c.rating}
                    ratingCount={c.ratingCount}
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