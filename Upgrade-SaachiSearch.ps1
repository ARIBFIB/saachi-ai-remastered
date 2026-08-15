# ============================================================
#  Saachi AI - Search UX Upgrade
#  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
#  PS> .\Upgrade-SaachiSearch.ps1
# ============================================================

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot                 # wherever you put this script
$web  = Join-Path $root "apps\web"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Saachi AI - Search Upgrade Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ── helper ──────────────────────────────────────────────────
function Write-File($path, $content) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  [OK] $path" -ForegroundColor Green
}

# ============================================================
#  STEP 1 — Install packages
# ============================================================
Write-Host "STEP 1: Installing npm packages..." -ForegroundColor Yellow
Set-Location $web
npm install cmdk @radix-ui/react-tabs --save --legacy-peer-deps
Write-Host "Packages installed." -ForegroundColor Green
Set-Location $root
Write-Host ""

# ============================================================
#  STEP 2 — Create SearchCommand component  (cmdk palette)
# ============================================================
Write-Host "STEP 2: Writing components..." -ForegroundColor Yellow

$searchCommand = @'
"use client";

/**
 * SearchCommand
 * cmdk-based command palette that powers the TopSearchBar dropdown.
 * Keyboard-navigable, grouped by content type, zero custom CSS hacks.
 */
import { useEffect, useRef, type ReactNode } from "react";
import { Command } from "cmdk";
import Link from "next/link";
import {
  GraduationCap,
  Newspaper,
  BookOpen,
  Users,
  Award,
  ArrowUpRight,
  Search
} from "lucide-react";
import { cn } from "@/lib/utils";

export type SearchGroup = {
  key: string;
  label: string;
  icon: ReactNode;
  items: { id: string; title: string; href: string; sub?: string }[];
};

type SearchCommandProps = {
  query: string;
  groups: SearchGroup[];
  onClose: () => void;
  className?: string;
};

export function SearchCommand({ query, groups, onClose, className }: SearchCommandProps) {
  const ref = useRef<HTMLDivElement>(null);

  // close on outside click
  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) onClose();
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, [onClose]);

  const totalItems = groups.reduce((s, g) => s + g.items.length, 0);
  const isEmpty = totalItems === 0;

  return (
    <div
      ref={ref}
      className={cn(
        "absolute left-0 right-0 top-[calc(100%+8px)] z-50 overflow-hidden rounded-xl border border-line bg-card shadow-2xl",
        className
      )}
    >
      <Command className="w-full" shouldFilter={false}>
        <Command.List className="max-h-[420px] overflow-y-auto p-1.5">
          {isEmpty ? (
            <Command.Empty className="py-10 text-center text-[13px] text-ink-soft">
              {query.trim()
                ? `No results for "${query}"`
                : "Start typing to search across courses, news, blog, and more."}
            </Command.Empty>
          ) : (
            groups.map((group) => {
              if (group.items.length === 0) return null;
              return (
                <Command.Group
                  key={group.key}
                  heading={
                    <div className="mb-1 flex items-center gap-1.5 px-2 pt-2 pb-0.5 text-[10.5px] font-semibold uppercase tracking-[0.08em] text-ink-soft/60">
                      {group.icon}
                      {group.label}
                    </div>
                  }
                >
                  {group.items.map((item) => (
                    <Command.Item
                      key={item.id}
                      value={item.id}
                      asChild
                      className="cursor-pointer rounded-lg px-3 py-2.5 text-[13px] transition-colors aria-selected:bg-gold-tint aria-selected:text-ink"
                      onSelect={() => onClose()}
                    >
                      <Link
                        href={item.href}
                        onClick={onClose}
                        className="flex items-center justify-between gap-3 outline-none"
                      >
                        <div className="min-w-0">
                          <p className="truncate font-medium text-ink">{item.title}</p>
                          {item.sub && (
                            <p className="mt-0.5 truncate text-[11.5px] text-ink-soft">{item.sub}</p>
                          )}
                        </div>
                        <ArrowUpRight size={13} className="shrink-0 text-ink-soft/60" />
                      </Link>
                    </Command.Item>
                  ))}
                </Command.Group>
              );
            })
          )}

          {/* footer: see all */}
          {query.trim() && (
            <div className="border-t border-line mt-1 pt-1">
              <Command.Item
                value="__see_all__"
                asChild
                className="cursor-pointer rounded-lg aria-selected:bg-gold-tint"
                onSelect={onClose}
              >
                <Link
                  href={`/search?q=${encodeURIComponent(query)}`}
                  onClick={onClose}
                  className="flex items-center justify-center gap-2 py-2.5 text-[12.5px] font-semibold text-accent-violet outline-none hover:underline"
                >
                  <Search size={13} />
                  See all results for &quot;{query}&quot;
                </Link>
              </Command.Item>
            </div>
          )}
        </Command.List>
      </Command>
    </div>
  );
}
'@

