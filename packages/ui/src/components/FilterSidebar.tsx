"use client";

import { Checkbox } from "./Checkbox";
import { Select } from "./Select";
import { cn } from "../cn";

export type FilterSidebarValue = {
  categories: string[];
  level?: string;
  language?: string;
};

export type FilterSidebarProps = {
  categoryOptions: { label: string; value: string }[];
  levelOptions: { label: string; value: string }[];
  languageOptions: { label: string; value: string }[];
  value: FilterSidebarValue;
  onChange: (next: FilterSidebarValue) => void;
  className?: string;
};

export function FilterSidebar({
  categoryOptions,
  levelOptions,
  languageOptions,
  value,
  onChange,
  className
}: FilterSidebarProps) {
  const toggleCategory = (cat: string) => {
    const isActive = value.categories.includes(cat);
    const nextCategories = isActive
      ? value.categories.filter((c) => c !== cat)
      : [...value.categories, cat];
    onChange({ ...value, categories: nextCategories });
  };

  return (
    <aside className={cn("flex w-full flex-col gap-8 rounded-card border border-line bg-card p-6", className)}>
      <div>
        <h4 className="mb-3 text-[13px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
          Category
        </h4>
        <div className="flex flex-col gap-2.5">
          {categoryOptions.map((opt) => (
            <Checkbox
              key={opt.value}
              label={opt.label}
              checked={value.categories.includes(opt.value)}
              onChange={() => toggleCategory(opt.value)}
            />
          ))}
        </div>
      </div>

      <Select
        label="Skill level"
        placeholder="All levels"
        options={levelOptions}
        value={value.level ?? ""}
        onChange={(e) => onChange({ ...value, level: e.target.value || undefined })}
      />

      <Select
        label="Language"
        placeholder="All languages"
        options={languageOptions}
        value={value.language ?? ""}
        onChange={(e) => onChange({ ...value, language: e.target.value || undefined })}
      />

      <button
        type="button"
        onClick={() => onChange({ categories: [], level: undefined, language: undefined })}
        className="text-left text-[13px] font-medium text-gold-dark hover:underline"
      >
        Clear all filters
      </button>
    </aside>
  );
}