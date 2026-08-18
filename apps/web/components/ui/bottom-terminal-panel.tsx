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