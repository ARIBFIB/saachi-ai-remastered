"use client";

import { useMemo, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { PlayCircle, CheckCircle2, ChevronLeft, ChevronRight, FileText, Download, Menu, X } from "lucide-react";
import { useEnrollmentStore } from "@saachi/store";
import { Button, EmptyState, cn } from "@saachi/ui";

type LessonType = "video" | "text" | "quiz" | "resource";
type Lesson = { id: string; title: string; type: LessonType; durationMinutes?: number };
type CourseModule = { id: string; title: string; lessons: Lesson[] };

// NOTE: demo-only dummy curriculum. Replace with useCourseCurriculum(courseId)
// once the backend curriculum endpoint and typed hook are available.
const DEMO_MODULES: CourseModule[] = [
  {
    id: "m1",
    title: "Getting started with n8n",
    lessons: [
      { id: "l1", title: "Installing and setting up n8n", type: "video", durationMinutes: 8 },
      { id: "l2", title: "Your first workflow", type: "video", durationMinutes: 12 },
      { id: "l3", title: "Key concepts recap", type: "text" }
    ]
  },
  {
    id: "m2",
    title: "Connecting AI models",
    lessons: [
      { id: "l4", title: "Calling the OpenAI API from n8n", type: "video", durationMinutes: 15 },
      { id: "l5", title: "Building a WhatsApp AI auto-responder", type: "video", durationMinutes: 20 },
      { id: "l6", title: "Module quiz", type: "quiz" }
    ]
  }
];

function flattenLessons(modules: CourseModule[]): Lesson[] {
  return modules.flatMap((m) => m.lessons);
}

export default function CoursePlayerPage() {
  const params = useParams<{ courseId: string; lessonId: string }>();
  const router = useRouter();
  const enrollments = useEnrollmentStore((s) => s.enrollments);

  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [completedIds, setCompletedIds] = useState<Set<string>>(new Set());

  const enrollment = useMemo(
    () => enrollments.find((e) => e.courseId === params.courseId),
    [enrollments, params.courseId]
  );

  const allLessons = useMemo(() => flattenLessons(DEMO_MODULES), []);
  const currentIndex = allLessons.findIndex((l) => l.id === params.lessonId);
  const currentLesson = currentIndex >= 0 ? allLessons[currentIndex] : allLessons[0];
  const nextLesson = allLessons[currentIndex + 1];
  const prevLesson = allLessons[currentIndex - 1];

  if (!enrollment) {
    return (
      <div className="mx-auto max-w-3xl px-4 py-16">
        <EmptyState
          title="Not enrolled in this course"
          description="You need to purchase this course before accessing the lessons."
          action={
            <Link href="/my-courses">
              <Button>Back to my courses</Button>
            </Link>
          }
        />
      </div>
    );
  }

  function handleMarkComplete() {
    setCompletedIds((prev) => new Set(prev).add(currentLesson.id));
    // NOTE: demo-only local completion tracking. Wire this up to the real
    // enrollment progress mutation once packages/store's enrollment API
    // exposes a progress-update action.
    if (nextLesson) {
      router.push(`/learn/${params.courseId}/${nextLesson.id}`);
    }
  }

  return (
    <div className="fixed inset-0 flex flex-col bg-paper">
      {/* Top bar */}
      <div className="flex h-14 shrink-0 items-center justify-between border-b border-line bg-card px-4">
        <div className="flex items-center gap-3 overflow-hidden">
          <button
            type="button"
            onClick={() => setSidebarOpen((v) => !v)}
            className="flex h-9 w-9 shrink-0 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
            aria-label="Toggle lesson list"
          >
            {sidebarOpen ? <X size={18} /> : <Menu size={18} />}
          </button>
          <Link href="/my-courses" className="truncate text-[14px] font-semibold text-ink hover:underline">
            {enrollment.title}
          </Link>
        </div>
        <span className="shrink-0 text-[13px] text-ink-soft">{enrollment.progressPercent}% complete</span>
      </div>

      <div className="flex flex-1 overflow-hidden">
        {/* Main content */}
        <div className="flex flex-1 flex-col overflow-y-auto">
          <div className="mx-auto w-full max-w-4xl px-4 py-8">
            {currentLesson.type === "video" && (
              <div className="mb-6 flex aspect-video w-full items-center justify-center rounded-card border border-line bg-ink text-paper">
                <PlayCircle size={56} strokeWidth={1.25} />
              </div>
            )}

            {currentLesson.type === "text" && (
              <div className="mb-6 flex min-h-[200px] items-start gap-3 rounded-card border border-line bg-card p-6">
                <FileText size={18} className="mt-0.5 shrink-0 text-ink-soft" />
                <p className="text-[14px] leading-relaxed text-ink-soft">
                  Lesson text content will render here once the rich-text lesson content API is wired up.
                </p>
              </div>
            )}

            {currentLesson.type === "quiz" && (
              <div className="mb-6 rounded-card border border-line bg-card p-6">
                <p className="text-[14px] text-ink-soft">
                  Quiz interface will render here once the quiz builder + submission API is wired up.
                </p>
              </div>
            )}

            <h1 className="mb-2 font-display text-[22px] font-bold text-ink">{currentLesson.title}</h1>
            {currentLesson.durationMinutes && (
              <p className="mb-6 text-[13px] text-ink-soft">{currentLesson.durationMinutes} min</p>
            )}

            <div className="flex items-center justify-between border-t border-line pt-6">
              <Button
                variant="secondary"
                disabled={!prevLesson}
                onClick={() => prevLesson && router.push(`/learn/${params.courseId}/${prevLesson.id}`)}
              >
                <ChevronLeft size={15} className="mr-1" />
                Previous
              </Button>

              <Button onClick={handleMarkComplete}>
                {completedIds.has(currentLesson.id) ? "Completed" : "Mark complete & continue"}
                {nextLesson && <ChevronRight size={15} className="ml-1" />}
              </Button>
            </div>
          </div>
        </div>

        {/* Lesson sidebar */}
        {sidebarOpen && (
          <aside className="w-[320px] shrink-0 overflow-y-auto border-l border-line bg-card">
            {DEMO_MODULES.map((m) => (
              <div key={m.id} className="border-b border-line">
                <p className="px-4 py-3 text-[12.5px] font-semibold uppercase tracking-[0.04em] text-ink-soft/70">
                  {m.title}
                </p>
                <div className="flex flex-col pb-2">
                  {m.lessons.map((lesson) => {
                    const isActive = lesson.id === currentLesson.id;
                    const isDone = completedIds.has(lesson.id);
                    return (
                      <Link
                        key={lesson.id}
                        href={`/learn/${params.courseId}/${lesson.id}`}
                        className={cn(
                          "flex items-center gap-2.5 px-4 py-2.5 text-[13px] transition-colors",
                          isActive ? "bg-gold-tint text-ink font-semibold" : "text-ink-soft hover:bg-paper-dim"
                        )}
                      >
                        {isDone ? (
                          <CheckCircle2 size={14} className="shrink-0 text-teal" />
                        ) : (
                          <PlayCircle size={14} className="shrink-0" />
                        )}
                        <span className="truncate">{lesson.title}</span>
                      </Link>
                    );
                  })}
                </div>
              </div>
            ))}

            <div className="p-4">
              <Button variant="secondary" size="sm" className="w-full">
                <Download size={13} className="mr-1.5" />
                Download resources
              </Button>
            </div>
          </aside>
        )}
      </div>
    </div>
  );
}