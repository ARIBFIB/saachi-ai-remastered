import { Header } from "@/components/marketing/Header";
import { CourseHero } from "@/components/course-detail/CourseHero";
import { WhatYoullLearn } from "@/components/course-detail/WhatYoullLearn";
import { CourseCurriculum } from "@/components/course-detail/CourseCurriculum";
import { InstructorBio } from "@/components/course-detail/InstructorBio";
import { PurchaseCard } from "@/components/course-detail/PurchaseCard";
import { DetailFooter } from "@/components/course-detail/DetailFooter";

export default function CourseDetailPage() {
  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <Header />

      <CourseHero
        category="AI & Machine Learning"
        levelBadge="Beginner Friendly"
        title="Mastering Prompt Engineering"
        description="Unlock the full potential of AI models. Learn advanced techniques to craft effective prompts, optimize outputs, and build AI-driven applications."
        rating={4.8}
        ratingsCount="2,450"
        studentsCount="12,340"
        instructorName="Dr. Sarah Chen"
        instructorAvatar="https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=100&q=80"
        previewImage="https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=900&q=80"
      />

      <main className="mx-auto w-full max-w-[1280px] px-6 py-12">
        <div className="grid grid-cols-1 gap-12 lg:grid-cols-[1fr_360px]">
          <div className="flex flex-col gap-12">
            <WhatYoullLearn />
            <CourseCurriculum />
            <InstructorBio
              name="Dr. Sarah Chen"
              title="Senior AI Researcher & Educator"
              rating={4.9}
              studentsCount="50k+"
              bio="Sarah is a leading researcher in Natural Language Processing with over 10 years of experience building and optimizing AI models for enterprise applications."
              avatar="https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=200&q=80"
            />
          </div>

          <div>
            <PurchaseCard
              price="$99.00"
              includes={[
                "12 hours on-demand video",
                "25 downloadable resources",
                "Certificate of completion",
              ]}
            />
          </div>
        </div>
      </main>

      <DetailFooter />
    </div>
  );
}
