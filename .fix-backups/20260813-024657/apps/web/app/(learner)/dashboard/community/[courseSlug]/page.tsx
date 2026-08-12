"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Input, Button } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  Search,
  Plus,
  MessageSquare,
  Eye,
  CheckCircle2,
  Pin,
  FileText,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";

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
      "I'm having trouble getting my implementation of stochastic gradient descent to converge on the provided dataset. It seems to oscillate...",
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

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

const forumStats = { questions: "1,248", resolvedPercent: "84%" };

const TOTAL_PAGES = 12; // TODO: derive from API pagination meta

export default function CommunityQAPage() {
  const [activeFilter, setActiveFilter] = useState(filters[0]);
  const [page, setPage] = useState(1);

  function handleAskQuestion() {
    // TODO: navigate to /dashboard/community/{courseSlug}/ask or open a modal
    console.log("ask a question");
  }

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Header */}
      <header className="fixed inset-x-0 top-0 z-50 h-16 bg-[var(--token-color-bg)] shadow-[var(--token-shadow-sm)]">
        <div className="flex h-full items-center justify-between px-6">
          <div className="flex items-center gap-6">
            <Link href="/" className="text-2xl font-black" style={{ color: "var(--token-color-primary)" }}>
              Saachi AI
            </Link>
            <nav className="hidden items-center gap-4 md:flex">
              <Link href="/courses" className="text-sm font-semibold tracking-wide" style={{ color: "var(--token-color-inkSoft)" }}>
                Marketplace
              </Link>
              <Link href="/categories" className="text-sm font-semibold tracking-wide" style={{ color: "var(--token-color-inkSoft)" }}>
                Categories
              </Link>
            </nav>
          </div>

          <div className="flex items-center gap-4">
            <div className="hidden w-64 md:block">
              <Input prefix={<Search size={14} color="var(--token-color-textMuted)" />} placeholder="Search..." />
            </div>
            <button aria-label="Cart" className="text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
              <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                <path
                  d="M6 20C5.45 20 4.97917 19.8042 4.5875 19.4125C4.19583 19.0208 4 18.55 4 18C4 17.45 4.19583 16.9792 4.5875 16.5875C4.97917 16.1958 5.45 16 6 16C6.55 16 7.02083 16.1958 7.4125 16.5875C7.80417 16.9792 8 17.45 8 18C8 18.55 7.80417 19.0208 7.4125 19.4125C7.02083 19.8042 6.55 20 6 20V20M16 20C15.45 20 14.9792 19.8042 14.5875 19.4125C14.1958 19.0208 14 18.55 14 18C14 17.45 14.1958 16.9792 14.5875 16.5875C14.9792 16.1958 15.45 16 16 16C16.55 16 17.0208 16.1958 17.4125 16.5875C17.8042 16.9792 18 17.45 18 18C18 18.55 17.8042 19.0208 17.4125 19.4125C17.0208 19.8042 16.55 20 16 20V20M5.15 4L7.55 9H14.55V9V9L17.3 4V4V4H5.15V4M4.2 2H18.95C19.3333 2 19.625 2.17083 19.825 2.5125C20.025 2.85417 20.0333 3.2 19.85 3.55L16.3 9.95C16.1167 10.2833 15.8708 10.5417 15.5625 10.725C15.2542 10.9083 14.9167 11 14.55 11H7.1L6 13V13V13H18V15H6C5.25 15 4.68333 14.6708 4.3 14.0125C3.91667 13.3542 3.9 12.7 4.25 12.05L5.6 9.6L2 2H0V0H3.25L4.2 2V2M7.55 9V9H14.55V9V9V9H7.55V9"
                  fill="currentColor"
                />
              </svg>
            </button>
            <Button type="primary">Sign In</Button>
          </div>
        </div>
      </header>

      {/* Sidebar -- kept white/light to match the rest of the dashboard */}
      <aside className="fixed inset-y-16 left-0 hidden w-72 flex-col border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex items-center gap-4 border-b border-[var(--token-color-border)] p-6">
          <span className="relative block h-12 w-12 shrink-0 overflow-hidden rounded-full">
            <Image src="https://i.pravatar.cc/96?img=47" alt="Learner avatar" fill sizes="48px" className="object-cover" />
          </span>
          <div className="flex flex-col">
            <span className="text-lg font-bold" style={{ color: "var(--token-color-ink)" }}>
              Learner Portal
            </span>
            <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
              Manage your skills
            </span>
          </div>
        </div>

        <nav className="flex flex-1 flex-col gap-1 py-4">
          {navItems.map(({ icon: Icon, label, href }) => {
            const isActive = label === "My Courses";
            return (
              <Link
                key={label}
                href={href}
                className="flex h-12 items-center gap-4 border-l-4 pl-4 pr-6 text-sm font-semibold tracking-wide transition"
                style={{
                  borderColor: isActive ? "var(--token-color-primary)" : "transparent",
                  backgroundColor: isActive ? "var(--token-color-primaryTint)" : "transparent",
                  color: isActive ? "var(--token-color-primary)" : "var(--token-color-inkSoft)",
                }}
              >
                <Icon size={18} />
                {label}
              </Link>
            );
          })}
        </nav>

        <div className="border-t border-[var(--token-color-border)] p-4">
          <Link
            href="/support"
            className="flex h-12 items-center gap-4 pl-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main column */}
      <div className="flex w-full flex-col pt-16 lg:pl-72">
        <main className="flex-1 p-12">
          <div className="flex flex-col gap-10">
            {/* Header & search */}
            <div className="flex items-start justify-between gap-6">
              <div className="flex flex-col gap-1">
                <h1 className="text-3xl font-bold leading-10" style={{ color: "var(--token-color-ink)" }}>
                  Advanced Machine Learning
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
                <div
                  className="flex flex-col gap-4 rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
                >
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

        {/* Footer */}
        <footer className="bg-zinc-200 px-6 py-10">
          <div className="flex flex-col gap-4">
            <span className="text-base font-bold" style={{ color: "var(--token-color-primary)" }}>
              Saachi AI
            </span>
            <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
              &copy; {new Date().getFullYear()} Saachi AI Marketplace. Empowering the future of skills.
            </p>

            <div className="flex flex-col gap-4 pt-4 sm:flex-row sm:justify-between">
              <div className="flex flex-col gap-1.5">
                <Link href="/about" className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                  About Us
                </Link>
                <Link href="/careers" className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                  Careers
                </Link>
              </div>
              <div className="flex flex-col gap-1.5">
                <Link href="/legal/privacy" className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                  Privacy Policy
                </Link>
                <Link href="/legal/terms" className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                  Terms of Service
                </Link>
                <Link href="/instructor/handbook" className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                  Instructor Handbook
                </Link>
              </div>
            </div>
          </div>
        </footer>
      </div>
    </div>
  );
}

function ThreadCard({ thread }: { thread: ForumThread }) {
  return (
    <article
      className="relative flex flex-col gap-2 overflow-hidden rounded-xl bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
    >
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