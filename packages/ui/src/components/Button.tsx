import { forwardRef, type ButtonHTMLAttributes } from "react";
import { cn } from "../cn";

type ButtonVariant = "primary" | "secondary" | "ghost" | "danger" | "brand";
type ButtonSize = "sm" | "md" | "lg";

export type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
};

const variantStyles: Record<ButtonVariant, string> = {
  primary: "bg-gold text-ink hover:bg-gold-dark",
  secondary: "border border-line-strong bg-card text-ink hover:border-ink",
  ghost: "bg-transparent text-ink-soft hover:bg-paper-dim",
  danger: "bg-error text-white hover:brightness-90",
    brand: "bg-gradient-brand text-white hover:brightness-110 shadow-[0_0_40px_-12px_rgba(124,58,237,0.5)]"
};

const sizeStyles: Record<ButtonSize, string> = {
  sm: "h-9 px-4 text-sm",
  md: "h-11 px-5 text-[15px]",
  lg: "h-[52px] px-7 text-[16px]"
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "primary", size = "md", loading, disabled, children, ...props }, ref) => {
    return (
      <button
        ref={ref}
        disabled={disabled || loading}
        className={cn(
          "inline-flex items-center justify-center gap-2 rounded-full font-semibold tracking-[-0.01em]",
          "transition-colors duration-150 ease-out disabled:opacity-50 disabled:pointer-events-none",
          variantStyles[variant],
          sizeStyles[size],
          className
        )}
        {...props}
      >
        {loading ? "Workingâ€¦" : children}
      </button>
    );
  }
);
Button.displayName = "Button";