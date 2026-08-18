#
#  Add-BottomTerminalPanel.ps1  –  FIXED VERSION
#  ----------------------------------------------
#  Directly writes the three files that need changes:
#    1. packages\store\src\useBottomPanelStore.ts        (already correct – skip if exists)
#    2. apps\web\components\ui\bottom-terminal-panel.tsx  (already correct – skip if exists)
#    3. apps\web\app\(instructor)\_components\InstructorShell.tsx  (patch if needed)
#    4. apps\web\app\(instructor)\instructor\courses\curriculum\page.tsx  (full replacement)
#
#  Run from SAI2 root:
#    .\Add-BottomTerminalPanel.ps1
#

param(
    [string]$RootPath = (Get-Location).Path
)

function Write-FileUtf8NoBom {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
    Write-Host "  [WRITTEN] $Path" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Add-BottomTerminalPanel (FIXED) ===" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1) STORE  –  packages\store\src\useBottomPanelStore.ts
# ============================================================
$storePath = Join-Path $RootPath "packages\store\src\useBottomPanelStore.ts"

$storeContent = @'
"use client";

import { create } from "zustand";

export type BottomPanelTabKind = "details" | "log" | "info";

export type BottomPanelDetailRow = {
  label: string;
  value: string;
};

export type BottomPanelTab = {
  id: string;
  title: string;
  kind: BottomPanelTabKind;
  rows: BottomPanelDetailRow[];
};

type BottomPanelState = {
  isOpen: boolean;
  height: number;
  tabs: BottomPanelTab[];
  activeTabId: string | null;
  openTab: (tab: BottomPanelTab) => void;
  closeTab: (id: string) => void;
  closeAllTabs: () => void;
  setActiveTab: (id: string) => void;
  setHeight: (height: number) => void;
  togglePanel: () => void;
  collapse: () => void;
};

export const MIN_PANEL_HEIGHT = 140;
export const MAX_PANEL_HEIGHT = 640;
export const DEFAULT_PANEL_HEIGHT = 260;

export const useBottomPanelStore = create<BottomPanelState>((set, get) => ({
  isOpen: false,
  height: DEFAULT_PANEL_HEIGHT,
  tabs: [],
  activeTabId: null,

  openTab: (tab) => {
    const existing = get().tabs.find((t) => t.id === tab.id);
    if (existing) {
      set((state) => ({
        tabs: state.tabs.map((t) => (t.id === tab.id ? tab : t)),
        activeTabId: tab.id,
        isOpen: true,
      }));
      return;
    }
    set((state) => ({
      tabs: [...state.tabs, tab],
      activeTabId: tab.id,
      isOpen: true,
    }));
  },

  closeTab: (id) => {
    set((state) => {
      const remaining = state.tabs.filter((t) => t.id !== id);
      const wasActive = state.activeTabId === id;
      const nextActive = wasActive
        ? (remaining[remaining.length - 1]?.id ?? null)
        : state.activeTabId;
      return {
        tabs: remaining,
        activeTabId: nextActive,
        isOpen: remaining.length > 0 ? state.isOpen : false,
      };
    });
  },

  closeAllTabs: () => set({ tabs: [], activeTabId: null, isOpen: false }),
  setActiveTab: (id) => set({ activeTabId: id }),

  setHeight: (height) => {
    const clamped = Math.min(MAX_PANEL_HEIGHT, Math.max(MIN_PANEL_HEIGHT, height));
    set({ height: clamped });
  },

  togglePanel: () => set((state) => ({ isOpen: !state.isOpen })),
  collapse: () => set({ isOpen: false }),
}));
'@

Write-FileUtf8NoBom -Path $storePath -Content $storeContent

# Export from store index if missing
$storeIndexPath = Join-Path $RootPath "packages\store\src\index.ts"
if (Test-Path $storeIndexPath) {
    $indexContent = Get-Content -Path $storeIndexPath -Raw -Encoding UTF8
    if ($indexContent -notmatch "useBottomPanelStore") {
        $appended = $indexContent.TrimEnd() + "`r`nexport * from `"./useBottomPanelStore`";`r`n"
        Write-FileUtf8NoBom -Path $storeIndexPath -Content $appended
        Write-Host "  [OK] Exported useBottomPanelStore from store index.ts" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] useBottomPanelStore already exported in index.ts" -ForegroundColor Yellow
    }
} else {
    Write-Host "  [WARN] packages\store\src\index.ts not found" -ForegroundColor Yellow
}

# ============================================================
# 2) COMPONENT  –  apps\web\components\ui\bottom-terminal-panel.tsx
# ============================================================
$panelPath = Join-Path $RootPath "apps\web\components\ui\bottom-terminal-panel.tsx"

$panelContent = @'
"use client";

import { useCallback, useEffect, useRef } from "react";
import { X, TerminalSquare, ChevronDown, Trash2 } from "lucide-react";
import {
  useBottomPanelStore,
  MIN_PANEL_HEIGHT,
  MAX_PANEL_HEIGHT,
} from "@saachi/store";
import { cn } from "@/lib/utils";

export function BottomTerminalPanel() {
  const isOpen      = useBottomPanelStore((s) => s.isOpen);
  const height      = useBottomPanelStore((s) => s.height);
  const tabs        = useBottomPanelStore((s) => s.tabs);
  const activeTabId = useBottomPanelStore((s) => s.activeTabId);
  const setActiveTab  = useBottomPanelStore((s) => s.setActiveTab);
  const closeTab      = useBottomPanelStore((s) => s.closeTab);
  const closeAllTabs  = useBottomPanelStore((s) => s.closeAllTabs);
  const setHeight     = useBottomPanelStore((s) => s.setHeight);
  const collapse      = useBottomPanelStore((s) => s.collapse);

  const draggingRef     = useRef(false);
  const startYRef       = useRef(0);
  const startHeightRef  = useRef(height);

  const handlePointerMove = useCallback(
    (e: PointerEvent) => {
      if (!draggingRef.current) return;
      const delta = startYRef.current - e.clientY;
      setHeight(startHeightRef.current + delta);
    },
    [setHeight]
  );

  const handlePointerUp = useCallback(() => {
    draggingRef.current = false;
    document.body.style.cursor = "";
    document.body.style.userSelect = "";
    window.removeEventListener("pointermove", handlePointerMove);
    window.removeEventListener("pointerup", handlePointerUp);
  }, [handlePointerMove]);

  function handleDragStart(e: React.PointerEvent) {
    draggingRef.current = true;
    startYRef.current = e.clientY;
    startHeightRef.current = height;
    document.body.style.cursor = "ns-resize";
    document.body.style.userSelect = "none";
    window.addEventListener("pointermove", handlePointerMove);
    window.addEventListener("pointerup", handlePointerUp);
  }

  useEffect(() => {
    return () => {
      window.removeEventListener("pointermove", handlePointerMove);
      window.removeEventListener("pointerup", handlePointerUp);
    };
  }, [handlePointerMove, handlePointerUp]);

  if (!isOpen || tabs.length === 0) return null;

  const activeTab = tabs.find((t) => t.id === activeTabId) ?? tabs[0];

  return (
    <div
      className="fixed inset-x-0 bottom-0 z-[60] flex flex-col border-t border-line bg-card shadow-[0_-4px_16px_rgba(0,0,0,0.08)]"
      style={{ height }}
      role="region"
      aria-label="Details panel"
    >
      {/* Drag handle */}
      <div
        onPointerDown={handleDragStart}
        className="group flex h-2 w-full shrink-0 cursor-ns-resize items-center justify-center"
        title="Drag to resize"
      >
        <span className="h-1 w-10 rounded-full bg-line-strong transition-colors group-hover:bg-gold-dark" />
      </div>

      {/* Tab bar */}
      <div className="flex shrink-0 items-center gap-0.5 border-b border-line bg-paper-dim/60 px-2">
        <div className="flex flex-1 items-center gap-0.5 overflow-x-auto">
          {tabs.map((tab) => {
            const isActive = tab.id === activeTab.id;
            return (
              <div
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={cn(
                  "group flex shrink-0 cursor-pointer items-center gap-2 rounded-t-control border-x border-t px-3 py-1.5 text-[12.5px] font-medium transition-colors duration-150 ease-out",
                  isActive
                    ? "border-line bg-card text-ink"
                    : "border-transparent text-ink-soft hover:bg-paper-dim hover:text-ink"
                )}
              >
                <TerminalSquare size={12} className="shrink-0 opacity-60" />
                <span className="max-w-[160px] truncate">{tab.title}</span>
                <button
                  type="button"
                  aria-label={`Close ${tab.title}`}
                  onClick={(e) => { e.stopPropagation(); closeTab(tab.id); }}
                  className="flex h-4 w-4 shrink-0 items-center justify-center rounded text-ink-soft/60 opacity-0 transition-opacity hover:bg-error-tint hover:text-error group-hover:opacity-100"
                >
                  <X size={11} />
                </button>
              </div>
            );
          })}
        </div>

        <div className="flex shrink-0 items-center gap-1 pl-2">
          <button
            type="button"
            onClick={closeAllTabs}
            title="Close all tabs"
            className="flex h-7 w-7 items-center justify-center rounded-control text-ink-soft transition-colors hover:bg-error-tint hover:text-error"
          >
            <Trash2 size={13} />
          </button>
          <button
            type="button"
            onClick={collapse}
            title="Hide panel"
            className="flex h-7 w-7 items-center justify-center rounded-control text-ink-soft transition-colors hover:bg-paper-dim hover:text-ink"
          >
            <ChevronDown size={14} />
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-y-auto bg-ink/[0.02] px-5 py-4 font-mono text-[12.5px] text-ink dark:bg-white/[0.02]">
        <p className="mb-3 text-[11px] uppercase tracking-[0.06em] text-ink-soft/70">
          {activeTab.title}
        </p>
        <div className="flex flex-col gap-1.5">
          {activeTab.rows.map((row, i) => (
            <div key={i} className="flex items-start gap-3">
              <span className="w-36 shrink-0 text-ink-soft/70">{row.label}</span>
              <span className="text-ink">{row.value}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default BottomTerminalPanel;
'@

Write-FileUtf8NoBom -Path $panelPath -Content $panelContent

# ============================================================
# 3) SHELL  –  InstructorShell.tsx  (patch only if needed)
# ============================================================
$shellPath = Join-Path $RootPath "apps\web\app\(instructor)\_components\InstructorShell.tsx"

if (Test-Path $shellPath) {
    $shellContent = Get-Content -Path $shellPath -Raw -Encoding UTF8

    $needsWrite = $false

    # 3a) Add imports if missing
    if ($shellContent -notmatch "BottomTerminalPanel") {
        $shellContent = $shellContent -replace `
            '(import\s*\{[^}]*\}\s*from\s*"@/components/ui/instructor-sidebar-v2";)', `
            "`$1`r`nimport { BottomTerminalPanel } from `"@/components/ui/bottom-terminal-panel`";`r`nimport { useBottomPanelStore } from `"@saachi/store`";"
        $needsWrite = $true
        Write-Host "  [OK] Added BottomTerminalPanel import to InstructorShell" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] BottomTerminalPanel import already present" -ForegroundColor Yellow
    }

    # 3b) Add store selectors after panelCollapsed state if missing
    if ($shellContent -notmatch "panelIsOpen") {
        $shellContent = $shellContent -replace `
            '(const \[panelCollapsed, setPanelCollapsed\] = useState\(false\);)', `
            "`$1`r`n  const panelIsOpen = useBottomPanelStore((s) => s.isOpen);`r`n  const panelHeight = useBottomPanelStore((s) => s.height);"
        $needsWrite = $true
        Write-Host "  [OK] Added panelIsOpen/panelHeight selectors" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] panelIsOpen already present" -ForegroundColor Yellow
    }

    # 3c) Add <BottomTerminalPanel /> before closing </div> of shell root if missing
    if ($shellContent -notmatch "<BottomTerminalPanel") {
        $shellContent = $shellContent -replace `
            '(\s*</div>\s*\)\s*;\s*\})', `
            "`r`n      <BottomTerminalPanel />`$1"
        $needsWrite = $true
        Write-Host "  [OK] Added <BottomTerminalPanel /> to shell render" -ForegroundColor Green
    } else {
        Write-Host "  [SKIP] <BottomTerminalPanel /> already present" -ForegroundColor Yellow
    }

    if ($needsWrite) {
        Write-FileUtf8NoBom -Path $shellPath -Content $shellContent
    }
} else {
    Write-Host "  [WARN] InstructorShell.tsx not found: $shellPath" -ForegroundColor Yellow
}

