import { ChevronLeft, ChevronRight } from "lucide-react";
import { Header } from "@/components/marketing/Header";
import { DetailFooter } from "@/components/course-detail/DetailFooter";
import { InstructorProfileCard } from "@/components/instructor/InstructorProfileCard";
import { InstructorStatsGrid } from "@/components/instructor/InstructorStatsGrid";
import {
  InstructorCourseCard,
  type InstructorCourseCardProps,
} from "@/components/instructor/InstructorCourseCard";

const courses: InstructorCourseCardProps[] = [
  {
    title: "Deep Learning Foundations: From Math to PyTorch",
    description: "Master the underlying mathematics of deep learning and build practical models\u2026",
    category: "Machine Learning",
    price: "$129.99",
    rating: 4.9,
    reviews: "8,241",
    duration: "32h",
    badge: { label: "Best Seller", variant: "light" },
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=800&q=80",
  },
  {
    title: "Advanced NLP with Transformers & Hugging Face",
    description: "Build state-of-the-art language models and deploy them to production environments.",
    category: "NLP",
    price: "$99.99",
    rating: 4.8,
    reviews: "4,102",
    duration: "24h",
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=800&q=80",
  },
  {
    title: "MLOps Engineering: Deploying Models at Scale",
    description: "Learn the complete lifecycle of deploying, monitoring, and maintaining machine\u2026",
    category: "MLOps",
    price: "$149.99",
    rating: 5.0,
    reviews: "128",
    duration: "40h",
    badge: { label: "New", variant: "dark" },
    image:
      "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=800&q=80",
  },
];

const instructorContent = {
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

export default function InstructorProfilePage({ params }: { params: { slug: string } }) {
  const instructor = instructorContent;

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

          <div className="flex justify-center gap-6">
            {courses.map((course) => (
              <InstructorCourseCard key={course.title} {...course} />
            ))}
          </div>
        </section>
      </main>

      <DetailFooter />
    </div>
  );
}