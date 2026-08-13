"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Plus, Trash2 } from "lucide-react";
import { Button, Input, Select, EmptyState } from "@saachi/ui";

type QuestionType = "multiple_choice" | "short_answer";

type Question = {
  id: string;
  type: QuestionType;
  prompt: string;
  options: string[];
  correctOptionIndex: number;
  correctAnswerText: string;
};

let qCounter = 0;
function newQuestion(type: QuestionType): Question {
  qCounter += 1;
  return {
    id: `q${qCounter}`,
    type,
    prompt: "",
    options: type === "multiple_choice" ? ["", "", "", ""] : [],
    correctOptionIndex: 0,
    correctAnswerText: ""
  };
}

const TYPE_OPTIONS = [
  { label: "Multiple choice", value: "multiple_choice" },
  { label: "Short answer", value: "short_answer" }
];

export default function QuizBuilderPage() {
  const router = useRouter();
  const params = useParams<{ id: string; lessonId: string }>();

  const [passingScore, setPassingScore] = useState("70");
  const [questions, setQuestions] = useState<Question[]>([]);
  const [saved, setSaved] = useState(false);

  function addQuestion(type: QuestionType) {
    setQuestions((prev) => [...prev, newQuestion(type)]);
  }

  function updateQuestion(id: string, patch: Partial<Question>) {
    setQuestions((prev) => prev.map((q) => (q.id === id ? { ...q, ...patch } : q)));
  }

  function updateOption(questionId: string, optionIndex: number, value: string) {
    setQuestions((prev) =>
      prev.map((q) =>
        q.id === questionId
          ? { ...q, options: q.options.map((o, i) => (i === optionIndex ? value : o)) }
          : q
      )
    );
  }

  function removeQuestion(id: string) {
    setQuestions((prev) => prev.filter((q) => q.id !== id));
  }

  function handleSave() {
    // NOTE: demo-only, no backend quiz-save mutation wired up yet.
    setSaved(true);
  }

  if (saved) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Quiz saved"
          description="Your quiz has been saved to the curriculum."
          action={
            <Button onClick={() => router.push(`/instructor/courses/${params.id}/curriculum`)}>
              Back to curriculum
            </Button>
          }
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Quiz Builder</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Lesson ID: {params.lessonId}</p>

      <div className="mb-6 max-w-xs">
        <Input
          label="Passing score (%)"
          type="number"
          value={passingScore}
          onChange={(e) => setPassingScore(e.target.value)}
        />
      </div>

      {questions.length === 0 ? (
        <EmptyState title="No questions yet" description="Add your first question to the question bank." />
      ) : (
        <div className="flex flex-col gap-5">
          {questions.map((q, qi) => (
            <div key={q.id} className="rounded-card border border-line bg-card p-5">
              <div className="mb-3 flex items-center justify-between gap-3">
                <span className="text-[13px] font-semibold text-ink-soft">Question {qi + 1}</span>
                <div className="flex items-center gap-2">
                  <Select
                    options={TYPE_OPTIONS}
                    value={q.type}
                    onChange={(e) => updateQuestion(q.id, { type: e.target.value as QuestionType, options: e.target.value === "multiple_choice" ? ["", "", "", ""] : [] })}
                    className="w-44"
                  />
                  <button type="button" onClick={() => removeQuestion(q.id)} aria-label="Remove question" className="text-ink-soft hover:text-error">
                    <Trash2 size={16} />
                  </button>
                </div>
              </div>

              <Input
                label="Question prompt"
                value={q.prompt}
                onChange={(e) => updateQuestion(q.id, { prompt: e.target.value })}
                placeholder="e.g. What does the 'trigger' node do in n8n?"
                className="mb-4"
              />

              {q.type === "multiple_choice" ? (
                <div className="flex flex-col gap-2">
                  {q.options.map((opt, oi) => (
                    <label key={oi} className="flex items-center gap-2">
                      <input
                        type="radio"
                        name={`correct-${q.id}`}
                        checked={q.correctOptionIndex === oi}
                        onChange={() => updateQuestion(q.id, { correctOptionIndex: oi })}
                        className="h-4 w-4 accent-gold-dark"
                        aria-label={`Mark option ${oi + 1} as correct`}
                      />
                      <Input
                        value={opt}
                        onChange={(e) => updateOption(q.id, oi, e.target.value)}
                        placeholder={`Option ${oi + 1}`}
                        className="flex-1"
                      />
                    </label>
                  ))}
                </div>
              ) : (
                <Input
                  label="Correct answer"
                  value={q.correctAnswerText}
                  onChange={(e) => updateQuestion(q.id, { correctAnswerText: e.target.value })}
                  placeholder="Expected short answer"
                />
              )}
            </div>
          ))}
        </div>
      )}

      <div className="mt-4 flex flex-wrap gap-2">
        <Button variant="secondary" onClick={() => addQuestion("multiple_choice")}>
          <Plus size={14} className="mr-1.5" />
          Multiple choice
        </Button>
        <Button variant="secondary" onClick={() => addQuestion("short_answer")}>
          <Plus size={14} className="mr-1.5" />
          Short answer
        </Button>
      </div>

      <Button size="lg" className="mt-6" disabled={questions.length === 0} onClick={handleSave}>
        Save quiz
      </Button>
    </div>
  );
}