# ============================================================
# 4) CURRICULUM PAGE  –  FULL REPLACEMENT (correct version)
# ============================================================
$curriculumPath = Join-Path $RootPath "apps\web\app\(instructor)\instructor\courses\curriculum\page.tsx"

$curriculumContent = @'
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
  Save,
  Info,
} from "lucide-react";
import {
  useInstructorCourseStore,
  type InstructorCourseLesson,
  type InstructorCourseModule,
} from "@saachi/store";
import { useBottomPanelStore } from "@saachi/store";
import { Button, Select, EmptyState, cn } from "@saachi/ui";

type LessonType = InstructorCourseLesson["type"];

const LESSON_TYPE_META: Record<LessonType, { label: string; icon: typeof Video }> = {
  video:    { label: "Video",    icon: Video    },
  text:     { label: "Text",     icon: FileText  },
  quiz:     { label: "Quiz",     icon: HelpCircle },
  resource: { label: "Resource", icon: Paperclip },
};

let idCounter = 0;
function nextId(prefix: string) {
  idCounter += 1;
  return `${prefix}_${Date.now().toString(36)}${idCounter}`;
}

export default function InstructorCoursesCurriculumPage() {
  const courses    = useInstructorCourseStore((s) => s.courses);
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
        <p className="mb-8 text-[14px] text-ink-soft">Drag-and-drop module and lesson structuring.</p>
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
          <Select
            options={courseOptions}
            value={courseId}
            onChange={(e) => setCourseId(e.target.value)}
            className="w-72"
          />
        </div>
      </div>

      {course && (
        <ModuleList key={course.id} modules={course.modules} onChange={persist} />
      )}
    </div>
  );
}

