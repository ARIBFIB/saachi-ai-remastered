import { forwardRef, type ButtonHTMLAttributes } from "react";
import { cn } from "../cn";

type ButtonVariant = "primary" | "secondary" | "ghost" | "danger";
type ButtonSize = "sm" | "md" | "lg";

export type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
};

const variantStyles: Record<ButtonVariant, string> = {
  primary:
    "text-white shadow-[0_4px_20px_rgba(30,64,175,0.10)] hover:shadow-[0_0_32px_rgba(59,130,246,0.35)]",
  secondary:
    "border border-[var(--border-hairline,rgba(15,23,42,0.14))] bg-transparent hover:border-blue-400",
  ghost: "bg-transparent text-[var(--text-secondary,#475569)] hover:bg-[var(--surface-elevated,#F1F5F9)]",
  danger: "bg-red-500 text-white hover:bg-red-600"
};

const sizeStyles: Record<ButtonSize, string> = {
  sm: "h-9 px-4 text-sm",
  md: "h-11 px-5 text-[15px]",
  lg: "h-13 px-6 text-[17px]"
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "primary", size = "md", loading, disabled, children, style, ...props }, ref) => {
    const isPrimary = variant === "primary";
    return (
      <button
        ref={ref}
        disabled={disabled || loading}
        className={cn(
          "inline-flex items-center justify-center rounded-full font-medium transition-all duration-200 ease-out disabled:opacity-60 disabled:pointer-events-none",
          variantStyles[variant],
          sizeStyles[size],
          className
        )}
        style={
          isPrimary
            ? {
                background:
                  "linear-gradient(135deg, #2563EB 0%, #0EA5E9 50%, #22D3EE 100%)",
                ...style
              }
            : style
        }
        {...props}
      >
        {loading ? "..." : children}
      </button>
    );
  }
);
Button.displayName = "Button";
