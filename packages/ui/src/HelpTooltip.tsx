"use client";

import { useEffect, useRef, useState } from "react";
import { HelpCircle } from "lucide-react";

type HelpTooltipProps = {
  text: string;
  className?: string;
};

export function HelpTooltip({ text, className = "" }: HelpTooltipProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    }
    if (open) document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, [open]);

  return (
    <div className={`relative inline-flex ${className}`} ref={ref}>
      <button
        type="button"
        onClick={(e) => {
          e.stopPropagation();
          setOpen((v) => !v);
        }}
        onMouseEnter={() => setOpen(true)}
        onMouseLeave={() => setOpen(false)}
        className="flex h-6 w-6 items-center justify-center rounded-full text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
        aria-label="Help"
      >
        <HelpCircle size={14} strokeWidth={1.75} />
      </button>

      {open && (
        <div
          onClick={(e) => e.stopPropagation()}
          className="absolute left-0 top-[calc(100%+6px)] z-20 w-[260px] rounded-control border border-line bg-card p-3 text-[12px] leading-relaxed text-ink-soft shadow-lg"
        >
          {text}
        </div>
      )}
    </div>
  );
}