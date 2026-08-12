import { ChevronLeft, ChevronRight } from "lucide-react";
import { Header } from "@/components/marketing/Header";
import { DetailFooter } from "@/components/course-detail/DetailFooter";
import { InstructorProfileCard } from "@/components/instructor/InstructorProfileCard";
import { InstructorStatsGrid } from "@/components/instructor/InstructorStatsGrid";
import {
  InstructorCourseCard,
  type InstructorCourseCardProps,
} from "@/components/instructor/InstructorCourseCard";
import { findInstructorBySlug, courseDurationLabel } from "@/lib/instructor-lookup";

const fallbackInstructor = {
  name: "Dr. Sarah Chen",
  title: "Senior AI Researcher & Lead Educator",
  bio: "Former Lead AI Researcher at TechGlobal with 10+ years of experience in deploying scalable machine learning models. I specialize in breaking down complex neural network architectures into digestible, practical lessons for working professionals. Passionate about ethical AI and real-world applications.",
  avatar:
    "https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=240&q=80",
  tags: ["Machine Learning", "Neural Networks", "Data Science"],
  coursesCount: 14,
  studentsCount: "125k+",
  rating: 4.9,
  reviewsCount: "15k",
};

interface InstructorProfilePageProps {
  params: Promise<{ slug: string }>;
}

export default async function InstructorProfilePage({ params }: InstructorProfilePageProps) {
  const { slug } = await params;
  const found = findInstructorBySlug(slug);

  const instructor = found
    ? {
        name: found.fullName,
        title: "Instructor",
        bio: found.bio || fallbackInstructor.bio,
        avatar: found.avatarUrl ?? fallbackInstructor.avatar,
        tags: fallbackInstructor.tags,
        coursesCount: found.courses.length,
        studentsCount: `${found.courses.reduce((sum, c) => sum + (c.instructorStudentCount ?? 0), 0).toLocaleString()}+`,
        rating:
          found.courses.length > 0
            ? Math.round((found.courses.reduce((sum, c) => sum + c.rating, 0) / found.courses.length) * 10) / 10
            : fallbackInstructor.rating,
        reviewsCount: found.courses.reduce((sum, c) => sum + c.ratingCount, 0).toLocaleString(),
      }
    : fallbackInstructor;

  const courses: InstructorCourseCardProps[] = found
    ? found.courses.map((c) => ({
        title: c.title,
        description: c.subtitle ?? "",
        category: c.categoryId,
        price: `$${c.price.toFixed(2)}`,
        rating: c.rating,
        reviews: c.ratingCount.toLocaleString(),
        duration: courseDurationLabel(c),
        image: c.thumbnailUrl ?? "https://placehold.co/800x450",
      }))
    : [];

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-10 px-12 py-10">
        <section className="flex items-stretch gap-6">
          <InstructorProfileCard
            name={instructor.name}
            title={instructor.title}
            bio={instructor.bio}
            avatar={instructor.avatar}
            tags={instructor.tags}
          />
          <InstructorStatsGrid
            coursesCount={instructor.coursesCount}
            studentsCount={instructor.studentsCount}
            rating={instructor.rating}
            reviewsCount={instructor.reviewsCount}
          />
        </section>

        <section className="flex flex-col gap-6">
          <div className="flex items-end justify-between">
            <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">
              More Courses by {instructor.name.split(" ").slice(-1)}
            </h2>
            <div className="flex gap-2">
              <button
                type="button"
                aria-label="Previous"
                className="flex h-10 w-8 items-center justify-center rounded-lg border border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
              >
                <ChevronLeft className="h-3 w-3" />
              </button>
              <button
                type="button"
                aria-label="Next"
                className="flex h-10 w-8 items-center justify-center rounded-lg border border-[var(--token-color-border)] text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
              >
                <ChevronRight className="h-3 w-3" />
              </button>
            </div>
          </div>

          {courses.length > 0 ? (
            <div className="flex flex-wrap justify-center gap-6">
              {courses.map((course) => (
                <InstructorCourseCard key={course.title} {...course} />
              ))}
            </div>
          ) : (
            <p style={{ color: "var(--token-color-inkSoft)" }}>
              This instructor has not published any courses yet.
            </p>
          )}
        </section>
      </main>

      <DetailFooter />
    </div>
  );
}