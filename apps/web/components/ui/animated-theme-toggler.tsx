"use client";

import { useCallback, useRef } from "react";
import { flushSync } from "react-dom";
import { Moon, Sun } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import { useThemeStore } from "@saachi/store";
import { cn } from "@/lib/utils";

type AnimatedThemeTogglerProps = {
  className?: string;
};

export function AnimatedThemeToggler({ className }: AnimatedThemeTogglerProps) {
  const buttonRef = useRef<HTMLButtonElement>(null);
  const theme = useThemeStore((s) => s.theme);
  const setTheme = useThemeStore((s) => s.setTheme);
  const isDark = theme === "dark";

  const onToggle = useCallback(async () => {
    if (!buttonRef.current) return;

    const next = isDark ? "light" : "dark";

    const supportsViewTransition =
      typeof document !== "undefined" && "startViewTransition" in document;

    if (!supportsViewTransition) {
      setTheme(next);
      return;
    }

    const transition = (
      document as unknown as {
        startViewTransition: (callback: () => void) => { ready: Promise<void> };
      }
    ).startViewTransition(() => {
      flushSync(() => {
        setTheme(next);
      });
    });

    await transition.ready;

    const { left, top, width, height } = buttonRef.current.getBoundingClientRect();
    const centerX = left + width / 2;
    const centerY = top + height / 2;
    const maxDistance = Math.hypot(
      Math.max(centerX, window.innerWidth - centerX),
      Math.max(centerY, window.innerHeight - centerY)
    );

    document.documentElement.animate(
      {
        clipPath: [
          `circle(0px at ${centerX}px ${centerY}px)`,
          `circle(${maxDistance}px at ${centerX}px ${centerY}px)`
        ]
      },
      {
        duration: 700,
        easing: "ease-in-out",
        pseudoElement: "::view-transition-new(root)"
      }
    );
  }, [isDark, setTheme]);

  return (
    <button
      ref={buttonRef}
      onClick={onToggle}
      aria-label={isDark ? "Switch to light mode" : "Switch to dark mode"}
      type="button"
      className={cn(
        "flex h-9 w-9 shrink-0 items-center justify-center rounded-control border border-line text-ink outline-none transition-colors duration-150 ease-out hover:bg-paper-dim focus:outline-none focus:ring-0",
        className
      )}
    >
      <AnimatePresence mode="wait" initial={false}>
        {isDark ? (
          <motion.span
            key="sun-icon"
            initial={{ opacity: 0, scale: 0.55, rotate: 25 }}
            animate={{ opacity: 1, scale: 1, rotate: 0 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.33 }}
            className="flex items-center justify-center"
          >
            <Sun size={16} strokeWidth={1.75} />
          </motion.span>
        ) : (
          <motion.span
            key="moon-icon"
            initial={{ opacity: 0, scale: 0.55, rotate: -25 }}
            animate={{ opacity: 1, scale: 1, rotate: 0 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.33 }}
            className="flex items-center justify-center"
          >
            <Moon size={16} strokeWidth={1.75} />
          </motion.span>
        )}
      </AnimatePresence>
    </button>
  );
}
