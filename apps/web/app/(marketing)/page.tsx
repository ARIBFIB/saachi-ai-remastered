import Link from "next/link";
import {
  ArrowRight,
  Sparkles,
  Megaphone,
  Workflow,
  MessageSquareText,
  Code2,
  Wand2,
  Star,
  CheckCircle2,
  PlayCircle,
  Users,
  BookOpen,
  Award,
  TrendingUp
} from "lucide-react";
import { Button } from "@saachi/ui";
import { Navbar } from "./_components/Navbar";
import { Footer } from "./_components/Footer";

const CATEGORIES = [
  {
    icon: Sparkles,
    title: "AI Fundamentals & Prompt Engineering",
    desc: "Go from zero to confident â€” prompt engineering basics and everyday AI literacy.",
    featured: true
  },
  {
    icon: Megaphone,
    title: "AI for Marketing & Sales",
    desc: "AI-powered campaigns, ad copy, and lead generation that actually converts."
  },
  {
    icon: Workflow,
    title: "AI Automation & Workflow Tools",
    desc: "n8n, Zapier, Make.com â€” connect AI models into no-code automations."
  },
  {
    icon: MessageSquareText,
    title: "AI Customer Support & Communication",
    desc: "Build WhatsApp auto-responders and AI call-center response systems."
  },
  {
    icon: Code2,
    title: "AI Integration for Developers",
    desc: "Wire OpenAI, Claude, and Gemini APIs into real production apps."
  },
  {
    icon: Wand2,
    title: "AI Design & Creative Tools",
    desc: "Generate graphics, logos, and UI with Midjourney, DALLÂ·E, and Figma AI."
  }
];

const STATS = [
  { value: "12,000+", label: "Learners building with AI" },
  { value: "600+", label: "Practical, outcome-based courses" },
  { value: "4.8/5", label: "Average course rating" },
  { value: "$2.1M+", label: "Paid out to instructors" }
];

const TESTIMONIALS = [
  {
    quote:
      "I packaged the exact automation workflow I use for client work into a course. Three months later it''s paying my rent â€” something YouTube never did.",
    name: "Ayesha Khan",
    role: "Freelance Automation Consultant",
    rating: 5
  },
  {
    quote:
      "Every course here is built to produce something real. I didn''t just watch a WhatsApp bot get built â€” I shipped my own by the end of the week.",
    name: "Bilal Ahmed",
    role: "Learner, AI Customer Support track",
    rating: 5
  },
  {
    quote:
      "The certification actually means something because it''s tied to a real deliverable, not a quiz. Clients recognize that.",
    name: "Sana Rizvi",
    role: "AI Marketing Instructor",
    rating: 5
  }
];

const WHY_CARDS = [
  {
    icon: CheckCircle2,
    title: "Outcome-based, not watch-time",
    desc: "Every course is built around a real, reproducible result â€” not passive viewing."
  },
  {
    icon: Users,
    title: "Learn from practitioners",
    desc: "Instructors are freelancers, agency owners, and developers using AI in real work today."
  },
  {
    icon: Award,
    title: "Certification that verifies skill",
    desc: "Completion requires the actual outcome, with a publicly verifiable certificate ID."
  },
  {
    icon: TrendingUp,
    title: "A path to income, both ways",
    desc: "Learn a skill, then package your own expertise and sell it to the next learner."
  }
];

