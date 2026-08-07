import type { ReactNode } from "react";
import { Inbox } from "lucide-react";
import { cn } from "../cn";

export type EmptyStateProps = {
  icon?: ReactNode;
  title: string;
  description?: string;
  action?: ReactNode;
  className?: string;
};

export function EmptyState({ icon, title, description, action, className }: EmptyStateProps) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center gap-3 rounded-card border border-dashed border-line-strong px-8 py-16 text-center",
        className
      )}
    >
      <div className="flex h-12 w-12 items-center justify-center rounded-full bg-gold-tint text-gold-dark">
        {icon ?? <Inbox size={22} />}
      </div>
      <h3 className="font-display text-[18px] font-semibold text-ink">{title}</h3>
      {description && <p className="max-w-[420px] text-[14px] text-ink-soft">{description}</p>}
      {action && <div className="mt-2">{action}</div>}
    </div>
  );
}