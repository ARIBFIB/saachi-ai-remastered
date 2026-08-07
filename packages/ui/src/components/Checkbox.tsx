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
      <label htmlFor={checkboxId} className="inline-flex cursor-pointer items-center gap-2.5 select-none">
        <span className="relative inline-flex h-[18px] w-[18px] shrink-0 items-center justify-center">
          <input
            ref={ref}
            type="checkbox"
            id={checkboxId}
            className={cn("peer absolute inset-0 h-full w-full cursor-pointer opacity-0", className)}
            {...props}
          />
          <span className="flex h-[18px] w-[18px] items-center justify-center rounded-[5px] border border-line-strong bg-card transition-colors duration-150 ease-out peer-checked:border-gold peer-checked:bg-gold peer-focus-visible:ring-2 peer-focus-visible:ring-gold/40">
            <Check size={13} strokeWidth={3} className="text-ink opacity-0 peer-checked:opacity-100" />
          </span>
        </span>
        {label && <span className="text-[14px] text-ink">{label}</span>}
      </label>
    );
  }
);
Checkbox.displayName = "Checkbox";