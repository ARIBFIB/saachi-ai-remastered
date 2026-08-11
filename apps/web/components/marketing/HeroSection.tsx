import Link from "next/link";
import { Sparkles } from "lucide-react";
import Image from "next/image";

export function HeroSection() {
  return (
    <section className="w-full border-b border-[var(--token-color-border)] bg-[var(--token-color-surface)]">
      <div className="mx-auto flex min-h-[640px] max-w-[1280px] items-center justify-center gap-10 px-6 py-12">
        {/* Left: copy */}
        <div className="relative h-96 flex-1">
          <div className="inline-flex items-center gap-1 rounded-sm bg-[var(--token-color-primaryTint)] px-2 py-1">
            <Sparkles className="h-3.5 w-3.5 text-gray-500" />
            <span className="text-xs font-medium text-gray-500">
              New: Advanced Generative Models Path
            </span>
          </div>

          <h1 className="mt-6 w-[596px] max-w-full text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
            Master AI,
            <br />
            Master the Future
          </h1>

          <p className="mt-6 max-w-96 text-lg leading-7 text-[var(--token-color-inkSoft)]">
            The world&apos;s leading AI-skills marketplace. Join thousands of
            professionals accelerating their careers with cutting-edge,
            expert-led artificial intelligence courses.
          </p>

          <div className="mt-8 flex items-center gap-4">
            <Link
              href="/courses"
              className="rounded-lg bg-[var(--token-color-primary)] px-10 py-4 text-sm font-semibold tracking-wide text-white shadow-[var(--token-shadow-sm)] hover:bg-[var(--token-color-primaryHover)]"
            >
              Explore Courses
            </Link>
            <Link
              href="/pricing"
              className="rounded-lg border border-[var(--token-color-border)] bg-[var(--token-color-bg)] px-10 py-4 text-sm font-semibold tracking-wide text-slate-600 hover:bg-gray-100"
            >
              For Enterprise
            </Link>
          </div>
        </div>

        {/* Right: image */}
        <div className="relative min-h-96 flex-1 self-stretch overflow-hidden rounded-xl shadow-[var(--token-shadow-lg)]">
          <Image
            src="https://placehold.co/596x544"
            alt="AI Learning Concept"
            fill
            className="object-cover"
            priority
          />
          <div className="absolute inset-0 mix-blend-overlay bg-gradient-to-br from-[var(--token-color-primary)]/10 to-transparent" />
        </div>
      </div>
    </section>
  );
}