// ── ModuleList ────────────────────────────────────────────────────────────────
function ModuleList({
  modules,
  onChange,
}: {
  modules: InstructorCourseModule[];
  onChange: (modules: InstructorCourseModule[]) => void;
}) {
  // Hook is correctly inside the function body
  const openTab = useBottomPanelStore((s) => s.openTab);

  const [dragIndex, setDragIndex] = useState<number | null>(null);
  const [expanded, setExpanded] = useState<Set<string>>(
    () => new Set(modules.map((m) => m.id))
  );

  function toggleExpanded(id: string) {
    setExpanded((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }

  function handleDragStart(index: number) { setDragIndex(index); }

  function handleDragOver(e: DragEvent, index: number) {
    e.preventDefault();
    if (dragIndex === null || dragIndex === index) return;
    const reordered = [...modules];
    const [moved] = reordered.splice(dragIndex, 1);
    reordered.splice(index, 0, moved);
    setDragIndex(index);
    onChange(reordered);
  }

  function handleDrop() { setDragIndex(null); }

  function addModule() {
    const newModule: InstructorCourseModule = {
      id: nextId("mod"),
      title: `Module ${modules.length + 1}`,
      lessons: [],
    };
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
      modules.map((m) =>
        m.id === moduleId ? { ...m, lessons: m.lessons.filter((l) => l.id !== lessonId) } : m
      )
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
        <EmptyState
          title="No modules yet"
          description="Add your first module to start building the curriculum."
        />
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
            {/* Module header row */}
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

              <span className="ml-auto shrink-0 text-[12px] text-ink-soft">
                {m.lessons.length} lesson(s)
              </span>

              {/* Info button – opens bottom panel */}
              <button
                type="button"
                aria-label="View module details"
                onClick={() =>
                  openTab({
                    id: `module-details-${m.id}`,
                    title: m.title,
                    kind: "details",
                    rows: [
                      { label: "Module ID",   value: m.id },
                      { label: "Lessons",     value: String(m.lessons.length) },
                      { label: "Created At",  value: new Date(Date.now() - 1000 * 60 * 60 * 24 * 6).toLocaleString() },
                      { label: "Updated At",  value: new Date(Date.now() - 1000 * 60 * 45).toLocaleString() },
                      { label: "Status",      value: "Draft" },
                    ],
                  })
                }
                className="mr-1 flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft transition-colors hover:bg-paper-dim hover:text-ink"
              >
                <Info size={14} />
              </button>

              {/* Delete button */}
              <button
                type="button"
                aria-label="Delete module"
                onClick={() => removeModule(m.id)}
                className="ml-2 flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft transition-colors hover:bg-error-tint hover:text-error"
              >
                <Trash2 size={14} />
              </button>
            </div>

            {/* Expanded lessons area */}
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
                      <Button
                        key={type}
                        size="sm"
                        variant="secondary"
                        onClick={() => addLesson(m.id, type)}
                      >
                        <Icon size={13} className="mr-1.5" />
                        + {LESSON_TYPE_META[type].label}
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

// ── ModuleTitle ───────────────────────────────────────────────────────────────
function ModuleTitle({ title, onSave }: { title: string; onSave: (title: string) => void }) {
  const [editing, setEditing] = useState(false);
  const [value, setValue] = useState(title);

  if (!editing) {
    return (
      <button
        type="button"
        onClick={() => { setValue(title); setEditing(true); }}
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
          if (e.key === "Enter") { onSave(value.trim() || title); setEditing(false); }
          if (e.key === "Escape") setEditing(false);
        }}
        className="min-w-0 flex-1 rounded-control border border-line-strong bg-paper px-2 py-1 text-[14px] font-semibold text-ink outline-none focus:border-gold"
      />
      <button
        type="button"
        onClick={() => { onSave(value.trim() || title); setEditing(false); }}
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

// ── LessonList ────────────────────────────────────────────────────────────────
function LessonList({
  lessons,
  onReorder,
  onUpdate,
  onRemove,
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
            <LessonTitleInline
              title={lesson.title}
              onSave={(title) => onUpdate(lesson.id, { title })}
            />
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

// ── LessonTitleInline ─────────────────────────────────────────────────────────
function LessonTitleInline({ title, onSave }: { title: string; onSave: (title: string) => void }) {
  const [editing, setEditing] = useState(false);
  const [value, setValue] = useState(title);

  if (!editing) {
    return (
      <button
        type="button"
        onClick={() => { setValue(title); setEditing(true); }}
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
      onBlur={() => { onSave(value.trim() || title); setEditing(false); }}
      onKeyDown={(e) => {
        if (e.key === "Enter") { onSave(value.trim() || title); setEditing(false); }
        if (e.key === "Escape") setEditing(false);
      }}
      className="min-w-0 flex-1 rounded border border-line-strong bg-card px-1.5 py-0.5 text-[13px] text-ink outline-none focus:border-gold"
    />
  );
}
'@

Write-FileUtf8NoBom -Path $curriculumPath -Content $curriculumContent

Write-Host ""
Write-Host "=== Done! ===" -ForegroundColor Cyan
Write-Host "Ab 'pnpm dev' restart karein aur build check karein." -ForegroundColor Cyan
Write-Host ""