"use client";

import { use } from "react";
import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { useBlogDetail } from "@saachi/api-client";
import { Loading, EmptyState, Button } from "@saachi/ui";

export default function BlogDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = use(params);
  const { data: post, isLoading } = useBlogDetail(slug);

  if (isLoading) return <Loading label="Loading post..." fullScreen />;
  if (!post) {
    return (
      <div className="mx-auto max-w-2xl px-4 py-24">
        <EmptyState title="Post not found" description="This blog post may have been removed." action={<Link href="/blog"><Button>Back to blog</Button></Link>} />
      </div>
    );
  }

  return (
    <article className="mx-auto max-w-3xl px-4 py-14 md:px-0">
      <Link href="/blog" className="mb-6 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink">
        <ArrowLeft size={14} /> Back to blog
      </Link>

      <span className="mb-3 inline-block rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{post.tag}</span>
      <h1 className="mb-3 font-display text-[30px] font-bold leading-tight text-ink md:text-[38px]">{post.title}</h1>
      <p className="mb-6 text-[13px] text-ink-soft">
        {post.author} - {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(post.publishedAt))} - {post.readTime}
      </p>

      <div className="mb-8 aspect-video w-full overflow-hidden rounded-card">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={post.imageUrl} alt={post.title} className="h-full w-full object-cover" />
      </div>

      <div className="flex flex-col gap-4 text-[15px] leading-relaxed text-ink-soft">
        {post.body.split("\n\n").map((para, i) => (
          <p key={i}>{para}</p>
        ))}
      </div>
    </article>
  );
}