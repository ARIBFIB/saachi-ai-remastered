import { forwardRef, type TextareaHTMLAttributes } from "react";
import { cn } from "../cn";

export type TextareaProps = TextareaHTMLAttributes<HTMLTextAreaElement> & {
  label?: string;
  error?: string;
  helperText?: string;
};

export const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ className, label, error, helperText, id, rows = 4, ...props }, ref) => {
    const textareaId = id ?? props.name;

    return (
      <div className="flex flex-col gap-1.5">
        {label && (
          <label
            htmlFor={textareaId}
            className="text-[13px] font-semibold text-[var(--text-primary,#0F172A)]"
          >
            {label}
          </label>
        )}
        <textarea
          ref={ref}
          id={textareaId}
          rows={rows}
          className={cn(
            "w-full resize-y rounded-[10px] border bg-[var(--surface-card,#FFFFFF)] px-3.5 py-3 text-[15px] leading-[1.55]",
            "border-[var(--border-hairline-strong,rgba(15,23,42,0.14))]",
            "text-[var(--text-primary,#0F172A)] placeholder:text-[var(--text-muted,#94A3B8)]",
            "outline-none transition-all duration-150 ease-out",
            "focus:border-[var(--blue-500,#3B82F6)] focus:shadow-[0_0_16px_rgba(59,130,246,0.25)]",
            error && "border-[#EF4444] focus:border-[#EF4444] focus:shadow-none",
            className
          )}
          aria-invalid={Boolean(error)}
          {...props}
        />
        {error ? (
          <p className="text-[13px] text-[#EF4444]">{error}</p>
        ) : helperText ? (
          <p className="text-[13px] text-[var(--text-secondary,#475569)]">{helperText}</p>
        ) : null}
      </div>
    );
  }
);
Textarea.displayName = "Textarea";
