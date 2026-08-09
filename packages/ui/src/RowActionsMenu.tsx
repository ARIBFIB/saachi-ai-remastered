"use client";

import { useEffect, useRef, useState, type ReactNode } from "react";
import { MoreVertical } from "lucide-react";

export type RowAction = {
  id: string;
  label: string;
  icon?: ReactNode;
  onClick: () => void;
  tone?: "default" | "danger";
  disabled?: boolean;
};

type RowActionsMenuProps = {
  actions: RowAction[];
  ariaLabel?: string;
};

export function RowActionsMenu({ actions, ariaLabel = "Row actions" }: RowActionsMenuProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    if (open) {
      document.addEventListener("mousedown", handleClickOutside);
    }
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [open]);

  return (
    <div className="relative inline-block" ref={ref}>
      <button
        type="button"
        onClick={(e) => {
          e.stopPropagation();
          setOpen((v) => !v);
        }}
        aria-label={ariaLabel}
        className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
      >
        <MoreVertical size={15} strokeWidth={1.75} />
      </button>

      {open && (
        <div
          onClick={(e) => e.stopPropagation()}
          className="absolute right-0 top-[calc(100%+4px)] z-30 w-[190px] overflow-hidden rounded-card border border-line bg-card shadow-lg"
        >
          <div className="flex flex-col p-1.5">
            {actions.map((action) => (
              <button
                key={action.id}
                type="button"
                disabled={action.disabled}
                onClick={() => {
                  action.onClick();
                  setOpen(false);
                }}
                className={`flex items-center gap-2.5 rounded-control px-3 py-2 text-left text-[13px] transition-colors duration-100 ease-out disabled:cursor-not-allowed disabled:opacity-40 ${
                  action.tone === "danger"
                    ? "text-error hover:bg-error-tint"
                    : "text-ink hover:bg-paper-dim"
                }`}
              >
                {action.icon}
                {action.label}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}