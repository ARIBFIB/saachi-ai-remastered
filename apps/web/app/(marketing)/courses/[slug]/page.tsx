import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { DetailFooter } from "@/components/course-detail/DetailFooter";
import { CourseHero } from "@/components/course-detail/CourseHero";
import { WhatYoullLearn } from "@/components/course-detail/WhatYoullLearn";
import { CourseCurriculum } from "@/components/course-detail/CourseCurriculum";
import { InstructorBio } from "@/components/course-detail/InstructorBio";
import { PurchaseCard } from "@/components/course-detail/PurchaseCard";

// TODO: replace with useCourseDetail(slug) hook from @saachi/api-client
interface CourseDetailData {
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

const DUMMY_COURSES: Record<string, CourseDetailData> = {
  "prompt-engineering-masterclass": {
    slug: "prompt-engineering-masterclass",
    category: "Prompt Engineering",
    levelBadge: "Intermediate",
    title: "Prompt Engineering Masterclass",
    description:
      "Master the art of crafting precise instructions for large language models -- from zero-shot prompting to advanced chain-of-thought reasoning.",
    rating: 4.8,
    ratingsCount: "3.2k",
    studentsCount: "18,400",
    instructorName: "Dr. Sarah Chen",
    instructorAvatar: "https://i.pravatar.cc/128?img=32",
    instructorTitle: "Lead AI Architect",
    instructorBio:
      "Sarah has spent the last 6 years building production LLM systems and has taught prompt engineering to over 20,000 students worldwide.",
    previewImage:
      "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=800&q=80",
    price: "$89.99",
    includes: ["8 hours on-demand video", "Downloadable resources", "Certificate of completion"],
  },
  "whatsapp-ai-auto-responder": {
    slug: "whatsapp-ai-auto-responder",
    category: "AI Automation",
    levelBadge: "Intermediate",
    title: "WhatsApp AI Auto-Responder for Small Business",
    description:
      "Build a working AI-powered WhatsApp auto-responder from scratch using n8n and an LLM API -- ship a real automation, not just a demo.",
    rating: 4.9,
    ratingsCount: "940",
    studentsCount: "6,100",
    instructorName: "Marcus Johnson",
    instructorAvatar: "https://i.pravatar.cc/128?img=13",
    instructorTitle: "Automation Engineer",
    instructorBio:
      "Marcus builds automation systems for small businesses across South Asia and has shipped over 40 production WhatsApp bots.",
    previewImage:
      "https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=800&q=80",
    price: "Rs 4,999",
    includes: ["6h 40m on-demand video", "Starter n8n workflow file", "Certificate of completion"],
  },
};

interface CoursePageProps {
  params: Promise<{ slug: string }>;
}

export default async function CourseDetailPage({ params }: CoursePageProps) {
  const { slug } = await params;
  const course = DUMMY_COURSES[slug];

  if (!course) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-white">
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

      <main className="mx-auto flex w-full max-w-[1280px] flex-col gap-10 px-6 py-12 lg:flex-row lg:items-start">
        <div className="flex flex-1 flex-col gap-10">
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

        <div className="w-full lg:w-80 lg:shrink-0">
          <PurchaseCard price={course.price} includes={course.includes} />
        </div>
      </main>

      <DetailFooter />
    </div>
  );
}