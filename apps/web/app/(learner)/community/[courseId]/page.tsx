"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { MessageCircle, ThumbsUp, Send } from "lucide-react";
import { Button, Textarea, EmptyState, Badge } from "@saachi/ui";

type Question = {
  id: string;
  authorName: string;
  body: string;
  createdAt: string;
  upvotes: number;
  instructorAnswer?: string;
};

// NOTE: demo-only dummy data. Replace with useCourseCommunity(courseId) once
// the community/Q&A backend endpoint and typed hook are available.
const INITIAL_QUESTIONS: Question[] = [
  {
    id: "q1",
    authorName: "Hassan Raza",
    body: "Does this work with the self-hosted n8n instance or only n8n Cloud?",
    createdAt: "2026-08-10T09:00:00Z",
    upvotes: 6,
    instructorAnswer: "Both! The workflows in this course work identically on self-hosted and n8n Cloud."
  },
  {
    id: "q2",
    authorName: "Sana Iqbal",
    body: "Is there a lesson on rate-limiting the OpenAI API calls inside a workflow?",
    createdAt: "2026-08-11T14:30:00Z",
    upvotes: 3
  }
];

export default function CourseCommunityPage() {
  const params = useParams<{ courseId: string }>();
  const [questions, setQuestions] = useState(INITIAL_QUESTIONS);
  const [draft, setDraft] = useState("");
  const [upvotedIds, setUpvotedIds] = useState<Set<string>>(new Set());

  function handlePost() {
    if (!draft.trim()) return;
    const newQuestion: Question = {
      id: `q${Date.now()}`,
      authorName: "You",
      body: draft.trim(),
      createdAt: new Date().toISOString(),
      upvotes: 0
    };
    setQuestions((prev) => [newQuestion, ...prev]);
    setDraft("");
  }

  function toggleUpvote(id: string) {
    setUpvotedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) {
        next.delete(id);
      } else {
        next.add(id);
      }
      return next;
    });
    setQuestions((prev) =>
      prev.map((q) =>
        q.id === id ? { ...q, upvotes: q.upvotes + (upvotedIds.has(id) ? -1 : 1) } : q
      )
    );
  }

  return (
    <div className="mx-auto max-w-3xl px-4 py-10 md:px-8">
      <h1 className="mb-1 flex items-center gap-2 font-display text-[24px] font-bold text-ink">
        <MessageCircle size={22} />
        Course Q&amp;A
      </h1>
      <p className="mb-8 text-[14px] text-ink-soft">
        Ask questions about lesson {params.courseId} and get answers from the instructor and other learners.
      </p>

      <div className="mb-10 rounded-card border border-line bg-card p-5">
        <Textarea
          label="Ask a question"
          rows={3}
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          placeholder="What would you like to ask?"
        />
        <div className="mt-3 flex justify-end">
          <Button size="sm" disabled={!draft.trim()} onClick={handlePost}>
            <Send size={13} className="mr-1.5" />
            Post question
          </Button>
        </div>
      </div>

      {questions.length === 0 ? (
        <EmptyState title="No questions yet" description="Be the first to ask something about this course." />
      ) : (
        <div className="flex flex-col gap-4">
          {questions.map((q) => (
            <div key={q.id} className="rounded-card border border-line bg-card p-5">
              <div className="mb-1.5 flex items-center justify-between">
                <span className="text-[13.5px] font-semibold text-ink">{q.authorName}</span>
                <span className="text-[12px] text-ink-soft">
                  {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(q.createdAt))}
                </span>
              </div>
              <p className="mb-3 text-[14px] text-ink">{q.body}</p>

              <button
                type="button"
                onClick={() => toggleUpvote(q.id)}
                className={`flex items-center gap-1.5 rounded-control border px-2.5 py-1 text-[12px] font-medium transition-colors ${
                  upvotedIds.has(q.id)
                    ? "border-gold-dark bg-gold-tint text-ink"
                    : "border-line text-ink-soft hover:bg-paper-dim"
                }`}
              >
                <ThumbsUp size={12} />
                {q.upvotes}
              </button>

              {q.instructorAnswer && (
                <div className="mt-4 rounded-control border border-teal/30 bg-teal-light p-3.5">
                  <Badge className="mb-2">Instructor answer</Badge>
                  <p className="text-[13.5px] text-ink">{q.instructorAnswer}</p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}