Write-File "$web\components\ui\search-command.tsx" $searchCommand

# ============================================================
#  STEP 3 — Rewrite TopSearchBar (uses SearchCommand)
# ============================================================
$topSearchBar = @'
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
'@

Write-File "$web\app\_components\TopSearchBar.tsx" $topSearchBar

# ============================================================
#  STEP 4 — Rewrite /search page (Radix Tabs + richer cards)
# ============================================================
$searchPage = @'
"use client";

import { Suspense, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import Link from "next/link";
import * as Tabs from "@radix-ui/react-tabs";
import {
  Search as SearchIcon,
  GraduationCap,
  Award,
  Newspaper,
  BookOpen,
  Users,
  Star
} from "lucide-react";
import {
  useCourseList,
  useNewsList,
  useBlogList,
  useCommunityList,
  useCertificateList
} from "@saachi/api-client";
import { CourseCard, EmptyState, Loading } from "@saachi/ui";
import { cn } from "@/lib/utils";

const TABS = [
  { value: "all",          label: "All",          icon: SearchIcon    },
  { value: "courses",      label: "Courses",      icon: GraduationCap },
  { value: "news",         label: "News",         icon: Newspaper     },
  { value: "blog",         label: "Blog",         icon: BookOpen      },
  { value: "community",    label: "Community",    icon: Users         },
  { value: "certificates", label: "Certificates", icon: Award         }
] as const;

type TabValue = (typeof TABS)[number]["value"];

/* ── small reusable card ─────────────────────────────────── */
function ContentCard({
  href,
  title,
  sub,
  tag,
  img
}: {
  href: string;
  title: string;
  sub?: string;
  tag?: string;
  img?: string;
}) {
  return (
    <Link
      href={href}
      className="group flex gap-4 rounded-xl border border-line bg-card p-4 transition-all hover:-translate-y-0.5 hover:border-gold-dark/40 hover:shadow-md"
    >
      {img && (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={img}
          alt={title}
          className="h-16 w-24 shrink-0 rounded-lg object-cover"
        />
      )}
      <div className="min-w-0 flex-1">
        {tag && (
          <span className="mb-1.5 inline-block rounded-full bg-gold-tint px-2 py-0.5 text-[10.5px] font-semibold text-gold-dark">
            {tag}
          </span>
        )}
        <h3 className="line-clamp-2 text-[14px] font-semibold leading-snug text-ink group-hover:text-accent-violet transition-colors">
          {title}
        </h3>
        {sub && <p className="mt-1 line-clamp-1 text-[12.5px] text-ink-soft">{sub}</p>}
      </div>
    </Link>
  );
}

/* ── section heading ─────────────────────────────────────── */
function SectionHeading({ icon: Icon, label }: { icon: typeof SearchIcon; label: string }) {
  return (
    <h2 className="mb-4 flex items-center gap-2 text-[15px] font-semibold text-ink">
      <Icon size={16} className="text-accent-violet" />
      {label}
    </h2>
  );
}

/* ── main content ────────────────────────────────────────── */
function SearchResults() {
  const router       = useRouter();
  const searchParams = useSearchParams();
  const q0           = searchParams.get("q") ?? "";
  const tab0         = (searchParams.get("type") ?? "all") as TabValue;

  const [inputVal, setInputVal] = useState(q0);
  const [tab, setTab]           = useState<TabValue>(tab0);

  const courseQ = useCourseList({ search: q0 || undefined });
  const newsQ   = useNewsList({ search: q0 || undefined });
  const blogQ   = useBlogList({ search: q0 || undefined });
  const commQ   = useCommunityList({ search: q0 || undefined });
  const certQ   = useCertificateList({ search: q0 || undefined });

  const loading = courseQ.isLoading || newsQ.isLoading || blogQ.isLoading || commQ.isLoading || certQ.isLoading;

  const courses = courseQ.data?.items ?? [];
  const news    = newsQ.data ?? [];
  const blog    = blogQ.data ?? [];
  const comm    = commQ.data ?? [];
  const certs   = certQ.data ?? [];

  const total   = courses.length + news.length + blog.length + comm.length + certs.length;

  function handleSearch(e: React.FormEvent) {
    e.preventDefault();
    const p = new URLSearchParams();
    if (inputVal.trim()) p.set("q", inputVal.trim());
    if (tab !== "all") p.set("type", tab);
    router.push(`/search?${p.toString()}`);
  }

  function changeTab(v: string) {
    setTab(v as TabValue);
    const p = new URLSearchParams();
    if (q0) p.set("q", q0);
    if (v !== "all") p.set("type", v);
    router.push(`/search?${p.toString()}`, { scroll: false });
  }

  const show = (key: TabValue) => tab === "all" || tab === key;

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      {/* ── search bar ── */}
      <div className="mb-8">
        <h1 className="mb-4 font-display text-[26px] font-bold text-ink">Search</h1>
        <form onSubmit={handleSearch} className="flex max-w-lg gap-2">
          <div className="flex flex-1 items-center gap-2 rounded-full border border-line-strong bg-card px-4 py-2.5 shadow-sm focus-within:border-accent-violet transition-colors">
            <SearchIcon size={16} className="shrink-0 text-ink-soft" />
            <input
              value={inputVal}
              onChange={(e) => setInputVal(e.target.value)}
              placeholder="Search courses, news, blog, community..."
              className="flex-1 bg-transparent text-[14px] text-ink placeholder:text-ink-soft/60 focus:outline-none"
            />
          </div>
          <button
            type="submit"
            className="rounded-full px-5 py-2.5 text-[13.5px] font-semibold text-white transition-all hover:brightness-110"
            style={{ backgroundImage: "var(--color-accent-gradient)" }}
          >
            Search
          </button>
        </form>
      </div>

      {/* ── tabs (Radix) ── */}
      <Tabs.Root value={tab} onValueChange={changeTab}>
        <Tabs.List className="mb-8 flex flex-wrap gap-1.5 border-b border-line pb-0">
          {TABS.map(({ value, label, icon: Icon }) => (
            <Tabs.Trigger
              key={value}
              value={value}
              className={cn(
                "relative flex items-center gap-1.5 rounded-t-lg px-3.5 py-2 text-[12.5px] font-semibold transition-colors",
                "text-ink-soft hover:text-ink",
                "data-[state=active]:text-accent-violet",
                // animated bottom border
                "after:absolute after:bottom-[-1px] after:left-0 after:right-0 after:h-[2px] after:rounded-t-full after:bg-accent-violet after:scale-x-0 after:transition-transform",
                "data-[state=active]:after:scale-x-100"
              )}
            >
              <Icon size={13} />
              {label}
            </Tabs.Trigger>
          ))}
        </Tabs.List>

        {/* ── results ── */}
        <Tabs.Content value={tab} forceMount className="outline-none">
          {!q0 ? (
            <EmptyState
              title="Search Saachi AI"
              description="Type a course, topic, article, or instructor name above."
            />
          ) : loading ? (
            <Loading label="Searching..." />
          ) : total === 0 ? (
            <EmptyState
              title={`No results for "${q0}"`}
              description="Try a different search term."
            />
          ) : (
            <div className="flex flex-col gap-12">
              {/* Courses */}
              {show("courses") && courses.length > 0 && (
                <section>
                  <SectionHeading icon={GraduationCap} label="Courses" />
                  <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
                    {courses.map((c) => (
                      <CourseCard
                        key={c.id}
                        slug={c.slug}
                        title={c.title}
                        thumbnailUrl={c.thumbnailUrl}
                        instructorName={c.instructor.fullName}
                        price={c.price}
                        currency={c.currency}
                        rating={c.rating}
                        ratingCount={c.ratingCount}
                      />
                    ))}
                  </div>
                </section>
              )}

              {/* News */}
              {show("news") && news.length > 0 && (
                <section>
                  <SectionHeading icon={Newspaper} label="News" />
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-3">
                    {news.map((a) => (
                      <ContentCard
                        key={a.id}
                        href={`/news/${a.slug}`}
                        title={a.title}
                        sub={a.excerpt}
                        tag={a.category}
                        img={a.imageUrl}
                      />
                    ))}
                  </div>
                </section>
              )}

              {/* Blog */}
              {show("blog") && blog.length > 0 && (
                <section>
                  <SectionHeading icon={BookOpen} label="Blog" />
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 xl:grid-cols-3">
                    {blog.map((b) => (
                      <ContentCard
                        key={b.id}
                        href={`/blog/${b.slug}`}
                        title={b.title}
                        sub={b.excerpt}
                        tag={b.tag}
                        img={b.imageUrl}
                      />
                    ))}
                  </div>
                </section>
              )}

              {/* Community */}
              {show("community") && comm.length > 0 && (
                <section>
                  <SectionHeading icon={Users} label="Community" />
                  <div className="flex flex-col gap-3">
                    {comm.map((p) => (
                      <ContentCard
                        key={p.id}
                        href={`/community/${p.id}`}
                        title={p.title}
                        sub={p.body}
                        tag={p.category}
                      />
                    ))}
                  </div>
                </section>
              )}

              {/* Certificates */}
              {show("certificates") && certs.length > 0 && (
                <section>
                  <SectionHeading icon={Award} label="Certificates" />
                  <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
                    {certs.map((c) => (
                      <Link
                        key={c.id}
                        href={`/certificates/${c.id}`}
                        className="flex items-start gap-3 rounded-xl border border-line bg-card p-4 transition-all hover:-translate-y-0.5 hover:border-gold-dark/40 hover:shadow-md"
                      >
                        <Award size={20} className="mt-0.5 shrink-0 text-gold-dark" />
                        <div className="min-w-0">
                          <p className="font-semibold text-[14px] text-ink">{c.courseTitle}</p>
                          <p className="mt-0.5 text-[12.5px] text-ink-soft">
                            {c.learnerName} &middot; {c.verificationId}
                          </p>
                        </div>
                      </Link>
                    ))}
                  </div>
                </section>
              )}
            </div>
          )}
        </Tabs.Content>
      </Tabs.Root>
    </div>
  );
}

