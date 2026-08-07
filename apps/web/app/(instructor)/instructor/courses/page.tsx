"use client";

import Link from "next/link";
import { PlusCircle, BookOpen } from "lucide-react";
import { useInstructorCourseStore } from "@saachi/store";
import { Button, Card, Badge, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_VARIANT = {
  draft: "default",
  pending_review: "warning",
  published: "success"
} as const;

export default function InstructorCoursesPage() {
  const { courses, removeCourse } = useInstructorCourseStore();

  return (
    <main className="mx-auto max-w-[1100px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="font-display text-[26px] font-semibold text-ink">My Courses</h1>
          <p className="mt-1 text-[14px] text-ink-soft">Manage the courses you've created.</p>
        </div>
        <Link href="/instructor/courses/new">
          <Button>
            <PlusCircle size={16} /> Create course
          </Button>
        </Link>
      </div>

      {courses.length === 0 ? (
        <EmptyState
          icon={<BookOpen size={22} />}
          title="No courses yet"
          description="Start the course creation wizard to publish your first course."
          action={
            <Link href="/instructor/courses/new">
              <Button>Create course</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-3">
          {courses.map((course) => (
            <Card key={course.id} className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <div className="flex items-center gap-2">
                  <p className="text-[15px] font-semibold text-ink">{course.title || "Untitled course"}</p>
                  <Badge variant={STATUS_VARIANT[course.status]}>{course.status.replace("_", " ")}</Badge>
                </div>
                <p className="mt-1 text-[13px] text-ink-soft">
                  {course.modules.length} modules &middot; Created {formatDate(course.createdAt)}
                </p>
              </div>
              <div className="flex items-center gap-4">
                <span className="font-mono text-[14px] font-semibold text-ink">
                  {formatCurrency(course.price, course.currency)}
                </span>
                <Button size="sm" variant="secondary" onClick={() => removeCourse(course.id)}>
                  Delete
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}