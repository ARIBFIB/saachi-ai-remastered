import type { LucideIcon } from "lucide-react";
import { ArrowUpRight, ArrowDownRight } from "lucide-react";
import { cn } from "../cn";

export type KpiCardProps = {
  label: string;
  value: string;
  icon: LucideIcon;
  delta?: { value: string; direction: "up" | "down" };
  className?: string;
};

export function KpiCard({ label, value, icon: Icon, delta, className }: KpiCardProps) {
  return (
    <div className={cn("rounded-card border border-line bg-card p-5", className)}>
      <div className="mb-4 flex h-9 w-9 items-center justify-center rounded-full border border-line text-ink">
        <Icon size={16} strokeWidth={1.75} />
      </div>
      <div className="font-mono text-[22px] font-semibold leading-none text-ink">{value}</div>
      <div className="mt-2 flex items-center gap-2">
        <span className="text-[13px] text-ink-soft">{label}</span>
        {delta && (
          <span
            className={cn(
              "flex items-center gap-0.5 text-[12px] font-semibold",
              delta.direction === "up" ? "text-success" : "text-error"
            )}
          >
            {delta.direction === "up" ? <ArrowUpRight size={12} /> : <ArrowDownRight size={12} />}
            {delta.value}
          </span>
        )}
      </div>
    </div>
  );
}