export default function SearchPage() {
  return (
    <Suspense fallback={<Loading label="Loading..." />}>
      <SearchResults />
    </Suspense>
  );
}
'@

Write-File "$web\app\(marketing)\search\page.tsx" $searchPage

# ============================================================
#  STEP 5 — Add cmdk base styles to globals.css (if not present)
# ============================================================
Write-Host "STEP 5: Patching globals.css for cmdk..." -ForegroundColor Yellow
$globalsPath = "$web\app\globals.css"
$existing    = Get-Content $globalsPath -Raw

$cmdkCSS = @"

/* ── cmdk command palette base ──────────────────────────── */
[cmdk-root] {
  outline: none;
}
[cmdk-group-heading] {
  user-select: none;
  pointer-events: none;
}
[cmdk-item] {
  display: flex;
  align-items: center;
  cursor: pointer;
  user-select: none;
  outline: none;
}
[cmdk-item][aria-selected="true"] {
  background: var(--color-gold-tint);
}
"@

if ($existing -notmatch "\[cmdk-root\]") {
    Add-Content -Path $globalsPath -Value $cmdkCSS
    Write-Host "  [OK] globals.css patched" -ForegroundColor Green
} else {
    Write-Host "  [SKIP] cmdk CSS already in globals.css" -ForegroundColor DarkGray
}

# ============================================================
#  Done
# ============================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  All done! Run your dev server:" -ForegroundColor Cyan
Write-Host "  cd apps\web && npm run dev" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""