"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Input, Button } from "antd";
import {
  Search,
  Plus,
  MessageSquare,
  Eye,
  CheckCircle2,
  Pin,
  FileText,
  ChevronLeft,
  ChevronRight,
  HelpCircle,
} from "lucide-react";
import { DUMMY_COURSES } from "@saachi/api-client";
import { DashboardSidebar } from "@/components/dashboard/DashboardSidebar";

// TODO: replace with useCourseForum(courseSlug) hook from @saachi/api-client
interface ForumThread {
  id: string;
  authorName: string;
  authorAvatar?: string;
  authorInitials?: string;
  postedAgo: string;
  title: string;
  excerpt: string;
  replies: number;
  views: number;
  tags: string[];
  resolved?: boolean;
}

interface PinnedTopic {
  id: string;
  title: string;
  author: string;
}

const filters = ["All Topics", "Unanswered", "Resolved", "Week 3 Project"];

const threads: ForumThread[] = [
  {
    id: "t1",
    authorName: "Alex Chen",
    authorAvatar: "https://i.pravatar.cc/80?img=12",
    postedAgo: "2 hours ago",
    title: "Gradient Descent convergence issues in Assignment 2",
    excerpt:
      "I am having trouble getting my implementation of stochastic gradient descent to converge on the provided dataset. It seems to oscillate...",
    replies: 5,
    views: 124,
    tags: ["Assignment 2", "Optimization"],
    resolved: true,
  },
  {
    id: "t2",
    authorName: "Sarah Jenkins",
    authorInitials: "SJ",
    postedAgo: "5 hours ago",
    title: "Understanding Backpropagation intuition",
    excerpt:
      "Can someone explain the chain rule application in the backpropagation algorithm in a more intuitive way? The math in lecture 4 makes sense,...",
    replies: 12,
    views: 342,
    tags: ["Theory", "Week 2"],
  },
];

const pinnedTopics: PinnedTopic[] = [
  { id: "p1", title: "Syllabus & Course Guidelines", author: "Instructor Team" },
  { id: "p2", title: "Environment Setup Guide (Python/Conda)", author: "TA David" },
];

const forumStats = { questions: "1,248", resolvedPercent: "84%" };

const TOTAL_PAGES = 12; // TODO: derive from API pagination meta

