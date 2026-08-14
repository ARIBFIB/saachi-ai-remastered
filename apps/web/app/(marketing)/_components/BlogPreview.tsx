import Link from "next/link";
import { ArrowUpRight } from "lucide-react";
import { BLOG_POSTS } from "./landing-fake-data";

export function BlogPreview() {
  return (
    <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
      {BLOG_POSTS.map((post) => (
        <Link
          key={post.id}
          href="/about"
          className="group overflow-hidden rounded-card border border-line bg-card transition-all hover:-translate-y-1 hover:shadow-lg"
        >
          <div className="aspect-video w-full overflow-hidden">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src={post.image} alt={post.title} className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105" />
          </div>
          <div className="p-5">
            <div className="mb-2 flex items-center justify-between">
              <span className="rounded-full bg-gold-tint px-2.5 py-0.5 text-[10.5px] font-semibold text-gold-dark">{post.tag}</span>
              <span className="text-[11.5px] text-ink-soft">{post.readTime}</span>
            </div>
            <h3 className="line-clamp-2 text-[15px] font-semibold leading-snug text-ink">{post.title}</h3>
            <span className="mt-3 flex items-center gap-1 text-[12.5px] font-medium text-accent-violet">
              Read more
              <ArrowUpRight size={13} className="transition-transform group-hover:translate-x-0.5 group-hover:-translate-y-0.5" />
            </span>
          </div>
        </Link>
      ))}
    </div>
  );
}