import { forwardRef, type InputHTMLAttributes } from "react";
import { Check } from "lucide-react";
import { cn } from "../cn";

export type CheckboxProps = Omit<InputHTMLAttributes<HTMLInputElement>, "type"> & {
  label?: string;
};

export const Checkbox = forwardRef<HTMLInputElement, CheckboxProps>(
  ({ className, label, id, ...props }, ref) => {
    const checkboxId = id ?? props.name;

    return (
      <label
        htmlFor={checkboxId}
        className="inline-flex cursor-pointer items-center gap-2.5 select-none"
      >
        <span className="relative inline-flex h-[18px] w-[18px] shrink-0 items-center justify-center">
          <input
            ref={ref}
            type="checkbox"
            id={checkboxId}
            className={cn("peer absolute inset-0 h-full w-full cursor-pointer opacity-0", className)}
            {...props}
          />
          <span
            className={cn(
              "flex h-[18px] w-[18px] items-center justify-center rounded-[5px] border transition-all duration-150 ease-out",
              "border-[var(--border-hairline-strong,rgba(15,23,42,0.14))] bg-[var(--surface-card,#FFFFFF)]",
              "peer-checked:border-transparent peer-checked:[background:var(--gradient-primary,linear-gradient(135deg,#2563EB_0%,#0EA5E9_50%,#22D3EE_100%))]",
              "peer-focus-visible:shadow-[0_0_0_2px_rgba(59,130,246,0.35)]"
            )}
          >
            <Check size={13} strokeWidth={3} className="text-white opacity-0 peer-checked:opacity-100" />
          </span>
        </span>
        {label && (
          <span className="text-[14px] text-[var(--text-primary,#0F172A)]">{label}</span>
        )}
      </label>
    );
  }
);
Checkbox.displayName = "Checkbox";
