"use client";

import { forwardRef } from "react";
import type { ButtonHTMLAttributes } from "react";

type ButtonVariant = "primary" | "secondary" | "ghost" | "danger";
type ButtonSize = "sm" | "md" | "lg";

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
  size?: ButtonSize;
};

const BASE =
  "inline-flex items-center justify-center gap-1.5 rounded-control font-medium whitespace-nowrap " +
  "transition-colors duration-150 ease-out outline-none " +
  "focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-ink " +
  "disabled:cursor-not-allowed disabled:opacity-45 " +
  "active:enabled:scale-[0.97]";

const SIZE_CLASSES: Record<ButtonSize, string> = {
  sm: "h-8 px-3 text-[12.5px]",
  md: "h-9 px-4 text-[13px]",
  lg: "h-11 px-5 text-[14px]"
};

const VARIANT_CLASSES: Record<ButtonVariant, string> = {
  primary:
    "bg-ink text-paper border border-ink " +
    "hover:enabled:bg-ink/90 " +
    "[data-theme=dark]_&:hover:enabled:bg-ink/80",
  secondary:
    "bg-card text-ink border border-line-strong " +
    "hover:enabled:bg-paper-dim hover:enabled:border-line-strong",
  ghost:
    "bg-transparent text-ink-soft border border-transparent " +
    "hover:enabled:bg-paper-dim hover:enabled:text-ink",
  danger:
    "bg-error text-paper border border-error " +
    "hover:enabled:bg-error/90"
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  { variant = "primary", size = "md", className = "", type = "button", ...props },
  ref
) {
  const classes = [BASE, SIZE_CLASSES[size], VARIANT_CLASSES[variant], className]
    .filter(Boolean)
    .join(" ");

  return <button ref={ref} type={type} className={classes} {...props} />;
});