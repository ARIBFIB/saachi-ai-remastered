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
        className="flex items-center gap-8 border border-slate-300 bg-white px-3 py-2 text-base text-zinc-900 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]"
      >
        {value}
        <ChevronDown className="h-4 w-4 text-gray-500" />
      </button>

      {open && (
        <ul className="absolute right-0 top-full z-10 mt-1 w-48 border border-slate-300 bg-white shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
          {options.map((opt) => (
            <li key={opt}>
              <button
                onClick={() => {
                  setValue(opt);
                  setOpen(false);
                }}
                className="block w-full px-3 py-2 text-left text-sm text-zinc-900 hover:bg-gray-100"
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
