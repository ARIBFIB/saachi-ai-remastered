"use client";

import { useState, type InputHTMLAttributes } from "react";
import { cn } from "@/lib/utils";

export type AuthFieldProps = InputHTMLAttributes<HTMLInputElement> & {
  label: string;
};

/**
 * Floating-label input box: while empty and unfocused, the label sits
 * centered inside the box like a placeholder. As soon as the field has
 * focus or a value, the label lifts to the right edge.
 */
export function AuthField({ label, className, value, onFocus, onBlur, id, ...props }: AuthFieldProps) {
  const [focused, setFocused] = useState(false);
  const hasValue = Boolean(value);
  const showFloatingLabel = focused || hasValue;
  const fieldId = id ?? props.name;

  return (
    <label
      htmlFor={fieldId}
      className={cn(
        "flex h-14 items-center justify-between gap-4 rounded-[10px] border border-line bg-card px-5 text-[16px] leading-none transition-colors",
        focused && "border-accent-violet",
        className
      )}
    >
      <input
        id={fieldId}
        value={value}
        onFocus={(e) => {
          setFocused(true);
          onFocus?.(e);
        }}
        onBlur={(e) => {
          setFocused(false);
          onBlur?.(e);
        }}
        aria-label={label}
        className="min-w-0 flex-1 truncate bg-transparent text-ink outline-none placeholder:text-transparent"
        {...props}
      />
      <span
        className={cn(
          "shrink-0 text-ink-soft transition-opacity",
          showFloatingLabel ? "text-[12px] font-medium uppercase tracking-wide" : "text-[16px]"
        )}
      >
        {label}
      </span>
    </label>
  );
}