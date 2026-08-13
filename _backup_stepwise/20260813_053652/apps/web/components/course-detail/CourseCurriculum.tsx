"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

interface Module {
  title: string;
  meta: string;
}

const modules: Module[] = [
  { title: "Module 1: Introduction to Large Language Models", meta: "3 lessons • 45 mins" },
  { title: "Module 2: Anatomy of a Perfect Prompt", meta: "5 lessons • 1hr 20 mins" },
];

function ModuleRow({ module }: { module: Module }) {
  const [open, setOpen] = useState(false);

  return (
    <div className="overflow-hidden rounded-xl border-2 border-slate-300/30 bg-slate-50 shadow-[var(--token-shadow-sm)]">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className="flex w-full items-center gap-4 bg-white p-4 text-left"
      >
        <ChevronDown
          className={`h-3 w-3 shrink-0 text-[#464555] transition-transform ${
            open ? "rotate-180" : ""
          }`}
        />
        <div>
          <h3 className="text-sm font-semibold tracking-wide text-zinc-900">
            {module.title}
          </h3>
          <p className="text-xs font-medium text-gray-700">{module.meta}</p>
        </div>
      </button>

      {open && (
        <div className="border-t border-slate-300/30 p-4 text-sm text-gray-700">
          Lesson content coming soon.
        </div>
      )}
    </div>
  );
}

export function CourseCurriculum() {
  return (
    <section className="flex w-full flex-col gap-6">
      <h2 className="text-2xl font-semibold text-zinc-900">Course Curriculum</h2>
      <div className="flex flex-col gap-4">
        {modules.map((m) => (
          <ModuleRow key={m.title} module={m} />
        ))}
      </div>
    </section>
  );
}
