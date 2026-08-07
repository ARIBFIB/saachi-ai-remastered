import Link from "next/link";
import { Target, Users, Sparkles, ArrowRight } from "lucide-react";
import { Button } from "@saachi/ui";
import { Navbar } from "../_components/Navbar";
import { Footer } from "../_components/Footer";

const VALUES = [
  {
    icon: Target,
    title: "Outcome over watch-time",
    desc: "Every course exists to produce something real - not to maximize minutes viewed."
  },
  {
    icon: Users,
    title: "Practitioners, not presenters",
    desc: "Our instructors use the exact skills they teach in their own client and business work."
  },
  {
    icon: Sparkles,
    title: "Practical AI, not hype",
    desc: "We're intentionally narrow: applied AI skills you can use at work this week."
  }
];

export default function AboutPage() {
  return (
    <>
      <Navbar />
      <main>
        <section className="px-6 py-20 md:py-28">
          <div className="mx-auto max-w-[760px] text-center">
            <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
              About Saachi AI
            </span>
            <h1 className="mt-4 font-display text-[32px] font-semibold leading-[1.2] text-ink md:text-[44px]">
              A skills exchange for the AI era
            </h1>
            <p className="mt-6 text-[17px] leading-relaxed text-ink-soft">
              Saachi AI exists to close the gap between knowing that AI tools exist and knowing
              how to actually use them to produce real, sellable outcomes - websites, apps,
              automations, marketing campaigns, content pipelines, customer support systems, and
              more. We connect people who've figured this out with people who want to learn it,
              inside a safe, paid, structured environment.
            </p>
          </div>
        </section>

        <section className="bg-paper-dim px-6 py-16 md:py-24">
          <div className="mx-auto max-w-[1140px]">
            <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
              {VALUES.map((v) => (
                <div key={v.title} className="rounded-card border border-line bg-card p-6">
                  <div className="mb-4 flex h-11 w-11 items-center justify-center rounded-control bg-teal-light">
                    <v.icon size={19} className="text-teal" />
                  </div>
                  <h3 className="mb-2 text-[16px] font-semibold text-ink">{v.title}</h3>
                  <p className="text-[14px] leading-relaxed text-ink-soft">{v.desc}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <section className="px-6 py-16 md:py-24">
          <div className="mx-auto max-w-[1140px] text-center">
            <h2 className="font-display text-[26px] font-semibold text-ink md:text-[32px]">
              Have a practical AI skill worth teaching?
            </h2>
            <Link href="/register" className="mt-6 inline-block">
              <Button size="lg">
                Become an Instructor <ArrowRight size={17} />
              </Button>
            </Link>
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}