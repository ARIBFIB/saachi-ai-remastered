import { X } from "lucide-react";

interface ComparisonRow {
  feature: string;
  free: string | null;
  pro: string;
  enterprise: string;
}

const rows: ComparisonRow[] = [
  { feature: "Course Access", free: "Free only", pro: "Unlimited Premium", enterprise: "Unlimited Premium" },
  { feature: "AI Mentorship", free: null, pro: "1-on-1 Sessions", enterprise: "Priority Scheduling" },
  { feature: "Analytics", free: "Basic", pro: "Detailed", enterprise: "Custom Organization" },
  { feature: "Support", free: "Community", pro: "Priority Email", enterprise: "24/7 Dedicated" },
];

export function FeatureComparisonTable() {
  return (
    <section className="w-full overflow-hidden rounded-[var(--token-radius-lg)] border-2 border-[var(--token-color-border)] bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]">
      <h2 className="pb-6 text-center text-3xl font-bold leading-10 text-[var(--token-color-ink)]">
        Compare Features
      </h2>

      <div className="min-w-[800px] overflow-x-auto">
        <div className="grid grid-cols-[1.5fr_1fr_1fr_1fr] border-b border-[var(--token-color-border)]">
          <div className="p-4 text-sm font-medium tracking-wide text-[var(--token-color-inkSoft)]">Feature</div>
          <div className="p-4 text-center text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">Free</div>
          <div className="p-4 text-center text-sm font-bold tracking-wide text-[var(--token-color-amber)]">Pro</div>
          <div className="p-4 text-center text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">Enterprise</div>
        </div>

        {rows.map((row, i) => (
          <div
            key={row.feature}
            className={`grid grid-cols-[1.5fr_1fr_1fr_1fr] ${
              i < rows.length - 1 ? "border-b border-[var(--token-color-border)]/40" : ""
            }`}
          >
            <div className="p-4 text-base text-[var(--token-color-inkSoft)]">{row.feature}</div>
            <div className="flex items-center justify-center p-4 text-center text-base text-[var(--token-color-inkSoft)]">
              {row.free ?? <X className="h-3 w-3 text-[var(--token-color-textMuted)]" />}
            </div>
            <div className="p-4 text-center text-base font-medium text-[var(--token-color-amber)]">{row.pro}</div>
            <div className="p-4 text-center text-base text-[var(--token-color-inkSoft)]">{row.enterprise}</div>
          </div>
        ))}
      </div>
    </section>
  );
}