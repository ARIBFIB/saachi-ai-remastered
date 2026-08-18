"use client";

import { useEffect, useMemo, useState, type DragEvent } from "react";
import {
  Plus,
  Trash2,
  GripVertical,
  Check,
  X,
  Eye,
  EyeOff,
  Save,
  HelpCircle,
  ChevronDown,
  ChevronUp,
  AlertCircle,
  CheckCircle2
} from "lucide-react";
import { useInstructorCourseStore } from "@saachi/store";
import {
  useQuizStore,
  blankQuestion,
  blankOption,
  genId,
  type QuizLesson,
  type QuizQuestion,
  type QuizOption
} from "@saachi/store";
import { Button, Select, Input, Textarea, EmptyState, Badge, cn } from "@saachi/ui";

// â”€â”€â”€ Types â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

type PreviewState = {
  selectedOptionId: string | null;
  submitted: boolean;
};

// â”€â”€â”€ Sub-components â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function OptionRow({
  option,
  isCorrect,
  onChange,
  onRemove,
  onMarkCorrect,
  canRemove
}: {
  option: QuizOption;
  isCorrect: boolean;
  onChange: (text: string) => void;
  onRemove: () => void;
  onMarkCorrect: () => void;
  canRemove: boolean;
}) {
  return (
    <div
      className={cn(
        "flex items-center gap-2.5 rounded-control border px-3 py-2 transition-colors duration-150",
        isCorrect
          ? "border-teal/40 bg-teal-light"
          : "border-line bg-paper-dim/40"
      )}
    >
      <button
        type="button"
        onClick={onMarkCorrect}
        title="Mark as correct answer"
        className={cn(
          "flex h-5 w-5 shrink-0 items-center justify-center rounded-full border-2 transition-colors duration-150",
          isCorrect
            ? "border-teal bg-teal text-white"
            : "border-line-strong bg-card hover:border-teal"
        )}
      >
        {isCorrect && <Check size={11} strokeWidth={3} />}
      </button>

      <input
        value={option.text}
        onChange={(e) => onChange(e.target.value)}
        placeholder="Option text..."
        className="min-w-0 flex-1 bg-transparent text-[13.5px] text-ink outline-none placeholder:text-ink-soft/50"
      />

      {canRemove && (
        <button
          type="button"
          onClick={onRemove}
          className="flex h-6 w-6 shrink-0 items-center justify-center rounded-control text-ink-soft/50 transition-colors hover:bg-error-tint hover:text-error"
        >
          <X size={13} />
        </button>
      )}
    </div>
  );
}

