"use client";

import { useEffect, useState } from "react";
import { Sun, Moon } from "lucide-react";
import { useThemeStore } from "@saachi/store";
import { cn } from "../cn";

export function ThemeToggle({ className }: { className?: string }) {
  const { theme, toggleTheme } = useThemeStore();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  useEffect(() => {
    if (!mounted) return;
    document.documentElement.setAttribute("data-theme", theme);
  }, [theme, mounted]);

  if (!mounted) {
    return <div className={cn("h-9 w-9 shrink-0 rounded-control", className)} />;
  }

  return (
    <button
      type="button"
      onClick={toggleTheme}
      aria-label={theme === "light" ? "Switch to dark mode" : "Switch to light mode"}
      className={cn(
        "flex h-9 w-9 shrink-0 items-center justify-center rounded-control border border-line text-ink transition-colors duration-150 ease-out hover:bg-paper-dim",
        className
      )}
    >
      {theme === "light" ? <Moon size={16} strokeWidth={1.75} /> : <Sun size={16} strokeWidth={1.75} />}
    </button>
  );
}