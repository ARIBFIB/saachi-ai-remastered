"use client";

import Link from "next/link";
import { useSession, useCourseList } from "@saachi/api-client";
import { Button, Card, CourseCard, SkeletonCard } from "@saachi/ui";

export default function LearnerDashboardPage() {
  const { data: session } = useSession();
  const { data, isLoading } = useCourseList({ sort: "popular" });

  const courses = data?.items ?? [];

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-10">
        <h1 className="font-display text-[28px] font-semibold text-ink">
          Welcome back{session?.fullName ? `, ${session.fullName.split(" ")[0]}` : ""}
        </h1>
        <p className="mt-1 text-[14px] text-ink-soft">
          Pick up where you left off, or explore something new.
        </p>
      </div>

      <Card className="mb-10 flex flex-col items-start gap-4 p-6 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h2 className="text-[16px] font-semibold text-ink">This is demo data</h2>
          <p className="mt-1 text-[14px] text-ink-soft">
            You are signed in with a local demo session - no backend or real account required yet.
          </p>
        </div>
        <Link href="/courses">
          <Button>Browse courses</Button>
        </Link>
      </Card>

      <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Recommended for you</h2>
      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
        {isLoading
          ? Array.from({ length: 4 }).map((_, i) => <SkeletonCard key={i} />)
          : courses.slice(0, 4).map((course) => (
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
    </main>
  );
}