function QuestionCard({
  question,
  index,
  isDragging,
  onDragStart,
  onDragOver,
  onDrop,
  onChange,
  onRemove
}: {
  question: QuizQuestion;
  index: number;
  isDragging: boolean;
  onDragStart: () => void;
  onDragOver: (e: DragEvent) => void;
  onDrop: () => void;
  onChange: (patch: Partial<QuizQuestion>) => void;
  onRemove: () => void;
}) {
  const [collapsed, setCollapsed] = useState(false);

  function updateOption(optId: string, text: string) {
    onChange({
      options: question.options.map((o) => (o.id === optId ? { ...o, text } : o))
    });
  }

  function removeOption(optId: string) {
    if (question.options.length <= 2) return;
    const newOptions = question.options.filter((o) => o.id !== optId);
    const patch: Partial<QuizQuestion> = { options: newOptions };
    if (question.correctOptionId === optId) {
      patch.correctOptionId = newOptions[0]?.id ?? "";
    }
    onChange(patch);
  }

  function addOption() {
    if (question.options.length >= 6) return;
    onChange({ options: [...question.options, blankOption()] });
  }

  return (
    <div
      draggable
      onDragStart={onDragStart}
      onDragOver={onDragOver}
      onDrop={onDrop}
      className={cn(
        "rounded-card border border-line bg-card transition-shadow duration-150",
        isDragging && "opacity-60 shadow-xl"
      )}
    >
      {/* Card header */}
      <div className="flex items-center gap-2 px-4 py-3">
        <span
          className="cursor-grab text-ink-soft/40 transition-colors hover:text-ink-soft"
          title="Drag to reorder"
        >
          <GripVertical size={16} />
        </span>

        <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-gold-tint text-[11px] font-semibold text-gold-dark">
          {index + 1}
        </span>

        <p className="min-w-0 flex-1 truncate text-[13.5px] font-semibold text-ink">
          {question.questionText.trim() || <span className="text-ink-soft/50 font-normal">Untitled question</span>}
        </p>

        <button
          type="button"
          onClick={() => setCollapsed((v) => !v)}
          className="flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
        >
          {collapsed ? <ChevronDown size={15} /> : <ChevronUp size={15} />}
        </button>

        <button
          type="button"
          onClick={onRemove}
          className="flex h-8 w-8 shrink-0 items-center justify-center rounded-control text-ink-soft transition-colors hover:bg-error-tint hover:text-error"
          title="Delete question"
        >
          <Trash2 size={14} />
        </button>
      </div>

      {/* Card body */}
      {!collapsed && (
        <div className="border-t border-line px-4 py-4 flex flex-col gap-4">
          {/* Question text */}
          <Textarea
            label="Question"
            rows={2}
            value={question.questionText}
            onChange={(e) => onChange({ questionText: e.target.value })}
            placeholder="Type the question here..."
          />

          {/* Options */}
          <div>
            <p className="mb-2 text-[12.5px] font-semibold text-ink-soft uppercase tracking-[0.05em]">
              Options <span className="normal-case font-normal text-ink-soft/60">(click circle to mark correct)</span>
            </p>
            <div className="flex flex-col gap-2">
              {question.options.map((opt) => (
                <OptionRow
                  key={opt.id}
                  option={opt}
                  isCorrect={opt.id === question.correctOptionId}
                  onChange={(text) => updateOption(opt.id, text)}
                  onRemove={() => removeOption(opt.id)}
                  onMarkCorrect={() => onChange({ correctOptionId: opt.id })}
                  canRemove={question.options.length > 2}
                />
              ))}
            </div>

            {question.options.length < 6 && (
              <button
                type="button"
                onClick={addOption}
                className="mt-2 flex items-center gap-1.5 text-[12.5px] font-medium text-gold-dark hover:underline"
              >
                <Plus size={13} />
                Add option
              </button>
            )}
          </div>

          {/* Explanation */}
          <Textarea
            label="Explanation (shown after answer)"
            rows={2}
            value={question.explanation}
            onChange={(e) => onChange({ explanation: e.target.value })}
            placeholder="Why is this the correct answer? Optional but recommended."
          />
        </div>
      )}
    </div>
  );
}

