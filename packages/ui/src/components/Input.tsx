import { forwardRef, type InputHTMLAttributes } from "react";
import { cn } from "../cn";

export type InputProps = InputHTMLAttributes<HTMLInputElement> & {
  label?: string;
  error?: string;
  helperText?: string;
};

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, label, error, helperText, id, ...props }, ref) => {
    const inputId = id ?? props.name;

    return (
      <div className="flex flex-col gap-1.5">
        {label && (
          <label htmlFor={inputId} className="text-[13px] font-semibold text-ink">
            {label}
          </label>
        )}
        <input
          ref={ref}
          id={inputId}
          className={cn(
            "h-11 w-full rounded-control border border-line-strong bg-card px-3.5 text-[15px] text-ink",
            "placeholder:text-ink-soft/50 outline-none transition-colors duration-150 ease-out",
            "focus:border-gold",
            error && "border-error focus:border-error",
            className
          )}
          aria-invalid={Boolean(error)}
          {...props}
        />
        {error ? (
          <p className="text-[13px] text-error">{error}</p>
        ) : helperText ? (
          <p className="text-[13px] text-ink-soft">{helperText}</p>
        ) : null}
      </div>
    );
  }
);
Input.displayName = "Input";