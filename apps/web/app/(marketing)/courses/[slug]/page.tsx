"use client";

import { useParams } from "next/navigation";
import { Star, PlayCircle, FileText, HelpCircle, Paperclip } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { Accordion, Badge, Button, CourseCard, Loading, ReviewCard } from "@saachi/ui";

const LESSON_ICON = {
  video: PlayCircle,
  text: FileText,
  quiz: HelpCircle,
  resource: Paperclip
} as const;

export default function CourseDetailPage() {
  const params = useParams<{ slug: string }>();
  const { data: course, isLoading } = useCourseDetail(params.slug);
  const addToCart = useCartStore((s) => s.addItem);
  const isInCart = useCartStore((s) => s.isInCart);
  const toggleWishlist = useWishlistStore((s) => s.toggle);
  const isWishlisted = useWishlistStore((s) => s.isWishlisted);

  if (isLoading || !course) {
    return <Loading fullScreen label="Loading course..." />;
  }

  const inCart = isInCart(course.id);
  const wishlisted = isWishlisted(course.id);

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      <div className="grid grid-cols-1 gap-10 lg:grid-cols-[1fr_360px]">
        <div>
          {/* Hero */}
          <Badge variant="gold">{course.status === "published" ? "Published course" : course.status}</Badge>
          <h1 className="mt-3 font-display text-[30px] font-bold leading-tight text-ink">{course.title}</h1>
          {course.subtitle && <p className="mt-2 text-[16px] text-ink-soft">{course.subtitle}</p>}

          <div className="mt-4 flex flex-wrap items-center gap-4 text-[14px] text-ink-soft">
            <span className="flex items-center gap-1.5">
              <Star size={15} className="fill-gold text-gold" />
              <span className="font-semibold text-ink">{course.rating.toFixed(1)}</span>
              <span>({course.ratingCount.toLocaleString()} ratings)</span>
            </span>
            <span>By {course.instructor.fullName}</span>
          </div>

          {course.thumbnailUrl && (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={course.thumbnailUrl}
              alt={course.title}
              className="mt-6 aspect-video w-full rounded-card object-cover"
            />
          )}

          {course.description && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">About this course</h2>
              <p className="leading-relaxed text-ink-soft">{course.description}</p>
            </section>
          )}

          {course.curriculum && course.curriculum.length > 0 && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">Curriculum</h2>
              <Accordion
                items={course.curriculum.map((mod) => ({
                  id: mod.id,
                  title: mod.title,
                  meta: <span className="text-[12px] text-ink-soft">{mod.lessons.length} lessons</span>,
                  content: (
                    <ul className="flex flex-col gap-2">
                      {mod.lessons.map((lesson) => {
                        const Icon = LESSON_ICON[lesson.type];
                        return (
                          <li key={lesson.id} className="flex items-center gap-2 text-[14px] text-ink">
                            <Icon size={15} className="text-ink-soft" />
                            {lesson.title}
                            {lesson.isPreview && (
                              <span className="ml-1 text-[12px] font-semibold text-gold-dark">Preview</span>
                            )}
                          </li>
                        );
                      })}
                    </ul>
                  )
                }))}
              />
            </section>
          )}

          {course.instructorBio && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">About the instructor</h2>
              <div className="rounded-card border border-line bg-card p-5">
                <h3 className="font-semibold text-ink">{course.instructor.fullName}</h3>
                <p className="mt-2 text-[14px] text-ink-soft">{course.instructorBio}</p>
                <p className="mt-2 text-[13px] text-ink-soft/70">
                  {course.instructorCourseCount ?? 0} courses - {(course.instructorStudentCount ?? 0).toLocaleString()} students
                </p>
              </div>
            </section>
          )}

          {course.reviews && course.reviews.length > 0 && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">Reviews</h2>
              <div className="flex flex-col gap-4">
                {course.reviews.map((review) => (
                  <ReviewCard key={review.id} {...review} />
                ))}
              </div>
            </section>
          )}

          {course.faq && course.faq.length > 0 && (
            <section className="mt-10">
              <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">FAQ</h2>
              <Accordion
                items={course.faq.map((item) => ({ id: item.id, title: item.question, content: item.answer }))}
              />
            </section>
          )}

          {course.relatedCourses && course.relatedCourses.length > 0 && (
            <section className="mt-10">
              <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Related courses</h2>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2">
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
        </div>

        {/* Sticky purchase card */}
        <aside className="h-fit rounded-card border border-line bg-card p-6 lg:sticky lg:top-24">
          <div className="font-mono text-[28px] font-bold text-ink">
            {new Intl.NumberFormat("en-US", { style: "currency", currency: course.currency }).format(course.price)}
          </div>
          <Button
            className="mt-5 w-full"
            size="lg"
            onClick={() =>
              addToCart({
                courseId: course.id,
                slug: course.slug,
                title: course.title,
                thumbnailUrl: course.thumbnailUrl,
                instructorName: course.instructor.fullName,
                price: course.price,
                currency: course.currency
              })
            }
          >
            {inCart ? "Added to cart" : "Add to cart"}
          </Button>
          <Button
            className="mt-3 w-full"
            size="lg"
            variant="secondary"
            onClick={() =>
              toggleWishlist({
                courseId: course.id,
                slug: course.slug,
                title: course.title,
                thumbnailUrl: course.thumbnailUrl,
                instructorName: course.instructor.fullName,
                price: course.price,
                currency: course.currency,
                rating: course.rating,
                ratingCount: course.ratingCount
              })
            }
          >
            {wishlisted ? "Remove from wishlist" : "Add to wishlist"}
          </Button>
        </aside>
      </div>
    </div>
  );
}