"use client";

import { useEffect, useMemo, useRef, useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import {
  Search,
  ChevronDown,
  GraduationCap,
  Award,
  Newspaper,
  BookOpen,
  Users,
  ArrowUpRight
} from "lucide-react";
import { cn } from "@/lib/utils";
import {
  useCourseList,
  useNewsList,
  useBlogList,
  useCommunityList,
  useCertificateList
} from "@saachi/api-client";
import { CATEGORIES } from "../../lib/categories";

type FilterOption = { value: string; label: string; icon: typeof Search };

const FILTERS: FilterOption[] = [
  { value: "all", label: "All", icon: Search },
  { value: "courses", label: "Courses", icon: GraduationCap },
  { value: "certificates", label: "Certificates", icon: Award },
  { value: "news", label: "News", icon: Newspaper },
  { value: "blog", label: "Blog", icon: BookOpen },
  { value: "community", label: "Community", icon: Users }
];

function useHideOnScroll() {
  const [hidden, setHidden] = useState(false);
  const lastY = useRef(0);
  useEffect(() => {
    lastY.current = window.scrollY;
    function onScroll() {
      const y = window.scrollY;
      const goingDown = y > lastY.current;
      setHidden(goingDown && y > 80);
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

  const [query, setQuery] = useState("");
  const [activeFilter, setActiveFilter] = useState("all");
  const [deptOpen, setDeptOpen] = useState(false);
  const [department, setDepartment] = useState<string | undefined>(undefined);
  const [dropdownOpen, setDropdownOpen] = useState(false);

  const wrapperRef = useRef<HTMLDivElement>(null);
  const deptRef = useRef<HTMLDivElement>(null);

  const courseQuery = useCourseList({ search: query.trim() || undefined, category: department, sort: "popular" });
  const newsQuery = useNewsList({ search: query.trim() || undefined });
  const blogQuery = useBlogList({ search: query.trim() || undefined });
  const communityQuery = useCommunityList({ search: query.trim() || undefined });
  const certQuery = useCertificateList({ search: query.trim() || undefined });

  const courseResults = useMemo(() => (courseQuery.data?.items ?? []).slice(0, 4), [courseQuery.data]);
  const newsResults = useMemo(() => (newsQuery.data ?? []).slice(0, 3), [newsQuery.data]);
  const blogResults = useMemo(() => (blogQuery.data ?? []).slice(0, 3), [blogQuery.data]);
  const communityResults = useMemo(() => (communityQuery.data ?? []).slice(0, 3), [communityQuery.data]);
  const certResults = useMemo(() => (certQuery.data ?? []).slice(0, 3), [certQuery.data]);

  const showCourses = activeFilter === "all" || activeFilter === "courses";
  const showNews = activeFilter === "all" || activeFilter === "news";
  const showBlog = activeFilter === "all" || activeFilter === "blog";
  const showCommunity = activeFilter === "all" || activeFilter === "community";
  const showCerts = activeFilter === "all" || activeFilter === "certificates";

  const totalResults =
    (showCourses ? courseResults.length : 0) +
    (showNews ? newsResults.length : 0) +
    (showBlog ? blogResults.length : 0) +
    (showCommunity ? communityResults.length : 0) +
    (showCerts ? certResults.length : 0);

  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target as Node)) setDropdownOpen(false);
      if (deptRef.current && !deptRef.current.contains(e.target as Node)) setDeptOpen(false);
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    const params = new URLSearchParams();
    if (query.trim()) params.set("q", query.trim());
    if (activeFilter !== "all") params.set("type", activeFilter);
    if (department) params.set("category", department);
    router.push(`/search?${params.toString()}`);
    setDropdownOpen(false);
  }

  const departmentLabel = department ? CATEGORIES.find((c) => c.id === department)?.name ?? "Department" : "All departments";

  return (
    <div
      className={cn(
        "sticky top-16 z-30 border-b border-black/10 transition-transform duration-300 ease-out",
        hidden ? "-translate-y-full" : "translate-y-0"
      )}
      style={{ backgroundImage: "var(--color-accent-gradient)" }}
    >
      <div className="mx-auto flex max-w-7xl flex-col gap-3 px-4 py-3.5 md:px-8">
        <form onSubmit={handleSubmit} className="flex items-center gap-2.5">
          <div ref={wrapperRef} className="relative w-full max-w-md">
            <div className="flex h-11 items-center gap-2 rounded-full border border-white/25 bg-white pl-4 pr-2 shadow-sm">
              <Search size={16} className="shrink-0 text-ink-soft" />
              <input
                value={query}
                onChange={(e) => {
                  setQuery(e.target.value);
                  setDropdownOpen(true);
                }}
                onFocus={() => setDropdownOpen(true)}
                onClick={() => setDropdownOpen(true)}
                placeholder="Search courses, certificates, news..."
                className="w-full bg-transparent text-[13.5px] text-ink placeholder:text-ink-soft/60 focus:outline-none"
              />

              <div ref={deptRef} className="relative shrink-0">
                <button
                  type="button"
                  onClick={() => setDeptOpen((v) => !v)}
                  className="flex items-center gap-1 rounded-full bg-paper-dim px-2.5 py-1.5 text-[11px] font-semibold text-ink-soft transition-colors hover:text-ink"
                >
                  <span className="hidden max-w-[90px] truncate sm:inline">{departmentLabel}</span>
                  <ChevronDown size={13} className={cn("transition-transform duration-200", deptOpen && "rotate-180")} />
                </button>

                {deptOpen && (
                  <div className="absolute right-0 top-[calc(100%+8px)] z-40 w-56 overflow-hidden rounded-card border border-line bg-card shadow-lg">
                    <button
                      type="button"
                      onClick={() => { setDepartment(undefined); setDeptOpen(false); }}
                      className={cn("flex w-full items-center px-4 py-2.5 text-left text-[13px] transition-colors hover:bg-paper-dim", !department ? "font-semibold text-accent-violet" : "text-ink")}
                    >
                      All departments
                    </button>
                    {CATEGORIES.map((cat) => (
                      <button
                        key={cat.id}
                        type="button"
                        onClick={() => { setDepartment(cat.id); setDeptOpen(false); }}
                        className={cn("flex w-full items-center px-4 py-2.5 text-left text-[13px] transition-colors hover:bg-paper-dim", department === cat.id ? "font-semibold text-accent-violet" : "text-ink")}
                      >
                        {cat.name}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>

            {dropdownOpen && (
              <div className="absolute left-0 right-0 top-[calc(100%+8px)] z-40 overflow-hidden rounded-card border border-line bg-card shadow-xl">
                {totalResults === 0 ? (
                  <div className="px-4 py-6 text-center text-[13px] text-ink-soft">
                    {query.trim() ? `No results found for "${query}".` : "Start typing to search across the whole platform."}
                  </div>
                ) : (
                  <div className="max-h-96 overflow-y-auto">
                    {showCourses && courseResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">Courses</p>
                        {courseResults.map((course) => (
                          <Link key={course.id} href={`/courses/${course.slug}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <GraduationCap size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{course.title}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                    {showNews && newsResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">News</p>
                        {newsResults.map((article) => (
                          <Link key={article.id} href={`/news/${article.slug}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <Newspaper size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{article.title}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                    {showBlog && blogResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">Blog</p>
                        {blogResults.map((post) => (
                          <Link key={post.id} href={`/blog/${post.slug}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <BookOpen size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{post.title}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                    {showCommunity && communityResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">Community</p>
                        {communityResults.map((post) => (
                          <Link key={post.id} href={`/community/${post.id}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <Users size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{post.title}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                    {showCerts && certResults.length > 0 && (
                      <div>
                        <p className="px-4 pt-3 pb-1 text-[10.5px] font-semibold uppercase tracking-wide text-ink-soft/60">Certificates</p>
                        {certResults.map((cert) => (
                          <Link key={cert.id} href={`/certificates/${cert.id}`} onClick={() => setDropdownOpen(false)} className="flex items-center justify-between gap-3 px-4 py-2.5 transition-colors hover:bg-paper-dim">
                            <div className="flex min-w-0 items-center gap-2">
                              <Award size={14} className="shrink-0 text-accent-violet" />
                              <span className="truncate text-[13px] font-medium text-ink">{cert.courseTitle} - {cert.learnerName}</span>
                            </div>
                            <ArrowUpRight size={13} className="shrink-0 text-ink-soft" />
                          </Link>
                        ))}
                      </div>
                    )}
                  </div>
                )}
                {query.trim() && (
                  <Link
                    href={`/search?q=${encodeURIComponent(query)}${activeFilter !== "all" ? `&type=${activeFilter}` : ""}${department ? `&category=${department}` : ""}`}
                    onClick={() => setDropdownOpen(false)}
                    className="flex items-center justify-center gap-2 border-t border-line bg-paper-dim px-4 py-2.5 text-[12px] font-semibold text-accent-violet hover:underline"
                  >
                    See all results for &quot;{query}&quot;
                  </Link>
                )}
              </div>
            )}
          </div>

          <button type="submit" className="group/searchbtn relative hidden h-11 shrink-0 items-center gap-1.5 overflow-hidden rounded-full bg-zinc-900 px-5 sm:flex">
            <span className="absolute inset-0 bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500 opacity-50 blur transition-opacity duration-500 group-hover/searchbtn:opacity-90" />
            <span className="relative flex items-center gap-1.5 text-[13px] font-semibold text-white">
              <Search size={14} />
              Search
            </span>
          </button>
        </form>

        <div className="flex flex-wrap items-center gap-2">
          {FILTERS.map((filter) => {
            const Icon = filter.icon;
            const active = activeFilter === filter.value;
            return (
              <button
                key={filter.value}
                type="button"
                onClick={() => setActiveFilter(filter.value)}
                className={cn(
                  "flex items-center gap-1.5 rounded-full border px-3.5 py-1.5 text-[12.5px] font-semibold transition-all duration-150",
                  active ? "border-white bg-white text-ink shadow-sm" : "border-white/40 bg-white/10 text-white/90 hover:border-white/70 hover:bg-white/20"
                )}
              >
                <Icon size={13} />
                {filter.label}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}

export default TopSearchBar;