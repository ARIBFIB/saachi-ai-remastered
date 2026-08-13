"use client";

import { useState } from "react";
import Link from "next/link";
import { Button } from "antd";
import { PlayCircle, CheckCircle2, Circle, ArrowLeft, ChevronRight } from "lucide-react";

// TODO: replace with useCourseCurriculum(courseSlug) + useLessonProgress() hooks
// from @saachi/api-client
interface Lesson {
  id: string;
  title: string;
  durationLabel: string;
  completed: boolean;
}

interface Module {
  id: string;
  title: string;
  lessons: Lesson[];
}

const modules: Module[] = [
  {
    id: "m1",
    title: "Module 1: Introduction to Large Language Models",
    lessons: [
      { id: "l1", title: "What is a Large Language Model?", durationLabel: "8:12", completed: true },
      { id: "l2", title: "Tokens, context windows, and limits", durationLabel: "11:40", completed: true },
      { id: "l3", title: "Setting up your first API call", durationLabel: "14:05", completed: false },
    ],
  },
  {
    id: "m2",
    title: "Module 2: Anatomy of a Perfect Prompt",
    lessons: [
      { id: "l4", title: "Zero-shot vs few-shot prompting", durationLabel: "10:22", completed: false },
      { id: "l5", title: "Chain-of-thought reasoning", durationLabel: "16:48", completed: false },
    ],
  },
];

export function CoursePlayerClient({ courseSlug }: { courseSlug: string }) {
  const allLessons = modules.flatMap((m) => m.lessons);
  const [activeLessonId, setActiveLessonId] = useState(allLessons[0]?.id ?? "");
  const activeLesson = allLessons.find((l) => l.id === activeLessonId) ?? allLessons[0];

  function handleMarkComplete() {
    // TODO: wire to useLessonProgress(courseSlug, activeLessonId).markComplete()
    // from @saachi/api-client
    console.log("mark complete", { courseSlug, lessonId: activeLessonId });
  }

  return (
    <div className="flex min-h-screen" style={{ backgroundColor: "var(--token-color-playerBg)" }}>
      {/* Video + lesson content */}
      <div className="flex flex-1 flex-col">
        <div className="flex items-center gap-3 px-6 py-4">
          <Link href="/dashboard/my-courses" className="flex items-center gap-1 text-sm text-white/70 hover:text-white">
            <ArrowLeft size={14} />
            Back to My Courses
          </Link>
        </div>

        <div className="relative mx-6 flex aspect-video items-center justify-center rounded-xl bg-black/60">
          <PlayCircle size={64} className="text-white/80" />
        </div>

        <div className="flex flex-col gap-3 px-6 py-6">
          <h1 className="text-xl font-semibold text-white">{activeLesson?.title}</h1>
          <p className="text-sm text-white/60">
            Course: {courseSlug.replace(/-/g, " ")}
          </p>

          <div className="pt-2">
            <Button type="primary" icon={<CheckCircle2 size={14} />} onClick={handleMarkComplete}>
              Mark Lesson Complete
            </Button>
          </div>
        </div>
      </div>

      {/* Lesson sidebar */}
      <aside className="hidden w-80 shrink-0 flex-col overflow-y-auto border-l border-white/10 bg-black/20 lg:flex">
        <div className="border-b border-white/10 px-5 py-4">
          <h2 className="text-sm font-semibold text-white">Course Content</h2>
        </div>

        <nav className="flex flex-col">
          {modules.map((module) => (
            <div key={module.id} className="border-b border-white/10">
              <div className="px-5 py-3 text-xs font-semibold uppercase tracking-wide text-white/50">
                {module.title}
              </div>
              <div className="flex flex-col">
                {module.lessons.map((lesson) => {
                  const isActive = lesson.id === activeLessonId;
                  return (
                    <button
                      key={lesson.id}
                      type="button"
                      onClick={() => setActiveLessonId(lesson.id)}
                      className="flex items-center justify-between gap-2 px-5 py-3 text-left transition"
                      style={{
                        backgroundColor: isActive ? "rgba(255,255,255,0.08)" : "transparent",
                      }}
                    >
                      <span className="flex items-center gap-2">
                        {lesson.completed ? (
                          <CheckCircle2 size={14} className="shrink-0 text-emerald-400" />
                        ) : (
                          <Circle size={14} className="shrink-0 text-white/40" />
                        )}
                        <span className={`text-sm ${isActive ? "font-semibold text-white" : "text-white/70"}`}>
                          {lesson.title}
                        </span>
                      </span>
                      <span className="flex items-center gap-1 text-xs text-white/40">
                        {lesson.durationLabel}
                        {isActive && <ChevronRight size={12} />}
                      </span>
                    </button>
                  );
                })}
              </div>
            </div>
          ))}
        </nav>
      </aside>
    </div>
  );
}