// â”€â”€â”€ Preview panel â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function QuizPreview({ questions }: { questions: QuizQuestion[] }) {
  const [currentIdx, setCurrentIdx] = useState(0);
  const [states, setStates] = useState<Record<string, PreviewState>>({});

  const question = questions[currentIdx];
  if (!question) {
    return (
      <EmptyState
        title="No questions yet"
        description="Add at least one question to preview the quiz."
      />
    );
  }

  const state: PreviewState = states[question.id] ?? {
    selectedOptionId: null,
    submitted: false
  };

  function selectOption(optId: string) {
    if (state.submitted) return;
    setStates((prev) => ({
      ...prev,
      [question.id]: { selectedOptionId: optId, submitted: false }
    }));
  }

  function submit() {
    if (!state.selectedOptionId) return;
    setStates((prev) => ({
      ...prev,
      [question.id]: { ...prev[question.id], submitted: true }
    }));
  }

  const isCorrect =
    state.submitted && state.selectedOptionId === question.correctOptionId;

  return (
    <div className="flex flex-col gap-4">
      {/* Progress */}
      <div className="flex items-center justify-between">
        <span className="text-[12px] text-ink-soft">
          Question {currentIdx + 1} of {questions.length}
        </span>
        <div className="flex gap-1">
          {questions.map((_, i) => (
            <button
              key={i}
              type="button"
              onClick={() => setCurrentIdx(i)}
              className={cn(
                "h-1.5 rounded-full transition-all",
                i === currentIdx ? "w-5 bg-gold-dark" : "w-1.5 bg-line-strong"
              )}
            />
          ))}
        </div>
      </div>

      {/* Question */}
      <div className="rounded-card border border-line bg-paper-dim/30 p-5">
        <p className="text-[15px] font-semibold text-ink leading-snug mb-4">
          {question.questionText || <span className="text-ink-soft/50">Untitled question</span>}
        </p>

        <div className="flex flex-col gap-2">
          {question.options.map((opt) => {
            const selected = state.selectedOptionId === opt.id;
            const correct = opt.id === question.correctOptionId;
            const showResult = state.submitted;

            return (
              <button
                key={opt.id}
                type="button"
                onClick={() => selectOption(opt.id)}
                disabled={state.submitted}
                className={cn(
                  "flex items-center gap-3 rounded-control border px-4 py-2.5 text-left text-[13.5px] transition-all duration-150 disabled:cursor-default",
                  !showResult && selected
                    ? "border-gold-dark/60 bg-gold-tint font-medium text-ink"
                    : !showResult
                    ? "border-line bg-card text-ink hover:border-gold-dark/40 hover:bg-gold-tint/30"
                    : showResult && correct
                    ? "border-teal/40 bg-teal-light font-medium text-ink"
                    : showResult && selected && !correct
                    ? "border-error/40 bg-error-tint text-ink"
                    : "border-line bg-card text-ink-soft"
                )}
              >
                {showResult && correct && (
                  <CheckCircle2 size={15} className="shrink-0 text-teal" />
                )}
                {showResult && selected && !correct && (
                  <AlertCircle size={15} className="shrink-0 text-error" />
                )}
                {!showResult && (
                  <span
                    className={cn(
                      "flex h-4 w-4 shrink-0 items-center justify-center rounded-full border-2",
                      selected ? "border-gold-dark bg-gold-dark" : "border-line-strong"
                    )}
                  >
                    {selected && <span className="h-1.5 w-1.5 rounded-full bg-white" />}
                  </span>
                )}
                <span className="flex-1">
                  {opt.text || <span className="italic text-ink-soft/50">Empty option</span>}
                </span>
              </button>
            );
          })}
        </div>

        {/* Feedback */}
        {state.submitted && (
          <div
            className={cn(
              "mt-4 rounded-control border px-4 py-3 text-[13px]",
              isCorrect
                ? "border-teal/30 bg-teal-light text-teal"
                : "border-error/30 bg-error-tint text-error"
            )}
          >
            <p className="font-semibold mb-0.5">
              {isCorrect ? "Correct!" : "Incorrect"}
            </p>
            {question.explanation && (
              <p className="text-[12.5px] text-ink-soft">{question.explanation}</p>
            )}
          </div>
        )}

        {/* Submit / Next */}
        <div className="mt-4 flex gap-2">
          {!state.submitted ? (
            <Button
              size="sm"
              disabled={!state.selectedOptionId}
              onClick={submit}
            >
              Check answer
            </Button>
          ) : currentIdx < questions.length - 1 ? (
            <Button size="sm" onClick={() => setCurrentIdx((i) => i + 1)}>
              Next question â†’
            </Button>
          ) : (
            <p className="text-[13px] text-teal font-medium flex items-center gap-1.5">
              <CheckCircle2 size={15} />
              Quiz complete
            </p>
          )}
        </div>
      </div>
    </div>
  );
}

// â”€â”€â”€ Main page â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

