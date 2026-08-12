"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button, Input } from "antd";
import { ArrowLeft, MessageCircle, ThumbsUp, Send } from "lucide-react";
import type { CommunityCourse, QAThread } from "./page";

interface CommunityQAClientProps {
  community: CommunityCourse;
}

export function CommunityQAClient({ community }: CommunityQAClientProps) {
  const [threads, setThreads] = useState<QAThread[]>(community.threads);
  const [newQuestion, setNewQuestion] = useState("");

  function handlePostQuestion() {
    if (!newQuestion.trim()) return;
    // TODO: wire to useCourseCommunity().postQuestion(courseSlug, text) from @saachi/api-client
    const thread: QAThread = {
      id: `local-${Date.now()}`,
      authorName: "You",
      authorAvatar: "https://i.pravatar.cc/64?img=47",
      question: newQuestion.trim(),
      timestamp: "Just now",
      replyCount: 0,
      upvotes: 0,
    };
    setThreads((prev) => [thread, ...prev]);
    setNewQuestion("");
  }

  function handleUpvote(threadId: string) {
    setThreads((prev) =>
      prev.map((t) => (t.id === threadId ? { ...t, upvotes: t.upvotes + 1 } : t))
    );
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)] px-6 py-10 lg:px-12">
      <div className="mx-auto flex w-full max-w-[800px] flex-col gap-8">
        <div className="flex flex-col gap-1">
          <Link
            href="/dashboard/my-courses"
            className="flex w-fit items-center gap-2 text-sm font-semibold text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
          >
            <ArrowLeft size={14} />
            Back to My Courses
          </Link>
          <h1 className="pt-2 text-3xl font-bold" style={{ color: "var(--token-color-ink)" }}>
            Community Q&amp;A
          </h1>
          <p style={{ color: "var(--token-color-inkSoft)" }}>{community.title}</p>
        </div>

        <div className="flex flex-col gap-3 rounded-xl border bg-[var(--token-color-surface)] p-4 shadow-[var(--token-shadow-sm)]" style={{ borderColor: "var(--token-color-border)" }}>
          <Input.TextArea
            rows={3}
            value={newQuestion}
            onChange={(e) => setNewQuestion(e.target.value)}
            placeholder="Ask a question about this course..."
          />
          <div className="flex justify-end">
            <Button type="primary" icon={<Send size={14} />} onClick={handlePostQuestion}>
              Post Question
            </Button>
          </div>
        </div>

        <div className="flex flex-col gap-4">
          {threads.map((thread) => (
            <div
              key={thread.id}
              className="flex gap-4 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
              style={{ borderColor: "var(--token-color-border)" }}
            >
              <span className="relative block h-10 w-10 shrink-0 overflow-hidden rounded-full">
                <Image src={thread.authorAvatar} alt={thread.authorName} fill sizes="40px" className="object-cover" />
              </span>

              <div className="flex flex-1 flex-col gap-2">
                <div className="flex items-center gap-2">
                  <span className="text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
                    {thread.authorName}
                  </span>
                  <span className="text-xs" style={{ color: "var(--token-color-inkSoft)" }}>
                    {thread.timestamp}
                  </span>
                </div>

                <p style={{ color: "var(--token-color-ink)" }}>{thread.question}</p>

                <div className="flex items-center gap-4 pt-1">
                  <button
                    type="button"
                    onClick={() => handleUpvote(thread.id)}
                    className="flex items-center gap-1 text-xs font-semibold"
                    style={{ color: "var(--token-color-inkSoft)" }}
                  >
                    <ThumbsUp size={13} />
                    {thread.upvotes}
                  </button>
                  <span className="flex items-center gap-1 text-xs font-semibold" style={{ color: "var(--token-color-inkSoft)" }}>
                    <MessageCircle size={13} />
                    {thread.replyCount} replies
                  </span>
                </div>
              </div>
            </div>
          ))}

          {threads.length === 0 && (
            <p className="py-10 text-center" style={{ color: "var(--token-color-inkSoft)" }}>
              No questions yet -- be the first to ask.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}