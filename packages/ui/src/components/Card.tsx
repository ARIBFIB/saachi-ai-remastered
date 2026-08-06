import { forwardRef, type HTMLAttributes } from "react";
import { cn } from "../cn";

export type CardProps = HTMLAttributes<HTMLDivElement> & {
  featured?: boolean;
};

export const Card = forwardRef<HTMLDivElement, CardProps>(
  ({ className, featured, children, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn(
          "rounded-2xl border border-[var(--border-hairline,rgba(15,23,42,0.08))] bg-[var(--surface-card,#FFFFFF)] p-6 shadow-[0_2px_8px_rgba(30,64,175,0.06)] transition-all duration-200 ease-out hover:-translate-y-0.5 hover:shadow-[0_4px_20px_rgba(30,64,175,0.10)]",
          featured && "bg-gradient-to-br from-white to-blue-50",
          className
        )}
        {...props}
      >
        {children}
      </div>
    );
  }
);
Card.displayName = "Card";
