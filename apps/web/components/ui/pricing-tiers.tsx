import type { ReactNode } from "react";
import Link from "next/link";
import { Check } from "lucide-react";
import { cn } from "@/lib/utils";

export type PricingPlan = {
  id: string;
  name: string;
  price: string;
  frequency?: string;
  description: string;
  features: string[];
  buttonText: string;
  buttonLink: string;
  isFeatured?: boolean;
  badge?: string;
};

export type PricingSectionData = {
  title: string;
  subtitle?: string;
  plans: PricingPlan[];
};

function PricingTier({
  name,
  price,
  frequency,
  description,
  features,
  buttonText,
  buttonLink,
  isFeatured = false,
  badge
}: PricingPlan) {
  return (
    <div
      className={cn(
        "flex w-full max-w-sm flex-col rounded-card border p-8 transition-transform duration-200",
        isFeatured
          ? "border-accent-violet/50 bg-gold-tint shadow-xl ring-1 ring-accent-violet/30 md:-translate-y-2"
          : "border-line bg-card shadow-sm hover:-translate-y-1"
      )}
    >
      {isFeatured && badge && (
        <span className="mb-3 w-fit self-center rounded-full bg-gold-dark px-3 py-1 text-[11px] font-bold uppercase tracking-wide text-white">
          {badge}
        </span>
      )}

      <h3 className="text-center font-display text-[22px] font-bold text-ink">{name}</h3>

      <div className="mt-4 flex items-baseline justify-center gap-1">
        <span className="font-mono text-[42px] font-extrabold leading-none text-ink">{price}</span>
        {frequency && <span className="text-[14px] font-medium text-ink-soft">{frequency}</span>}
      </div>

      <p className="mt-4 text-center text-[13.5px] leading-relaxed text-ink-soft">{description}</p>

      <ul className="mt-8 flex flex-1 flex-col gap-3.5">
        {features.map((feature) => (
          <li key={feature} className="flex items-start gap-3 text-[13.5px] text-ink">
            <span
              className={cn(
                "mt-0.5 flex h-5 w-5 shrink-0 items-center justify-center rounded-full",
                isFeatured ? "bg-accent-violet text-white" : "bg-teal-light text-teal"
              )}
            >
              <Check size={12} strokeWidth={3} />
            </span>
            {feature}
          </li>
        ))}
      </ul>

      <Link
        href={buttonLink}
        className={cn(
          "mt-8 w-full rounded-full py-3 text-center text-[13.5px] font-semibold transition-transform hover:scale-[1.02]",
          isFeatured ? "bg-ink text-paper" : "border border-line text-ink hover:bg-paper-dim"
        )}
      >
        {buttonText}
      </Link>
    </div>
  );
}

export function PricingSection({
  data,
  className,
  header
}: {
  data: PricingSectionData;
  className?: string;
  header?: ReactNode;
}) {
  return (
    <div className={className}>
      {header ?? (
        <div className="mb-10 text-center">
          <h2 className="font-display text-[26px] font-bold text-ink md:text-[32px]">{data.title}</h2>
          {data.subtitle && (
            <p className="mx-auto mt-3 max-w-xl text-[14.5px] text-ink-soft">{data.subtitle}</p>
          )}
        </div>
      )}
      <div className="flex flex-col items-stretch justify-center gap-6 md:flex-row md:items-center">
        {data.plans.map((plan) => (
          <PricingTier key={plan.id} {...plan} />
        ))}
      </div>
    </div>
  );
}

export default PricingSection;