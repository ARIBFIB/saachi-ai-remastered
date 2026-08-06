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
        "flex flex-col items-center justify-center gap-3 rounded-2xl border border-dashed",
        "border-[var(--border-hairline-strong,rgba(15,23,42,0.14))] px-8 py-16 text-center",
        className
      )}
    >
      <div className="flex h-12 w-12 items-center justify-center rounded-full bg-[var(--blue-50,#EFF6FF)] text-[var(--blue-500,#3B82F6)]">
        {icon ?? <Inbox size={22} />}
      </div>
      <h3 className="text-[18px] font-semibold text-[var(--text-primary,#0F172A)]">{title}</h3>
      {description && (
        <p className="max-w-[420px] text-[14px] text-[var(--text-secondary,#475569)]">
          {description}
        </p>
      )}
      {action && <div className="mt-2">{action}</div>}
    </div>
  );
}
