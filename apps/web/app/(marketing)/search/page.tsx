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

/* â”€â”€ small reusable card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
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

/* â”€â”€ section heading â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
function SectionHeading({ icon: Icon, label }: { icon: typeof SearchIcon; label: string }) {
  return (
    <h2 className="mb-4 flex items-center gap-2 text-[15px] font-semibold text-ink">
      <Icon size={16} className="text-accent-violet" />
      {label}
    </h2>
  );
}

/* â”€â”€ main content â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */
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
      {/* â”€â”€ search bar â”€â”€ */}
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

      {/* â”€â”€ tabs (Radix) â”€â”€ */}
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

        {/* â”€â”€ results â”€â”€ */}
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