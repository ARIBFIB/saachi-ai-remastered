<#
    Add-BottomTerminalPanel.ps1
    ---------------------------
    Adds a VS Code-style bottom terminal panel to the Instructor module:
      - Multiple tabs (each tab = details view, e.g. created/updated timestamps)
      - Close (X) button per tab
      - Drag-to-resize from the top edge
      - Full-width, bottom-attached, collapsible
      - FRONTEND ONLY, dummy data only. No backend calls.

    Run from SAI2 root:
      .\Add-BottomTerminalPanel.ps1
#>

param(
    [string]$RootPath = (Get-Location).Path
)

function Write-FileUtf8NoBom {
    param([string]$Path, [string]$Content)
    $dir = Split-Path -Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Regex-ReplaceInFile {
    param(
        [string]$Path,
        [string]$Pattern,
        [string]$Replacement,
        [string]$Description
    )
    if (-not (Test-Path $Path)) {
        Write-Host "  [SKIP] File not found: $Path" -ForegroundColor Yellow
        return $false
    }
    $content = Get-Content -Path $Path -Raw -Encoding UTF8
    $regex = New-Object System.Text.RegularExpressions.Regex($Pattern)
    if (-not $regex.IsMatch($content)) {
        Write-Host "  [SKIP] Pattern not found for: $Description ($Path)" -ForegroundColor Yellow
        return $false
    }
    $newContent = $regex.Replace($content, $Replacement, 1)
    Write-FileUtf8NoBom -Path $Path -Content $newContent
    Write-Host "  [OK] $Description" -ForegroundColor Green
    return $true
}

Write-Host ""
Write-Host "=== Adding Bottom Terminal Panel (Instructor module) ===" -ForegroundColor Cyan
Write-Host ""

# ============================================================
# 1) STORE: packages/store/src/useBottomPanelStore.ts
# ============================================================
$storePath = Join-Path $RootPath "packages\store\src\useBottomPanelStore.ts"

$storeContent = @'
"use client";

import { create } from "zustand";

/**
 * Bottom Terminal Panel store (VS Code-style).
 * Frontend-only, dummy data. Manages open tabs, active tab, panel height,
 * and open/collapsed state. Any part of the instructor UI can call
 * `openTab(...)` to push a new details tab into the panel.
 */

export type BottomPanelTabKind = "details" | "log" | "info";

export type BottomPanelDetailRow = {
  label: string;
  value: string;
};

export type BottomPanelTab = {
  id: string;
  title: string;
  kind: BottomPanelTabKind;
  // Generic rows shown terminal-style, e.g. Created At / Updated At / Status
  rows: BottomPanelDetailRow[];
};

type BottomPanelState = {
  isOpen: boolean;
  height: number; // px
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
      // Refresh content of an already-open tab and just focus it.
      set((state) => ({
        tabs: state.tabs.map((t) => (t.id === tab.id ? tab : t)),
        activeTabId: tab.id,
        isOpen: true
      }));
      return;
    }
    set((state) => ({
      tabs: [...state.tabs, tab],
      activeTabId: tab.id,
      isOpen: true
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
        isOpen: remaining.length > 0 ? state.isOpen : false
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

  collapse: () => set({ isOpen: false })
}));
'@

Write-FileUtf8NoBom -Path $storePath -Content $storeContent
Write-Host "[CREATED] $storePath" -ForegroundColor Green

# ------------------------------------------------------------
# Export it from packages/store/src/index.ts (if not already)
# ------------------------------------------------------------
$storeIndexPath = Join-Path $RootPath "packages\store\src\index.ts"
if (Test-Path $storeIndexPath) {
    $indexContent = Get-Content -Path $storeIndexPath -Raw -Encoding UTF8
    if ($indexContent -notmatch "useBottomPanelStore") {
        $appended = $indexContent.TrimEnd() + "`r`nexport * from `"./useBottomPanelStore`";`r`n"
        Write-FileUtf8NoBom -Path $storeIndexPath -Content $appended
        Write-Host "[OK] Exported useBottomPanelStore from store index.ts" -ForegroundColor Green
    }
    else {
        Write-Host "[SKIP] useBottomPanelStore already exported in index.ts" -ForegroundColor Yellow
    }
}
else {
    Write-Host "[WARN] packages\store\src\index.ts not found - export it manually." -ForegroundColor Yellow
}

# ============================================================
# 2) COMPONENT: apps/web/components/ui/bottom-terminal-panel.tsx
# ============================================================
$panelPath = Join-Path $RootPath "apps\web\components\ui\bottom-terminal-panel.tsx"

$panelContent = @'
"use client";

/**
 * BottomTerminalPanel
 * --------------------
 * VS Code-style bottom panel: multiple tabs, close (X) per tab,
 * drag-to-resize from the top edge, full-width, bottom-attached.
 * Frontend-only. Content is whatever the caller passed via
 * useBottomPanelStore().openTab({ ... dummy rows ... }).
 */

import { useCallback, useEffect, useRef } from "react";
import { X, TerminalSquare, ChevronDown, Trash2 } from "lucide-react";
import {
  useBottomPanelStore,
  MIN_PANEL_HEIGHT,
  MAX_PANEL_HEIGHT
} from "@saachi/store";
import { cn } from "@/lib/utils";

export function BottomTerminalPanel() {
  const isOpen = useBottomPanelStore((s) => s.isOpen);
  const height = useBottomPanelStore((s) => s.height);
  const tabs = useBottomPanelStore((s) => s.tabs);
  const activeTabId = useBottomPanelStore((s) => s.activeTabId);
  const setActiveTab = useBottomPanelStore((s) => s.setActiveTab);
  const closeTab = useBottomPanelStore((s) => s.closeTab);
  const closeAllTabs = useBottomPanelStore((s) => s.closeAllTabs);
  const setHeight = useBottomPanelStore((s) => s.setHeight);
  const collapse = useBottomPanelStore((s) => s.collapse);

  const draggingRef = useRef(false);
  const startYRef = useRef(0);
  const startHeightRef = useRef(height);

  const handlePointerMove = useCallback(
    (e: PointerEvent) => {
      if (!draggingRef.current) return;
      const delta = startYRef.current - e.clientY; // drag up = increase height
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
      {/* Drag handle - top edge, full width */}
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
                  onClick={(e) => {
                    e.stopPropagation();
                    closeTab(tab.id);
                  }}
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

      {/* Panel content - terminal style */}
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
Write-Host "[CREATED] $panelPath" -ForegroundColor Green

# ============================================================
# 3) WIRE INTO InstructorShell.tsx
# ============================================================
$shellPath = Join-Path $RootPath "apps\web\app\(instructor)\_components\InstructorShell.tsx"

Write-Host ""
Write-Host "Patching InstructorShell.tsx ..." -ForegroundColor Cyan

# 3a) Add import (after the InstructorSearchBar import line)
Regex-ReplaceInFile -Path $shellPath `
  -Pattern 'import\s*\{\s*INSTRUCTOR_SIDEBAR,[^\}]*\}\s*from\s*"@/components/ui/instructor-sidebar-v2";' `
  -Replacement "`$0`r`nimport { BottomTerminalPanel } from `"@/components/ui/bottom-terminal-panel`";`r`nimport { useBottomPanelStore } from `"@saachi/store`";" `
  -Description "Add BottomTerminalPanel + store import"

# 3b) Render the panel + adjust bottom padding of main content when panel open
Regex-ReplaceInFile -Path $shellPath `
  -Pattern '(\s*)<div className=\{`transition-\[margin\] duration-300 ease-out \$\{sidebarOffsetClass\}`\}>\s*<main className="mx-auto max-w-\[1200px\] px-4 py-8 md:px-8 md:py-10">\{children\}</main>\s*</div>' `
  -Replacement @'
$1<div className={`transition-[margin] duration-300 ease-out ${sidebarOffsetClass}`}>
        <main
          className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10 transition-[padding] duration-150 ease-out"
          style={{ paddingBottom: panelIsOpen ? panelHeight + 32 : undefined }}
        >
          {children}
        </main>
      </div>

      <BottomTerminalPanel />
'@ `
  -Description "Render BottomTerminalPanel + reserve bottom space when open"

# 3c) Add panelIsOpen / panelHeight hooks near other useState hooks
Regex-ReplaceInFile -Path $shellPath `
  -Pattern 'const \[panelCollapsed, setPanelCollapsed\] = useState\(false\);' `
  -Replacement "`$0`r`n  const panelIsOpen = useBottomPanelStore((s) => s.isOpen);`r`n  const panelHeight = useBottomPanelStore((s) => s.height);" `
  -Description "Add panelIsOpen / panelHeight selectors"

# ============================================================
# 4) DEMO WIRING: Curriculum Builder - "Info" button per module
#    opens a details tab with dummy created/updated timestamps.
# ============================================================
$curriculumPath = Join-Path $RootPath "apps\web\app\(instructor)\instructor\courses\curriculum\page.tsx"

Write-Host ""
Write-Host "Patching Curriculum Builder page (demo trigger) ..." -ForegroundColor Cyan

Regex-ReplaceInFile -Path $curriculumPath `
  -Pattern 'import \{ Button, Select, EmptyState, cn \} from "@saachi/ui";' `
  -Replacement "`$0`r`nimport { Info } from `"lucide-react`";`r`nimport { useBottomPanelStore } from `"@saachi/store`";" `
  -Description "Add Info icon + useBottomPanelStore import"

# Insert an "Info" button next to the delete-module button, opening a details tab.
Regex-ReplaceInFile -Path $curriculumPath `
  -Pattern '(function ModuleList\(\{\s*modules,\s*onChange\s*\}[^\{]*\{\s*)' `
  -Replacement "`$1`r`n  const openTab = useBottomPanelStore((s) => s.openTab);`r`n" `
  -Description "Add openTab hook inside ModuleList"

Regex-ReplaceInFile -Path $curriculumPath `
  -Pattern '(<button\s*\r?\n\s*type="button"\s*\r?\n\s*aria-label="Delete module")' `
  -Replacement @'
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
              $1
'@ `
  -Description "Add per-module Info button that opens a bottom-panel details tab"

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host "Restart 'pnpm dev' (or your dev server) to see the changes." -ForegroundColor Cyan
Write-Host ""