import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { InstructorProfileCard } from "@/components/instructor/InstructorProfileCard";
import { InstructorStatsGrid } from "@/components/instructor/InstructorStatsGrid";
import { InstructorCourseCard, type InstructorCourseCardProps } from "@/components/instructor/InstructorCourseCard";

// TODO: replace with useInstructor(slug) hook from @saachi/api-client
interface InstructorProfile {
  slug: string;
  name: string;
  title: string;
  bio: string;
  avatar: string;
  tags: string[];
  coursesCount: number;
  studentsCount: string;
  rating: number;
  reviewsCount: string;
  courses: InstructorCourseCardProps[];
}

const DUMMY_INSTRUCTORS: Record<string, InstructorProfile> = {
  "dr-sarah-chen": {
    slug: "dr-sarah-chen",
    name: "Dr. Sarah Chen",
    title: "Lead AI Architect @ Saachi AI",
    bio: "Sarah has spent the last decade building and teaching large-scale NLP systems, helping thousands of engineers level up their prompting and model-building skills.",
    avatar: "https://i.pravatar.cc/256?img=32",
    tags: ["NLP", "Prompt Engineering", "LLMs"],
    coursesCount: 6,
    studentsCount: "42.1k",
    rating: 4.9,
    reviewsCount: "8.3k",
    courses: [
      {
        title: "Prompt Engineering Masterclass",
        description: "Master the art of crafting precise instructions for large language models.",
        category: "Generative AI",
        price: "$89.99",
        rating: 4.8,
        reviews: "2.4k",
        duration: "12h",
        image:
          "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
        badge: { label: "Bestseller", variant: "light" },
      },
    ],
  },
};

function getInstructorBySlug(slug: string): InstructorProfile | null {
  return DUMMY_INSTRUCTORS[slug] ?? null;
}

interface InstructorPageProps {
  params: Promise<{ slug: string }>;
}

export default async function InstructorPage({ params }: InstructorPageProps) {
  const { slug } = await params;
  const instructor = getInstructorBySlug(slug);

  if (!instructor) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-10 px-6 py-10">
        <div className="flex flex-col gap-6 lg:flex-row">
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
        </div>

        <div className="flex flex-col gap-6">
          <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">
            Courses by {instructor.name}
          </h2>
          <div className="flex flex-wrap gap-6">
            {instructor.courses.map((course) => (
              <InstructorCourseCard key={course.title} {...course} />
            ))}
          </div>
        </div>
      </main>

      <CompactFooter />
    </div>
  );
}