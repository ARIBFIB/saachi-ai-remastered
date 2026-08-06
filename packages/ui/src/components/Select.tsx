import { forwardRef, type SelectHTMLAttributes } from "react";
import { ChevronDown } from "lucide-react";
import { cn } from "../cn";

export type SelectOption = {
  label: string;
  value: string;
};

export type SelectProps = SelectHTMLAttributes<HTMLSelectElement> & {
  label?: string;
  error?: string;
  helperText?: string;
  options: SelectOption[];
  placeholder?: string;
};

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ className, label, error, helperText, options, placeholder, id, ...props }, ref) => {
    const selectId = id ?? props.name;

    return (
      <div className="flex flex-col gap-1.5">
        {label && (
          <label
            htmlFor={selectId}
            className="text-[13px] font-semibold text-[var(--text-primary,#0F172A)]"
          >
            {label}
          </label>
        )}
        <div className="relative">
          <select
            ref={ref}
            id={selectId}
            className={cn(
              "h-11 w-full appearance-none rounded-[10px] border bg-[var(--surface-card,#FFFFFF)] px-3.5 pr-10 text-[15px]",
              "border-[var(--border-hairline-strong,rgba(15,23,42,0.14))]",
              "text-[var(--text-primary,#0F172A)]",
              "outline-none transition-all duration-150 ease-out",
              "focus:border-[var(--blue-500,#3B82F6)] focus:shadow-[0_0_16px_rgba(59,130,246,0.25)]",
              error && "border-[#EF4444] focus:border-[#EF4444] focus:shadow-none",
              className
            )}
            aria-invalid={Boolean(error)}
            {...props}
          >
            {placeholder && (
              <option value="" disabled>
                {placeholder}
              </option>
            )}
            {options.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
          <ChevronDown
            size={18}
            className="pointer-events-none absolute right-3.5 top-1/2 -translate-y-1/2 text-[var(--text-secondary,#475569)]"
          />
        </div>
        {error ? (
          <p className="text-[13px] text-[#EF4444]">{error}</p>
        ) : helperText ? (
          <p className="text-[13px] text-[var(--text-secondary,#475569)]">{helperText}</p>
        ) : null}
      </div>
    );
  }
);
Select.displayName = "Select";
