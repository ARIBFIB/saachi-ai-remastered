"use client";

import Link from "next/link";
import { useState } from "react";
import { Users, MessageCircle, ArrowBigUp } from "lucide-react";
import { useCommunityList } from "@saachi/api-client";
import { Input, Loading, EmptyState } from "@saachi/ui";

export default function CommunityListPage() {
  const [search, setSearch] = useState("");
  const { data, isLoading } = useCommunityList({ search: search || undefined });

  return (
    <div className="mx-auto max-w-4xl px-4 py-14 md:px-8">
      <div className="mb-8 flex items-center gap-2">
        <Users size={22} className="text-accent-violet" />
        <h1 className="font-display text-[28px] font-bold text-ink">Community</h1>
      </div>
      <Input
        placeholder="Search discussions..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-8 max-w-sm"
      />

      {isLoading ? (
        <Loading label="Loading discussions..." />
      ) : !data || data.length === 0 ? (
        <EmptyState title="No discussions found" description="Try a different search term." />
      ) : (
        <div className="flex flex-col gap-3">
          {data.map((post) => (
            <Link
              key={post.id}
              href={`/community/${post.id}`}
              className="flex items-start gap-4 rounded-card border border-line bg-card p-5 transition-colors hover:border-gold-dark/40"
            >
              <div className="flex shrink-0 flex-col items-center gap-1 text-ink-soft">
                <ArrowBigUp size={18} />
                <span className="text-[12px] font-semibold">{post.upvotes}</span>
              </div>
              <div className="min-w-0 flex-1">
                <div className="mb-1 flex flex-wrap items-center gap-2">
                  <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{post.category}</span>
                  {post.courseTitle && <span className="text-[11.5px] text-ink-soft">{post.courseTitle}</span>}
                </div>
                <h3 className="text-[15px] font-semibold text-ink">{post.title}</h3>
                <p className="mt-1 line-clamp-2 text-[13px] text-ink-soft">{post.body}</p>
                <div className="mt-2 flex items-center gap-3 text-[12px] text-ink-soft">
                  <span>{post.authorName}</span>
                  <span className="flex items-center gap-1">
                    <MessageCircle size={12} /> {post.replies.length}
                  </span>
                </div>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}