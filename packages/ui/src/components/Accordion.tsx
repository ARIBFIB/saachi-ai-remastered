"use client";

import { useState, type ReactNode } from "react";
import { ChevronDown } from "lucide-react";
import { cn } from "../cn";

export type AccordionItemData = {
  id: string;
  title: ReactNode;
  content: ReactNode;
  meta?: ReactNode;
};

export type AccordionProps = {
  items: AccordionItemData[];
  defaultOpenId?: string;
  className?: string;
};

export function Accordion({ items, defaultOpenId, className }: AccordionProps) {
  const [openId, setOpenId] = useState<string | null>(defaultOpenId ?? null);

  return (
    <div
      className={cn(
        "flex flex-col overflow-hidden rounded-2xl border border-[var(--border-hairline,rgba(15,23,42,0.08))]",
        "divide-y divide-[var(--border-hairline,rgba(15,23,42,0.08))]",
        className
      )}
    >
      {items.map((item) => {
        const isOpen = openId === item.id;
        return (
          <div key={item.id} className="bg-[var(--surface-card,#FFFFFF)]">
            <button
              type="button"
              onClick={() => setOpenId(isOpen ? null : item.id)}
              className="flex w-full items-center justify-between gap-4 px-5 py-4 text-left"
              aria-expanded={isOpen}
            >
              <div className="flex flex-1 items-center gap-3">
                <span className="text-[15px] font-semibold text-[var(--text-primary,#0F172A)]">
                  {item.title}
                </span>
                {item.meta}
              </div>
              <ChevronDown
                size={18}
                className={cn(
                  "shrink-0 text-[var(--text-secondary,#475569)] transition-transform duration-200 ease-out",
                  isOpen && "rotate-180 text-[var(--blue-600,#2563EB)]"
                )}
              />
            </button>
            <div
              className={cn(
                "grid transition-all duration-200 ease-out",
                isOpen ? "grid-rows-[1fr] opacity-100" : "grid-rows-[0fr] opacity-0"
              )}
            >
              <div className="overflow-hidden">
                <div className="px-5 pb-4 text-[14px] leading-relaxed text-[var(--text-secondary,#475569)]">
                  {item.content}
                </div>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
