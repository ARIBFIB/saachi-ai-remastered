"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useMemo } from "react";
import {
  PlayCircle,
  FileText,
  HelpCircle,
  Download,
  CheckCircle2,
  Circle,
  ChevronLeft,
  ChevronRight,
  ArrowLeft
} from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState, SkeletonText } from "@saachi/ui";

const LESSON_ICONS = {
  video: PlayCircle,
  text: FileText,
  quiz: HelpCircle,
  resource: Download
} as const;

export default function CoursePlayerPage({
  params
}: {
  params: { courseId: string; lessonId: string };
}) {
  const router = useRouter();
  const { data: course, isLoading } = useCourseDetail(params.courseId);
  const enrollmentStore = useEnrollmentStore();
  const enrollment = enrollmentStore.getEnrollment(params.courseId);

  const flatLessons = useMemo(() => {
    if (!course?.curriculum) return [];
    return course.curriculum.flatMap((mod) =>
      mod.lessons.map((lesson) => ({ ...lesson, moduleTitle: mod.title }))
    );
  }, [course]);

  const currentIndex = flatLessons.findIndex((l) => l.id === params.lessonId);
  const currentLesson = flatLessons[currentIndex];
  const prevLesson = currentIndex > 0 ? flatLessons[currentIndex - 1] : null;
  const nextLesson = currentIndex >= 0 && currentIndex < flatLessons.length - 1 ? flatLessons[currentIndex + 1] : null;

  const isComplete = enrollment?.completedLessonIds.includes(params.lessonId) ?? false;

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[1140px] px-6 py-16">
        <SkeletonText lines={4} />
      </main>
    );
  }

  if (!course || !currentLesson) {
    return (
      <main className="mx-auto max-w-[1140px] px-6 py-16">
        <EmptyState
          title="Lesson not found"
          description="This lesson may not exist for this course."
          action={
            <Link href="/my-courses">
              <Button>Back to My Courses</Button>
            </Link>
          }
        />
      </main>
    );
  }

  const handleMarkComplete = () => {
    enrollmentStore.markLessonComplete(params.courseId, params.lessonId, flatLessons.length);
    if (nextLesson) {
      router.push(`/learn/${params.courseId}/${nextLesson.id}`);
    }
  };

  return (
    <div className="min-h-screen bg-paper">
      <header className="flex items-center justify-between border-b border-line bg-card px-6 py-3">
        <Link href="/my-courses" className="flex items-center gap-2 text-[13px] font-medium text-ink-soft hover:text-ink">
          <ArrowLeft size={16} /> My Courses
        </Link>
        <h1 className="line-clamp-1 text-[14px] font-semibold text-ink">{course.title}</h1>
        <span className="text-[12px] text-ink-soft">
          Lesson {currentIndex + 1} of {flatLessons.length}
        </span>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-[1fr_320px]">
        <div className="px-6 py-8 md:px-10">
          <div className="mx-auto max-w-[820px]">
            <div className="mb-6 aspect-video w-full overflow-hidden rounded-card bg-ink">
              {currentLesson.type === "video" ? (
                <div className="flex h-full w-full items-center justify-center text-white/60">
                  <PlayCircle size={56} />
                </div>
              ) : currentLesson.type === "quiz" ? (
                <div className="flex h-full w-full flex-col items-center justify-center gap-2 text-white/80">
                  <HelpCircle size={40} />
                  <span className="text-[14px]">Quiz content - demo placeholder</span>
                </div>
              ) : (
                <div className="flex h-full w-full flex-col items-center justify-center gap-2 text-white/80">
                  <FileText size={40} />
                  <span className="text-[14px]">Text/resource lesson - demo placeholder</span>
                </div>
              )}
            </div>

            <p className="mb-1 text-[12px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
              {currentLesson.moduleTitle}
            </p>
            <h2 className="font-display text-[24px] font-semibold text-ink">{currentLesson.title}</h2>
            <p className="mt-3 text-[14px] leading-relaxed text-ink-soft">
              This is demo lesson content. Once the backend and video CDN (Doc 3) are wired up,
              real video playback, transcripts, and downloadable resources will render here.
            </p>

            <div className="mt-8 flex items-center justify-between border-t border-line pt-6">
              <Button
                variant="ghost"
                onClick={() => prevLesson && router.push(`/learn/${params.courseId}/${prevLesson.id}`)}
                disabled={!prevLesson}
              >
                <ChevronLeft size={16} /> Previous
              </Button>

              {isComplete ? (
                <Button variant="secondary" disabled>
                  <CheckCircle2 size={16} className="text-teal" /> Completed
                </Button>
              ) : (
                <Button onClick={handleMarkComplete}>Mark complete & continue</Button>
              )}

              <Button
                variant="ghost"
                onClick={() => nextLesson && router.push(`/learn/${params.courseId}/${nextLesson.id}`)}
                disabled={!nextLesson}
              >
                Next <ChevronRight size={16} />
              </Button>
            </div>
          </div>
        </div>

        <aside className="border-t border-line bg-card lg:border-l lg:border-t-0">
          <div className="max-h-[calc(100vh-56px)] overflow-y-auto p-4">
            {course.curriculum?.map((mod) => (
              <div key={mod.id} className="mb-4">
                <h3 className="mb-2 px-2 text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/70">
                  {mod.title}
                </h3>
                <div className="flex flex-col gap-1">
                  {mod.lessons.map((lesson) => {
                    const Icon = LESSON_ICONS[lesson.type];
                    const done = enrollment?.completedLessonIds.includes(lesson.id) ?? false;
                    const active = lesson.id === params.lessonId;
                    return (
                      <Link
                        key={lesson.id}
                        href={`/learn/${params.courseId}/${lesson.id}`}
                        className={[
                          "flex items-center gap-2.5 rounded-control px-3 py-2.5 text-[13px] transition-colors duration-150 ease-out",
                          active ? "bg-gold-tint text-ink font-semibold" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                        ].join(" ")}
                      >
                        {done ? (
                          <CheckCircle2 size={15} className="shrink-0 text-teal" />
                        ) : (
                          <Circle size={15} className="shrink-0 text-line-strong" />
                        )}
                        <Icon size={14} className="shrink-0" />
                        <span className="line-clamp-1">{lesson.title}</span>
                      </Link>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        </aside>
      </div>
    </div>
  );
}