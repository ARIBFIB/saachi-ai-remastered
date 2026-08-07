"use client";

import { ReviewCard } from "@saachi/ui";
import { DUMMY_COURSES } from "@saachi/api-client";

export default function InstructorReviewsPage() {
  const allReviews = DUMMY_COURSES.flatMap((c) =>
    (c.reviews ?? []).map((r) => ({ ...r, courseTitle: c.title }))
  );

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Reviews</h1>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        {allReviews.map((review) => (
          <div key={review.id}>
            <p className="mb-2 text-[12px] font-semibold uppercase tracking-[0.04em] text-gold-dark">
              {review.courseTitle}
            </p>
            <ReviewCard {...review} />
          </div>
        ))}
      </div>
    </main>
  );
}