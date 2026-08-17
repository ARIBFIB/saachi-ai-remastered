"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useCourseList } from "@saachi/api-client";
import { Button, CourseCard, Loading } from "@saachi/ui";
import { TopSearchBar } from "../_components/TopSearchBar";
import {
  ArrowRight,
  Sparkles,
  Users,
  BookOpen,
  Award,
  Star,
  ShieldCheck,
  Zap,
  TrendingUp,
  PlayCircle,
  BadgeCheck
} from "lucide-react";
import { CATEGORIES } from "../../lib/categories";
import { Reveal } from "./_components/Reveal";
import { FaqAccordion } from "./_components/FaqAccordion";
import { TrendingCarousel } from "./_components/TrendingCarousel";
import { SpotlightPanels } from "./_components/SpotlightPanels";
import { LogoCloud } from "./_components/LogoCloud";
import { BlogPreview } from "./_components/BlogPreview";
import { PricingTeaser } from "./_components/PricingTeaser";
import NewsletterBlock from "@/components/ui/newsletter-2";

import { CoverflowCarousel } from "@/components/ui/coverflow-carousel";
import { HeroMediaCollage } from "@/components/ui/hero-media-collage";
import { HeroCursorTrail } from "@/components/ui/hero-cursor-trail";
import { GalleryCursorTrail } from "@/components/ui/gallery-cursor-trail";
import { ImageStreamHero } from "@/components/ui/image-stream-hero";
import HowItWorks from "@/components/ui/how-it-works";
import { LimitedTimeOfferPricing } from "@/components/ui/limited-time-offer-pricing";
import { AnimatedTestimonials } from "@/components/ui/animated-testimonials";
import { GlobalVisitorsPanel } from "@/components/ui/global-visitors-panel";
import GlassCta from "@/components/ui/glass-cta";

const STATS = [
  { label: "Active students", value: "42,000+", icon: Users },
  { label: "Courses live", value: "1,280+", icon: BookOpen },
  { label: "Instructor payouts", value: "$2.1M+", icon: TrendingUp },
  { label: "Avg. rating", value: "4.8 / 5", icon: Star }
];

const TRUST_BADGES = [
  "Featured on ProductHunt", "AI Weekly Pick", "TechCrunch Mentioned",
  "500+ 5-star reviews", "SSL Secured Checkout", "7-Day Refunds",
  "42,000+ learners", "1,280+ live courses"
];

const INSTRUCTORS = [
  { name: "Ayesha Khan", role: "Automation & n8n", students: "6.2k", avatar: "https://i.pravatar.cc/96?img=47" },
  { name: "Hamza Malik", role: "AI Integration", students: "4.8k", avatar: "https://i.pravatar.cc/96?img=12" },
  { name: "Sara Iqbal", role: "AI Marketing", students: "3.1k", avatar: "https://i.pravatar.cc/96?img=32" },
  { name: "Omar Sheikh", role: "AI Development", students: "5.5k", avatar: "https://i.pravatar.cc/96?img=15" },
  { name: "Noor Fatima", role: "AI Design", students: "2.7k", avatar: "https://i.pravatar.cc/96?img=44" },
  { name: "Bilal S.", role: "Career & Freelancing", students: "1.9k", avatar: "https://i.pravatar.cc/96?img=8" }
];


const HOW_IT_WORKS = [
  { title: "Pick a skill", desc: "Browse 1,200+ practical AI courses across automation, marketing, design, and development.", icon: Sparkles },
  { title: "Learn by building", desc: "Every course ships real projects and templates, not just watch-and-forget video.", icon: PlayCircle },
  { title: "Get certified & earn", desc: "Finish, get certified, and turn what you learned into freelance work -- or teach it yourself.", icon: Award }
];

