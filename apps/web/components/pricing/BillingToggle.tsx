"use client";

import { useState } from "react";

export type BillingCycle = "monthly" | "annually";

interface BillingToggleProps {
  onChange?: (cycle: BillingCycle) => void;
}

export function BillingToggle({ onChange }: BillingToggleProps) {
  const [cycle, setCycle] = useState<BillingCycle>("monthly");

  function toggle() {
    const next = cycle === "monthly" ? "annually" : "monthly";
    setCycle(next);
    onChange?.(next);
  }

  const isAnnual = cycle === "annually";

  return (
    <div className="flex items-center justify-center gap-4 pt-4">
      <span className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">Monthly</span>

      <button
        type="button"
        role="switch"
        aria-checked={isAnnual}
        onClick={toggle}
        className={`relative h-6 w-11 shrink-0 rounded-full transition ${
          isAnnual ? "bg-[var(--token-color-primary)]" : "bg-[var(--token-color-border)]"
        }`}
      >
        <span
          className={`absolute top-0.5 h-5 w-5 rounded-full bg-[var(--token-color-surface)] shadow transition-transform ${
            isAnnual ? "translate-x-[22px]" : "translate-x-0.5"
          }`}
        />
      </button>

      <span className="flex items-end gap-1 pb-px">
        <span className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">Annually</span>
        <span className="text-xs font-bold tracking-wide text-[var(--token-color-primary)]">(Save 20%)</span>
      </span>
    </div>
  );
}