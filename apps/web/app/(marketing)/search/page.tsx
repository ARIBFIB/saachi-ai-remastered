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