export default function HomePage() {
  const { data: featured, isLoading } = useCourseList({ sort: "popular", page: 1 });
  const [heroLoaded, setHeroLoaded] = useState(false);

  useEffect(() => {
    const t = setTimeout(() => setHeroLoaded(true), 700);
    return () => clearTimeout(t);
  }, []);

  return (
    <div className="overflow-hidden">
      {/* Hero */}
      <section className="relative mx-auto max-w-7xl px-4 pb-14 pt-16 md:px-8 md:pt-24">
        <div
          className="pointer-events-none absolute -left-32 -top-32 h-96 w-96 rounded-full opacity-30 blur-3xl"
          style={{ backgroundImage: "var(--color-accent-gradient)" }}
        />
        <div className="relative max-w-2xl">

          {heroLoaded ? (
            <>
              <h1 className="font-display text-[38px] font-bold leading-[1.05] text-ink md:text-[64px]">
                Learn AI Skills.
                <br />
                <span className="text-gradient-brand">Build Real Projects.</span>
              </h1>
              <p className="mt-5 text-[16px] leading-relaxed text-ink-soft md:text-[18px]">
                Not another watch-time platform. Saachi AI is a skills exchange for the AI era -
                structured, practical, and paid.
              </p>
            </>
          ) : (
            <div className="flex flex-col gap-3">
              <div className="h-[38px] w-[92%] animate-pulse rounded-lg bg-paper-dim md:h-[64px]" />
              <div className="h-[38px] w-[70%] animate-pulse rounded-lg bg-paper-dim md:h-[64px]" />
              <div className="mt-3 h-4 w-full animate-pulse rounded bg-paper-dim" />
              <div className="h-4 w-[85%] animate-pulse rounded bg-paper-dim" />
            </div>
          )}
          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/courses" className="group">
              <button
                type="button"
                className="inline-flex h-[52px] items-center gap-2 rounded-full px-7 text-[16px] font-semibold text-white shadow-[0_0_40px_-12px_rgba(124,58,237,0.5)] transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-[0_0_50px_-8px_rgba(124,58,237,0.65)] active:translate-y-0"
                style={{ backgroundImage: "var(--color-accent-gradient)" }}
              >
                Browse courses
                <ArrowRight size={16} className="transition-transform duration-200 ease-out group-hover:translate-x-1" />
              </button>
            </Link>
            <Link href="/register" className="group">
              <button
                type="button"
                className="inline-flex h-[52px] items-center gap-2 rounded-full border border-line-strong bg-card px-7 text-[16px] font-semibold text-ink transition-all duration-200 ease-out hover:-translate-y-0.5 hover:border-accent-violet/50 hover:bg-paper-dim active:translate-y-0"
              >
                Become an instructor
                <ArrowRight size={16} className="transition-transform duration-200 ease-out group-hover:translate-x-1" />
              </button>
            </Link>
          </div>

          <div className="relative z-10 mt-8 max-w-xl">
            <TopSearchBar />
          </div>




        </div>

        <div className="pointer-events-auto absolute right-0 top-1/2 z-10 hidden -translate-y-1/2 lg:block xl:right-4">
          <GalleryCursorTrail />
        </div>

        <HeroCursorTrail />
      </section>

      {/* Trust badges marquee */}
      <section className="border-y border-line bg-paper-dim py-4">
        <div className="marquee-track">
          {[...TRUST_BADGES, ...TRUST_BADGES].map((badge, i) => (
            <span
              key={`${badge}-${i}`}
              className="mx-4 flex shrink-0 items-center gap-2 text-[13px] font-medium text-ink-soft"
            >
              <BadgeCheck size={14} className="text-accent-violet" />
              {badge}
            </span>
          ))}
        </div>
      </section>

      {/* Stats */}
      <section className="mx-auto max-w-7xl px-4 py-16 md:px-8">
        <Reveal>
          <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
            {STATS.map((s) => (
              <div key={s.label} className="rounded-card border border-line bg-card p-5 text-center">
                <s.icon size={20} className="mx-auto mb-2 text-accent-violet" />
                <p className="font-display text-[24px] font-bold text-ink">{s.value}</p>
                <p className="mt-1 text-[12.5px] text-ink-soft">{s.label}</p>
              </div>
            ))}
          </div>
        </Reveal>
      </section>

      {/* Logo cloud */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <LogoCloud />
        </Reveal>
      </section>

      {/* Live global visitors */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Live on Saachi AI right now</h2>
          <p className="mb-8 text-[14px] text-ink-soft">A real-time snapshot of learners around the world.</p>
        </Reveal>
        <Reveal delay={80}>
          <GlobalVisitorsPanel />
        </Reveal>
      </section>

      {/* Category grid */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-5 font-display text-[22px] font-semibold text-ink">Browse by category</h2>
        </Reveal>
        <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
          {CATEGORIES.map((cat, i) => (
            <Reveal key={cat.id} delay={i * 40}>
              <Link
                href={`/categories/${cat.slug}`}
                className="group flex h-full flex-col justify-between rounded-card border border-line bg-card p-4 text-[14px] font-medium text-ink transition-all hover:-translate-y-1 hover:border-accent-violet/50 hover:shadow-md"
              >
                <span>{cat.name}</span>
                <span className="mt-3 text-[11px] font-semibold text-ink-soft group-hover:text-accent-violet">
                  Explore &rarr;
                </span>
              </Link>
            </Reveal>
          ))}
        </div>
      </section>

      {/* Trending carousel */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <TrendingCarousel />
        </Reveal>
      </section>

      {/* Spotlight panels (Border Beam) */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Ways to level up</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Pick the path that fits how you learn best.</p>
        </Reveal>
        <Reveal delay={80}>
          <SpotlightPanels />
        </Reveal>
      </section>

      {/* How it works */}
      <Reveal>
        <HowItWorks />
      </Reveal>

      {/* Featured courses */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <div className="mb-5 flex items-center justify-between">
            <h2 className="font-display text-[22px] font-semibold text-ink">Featured courses</h2>
            <Link href="/courses" className="text-[14px] font-medium text-accent-violet hover:underline">
              View all
            </Link>
          </div>
        </Reveal>

        {isLoading ? (
          <Loading label="Loading courses..." />
        ) : (
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
            {featured?.items.map((course, i) => (
              <Reveal key={course.id} delay={i * 60}>
                <CourseCard
                  slug={course.slug}
                  title={course.title}
                  thumbnailUrl={course.thumbnailUrl}
                  instructorName={course.instructor.fullName}
                  price={course.price}
                  currency={course.currency}
                  rating={course.rating}
                  ratingCount={course.ratingCount}
                />
              </Reveal>
            ))}
          </div>
        )}
      </section>

      {/* Pricing teaser */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Simple, transparent pricing</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Buy individual courses, or go unlimited with Pro.</p>
        </Reveal>
        <Reveal delay={80}>
          <PricingTeaser />
        </Reveal>
      </section>

      {/* Limited-time offer */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal delay={100}>
          <LimitedTimeOfferPricing />
        </Reveal>
      </section>

      {/* Popular instructors -- coverflow */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Learn from top instructors</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Verified practitioners, not just presenters. Drag to browse.</p>
        </Reveal>
        <Reveal delay={100}>
          <CoverflowCarousel
            showCaption
            showNavigation
            label="Top instructors"
            slides={INSTRUCTORS.map((inst) => ({
              src: inst.avatar,
              alt: inst.name,
              title: inst.name,
              subtitle: inst.role,
              meta: [{ label: "Students", value: inst.students }]
            }))}
          />
        </Reveal>
      </section>
      {/* Testimonials - AnimatedTestimonials */}
      <AnimatedTestimonials
        title="What learners are saying"
        subtitle="4.8 average rating across 12,000+ reviews. Real results from real people."
        badgeText="Verified reviews"
        autoRotateInterval={6000}
        testimonials={[
          {
            id: 1,
            name: "Fatima R.",
            role: "Freelance automation consultant",
            company: "Independent",
            content: "I landed 3 client projects within a month of finishing the n8n automation course. The invoice-parsing workflow alone paid for the course ten times over.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=5",
          },
          {
            id: 2,
            name: "Ali Raza",
            role: "Support team lead",
            company: "Local Retail Co.",
            content: "Our WhatsApp response time dropped by 70% after building the chatbot from the course. Practical, no fluff, straight to the point.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=22",
          },
          {
            id: 3,
            name: "Hina Malik",
            role: "Marketing manager",
            company: "Agency Partner",
            content: "Best structured AI marketing content I have found anywhere. Wish there were a couple more advanced modules, but genuinely worth it.",
            rating: 4,
            avatar: "https://i.pravatar.cc/150?img=25",
          },
          {
            id: 4,
            name: "Omar Sheikh",
            role: "Indie developer",
            company: "Self-employed",
            content: "Went from zero to shipping my own AI agent product in six weeks. The instructor actually answers Q&A - that made all the difference.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=15",
          },
          {
            id: 5,
            name: "Zara Ahmed",
            role: "Product designer",
            company: "Independent",
            content: "The design systems course completely changed how I hand off files to developers. Immediate ROI.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=48",
          },
          {
            id: 6,
            name: "Usman Tariq",
            role: "Agency owner",
            company: "Growth Agency",
            content: "We onboarded our whole team through Saachi AI Business. Certificates and dashboards made tracking easy.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=13",
          },
          {
            id: 7,
            name: "Mahnoor Khalid",
            role: "Content strategist",
            company: "Freelance",
            content: "Solid course library, wish there was more advanced copywriting content, but great value overall.",
            rating: 4,
            avatar: "https://i.pravatar.cc/150?img=45",
          },
          {
            id: 8,
            name: "Danish Iqbal",
            role: "Automation freelancer",
            company: "Freelance",
            content: "Booked a mentorship call the same week I finished the course. Instructor feedback was gold.",
            rating: 5,
            avatar: "https://i.pravatar.cc/150?img=33",
          },
        ]}
        trustedCompanies={["NovaWorks", "BrightStack", "Vertex Labs", "Cirrus Digital", "Ember Systems", "Northline Tech"]}
        trustedCompaniesTitle="Learners from companies worldwide"
      />

      {/* Course spotlight stream */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <ImageStreamHero
            className="h-[420px] w-full rounded-card border border-line bg-paper-dim"
            images={[
              { src: "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=480&fit=crop&q=70&auto=format", alt: "AI automation workspace" },
              { src: "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=480&fit=crop&q=70&auto=format", alt: "Developer working with AI tools" },
              { src: "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=480&fit=crop&q=70&auto=format", alt: "Analytics dashboard" },
              { src: "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=480&h=480&fit=crop&q=70&auto=format", alt: "Team collaborating" },
              { src: "https://images.unsplash.com/photo-1550439062-609e1531270e?w=480&h=480&fit=crop&q=70&auto=format", alt: "Whiteboard planning session" },
              { src: "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=480&h=480&fit=crop&q=70&auto=format", alt: "Remote work setup" }
            ]}
          >
            <div className="relative z-10 flex h-full flex-col items-center justify-between py-10 text-center">
              <div className="px-6">
                <h2 className="text-balance font-display text-[28px] font-bold text-ink md:text-[36px]">
                  Every course, built around real work.
                </h2>
              </div>
              <p className="max-w-md text-balance px-6 text-[13.5px] text-ink-soft">
                Screenshots, templates, and workflows straight from working AI practitioners -- not stock slides.
              </p>
            </div>
          </ImageStreamHero>
        </Reveal>
      </section>

      {/* Blog / resources */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <div className="mb-5 flex items-center justify-between">
            <h2 className="font-display text-[22px] font-semibold text-ink">From the blog</h2>
            <Link href="/about" className="text-[14px] font-medium text-accent-violet hover:underline">
              View all
            </Link>
          </div>
        </Reveal>
        <Reveal delay={80}>
          <BlogPreview />
        </Reveal>
      </section>

      {/* FAQ */}
      <section className="mx-auto max-w-4xl px-4 pb-16 md:px-8">
        <Reveal>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">Frequently asked questions</h2>
          <p className="mb-8 text-[14px] text-ink-soft">Everything you need to know before you start.</p>
        </Reveal>
        <Reveal delay={100}>
          <FaqAccordion />
        </Reveal>
      </section>

      {/* Newsletter */}
      <section className="mx-auto max-w-7xl px-4 pb-16 md:px-8">
        <Reveal>
          <NewsletterBlock />
        </Reveal>
      </section>

      {/* Final CTA */}
      <section className="mx-auto max-w-7xl px-4 pb-24 md:px-8">
        <Reveal>
          <GlassCta />
        </Reveal>
      </section>
    </div>
  );
}
