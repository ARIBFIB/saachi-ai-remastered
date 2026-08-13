"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { Plus, Trash2, Check } from "lucide-react";
import { Button, Input, EmptyState } from "@saachi/ui";

type Choice = { id: string; text: string; correct: boolean };
type Question = { id: string; prompt: string; choices: Choice[] };

let counter = 0;
function nextId() {
  counter += 1;
  return `q${counter}`;
}

export default function QuizLessonEditorPage() {
  const params = useParams<{ id: string; lessonId: string }>();
  const [passingScore, setPassingScore] = useState("70");
  const [questions, setQuestions] = useState<Question[]>([]);
  const [saved, setSaved] = useState(false);

  function addQuestion() {
    setQuestions((prev) => [
      ...prev,
      {
        id: nextId(),
        prompt: "",
        choices: [
          { id: `${Date.now()}-a`, text: "", correct: true },
          { id: `${Date.now()}-b`, text: "", correct: false }
        ]
      }
    ]);
  }

  function updatePrompt(qId: string, prompt: string) {
    setQuestions((prev) => prev.map((q) => (q.id === qId ? { ...q, prompt } : q)));
  }

  function updateChoiceText(qId: string, cId: string, text: string) {
    setQuestions((prev) =>
      prev.map((q) => (q.id === qId ? { ...q, choices: q.choices.map((c) => (c.id === cId ? { ...c, text } : c)) } : q))
    );
  }

  function setCorrectChoice(qId: string, cId: string) {
    setQuestions((prev) =>
      prev.map((q) =>
        q.id === qId ? { ...q, choices: q.choices.map((c) => ({ ...c, correct: c.id === cId })) } : q
      )
    );
  }

  function addChoice(qId: string) {
    setQuestions((prev) =>
      prev.map((q) =>
        q.id === qId ? { ...q, choices: [...q.choices, { id: `${Date.now()}`, text: "", correct: false }] } : q
      )
    );
  }

  function removeQuestion(qId: string) {
    setQuestions((prev) => prev.filter((q) => q.id !== qId));
  }

  function handleSave() {
    // NOTE: demo-only, no backend quiz-save mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Quiz builder</h1>
      <p className="mb-8 text-[13px] text-ink-soft">
        Course {params.id} - Lesson {params.lessonId}
      </p>

      <div className="mb-6 rounded-card border border-line bg-card p-5">
        <Input
          label="Passing score (%)"
          type="number"
          min={0}
          max={100}
          value={passingScore}
          onChange={(e) => setPassingScore(e.target.value)}
          className="max-w-[160px]"
        />
      </div>

      {questions.length === 0 ? (
        <EmptyState title="No questions yet" description="Add your first quiz question below." />
      ) : (
        <div className="flex flex-col gap-4">
          {questions.map((q, index) => (
            <div key={q.id} className="rounded-card border border-line bg-card p-5">
              <div className="mb-3 flex items-center justify-between">
                <p className="text-[13px] font-semibold text-ink-soft">Question {index + 1}</p>
                <button type="button" onClick={() => removeQuestion(q.id)} className="text-ink-soft hover:text-error">
                  <Trash2 size={14} />
                </button>
              </div>

              <Input
                value={q.prompt}
                onChange={(e) => updatePrompt(q.id, e.target.value)}
                placeholder="Question prompt"
                className="mb-3"
              />

              <div className="flex flex-col gap-2">
                {q.choices.map((c) => (
                  <div key={c.id} className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => setCorrectChoice(q.id, c.id)}
                      title="Mark as correct answer"
                      className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-control border ${
                        c.correct ? "border-teal bg-teal-light text-teal" : "border-line text-ink-soft"
                      }`}
                    >
                      <Check size={14} />
                    </button>
                    <Input
                      value={c.text}
                      onChange={(e) => updateChoiceText(q.id, c.id, e.target.value)}
                      placeholder="Choice text"
                      className="flex-1"
                    />
                  </div>
                ))}
              </div>

              <Button size="sm" variant="secondary" className="mt-3" onClick={() => addChoice(q.id)}>
                <Plus size={13} className="mr-1" /> Add choice
              </Button>
            </div>
          ))}
        </div>
      )}

      <Button variant="secondary" className="mt-4" onClick={addQuestion}>
        <Plus size={14} className="mr-1.5" /> Add question
      </Button>

      <div className="mt-6">
        <Button size="lg" onClick={handleSave}>
          {saved ? "Saved" : "Save quiz"}
        </Button>
      </div>
    </div>
  );
}