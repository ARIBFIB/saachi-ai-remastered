import Link from "next/link";
import { Check } from "lucide-react";
import { Button, Card, Accordion } from "@saachi/ui";
import { Navbar } from "../_components/Navbar";
import { Footer } from "../_components/Footer";

const PLANS = [
  {
    name: "Basic",
    price: "Free",
    desc: "Browse and buy individual courses.",
    features: ["Buy courses individually", "Lifetime access to purchased courses", "Community Q&A access", "Certificate on completion"],
    cta: "Get started",
    featured: false
  },
  {
    name: "Pro",
    price: "$19/mo",
    desc: "Unlimited access to the Standard course library.",
    features: [
      "Everything in Basic",
      "Unlimited access to all Standard-tier courses",
      "Priority community support",
      "Early access to new courses"
    ],
    cta: "Start Pro",
    featured: true
  },
  {
    name: "Business",
    price: "Custom",
    desc: "Bulk seats and team reporting for organizations.",
    features: [
      "Everything in Pro",
      "Bulk seat licenses for your team",
      "Team completion & compliance reports",
      "Custom invoicing / PO billing"
    ],
    cta: "Contact sales",
    featured: false
  }
];

const FAQ_ITEMS = [
  {
    id: "f1",
    title: "Can I cancel my Pro subscription anytime?",
    content: "Yes, Pro is billed monthly or yearly and can be cancelled anytime from your billing settings."
  },
  {
    id: "f2",
    title: "Do Basic (pay-per-course) purchases expire?",
    content: "No, courses you purchase individually are yours for life, regardless of your subscription status."
  },
  {
    id: "f3",
    title: "What's included in Business/Team plans?",
    content: "Bulk seat purchasing, a team roster dashboard, course assignment, and completion reporting for your organization."
  }
];

export default function PricingPage() {
  return (
    <>
      <Navbar />
      <main>
        <section className="px-6 py-16 text-center md:py-24">
          <span className="text-[13px] font-semibold uppercase tracking-[0.06em] text-gold-dark">
            Pricing
          </span>
          <h1 className="mx-auto mt-3 max-w-[640px] font-display text-[30px] font-semibold leading-[1.2] text-ink md:text-[40px]">
            Simple pricing, built around how you learn
          </h1>
        </section>

        <section className="px-6 pb-20">
          <div className="mx-auto grid max-w-[1100px] grid-cols-1 gap-6 md:grid-cols-3">
            {PLANS.map((plan) => (
              <Card
                key={plan.name}
                featured={plan.featured}
                className={plan.featured ? "flex flex-col border-2 border-ink p-8" : "flex flex-col p-8"}
              >
                {plan.featured && (
                  <span className="mb-4 w-fit rounded-full bg-gold px-3 py-1 text-[11px] font-bold uppercase tracking-[0.05em] text-ink">
                    Most popular
                  </span>
                )}
                <h3 className="text-[18px] font-semibold text-ink">{plan.name}</h3>
                <p className="mt-1 font-mono text-[28px] font-semibold text-ink">{plan.price}</p>
                <p className="mt-2 text-[13px] text-ink-soft">{plan.desc}</p>
                <ul className="mt-6 flex flex-1 flex-col gap-3">
                  {plan.features.map((f) => (
                    <li key={f} className="flex items-start gap-2 text-[13px] text-ink-soft">
                      <Check size={15} className="mt-0.5 shrink-0 text-teal" />
                      {f}
                    </li>
                  ))}
                </ul>
                <Link href={plan.name === "Business" ? "/contact" : "/register"} className="mt-6">
                  <Button size="lg" variant={plan.featured ? "primary" : "secondary"} className="w-full">
                    {plan.cta}
                  </Button>
                </Link>
              </Card>
            ))}
          </div>
        </section>

        <section className="bg-paper-dim px-6 py-16 md:py-24">
          <div className="mx-auto max-w-[720px]">
            <h2 className="mb-8 text-center font-display text-[24px] font-semibold text-ink">
              Frequently asked questions
            </h2>
            <Accordion items={FAQ_ITEMS} />
          </div>
        </section>
      </main>
      <Footer />
    </>
  );
}