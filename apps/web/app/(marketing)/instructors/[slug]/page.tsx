"use client";

import { useParams } from "next/navigation";
import Link from "next/link";
import { Star, Users, BookOpen, MessageCircle } from "lucide-react";
import { useInstructorProfile } from "@saachi/api-client";
import { CourseCard, Loading, EmptyState, Button } from "@saachi/ui";

export default function InstructorPublicProfilePage() {
  const params = useParams<{ slug: string }>();
  const { data: instructor, isLoading } = useInstructorProfile(params.slug);

  if (isLoading) {
    return (
      <div className="mx-auto max-w-7xl px-4 py-16 md:px-8">
        <Loading label="Loading instructor profile..." />
      </div>
    );
  }

  if (!instructor) {
    return (
      <div className="mx-auto max-w-7xl px-4 py-16 md:px-8">
        <EmptyState
          title="Instructor not found"
          description="This instructor profile may have been removed or the link is incorrect."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-12 md:px-8">
      {/* Header */}
      <div className="mb-10 flex flex-col items-center gap-4 text-center sm:flex-row sm:items-start sm:text-left">
        <div className="flex h-24 w-24 shrink-0 items-center justify-center overflow-hidden rounded-full border border-line bg-paper-dim text-[28px] font-semibold text-ink-soft">
          {instructor.avatarUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={instructor.avatarUrl} alt={instructor.fullName} className="h-full w-full object-cover" />
          ) : (
            instructor.fullName.charAt(0)
          )}
        </div>
        <div>
          <h1 className="font-display text-[26px] font-bold text-ink">{instructor.fullName}</h1>
          {instructor.headline && <p className="mt-1 text-[14px] text-ink-soft">{instructor.headline}</p>}

          <div className="mt-4 flex flex-wrap justify-center gap-5 text-[13px] text-ink-soft sm:justify-start">
            <span className="flex items-center gap-1.5">
              <Star size={14} className="text-gold-dark" fill="currentColor" />
              <span className="font-semibold text-ink">{instructor.averageRating?.toFixed(1) ?? "New"}</span> rating
            </span>
            <span className="flex items-center gap-1.5">
              <Users size={14} /> {instructor.studentCount ?? 0} students
            </span>
            <span className="flex items-center gap-1.5">
              <BookOpen size={14} /> {instructor.courseCount ?? 0} courses
            </span>
          </div>
        </div>

        <Button variant="secondary" size="sm" className="sm:ml-auto sm:mt-1">
          <MessageCircle size={14} className="mr-1.5" />
          Message
        </Button>
      </div>

      {/* Bio */}
      {instructor.bio && (
        <section className="mb-12 max-w-3xl">
          <h2 className="mb-3 font-display text-[18px] font-semibold text-ink">About</h2>
          <p className="text-[14px] leading-relaxed text-ink-soft">{instructor.bio}</p>
        </section>
      )}

      {/* Courses */}
      <section className="mb-12">
        <h2 className="mb-5 font-display text-[18px] font-semibold text-ink">Courses by {instructor.fullName}</h2>
        {!instructor.courses || instructor.courses.length === 0 ? (
          <EmptyState title="No published courses yet" description="This instructor hasn't published any courses." />
        ) : (
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-4">
            {instructor.courses.map((course) => (
              <CourseCard
                key={course.id}
                slug={course.slug}
                title={course.title}
                thumbnailUrl={course.thumbnailUrl}
                instructorName={instructor.fullName}
                price={course.price}
                currency={course.currency}
                rating={course.rating ?? 0}
                ratingCount={course.ratingCount ?? 0}
              />
            ))}
          </div>
        )}
      </section>

      {/* Reviews about instructor */}
      <section>
        <h2 className="mb-5 font-display text-[18px] font-semibold text-ink">What learners say</h2>
        {!instructor.reviews || instructor.reviews.length === 0 ? (
          <p className="text-[14px] text-ink-soft">No reviews yet.</p>
        ) : (
          <div className="flex flex-col gap-4">
            {instructor.reviews.map((r) => (
              <div key={r.id} className="rounded-card border border-line bg-card p-4">
                <div className="mb-1 flex items-center justify-between">
                  <span className="text-[13.5px] font-semibold text-ink">{r.authorName}</span>
                  <span className="text-gold-dark">{"\u2605".repeat(r.rating)}{"\u2606".repeat(5 - r.rating)}</span>
                </div>
                <p className="text-[13.5px] text-ink-soft">{r.comment}</p>
              </div>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}