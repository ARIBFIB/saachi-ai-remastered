import type { HTMLAttributes } from "react";
import { cn } from "../cn";

type BadgeVariant = "default" | "success" | "warning" | "error" | "gold";

export type BadgeProps = HTMLAttributes<HTMLSpanElement> & {
  variant?: BadgeVariant;
};

const variantStyles: Record<BadgeVariant, string> = {
  default: "bg-paper-dim text-ink-soft",
  success: "bg-teal-light text-teal",
  warning: "bg-gold-tint text-gold-dark",
  error: "bg-error-tint text-error",
  gold: "bg-gold text-ink"
};

export function Badge({ className, variant = "default", children, ...props }: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1 rounded-full px-3 py-1 text-xs font-semibold",
        variantStyles[variant],
        className
      )}
      {...props}
    >
      {children}
    </span>
  );
}