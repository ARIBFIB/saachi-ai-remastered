import { CheckCircle2 } from "lucide-react";

export interface PricingCardProps {
  tier: string;
  description: string;
  price: string;
  priceSuffix?: string;
  features: string[];
  ctaLabel: string;
  highlighted?: boolean;
  badge?: string;
}

export function PricingCard({
  tier,
  description,
  price,
  priceSuffix,
  features,
  ctaLabel,
  highlighted = false,
  badge,
}: PricingCardProps) {
  return (
    <div
      className={`relative flex w-96 flex-col justify-between rounded-xl border-2 bg-[var(--token-color-surface)]/90 p-6 backdrop-blur-[6px] ${
        highlighted
          ? "border-[var(--token-color-primary)]/30 shadow-[0px_0px_40px_0px_rgba(79,70,229,0.15)]"
          : "border-[var(--token-color-border)]/60"
      }`}
    >
      {badge && (
        <span className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-[var(--token-color-primary)] px-3 py-1 text-xs font-bold uppercase tracking-wide text-white">
          {badge}
        </span>
      )}

      <div className="flex flex-col gap-1 pb-6">
        <h3
          className={`text-2xl font-semibold leading-8 ${
            highlighted ? "text-[var(--token-color-primary)]" : "text-[var(--token-color-ink)]"
          }`}
        >
          {tier}
        </h3>
        <p className="text-base text-[var(--token-color-inkSoft)]">{description}</p>

        <div className="flex items-baseline gap-1 pt-5">
          <span className="text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">{price}</span>
          {priceSuffix && <span className="text-base text-[var(--token-color-inkSoft)]">{priceSuffix}</span>}
        </div>

        <ul className="flex flex-col gap-4 pt-5">
          {features.map((feature) => (
            <li key={feature} className="flex items-center gap-2">
              <CheckCircle2 className="h-3 w-3 shrink-0 text-[var(--token-color-primary)]" />
              <span className="text-base text-[var(--token-color-inkSoft)]">{feature}</span>
            </li>
          ))}
        </ul>
      </div>

      <button
        type="button"
        className={`w-full rounded-lg py-3 text-sm font-semibold tracking-wide transition ${
          highlighted
            ? "bg-[var(--token-color-primary)] text-white shadow-[var(--token-shadow-sm)] hover:bg-[var(--token-color-primaryHover)]"
            : "border-2 border-[var(--token-color-textMuted)] text-[var(--token-color-ink)] hover:bg-[var(--token-color-surfaceAlt)]"
        }`}
      >
        {ctaLabel}
      </button>
    </div>
  );
}