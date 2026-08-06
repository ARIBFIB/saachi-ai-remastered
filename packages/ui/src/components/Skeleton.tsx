import type { HTMLAttributes } from "react";
import { cn } from "../cn";

export type SkeletonProps = HTMLAttributes<HTMLDivElement>;

export function Skeleton({ className, ...props }: SkeletonProps) {
  return (
    <div
      className={cn(
        "animate-pulse rounded-[10px] bg-[var(--surface-elevated,#F1F5F9)]",
        "bg-[linear-gradient(90deg,var(--surface-elevated,#F1F5F9)_0%,rgba(96,165,250,0.12)_50%,var(--surface-elevated,#F1F5F9)_100%)]",
        "bg-[length:200%_100%]",
        className
      )}
      {...props}
    />
  );
}

export function SkeletonText({ lines = 3 }: { lines?: number }) {
  return (
    <div className="flex flex-col gap-2">
      {Array.from({ length: lines }).map((_, i) => (
        <Skeleton
          key={i}
          className="h-4"
          style={{ width: i === lines - 1 ? "60%" : "100%" }}
        />
      ))}
    </div>
  );
}

export function SkeletonCard() {
  return (
    <div className="rounded-2xl border border-[var(--border-hairline,rgba(15,23,42,0.08))] p-6">
      <Skeleton className="mb-4 h-40 w-full" />
      <Skeleton className="mb-2 h-5 w-3/4" />
      <SkeletonText lines={2} />
    </div>
  );
}
