"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

const options = ["Most Popular", "Highest Rated", "Newest", "Price: Low to High", "Price: High to Low"];

export function SortDropdown() {
  const [value, setValue] = useState(options[0]);
  const [open, setOpen] = useState(false);

  return (
    <div className="relative">
      <button
        onClick={() => setOpen((o) => !o)}
        className="flex items-center gap-8 border px-3 py-2 text-sm"
        style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)", color: "var(--token-color-inkDeep)" }}
      >
        {value}
        <ChevronDown className="h-4 w-4" style={{ color: "var(--token-color-inkDeepSoft)" }} />
      </button>

      {open && (
        <ul
          className="absolute right-0 top-full z-10 mt-1 w-48 border shadow-[0px_4px_20px_0px_rgba(15,23,42,0.08)]"
          style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}
        >
          {options.map((opt) => (
            <li key={opt}>
              <button
                onClick={() => { setValue(opt); setOpen(false); }}
                className="block w-full px-3 py-2 text-left text-sm hover:opacity-70"
                style={{ color: "var(--token-color-inkDeep)" }}
              >
                {opt}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}