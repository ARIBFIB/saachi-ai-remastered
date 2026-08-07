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
          "rounded-card border border-line bg-card p-6",
          "transition-all duration-200 ease-out hover:-translate-y-0.5 hover:border-line-strong",
          featured && "border-teal/20 bg-teal-light",
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