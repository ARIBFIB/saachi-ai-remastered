"use client";

import { useEffect, useMemo, useRef, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { Search, ChevronDown, GraduationCap, Award, Newspaper, BookOpen, Users } from "lucide-react";
import { cn } from "@/lib/utils";
import {
  useCourseList,
  useNewsList,
  useBlogList,
  useCommunityList,
  useCertificateList
} from "@saachi/api-client";
import { CATEGORIES } from "../../lib/categories";
import { SearchCommand, type SearchGroup } from "@/components/ui/search-command";

function useHideOnScroll() {
  const [hidden, setHidden] = useState(false);
  const lastY = useRef(0);
  useEffect(() => {
    lastY.current = window.scrollY;
    function onScroll() {
      const y = window.scrollY;
      setHidden(y > lastY.current && y > 80);
      lastY.current = y;
    }
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);
  return hidden;
}

export function TopSearchBar() {
  const router = useRouter();
  const hidden = useHideOnScroll();

  const [query, setQuery]       = useState("");
  const [deptOpen, setDeptOpen] = useState(false);
  const [department, setDept]   = useState<string | undefined>(undefined);
  const [open, setOpen]         = useState(false);

  const deptRef    = useRef<HTMLDivElement>(null);
  const inputRef   = useRef<HTMLInputElement>(null);
  const wrapperRef = useRef<HTMLDivElement>(null);

  // live search hooks
  const courseQ = useCourseList({ search: query || undefined, category: department, sort: "popular" });
  const newsQ   = useNewsList({ search: query || undefined });
  const blogQ   = useBlogList({ search: query || undefined });
  const commQ   = useCommunityList({ search: query || undefined });
  const certQ   = useCertificateList({ search: query || undefined });

  const groups: SearchGroup[] = useMemo(() => [
    {
      key: "courses",
      label: "Courses",
      icon: <GraduationCap size={12} />,
      items: (courseQ.data?.items ?? []).slice(0, 5).map((c) => ({
        id: c.id,
        title: c.title,
        href: `/courses/${c.slug}`,
        sub: c.instructor.fullName
      }))
    },
    {
      key: "news",
      label: "News",
      icon: <Newspaper size={12} />,
      items: (newsQ.data ?? []).slice(0, 3).map((n) => ({
        id: n.id,
        title: n.title,
        href: `/news/${n.slug}`,
        sub: n.category
      }))
    },
    {
      key: "blog",
      label: "Blog",
      icon: <BookOpen size={12} />,
      items: (blogQ.data ?? []).slice(0, 3).map((b) => ({
        id: b.id,
        title: b.title,
        href: `/blog/${b.slug}`,
        sub: b.tag
      }))
    },
    {
      key: "community",
      label: "Community",
      icon: <Users size={12} />,
      items: (commQ.data ?? []).slice(0, 3).map((p) => ({
        id: p.id,
        title: p.title,
        href: `/community/${p.id}`,
        sub: p.category
      }))
    },
    {
      key: "certificates",
      label: "Certificates",
      icon: <Award size={12} />,
      items: (certQ.data ?? []).slice(0, 3).map((c) => ({
        id: c.id,
        title: c.courseTitle,
        href: `/certificates/${c.id}`,
        sub: c.learnerName
      }))
    }
  ], [courseQ.data, newsQ.data, blogQ.data, commQ.data, certQ.data]);

  // close dept dropdown on outside click
  useEffect(() => {
    function handle(e: MouseEvent) {
      if (deptRef.current && !deptRef.current.contains(e.target as Node)) setDeptOpen(false);
    }
    document.addEventListener("mousedown", handle);
    return () => document.removeEventListener("mousedown", handle);
  }, []);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setOpen(false);
    const params = new URLSearchParams();
    if (query.trim()) params.set("q", query.trim());
    if (department)   params.set("category", department);
    router.push(`/search?${params.toString()}`);
  }

  const deptLabel = department
    ? CATEGORIES.find((c) => c.id === department)?.name ?? "Department"
    : "All departments";

  return (
    <div
      className={cn(
        "sticky top-16 z-30 border-b border-black/10 transition-transform duration-300 ease-out",
        hidden ? "-translate-y-full" : "translate-y-0"
      )}
      style={{ backgroundImage: "var(--color-accent-gradient)" }}
    >
      <div className="mx-auto flex max-w-7xl items-center gap-3 px-4 py-3 md:px-8">
        {/* Search input + cmdk dropdown */}
        <form onSubmit={handleSubmit} className="relative flex-1 max-w-xl" ref={wrapperRef}>
          <div className="flex h-11 items-center gap-2 rounded-full border border-white/25 bg-white pl-4 pr-2 shadow-sm">
            <Search size={16} className="shrink-0 text-ink-soft" />
            <input
              ref={inputRef}
              value={query}
              onChange={(e) => { setQuery(e.target.value); setOpen(true); }}
              onFocus={() => setOpen(true)}
              placeholder="Search courses, news, community..."
              className="w-full bg-transparent text-[13.5px] text-ink placeholder:text-ink-soft/60 focus:outline-none"
            />

            {/* Department picker */}
            <div ref={deptRef} className="relative shrink-0">
              <button
                type="button"
                onClick={() => setDeptOpen((v) => !v)}
                className="flex items-center gap-1 rounded-full bg-paper-dim px-2.5 py-1.5 text-[11px] font-semibold text-ink-soft hover:text-ink transition-colors"
              >
                <span className="hidden max-w-[90px] truncate sm:inline">{deptLabel}</span>
                <ChevronDown size={12} className={cn("transition-transform duration-200", deptOpen && "rotate-180")} />
              </button>

              {deptOpen && (
                <div className="absolute right-0 top-[calc(100%+8px)] z-50 w-56 overflow-hidden rounded-xl border border-line bg-card shadow-xl">
                  <button
                    type="button"
                    onClick={() => { setDept(undefined); setDeptOpen(false); }}
                    className={cn("flex w-full items-center px-4 py-2.5 text-left text-[13px] hover:bg-paper-dim", !department ? "font-semibold text-accent-violet" : "text-ink")}
                  >
                    All departments
                  </button>
                  {CATEGORIES.map((cat) => (
                    <button
                      key={cat.id}
                      type="button"
                      onClick={() => { setDept(cat.id); setDeptOpen(false); }}
                      className={cn("flex w-full items-center px-4 py-2.5 text-left text-[13px] hover:bg-paper-dim", department === cat.id ? "font-semibold text-accent-violet" : "text-ink")}
                    >
                      {cat.name}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* cmdk dropdown */}
          {open && (
            <SearchCommand
              query={query}
              groups={groups}
              onClose={() => setOpen(false)}
            />
          )}
        </form>

        {/* Search button */}
        <button
          type="submit"
          form="top-search-form"
          onClick={handleSubmit as any}
          className="group/btn relative hidden h-11 shrink-0 items-center gap-1.5 overflow-hidden rounded-full bg-zinc-900 px-5 sm:flex"
        >
          <span className="absolute inset-0 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 opacity-50 blur transition-opacity duration-500 group-hover/btn:opacity-90" />
          <span className="relative flex items-center gap-1.5 text-[13px] font-semibold text-white">
            <Search size={14} />
            Search
          </span>
        </button>
      </div>
    </div>
  );
}

export default TopSearchBar;