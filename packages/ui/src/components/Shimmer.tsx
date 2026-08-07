import type { HTMLAttributes } from "react";
import { cn } from "../cn";

export type ShimmerProps = HTMLAttributes<HTMLDivElement>;

/** Base shimmer block - grayscale sweep, works in light + dark theme. */
export function Shimmer({ className, ...props }: ShimmerProps) {
  return (
    <div
      className={cn(
        "relative overflow-hidden rounded-control bg-paper-dim",
        "before:absolute before:inset-0 before:-translate-x-full",
        "before:bg-gradient-to-r before:from-transparent before:via-white/60 before:to-transparent",
        "before:animate-shimmer dark:before:via-white/10",
        className
      )}
      {...props}
    />
  );
}

export function ShimmerText({ lines = 3, lastLineWidth = "60%" }: { lines?: number; lastLineWidth?: string }) {
  return (
    <div className="flex flex-col gap-2">
      {Array.from({ length: lines }).map((_, i) => (
        <Shimmer key={i} className="h-3.5" style={{ width: i === lines - 1 ? lastLineWidth : "100%" }} />
      ))}
    </div>
  );
}

export function ShimmerKpiCard() {
  return (
    <div className="rounded-card border border-line bg-card p-5">
      <Shimmer className="mb-4 h-9 w-9 rounded-full" />
      <Shimmer className="mb-2 h-6 w-20" />
      <Shimmer className="h-3.5 w-28" />
    </div>
  );
}

export function ShimmerTableRow({ columns = 5 }: { columns?: number }) {
  return (
    <div className="flex items-center gap-4 border-b border-line px-4 py-3.5">
      {Array.from({ length: columns }).map((_, i) => (
        <Shimmer key={i} className="h-3.5 flex-1" />
      ))}
    </div>
  );
}

export function ShimmerTable({ rows = 6, columns = 5 }: { rows?: number; columns?: number }) {
  return (
    <div className="overflow-hidden rounded-card border border-line bg-card">
      {Array.from({ length: rows }).map((_, i) => (
        <ShimmerTableRow key={i} columns={columns} />
      ))}
    </div>
  );
}

export function ShimmerChart() {
  return (
    <div className="rounded-card border border-line bg-card p-6">
      <Shimmer className="mb-6 h-4 w-32" />
      <Shimmer className="h-[220px] w-full" />
    </div>
  );
}