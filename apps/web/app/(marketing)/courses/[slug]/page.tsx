"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { Star, Clock, BarChart3, Globe2, PlayCircle, CheckCircle2, ChevronDown } from "lucide-react";
import { useCourseDetailDemo } from "@saachi/api-client";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { Button, Loading, EmptyState, Badge } from "@saachi/ui";

export default function CourseDetailPage() {
  const params = useParams<{ slug: string }>();
  const router = useRouter();
  const { data: course, isLoading } = useCourseDetailDemo(params.slug);
  const addToCart = useCartStore((s) => s.addItem);
  const addToWishlist = useWishlistStore((s) => s.toggle);
  const [openModuleId, setOpenModuleId] = useState<string | null>(null);

  if (isLoading) {
    return (
      <div className="mx-auto max-w-7xl px-4 py-16 md:px-8">
        <Loading label="Loading course..." />
      </div>
    );
  }

  if (!course) {
    return (
      <div className="mx-auto max-w-7xl px-4 py-16 md:px-8">
        <EmptyState
          title="Course not found"
          description="This course may have been removed or the link is incorrect."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      </div>
    );
  }

  const handleAddToCart = () => {
    addToCart({
      courseId: course.id,
      slug: course.slug,
      title: course.title,
      thumbnailUrl: course.thumbnailUrl,
      instructorName: course.instructor.fullName,
      price: course.price,
      currency: course.currency
    });
  };

  const handleBuyNow = () => {
    handleAddToCart();
    router.push("/checkout");
  };

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      <div className="grid grid-cols-1 gap-10 lg:grid-cols-[1fr_360px]">
        <div>
          {/* Hero */}
          <p className="mb-2 text-[13px] font-medium text-gold-dark">{course.categoryName ?? "Course"}</p>
          <h1 className="mb-3 font-display text-[28px] font-bold leading-tight text-ink md:text-[36px]">
            {course.title}
          </h1>
          {course.subtitle && <p className="mb-4 text-[15px] text-ink-soft">{course.subtitle}</p>}

          <div className="mb-6 flex flex-wrap items-center gap-4 text-[13px] text-ink-soft">
            <span className="flex items-center gap-1.5">
              <Star size={14} className="text-gold-dark" fill="currentColor" />
              <span className="font-semibold text-ink">{course.rating?.toFixed(1) ?? "New"}</span>
              {course.ratingCount ? <span>({course.ratingCount} ratings)</span> : null}
            </span>
            <span className="flex items-center gap-1.5">
              <BarChart3 size={14} /> {course.level}
            </span>
            <span className="flex items-center gap-1.5">
              <Globe2 size={14} /> {course.language === "ur" ? "Urdu" : "English"}
            </span>
            {course.durationMinutes ? (
              <span className="flex items-center gap-1.5">
                <Clock size={14} /> {Math.round(course.durationMinutes / 60)}h total
              </span>
            ) : null}
          </div>

          <p className="mb-8 text-[13px] text-ink-soft">
            Created by{" "}
            <Link href={`/instructors/${course.instructor.slug}`} className="font-semibold text-gold-dark hover:underline">
              {course.instructor.fullName}
            </Link>
          </p>

          {/* Preview video / thumbnail */}
          <div className="mb-10 aspect-video w-full overflow-hidden rounded-card border border-line bg-paper-dim">
            {course.thumbnailUrl && (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={course.thumbnailUrl} alt={course.title} className="h-full w-full object-cover" />
            )}
          </div>

          {/* Curriculum */}
          <section className="mb-10">
            <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Curriculum</h2>
            {!course.modules || course.modules.length === 0 ? (
              <p className="text-[14px] text-ink-soft">Curriculum will be published soon.</p>
            ) : (
              <div className="flex flex-col gap-2">
                {course.modules.map((m) => (
                  <div key={m.id} className="overflow-hidden rounded-card border border-line bg-card">
                    <button
                      type="button"
                      onClick={() => setOpenModuleId((prev) => (prev === m.id ? null : m.id))}
                      className="flex w-full items-center justify-between px-4 py-3.5 text-left"
                    >
                      <span className="text-[14px] font-semibold text-ink">{m.title}</span>
                      <ChevronDown
                        size={16}
                        className={`shrink-0 text-ink-soft transition-transform ${openModuleId === m.id ? "rotate-180" : ""}`}
                      />
                    </button>
                    {openModuleId === m.id && (
                      <ul className="flex flex-col gap-1 border-t border-line px-4 py-3">
                        {m.lessons.map((l) => (
                          <li key={l.id} className="flex items-center gap-2.5 py-1.5 text-[13px] text-ink-soft">
                            <PlayCircle size={14} className="shrink-0" />
                            {l.title}
                          </li>
                        ))}
                      </ul>
                    )}
                  </div>
                ))}
              </div>
            )}
          </section>

          {/* Instructor bio */}
          <section className="mb-10">
            <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">About the instructor</h2>
            <div className="flex items-start gap-4 rounded-card border border-line bg-card p-5">
              <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-full border border-line bg-paper-dim text-[18px] font-semibold text-ink-soft">
                {course.instructor.fullName.charAt(0)}
              </div>
              <div>
                <Link href={`/instructors/${course.instructor.slug}`} className="text-[15px] font-semibold text-ink hover:underline">
                  {course.instructor.fullName}
                </Link>
                {course.instructor.bio && <p className="mt-1.5 text-[13.5px] leading-relaxed text-ink-soft">{course.instructor.bio}</p>}
              </div>
            </div>
          </section>

          {/* Reviews */}
          <section>
            <h2 className="mb-4 font-display text-[20px] font-semibold text-ink">Reviews</h2>
            {!course.reviews || course.reviews.length === 0 ? (
              <p className="text-[14px] text-ink-soft">No reviews yet.</p>
            ) : (
              <div className="flex flex-col gap-4">
                {course.reviews.map((r) => (
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

        {/* Sticky purchase card */}
        <aside className="h-fit rounded-card border border-line bg-card p-6 lg:sticky lg:top-24">
          <p className="mb-4 font-mono text-[28px] font-bold text-ink">
            {new Intl.NumberFormat("en-US", { style: "currency", currency: course.currency }).format(course.price)}
          </p>
          <div className="flex flex-col gap-2.5">
            <Button size="lg" className="w-full" onClick={handleBuyNow}>
              Buy now
            </Button>
            <Button size="lg" variant="secondary" className="w-full" onClick={handleAddToCart}>
              Add to cart
            </Button>
            <Button
              size="sm"
              variant="ghost"
              className="w-full"
              onClick={() =>
                addToWishlist({
                  courseId: course.id,
                  slug: course.slug,
                  title: course.title,
                  thumbnailUrl: course.thumbnailUrl,
                  instructorName: course.instructor.fullName,
                  price: course.price,
                  currency: course.currency,
                  rating: course.rating ?? 0,
                  ratingCount: course.ratingCount ?? 0
                })
              }
            >
              Add to wishlist
            </Button>
          </div>

          <ul className="mt-6 flex flex-col gap-2 text-[13px] text-ink-soft">
            <li className="flex items-center gap-2">
              <CheckCircle2 size={14} className="text-teal" /> Full lifetime access
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle2 size={14} className="text-teal" /> Certificate of completion
            </li>
            <li className="flex items-center gap-2">
              <CheckCircle2 size={14} className="text-teal" /> Access on mobile and desktop
            </li>
          </ul>

          {course.categoryName && (
            <div className="mt-6 border-t border-line pt-4">
              <Badge>{course.categoryName}</Badge>
            </div>
          )}
        </aside>
      </div>
    </div>
  );
}