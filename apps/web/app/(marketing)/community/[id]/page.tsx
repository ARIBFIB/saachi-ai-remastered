"use client";

import { use } from "react";
import Link from "next/link";
import { ArrowLeft, ArrowBigUp, BadgeCheck } from "lucide-react";
import { useCommunityDetail } from "@saachi/api-client";
import { Loading, EmptyState, Button } from "@saachi/ui";

export default function CommunityDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { data: post, isLoading } = useCommunityDetail(id);

  if (isLoading) return <Loading label="Loading discussion..." fullScreen />;
  if (!post) {
    return (
      <div className="mx-auto max-w-2xl px-4 py-24">
        <EmptyState title="Discussion not found" description="This community post may have been removed." action={<Link href="/community"><Button>Back to community</Button></Link>} />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-3xl px-4 py-14 md:px-0">
      <Link href="/community" className="mb-6 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink">
        <ArrowLeft size={14} /> Back to community
      </Link>

      <div className="mb-2 flex flex-wrap items-center gap-2">
        <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{post.category}</span>
        {post.courseTitle && <span className="text-[12px] text-ink-soft">{post.courseTitle}</span>}
      </div>
      <h1 className="mb-3 font-display text-[26px] font-bold leading-tight text-ink md:text-[32px]">{post.title}</h1>

      <div className="mb-6 flex items-center gap-4 rounded-card border border-line bg-card p-5">
        <div className="flex shrink-0 flex-col items-center gap-1 text-ink-soft">
          <ArrowBigUp size={18} />
          <span className="text-[12px] font-semibold">{post.upvotes}</span>
        </div>
        <div>
          <p className="text-[13px] font-semibold text-ink">{post.authorName}</p>
          <p className="mt-2 text-[14.5px] leading-relaxed text-ink-soft">{post.body}</p>
        </div>
      </div>

      <h2 className="mb-4 text-[15px] font-semibold text-ink">{post.replies.length} repl{post.replies.length === 1 ? "y" : "ies"}</h2>
      <div className="flex flex-col gap-3">
        {post.replies.map((reply) => (
          <div key={reply.id} className="rounded-card border border-line bg-card p-4">
            <div className="mb-1 flex items-center gap-1.5">
              <span className="text-[13px] font-semibold text-ink">{reply.authorName}</span>
              {reply.isInstructor && <BadgeCheck size={13} className="text-teal" />}
            </div>
            <p className="text-[13.5px] text-ink-soft">{reply.body}</p>
          </div>
        ))}
        {post.replies.length === 0 && (
          <p className="text-[13px] text-ink-soft">No replies yet.</p>
        )}
      </div>
    </div>
  );
}