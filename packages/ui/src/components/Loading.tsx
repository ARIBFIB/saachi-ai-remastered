"use client";

import Lottie from "lottie-react";
import { useEffect, useState } from "react";
import { cn } from "../cn";

export type LoadingProps = {
  size?: number;
  label?: string;
  fullScreen?: boolean;
  className?: string;
};

export function Loading({ size = 120, label, fullScreen = false, className }: LoadingProps) {
  const [animationData, setAnimationData] = useState<object | null>(null);

  useEffect(() => {
    let cancelled = false;
    fetch("/animations/loading.json")
      .then((res) => res.json())
      .then((data) => {
        if (!cancelled) setAnimationData(data);
      })
      .catch(() => {
        // Silently ignore â€” falls back to just showing the label below.
      });
    return () => {
      cancelled = true;
    };
  }, []);

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
      {animationData ? (
        <Lottie animationData={animationData} loop autoplay style={{ width: size, height: size }} />
      ) : (
        <div
          className="animate-pulse rounded-full border-2 border-line-strong border-t-gold"
          style={{ width: size / 2, height: size / 2 }}
        />
      )}
      {label && <p className="text-[13px] text-ink-soft">{label}</p>}
      <span className="sr-only">Loading</span>
    </div>
  );
}