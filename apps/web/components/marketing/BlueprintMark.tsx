// Signature element for the "Blueprint" design system: a small dimension-line
// crosshair mark, like a corner registration mark on a spec sheet. Used
// sparingly on hero cards and section dividers -- not decoration, it signals
// "this is measured / specified," matching Saachi's outcome-based identity.
interface BlueprintMarkProps {
  className?: string;
  color?: string;
}

export function BlueprintMark({ className = "", color = "var(--token-color-blueprintLine)" }: BlueprintMarkProps) {
  return (
    <svg
      className={className}
      width="20"
      height="20"
      viewBox="0 0 20 20"
      fill="none"
      aria-hidden="true"
    >
      <path d="M10 0V6" stroke={color} strokeWidth="1" />
      <path d="M10 14V20" stroke={color} strokeWidth="1" />
      <path d="M0 10H6" stroke={color} strokeWidth="1" />
      <path d="M14 10H20" stroke={color} strokeWidth="1" />
      <circle cx="10" cy="10" r="2" stroke={color} strokeWidth="1" />
    </svg>
  );
}

interface SpecLabelProps {
  index: string;
  label: string;
}

// Small mono-type "spec field" label -- reused as section eyebrows instead
// of a generic pill badge.
export function SpecLabel({ index, label }: SpecLabelProps) {
  return (
    <div className="flex items-center gap-2">
      <span
        className="text-xs font-medium"
        style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-amberDark)" }}
      >
        {index}
      </span>
      <span
        className="h-px w-6"
        style={{ backgroundColor: "var(--token-color-blueprintLine)" }}
      />
      <span
        className="text-xs font-semibold uppercase tracking-[0.12em]"
        style={{ color: "var(--token-color-inkDeepSoft)" }}
      >
        {label}
      </span>
    </div>
  );
}