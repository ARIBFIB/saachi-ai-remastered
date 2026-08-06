"use client";

import { useParams } from "next/navigation";
import { PlayCircle, Star, Clock, FileText, HelpCircle } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import {
  Button,
  Card,
  Badge,
  Accordion,
  ReviewCard,
  CourseCard,
  SkeletonCard,
  Skeleton,
  EmptyState
} from "@saachi/ui";
import type { AccordionItemData } from "@saachi/ui";

function formatDuration(totalSeconds?: number) {
  if (!totalSeconds) return null;
  const minutes = Math.round(totalSeconds / 60);
  return `${minutes} min`;
}

function formatPrice(price: number, currency: string) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
    minimumFractionDigits: price % 1 === 0 ? 0 : 2
  }).format(price);
}

export default function CourseDetailPage() {
  const params = useParams<{ slug: string }>();
  const { data: course, isLoading, isError } = useCourseDetail(params.slug);

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[1120px] px-6 py-16">
        <Skeleton className="mb-4 h-10 w-2/3" />
        <Skeleton className="mb-8 h-5 w-1/3" />
        <div className="grid grid-cols-1 gap-8 lg:grid-cols-[1fr_360px]">
          <div className="flex flex-col gap-6">
            <SkeletonCard />
            <SkeletonCard />
          </div>
          <SkeletonCard />
        </div>
      </main>
    );
  }

  if (isError || !course) {
    return (
      <main className="mx-auto max-w-[1120px] px-6 py-16">
        <EmptyState
          title="Course not found"
          description="This course may have been removed, or the link is incorrect."
        />
      </main>
    );
  }

  const curriculumItems: AccordionItemData[] = (course.curriculum ?? []).map((module) => ({
    id: module.id,
    title: module.title,
    meta: (
      <span className="text-[12px] text-[var(--text-muted,#94A3B8)]">
        {module.lessons.length} lessons
      </span>
    ),
    content: (
      <ul className="flex flex-col gap-2">
        {module.lessons.map((lesson) => (
          <li key={lesson.id} className="flex items-center justify-between gap-3">
            <span className="flex items-center gap-2 text-[var(--text-primary,#0F172A)]">
              <FileText size={14} className="text-[var(--text-muted,#94A3B8)]" />
              {lesson.title}
              {lesson.isPreview && (
                <Badge variant="info" className="ml-1">
                  Preview
                </Badge>
              )}
            </span>
            {formatDuration(lesson.durationSeconds) && (
              <span className="flex items-center gap-1 text-[12px] text-[var(--text-muted,#94A3B8)]">
                <Clock size={12} />
                {formatDuration(lesson.durationSeconds)}
              </span>
            )}
          </li>
        ))}
      </ul>
    )
  }));

  const faqItems: AccordionItemData[] = (course.faq ?? []).map((item) => ({
    id: item.id,
    title: item.question,
    content: item.answer
  }));

  const breakdown = course.ratingBreakdown;
  const totalRatings = breakdown
    ? breakdown[5] + breakdown[4] + breakdown[3] + breakdown[2] + breakdown[1]
    : course.ratingCount;

  return (
    <main className="mx-auto max-w-[1120px] px-6 py-16">
      {/* Hero */}
      <div className="mb-10 grid grid-cols-1 gap-8 lg:grid-cols-[1fr_360px]">
        <div>
          <Badge variant="info">{course.status === "published" ? "Published" : course.status}</Badge>
          <h1 className="mt-3 text-[32px] font-bold leading-tight text-[var(--text-primary,#0F172A)]">
            {course.title}
          </h1>
          {course.subtitle && (
            <p className="mt-2 text-[16px] text-[var(--text-secondary,#475569)]">{course.subtitle}</p>
          )}

          <div className="mt-4 flex flex-wrap items-center gap-4 text-[14px]">
            <span className="flex items-center gap-1.5">
              <Star size={16} className="fill-[var(--blue-500,#3B82F6)] text-[var(--blue-500,#3B82F6)]" />
              <span className="font-semibold text-[var(--text-primary,#0F172A)]">
                {course.rating.toFixed(1)}
              </span>
              <span className="text-[var(--text-muted,#94A3B8)]">
                ({course.ratingCount.toLocaleString()} ratings)
              </span>
            </span>
            <span className="text-[var(--text-secondary,#475569)]">
              Instructor:{" "}
              <span className="font-semibold text-[var(--text-primary,#0F172A)]">
                {course.instructor.fullName}
              </span>
            </span>
          </div>

          {/* Preview video / thumbnail */}
          <div className="relative mt-6 aspect-video w-full overflow-hidden rounded-2xl bg-[var(--surface-elevated,#F1F5F9)] shadow-[0_16px_40px_rgba(30,64,175,0.14)]">
            {course.thumbnailUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={course.thumbnailUrl}
                alt={course.title}
                className="h-full w-full object-cover"
              />
            ) : null}
            <div className="absolute inset-0 flex items-center justify-center bg-[rgba(11,17,32,0.25)]">
              <button
                type="button"
                aria-label="Play preview"
                className="flex h-16 w-16 items-center justify-center rounded-full bg-white/90 shadow-[0_0_32px_rgba(59,130,246,0.35)] transition-transform duration-200 ease-out hover:scale-105"
              >
                <PlayCircle size={36} className="text-[var(--blue-600,#2563EB)]" />
              </button>
            </div>
          </div>

          {course.description && (
            <p className="mt-6 text-[15px] leading-relaxed text-[var(--text-secondary,#475569)]">
              {course.description}
            </p>
          )}
        </div>

        {/* Sticky purchase card */}
        <div>
          <Card className="sticky top-24 flex flex-col gap-4">
            <div className="text-[28px] font-bold text-[var(--text-primary,#0F172A)]">
              {formatPrice(course.price, course.currency)}
            </div>
            <Button size="lg" className="w-full">
              Enroll Now
            </Button>
            <Button size="lg" variant="secondary" className="w-full">
              Add to Wishlist
            </Button>
            <div className="border-t border-[var(--border-hairline,rgba(15,23,42,0.08))] pt-4 text-[13px] text-[var(--text-secondary,#475569)]">
              Full lifetime access · Certificate on completion · 30-day refund policy
            </div>
          </Card>
        </div>
      </div>

      {/* Curriculum */}
      {curriculumItems.length > 0 && (
        <section className="mb-12">
          <h2 className="mb-4 text-[22px] font-semibold text-[var(--text-primary,#0F172A)]">
            Curriculum
          </h2>
          <Accordion items={curriculumItems} />
        </section>
      )}

      {/* Instructor bio */}
      <section className="mb-12">
        <h2 className="mb-4 text-[22px] font-semibold text-[var(--text-primary,#0F172A)]">
          About the instructor
        </h2>
        <Card className="flex flex-col gap-3 sm:flex-row sm:items-start sm:gap-6">
          <div className="flex h-16 w-16 shrink-0 items-center justify-center overflow-hidden rounded-full bg-[var(--blue-50,#EFF6FF)] text-[20px] font-semibold text-[var(--blue-600,#2563EB)]">
            {course.instructor.avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={course.instructor.avatarUrl}
                alt={course.instructor.fullName}
                className="h-full w-full object-cover"
              />
            ) : (
              course.instructor.fullName.charAt(0).toUpperCase()
            )}
          </div>
          <div>
            <h3 className="text-[16px] font-semibold text-[var(--text-primary,#0F172A)]">
              {course.instructor.fullName}
            </h3>
            <p className="mt-1 text-[13px] text-[var(--text-secondary,#475569)]">
              {course.instructorCourseCount ?? 0} courses · {(course.instructorStudentCount ?? 0).toLocaleString()} students
            </p>
            {course.instructorBio && (
              <p className="mt-3 text-[14px] leading-relaxed text-[var(--text-secondary,#475569)]">
                {course.instructorBio}
              </p>
            )}
          </div>
        </Card>
      </section>

      {/* Reviews */}
      <section className="mb-12">
        <h2 className="mb-4 text-[22px] font-semibold text-[var(--text-primary,#0F172A)]">
          Student reviews
        </h2>

        {breakdown && (
          <Card className="mb-6 flex flex-col gap-2">
            {([5, 4, 3, 2, 1] as const).map((star) => {
              const count = breakdown[star];
              const pct = totalRatings > 0 ? Math.round((count / totalRatings) * 100) : 0;
              return (
                <div key={star} className="flex items-center gap-3 text-[13px]">
                  <span className="w-10 shrink-0 text-[var(--text-secondary,#475569)]">{star} star</span>
                  <div className="h-2 flex-1 overflow-hidden rounded-full bg-[var(--surface-elevated,#F1F5F9)]">
                    <div
                      className="h-full rounded-full"
                      style={{
                        width: `${pct}%`,
                        background:
                          "linear-gradient(135deg, #2563EB 0%, #0EA5E9 50%, #22D3EE 100%)"
                      }}
                    />
                  </div>
                  <span className="w-10 shrink-0 text-right text-[var(--text-muted,#94A3B8)]">{pct}%</span>
                </div>
              );
            })}
          </Card>
        )}

        {course.reviews && course.reviews.length > 0 ? (
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            {course.reviews.map((review) => (
              <ReviewCard
                key={review.id}
                authorName={review.authorName}
                authorAvatarUrl={review.authorAvatarUrl}
                rating={review.rating}
                comment={review.comment}
                createdAt={review.createdAt}
                verifiedPurchase={review.verifiedPurchase}
              />
            ))}
          </div>
        ) : (
          <EmptyState
            icon={<Star size={22} />}
            title="No reviews yet"
            description="Be the first to leave a review after completing this course."
          />
        )}
      </section>

      {/* FAQ */}
      {faqItems.length > 0 && (
        <section className="mb-12">
          <h2 className="mb-4 flex items-center gap-2 text-[22px] font-semibold text-[var(--text-primary,#0F172A)]">
            <HelpCircle size={20} className="text-[var(--blue-500,#3B82F6)]" />
            Frequently asked questions
          </h2>
          <Accordion items={faqItems} />
        </section>
      )}

      {/* Related courses */}
      {course.relatedCourses && course.relatedCourses.length > 0 && (
        <section>
          <h2 className="mb-4 text-[22px] font-semibold text-[var(--text-primary,#0F172A)]">
            Related courses
          </h2>
          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
            {course.relatedCourses.map((related) => (
              <CourseCard
                key={related.id}
                slug={related.slug}
                title={related.title}
                thumbnailUrl={related.thumbnailUrl}
                instructorName={related.instructor.fullName}
                price={related.price}
                currency={related.currency}
                rating={related.rating}
                ratingCount={related.ratingCount}
              />
            ))}
          </div>
        </section>
      )}
    </main>
  );
}
