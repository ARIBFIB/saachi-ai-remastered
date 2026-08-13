"use client";

import { Suspense, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import { Search as SearchIcon } from "lucide-react";
import { useCourseList } from "@saachi/api-client";
import { CourseCard, EmptyState, Input, Loading } from "@saachi/ui";

function SearchResults() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const initialQuery = searchParams.get("q") ?? "";
  const [query, setQuery] = useState(initialQuery);

  const { data, isLoading } = useCourseList({ search: initialQuery || undefined });

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    router.push(`/search?q=${encodeURIComponent(query)}`);
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Search</h1>

      <form onSubmit={handleSubmit} className="mb-8 flex max-w-lg gap-2">
        <Input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search courses or instructors..."
          className="flex-1"
        />
      </form>

      {!initialQuery ? (
        <EmptyState
          title="Search Saachi AI"
          description="Type a course, topic, or instructor name above to get started."
        />
      ) : isLoading ? (
        <Loading label="Searching..." />
      ) : !data || data.items.length === 0 ? (
        <EmptyState
          title={`No results for "${initialQuery}"`}
          description="Try a different search term or browse categories instead."
        />
      ) : (
        <>
          <p className="mb-4 flex items-center gap-2 text-[13px] text-ink-soft">
            <SearchIcon size={14} />
            {data.total} results for &quot;{initialQuery}&quot;
          </p>
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
  );
}

export default function SearchPage() {
  return (
    <Suspense fallback={<Loading label="Loading..." />}>
      <SearchResults />
    </Suspense>
  );
}