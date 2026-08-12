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
        className="flex h-4 w-4 items-center justify-center border transition"
        style={{
          borderColor: checked ? "var(--token-color-amberDark)" : "var(--token-color-blueprintLine)",
          backgroundColor: checked ? "var(--token-color-amber)" : "var(--token-color-surface)",
        }}
      >
        {checked && <Check className="h-3 w-3" style={{ color: "var(--token-color-inkDeep)" }} strokeWidth={3} />}
      </button>
      <span className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>{label}</span>
    </label>
  );
}

export function FilterSidebar() {
  const [selectedCategories, setSelectedCategories] = useState<string[]>(["Machine Learning"]);
  const [selectedLevels, setSelectedLevels] = useState<string[]>(["Intermediate"]);

  function toggle(list: string[], setList: (v: string[]) => void, value: string) {
    setList(list.includes(value) ? list.filter((v) => v !== value) : [...list, value]);
  }

  return (
    <aside className="w-56 border p-6" style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}>
      <div className="flex flex-col gap-4">
        <h3
          className="text-xs font-semibold uppercase tracking-[0.1em]"
          style={{ color: "var(--token-color-inkDeep)" }}
        >
          Category
        </h3>
        <div className="flex flex-col gap-2">
          {categories.map((c) => (
            <Checkbox key={c} label={c} checked={selectedCategories.includes(c)} onChange={() => toggle(selectedCategories, setSelectedCategories, c)} />
          ))}
        </div>
      </div>

      <hr className="my-6" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }} />

      <div className="flex flex-col gap-4">
        <h3
          className="text-xs font-semibold uppercase tracking-[0.1em]"
          style={{ color: "var(--token-color-inkDeep)" }}
        >
          Level
        </h3>
        <div className="flex flex-col gap-2">
          {levels.map((l) => (
            <Checkbox key={l} label={l} checked={selectedLevels.includes(l)} onChange={() => toggle(selectedLevels, setSelectedLevels, l)} />
          ))}
        </div>
      </div>

      <hr className="my-6" style={{ borderColor: "var(--token-color-blueprintLineSoft)" }} />

      <div className="flex flex-col gap-4">
        <h3
          className="text-xs font-semibold uppercase tracking-[0.1em]"
          style={{ color: "var(--token-color-inkDeep)" }}
        >
          Price
        </h3>
        <div className="flex flex-col gap-2">
          <input type="range" min={0} max={200} defaultValue={200} className="h-1 w-full" style={{ accentColor: "var(--token-color-amberDark)" }} />
          <div className="flex justify-between text-xs font-medium" style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-inkDeepSoft)" }}>
            <span>$0</span>
            <span>$200+</span>
          </div>
        </div>
      </div>
    </aside>
  );
}