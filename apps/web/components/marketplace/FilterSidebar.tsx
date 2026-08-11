"use client";

import { useState } from "react";
import { Check } from "lucide-react";

const categories = ["Machine Learning", "Deep Learning", "NLP", "Generative AI"];
const levels = ["Beginner", "Intermediate", "Advanced"];

function Checkbox({
  label,
  checked,
  onChange,
}: {
  label: string;
  checked: boolean;
  onChange: () => void;
}) {
  return (
    <label className="flex cursor-pointer items-center gap-2">
      <button
        type="button"
        onClick={onChange}
        className={`flex h-4 w-4 items-center justify-center rounded-sm border transition ${
          checked
            ? "border-[#3525CD] bg-[#3525CD]"
            : "border-[#C7C4D8] bg-white"
        }`}
      >
        {checked && <Check className="h-3 w-3 text-white" strokeWidth={3} />}
      </button>
      <span className="text-base text-slate-600">{label}</span>
    </label>
  );
}

export function FilterSidebar() {
  const [selectedCategories, setSelectedCategories] = useState<string[]>([
    "Machine Learning",
  ]);
  const [selectedLevels, setSelectedLevels] = useState<string[]>([
    "Intermediate",
  ]);

  function toggle(
    list: string[],
    setList: (v: string[]) => void,
    value: string
  ) {
    setList(
      list.includes(value) ? list.filter((v) => v !== value) : [...list, value]
    );
  }

  return (
    <aside className="w-56 rounded-xl border border-slate-300/30 bg-white p-6 shadow-[0px_4px_20px_0px_rgba(15,23,42,0.05)]">
      <div className="flex flex-col gap-4">
        <h3 className="text-sm font-semibold tracking-wide text-zinc-900">
          Category
        </h3>
        <div className="flex flex-col gap-2">
          {categories.map((c) => (
            <Checkbox
              key={c}
              label={c}
              checked={selectedCategories.includes(c)}
              onChange={() => toggle(selectedCategories, setSelectedCategories, c)}
            />
          ))}
        </div>
      </div>

      <hr className="my-6 border-slate-300/50" />

      <div className="flex flex-col gap-4">
        <h3 className="text-sm font-semibold tracking-wide text-zinc-900">
          Level
        </h3>
        <div className="flex flex-col gap-2">
          {levels.map((l) => (
            <Checkbox
              key={l}
              label={l}
              checked={selectedLevels.includes(l)}
              onChange={() => toggle(selectedLevels, setSelectedLevels, l)}
            />
          ))}
        </div>
      </div>

      <hr className="my-6 border-slate-300/50" />

      <div className="flex flex-col gap-4">
        <h3 className="text-sm font-semibold tracking-wide text-zinc-900">
          Price
        </h3>
        <div className="flex flex-col gap-2">
          <input
            type="range"
            min={0}
            max={200}
            defaultValue={200}
            className="h-1 w-full accent-[#3525CD]"
          />
          <div className="flex justify-between text-xs font-medium text-gray-500">
            <span>$0</span>
            <span>$200+</span>
          </div>
        </div>
      </div>
    </aside>
  );
}
