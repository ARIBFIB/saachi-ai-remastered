import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { CourseCard, type CourseCardProps } from "./CourseCard";

const courses: CourseCardProps[] = [
  {
    title: "AI Ethics & Responsibleâ€¦",
    instructor: "Dr. Sarah Jenkins",
    rating: 4.9,
    reviews: "2.4k",
    tag: "Foundational",
    tagVariant: "default",
    image: "https://placehold.co/288x160",
  },
  {
    title: "Mastering Prompt Engineering",
    instructor: "Alex Chen",
    rating: 4.8,
    reviews: "8.1k",
    tag: "Bestseller",
    tagVariant: "highlight",
    image: "https://placehold.co/288x160",
  },
  {
    title: "Generative AI & Digital Art",
    instructor: "Elena Rodriguez",
    rating: 4.7,
    reviews: "1.2k",
    tag: "Creative",
    tagVariant: "default",
    image: "https://placehold.co/288x160",
  },
  {
    title: "LLM Ops & Deploymentâ€¦",
    instructor: "David Kim, PhD",
    rating: 4.9,
    reviews: "940",
    tag: "Advanced",
    tagVariant: "neutral",
    image: "https://placehold.co/288x160",
  },
];

export function TrendingCourses() {
  return (
    <section className="w-full bg-[var(--token-color-bg)] py-12">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="flex items-end justify-between">
          <div className="flex flex-col gap-1">
            <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">
              Trending Courses
            </h2>
            <p className="text-base text-[var(--token-color-inkSoft)]">
              Highly rated programs to start your journey.
            </p>
          </div>
          <Link
            href="/courses"
            className="flex items-center gap-1 text-sm font-semibold tracking-wide text-[var(--token-color-primary)]"
          >
            View all
            <ArrowRight className="h-3 w-3" />
          </Link>
        </div>

        <div className="flex justify-center gap-6">
          {courses.map((course) => (
            <CourseCard key={course.title} {...course} />
          ))}
        </div>
      </div>
    </section>
  );
}
