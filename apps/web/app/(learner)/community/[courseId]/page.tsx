"use client";

import { useState } from "react";
import { ArrowUp, MessageSquare, BadgeCheck } from "lucide-react";
import { useCourseDetail } from "@saachi/api-client";
import { useCommunityStore } from "@saachi/store";
import { useSession } from "@saachi/api-client";
import { Button, Card, Textarea, EmptyState, SkeletonText } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

export default function CommunityPage({ params }: { params: { courseId: string } }) {
  const { data: course, isLoading } = useCourseDetail(params.courseId);
  const { data: session } = useSession();
  const community = useCommunityStore();
  const [newQuestion, setNewQuestion] = useState("");
  const [replyDrafts, setReplyDrafts] = useState<Record<string, string>>({});

  const questions = community.questions
    .filter((q) => q.courseId === params.courseId)
    .sort((a, b) => b.upvotes - a.upvotes);

  const handleAskQuestion = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newQuestion.trim()) return;
    community.addQuestion(params.courseId, session?.fullName ?? "You", newQuestion.trim());
    setNewQuestion("");
  };

  const handleReply = (questionId: string) => {
    const body = replyDrafts[questionId];
    if (!body?.trim()) return;
    community.addAnswer(questionId, session?.fullName ?? "You", body.trim());
    setReplyDrafts((prev) => ({ ...prev, [questionId]: "" }));
  };

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
        <SkeletonText lines={4} />
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[24px] font-semibold text-ink">
          Q&A - {course?.title ?? "Course"}
        </h1>
        <p className="mt-1 text-[14px] text-ink-soft">Ask questions, get help from instructors and peers.</p>
      </div>

      <Card className="mb-8 p-5">
        <form onSubmit={handleAskQuestion} className="flex flex-col gap-3">
          <Textarea
            placeholder="Ask a question about this course..."
            value={newQuestion}
            onChange={(e) => setNewQuestion(e.target.value)}
            rows={3}
          />
          <Button type="submit" className="w-fit">
            Post question
          </Button>
        </form>
      </Card>

      {questions.length === 0 ? (
        <EmptyState
          icon={<MessageSquare size={22} />}
          title="No questions yet"
          description="Be the first to ask something about this course."
        />
      ) : (
        <div className="flex flex-col gap-4">
          {questions.map((q) => (
            <Card key={q.id} className="p-5">
              <div className="flex gap-4">
                <button
                  type="button"
                  onClick={() => community.upvoteQuestion(q.id)}
                  className="flex shrink-0 flex-col items-center gap-1 rounded-control border border-line-strong px-2.5 py-2 text-ink-soft hover:border-gold-dark hover:text-gold-dark"
                >
                  <ArrowUp size={14} />
                  <span className="text-[12px] font-semibold">{q.upvotes}</span>
                </button>
                <div className="flex-1">
                  <p className="text-[14px] text-ink">{q.body}</p>
                  <p className="mt-2 text-[12px] text-ink-soft">
                    {q.authorName} &middot; {formatRelativeTime(q.createdAt)}
                  </p>

                  {q.answers.length > 0 && (
                    <div className="mt-4 flex flex-col gap-3 border-l-2 border-line pl-4">
                      {q.answers.map((a) => (
                        <div key={a.id}>
                          <div className="flex items-center gap-1.5">
                            <span className="text-[13px] font-semibold text-ink">{a.authorName}</span>
                            {a.isInstructor && <BadgeCheck size={13} className="text-teal" />}
                          </div>
                          <p className="mt-1 text-[13px] text-ink-soft">{a.body}</p>
                          <p className="mt-1 text-[11px] text-ink-soft/60">{formatRelativeTime(a.createdAt)}</p>
                        </div>
                      ))}
                    </div>
                  )}

                  <div className="mt-4 flex items-center gap-2">
                    <Textarea
                      placeholder="Write a reply..."
                      rows={1}
                      value={replyDrafts[q.id] ?? ""}
                      onChange={(e) => setReplyDrafts((prev) => ({ ...prev, [q.id]: e.target.value }))}
                      className="flex-1"
                    />
                    <Button size="sm" variant="secondary" onClick={() => handleReply(q.id)}>
                      Reply
                    </Button>
                  </div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}