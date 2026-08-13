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