export default function HomePage() {
  return (
    <main>
      <Navbar />

      {/* ---------- Hero ---------- */}
      <section className="relative overflow-hidden px-6 pb-24 pt-20 md:pb-32 md:pt-28">
        <div
          className="pointer-events-none absolute inset-x-0 top-0 h-[600px]"
          style={{ background: "var(--gradient-glow-light)" }}
        />

        <div className="relative mx-auto flex max-w-[840px] flex-col items-center text-center">
          <div className="glass animate-fade-slide-up inline-flex items-center gap-2 rounded-full px-4 py-2 text-[13px] font-medium text-[var(--text-secondary)]">
            <span className="flex h-2 w-2 rounded-full bg-[var(--cyan-400)]" />
            Now in early access â€” founding instructor spots open
          </div>

          <h1
            className="animate-fade-slide-up mt-6 text-[38px] font-bold leading-[1.12] tracking-[-0.02em] text-[var(--text-primary)] md:text-[64px]"
            style={{ animationDelay: "80ms" }}
          >
            Learn practical <span className="text-gradient">AI skills</span>.
            <br />
            Build real things. Get paid to teach.
          </h1>

          <p
            className="animate-fade-slide-up mt-6 max-w-[620px] text-[17px] leading-[1.6] text-[var(--text-secondary)] md:text-[18px]"
            style={{ animationDelay: "140ms" }}
          >
            Saachi AI is a skills-first marketplace for applied AI â€” practitioners teach the
            exact workflows they use for real work, and learners walk away with something
            they built, not just something they watched.
          </p>

          <div
            className="animate-fade-slide-up mt-8 flex flex-col items-center gap-4 sm:flex-row"
            style={{ animationDelay: "200ms" }}
          >
            <Link href="/register">
              <Button size="lg">
                Get Started Free <ArrowRight size={17} className="ml-1.5" />
              </Button>
            </Link>
            <Link href="/courses">
              <Button size="lg" variant="secondary">
                <PlayCircle size={18} className="mr-1.5" />
                Browse Courses
              </Button>
            </Link>
          </div>

          {/* Product mockup */}
          <div
            className="animate-fade-slide-up relative mt-16 w-full max-w-[1000px]"
            style={{ animationDelay: "260ms" }}
          >
            <div
              className="pointer-events-none absolute inset-x-8 -bottom-6 -top-6 -z-10 rounded-[32px] blur-3xl"
              style={{ background: "var(--gradient-glow-light)" }}
            />
            <div
              className="glass overflow-hidden rounded-[var(--radius-lg)] p-2 shadow-[var(--shadow-xl)]"
              style={{ transform: "rotateX(1.5deg)" }}
            >
              <div className="overflow-hidden rounded-[18px] border border-[var(--border-hairline)] bg-[var(--surface-card)]">
                <div className="flex items-center gap-1.5 border-b border-[var(--border-hairline)] bg-[var(--surface-elevated)] px-4 py-3">
                  <span className="h-2.5 w-2.5 rounded-full bg-[#EF4444]/60" />
                  <span className="h-2.5 w-2.5 rounded-full bg-[#F59E0B]/60" />
                  <span className="h-2.5 w-2.5 rounded-full bg-[#14B8A6]/60" />
                </div>
                <div className="grid grid-cols-1 gap-4 p-6 sm:grid-cols-3">
                  {CATEGORIES.slice(0, 3).map((cat) => (
                    <div
                      key={cat.title}
                      className="rounded-[14px] border border-[var(--border-hairline)] bg-[var(--surface-bg)] p-4 text-left"
                    >
                      <div
                        className="mb-3 flex h-9 w-9 items-center justify-center rounded-[10px]"
                        style={{ background: "rgba(59,130,246,0.12)" }}
                      >
                        <cat.icon size={17} className="text-[var(--blue-600)]" />
                      </div>
                      <p className="text-[13px] font-semibold leading-snug text-[var(--text-primary)]">
                        {cat.title}
                      </p>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>

          {/* Trust strip */}
          <div
            className="animate-fade-slide-up mt-12 flex flex-wrap items-center justify-center gap-x-10 gap-y-4 text-[13px] font-medium uppercase tracking-[0.06em] text-[var(--text-muted)]"
            style={{ animationDelay: "320ms" }}
          >
            <span className="opacity-60 transition-opacity hover:opacity-100">Built for freelancers</span>
            <span className="opacity-60 transition-opacity hover:opacity-100">Trusted by agencies</span>
            <span className="opacity-60 transition-opacity hover:opacity-100">Local payment rails</span>
            <span className="opacity-60 transition-opacity hover:opacity-100">Certified outcomes</span>
          </div>
        </div>
      </section>

      {/* ---------- Why Saachi AI ---------- */}
      <section className="px-6 py-16 md:py-24" style={{ background: "var(--surface-bg-tint)" }}>
        <div className="mx-auto max-w-[1120px]">
          <div className="mx-auto mb-14 max-w-[640px] text-center">
            <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-[var(--blue-600)]">
              Why Saachi AI
            </span>
            <h2 className="mt-3 text-[28px] font-bold leading-[1.2] text-[var(--text-primary)] md:text-[36px]">
              Not a video platform. A skills exchange.
            </h2>
          </div>

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {WHY_CARDS.map((card) => (
              <div
                key={card.title}
                className="group rounded-[var(--radius-md)] border border-[var(--border-hairline)] bg-[var(--surface-card)] p-6 shadow-[var(--shadow-sm)] transition-all duration-200 ease-out hover:-translate-y-1 hover:border-[rgba(59,130,246,0.35)] hover:shadow-[var(--shadow-glow-sm)]"
              >
                <div
                  className="mb-4 flex h-11 w-11 items-center justify-center rounded-[10px]"
                  style={{ background: "rgba(59,130,246,0.12)" }}
                >
                  <card.icon size={19} className="text-[var(--blue-600)]" />
                </div>
                <h3 className="mb-2 text-[16px] font-semibold text-[var(--text-primary)]">{card.title}</h3>
                <p className="text-[14px] leading-relaxed text-[var(--text-secondary)]">{card.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Category grid ---------- */}
      <section className="px-6 py-16 md:py-24">
        <div className="mx-auto max-w-[1120px]">
          <div className="mx-auto mb-14 max-w-[640px] text-center">
            <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-[var(--blue-600)]">
              Explore
            </span>
            <h2 className="mt-3 text-[28px] font-bold leading-[1.2] text-[var(--text-primary)] md:text-[36px]">
              Practical AI, organized by outcome
            </h2>
            <p className="mt-4 text-[16px] leading-relaxed text-[var(--text-secondary)]">
              Ten focused tracks, each built around what you can actually ship afterward.
            </p>
          </div>

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {CATEGORIES.map((cat) => (
              <div
                key={cat.title}
                className={
                  cat.featured
                    ? "border-beam-card p-6"
                    : "rounded-[var(--radius-md)] border border-[var(--border-hairline)] bg-[var(--surface-card)] p-6 shadow-[var(--shadow-sm)] transition-all duration-200 ease-out hover:-translate-y-1 hover:border-[rgba(59,130,246,0.35)] hover:shadow-[var(--shadow-md)]"
                }
                style={cat.featured ? { background: "var(--gradient-card-light)" } : undefined}
              >
                <div
                  className="mb-4 flex h-11 w-11 items-center justify-center rounded-[10px]"
                  style={{ background: "rgba(59,130,246,0.12)" }}
                >
                  <cat.icon size={19} className="text-[var(--blue-600)]" />
                </div>
                <h3 className="mb-2 text-[17px] font-semibold text-[var(--text-primary)]">{cat.title}</h3>
                <p className="mb-4 text-[14px] leading-relaxed text-[var(--text-secondary)]">{cat.desc}</p>
                <Link
                  href="/courses"
                  className="inline-flex items-center gap-1 text-[13px] font-semibold text-[var(--blue-600)] transition-colors hover:text-[var(--blue-700)]"
                >
                  Explore track <ArrowRight size={14} />
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Stat banner ---------- */}
      <section className="px-6 py-16 md:py-24" style={{ background: "var(--gradient-banner)" }}>
        <div className="mx-auto grid max-w-[1120px] grid-cols-2 gap-8 text-center md:grid-cols-4">
          {STATS.map((stat) => (
            <div key={stat.label}>
              <div className="text-gradient text-[32px] font-bold md:text-[44px]">{stat.value}</div>
              <p className="mt-2 text-[13px] text-[rgba(241,245,249,0.72)] md:text-[14px]">{stat.label}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ---------- Testimonials ---------- */}
      <section className="px-6 py-16 md:py-24" style={{ background: "var(--surface-bg-tint)" }}>
        <div className="mx-auto max-w-[1120px]">
          <div className="mx-auto mb-14 max-w-[640px] text-center">
            <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-[var(--blue-600)]">
              Real outcomes
            </span>
            <h2 className="mt-3 text-[28px] font-bold leading-[1.2] text-[var(--text-primary)] md:text-[36px]">
              Learners and instructors, in their own words
            </h2>
          </div>

          <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
            {TESTIMONIALS.map((t) => (
              <div
                key={t.name}
                className="relative overflow-hidden rounded-[var(--radius-lg)] border border-[var(--border-hairline)] bg-[var(--surface-card)] p-6 shadow-[var(--shadow-sm)]"
              >
                <span
                  aria-hidden
                  className="pointer-events-none absolute -left-1 -top-4 select-none text-[80px] font-bold leading-none text-[var(--blue-100)]"
                >
                  &ldquo;
                </span>
                <div className="relative mb-4 flex items-center gap-1">
                  {Array.from({ length: t.rating }).map((_, i) => (
                    <Star key={i} size={14} className="fill-[var(--blue-500)] text-[var(--blue-500)]" />
                  ))}
                </div>
                <p className="relative mb-6 text-[15px] leading-relaxed text-[var(--text-primary)]">
                  {t.quote}
                </p>
                <div className="relative flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center rounded-full bg-[var(--blue-50)] text-[14px] font-semibold text-[var(--blue-600)]">
                    {t.name.charAt(0)}
                  </div>
                  <div>
                    <div className="text-[13px] font-semibold text-[var(--text-primary)]">{t.name}</div>
                    <div className="text-[12px] text-[var(--text-muted)]">{t.role}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Become an instructor CTA ---------- */}
      <section className="px-6 py-16 md:py-24">
        <div className="mx-auto max-w-[1120px]">
          <div
            className="flex flex-col items-center gap-6 rounded-[var(--radius-lg)] px-8 py-16 text-center shadow-[var(--shadow-xl)] md:px-16"
            style={{ background: "var(--gradient-banner)" }}
          >
            <div className="glass inline-flex items-center gap-2 rounded-full px-4 py-2 text-[13px] font-medium text-white">
              <BookOpen size={14} />
              For practitioners
            </div>
            <h2 className="max-w-[640px] text-[28px] font-bold leading-[1.2] text-white md:text-[40px]">
              Have practical AI skills? Turn them into income.
            </h2>
            <p className="max-w-[560px] text-[16px] leading-relaxed text-[rgba(241,245,249,0.78)]">
              Package the exact workflow you already use for real work into a course, and
              start earning from learners who want to build it too.
            </p>
            <Link href="/register">
              <Button size="lg" className="mt-2">
                Become an Instructor <ArrowRight size={17} className="ml-1.5" />
              </Button>
            </Link>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}
