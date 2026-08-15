"use client";

import { use } from "react";
import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { useNewsDetail } from "@saachi/api-client";
import { Loading, EmptyState, Button } from "@saachi/ui";

export default function NewsDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = use(params);
  const { data: article, isLoading } = useNewsDetail(slug);

  if (isLoading) return <Loading label="Loading article..." fullScreen />;
  if (!article) {
    return (
      <div className="mx-auto max-w-2xl px-4 py-24">
        <EmptyState title="Article not found" description="This news article may have been removed." action={<Link href="/news"><Button>Back to news</Button></Link>} />
      </div>
    );
  }

  return (
    <article className="mx-auto max-w-3xl px-4 py-14 md:px-0">
      <Link href="/news" className="mb-6 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink">
        <ArrowLeft size={14} /> Back to news
      </Link>

      <span className="mb-3 inline-block rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{article.category}</span>
      <h1 className="mb-3 font-display text-[30px] font-bold leading-tight text-ink md:text-[38px]">{article.title}</h1>
      <p className="mb-6 text-[13px] text-ink-soft">
        {article.author} - {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(article.publishedAt))} - {article.readTime}
      </p>

      <div className="mb-8 aspect-video w-full overflow-hidden rounded-card">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img src={article.imageUrl} alt={article.title} className="h-full w-full object-cover" />
      </div>

      <div className="flex flex-col gap-4 text-[15px] leading-relaxed text-ink-soft">
        {article.body.split("\n\n").map((para, i) => (
          <p key={i}>{para}</p>
        ))}
      </div>
    </article>
  );
}