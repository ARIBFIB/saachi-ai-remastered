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
    image: "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Mastering Prompt Engineering",
    instructor: "Alex Chen",
    rating: 4.8,
    reviews: "8.1k",
    tag: "Bestseller",
    tagVariant: "highlight",
    image: "https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Generative AI & Digital Art",
    instructor: "Elena Rodriguez",
    rating: 4.7,
    reviews: "1.2k",
    tag: "Creative",
    tagVariant: "default",
    image: "https://images.unsplash.com/photo-1550439062-609e1531270e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "LLM Ops & Deploymentâ€¦",
    instructor: "David Kim, PhD",
    rating: 4.9,
    reviews: "940",
    tag: "Advanced",
    tagVariant: "neutral",
    image: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
];

export function TrendingCourses() {
  return (
    <section className="w-full bg-[#F8FAFC] py-12">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="flex items-end justify-between">
          <div className="flex flex-col gap-1">
            <h2 className="text-2xl font-semibold text-[#18181B]">
              Trending Courses
            </h2>
            <p className="text-base text-[#3F3F46]">
              Highly rated programs to start your journey.
            </p>
          </div>
          <Link
            href="/courses"
            className="flex items-center gap-1 text-sm font-semibold tracking-wide text-[#3525CD]"
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
