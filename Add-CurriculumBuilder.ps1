<#
.SYNOPSIS
  Adds a real Curriculum Builder to the SAI2 Instructor module.
  - Replaces packages/store/src/useInstructorCourseStore.ts with a seeded
    version (adds setModules action + 4 demo courses with modules/lessons)
  - Replaces the Curriculum Builder placeholder page with a real
    drag-and-drop module/lesson editor:
    apps/web/app/(instructor)/instructor/courses/curriculum/page.tsx

  Run this from the SAI2 monorepo root:
  PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2>
#>

$ErrorActionPreference = "Stop"

function Write-FileUtf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$RelativePath,
        [Parameter(Mandatory=$true)][string]$Content
    )
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $RelativePath
    $dir = Split-Path -Path $fullPath -Parent
    if (-not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $utf8NoBom)
    Write-Host "  Wrote: $RelativePath"
}

Write-Host ""
Write-Host "== SAI2: Curriculum Builder module ==" -ForegroundColor Cyan
Write-Host ""

# ---------------------------------------------------------------------------
# 1) Seeded instructor course store (adds setModules action)
# ---------------------------------------------------------------------------
$storeContent = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type InstructorCourseLesson = {
  id: string;
  title: string;
  type: "video" | "text" | "quiz" | "resource";
};

export type InstructorCourseModule = {
  id: string;
  title: string;
  lessons: InstructorCourseLesson[];
};

export type InstructorCourse = {
  id: string;
  title: string;
  subtitle: string;
  categoryId: string;
  language: string;
  level: "beginner" | "intermediate" | "advanced";
  price: number;
  currency: string;
  status: "draft" | "pending_review" | "published";
  modules: InstructorCourseModule[];
  createdAt: string;
  enrollmentCount: number;
  revenue: number;
  rating: number;
};

// NOTE: demo-only seed data so the Curriculum Builder has real content to
// edit out of the box. Mirrors the dummy courses shown on
// apps/web/app/(instructor)/instructor/courses/page.tsx (crs_i1..crs_i4).
// Replace with a real fetch-and-hydrate from the backend once available.
const SEED_COURSES: InstructorCourse[] = [
  {
    id: "crs_i1",
    title: "Automate Everything with n8n & AI",
    subtitle: "Connect AI models into no-code workflows that run themselves.",
    categoryId: "ai-automation",
    language: "en",
    level: "intermediate",
    price: 39,
    currency: "USD",
    status: "published",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 140).toISOString(),
    enrollmentCount: 654,
    revenue: 8420,
    rating: 4.7,
    modules: [
      {
        id: "mod_i1_1",
        title: "n8n Basics",
        lessons: [
          { id: "les_i1_1", title: "Installing and connecting n8n", type: "video" },
          { id: "les_i1_2", title: "Your first AI node", type: "video" },
          { id: "les_i1_3", title: "Knowledge check", type: "quiz" }
        ]
      },
      {
        id: "mod_i1_2",
        title: "Five Real Automations",
        lessons: [
          { id: "les_i1_4", title: "Lead qualification bot", type: "video" },
          { id: "les_i1_5", title: "Invoice parsing pipeline", type: "video" },
          { id: "les_i1_6", title: "Starter workflow files", type: "resource" }
        ]
      }
    ]
  },
  {
    id: "crs_i2",
    title: "AI Chatbots for WhatsApp Support",
    subtitle: "Ship a working AI customer-support bot on WhatsApp.",
    categoryId: "ai-support",
    language: "en",
    level: "advanced",
    price: 59,
    currency: "USD",
    status: "pending_review",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 12).toISOString(),
    enrollmentCount: 0,
    revenue: 0,
    rating: 0,
    modules: [
      {
        id: "mod_i2_1",
        title: "WhatsApp API Setup",
        lessons: [
          { id: "les_i2_1", title: "WhatsApp Business API basics", type: "video" },
          { id: "les_i2_2", title: "Webhook configuration", type: "text" }
        ]
      },
      {
        id: "mod_i2_2",
        title: "Building the AI Layer",
        lessons: [{ id: "les_i2_3", title: "Knowledge base + retrieval", type: "video" }]
      }
    ]
  },
  {
    id: "crs_i3",
    title: "Prompt Engineering for Client Work",
    subtitle: "Practical prompting techniques for freelance and agency work.",
    categoryId: "ai-fundamentals",
    language: "en",
    level: "beginner",
    price: 29,
    currency: "USD",
    status: "draft",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 4).toISOString(),
    enrollmentCount: 0,
    revenue: 0,
    rating: 0,
    modules: [
      {
        id: "mod_i3_1",
        title: "Getting Started",
        lessons: [{ id: "les_i3_1", title: "Why prompting is a skill", type: "video" }]
      }
    ]
  },
  {
    id: "crs_i4",
    title: "Cold Outreach with Claude",
    subtitle: "AI-assisted cold email sequences that book meetings.",
    categoryId: "ai-marketing",
    language: "en",
    level: "intermediate",
    price: 35,
    currency: "USD",
    status: "draft",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 30).toISOString(),
    enrollmentCount: 0,
    revenue: 0,
    rating: 0,
    modules: []
  }
];

type InstructorCourseState = {
  courses: InstructorCourse[];
  addCourse: (course: InstructorCourse) => void;
  updateCourse: (id: string, patch: Partial<InstructorCourse>) => void;
  removeCourse: (id: string) => void;
  setModules: (courseId: string, modules: InstructorCourseModule[]) => void;
};

export const useInstructorCourseStore = create<InstructorCourseState>()(
  persist(
    (set, get) => ({
      courses: SEED_COURSES,
      addCourse: (course) => set({ courses: [course, ...get().courses] }),
      updateCourse: (id, patch) =>
        set({ courses: get().courses.map((c) => (c.id === id ? { ...c, ...patch } : c)) }),
      removeCourse: (id) => set({ courses: get().courses.filter((c) => c.id !== id) }),
      setModules: (courseId, modules) =>
        set({ courses: get().courses.map((c) => (c.id === courseId ? { ...c, modules } : c)) })
    }),
    { name: "saachi-instructor-courses" }
  )
);

'@
Write-FileUtf8NoBom -RelativePath "packages\store\src\useInstructorCourseStore.ts" -Content $storeContent

# ---------------------------------------------------------------------------
# 2) Curriculum Builder page (drag-and-drop modules + lessons)
# ---------------------------------------------------------------------------
$pageContent = @'
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

'@
Write-FileUtf8NoBom -RelativePath "apps\web\app\(instructor)\instructor\courses\curriculum\page.tsx" -Content $pageContent

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Note: this seeds packages/store's persisted 'saachi-instructor-courses'"
Write-Host "localStorage key with demo courses. If you already have stale data in"
Write-Host "your browser under that key, clear it (Application tab -> Local Storage)"
Write-Host "to see the new seed data, since zustand persist restores from storage"
Write-Host "first if a value already exists there."
Write-Host ""
Write-Host "Next: restart 'npm run dev' inside apps/web if it was already running."
Write-Host ""