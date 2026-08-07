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
    <div className={cn("flex flex-col overflow-hidden rounded-card border border-line divide-y divide-line", className)}>
      {items.map((item) => {
        const isOpen = openId === item.id;
        return (
          <div key={item.id} className="bg-card">
            <button
              type="button"
              onClick={() => setOpenId(isOpen ? null : item.id)}
              className="flex w-full items-center justify-between gap-4 px-5 py-4 text-left"
              aria-expanded={isOpen}
            >
              <div className="flex flex-1 items-center gap-3">
                <span className="text-[15px] font-semibold text-ink">{item.title}</span>
                {item.meta}
              </div>
              <ChevronDown
                size={18}
                className={cn(
                  "shrink-0 text-ink-soft transition-transform duration-200 ease-out",
                  isOpen && "rotate-180 text-gold-dark"
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
                <div className="px-5 pb-4 text-[14px] leading-relaxed text-ink-soft">{item.content}</div>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}