"use client";

import { useState } from "react";

export interface FilterTab {
  label: string;
  count: number;
}

interface ResultFilterTabsProps {
  tabs: FilterTab[];
}

export function ResultFilterTabs({ tabs }: ResultFilterTabsProps) {
  const [active, setActive] = useState(tabs[0]?.label);

  return (
    <div className="flex flex-wrap items-center gap-2 pt-4">
      {tabs.map((tab) => {
        const isActive = tab.label === active;
        return (
          <button
            key={tab.label}
            type="button"
            onClick={() => setActive(tab.label)}
            className={`rounded-full px-4 pb-2 pt-1.5 text-xs font-medium transition ${
              isActive
                ? "bg-[var(--token-color-primaryTint)] text-[var(--token-color-primary)] outline outline-1 outline-offset-[-1px] outline-[var(--token-color-primary)]"
                : "bg-zinc-200 text-[var(--token-color-inkSoft)] outline outline-1 outline-offset-[-1px] outline-[var(--token-color-border)]"
            }`}
          >
            {tab.label}
            {tab.count > 0 && ` (${tab.count})`}
          </button>
        );
      })}
    </div>
  );
}