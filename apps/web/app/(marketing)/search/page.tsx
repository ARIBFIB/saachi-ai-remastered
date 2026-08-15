"use client";

import { Suspense, useState } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import Link from "next/link";
import { Search as SearchIcon, GraduationCap, Award, Newspaper, BookOpen, Users } from "lucide-react";
import {
  useCourseList,
  useNewsList,
  useBlogList,
  useCommunityList,
  useCertificateList
} from "@saachi/api-client";
import { CourseCard, EmptyState, Input, Loading, cn } from "@saachi/ui";

const TABS = [
  { value: "all", label: "All", icon: SearchIcon },
  { value: "courses", label: "Courses", icon: GraduationCap },
  { value: "news", label: "News", icon: Newspaper },
  { value: "blog", label: "Blog", icon: BookOpen },
  { value: "community", label: "Community", icon: Users },
  { value: "certificates", label: "Certificates", icon: Award }
];

function SearchResults() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const initialQuery = searchParams.get("q") ?? "";
  const initialType = searchParams.get("type") ?? "all";
  const [query, setQuery] = useState(initialQuery);
  const [tab, setTab] = useState(initialType);

  const courseQuery = useCourseList({ search: initialQuery || undefined });
  const newsQuery = useNewsList({ search: initialQuery || undefined });
  const blogQuery = useBlogList({ search: initialQuery || undefined });
  const communityQuery = useCommunityList({ search: initialQuery || undefined });
  const certQuery = useCertificateList({ search: initialQuery || undefined });

  const isLoading = courseQuery.isLoading || newsQuery.isLoading || blogQuery.isLoading || communityQuery.isLoading || certQuery.isLoading;

  const courses = courseQuery.data?.items ?? [];
  const news = newsQuery.data ?? [];
  const blog = blogQuery.data ?? [];
  const community = communityQuery.data ?? [];
  const certs = certQuery.data ?? [];

  const totalCount = courses.length + news.length + blog.length + community.length + certs.length;

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    router.push(`/search?q=${encodeURIComponent(query)}${tab !== "all" ? `&type=${tab}` : ""}`);
  }

  return (
    <div className="mx-auto max-w-7xl px-4 py-10 md:px-8">
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Search</h1>

      <form onSubmit={handleSubmit} className="mb-6 flex max-w-lg gap-2">
        <Input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Search courses, news, blog, community, certificates..." className="flex-1" />
      </form>

      <div className="mb-8 flex flex-wrap gap-2">
        {TABS.map((t) => {
          const Icon = t.icon;
          const active = tab === t.value;
          return (
            <button
              key={t.value}
              type="button"
              onClick={() => setTab(t.value)}
              className={cn(
                "flex items-center gap-1.5 rounded-full border px-3.5 py-1.5 text-[12.5px] font-semibold transition-colors",
                active ? "border-transparent bg-gradient-brand text-white" : "border-line text-ink-soft hover:border-line-strong hover:text-ink"
              )}
            >
              <Icon size={13} />
              {t.label}
            </button>
          );
        })}
      </div>

      {!initialQuery ? (
        <EmptyState title="Search Saachi AI" description="Type a course, topic, article, or instructor name above to get started." />
      ) : isLoading ? (
        <Loading label="Searching..." />
      ) : totalCount === 0 ? (
        <EmptyState title={`No results for "${initialQuery}"`} description="Try a different search term." />
      ) : (
        <div className="flex flex-col gap-12">
          {(tab === "all" || tab === "courses") && courses.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <GraduationCap size={16} className="text-accent-violet" /> Courses
              </h2>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
                {courses.map((course) => (
                  <CourseCard key={course.id} slug={course.slug} title={course.title} thumbnailUrl={course.thumbnailUrl} instructorName={course.instructor.fullName} price={course.price} currency={course.currency} rating={course.rating} ratingCount={course.ratingCount} />
                ))}
              </div>
            </section>
          )}

          {(tab === "all" || tab === "news") && news.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <Newspaper size={16} className="text-accent-violet" /> News
              </h2>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
                {news.map((article) => (
                  <Link key={article.id} href={`/news/${article.slug}`} className="group overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg">
                    <div className="aspect-video w-full overflow-hidden">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img src={article.imageUrl} alt={article.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
                    </div>
                    <div className="p-4">
                      <h3 className="line-clamp-2 text-[14.5px] font-semibold text-ink">{article.title}</h3>
                      <p className="mt-1 line-clamp-2 text-[12.5px] text-ink-soft">{article.excerpt}</p>
                    </div>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {(tab === "all" || tab === "blog") && blog.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <BookOpen size={16} className="text-accent-violet" /> Blog
              </h2>
              <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 xl:grid-cols-3">
                {blog.map((post) => (
                  <Link key={post.id} href={`/blog/${post.slug}`} className="group overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg">
                    <div className="aspect-video w-full overflow-hidden">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img src={post.imageUrl} alt={post.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
                    </div>
                    <div className="p-4">
                      <h3 className="line-clamp-2 text-[14.5px] font-semibold text-ink">{post.title}</h3>
                      <p className="mt-1 line-clamp-2 text-[12.5px] text-ink-soft">{post.excerpt}</p>
                    </div>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {(tab === "all" || tab === "community") && community.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <Users size={16} className="text-accent-violet" /> Community
              </h2>
              <div className="flex flex-col gap-3">
                {community.map((post) => (
                  <Link key={post.id} href={`/community/${post.id}`} className="rounded-card border border-line bg-card p-4 transition-colors hover:border-gold-dark/40">
                    <h3 className="text-[14.5px] font-semibold text-ink">{post.title}</h3>
                    <p className="mt-1 line-clamp-2 text-[12.5px] text-ink-soft">{post.body}</p>
                  </Link>
                ))}
              </div>
            </section>
          )}

          {(tab === "all" || tab === "certificates") && certs.length > 0 && (
            <section>
              <h2 className="mb-4 flex items-center gap-2 text-[16px] font-semibold text-ink">
                <Award size={16} className="text-accent-violet" /> Certificates
              </h2>
              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 xl:grid-cols-3">
                {certs.map((cert) => (
                  <Link key={cert.id} href={`/certificates/${cert.id}`} className="rounded-card border border-line bg-card p-4 transition-colors hover:border-gold-dark/40">
                    <p className="text-[14px] font-semibold text-ink">{cert.courseTitle}</p>
                    <p className="mt-1 text-[12.5px] text-ink-soft">{cert.learnerName} - {cert.verificationId}</p>
                  </Link>
                ))}
              </div>
            </section>
          )}
        </div>
      )}
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