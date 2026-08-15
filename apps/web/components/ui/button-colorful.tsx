"use client";

import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { ArrowUpRight } from "lucide-react";

interface ButtonColorfulProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  label?: string;
}

export function ButtonColorful({
  className,
  label = "Explore",
  ...props
}: ButtonColorfulProps) {
  return (
    <Button
      className={cn(
        "relative h-9 px-3.5 overflow-hidden",
        "bg-zinc-900 dark:bg-zinc-100",
        "transition-all duration-200",
        "group/btn",
        className
      )}
      {...props}
    >
      <div
        className={cn(
          "absolute inset-0",
          "bg-gradient-to-r from-indigo-500 via-purple-500 to-pink-500",
          "opacity-50 group-hover/btn:opacity-90",
          "blur transition-opacity duration-500"
        )}
      />
      <div className="relative flex items-center justify-center gap-1.5">
        <span className="text-[12.5px] font-semibold text-white dark:text-zinc-900">{label}</span>
        <ArrowUpRight className="h-3.5 w-3.5 text-white/90 dark:text-zinc-900/90" />
      </div>
    </Button>
  );
}

export default ButtonColorful;