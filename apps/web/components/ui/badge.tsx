import * as React from "react";
import { cn } from "@saachi/ui";

export interface BadgeProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: "default" | "teal" | "gold" | "muted" | "error";
}

const VARIANT_CLASSES: Record<NonNullable<BadgeProps["variant"]>, string> = {
  default: "border-line bg-paper-dim text-ink-soft",
  teal: "border-teal/30 bg-teal-light text-teal",
  gold: "border-gold-dark/30 bg-gold-tint text-gold-dark",
  muted: "border-line bg-paper-dim text-ink-soft",
  error: "border-error/30 bg-error-tint text-error"
};

function Badge({ className, variant = "default", ...props }: BadgeProps) {
  return (
    <div
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-0.5 text-[11px] font-semibold capitalize",
        VARIANT_CLASSES[variant],
        className
      )}
      {...props}
    />
  );
}

export { Badge };