export default function InstructorQuizBuilderPage() {
  const courses = useInstructorCourseStore((s) => s.courses);
  const { quizzes, saveQuiz, deleteQuiz, getQuizzesForCourse } = useQuizStore();

  // â”€â”€ selections â”€â”€
  const [courseId, setCourseId] = useState(courses[0]?.id ?? "");
  const [moduleId, setModuleId] = useState("");
  const [quizId, setQuizId] = useState<string>("__new__");
  const [previewMode, setPreviewMode] = useState(false);

  // â”€â”€ local quiz draft state â”€â”€
  const [title, setTitle] = useState("Untitled quiz");
  const [description, setDescription] = useState("");
  const [questions, setQuestions] = useState<QuizQuestion[]>([blankQuestion()]);
  const [dragIndex, setDragIndex] = useState<number | null>(null);
  const [savedTick, setSavedTick] = useState(0);

  // Derived
  const course = useMemo(
    () => courses.find((c) => c.id === courseId),
    [courses, courseId]
  );

  const modules = course?.modules ?? [];

  const moduleOptions = useMemo(
    () => [
      { label: "Select a moduleâ€¦", value: "" },
      ...modules.map((m) => ({ label: m.title, value: m.id }))
    ],
    [modules]
  );

  const courseQuizzes = useMemo(
    () => getQuizzesForCourse(courseId),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [courseId, quizzes]
  );

  const quizSelectOptions = useMemo(
    () => [
      { label: "+ New quiz", value: "__new__" },
      ...courseQuizzes.map((q) => ({
        label: q.title,
        value: q.id
      }))
    ],
    [courseQuizzes]
  );

  // When course changes, reset module + quiz
  useEffect(() => {
    setModuleId("");
    setQuizId("__new__");
    resetDraft();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [courseId]);

  // When quiz selection changes, load it or reset to blank
  useEffect(() => {
    if (quizId === "__new__") {
      resetDraft();
      return;
    }
    const found = quizzes.find((q) => q.id === quizId);
    if (found) {
      setTitle(found.title);
      setDescription(found.description);
      setModuleId(found.moduleId);
      setQuestions(found.questions.length > 0 ? found.questions : [blankQuestion()]);
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [quizId]);

  function resetDraft() {
    setTitle("Untitled quiz");
    setDescription("");
    setQuestions([blankQuestion()]);
    setSavedTick(0);
  }

  // â”€â”€ question CRUD â”€â”€

  function addQuestion() {
    setQuestions((prev) => [...prev, blankQuestion()]);
  }

  function updateQuestion(idx: number, patch: Partial<QuizQuestion>) {
    setQuestions((prev) =>
      prev.map((q, i) => (i === idx ? { ...q, ...patch } : q))
    );
  }

  function removeQuestion(idx: number) {
    setQuestions((prev) => {
      const next = prev.filter((_, i) => i !== idx);
      return next.length === 0 ? [blankQuestion()] : next;
    });
  }

  // â”€â”€ drag reorder â”€â”€

  function handleDragOver(e: DragEvent, targetIdx: number) {
    e.preventDefault();
    if (dragIndex === null || dragIndex === targetIdx) return;
    setQuestions((prev) => {
      const next = [...prev];
      const [moved] = next.splice(dragIndex, 1);
      next.splice(targetIdx, 0, moved);
      return next;
    });
    setDragIndex(targetIdx);
  }

  // â”€â”€ save â”€â”€

  function handleSave() {
    const quiz: QuizLesson = {
      id: quizId === "__new__" ? genId("quiz") : quizId,
      courseId,
      moduleId,
      title: title.trim() || "Untitled quiz",
      description,
      questions,
      updatedAt: new Date().toISOString()
    };
    saveQuiz(quiz);
    if (quizId === "__new__") {
      setQuizId(quiz.id);
    }
    setSavedTick((t) => t + 1);
  }

  function handleDelete() {
    if (quizId === "__new__") return;
    deleteQuiz(quizId);
    setQuizId("__new__");
    resetDraft();
  }

  // â”€â”€ validation warnings â”€â”€

  const warnings = useMemo(() => {
    const w: string[] = [];
    if (!moduleId) w.push("No module selected â€” quiz won't be linked to a module.");
    questions.forEach((q, i) => {
      if (!q.questionText.trim()) w.push(`Q${i + 1}: question text is empty.`);
      const emptyOpts = q.options.filter((o) => !o.text.trim()).length;
      if (emptyOpts > 0) w.push(`Q${i + 1}: ${emptyOpts} option(s) have no text.`);
      if (!q.correctOptionId) w.push(`Q${i + 1}: no correct answer selected.`);
    });
    return w;
  }, [moduleId, questions]);

  // â”€â”€ early returns â”€â”€

  if (courses.length === 0) {
    return (
      <div>
        <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Quiz Builder</h1>
        <p className="mb-8 text-[14px] text-ink-soft">
          Create multiple-choice quizzes and attach them to course modules.
        </p>
        <EmptyState
          title="No courses yet"
          description="Create a course first, then come back to build quizzes."
        />
      </div>
    );
  }

  return (
    <div>
      {/* â”€â”€ Page header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */}
      <div className="mb-6 flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Quiz Builder</h1>
          <p className="text-[14px] text-ink-soft">
            Build multiple-choice quizzes and attach them to your course modules.
          </p>
        </div>

        <div className="flex items-center gap-2">
          {savedTick > 0 && (
            <span className="flex items-center gap-1.5 text-[12.5px] font-medium text-teal">
              <Save size={13} />
              Saved
            </span>
          )}

          <button
            type="button"
            onClick={() => setPreviewMode((v) => !v)}
            className="flex items-center gap-1.5 rounded-full border border-line px-3.5 py-1.5 text-[12.5px] font-semibold text-ink-soft transition-colors hover:border-line-strong hover:text-ink"
          >
            {previewMode ? (
              <>
                <EyeOff size={13} />
                Edit
              </>
            ) : (
              <>
                <Eye size={13} />
                Preview
              </>
            )}
          </button>

          {quizId !== "__new__" && (
            <Button size="sm" variant="secondary" onClick={handleDelete}>
              <Trash2 size={13} className="mr-1" />
              Delete quiz
            </Button>
          )}

          <Button size="sm" onClick={handleSave}>
            <Save size={13} className="mr-1" />
            {quizId === "__new__" ? "Save quiz" : "Update quiz"}
          </Button>
        </div>
      </div>

      {/* â”€â”€ Controls row â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */}
      <div className="mb-6 grid grid-cols-1 gap-4 rounded-card border border-line bg-card p-5 sm:grid-cols-2 lg:grid-cols-4">
        <Select
          label="Course"
          options={courses.map((c) => ({ label: c.title, value: c.id }))}
          value={courseId}
          onChange={(e) => setCourseId(e.target.value)}
        />

        <Select
          label="Module (optional)"
          options={moduleOptions}
          value={moduleId}
          onChange={(e) => setModuleId(e.target.value)}
        />

        <Select
          label="Quiz"
          options={quizSelectOptions}
          value={quizId}
          onChange={(e) => setQuizId(e.target.value)}
        />

        <Input
          label="Quiz title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="e.g. Module 1 knowledge check"
        />
      </div>

      {/* Description */}
      <div className="mb-6">
        <Textarea
          label="Quiz description (optional)"
          rows={2}
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Brief instructions shown to learners before the quiz starts."
        />
      </div>

      {/* â”€â”€ Warnings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */}
      {warnings.length > 0 && !previewMode && (
        <div className="mb-5 rounded-control border border-warning/40 bg-warning-tint px-4 py-3">
          <p className="mb-1.5 flex items-center gap-1.5 text-[12.5px] font-semibold text-warning">
            <AlertCircle size={14} />
            {warnings.length} issue{warnings.length > 1 ? "s" : ""} to fix before publishing
          </p>
          <ul className="flex flex-col gap-0.5">
            {warnings.map((w, i) => (
              <li key={i} className="text-[12px] text-ink-soft">
                Â· {w}
              </li>
            ))}
          </ul>
        </div>
      )}

      {/* â”€â”€ Main content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */}
      {previewMode ? (
        <div className="max-w-xl">
          <div className="mb-4 flex items-center gap-2">
            <HelpCircle size={16} className="text-gold-dark" />
            <h2 className="text-[15px] font-semibold text-ink">
              Learner preview â€” {title}
            </h2>
            <Badge variant="gold">Preview mode</Badge>
          </div>
          {description && (
            <p className="mb-4 text-[13px] text-ink-soft leading-relaxed">{description}</p>
          )}
          <QuizPreview questions={questions} />
        </div>
      ) : (
        <>
          {/* Question count + add button */}
          <div className="mb-4 flex items-center justify-between">
            <p className="text-[13px] font-semibold text-ink-soft">
              {questions.length} question{questions.length !== 1 ? "s" : ""}
            </p>
            <Button size="sm" variant="secondary" onClick={addQuestion}>
              <Plus size={13} className="mr-1" />
              Add question
            </Button>
          </div>

          {/* Question cards */}
          <div className="flex flex-col gap-4">
            {questions.map((q, idx) => (
              <QuestionCard
                key={q.id}
                question={q}
                index={idx}
                isDragging={dragIndex === idx}
                onDragStart={() => setDragIndex(idx)}
                onDragOver={(e) => handleDragOver(e, idx)}
                onDrop={() => setDragIndex(null)}
                onChange={(patch) => updateQuestion(idx, patch)}
                onRemove={() => removeQuestion(idx)}
              />
            ))}
          </div>

          {/* Bottom add */}
          <button
            type="button"
            onClick={addQuestion}
            className="mt-5 flex w-full items-center justify-center gap-2 rounded-card border-2 border-dashed border-line py-4 text-[13px] font-medium text-ink-soft transition-colors hover:border-gold-dark/40 hover:text-ink"
          >
            <Plus size={15} />
            Add another question
          </button>
        </>
      )}
    </div>
  );
}