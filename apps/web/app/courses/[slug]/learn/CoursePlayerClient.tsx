"use client";

import { useState } from "react";
import Link from "next/link";
import { CheckCircle2, Circle, PlayCircle, ArrowLeft, ChevronLeft, ChevronRight } from "lucide-react";
import type { PlayerCourse, PlayerLesson } from "./page";

interface CoursePlayerClientProps {
  course: PlayerCourse;
}

export function CoursePlayerClient({ course }: CoursePlayerClientProps) {
  const allLessons = course.modules.flatMap((m) => m.lessons);
  const [activeLessonId, setActiveLessonId] = useState<string>(
    allLessons.find((l) => !l.completed)?.id ?? allLessons[0]?.id ?? ""
  );
  const [lessons, setLessons] = useState<PlayerLesson[]>(allLessons);

  const activeIndex = lessons.findIndex((l) => l.id === activeLessonId);
  const activeLesson = lessons[activeIndex];

  function handleSelectLesson(id: string) {
    setActiveLessonId(id);
  }

  function handleMarkComplete() {
    // TODO: wire to useLessonProgress().markComplete(lessonId) from @saachi/api-client
    setLessons((prev) => prev.map((l) => (l.id === activeLessonId ? { ...l, completed: true } : l)));
  }

  function goToLesson(offset: number) {
    const nextIndex = activeIndex + offset;
    if (nextIndex >= 0 && nextIndex < lessons.length) {
      setActiveLessonId(lessons[nextIndex].id);
    }
  }

  const completedCount = lessons.filter((l) => l.completed).length;
  const progressPercent = lessons.length > 0 ? Math.round((completedCount / lessons.length) * 100) : 0;

  return (
    <div className="flex min-h-screen bg-[var(--token-color-playerBg)]">
      {/* Sidebar: curriculum */}
      <aside className="fixed inset-y-0 left-0 hidden w-80 flex-col overflow-y-auto border-r border-white/10 bg-[var(--token-color-ink)] lg:flex">
        <div className="flex flex-col gap-1 border-b border-white/10 p-6">
          <Link href={`/courses/${course.slug}`} className="flex items-center gap-2 text-sm font-semibold text-white/70 hover:text-white">
            <ArrowLeft size={14} />
            Back to Course
          </Link>
          <h1 className="pt-2 text-lg font-semibold text-white">{course.title}</h1>
          <span className="text-xs font-medium text-white/50">{progressPercent}% complete</span>
        </div>

        <nav className="flex flex-col gap-2 p-4">
          {course.modules.map((module) => (
            <div key={module.id} className="flex flex-col gap-1">
              <h3 className="px-2 pb-1 text-xs font-semibold uppercase tracking-wide text-white/40">
                {module.title}
              </h3>
              {module.lessons.map((lessonMeta) => {
                const lesson = lessons.find((l) => l.id === lessonMeta.id) ?? lessonMeta;
                const isActive = lesson.id === activeLessonId;
                return (
                  <button
                    key={lesson.id}
                    type="button"
                    onClick={() => handleSelectLesson(lesson.id)}
                    className={`flex items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm transition ${
                      isActive ? "bg-white/10 text-white" : "text-white/70 hover:bg-white/5"
                    }`}
                  >
                    {lesson.completed ? (
                      <CheckCircle2 size={16} className="shrink-0 text-[var(--token-color-completedGreen)]" />
                    ) : (
                      <Circle size={16} className="shrink-0 text-white/30" />
                    )}
                    <span className="flex-1 truncate font-medium">{lesson.title}</span>
                    <span className="shrink-0 text-xs text-white/40">{lesson.durationLabel}</span>
                  </button>
                );
              })}
            </div>
          ))}
        </nav>
      </aside>

      {/* Main player */}
      <div className="flex w-full flex-col lg:pl-80">
        <div className="flex aspect-video w-full items-center justify-center bg-black">
          <PlayCircle size={64} className="text-white/30" />
        </div>

        <div className="flex flex-1 flex-col gap-6 px-8 py-8">
          <div className="flex items-start justify-between gap-6">
            <div className="flex flex-col gap-1">
              <h2 className="text-2xl font-semibold text-white">
                {activeLesson?.title ?? "Select a lesson"}
              </h2>
              <span className="text-sm text-white/50">{activeLesson?.durationLabel}</span>
            </div>

            <button
              type="button"
              onClick={handleMarkComplete}
              disabled={!activeLesson || activeLesson.completed}
              className="flex shrink-0 items-center gap-2 rounded-lg bg-[var(--token-color-primary)] px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-[var(--token-color-primaryHover)] disabled:cursor-not-allowed disabled:opacity-50"
            >
              <CheckCircle2 size={16} />
              {activeLesson?.completed ? "Completed" : "Mark as Complete"}
            </button>
          </div>

          <div className="flex items-center justify-between border-t border-white/10 pt-6">
            <button
              type="button"
              onClick={() => goToLesson(-1)}
              disabled={activeIndex <= 0}
              className="flex items-center gap-2 rounded-lg border border-white/10 px-4 py-2 text-sm font-semibold text-white/70 transition hover:bg-white/5 disabled:cursor-not-allowed disabled:opacity-40"
            >
              <ChevronLeft size={14} />
              Previous
            </button>

            <button
              type="button"
              onClick={() => goToLesson(1)}
              disabled={activeIndex >= lessons.length - 1}
              className="flex items-center gap-2 rounded-lg border border-white/10 px-4 py-2 text-sm font-semibold text-white/70 transition hover:bg-white/5 disabled:cursor-not-allowed disabled:opacity-40"
            >
              Next
              <ChevronRight size={14} />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}