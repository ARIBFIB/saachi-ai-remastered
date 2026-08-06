"use client";

import { type ReactNode, useEffect } from "react";
import { X } from "lucide-react";
import { cn } from "../cn";

export type ModalProps = {
  open: boolean;
  onClose: () => void;
  title?: string;
  children: ReactNode;
  footer?: ReactNode;
  size?: "md" | "lg";
};

export function Modal({ open, onClose, title, children, footer, size = "md" }: ModalProps) {
  useEffect(() => {
    if (!open) return;
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", onKeyDown);
    return () => document.removeEventListener("keydown", onKeyDown);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4"
      role="dialog"
      aria-modal="true"
    >
      <div
        className="absolute inset-0 bg-[rgba(11,17,32,0.5)] backdrop-blur-[4px]"
        onClick={onClose}
      />
      <div
        className={cn(
          "relative w-full rounded-[24px] bg-[var(--surface-overlay,var(--surface-card,#FFFFFF))] p-6 shadow-[0_24px_64px_rgba(30,64,175,0.18)]",
          "animate-[modal-in_220ms_cubic-bezier(0.16,1,0.3,1)]",
          size === "lg" ? "max-w-[720px]" : "max-w-[520px]"
        )}
      >
        {title && (
          <div className="mb-4 flex items-center justify-between">
            <h2 className="text-[20px] font-semibold text-[var(--text-primary,#0F172A)]">{title}</h2>
            <button
              onClick={onClose}
              aria-label="Close"
              className="flex h-9 w-9 items-center justify-center rounded-full text-[var(--text-secondary,#475569)] transition-colors hover:bg-[var(--surface-elevated,#F1F5F9)]"
            >
              <X size={18} />
            </button>
          </div>
        )}
        <div>{children}</div>
        {footer && (
          <div className="mt-6 flex justify-end gap-3">{footer}</div>
        )}
      </div>
    </div>
  );
}
