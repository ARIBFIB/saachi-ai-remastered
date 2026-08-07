import Link from "next/link";
import {
  ArrowRight,
  Megaphone,
  Workflow,
  MessageSquareText,
  Code2,
  Wand2,
  Sparkles,
  Star,
  CheckCircle2,
  PlayCircle,
  Users,
  BookOpen,
  Award,
  TrendingUp,
  BadgeCheck
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
      "I packaged the exact automation workflow I use for client work into a course. Three months later it's paying my rent â€” something YouTube never did.",
    name: "Ayesha Khan",
    role: "Freelance Automation Consultant"
  },
  {
    quote:
      "Every course here is built to produce something real. I didn't just watch a WhatsApp bot get built â€” I shipped my own by the end of the week.",
    name: "Bilal Ahmed",
    role: "Learner, AI Customer Support track"
  },
  {
    quote:
      "The certification actually means something because it's tied to a real deliverable, not a quiz. Clients recognize that.",
    name: "Sana Rizvi",
    role: "AI Marketing Instructor"
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
        <div className="relative mx-auto flex max-w-[880px] flex-col items-center text-center">
          <div className="inline-flex items-center gap-2 rounded-full border border-line px-4 py-2 text-[13px] font-medium text-ink-soft">
            <span className="flex h-2 w-2 rounded-full bg-gold" />
            Now in early access â€” founding instructor spots open
          </div>

          <h1 className="mt-8 font-display text-[40px] font-semibold leading-[1.1] tracking-[-0.02em] text-ink md:text-[68px]">
            Learn practical AI skills.
            <br />
            Build real things. <span className="italic text-gold-dark">Get paid</span> to teach.
          </h1>

          <p className="mt-6 max-w-[620px] text-[17px] leading-[1.6] text-ink-soft md:text-[18px]">
            Saachi AI is a skills-first marketplace for applied AI â€” practitioners teach the
            exact workflows they use for real work, and learners walk away with something
            they built, not just something they watched.
          </p>

          <div className="mt-8 flex flex-col items-center gap-4 sm:flex-row">
            <Link href="/register">
              <Button size="lg">
                Get Started Free <ArrowRight size={17} />
              </Button>
            </Link>
            <Link href="/courses">
              <Button size="lg" variant="secondary">
                <PlayCircle size={18} /> Browse Courses
              </Button>
            </Link>
          </div>

          {/* Signature seal + product mockup */}
          <div className="relative mt-16 w-full max-w-[1000px]">
            <div className="absolute -top-8 right-6 z-10 hidden h-24 w-24 rotate-6 items-center justify-center rounded-full border-2 border-dashed border-gold-dark bg-paper text-center md:flex">
              <div className="flex flex-col items-center gap-0.5">
                <BadgeCheck size={20} className="text-teal" />
                <span className="font-display text-[10px] font-semibold uppercase leading-tight tracking-[0.08em] text-ink">
                  Verified
                  <br />
                  skill
                </span>
              </div>
            </div>
            <div className="overflow-hidden rounded-card border border-line bg-card">
              <div className="flex items-center gap-1.5 border-b border-line bg-paper-dim px-4 py-3">
                <span className="h-2.5 w-2.5 rounded-full bg-error/50" />
                <span className="h-2.5 w-2.5 rounded-full bg-gold/60" />
                <span className="h-2.5 w-2.5 rounded-full bg-teal/50" />
              </div>
              <div className="grid grid-cols-1 gap-4 p-6 sm:grid-cols-3">
                {CATEGORIES.slice(0, 3).map((cat) => (
                  <div key={cat.title} className="rounded-control border border-line bg-paper p-4 text-left">
                    <div className="mb-3 flex h-9 w-9 items-center justify-center rounded-control bg-gold-tint">
                      <cat.icon size={17} className="text-gold-dark" />
                    </div>
                    <p className="text-[13px] font-semibold leading-snug text-ink">{cat.title}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="mt-12 flex flex-wrap items-center justify-center gap-x-10 gap-y-4 text-[13px] font-medium uppercase tracking-[0.06em] text-ink-soft">
            <span className="opacity-60 transition-opacity hover:opacity-100">Built for freelancers</span>
            <span className="opacity-60 transition-opacity hover:opacity-100">Trusted by agencies</span>
            <span className="opacity-60 transition-opacity hover:opacity-100">Local payment rails</span>
            <span className="opacity-60 transition-opacity hover:opacity-100">Certified outcomes</span>
          </div>
        </div>
      </section>

      {/* ---------- Why Saachi AI ---------- */}
      <section className="bg-paper-dim px-6 py-16 md:py-24">
        <div className="mx-auto max-w-[1140px]">
          <div className="mx-auto mb-14 max-w-[640px] text-center">
            <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
              Why Saachi AI
            </span>
            <h2 className="mt-3 font-display text-[28px] font-semibold leading-[1.2] text-ink md:text-[36px]">
              Not a video platform. A skills exchange.
            </h2>
          </div>

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {WHY_CARDS.map((card) => (
              <div
                key={card.title}
                className="rounded-card border border-line bg-card p-6 transition-all duration-200 ease-out hover:-translate-y-1 hover:border-gold-dark/40"
              >
                <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-control bg-teal-light">
                  <card.icon size={19} className="text-teal" />
                </div>
                <h3 className="mb-2 text-[16px] font-semibold text-ink">{card.title}</h3>
                <p className="text-[14px] leading-relaxed text-ink-soft">{card.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Category grid ---------- */}
      <section className="px-6 py-16 md:py-24">
        <div className="mx-auto max-w-[1140px]">
          <div className="mx-auto mb-14 max-w-[640px] text-center">
            <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
              Explore
            </span>
            <h2 className="mt-3 font-display text-[28px] font-semibold leading-[1.2] text-ink md:text-[36px]">
              Practical AI, organized by outcome
            </h2>
            <p className="mt-4 text-[16px] leading-relaxed text-ink-soft">
              Ten focused tracks, each built around what you can actually ship afterward.
            </p>
          </div>

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {CATEGORIES.map((cat) => (
              <div
                key={cat.title}
                className={
                  cat.featured
                    ? "rounded-card border-2 border-ink bg-gold-tint p-6"
                    : "rounded-card border border-line bg-card p-6 transition-all duration-200 ease-out hover:-translate-y-1 hover:border-gold-dark/40"
                }
              >
                <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-control bg-ink/5">
                  <cat.icon size={19} className="text-ink" />
                </div>
                <h3 className="mb-2 text-[17px] font-semibold text-ink">{cat.title}</h3>
                <p className="mb-4 text-[14px] leading-relaxed text-ink-soft">{cat.desc}</p>
                <Link
                  href="/courses"
                  className="inline-flex items-center gap-1 text-[13px] font-semibold text-gold-dark transition-colors hover:text-ink"
                >
                  Explore track <ArrowRight size={14} />
                </Link>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Stat banner ---------- */}
      <section className="bg-ink px-6 py-16 md:py-24">
        <div className="mx-auto grid max-w-[1140px] grid-cols-2 gap-8 text-center md:grid-cols-4">
          {STATS.map((stat) => (
            <div key={stat.label}>
              <div className="font-mono text-[30px] font-semibold text-gold md:text-[40px]">{stat.value}</div>
              <p className="mt-2 text-[13px] text-white/60 md:text-[14px]">{stat.label}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ---------- Testimonials ---------- */}
      <section className="px-6 py-16 md:py-24">
        <div className="mx-auto max-w-[1140px]">
          <div className="mx-auto mb-14 max-w-[640px] text-center">
            <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
              Real outcomes
            </span>
            <h2 className="mt-3 font-display text-[28px] font-semibold leading-[1.2] text-ink md:text-[36px]">
              Learners and instructors, in their own words
            </h2>
          </div>

          <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
            {TESTIMONIALS.map((t) => (
              <div key={t.name} className="rounded-card border border-line bg-card p-6">
                <div className="mb-4 flex items-center gap-1">
                  {Array.from({ length: 5 }).map((_, i) => (
                    <Star key={i} size={14} className="fill-gold text-gold" />
                  ))}
                </div>
                <p className="mb-6 text-[15px] leading-relaxed text-ink">{t.quote}</p>
                <div className="flex items-center gap-3">
                  <div className="flex h-10 w-10 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[14px] font-semibold text-teal">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={`https://picsum.photos/seed/${encodeURIComponent(t.name)}/100/100`}
                      alt={t.name}
                      className="h-full w-full object-cover"
                    />
                  </div>
                  <div>
                    <div className="text-[13px] font-semibold text-ink">{t.name}</div>
                    <div className="text-[12px] text-ink-soft">{t.role}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ---------- Become an instructor CTA ---------- */}
      <section className="px-6 py-16 md:py-24">
        <div className="mx-auto max-w-[1140px]">
          <div className="flex flex-col items-center gap-6 rounded-card border-2 border-ink bg-gold px-8 py-16 text-center md:px-16">
            <div className="inline-flex items-center gap-2 rounded-full border border-ink/20 bg-paper px-4 py-2 text-[13px] font-medium text-ink">
              <BookOpen size={14} />
              For practitioners
            </div>
            <h2 className="max-w-[640px] font-display text-[28px] font-semibold leading-[1.2] text-ink md:text-[40px]">
              Have practical AI skills? Turn them into income.
            </h2>
            <p className="max-w-[560px] text-[16px] leading-relaxed text-ink/80">
              Package the exact workflow you already use for real work into a course, and
              start earning from learners who want to build it too.
            </p>
            <Link href="/register">
              <Button size="lg" variant="secondary" className="mt-2 border-ink bg-ink text-white hover:bg-ink-soft">
                Become an Instructor <ArrowRight size={17} />
              </Button>
            </Link>
          </div>
        </div>
      </section>

      <Footer />
    </main>
  );
}