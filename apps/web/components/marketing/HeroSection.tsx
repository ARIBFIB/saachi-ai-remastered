import Link from "next/link";
import { Sparkles } from "lucide-react";
import Image from "next/image";

export function HeroSection() {
  return (
    <section className="w-full border-b border-[#CBD5E1] bg-[#FFFFFF]">
      <div className="mx-auto flex min-h-[640px] max-w-[1280px] items-center justify-center gap-10 px-6 py-12">
        {/* Left: copy */}
        <div className="relative h-96 flex-1">
          <div className="inline-flex items-center gap-1 rounded-sm bg-[#E0E7FF] px-2 py-1">
            <Sparkles className="h-3.5 w-3.5 text-gray-500" />
            <span className="text-xs font-medium text-gray-500">
              New: Advanced Generative Models Path
            </span>
          </div>

          <h1 className="mt-6 w-[596px] max-w-full text-5xl font-bold leading-[52.8px] text-[#18181B]">
            Master AI,
            <br />
            Master the Future
          </h1>

          <p className="mt-6 max-w-96 text-lg leading-7 text-[#3F3F46]">
            The world&apos;s leading AI-skills marketplace. Join thousands of
            professionals accelerating their careers with cutting-edge,
            expert-led artificial intelligence courses.
          </p>

          <div className="mt-8 flex items-center gap-4">
            <Link
              href="/courses"
              className="rounded-lg bg-[#3525CD] px-10 py-4 text-sm font-semibold tracking-wide text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[#2A1DA3]"
            >
              Explore Courses
            </Link>
            <Link
              href="/pricing"
              className="rounded-lg border border-[#CBD5E1] bg-[#F8FAFC] px-10 py-4 text-sm font-semibold tracking-wide text-slate-600 hover:bg-gray-100"
            >
              For Enterprise
            </Link>
          </div>
        </div>

        {/* Right: image */}
        <div className="relative min-h-96 flex-1 self-stretch overflow-hidden rounded-xl shadow-[0px_10px_32px_0px_rgba(15,23,42,0.12)]">
          <Image
            src="https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=1200&q=80"
            alt="AI Learning Concept"
            fill
            sizes="(max-width: 768px) 100vw, 596px"
            className="object-cover"
            priority
          />
          <div className="absolute inset-0 mix-blend-overlay bg-gradient-to-br from-[#3525CD]/10 to-transparent" />
        </div>
      </div>
    </section>
  );
}
