"use client";

import { useParams } from "next/navigation";
import { Star, Users, BookOpen } from "lucide-react";
import { useCourseList } from "@saachi/api-client";
import { CourseCard, EmptyState, Loading, Badge } from "@saachi/ui";

export default function InstructorProfilePage() {
  const params = useParams<{ slug: string }>();
  const instructorSlug = params.slug;

  // NOTE: no dedicated useInstructorProfile hook is confirmed yet.
  // Reusing course list filtered client-side by instructor until a
  // dedicated hooks/useInstructors.ts is verified/added.
  const { data, isLoading } = useCourseList({ search: instructorSlug });

  const courses = data?.items ?? [];
  const instructor = courses[0]?.instructor;

  if (isLoading) {
    return <Loading label="Loading instructor profile..." />;
  }

  if (!instructor) {
    return (
      <div className="mx-auto max-w-3xl px-4 py-16">
        <EmptyState
          title="Instructor not found"
          description="This instructor profile could not be located."
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-6xl px-4 py-12 md:px-8">
      <div className="mb-10 flex flex-col items-center gap-4 text-center md:flex-row md:items-start md:text-left">
        <div className="flex h-20 w-20 shrink-0 items-center justify-center rounded-full bg-gold-tint text-[26px] font-bold text-gold-dark">
          {instructor.fullName?.charAt(0) ?? "?"}
        </div>
        <div>
          <h1 className="font-display text-[26px] font-bold text-ink">{instructor.fullName}</h1>
          <Badge variant="gold" className="mt-2">Instructor</Badge>
          <div className="mt-3 flex flex-wrap justify-center gap-4 text-[13px] text-ink-soft md:justify-start">
            <span className="flex items-center gap-1.5">
              <BookOpen size={14} /> {courses.length} courses
            </span>
            <span className="flex items-center gap-1.5">
              <Users size={14} /> Students taught: n/a
            </span>
            <span className="flex items-center gap-1.5">
              <Star size={14} /> Avg rating: n/a
            </span>
          </div>
        </div>
      </div>

      <h2 className="mb-5 font-display text-[20px] font-semibold text-ink">Courses by this instructor</h2>
      {courses.length === 0 ? (
        <EmptyState title="No published courses yet" description="Check back later." />
      ) : (
        <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
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
  );
}