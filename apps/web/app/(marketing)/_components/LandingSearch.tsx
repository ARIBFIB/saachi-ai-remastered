"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import { Search, TrendingUp, Star } from "lucide-react";

type FakeResult = {
  title: string;
  category: string;
  instructor: string;
  rating: number;
  students: number;
};

// NOTE: demo-only dummy dataset for the landing-page search preview.
const FAKE_COURSES: FakeResult[] = [
  { title: "Automate Everything with n8n & AI", category: "Automation", instructor: "Ayesha Khan", rating: 4.8, students: 2140 },
  { title: "Prompt Engineering for Client Work", category: "Fundamentals", instructor: "Hamza Malik", rating: 4.6, students: 980 },
  { title: "AI Chatbots for WhatsApp Support", category: "Automation", instructor: "Ayesha Khan", rating: 4.7, students: 1560 },
  { title: "Cold Outreach with Claude", category: "Marketing", instructor: "Sara Iqbal", rating: 4.5, students: 740 },
  { title: "Build AI Agents with LangChain", category: "Development", instructor: "Omar Sheikh", rating: 4.9, students: 3200 },
  { title: "AI Design Systems in Figma", category: "Design", instructor: "Noor Fatima", rating: 4.7, students: 1120 },
  { title: "Freelancing with AI Tools", category: "Career", instructor: "Bilal S.", rating: 4.4, students: 610 },
  { title: "Voice AI & Call Automation", category: "Automation", instructor: "Hina Malik", rating: 4.6, students: 890 }
];

export function LandingSearch() {
  const [query, setQuery] = useState("");
  const [focused, setFocused] = useState(false);

  const results = useMemo(() => {
    if (!query.trim()) return [];
    const q = query.toLowerCase();
    return FAKE_COURSES.filter(
      (c) =>
        c.title.toLowerCase().includes(q) ||
        c.category.toLowerCase().includes(q) ||
        c.instructor.toLowerCase().includes(q)
    ).slice(0, 5);
  }, [query]);

  const showDropdown = focused && query.trim().length > 0;

  return (
    <div className="relative mx-auto w-full max-w-xl">
      <div className="flex items-center gap-3 rounded-full border border-line bg-card px-5 py-3.5 shadow-sm transition-shadow focus-within:shadow-md">
        <Search size={18} className="shrink-0 text-ink-soft" />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onFocus={() => setFocused(true)}
          onBlur={() => setTimeout(() => setFocused(false), 150)}
          placeholder="Search courses, skills, or instructors..."
          className="w-full bg-transparent text-[14px] text-ink placeholder:text-ink-soft focus:outline-none"
        />
        {query && (
          <span className="shrink-0 rounded-full bg-paper-dim px-2.5 py-1 text-[11px] font-semibold text-ink-soft">
            {results.length} results
          </span>
        )}
      </div>

      {showDropdown && (
        <div className="absolute left-0 right-0 top-[calc(100%+8px)] z-30 overflow-hidden rounded-card border border-line bg-card shadow-lg">
          {results.length === 0 ? (
            <div className="px-5 py-6 text-center text-[13px] text-ink-soft">
              No matches for &quot;{query}&quot; -- try &quot;automation&quot; or &quot;design&quot;.
            </div>
          ) : (
            <ul className="flex flex-col divide-y divide-line">
              {results.map((r) => (
                <li key={r.title}>
                  <Link
                    href="/courses"
                    className="flex items-center justify-between gap-3 px-5 py-3 transition-colors hover:bg-paper-dim"
                  >
                    <div className="min-w-0">
                      <p className="truncate text-[13.5px] font-semibold text-ink">{r.title}</p>
                      <p className="text-[12px] text-ink-soft">
                        {r.category} - {r.instructor}
                      </p>
                    </div>
                    <div className="flex shrink-0 items-center gap-1 text-[12px] font-medium text-ink-soft">
                      <Star size={12} className="fill-current text-accent-pink" />
                      {r.rating}
                    </div>
                  </Link>
                </li>
              ))}
            </ul>
          )}
          <Link
            href="/courses"
            className="flex items-center justify-center gap-2 border-t border-line bg-paper-dim px-5 py-3 text-[12.5px] font-semibold text-accent-violet hover:underline"
          >
            <TrendingUp size={13} />
            See all courses matching &quot;{query}&quot;
          </Link>
        </div>
      )}
    </div>
  );
}
