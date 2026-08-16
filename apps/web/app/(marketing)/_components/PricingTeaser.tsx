import { PricingSection, type PricingSectionData } from "@/components/ui/pricing-tiers";

const PRICING_DATA: PricingSectionData = {
  title: "Simple, transparent pricing",
  subtitle: "Buy individual courses, or go unlimited with Pro.",
  plans: [
    {
      id: "basic",
      name: "Basic",
      price: "Free",
      description: "Browse the marketplace and buy individual courses.",
      features: ["Buy any course individually", "Completion certificates", "Community Q&A access"],
      buttonText: "Get started",
      buttonLink: "/register",
      isFeatured: false
    },
    {
      id: "pro",
      name: "Pro",
      price: "$19",
      frequency: "/ mo",
      description: "Unlimited access to all Standard-tier courses.",
      features: [
        "Unlimited standard courses",
        "Everything in Basic",
        "Priority support",
        "Verified certificates included"
      ],
      buttonText: "Start Pro",
      buttonLink: "/checkout",
      isFeatured: true,
      badge: "Most popular"
    },
    {
      id: "business",
      name: "Business",
      price: "Custom",
      description: "Bulk seats and team management for organizations.",
      features: [
        "Everything in Pro",
        "Bulk seat licenses",
        "Team completion dashboards",
        "Custom invoicing"
      ],
      buttonText: "Contact sales",
      buttonLink: "/contact",
      isFeatured: false
    }
  ]
};

export function PricingTeaser() {
  return (
    <PricingSection
      data={PRICING_DATA}
      header={
        <>
          <h2 className="mb-2 font-display text-[22px] font-semibold text-ink">{PRICING_DATA.title}</h2>
          <p className="mb-8 text-[14px] text-ink-soft">{PRICING_DATA.subtitle}</p>
        </>
      }
    />
  );
}
