"use client";

import { useRouter } from "next/navigation";
import { Plus, Trash2, CheckCircle2, PlayCircle, FileText, HelpCircle, Download } from "lucide-react";
import { useCourseBuilderStore, useInstructorCourseStore } from "@saachi/store";
import { Button, Card, Input, Textarea, Select, Checkbox, Badge } from "@saachi/ui";

const STEPS = ["Basics", "Curriculum", "Pricing", "Media", "Review"];

const CATEGORY_OPTIONS = [
  { label: "AI Fundamentals & Prompt Engineering", value: "ai-fundamentals" },
  { label: "AI for Marketing & Sales", value: "ai-marketing" },
  { label: "AI Automation & Workflow Tools", value: "ai-automation" },
  { label: "AI Customer Support & Communication", value: "ai-support" },
  { label: "AI Website & App Development", value: "ai-dev" },
  { label: "AI Integration for Developers", value: "ai-integration" }
];

const LEVEL_OPTIONS = [
  { label: "Beginner", value: "beginner" },
  { label: "Intermediate", value: "intermediate" },
  { label: "Advanced", value: "advanced" }
];

const LANGUAGE_OPTIONS = [
  { label: "English", value: "en" },
  { label: "Urdu", value: "ur" }
];

const CURRENCY_OPTIONS = [
  { label: "USD", value: "USD" },
  { label: "PKR", value: "PKR" },
  { label: "GBP", value: "GBP" }
];

const LESSON_TYPE_ICON = {
  video: PlayCircle,
  text: FileText,
  quiz: HelpCircle,
  resource: Download
} as const;

