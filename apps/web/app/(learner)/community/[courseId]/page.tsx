"use client";

import { useParams } from "next/navigation";
import { useState, type FormEvent } from "react";
import { ArrowBigUp, MessageCircle } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { Button, EmptyState, Loading, Textarea } from "@saachi/ui";

type Question = {
  id: string;
  author: string;
  body: string;
  upvotes: number;
  instructorAnswer?: string;
};

const SEED_QUESTIONS: Question[] = [
  {
    id: "q1",
    author: "Fatima R.",
    body: "Does this course cover the latest API version?",
    upvotes: 4,
    instructorAnswer: "Yes, updated for the current API as of this course's last revision."
  },
  { id: "q2", author: "Bilal S.", body: "Any prerequisites before lesson 3?", upvotes: 1 }
];

export default function CourseCommunityPage() {
  const params = useParams<{ courseId: string }>();
  const { data: course, isLoading } = useCourseDetail(params.courseId);
  const [questions, setQuestions] = useState<Question[]>(SEED_QUESTIONS);
  const [newQuestion, setNewQuestion] = useState("");

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (!newQuestion.trim()) return;
    setQuestions((prev) => [
      { id: `q${Date.now()}`, author: "You", body: newQuestion.trim(), upvotes: 0 },
      ...prev
    ]);
    setNewQuestion("");
  }

  function handleUpvote(id: string) {
    setQuestions((prev) => prev.map((q) => (q.id === id ? { ...q, upvotes: q.upvotes + 1 } : q)));
  }

  if (isLoading) {
    return <Loading label="Loading discussion..." />;
  }

  return (
    <div className="mx-auto max-w-3xl">
      <p className="mb-1 text-[13px] font-medium text-gold-dark">{course?.title ?? "Course"}</p>
      <h1 className="mb-6 flex items-center gap-2 font-display text-[24px] font-bold text-ink">
        <MessageCircle size={22} />
        Community Q&A
      </h1>

      <form onSubmit={handleSubmit} className="mb-8 flex flex-col gap-3">
        <Textarea
          label="Ask a question"
          rows={3}
          value={newQuestion}
          onChange={(e) => setNewQuestion(e.target.value)}
          placeholder="What would you like to ask?"
        />
        <Button type="submit" className="self-start">
          Post question
        </Button>
      </form>

      {questions.length === 0 ? (
        <EmptyState title="No questions yet" description="Be the first to ask something." />
      ) : (
        <div className="flex flex-col gap-4">
          {questions.map((q) => (
            <div key={q.id} className="rounded-card border border-line bg-card p-4">
              <div className="flex items-start gap-3">
                <button
                  type="button"
                  onClick={() => handleUpvote(q.id)}
                  className="flex flex-col items-center gap-0.5 rounded-control border border-line px-2 py-1 text-ink-soft hover:bg-paper-dim"
                  aria-label="Upvote"
                >
                  <ArrowBigUp size={15} />
                  <span className="text-[11px] font-semibold">{q.upvotes}</span>
                </button>
                <div className="min-w-0 flex-1">
                  <p className="text-[13px] font-semibold text-ink">{q.author}</p>
                  <p className="mt-1 text-[14px] text-ink-soft">{q.body}</p>

                  {q.instructorAnswer && (
                    <div className="mt-3 rounded-control bg-gold-tint px-3 py-2">
                      <p className="text-[12px] font-semibold text-gold-dark">Instructor answer</p>
                      <p className="mt-0.5 text-[13px] text-ink">{q.instructorAnswer}</p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}