"use client";

import Link from "next/link";
import { useRef } from "react";
import { ChevronLeft, ChevronRight, Star, Flame } from "lucide-react";
import { cn } from "@saachi/ui";
import { TRENDING_COURSES } from "./landing-fake-data";

const BADGE_STYLES: Record<string, string> = {
  Bestseller: "bg-gold text-ink",
  New: "bg-teal text-white",
  Hot: "bg-accent-pink text-white",
  "Staff pick": "bg-accent-violet text-white"
};

export function TrendingCarousel() {
  const trackRef = useRef<HTMLDivElement>(null);

  function scrollBy(amount: number) {
    trackRef.current?.scrollBy({ left: amount, behavior: "smooth" });
  }

  return (
    <div>
      <div className="mb-5 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <Flame size={18} className="text-accent-pink" />
          <h2 className="font-display text-[22px] font-semibold text-ink">Trending this week</h2>
        </div>
        <div className="hidden items-center gap-2 md:flex">
          <button
            type="button"
            aria-label="Scroll left"
            onClick={() => scrollBy(-360)}
            className="flex h-9 w-9 items-center justify-center rounded-full border border-line bg-card text-ink-soft hover:bg-paper-dim"
          >
            <ChevronLeft size={16} />
          </button>
          <button
            type="button"
            aria-label="Scroll right"
            onClick={() => scrollBy(360)}
            className="flex h-9 w-9 items-center justify-center rounded-full border border-line bg-card text-ink-soft hover:bg-paper-dim"
          >
            <ChevronRight size={16} />
          </button>
        </div>
      </div>

      <div
        ref={trackRef}
        className="flex snap-x snap-mandatory gap-4 overflow-x-auto pb-3 [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden"
      >
        {TRENDING_COURSES.map((c) => (
          <Link
            key={c.id}
            href="/courses"
            className="group relative w-[260px] shrink-0 snap-start overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg"
          >
            <div className="relative aspect-video w-full overflow-hidden">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={c.image} alt={c.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
              <span className={cn("absolute left-3 top-3 rounded-full px-2.5 py-1 text-[10px] font-bold uppercase tracking-wide", BADGE_STYLES[c.badge])}>
                {c.badge}
              </span>
            </div>
            <div className="p-4">
              <p className="text-[11px] font-medium uppercase tracking-wide text-accent-violet">{c.category}</p>
              <h3 className="mt-1 line-clamp-2 text-[14.5px] font-semibold leading-snug text-ink">{c.title}</h3>
              <p className="mt-1 text-[12.5px] text-ink-soft">{c.instructor}</p>
              <div className="mt-3 flex items-center justify-between">
                <span className="flex items-center gap-1 text-[12.5px] font-medium text-ink-soft">
                  <Star size={12} className="fill-current text-accent-pink" />
                  {c.rating} ({c.students})
                </span>
                <span className="font-mono text-[14px] font-bold text-ink">{c.price}</span>
              </div>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}