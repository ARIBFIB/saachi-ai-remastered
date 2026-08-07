"use client";

import { useState } from "react";
import Link from "next/link";
import { Star, Clock, PlayCircle, CheckCircle2, Globe, BarChart3, Heart, ShoppingCart } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import {
  Button,
  Card,
  Badge,
  Accordion,
  ReviewCard,
  CourseCard,
  SkeletonText,
  EmptyState
} from "@saachi/ui";
import { formatDuration } from "@saachi/utils";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { Navbar } from "../../_components/Navbar";
import { Footer } from "../../_components/Footer";

export default function CourseDetailPage({ params }: { params: { slug: string } }) {
  const { data: course, isLoading, isError } = useCourseDetail(params.slug);
  const [justAdded, setJustAdded] = useState(false);

  const cart = useCartStore();
  const wishlist = useWishlistStore();

  if (isLoading) {
    return (
      <>
        <Navbar />
        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <SkeletonText lines={4} />
        </main>
        <Footer />
      </>
    );
  }

  if (isError || !course) {
    return (
      <>
        <Navbar />
        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <EmptyState
            title="Course not found"
            description="This course may have been moved or is no longer available."
            action={
              <Link href="/courses">
                <Button>Browse courses</Button>
              </Link>
            }
          />
        </main>
        <Footer />
      </>
    );
  }

  const formattedPrice = new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: course.currency,
    minimumFractionDigits: course.price % 1 === 0 ? 0 : 2
  }).format(course.price);

  const inCart = cart.isInCart(course.id);
  const wishlisted = wishlist.isWishlisted(course.id);

  const handleAddToCart = () => {
    cart.addItem({
      courseId: course.id,
      slug: course.slug,
      title: course.title,
      thumbnailUrl: course.thumbnailUrl,
      instructorName: course.instructor.fullName,
      price: course.price,
      currency: course.currency
    });
    setJustAdded(true);
  };

  const handleToggleWishlist = () => {
    wishlist.toggle({
      courseId: course.id,
      slug: course.slug,
      title: course.title,
      thumbnailUrl: course.thumbnailUrl,
      instructorName: course.instructor.fullName,
      price: course.price,
      currency: course.currency,
      rating: course.rating,
      ratingCount: course.ratingCount
    });
  };

  const curriculumItems = (course.curriculum ?? []).map((mod) => ({
    id: mod.id,
    title: mod.title,
    meta: <span className="text-[12px] text-ink-soft/60">{mod.lessons.length} lessons</span>,
    content: (
      <ul className="flex flex-col gap-2">
        {mod.lessons.map((lesson) => (
          <li key={lesson.id} className="flex items-center justify-between text-[14px] text-ink">
            <span className="flex items-center gap-2">
              <PlayCircle size={15} className="text-ink-soft" />
              {lesson.title}
              {lesson.isPreview && <Badge variant="gold">Preview</Badge>}
            </span>
            {lesson.durationSeconds && (
              <span className="text-[12px] text-ink-soft/60">{formatDuration(lesson.durationSeconds)}</span>
            )}
          </li>
        ))}
      </ul>
    )
  }));

  const faqItems = (course.faq ?? []).map((item) => ({
    id: item.id,
    title: item.question,
    content: item.answer
  }));

  return (
    <>
      <Navbar />
      <main className="mx-auto max-w-[1140px] px-6 py-12">
        <div className="grid grid-cols-1 gap-10 lg:grid-cols-[1fr_360px]">
          <div>
            <div className="mb-3 flex flex-wrap items-center gap-2">
              <Badge variant="gold">{course.status === "published" ? "Published" : course.status}</Badge>
              <span className="flex items-center gap-1 text-[13px] text-ink-soft">
                <Star size={14} className="fill-gold text-gold" />
                <strong className="text-ink">{course.rating.toFixed(1)}</strong>
                ({course.ratingCount.toLocaleString()} ratings)
              </span>
            </div>

            <h1 className="font-display text-[32px] font-semibold leading-tight text-ink md:text-[40px]">
              {course.title}
            </h1>
            {course.subtitle && (
              <p className="mt-3 text-[16px] leading-relaxed text-ink-soft">{course.subtitle}</p>
            )}

            <div className="mt-6 flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[14px] font-semibold text-teal">
                {course.instructor.avatarUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.instructor.avatarUrl} alt={course.instructor.fullName} className="h-full w-full object-cover" />
                ) : (
                  course.instructor.fullName.charAt(0)
                )}
              </div>
              <div>
                <div className="text-[14px] font-semibold text-ink">{course.instructor.fullName}</div>
                <div className="text-[12px] text-ink-soft">
                  {course.instructorCourseCount ?? 1} courses &middot;{" "}
                  {(course.instructorStudentCount ?? 0).toLocaleString()} students
                </div>
              </div>
            </div>

            {course.description && (
              <div className="mt-8">
                <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">About this course</h2>
                <p className="whitespace-pre-line text-[15px] leading-relaxed text-ink-soft">
                  {course.description}
                </p>
              </div>
            )}

            {curriculumItems.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">Curriculum</h2>
                <Accordion items={curriculumItems} defaultOpenId={curriculumItems[0]?.id} />
              </div>
            )}

            {course.reviews && course.reviews.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Reviews</h2>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  {course.reviews.map((review) => (
                    <ReviewCard key={review.id} {...review} />
                  ))}
                </div>
              </div>
            )}

            {faqItems.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-3 font-display text-[20px] font-semibold text-ink">FAQ</h2>
                <Accordion items={faqItems} />
              </div>
            )}

            {course.relatedCourses && course.relatedCourses.length > 0 && (
              <div className="mt-10">
                <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Related courses</h2>
                <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
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
              </div>
            )}
          </div>

          <div className="lg:sticky lg:top-24 lg:self-start">
            <Card className="p-6">
              <div className="mb-4 aspect-video w-full overflow-hidden rounded-control bg-paper-dim">
                {course.thumbnailUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.thumbnailUrl} alt={course.title} className="h-full w-full object-cover" />
                ) : (
                  <div className="flex h-full w-full items-center justify-center text-[13px] text-ink-soft/60">
                    No preview
                  </div>
                )}
              </div>

              <div className="mb-5 flex items-center justify-between">
                <span className="font-mono text-[28px] font-semibold text-ink">{formattedPrice}</span>
                <button
                  type="button"
                  onClick={handleToggleWishlist}
                  aria-label="Toggle wishlist"
                  className="flex h-10 w-10 items-center justify-center rounded-full border border-line-strong text-ink-soft transition-colors duration-150 ease-out hover:border-error hover:text-error"
                >
                  <Heart size={18} className={wishlisted ? "fill-error text-error" : ""} />
                </button>
              </div>

              {inCart || justAdded ? (
                <div className="flex flex-col gap-2">
                  <div className="flex items-center gap-2 rounded-control bg-teal-light px-4 py-3 text-[14px] font-semibold text-teal">
                    <CheckCircle2 size={18} /> In your cart
                  </div>
                  <Link href="/cart">
                    <Button size="lg" variant="secondary" className="w-full">
                      <ShoppingCart size={17} /> Go to cart
                    </Button>
                  </Link>
                </div>
              ) : (
                <Button size="lg" className="w-full" onClick={handleAddToCart}>
                  <ShoppingCart size={17} /> Add to cart
                </Button>
              )}

              <ul className="mt-6 flex flex-col gap-3 text-[13px] text-ink-soft">
                <li className="flex items-center gap-2">
                  <Globe size={15} /> Language: English
                </li>
                <li className="flex items-center gap-2">
                  <BarChart3 size={15} /> Level: All levels
                </li>
                <li className="flex items-center gap-2">
                  <Clock size={15} /> Lifetime access
                </li>
              </ul>
            </Card>
          </div>
        </div>
      </main>
      <Footer />
    </>
  );
}