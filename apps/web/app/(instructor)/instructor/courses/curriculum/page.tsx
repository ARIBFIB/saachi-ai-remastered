"use client";

import { useMemo, useState, type DragEvent } from "react";
import {
  GripVertical,
  Plus,
  Trash2,
  Pencil,
  Check,
  X,
  Video,
  FileText,
  HelpCircle,
  Paperclip,
  ChevronDown,
  Save
} from "lucide-react";
import { useInstructorCourseStore, type InstructorCourseLesson, type InstructorCourseModule } from "@saachi/store";
import { Button, Select, EmptyState, cn } from "@saachi/ui";
import { Info } from "lucide-react";
import { useBottomPanelStore } from "@saachi/store";

type LessonType = InstructorCourseLesson["type"];

const LESSON_TYPE_META: Record<LessonType, { label: string; icon: typeof Video }> = {
  video: { label: "Video", icon: Video },
  text: { label: "Text", icon: FileText },
  quiz: { label: "Quiz", icon: HelpCircle },
  resource: { label: "Resource", icon: Paperclip }
};

let idCounter = 0;
function nextId(prefix: string) {
  idCounter += 1;
  return `${prefix}_${Date.now().toString(36)}${idCounter}`;
}

export default function InstructorCoursesCurriculumPage() {
  const courses = useInstructorCourseStore((s) => s.courses);
  const setModules = useInstructorCourseStore((s) => s.setModules);

  const [courseId, setCourseId] = useState(courses[0]?.id ?? "");
  const [savedTick, setSavedTick] = useState(0);

  const course = useMemo(() => courses.find((c) => c.id === courseId), [courses, courseId]);

  const courseOptions = courses.map((c) => ({ label: c.title, value: c.id }));

  function persist(modules: InstructorCourseModule[]) {
    if (!course) return;
    setModules(course.id, modules);
    setSavedTick((t) => t + 1);
  }

  if (courses.length === 0) {
    return (
      <div>
        <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Curriculum Builder</h1>
        <p className="mb-8 text-[14px] text-ink-soft">Drag-and-drop module and lesson structuring for your courses.</p>
        <EmptyState title="No courses yet" description="Create a course first to start building its curriculum." />
      </div>
    );
  }

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Curriculum Builder</h1>
          <p className="text-[14px] text-ink-soft">Drag modules and lessons to reorder. Changes save automatically.</p>
        </div>
        <div className="flex items-center gap-3">
          {savedTick > 0 && (
            <span className="flex items-center gap-1.5 text-[12.5px] font-medium text-teal">
              <Save size={13} />
              Saved
            </span>
          )}
          <Select options={courseOptions} value={courseId} onChange={(e) => setCourseId(e.target.value)} className="w-72" />
        </div>
      </div>

      {course && <ModuleList key={course.id} modules={course.modules} onChange={persist} />}
    </div>
  );
}