export default function CourseWizardPage() {
  const router = useRouter();
  const wizard = useCourseBuilderStore();
  const instructorCourses = useInstructorCourseStore();
  const { draft, step } = wizard;

  const canGoNext = () => {
    if (step === 1) return draft.title.trim().length >= 5 && draft.categoryId;
    if (step === 2) return draft.modules.length > 0;
    if (step === 3) return draft.price >= 0;
    return true;
  };

  const handlePublish = (status: "draft" | "pending_review") => {
    const totalLessons = draft.modules.reduce((sum, m) => sum + m.lessons.length, 0);
    instructorCourses.addCourse({
      id: `crs_local_${Date.now()}`,
      title: draft.title,
      subtitle: draft.subtitle,
      categoryId: draft.categoryId,
      language: draft.language,
      level: draft.level,
      price: draft.price,
      currency: draft.currency,
      status,
      modules: draft.modules,
      createdAt: new Date().toISOString(),
      enrollmentCount: 0,
      revenue: 0,
      rating: 0
    });
    wizard.reset();
    router.push("/instructor/courses");
  };

  return (
    <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
      <h1 className="mb-2 font-display text-[26px] font-semibold text-ink">Create a course</h1>
      <p className="mb-8 text-[14px] text-ink-soft">
        This demo wizard saves your course locally in the browser (no backend yet).
      </p>

      <div className="mb-8 flex items-center gap-2">
        {STEPS.map((label, i) => {
          const stepNum = i + 1;
          const active = stepNum === step;
          const done = stepNum < step;
          return (
            <div key={label} className="flex flex-1 items-center gap-2">
              <div
                className={[
                  "flex h-8 w-8 shrink-0 items-center justify-center rounded-full text-[12px] font-semibold",
                  done ? "bg-teal text-white" : active ? "bg-gold text-ink" : "bg-paper-dim text-ink-soft"
                ].join(" ")}
              >
                {done ? <CheckCircle2 size={15} /> : stepNum}
              </div>
              <span className={active ? "text-[12px] font-semibold text-ink" : "text-[12px] text-ink-soft"}>
                {label}
              </span>
              {stepNum < STEPS.length && <div className="h-px flex-1 bg-line" />}
            </div>
          );
        })}
      </div>

      <Card className="p-6">
        {step === 1 && (
          <div className="flex flex-col gap-4">
            <Input
              label="Course title"
              placeholder="e.g. Build a WhatsApp AI Auto-Responder"
              value={draft.title}
              onChange={(e) => wizard.updateDraft({ title: e.target.value })}
            />
            <Textarea
              label="Subtitle"
              placeholder="One sentence describing the outcome"
              value={draft.subtitle}
              onChange={(e) => wizard.updateDraft({ subtitle: e.target.value })}
            />
            <Select
              label="Category"
              placeholder="Select a category"
              options={CATEGORY_OPTIONS}
              value={draft.categoryId}
              onChange={(e) => wizard.updateDraft({ categoryId: e.target.value })}
            />
            <div className="grid grid-cols-2 gap-4">
              <Select
                label="Level"
                options={LEVEL_OPTIONS}
                value={draft.level}
                onChange={(e) => wizard.updateDraft({ level: e.target.value as typeof draft.level })}
              />
              <Select
                label="Language"
                options={LANGUAGE_OPTIONS}
                value={draft.language}
                onChange={(e) => wizard.updateDraft({ language: e.target.value })}
              />
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="flex flex-col gap-5">
            {draft.modules.length === 0 && (
              <p className="text-[13px] text-ink-soft">Add at least one module to continue.</p>
            )}
            {draft.modules.map((mod) => (
              <div key={mod.id} className="rounded-control border border-line p-4">
                <div className="mb-3 flex items-center gap-2">
                  <Input
                    value={mod.title}
                    onChange={(e) => wizard.updateModuleTitle(mod.id, e.target.value)}
                    className="flex-1"
                  />
                  <button
                    type="button"
                    onClick={() => wizard.removeModule(mod.id)}
                    className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
                  >
                    <Trash2 size={15} />
                  </button>
                </div>

                <div className="flex flex-col gap-2">
                  {mod.lessons.map((lesson) => {
                    const Icon = LESSON_TYPE_ICON[lesson.type];
                    return (
                      <div key={lesson.id} className="flex items-center gap-2">
                        <Icon size={15} className="shrink-0 text-ink-soft" />
                        <Input
                          value={lesson.title}
                          onChange={(e) => wizard.updateLessonTitle(mod.id, lesson.id, e.target.value)}
                          className="h-9 flex-1"
                        />
                        <button
                          type="button"
                          onClick={() => wizard.removeLesson(mod.id, lesson.id)}
                          className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
                        >
                          <Trash2 size={13} />
                        </button>
                      </div>
                    );
                  })}
                </div>

                <div className="mt-3 flex flex-wrap gap-2">
                  {(["video", "text", "quiz", "resource"] as const).map((type) => (
                    <button
                      key={type}
                      type="button"
                      onClick={() => wizard.addLesson(mod.id, type)}
                      className="flex items-center gap-1.5 rounded-full border border-line-strong px-3 py-1.5 text-[12px] font-medium text-ink-soft hover:border-ink hover:text-ink"
                    >
                      <Plus size={12} /> {type}
                    </button>
                  ))}
                </div>
              </div>
            ))}
            <Button variant="secondary" onClick={() => wizard.addModule()}>
              <Plus size={15} /> Add module
            </Button>
          </div>
        )}

        {step === 3 && (
          <div className="flex flex-col gap-4">
            <div className="grid grid-cols-2 gap-4">
              <Input
                label="Price"
                type="number"
                min={0}
                value={draft.price}
                onChange={(e) => wizard.updateDraft({ price: Number(e.target.value) })}
              />
              <Select
                label="Currency"
                options={CURRENCY_OPTIONS}
                value={draft.currency}
                onChange={(e) => wizard.updateDraft({ currency: e.target.value as typeof draft.currency })}
              />
            </div>
            <Checkbox
              label="Include this course in Saachi AI Pro subscription"
              checked={draft.subscriptionIncluded}
              onChange={(e) => wizard.updateDraft({ subscriptionIncluded: e.target.checked })}
            />
          </div>
        )}

        {step === 4 && (
          <div className="flex flex-col gap-4">
            <Input
              label="Thumbnail seed (demo)"
              placeholder="e.g. my-course-thumbnail"
              helperText="In demo mode this generates a placeholder image. Real upload wires to Media API later."
              value={draft.thumbnailSeed}
              onChange={(e) => wizard.updateDraft({ thumbnailSeed: e.target.value })}
            />
            {draft.thumbnailSeed && (
              <div className="aspect-video w-full max-w-[360px] overflow-hidden rounded-control bg-paper-dim">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={`https://picsum.photos/seed/${encodeURIComponent(draft.thumbnailSeed)}/800/450`}
                  alt="Course thumbnail preview"
                  className="h-full w-full object-cover"
                />
              </div>
            )}
          </div>
        )}

        {step === 5 && (
          <div className="flex flex-col gap-4">
            <h3 className="text-[16px] font-semibold text-ink">{draft.title || "Untitled course"}</h3>
            <p className="text-[14px] text-ink-soft">{draft.subtitle}</p>
            <div className="flex flex-wrap gap-2">
              <Badge>{draft.categoryId || "No category"}</Badge>
              <Badge>{draft.level}</Badge>
              <Badge>{draft.language === "en" ? "English" : "Urdu"}</Badge>
              <Badge variant="gold">
                {draft.currency} {draft.price}
              </Badge>
            </div>
            <p className="text-[13px] text-ink-soft">
              {draft.modules.length} modules, {draft.modules.reduce((s, m) => s + m.lessons.length, 0)} lessons
            </p>
          </div>
        )}
      </Card>

      <div className="mt-6 flex items-center justify-between">
        <Button
          variant="ghost"
          onClick={() => wizard.setStep(Math.max(1, step - 1))}
          disabled={step === 1}
        >
          Back
        </Button>

        {step < STEPS.length ? (
          <Button onClick={() => wizard.setStep(step + 1)} disabled={!canGoNext()}>
            Continue
          </Button>
        ) : (
          <div className="flex gap-3">
            <Button variant="secondary" onClick={() => handlePublish("draft")}>
              Save as draft
            </Button>
            <Button onClick={() => handlePublish("pending_review")}>Submit for review</Button>
          </div>
        )}
      </div>
    </main>
  );
}