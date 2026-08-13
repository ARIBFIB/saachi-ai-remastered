"use client";

import { useState } from "react";
import Image from "next/image";
import { Button, Input } from "antd";
import { ThumbsUp, MessageSquare, BadgeCheck } from "lucide-react";

// TODO: replace with useCommunityThreads(courseSlug) hook from @saachi/api-client
interface ThreadPost {
  id: string;
  author: string;
  avatar: string;
  timestamp: string;
  content: string;
  upvotes: number;
  isInstructor?: boolean;
}

const initialThreads: ThreadPost[] = [
  {
    id: "t1",
    author: "Dr. Sarah Chen",
    avatar: "https://i.pravatar.cc/64?img=32",
    timestamp: "2 days ago",
    content:
      "Welcome to the Q&A for this course! Ask anything about the lessons and I'll do my best to answer within 24 hours.",
    upvotes: 24,
    isInstructor: true,
  },
  {
    id: "t2",
    author: "Jordan Lee",
    avatar: "https://i.pravatar.cc/64?img=15",
    timestamp: "1 day ago",
    content: "In lesson 3, why does the temperature parameter change the output so drastically?",
    upvotes: 8,
  },
];

export function CommunityQAClient({ courseSlug }: { courseSlug: string }) {
  const [threads, setThreads] = useState<ThreadPost[]>(initialThreads);
  const [draft, setDraft] = useState("");

  function handlePost() {
    if (!draft.trim()) return;
    // TODO: wire to useCommunityThreads(courseSlug).postQuestion() from @saachi/api-client
    setThreads((prev) => [
      {
        id: `local-${Date.now()}`,
        author: "You",
        avatar: "https://i.pravatar.cc/64?img=47",
        timestamp: "Just now",
        content: draft,
        upvotes: 0,
      },
      ...prev,
    ]);
    setDraft("");
  }

  function handleUpvote(id: string) {
    setThreads((prev) => prev.map((t) => (t.id === id ? { ...t, upvotes: t.upvotes + 1 } : t)));
  }

  return (
    <div className="mx-auto flex w-full max-w-[860px] flex-col gap-8 px-6 py-12">
      <div className="flex flex-col gap-1">
        <h1 className="text-3xl font-bold" style={{ color: "var(--token-color-ink)" }}>
          Course Discussion
        </h1>
        <p style={{ color: "var(--token-color-inkSoft)" }}>
          Ask questions and get help from the instructor and other learners in{" "}
          <span className="font-semibold">{courseSlug.replace(/-/g, " ")}</span>.
        </p>
      </div>

      <div
        className="flex flex-col gap-3 rounded-xl border p-5"
        style={{ borderColor: "var(--token-color-border)", backgroundColor: "var(--token-color-surface)" }}
      >
        <Input.TextArea
          rows={3}
          value={draft}
          onChange={(e) => setDraft(e.target.value)}
          placeholder="Ask a question about this course..."
        />
        <div className="flex justify-end">
          <Button type="primary" onClick={handlePost}>
            Post Question
          </Button>
        </div>
      </div>

      <div className="flex flex-col gap-4">
        {threads.map((post) => (
          <article
            key={post.id}
            className="flex gap-4 rounded-xl border p-5"
            style={{
              borderColor: post.isInstructor ? "var(--token-color-primary)" : "var(--token-color-border)",
              backgroundColor: "var(--token-color-surface)",
            }}
          >
            <span className="relative block h-10 w-10 shrink-0 overflow-hidden rounded-full">
              <Image src={post.avatar} alt={post.author} fill sizes="40px" className="object-cover" />
            </span>

            <div className="flex flex-1 flex-col gap-1.5">
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
                  {post.author}
                </span>
                {post.isInstructor && (
                  <span
                    className="flex items-center gap-1 rounded-full px-2 py-0.5 text-[10px] font-bold uppercase"
                    style={{ backgroundColor: "var(--token-color-primaryTint)", color: "var(--token-color-primary)" }}
                  >
                    <BadgeCheck size={10} />
                    Instructor
                  </span>
                )}
                <span className="text-xs" style={{ color: "var(--token-color-inkSoft)" }}>
                  &bull; {post.timestamp}
                </span>
              </div>

              <p className="text-sm leading-6" style={{ color: "var(--token-color-inkSoft)" }}>
                {post.content}
              </p>

              <div className="flex items-center gap-4 pt-1">
                <button
                  type="button"
                  onClick={() => handleUpvote(post.id)}
                  className="flex items-center gap-1 text-xs font-medium"
                  style={{ color: "var(--token-color-inkSoft)" }}
                >
                  <ThumbsUp size={13} />
                  {post.upvotes}
                </button>
                <button
                  type="button"
                  className="flex items-center gap-1 text-xs font-medium"
                  style={{ color: "var(--token-color-inkSoft)" }}
                >
                  <MessageSquare size={13} />
                  Reply
                </button>
              </div>
            </div>
          </article>
        ))}
      </div>
    </div>
  );
}