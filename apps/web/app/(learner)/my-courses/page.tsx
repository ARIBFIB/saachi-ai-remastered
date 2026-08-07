"use client";

import Link from "next/link";
import { BookOpen } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { useCourseDetail } from "@saachi/api-client";
import { Button, Card, EmptyState } from "@saachi/ui";

function ContinueButton({ courseId, slug }: { courseId: string; slug: string }) {
  const { data: course } = useCourseDetail(slug);
  const firstLessonId = course?.curriculum?.[0]?.lessons?.[0]?.id;

  if (!firstLessonId) {
    return (
      <Button size="sm" variant="secondary" className="shrink-0" disabled>
        Loading...
      </Button>
    );
  }

  return (
    <Link href={`/learn/${courseId}/${firstLessonId}`}>
      <Button size="sm" variant="secondary" className="shrink-0">
        Continue
      </Button>
    </Link>
  );
}

export default function MyCoursesPage() {
  const { enrollments } = useEnrollmentStore();

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">My Courses</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Everything you're enrolled in, in one place.</p>
      </div>

      {enrollments.length === 0 ? (
        <EmptyState
          icon={<BookOpen size={22} />}
          title="No courses yet"
          description="Once you purchase a course, it will show up here with your progress."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-4">
          {enrollments.map((course) => (
            <Card key={course.courseId} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center">
              <Link href={`/courses/${course.slug}`} className="block h-[90px] w-[160px] shrink-0 overflow-hidden rounded-control bg-paper-dim">
                {course.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.thumbnailUrl} alt={course.title} className="h-full w-full object-cover" />
                )}
              </Link>
              <div className="flex-1">
                <Link href={`/courses/${course.slug}`} className="text-[15px] font-semibold text-ink hover:text-gold-dark">
                  {course.title}
                </Link>
                <p className="mt-1 text-[13px] text-ink-soft">{course.instructorName}</p>
                <div className="mt-3 flex items-center gap-3">
                  <div className="h-2 w-full max-w-[220px] overflow-hidden rounded-full bg-paper-dim">
                    <div
                      className="h-full rounded-full bg-gold"
                      style={{ width: `${course.progressPercent}%` }}
                    />
                  </div>
                  <span className="shrink-0 text-[12px] text-ink-soft">{course.progressPercent}% complete</span>
                </div>
              </div>
              {course.progressPercent >= 100 ? (
                <Link href="/certificates">
                  <Button size="sm" variant="secondary" className="shrink-0">
                    View certificate
                  </Button>
                </Link>
              ) : (
                <ContinueButton courseId={course.courseId} slug={course.slug} />
              )}
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}