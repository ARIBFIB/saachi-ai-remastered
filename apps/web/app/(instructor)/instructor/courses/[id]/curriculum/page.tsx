"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { Plus, GripVertical, Trash2, Video, FileText, HelpCircle, Paperclip, ArrowLeft } from "lucide-react";
import { Button, Input, EmptyState } from "@saachi/ui";

type LessonType = "video" | "text" | "quiz" | "resource";
type Lesson = { id: string; title: string; type: LessonType };
type Module = { id: string; title: string; lessons: Lesson[] };

let idCounter = 0;
function nextId() {
  idCounter += 1;
  return `m${idCounter}`;
}

const LESSON_ICONS: Record<LessonType, typeof Video> = {
  video: Video,
  text: FileText,
  quiz: HelpCircle,
  resource: Paperclip
};

export default function CourseCurriculumPage() {
  const params = useParams<{ id: string }>();

  // NOTE: demo-only local state. Replace with useCourseCurriculum(params.id)
  // once the backend curriculum endpoint and typed hook are available.
  const [modules, setModules] = useState<Module[]>([]);
  const [saved, setSaved] = useState(false);

  function addModule() {
    setModules((prev) => [...prev, { id: nextId(), title: `Module ${prev.length + 1}`, lessons: [] }]);
  }

  function renameModule(moduleId: string, title: string) {
    setModules((prev) => prev.map((m) => (m.id === moduleId ? { ...m, title } : m)));
  }

  function removeModule(moduleId: string) {
    setModules((prev) => prev.filter((m) => m.id !== moduleId));
  }

  function addLesson(moduleId: string, type: LessonType) {
    setModules((prev) =>
      prev.map((m) =>
        m.id === moduleId
          ? { ...m, lessons: [...m.lessons, { id: nextId(), title: `New ${type} lesson`, type }] }
          : m
      )
    );
  }

  function removeLesson(moduleId: string, lessonId: string) {
    setModules((prev) =>
      prev.map((m) => (m.id === moduleId ? { ...m, lessons: m.lessons.filter((l) => l.id !== lessonId) } : m))
    );
  }

  function handleSave() {
    // NOTE: demo-only, no backend curriculum-save mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  function lessonEditorHref(lessonId: string, type: LessonType) {
    if (type === "video") return `/instructor/courses/${params.id}/lessons/${lessonId}/video`;
    if (type === "text") return `/instructor/courses/${params.id}/lessons/${lessonId}/text`;
    if (type === "quiz") return `/instructor/courses/${params.id}/lessons/${lessonId}/quiz`;
    return `/instructor/courses/${params.id}/lessons/${lessonId}/video`;
  }

  return (
    <div className="mx-auto max-w-2xl">
      <Link
        href={`/instructor/courses/${params.id}/edit`}
        className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} />
        Back to course
      </Link>

      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Curriculum</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Course ID: {params.id}</p>

      {modules.length === 0 ? (
        <EmptyState title="No modules yet" description="Add your first module to start building the curriculum." />
      ) : (
        <div className="flex flex-col gap-4">
          {modules.map((m) => (
            <div key={m.id} className="rounded-card border border-line bg-card p-4">
              <div className="mb-3 flex items-center gap-2">
                <GripVertical size={16} className="shrink-0 text-ink-soft/50" />
                <Input
                  value={m.title}
                  onChange={(e) => renameModule(m.id, e.target.value)}
                  className="flex-1"
                />
                <button
                  type="button"
                  onClick={() => removeModule(m.id)}
                  aria-label="Remove module"
                  className="shrink-0 text-ink-soft hover:text-error"
                >
                  <Trash2 size={15} />
                </button>
              </div>

              {m.lessons.length > 0 && (
                <ul className="mb-3 flex flex-col gap-1.5">
                  {m.lessons.map((l) => {
                    const Icon = LESSON_ICONS[l.type];
                    return (
                      <li
                        key={l.id}
                        className="flex items-center gap-2 rounded-control bg-paper-dim px-3 py-2 text-[13px] text-ink"
                      >
                        <Icon size={13} className="shrink-0 text-ink-soft" />
                        <Link href={lessonEditorHref(l.id, l.type)} className="flex-1 truncate hover:underline">
                          {l.title}
                        </Link>
                        <span className="shrink-0 rounded bg-card px-1.5 py-0.5 text-[10px] uppercase text-ink-soft">
                          {l.type}
                        </span>
                        <button
                          type="button"
                          onClick={() => removeLesson(m.id, l.id)}
                          aria-label="Remove lesson"
                          className="shrink-0 text-ink-soft hover:text-error"
                        >
                          <Trash2 size={12} />
                        </button>
                      </li>
                    );
                  })}
                </ul>
              )}

              <div className="flex flex-wrap gap-2">
                <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "video")}>
                  + Video
                </Button>
                <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "text")}>
                  + Text
                </Button>
                <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "quiz")}>
                  + Quiz
                </Button>
                <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "resource")}>
                  + Resource
                </Button>
              </div>
            </div>
          ))}
        </div>
      )}

      <Button variant="secondary" className="mt-4" onClick={addModule}>
        <Plus size={14} className="mr-1.5" />
        Add module
      </Button>

      <div className="mt-6">
        <Button size="lg" onClick={handleSave}>
          {saved ? "Saved" : "Save curriculum"}
        </Button>
      </div>
    </div>
  );
}