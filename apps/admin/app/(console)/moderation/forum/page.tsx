"use client";

import { useState } from "react";
import { MessagesSquare, Trash2, ShieldAlert, CheckCircle2 } from "lucide-react";
import { useFlaggedForumPosts, useResolveFlaggedForumPost, type FlaggedForumPost } from "@saachi/api-client";
import { Button, Card, Select, StatusPill, ShimmerTableRow, EmptyState } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Removed", value: "removed" },
  { label: "Dismissed", value: "dismissed" },
  { label: "Warned", value: "warned" }
];

const STATUS_TONE: Record<FlaggedForumPost["status"], "warning" | "error" | "neutral" | "info"> = {
  pending: "warning",
  removed: "error",
  dismissed: "neutral",
  warned: "info"
};

export default function FlaggedForumPostsPage() {
  const [statusFilter, setStatusFilter] = useState("pending");
  const { data: posts, isLoading } = useFlaggedForumPosts({ status: statusFilter || undefined });
  const resolve = useResolveFlaggedForumPost();

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <MessagesSquare size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Flagged Forum Posts</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Community Q&A posts reported for review.</p>
          </div>
        </div>
        <div className="w-[180px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
      </div>

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={4} />
          ))}
        </div>
      ) : !posts || posts.length === 0 ? (
        <EmptyState icon={<MessagesSquare size={22} strokeWidth={1.75} />} title="Nothing flagged" description="No forum posts match this filter." />
      ) : (
        <div className="flex flex-col gap-4">
          {posts.map((post) => (
            <Card key={post.id} className="flex flex-col gap-4 p-5">
              <div>
                <div className="flex items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{post.authorName}</p>
                  <StatusPill label={post.status} tone={STATUS_TONE[post.status]} />
                </div>
                <p className="mt-1 text-[12.5px] text-ink-soft">
                  in {post.courseTitle} - {formatRelativeTime(post.createdAt)}
                </p>
              </div>

              <p className="rounded-control border border-line bg-paper-dim p-3.5 text-[13.5px] leading-relaxed text-ink">
                {post.body}
              </p>

              <div className="flex items-center gap-2 text-[12.5px] text-ink-soft">
                <ShieldAlert size={13} strokeWidth={1.75} className="shrink-0 text-error" />
                Flagged by {post.flaggedBy} - reason: {post.flagReason}
              </div>

              {post.status === "pending" && (
                <div className="flex flex-wrap gap-2">
                  <Button size="sm" variant="secondary" onClick={() => resolve.mutate({ id: post.id, status: "dismissed" })}>
                    <CheckCircle2 size={14} strokeWidth={1.75} /> Dismiss flag
                  </Button>
                  <Button size="sm" variant="secondary" onClick={() => resolve.mutate({ id: post.id, status: "warned" })}>
                    Warn user
                  </Button>
                  <Button size="sm" variant="danger" onClick={() => resolve.mutate({ id: post.id, status: "removed" })}>
                    <Trash2 size={14} strokeWidth={1.75} /> Remove post
                  </Button>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}