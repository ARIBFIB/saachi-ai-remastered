"use client";

type SwitchProps = {
  checked: boolean;
  onChange: () => void;
  disabled?: boolean;
  label?: string;
  className?: string;
};

export function Switch({ checked, onChange, disabled = false, label, className = "" }: SwitchProps) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      onClick={onChange}
      className={`relative h-6 w-11 shrink-0 rounded-full outline-none transition-colors duration-200 ease-out
        focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-ink
        disabled:cursor-not-allowed disabled:opacity-40
        ${checked ? "bg-ink hover:bg-ink/85" : "bg-paper-dim hover:bg-line-strong"}
        ${!disabled ? "cursor-pointer active:scale-[0.96]" : ""}
        ${className}`}
    >
      <span
        className={`absolute top-0.5 h-5 w-5 rounded-full bg-paper shadow-sm transition-transform duration-200 ease-out
          ${checked ? "translate-x-[22px]" : "translate-x-0.5"}`}
      />
    </button>
  );
}