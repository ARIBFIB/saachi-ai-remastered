"use client";

import { useState } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { RotateCw } from "lucide-react";

type RefreshButtonProps = {
  className?: string;
  title?: string;
};

export function RefreshButton({ className = "", title = "Refresh" }: RefreshButtonProps) {
  const queryClient = useQueryClient();
  const [spinning, setSpinning] = useState(false);

  const handleRefresh = async () => {
    if (spinning) return;
    setSpinning(true);
    await queryClient.invalidateQueries();
    window.setTimeout(() => setSpinning(false), 500);
  };

  return (
    <button
      type="button"
      onClick={handleRefresh}
      title={title}
      aria-label={title}
      className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-control border border-line text-ink-soft transition-colors duration-150 ease-out hover:border-line-strong hover:text-ink ${className}`}
    >
      <RotateCw size={15} strokeWidth={1.75} className={spinning ? "animate-spin" : ""} />
    </button>
  );
}