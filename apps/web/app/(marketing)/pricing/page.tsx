import { Header } from "@/components/marketing/Header";
import { DetailFooter } from "@/components/course-detail/DetailFooter";
import { BillingToggle } from "@/components/pricing/BillingToggle";
import { PricingCard, type PricingCardProps } from "@/components/pricing/PricingCard";
import { FeatureComparisonTable } from "@/components/pricing/FeatureComparisonTable";
import { FaqAccordion } from "@/components/pricing/FaqAccordion";

const tiers: PricingCardProps[] = [
  {
    tier: "Free",
    description: "For curious learners starting their journey.",
    price: "$0",
    priceSuffix: "/month",
    features: ["Access to free courses", "Community forums", "Basic progress tracking"],
    ctaLabel: "Get Started",
  },
  {
    tier: "Pro",
    description: "For dedicated professionals accelerating their skills.",
    price: "$29",
    priceSuffix: "/month",
    features: [
      "Everything in Free",
      "Unlimited premium courses",
      "1-on-1 AI Mentorship",
      "Certificate of completion",
    ],
    ctaLabel: "Select Pro",
    highlighted: true,
    badge: "Most Popular",
  },
  {
    tier: "Enterprise",
    description: "Custom solutions for teams and organizations.",
    price: "Custom",
    features: [
      "Dedicated success manager",
      "Custom learning paths",
      "Advanced analytics dashboard",
      "SSO & API access",
    ],
    ctaLabel: "Contact Sales",
  },
];

export default function PricingPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-col items-center gap-10 px-6 pb-20 pt-24">
        <section className="flex w-full flex-col items-center gap-1.5">
          <h1 className="text-center text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
            Simple, transparent pricing
          </h1>
          <p className="max-w-[672px] text-center text-lg leading-7 text-[var(--token-color-inkSoft)]">
            Choose the plan that best fits your learning or teaching goals. No hidden fees, ever.
          </p>
          <BillingToggle />
        </section>

        <section className="flex flex-wrap items-start justify-center gap-6 pt-6">
          {tiers.map((tier) => (
            <PricingCard key={tier.tier} {...tier} />
          ))}
        </section>

        <FeatureComparisonTable />

        <FaqAccordion />
      </main>

      <DetailFooter />
    </div>
  );
}