"use client";

import Link from "next/link";
import { Star, Users, BookOpen, MessageSquare } from "lucide-react";
import { DUMMY_COURSES } from "@saachi/api-client";
import { Button, Card, CourseCard, ReviewCard, EmptyState } from "@saachi/ui";
import { Navbar } from "../../_components/Navbar";
import { Footer } from "../../_components/Footer";

function slugifyName(name: string) {
  return name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
}

export default function InstructorProfilePage({ params }: { params: { slug: string } }) {
  const instructorCourses = DUMMY_COURSES.filter(
    (c) => slugifyName(c.instructor.fullName) === params.slug
  );

  if (instructorCourses.length === 0) {
    return (
      <>
        <Navbar />
        <main className="mx-auto max-w-[1140px] px-6 py-16">
          <EmptyState
            title="Instructor not found"
            description="This instructor profile may have been moved."
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

  const instructor = instructorCourses[0].instructor;
  const totalStudents = instructorCourses.reduce(
    (sum, c) => sum + (c.instructorStudentCount ?? 0),
    0
  );
  const avgRating =
    instructorCourses.reduce((sum, c) => sum + c.rating, 0) / instructorCourses.length;
  const allReviews = instructorCourses.flatMap((c) => c.reviews ?? []).slice(0, 4);

  return (
    <>
      <Navbar />
      <main>
        <section className="bg-paper-dim px-6 py-16">
          <div className="mx-auto flex max-w-[1140px] flex-col items-center gap-6 text-center md:flex-row md:items-start md:text-left">
            <div className="flex h-24 w-24 shrink-0 items-center justify-center overflow-hidden rounded-full border-2 border-ink bg-teal-light text-[28px] font-semibold text-teal">
              {instructor.avatarUrl ? (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={instructor.avatarUrl} alt={instructor.fullName} className="h-full w-full object-cover" />
              ) : (
                instructor.fullName.charAt(0)
              )}
            </div>
            <div className="flex-1">
              <h1 className="font-display text-[30px] font-semibold text-ink">{instructor.fullName}</h1>
              <p className="mt-2 max-w-[560px] text-[15px] leading-relaxed text-ink-soft">
                {instructorCourses[0].instructorBio ?? "Practical AI practitioner and instructor on Saachi AI."}
              </p>
              <div className="mt-4 flex flex-wrap justify-center gap-6 text-[13px] text-ink-soft md:justify-start">
                <span className="flex items-center gap-1.5">
                  <Users size={15} /> {totalStudents.toLocaleString()} students
                </span>
                <span className="flex items-center gap-1.5">
                  <BookOpen size={15} /> {instructorCourses.length} courses
                </span>
                <span className="flex items-center gap-1.5">
                  <Star size={15} className="fill-gold text-gold" /> {avgRating.toFixed(1)} average rating
                </span>
              </div>
              <Link href="/login" className="mt-5 inline-block">
                <Button size="sm" variant="secondary">
                  <MessageSquare size={15} /> Message instructor
                </Button>
              </Link>
            </div>
          </div>
        </section>

        <section className="px-6 py-16">
          <div className="mx-auto max-w-[1140px]">
            <h2 className="mb-6 font-display text-[22px] font-semibold text-ink">Courses by {instructor.fullName}</h2>
            <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 xl:grid-cols-3">
              {instructorCourses.map((course) => (
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

            {allReviews.length > 0 && (
              <div className="mt-14">
                <h2 className="mb-6 font-display text-[22px] font-semibold text-ink">
                  What students say
                </h2>
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  {allReviews.map((review) => (
                    <ReviewCard key={review.id} {...review} />
                  ))}
                </div>
              </div>
            )}
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}