export function CommunityQAClient({ courseSlug }: { courseSlug: string }) {
  const [activeFilter, setActiveFilter] = useState(filters[0]);
  const [page, setPage] = useState(1);

  const matchedCourse = DUMMY_COURSES.find((c) => c.slug === courseSlug);
  const courseTitle = matchedCourse?.title ?? "Course";

  function handleAskQuestion() {
    // TODO: navigate to /dashboard/community/{courseSlug}/ask or open a modal
    console.log("ask a question", courseSlug);
  }

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      <DashboardSidebar />

      {/* Main column */}
      <div className="flex w-full flex-col lg:pl-72">
        <main className="flex-1 p-12">
          <div className="flex flex-col gap-10">
            {/* Header & search */}
            <div className="flex items-start justify-between gap-6">
              <div className="flex flex-col gap-1">
                <h1 className="text-3xl font-bold leading-10" style={{ color: "var(--token-color-ink)" }}>
                  {courseTitle}
                </h1>
                <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                  Course Discussion Forum
                </p>
              </div>

              <div className="flex items-center gap-4">
                <Input
                  prefix={<Search size={16} color="var(--token-color-textMuted)" />}
                  placeholder="Search questions..."
                  size="large"
                  style={{ width: 320 }}
                />
                <Button type="primary" size="large" icon={<Plus size={14} />} onClick={handleAskQuestion}>
                  Ask a Question
                </Button>
              </div>
            </div>

            {/* Bento grid: discussion list + sidebar */}
            <div className="grid grid-cols-1 gap-6 xl:grid-cols-12">
              {/* Main discussion list */}
              <div className="flex flex-col gap-4 xl:col-span-8">
                {/* Filters */}
                <div className="flex flex-wrap gap-2 pb-2">
                  {filters.map((filter) => {
                    const isActive = filter === activeFilter;
                    return (
                      <button
                        key={filter}
                        type="button"
                        onClick={() => setActiveFilter(filter)}
                        className="rounded-full px-4 py-1.5 text-xs font-semibold tracking-wide transition"
                        style={{
                          backgroundColor: isActive ? "var(--token-color-primaryTint)" : "var(--token-color-surface)",
                          color: isActive ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                          border: `1px solid ${isActive ? "var(--token-color-primary)" : "var(--token-color-border)"}`,
                          fontWeight: isActive ? 600 : 500,
                        }}
                      >
                        {filter}
                      </button>
                    );
                  })}
                </div>

                {/* Thread cards */}
                {threads.map((thread) => (
                  <ThreadCard key={thread.id} thread={thread} />
                ))}

                {/* Pagination */}
                <div className="flex justify-center gap-2 pt-6">
                  <button
                    type="button"
                    aria-label="Previous page"
                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                    className="flex h-10 w-10 items-center justify-center rounded-lg border transition hover:bg-[var(--token-color-surfaceAlt)]"
                    style={{ borderColor: "var(--token-color-border)" }}
                  >
                    <ChevronLeft size={14} color="var(--token-color-inkSoft)" />
                  </button>

                  {[1, 2, 3].map((p) => {
                    const isActive = p === page;
                    return (
                      <button
                        key={p}
                        type="button"
                        onClick={() => setPage(p)}
                        className="flex h-10 w-10 items-center justify-center rounded-lg text-base transition"
                        style={{
                          backgroundColor: isActive ? "var(--token-color-primary)" : "transparent",
                          color: isActive ? "#FFFFFF" : "var(--token-color-ink)",
                          border: isActive ? "none" : "1px solid var(--token-color-border)",
                        }}
                      >
                        {p}
                      </button>
                    );
                  })}

                  <span className="flex h-10 w-10 items-center justify-center" style={{ color: "var(--token-color-inkSoft)" }}>
                    ...
                  </span>

                  <button
                    type="button"
                    onClick={() => setPage(TOTAL_PAGES)}
                    className="flex h-10 w-10 items-center justify-center rounded-lg border text-base transition hover:bg-[var(--token-color-surfaceAlt)]"
                    style={{ borderColor: "var(--token-color-border)", color: "var(--token-color-ink)" }}
                  >
                    {TOTAL_PAGES}
                  </button>

                  <button
                    type="button"
                    aria-label="Next page"
                    onClick={() => setPage((p) => Math.min(TOTAL_PAGES, p + 1))}
                    className="flex h-10 w-10 items-center justify-center rounded-lg border transition hover:bg-[var(--token-color-surfaceAlt)]"
                    style={{ borderColor: "var(--token-color-border)" }}
                  >
                    <ChevronRight size={14} color="var(--token-color-inkSoft)" />
                  </button>
                </div>
              </div>

              {/* Sidebar content */}
              <div className="flex flex-col gap-6 xl:col-span-4">
                {/* Forum stats */}
                <div className="flex flex-col gap-4 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]">
                  <h4 className="text-sm font-semibold uppercase tracking-wide" style={{ color: "var(--token-color-ink)" }}>
                    Forum Stats
                  </h4>

                  <div className="flex justify-center gap-4">
                    <div
                      className="flex flex-1 flex-col items-center gap-2 rounded-lg px-4 py-4"
                      style={{ backgroundColor: "var(--token-color-surfaceAlt)" }}
                    >
                      <span className="text-2xl font-semibold" style={{ color: "var(--token-color-primary)" }}>
                        {forumStats.questions}
                      </span>
                      <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                        Questions
                      </span>
                    </div>
                    <div
                      className="flex flex-1 flex-col items-center gap-2 rounded-lg px-4 py-4"
                      style={{ backgroundColor: "var(--token-color-surfaceAlt)" }}
                    >
                      <span className="text-2xl font-semibold" style={{ color: "var(--token-color-primary)" }}>
                        {forumStats.resolvedPercent}
                      </span>
                      <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                        Resolved
                      </span>
                    </div>
                  </div>
                </div>

                {/* Pinned topics */}
                <div className="flex flex-col gap-4 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]">
                  <div className="flex items-center gap-2">
                    <Pin size={14} color="var(--token-color-error)" />
                    <h4 className="text-sm font-semibold uppercase tracking-wide" style={{ color: "var(--token-color-ink)" }}>
                      Pinned Topics
                    </h4>
                  </div>

                  <div className="flex flex-col gap-3">
                    {pinnedTopics.map((topic) => (
                      <Link
                        key={topic.id}
                        href="#"
                        className="flex items-start gap-3 transition hover:opacity-80"
                      >
                        <FileText size={18} color="var(--token-color-textMuted)" className="mt-0.5 shrink-0" />
                        <div className="flex flex-col">
                          <span style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-base)" }}>
                            {topic.title}
                          </span>
                          <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                            By {topic.author}
                          </span>
                        </div>
                      </Link>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}

function ThreadCard({ thread }: { thread: ForumThread }) {
  return (
    <article className="relative flex flex-col gap-2 overflow-hidden rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]">
      {thread.resolved && (
        <span
          className="absolute left-0 top-0 h-full w-1"
          style={{ backgroundColor: "var(--token-color-success)" }}
        />
      )}

      <div className="flex items-start justify-between">
        <div className="flex items-center gap-3">
          {thread.authorAvatar ? (
            <span className="relative block h-10 w-10 shrink-0 overflow-hidden rounded-full">
              <Image src={thread.authorAvatar} alt={thread.authorName} fill sizes="40px" className="object-cover" />
            </span>
          ) : (
            <span
              className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full text-sm font-bold tracking-wide"
              style={{ backgroundColor: "var(--token-color-primaryTint)", color: "var(--token-color-textMuted)" }}
            >
              {thread.authorInitials}
            </span>
          )}
          <div className="flex flex-col">
            <span className="text-sm font-semibold tracking-wide" style={{ color: "var(--token-color-ink)" }}>
              {thread.authorName}
            </span>
            <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
              {thread.postedAgo}
            </span>
          </div>
        </div>

        {thread.resolved && (
          <span
            className="flex items-center gap-1 rounded-sm px-2 py-1 text-xs font-medium"
            style={{
              backgroundColor: "var(--token-color-successTint)",
              color: "var(--token-color-success)",
              border: "1px solid var(--token-color-success)",
            }}
          >
            <CheckCircle2 size={12} />
            Resolved
          </span>
        )}
      </div>

      <h3 className="pt-2 text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
        {thread.title}
      </h3>

      <p className="pb-2" style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
        {thread.excerpt}
      </p>

      <div className="flex items-center justify-between pt-4" style={{ borderTop: "1px solid var(--token-color-border)" }}>
        <div className="flex items-center gap-4">
          <span className="flex items-center gap-1.5">
            <MessageSquare size={14} color="var(--token-color-inkSoft)" />
            <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
              {thread.replies} Replies
            </span>
          </span>
          <span className="flex items-center gap-1.5">
            <Eye size={14} color="var(--token-color-inkSoft)" />
            <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
              {thread.views} Views
            </span>
          </span>
        </div>

        <div className="flex gap-2">
          {thread.tags.map((tag) => (
            <span
              key={tag}
              className="rounded-sm px-2 py-1 text-xs font-medium"
              style={{ backgroundColor: "var(--token-color-surfaceAlt)", color: "var(--token-color-inkSoft)" }}
            >
              {tag}
            </span>
          ))}
        </div>
      </div>
    </article>
  );
}