function ModuleList({
  modules,
  onChange
}: {
  
  const openTab = useBottomPanelStore((s) => s.openTab);
modules: InstructorCourseModule[];
  onChange: (modules: InstructorCourseModule[]) => void;
}) {
  const [dragIndex, setDragIndex] = useState<number | null>(null);
  const [expanded, setExpanded] = useState<Set<string>>(() => new Set(modules.map((m) => m.id)));

  function toggleExpanded(id: string) {
    setExpanded((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  function handleDragStart(index: number) {
    setDragIndex(index);
  }

  function handleDragOver(e: DragEvent, index: number) {
    e.preventDefault();
    if (dragIndex === null || dragIndex === index) return;
    const reordered = [...modules];
    const [moved] = reordered.splice(dragIndex, 1);
    reordered.splice(index, 0, moved);
    setDragIndex(index);
    onChange(reordered);
  }

  function handleDrop() {
    setDragIndex(null);
  }

  function addModule() {
    const newModule: InstructorCourseModule = { id: nextId("mod"), title: `Module ${modules.length + 1}`, lessons: [] };
    setExpanded((prev) => new Set(prev).add(newModule.id));
    onChange([...modules, newModule]);
  }

  function updateModule(id: string, patch: Partial<InstructorCourseModule>) {
    onChange(modules.map((m) => (m.id === id ? { ...m, ...patch } : m)));
  }

  function removeModule(id: string) {
    onChange(modules.filter((m) => m.id !== id));
  }

  function addLesson(moduleId: string, type: LessonType) {
    onChange(
      modules.map((m) =>
        m.id === moduleId
          ? { ...m, lessons: [...m.lessons, { id: nextId("les"), title: `New ${type} lesson`, type }] }
          : m
      )
    );
  }

  function updateLesson(moduleId: string, lessonId: string, patch: Partial<InstructorCourseLesson>) {
    onChange(
      modules.map((m) =>
        m.id === moduleId
          ? { ...m, lessons: m.lessons.map((l) => (l.id === lessonId ? { ...l, ...patch } : l)) }
          : m
      )
    );
  }

  function removeLesson(moduleId: string, lessonId: string) {
    onChange(
      modules.map((m) => (m.id === moduleId ? { ...m, lessons: m.lessons.filter((l) => l.id !== lessonId) } : m))
    );
  }

  function reorderLesson(moduleId: string, fromIndex: number, toIndex: number) {
    onChange(
      modules.map((m) => {
        if (m.id !== moduleId) return m;
        const lessons = [...m.lessons];
        const [moved] = lessons.splice(fromIndex, 1);
        lessons.splice(toIndex, 0, moved);
        return { ...m, lessons };
      })
    );
  }

  return (
    <div className="flex flex-col gap-3">
      {modules.length === 0 ? (
        <EmptyState title="No modules yet" description="Add your first module to start building the curriculum." />
      ) : (
        modules.map((m, index) => (
          <div
            key={m.id}
            draggable
            onDragStart={() => handleDragStart(index)}
            onDragOver={(e) => handleDragOver(e, index)}
            onDrop={handleDrop}
            className={cn(
              "rounded-card border border-line bg-card transition-shadow",
              dragIndex === index && "opacity-60 shadow-lg"
            )}
          >
            <div className="flex items-center gap-2 px-4 py-3">
              <span className="cursor-grab text-ink-soft/50" title="Drag to reorder">
                <GripVertical size={16} />
              </span>
              <button
                type="button"
                onClick={() => toggleExpanded(m.id)}
                className="flex h-6 w-6 shrink-0 items-center justify-center text-ink-soft"
                aria-label="Toggle module"
              >
                <ChevronDown
                  size={15}
                  className="transition-transform duration-200"
                  style={{ transform: expanded.has(m.id) ? "rotate(0deg)" : "rotate(-90deg)" }}
                />
              </button>
              <ModuleTitle title={m.title} onSave={(title) => updateModule(m.id, { title })} />
              <span className="ml-auto shrink-0 text-[12px] text-ink-soft">{m.lessons.length} lesson(s)</span>
              <button
                type="button"
                aria-label="View module details"
                onClick={() =>
                  openTab({
                    id: `module-details-${m.id}`,
                    title: m.title,
                    kind: "details",
                    rows: [
                      { label: "Module ID", value: m.id },
                      { label: "Lessons", value: String(m.lessons.length) },
                      // NOTE: dummy timestamps - module type has no real
                      // createdAt/updatedAt yet. Replace once backend adds them.
                      { label: "Created At", value: new Date(Date.now() - 1000 * 60 * 60 * 24 * 6).toLocaleString() },
                      { label: "Updated At", value: new Date(Date.now() - 1000 * 60 * 45).toLocaleString() },
                      { label: "Status", value: "Draft" }
                    ]
                  })
                }
                className="mr-1 flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft transition-colors hover:bg-paper-dim hover:text-ink"
              >
                <Info size={14} />
              </button>
              <button
                type="button"
                aria-label="Delete module"
                onClick={() => removeModule(m.id)}
                className="ml-2 flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft transition-colors hover:bg-error-tint hover:text-error"
              >
                <Trash2 size={14} />
              </button>
            </div>

            {expanded.has(m.id) && (
              <div className="border-t border-line px-4 py-3">
                <LessonList
                  lessons={m.lessons}
                  onReorder={(from, to) => reorderLesson(m.id, from, to)}
                  onUpdate={(lessonId, patch) => updateLesson(m.id, lessonId, patch)}
                  onRemove={(lessonId) => removeLesson(m.id, lessonId)}
                />
                <div className="mt-3 flex flex-wrap gap-2">
                  {(Object.keys(LESSON_TYPE_META) as LessonType[]).map((type) => {
                    const Icon = LESSON_TYPE_META[type].icon;
                    return (
                      <Button key={type} size="sm" variant="secondary" onClick={() => addLesson(m.id, type)}>
                        <Icon size={13} className="mr-1.5" />+ {LESSON_TYPE_META[type].label}
                      </Button>
                    );
                  })}
                </div>
              </div>
            )}
          </div>
        ))
      )}

      <Button variant="secondary" className="self-start" onClick={addModule}>
        <Plus size={14} className="mr-1.5" />
        Add module
      </Button>
    </div>
  );
}

function ModuleTitle({ title, onSave }: { title: string; onSave: (title: string) => void }) {
  const [editing, setEditing] = useState(false);
  const [value, setValue] = useState(title);

  if (!editing) {
    return (
      <button
        type="button"
        onClick={() => {
          setValue(title);
          setEditing(true);
        }}
        className="group flex min-w-0 flex-1 items-center gap-2 text-left"
      >
        <span className="truncate text-[14px] font-semibold text-ink">{title}</span>
        <Pencil size={12} className="shrink-0 text-ink-soft/0 transition-colors group-hover:text-ink-soft" />
      </button>
    );
  }

  return (
    <div className="flex min-w-0 flex-1 items-center gap-1.5">
      <input
        autoFocus
        value={value}
        onChange={(e) => setValue(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === "Enter") {
            onSave(value.trim() || title);
            setEditing(false);
          }
          if (e.key === "Escape") setEditing(false);
        }}
        className="min-w-0 flex-1 rounded-control border border-line-strong bg-paper px-2 py-1 text-[14px] font-semibold text-ink outline-none focus:border-gold"
      />
      <button
        type="button"
        onClick={() => {
          onSave(value.trim() || title);
          setEditing(false);
        }}
        className="flex h-7 w-7 shrink-0 items-center justify-center rounded-control text-teal hover:bg-teal-light"
      >
        <Check size={14} />
      </button>
      <button
        type="button"
        onClick={() => setEditing(false)}
        className="flex h-7 w-7 shrink-0 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
      >
        <X size={14} />
      </button>
    </div>
  );
}

function LessonList({
  lessons,
  onReorder,
  onUpdate,
  onRemove
}: {
  lessons: InstructorCourseLesson[];
  onReorder: (fromIndex: number, toIndex: number) => void;
  onUpdate: (lessonId: string, patch: Partial<InstructorCourseLesson>) => void;
  onRemove: (lessonId: string) => void;
}) {
  const [dragIndex, setDragIndex] = useState<number | null>(null);

  if (lessons.length === 0) {
    return <p className="text-[12.5px] text-ink-soft">No lessons in this module yet.</p>;
  }

  return (
    <ul className="flex flex-col gap-1.5">
      {lessons.map((lesson, index) => {
        const Icon = LESSON_TYPE_META[lesson.type].icon;
        return (
          <li
            key={lesson.id}
            draggable
            onDragStart={() => setDragIndex(index)}
            onDragOver={(e) => {
              e.preventDefault();
              if (dragIndex === null || dragIndex === index) return;
              onReorder(dragIndex, index);
              setDragIndex(index);
            }}
            onDrop={() => setDragIndex(null)}
            className={cn(
              "flex items-center gap-2 rounded-control border border-line bg-paper-dim/50 px-3 py-2 transition-opacity",
              dragIndex === index && "opacity-60"
            )}
          >
            <span className="cursor-grab text-ink-soft/40" title="Drag to reorder">
              <GripVertical size={14} />
            </span>
            <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded bg-card text-ink-soft">
              <Icon size={12} />
            </span>
            <LessonTitleInline title={lesson.title} onSave={(title) => onUpdate(lesson.id, { title })} />
            <button
              type="button"
              aria-label="Delete lesson"
              onClick={() => onRemove(lesson.id)}
              className="flex h-7 w-7 shrink-0 items-center justify-center rounded-control text-ink-soft/60 transition-colors hover:bg-error-tint hover:text-error"
            >
              <Trash2 size={13} />
            </button>
          </li>
        );
      })}
    </ul>
  );
}

function LessonTitleInline({ title, onSave }: { title: string; onSave: (title: string) => void }) {
  const [editing, setEditing] = useState(false);
  const [value, setValue] = useState(title);

  if (!editing) {
    return (
      <button
        type="button"
        onClick={() => {
          setValue(title);
          setEditing(true);
        }}
        className="min-w-0 flex-1 truncate text-left text-[13px] text-ink"
      >
        {title}
      </button>
    );
  }

  return (
    <input
      autoFocus
      value={value}
      onChange={(e) => setValue(e.target.value)}
      onBlur={() => {
        onSave(value.trim() || title);
        setEditing(false);
      }}
      onKeyDown={(e) => {
        if (e.key === "Enter") {
          onSave(value.trim() || title);
          setEditing(false);
        }
        if (e.key === "Escape") setEditing(false);
      }}
      className="min-w-0 flex-1 rounded border border-line-strong bg-card px-1.5 py-0.5 text-[13px] text-ink outline-none focus:border-gold"
    />
  );
}
