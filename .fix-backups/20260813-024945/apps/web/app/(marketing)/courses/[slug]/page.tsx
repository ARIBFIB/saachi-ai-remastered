import { DUMMY_COURSES } from "@saachi/api-client";
import { Header } from "@/components/marketing/Header";
import { CourseHero } from "@/components/course-detail/CourseHero";
import { WhatYoullLearn } from "@/components/course-detail/WhatYoullLearn";
import { CourseCurriculum } from "@/components/course-detail/CourseCurriculum";
import { InstructorBio } from "@/components/course-detail/InstructorBio";
import { PurchaseCard } from "@/components/course-detail/PurchaseCard";
import { DetailFooter } from "@/components/course-detail/DetailFooter";

interface CourseDetailPageProps {
  params: Promise<{ slug: string }>;
}

export default async function CourseDetailPage({ params }: CourseDetailPageProps) {
  const { slug } = await params;
  const course = DUMMY_COURSES.find((c) => c.slug === slug) ?? DUMMY_COURSES[0];

  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <Header />

      <CourseHero
        category={course.categoryId}
        levelBadge={course.level === "beginner" ? "Beginner Friendly" : course.level === "advanced" ? "Advanced" : "Intermediate"}
        title={course.title}
        description={course.description ?? course.subtitle ?? ""}
        rating={course.rating}
        ratingsCount={course.ratingCount.toLocaleString()}
        studentsCount={(course.instructorStudentCount ?? 0).toLocaleString()}
        instructorName={course.instructor.fullName}
        instructorAvatar={course.instructor.avatarUrl ?? "https://placehold.co/100x100"}
        previewImage={course.thumbnailUrl ?? "https://placehold.co/900x506"}
      />

      <main className="mx-auto w-full max-w-[1280px] px-6 py-12">
        <div className="grid grid-cols-1 gap-12 lg:grid-cols-[1fr_360px]">
          <div className="flex flex-col gap-12">
            {/* NOTE: WhatYoullLearn and CourseCurriculum still render static
                mock content for every course -- wiring real per-course
                curriculum data means adding props to those two components,
                which is a separate follow-up change. */}
            <WhatYoullLearn />
            <CourseCurriculum />
            <InstructorBio
              name={course.instructor.fullName}
              title="Instructor"
              rating={course.rating}
              studentsCount={`${(course.instructorStudentCount ?? 0).toLocaleString()}+`}
              bio={course.instructorBio ?? ""}
              avatar={course.instructor.avatarUrl ?? "https://placehold.co/200x200"}
            />
          </div>

          <div>
            <PurchaseCard
              price={`$${course.price.toFixed(2)}`}
              includes={[
                "On-demand video lessons",
                "Downloadable resources",
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