import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { DetailFooter } from "@/components/course-detail/DetailFooter";
import { CourseHero } from "@/components/course-detail/CourseHero";
import { WhatYoullLearn } from "@/components/course-detail/WhatYoullLearn";
import { CourseCurriculum } from "@/components/course-detail/CourseCurriculum";
import { InstructorBio } from "@/components/course-detail/InstructorBio";
import { PurchaseCard } from "@/components/course-detail/PurchaseCard";

// TODO: replace with useCourse(slug) hook from @saachi/api-client
interface CourseDetail {
  slug: string;
  category: string;
  levelBadge: string;
  title: string;
  description: string;
  rating: number;
  ratingsCount: string;
  studentsCount: string;
  instructorName: string;
  instructorAvatar: string;
  instructorTitle: string;
  instructorBio: string;
  previewImage: string;
  price: string;
  includes: string[];
}

const DUMMY_COURSE_DETAILS: Record<string, CourseDetail> = {
  "prompt-engineering-masterclass": {
    slug: "prompt-engineering-masterclass",
    category: "Generative AI",
    levelBadge: "Intermediate",
    title: "Prompt Engineering Masterclass",
    description:
      "Master the art of crafting precise instructions for large language models, from zero-shot prompting to advanced chain-of-thought reasoning.",
    rating: 4.8,
    ratingsCount: "2.4k",
    studentsCount: "18,204",
    instructorName: "Dr. Sarah Chen",
    instructorAvatar: "https://i.pravatar.cc/128?img=32",
    instructorTitle: "Lead AI Architect",
    instructorBio:
      "Sarah has spent the last decade building and teaching large-scale NLP systems, and has helped thousands of engineers level up their prompting skills.",
    previewImage:
      "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=1200&q=80",
    price: "$89.99",
    includes: ["12 hours on-demand video", "Downloadable resources", "Certificate of completion"],
  },
};

function getCourseBySlug(slug: string): CourseDetail | null {
  return DUMMY_COURSE_DETAILS[slug] ?? null;
}

interface CourseDetailPageProps {
  params: Promise<{ slug: string }>;
}

export default async function CourseDetailPage({ params }: CourseDetailPageProps) {
  const { slug } = await params;
  const course = getCourseBySlug(slug);

  if (!course) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <CourseHero
        category={course.category}
        levelBadge={course.levelBadge}
        title={course.title}
        description={course.description}
        rating={course.rating}
        ratingsCount={course.ratingsCount}
        studentsCount={course.studentsCount}
        instructorName={course.instructorName}
        instructorAvatar={course.instructorAvatar}
        previewImage={course.previewImage}
      />

      <main className="mx-auto flex w-full max-w-[1280px] flex-col gap-6 px-6 py-12 lg:flex-row lg:items-start">
        <div className="flex flex-1 flex-col gap-6">
          <WhatYoullLearn />
          <CourseCurriculum />
          <InstructorBio
            name={course.instructorName}
            title={course.instructorTitle}
            rating={course.rating}
            studentsCount={course.studentsCount}
            bio={course.instructorBio}
            avatar={course.instructorAvatar}
          />
        </div>

        <div className="w-full lg:w-80">
          <PurchaseCard price={course.price} includes={course.includes} />
        </div>
      </main>

      <DetailFooter />
    </div>
  );
}