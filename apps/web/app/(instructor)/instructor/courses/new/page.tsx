"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Check } from "lucide-react";
import { Button, Input, Select, Textarea, EmptyState, cn } from "@saachi/ui";
import { CATEGORIES } from "../../../../../lib/categories";

const STEPS = ["Basics", "Curriculum", "Pricing", "Media", "Review & Submit"];

const LEVEL_OPTIONS = [
  { label: "Beginner", value: "beginner" },
  { label: "Intermediate", value: "intermediate" },
  { label: "Advanced", value: "advanced" }
];

const LANGUAGE_OPTIONS = [
  { label: "English", value: "en" },
  { label: "Urdu", value: "ur" }
];

type LessonType = "video" | "text" | "quiz" | "resource";

type Lesson = { id: string; title: string; type: LessonType };
type Module = { id: string; title: string; lessons: Lesson[] };

let idCounter = 0;
function nextId() {
  idCounter += 1;
  return `m${idCounter}`;
}

export default function CourseWizardPage() {
  const router = useRouter();
  const [step, setStep] = useState(0);
  const [submitted, setSubmitted] = useState(false);

  // Step 1: Basics
  const [title, setTitle] = useState("");
  const [subtitle, setSubtitle] = useState("");
  const [category, setCategory] = useState(CATEGORIES[0]?.id ?? "");
  const [level, setLevel] = useState("beginner");
  const [language, setLanguage] = useState("en");

  // Step 2: Curriculum
  const [modules, setModules] = useState<Module[]>([]);

  function addModule() {
    setModules((prev) => [...prev, { id: nextId(), title: `Module ${prev.length + 1}`, lessons: [] }]);
  }

  function addLesson(moduleId: string, type: LessonType) {
    setModules((prev) =>
      prev.map((m) =>
        m.id === moduleId
          ? { ...m, lessons: [...m.lessons, { id: nextId(), title: `New ${type} lesson`, type }] }
          : m
      )
    );
  }

  // Step 3: Pricing
  const [price, setPrice] = useState("");
  const [currency, setCurrency] = useState("USD");
  const [includeInSubscription, setIncludeInSubscription] = useState(false);

  // Step 4: Media
  const [thumbnailUrl, setThumbnailUrl] = useState("");
  const [promoVideoUrl, setPromoVideoUrl] = useState("");

  const canGoNext = (() => {
    if (step === 0) return title.trim().length > 0 && category.length > 0;
    if (step === 1) return modules.length > 0;
    if (step === 2) return price.trim().length > 0;
    return true;
  })();

  function handleSubmit() {
    // NOTE: demo-only, no backend course-creation mutation wired up yet.
    setSubmitted(true);
  }

  if (submitted) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Course submitted for review"
          description="Our moderation team will review your course and notify you once it's approved."
          action={<Button onClick={() => router.push("/instructor/courses")}>Back to my courses</Button>}
        />
      </div>
    );
  }

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Create a new course</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Step {step + 1} of {STEPS.length}: {STEPS[step]}</p>

      {/* Stepper */}
      <div className="mb-8 flex items-center gap-2">
        {STEPS.map((s, i) => (
          <div key={s} className="flex flex-1 items-center gap-2">
            <div
              className={cn(
                "flex h-7 w-7 shrink-0 items-center justify-center rounded-full text-[12px] font-semibold",
                i < step ? "bg-teal text-white" : i === step ? "bg-gold-dark text-white" : "bg-paper-dim text-ink-soft"
              )}
            >
              {i < step ? <Check size={14} /> : i + 1}
            </div>
            {i < STEPS.length - 1 && <div className={cn("h-0.5 flex-1", i < step ? "bg-teal" : "bg-line")} />}
          </div>
        ))}
      </div>

      <div className="rounded-card border border-line bg-card p-6">
        {step === 0 && (
          <div className="flex flex-col gap-4">
            <Input label="Course title" required value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. n8n Automation Bootcamp" />
            <Input label="Subtitle" value={subtitle} onChange={(e) => setSubtitle(e.target.value)} placeholder="A short one-line summary" />
            <Select
              label="Category"
              options={CATEGORIES.map((c) => ({ label: c.name, value: c.id }))}
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            />
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Select label="Level" options={LEVEL_OPTIONS} value={level} onChange={(e) => setLevel(e.target.value)} />
              <Select label="Language" options={LANGUAGE_OPTIONS} value={language} onChange={(e) => setLanguage(e.target.value)} />
            </div>
          </div>
        )}

        {step === 1 && (
          <div>
            {modules.length === 0 ? (
              <EmptyState title="No modules yet" description="Add your first module to start building the curriculum." />
            ) : (
              <div className="flex flex-col gap-4">
                {modules.map((m) => (
                  <div key={m.id} className="rounded-control border border-line p-4">
                    <p className="mb-3 text-[14px] font-semibold text-ink">{m.title}</p>
                    {m.lessons.length > 0 && (
                      <ul className="mb-3 flex flex-col gap-1.5">
                        {m.lessons.map((l) => (
                          <li key={l.id} className="flex items-center gap-2 text-[13px] text-ink-soft">
                            <span className="rounded bg-paper-dim px-1.5 py-0.5 text-[11px] uppercase">{l.type}</span>
                            {l.title}
                          </li>
                        ))}
                      </ul>
                    )}
                    <div className="flex flex-wrap gap-2">
                      <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "video")}>+ Video</Button>
                      <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "text")}>+ Text</Button>
                      <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "quiz")}>+ Quiz</Button>
                      <Button size="sm" variant="secondary" onClick={() => addLesson(m.id, "resource")}>+ Resource</Button>
                    </div>
                  </div>
                ))}
              </div>
            )}
            <Button variant="secondary" className="mt-4" onClick={addModule}>+ Add module</Button>
          </div>
        )}

        {step === 2 && (
          <div className="flex flex-col gap-4">
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Input label="Price" type="number" required value={price} onChange={(e) => setPrice(e.target.value)} placeholder="49.00" />
              <Select
                label="Currency"
                options={[
                  { label: "USD", value: "USD" },
                  { label: "PKR", value: "PKR" }
                ]}
                value={currency}
                onChange={(e) => setCurrency(e.target.value)}
              />
            </div>
            <label className="flex items-center gap-2 text-[13px] text-ink-soft">
              <input
                type="checkbox"
                checked={includeInSubscription}
                onChange={(e) => setIncludeInSubscription(e.target.checked)}
                className="h-4 w-4 accent-gold-dark"
              />
              Include this course in the Saachi AI Pro subscription
            </label>
          </div>
        )}

        {step === 3 && (
          <div className="flex flex-col gap-4">
            <Input label="Thumbnail URL" value={thumbnailUrl} onChange={(e) => setThumbnailUrl(e.target.value)} placeholder="https://..." />
            <Input label="Promo video URL" value={promoVideoUrl} onChange={(e) => setPromoVideoUrl(e.target.value)} placeholder="https://..." />
            <p className="text-[12px] text-ink-soft">
              File upload with resumable/chunked upload will be wired up once the signed-URL flow from the backend is available.
            </p>
          </div>
        )}

        {step === 4 && (
          <div className="flex flex-col gap-4 text-[14px]">
            <div>
              <p className="text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/60">Title</p>
              <p className="text-ink">{title || "—"}</p>
            </div>
            <div>
              <p className="text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/60">Category</p>
              <p className="text-ink">{CATEGORIES.find((c) => c.id === category)?.name ?? "—"}</p>
            </div>
            <div>
              <p className="text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/60">Modules</p>
              <p className="text-ink">{modules.length} module(s), {modules.reduce((sum, m) => sum + m.lessons.length, 0)} lesson(s)</p>
            </div>
            <div>
              <p className="text-[12px] font-semibold uppercase tracking-[0.05em] text-ink-soft/60">Price</p>
              <p className="text-ink">{price ? `${price} ${currency}` : "—"}</p>
            </div>
          </div>
        )}
      </div>

      <div className="mt-6 flex justify-between">
        <Button variant="secondary" disabled={step === 0} onClick={() => setStep((s) => Math.max(0, s - 1))}>
          Back
        </Button>
        {step < STEPS.length - 1 ? (
          <Button disabled={!canGoNext} onClick={() => setStep((s) => Math.min(STEPS.length - 1, s + 1))}>
            Next
          </Button>
        ) : (
          <Button onClick={handleSubmit}>Submit for review</Button>
        )}
      </div>
    </div>
  );
}