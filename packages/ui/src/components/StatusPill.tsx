import { cn } from "../cn";

type StatusTone = "neutral" | "success" | "warning" | "error" | "info";

export type StatusPillProps = {
  label: string;
  tone?: StatusTone;
  className?: string;
};

const toneStyles: Record<StatusTone, string> = {
  neutral: "bg-paper-dim text-ink-soft border-line",
  success: "bg-success-tint text-success border-success/20",
  warning: "bg-warning-tint text-warning border-warning/20",
  error: "bg-error-tint text-error border-error/20",
  info: "bg-info-tint text-info border-info/20"
};

export function StatusPill({ label, tone = "neutral", className }: StatusPillProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-[12px] font-semibold capitalize",
        toneStyles[tone],
        className
      )}
    >
      <span className="h-1.5 w-1.5 rounded-full bg-current" />
      {label}
    </span>
  );
}