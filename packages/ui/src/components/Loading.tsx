"use client";

import Lottie from "lottie-react";
import { cn } from "../cn";

export type LoadingProps = {
  size?: number;
  label?: string;
  fullScreen?: boolean;
  className?: string;
};

export function Loading({ size = 120, label, fullScreen = false, className }: LoadingProps) {
  return (
    <div
      className={cn(
        "flex flex-col items-center justify-center gap-3",
        fullScreen ? "min-h-[60vh] w-full" : "py-10",
        className
      )}
      role="status"
      aria-live="polite"
    >
      <Lottie
        path="/animations/loading.json"
        loop
        autoplay
        style={{ width: size, height: size }}
      />
      {label && <p className="text-[13px] text-ink-soft">{label}</p>}
      <span className="sr-only">Loading</span>
    </div>
  );
}