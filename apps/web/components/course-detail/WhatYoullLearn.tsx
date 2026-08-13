import { Check } from "lucide-react";

const learningPoints = [
  "Core principles of LLM architecture",
  "Zero-shot and few-shot prompting techniques",
  "Chain-of-thought reasoning setups",
  "Preventing hallucinations and bias",
];

export function WhatYoullLearn() {
  return (
    <section className="w-full rounded-[var(--token-radius-lg)] border-2 border-[var(--token-color-inkDeep)] bg-slate-50 p-6 shadow-[var(--token-shadow-sm)]">
      <h2 className="mb-6 text-2xl font-semibold text-zinc-900">
        What you&apos;ll learn
      </h2>
      <div className="grid grid-cols-1 gap-x-8 gap-y-3 sm:grid-cols-2">
        {learningPoints.map((point) => (
          <div key={point} className="flex items-start gap-2">
            <Check className="mt-0.5 h-4 w-4 shrink-0 text-[var(--token-color-amber)]" strokeWidth={3} />
            <span className="text-base text-zinc-900">{point}</span>
          </div>
        ))}
      </div>
    </section>
  );
}
