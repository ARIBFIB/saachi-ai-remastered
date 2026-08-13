"use client";

import { useState } from "react";

interface CategoryChipsProps {
  chips: string[];
  defaultActive?: string;
  onChange?: (chip: string) => void;
}

export function CategoryChips({ chips, defaultActive, onChange }: CategoryChipsProps) {
  const [active, setActive] = useState(defaultActive ?? chips[0]);

  function handleSelect(chip: string) {
    setActive(chip);
    onChange?.(chip);
  }

  return (
    <div className="flex flex-wrap items-start gap-2 self-stretch pt-4">
      {chips.map((chip) => {
        const isActive = chip === active;
        return (
          <button
            key={chip}
            type="button"
            onClick={() => handleSelect(chip)}
            className={`rounded-full border-2 px-4 py-2 text-sm font-semibold tracking-wide transition ${
              isActive
                ? "border-[var(--token-color-primary)]/20 bg-[var(--token-color-primary)]/10 text-[var(--token-color-primary)]"
                : "border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] text-[var(--token-color-inkSoft)]"
            }`}
          >
            {chip}
          </button>
        );
      })}
    </div>
  );
}