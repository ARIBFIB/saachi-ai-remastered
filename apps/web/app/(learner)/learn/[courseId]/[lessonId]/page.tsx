"use client";

import { useMemo } from "react";
import { useParams, useRouter } from "next/navigation";
import { CheckCircle2, Circle, PlayCircle, FileText, HelpCircle, Paperclip } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { useEnrollmentStore } from "@saachi/store";
import { Button, Loading, cn } from "@saachi/ui";

const LESSON_ICON = {
  video: PlayCircle,
  text: FileText,
  quiz: HelpCircle,
  resource: Paperclip
} as const;

export default function CoursePlayerPage() {
  const params = useParams<{ courseId: string; lessonId: string }>();
  const router = useRouter();
  const { data: course, isLoading } = useCourseDetail(params.courseId);
  const enrollment = useEnrollmentStore((s) => s.getEnrollment(params.courseId));
  const markLessonComplete = useEnrollmentStore((s) => s.markLessonComplete);

  const allLessons = useMemo(
    () => course?.curriculum?.flatMap((mod) => mod.lessons) ?? [],
    [course]
  );

  const currentLesson =
    allLessons.find((l) => l.id === params.lessonId) ?? allLessons[0];

  if (isLoading || !course) {
    return <Loading fullScreen label="Loading lesson..." />;
  }

  if (!currentLesson) {
    return <p className="p-10 text-center text-ink-soft">No lessons found for this course.</p>;
  }

  const isComplete = enrollment?.completedLessonIds.includes(currentLesson.id) ?? false;
  const Icon = LESSON_ICON[currentLesson.type];

  function goToLesson(lessonId: string) {
    router.push(`/learn/${params.courseId}/${lessonId}`);
  }

  return (
    <div className="mx-auto grid max-w-7xl grid-cols-1 gap-6 px-4 py-8 md:grid-cols-[1fr_320px] md:px-8">
      <div>
        <p className="mb-1 text-[13px] font-medium text-gold-dark">{course.title}</p>
        <h1 className="mb-4 font-display text-[24px] font-bold text-ink">{currentLesson.title}</h1>

        <div className="mb-6 flex aspect-video w-full items-center justify-center rounded-card border border-line bg-paper-dim">
          <Icon size={48} className="text-ink-soft/40" />
        </div>

        <Button
          onClick={() => markLessonComplete(params.courseId, currentLesson.id, allLessons.length)}
          disabled={isComplete}
        >
          {isComplete ? "Lesson completed" : "Mark as complete"}
        </Button>
      </div>

      <aside className="h-fit rounded-card border border-line bg-card p-4 md:sticky md:top-24">
        <h2 className="mb-3 text-[13px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
          Curriculum
        </h2>
        <div className="flex flex-col gap-4">
          {course.curriculum?.map((mod) => (
            <div key={mod.id}>
              <p className="mb-2 text-[13px] font-semibold text-ink">{mod.title}</p>
              <ul className="flex flex-col gap-1">
                {mod.lessons.map((lesson) => {
                  const done = enrollment?.completedLessonIds.includes(lesson.id) ?? false;
                  const active = lesson.id === currentLesson.id;
                  return (
                    <li key={lesson.id}>
                      <button
                        type="button"
                        onClick={() => goToLesson(lesson.id)}
                        className={cn(
                          "flex w-full items-center gap-2 rounded-control px-2.5 py-2 text-left text-[13px]",
                          active ? "bg-gold-tint text-ink" : "text-ink-soft hover:bg-paper-dim"
                        )}
                      >
                        {done ? (
                          <CheckCircle2 size={15} className="shrink-0 text-teal" />
                        ) : (
                          <Circle size={15} className="shrink-0 text-line-strong" />
                        )}
                        <span className="truncate">{lesson.title}</span>
                      </button>
                    </li>
                  );
                })}
              </ul>
            </div>
          ))}
        </div>
      </aside>
    </div>
  );
}