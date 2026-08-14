import Link from "next/link";
import { Check } from "lucide-react";
import { cn } from "@saachi/ui";

const PLANS = [
  { name: "Basic", price: "Free", accent: "border-line", features: ["Buy courses individually", "Completion certificates"] },
  { name: "Pro", price: "$19/mo", accent: "border-accent-violet/50 bg-gold-tint", highlighted: true, features: ["Unlimited standard courses", "Priority support", "Verified certificates"] },
  { name: "Business", price: "Contact us", accent: "border-line", features: ["Bulk seat licenses", "Team dashboards"] }
];

export function PricingTeaser() {
  return (
    <div className="grid grid-cols-1 gap-5 md:grid-cols-3">
      {PLANS.map((plan) => (
        <div key={plan.name} className={cn("flex flex-col rounded-card border p-6", plan.accent)}>
          {plan.highlighted && (
            <span className="mb-3 w-fit rounded-full bg-gold-dark px-2.5 py-0.5 text-[10px] font-bold uppercase tracking-wide text-white">
              Most popular
            </span>
          )}
          <h3 className="font-display text-[18px] font-semibold text-ink">{plan.name}</h3>
          <p className="mt-1 font-mono text-[24px] font-bold text-ink">{plan.price}</p>
          <ul className="my-5 flex flex-1 flex-col gap-2 text-[13px] text-ink-soft">
            {plan.features.map((f) => (
              <li key={f} className="flex items-start gap-2">
                <Check size={14} className="mt-0.5 shrink-0 text-teal" />
                {f}
              </li>
            ))}
          </ul>
          <Link
            href="/pricing"
            className={cn(
              "w-full rounded-full py-2.5 text-center text-[13px] font-semibold transition-opacity hover:opacity-90",
              plan.highlighted ? "bg-ink text-paper" : "border border-line text-ink"
            )}
          >
            View plan
          </Link>
        </div>
      ))}
    </div>
  );
}