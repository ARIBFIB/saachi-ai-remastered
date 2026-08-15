"use client";

import Link from "next/link";
import { useState } from "react";
import { Newspaper } from "lucide-react";
import { useNewsList } from "@saachi/api-client";
import { Input, Loading, EmptyState } from "@saachi/ui";

export default function NewsListPage() {
  const [search, setSearch] = useState("");
  const { data, isLoading } = useNewsList({ search: search || undefined });

  return (
    <div className="mx-auto max-w-6xl px-4 py-14 md:px-8">
      <div className="mb-8 flex items-center gap-2">
        <Newspaper size={22} className="text-accent-violet" />
        <h1 className="font-display text-[28px] font-bold text-ink">News</h1>
      </div>
      <Input
        placeholder="Search news..."
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        className="mb-8 max-w-sm"
      />

      {isLoading ? (
        <Loading label="Loading news..." />
      ) : !data || data.length === 0 ? (
        <EmptyState title="No articles found" description="Try a different search term." />
      ) : (
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {data.map((article) => (
            <Link
              key={article.id}
              href={`/news/${article.slug}`}
              className="group overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg"
            >
              <div className="aspect-video w-full overflow-hidden">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={article.imageUrl} alt={article.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
              </div>
              <div className="p-5">
                <div className="mb-2 flex items-center justify-between">
                  <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{article.category}</span>
                  <span className="text-[11.5px] text-ink-soft">{article.readTime}</span>
                </div>
                <h3 className="line-clamp-2 text-[15px] font-semibold leading-snug text-ink">{article.title}</h3>
                <p className="mt-2 line-clamp-2 text-[13px] text-ink-soft">{article.excerpt}</p>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}