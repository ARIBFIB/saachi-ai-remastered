import Link from "next/link";
import { ArrowRight } from "lucide-react";
import { CourseCard, type CourseCardProps } from "./CourseCard";
import { SpecLabel } from "./BlueprintMark";

const courses: CourseCardProps[] = [
  {
    title: "AI Ethics & Responsible Deployment",
    instructor: "Dr. Sarah Jenkins",
    rating: 4.9,
    reviews: "2.4k",
    tag: "Foundational",
    image: "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Mastering Prompt Engineering",
    instructor: "Alex Chen",
    rating: 4.8,
    reviews: "8.1k",
    tag: "Bestseller",
    image: "https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Generative AI & Digital Art",
    instructor: "Elena Rodriguez",
    rating: 4.7,
    reviews: "1.2k",
    tag: "Creative",
    image: "https://images.unsplash.com/photo-1550439062-609e1531270e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "LLM Ops & Production Deployment",
    instructor: "David Kim, PhD",
    rating: 4.9,
    reviews: "940",
    tag: "Advanced",
    image: "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
];

export function TrendingCourses() {
  return (
    <section className="w-full py-16" style={{ backgroundColor: "var(--token-color-bg)" }}>
      <div className="mx-auto flex max-w-[1280px] flex-col gap-10 px-6">
        <div className="flex items-end justify-between">
          <div className="flex flex-col gap-3">
            <SpecLabel index="02" label="Trending" />
            <h2
              className="text-3xl font-semibold"
              style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
            >
              Courses learners are shipping right now
            </h2>
          </div>
          <Link
            href="/courses"
            className="flex items-center gap-1 text-sm font-semibold tracking-wide"
            style={{ color: "var(--token-color-teal)" }}
          >
            View all
            <ArrowRight className="h-3 w-3" />
          </Link>
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {courses.map((course) => (
            <CourseCard key={course.title} {...course} />
          ))}
        </div>
      </div>
    </section>
  );
}