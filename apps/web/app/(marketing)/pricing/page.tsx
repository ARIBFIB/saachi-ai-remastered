import Link from "next/link";
import { Button, Badge } from "@saachi/ui";

const PLANS = [
  {
    name: "Basic",
    price: "Free",
    description: "Browse the marketplace and buy individual courses.",
    features: ["Buy any course individually", "Course completion certificates", "Community Q&A access"],
    cta: "Get started",
    href: "/register"
  },
  {
    name: "Pro",
    price: "$19/mo",
    description: "Unlimited access to all Standard-tier courses.",
    features: [
      "Unlimited Standard-tier courses",
      "Everything in Basic",
      "Priority support",
      "Verified certificates included"
    ],
    cta: "Start Pro",
    href: "/checkout",
    highlighted: true
  },
  {
    name: "Business",
    price: "Contact us",
    description: "Bulk seats and team management for organizations.",
    features: [
      "Everything in Pro",
      "Bulk seat licenses",
      "Team completion dashboards",
      "Custom invoicing"
    ],
    cta: "Contact sales",
    href: "/contact"
  }
];

export default function PricingPage() {
  return (
    <div className="mx-auto max-w-6xl px-4 py-16 md:px-8">
      <div className="mb-12 text-center">
        <h1 className="mb-3 font-display text-[32px] font-bold text-ink">Simple, transparent pricing</h1>
        <p className="text-[15px] text-ink-soft">Buy individual courses, or go unlimited with Saachi AI Pro.</p>
      </div>

      <div className="grid grid-cols-1 gap-6 md:grid-cols-3">
        {PLANS.map((plan) => (
          <div
            key={plan.name}
            className={`flex flex-col rounded-card border p-6 ${
              plan.highlighted ? "border-gold-dark/50 bg-gold-tint" : "border-line bg-card"
            }`}
          >
            {plan.highlighted && (
              <Badge variant="gold" className="mb-3 self-start">
                Most popular
              </Badge>
            )}
            <h2 className="font-display text-[20px] font-semibold text-ink">{plan.name}</h2>
            <p className="mt-1 font-mono text-[26px] font-bold text-ink">{plan.price}</p>
            <p className="mt-2 text-[13px] text-ink-soft">{plan.description}</p>

            <ul className="my-6 flex flex-1 flex-col gap-2 text-[14px] text-ink-soft">
              {plan.features.map((f) => (
                <li key={f}>- {f}</li>
              ))}
            </ul>

            <Link href={plan.href}>
              <Button className="w-full" variant={plan.highlighted ? "primary" : "secondary"}>
                {plan.cta}
              </Button>
            </Link>
          </div>
        ))}
      </div>
    </div>
  );
}
