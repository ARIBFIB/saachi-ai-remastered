"use client";

import Image from "next/image";
import { Lock, ShieldCheck } from "lucide-react";

export interface CheckoutItem {
  id: string;
  title: string;
  subtitle: string;
  price: number;
  image: string;
}

interface CheckoutOrderSummaryProps {
  items: CheckoutItem[];
  subtotal: number;
  onCompletePurchase: () => void;
}

export function CheckoutOrderSummary({
  items,
  subtotal,
  onCompletePurchase,
}: CheckoutOrderSummaryProps) {
  return (
    <div
      className="flex flex-col gap-1.5 rounded-[var(--token-radius-lg)] border-2 bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
      style={{ borderColor: "var(--token-color-inkDeep)", borderWidth: "2px", borderStyle: "solid" }}
    >
      <h2
        className="text-2xl font-semibold"
        style={{ color: "var(--token-color-ink)" }}
      >
        Order Summary
      </h2>

      <div className="flex flex-col gap-4 py-2">
        {items.map((item) => (
          <div key={item.id} className="flex items-start gap-4">
            <div className="relative h-16 w-16 shrink-0 overflow-hidden rounded-[var(--token-radius-md)] bg-[var(--token-color-surfaceAlt)]">
              <Image
                src={item.image}
                alt={item.title}
                fill
                sizes="64px"
                className="object-cover"
              />
            </div>

            <div className="flex flex-1 flex-col gap-0.5">
              <h3
                className="text-sm font-semibold leading-tight tracking-wide"
                style={{ color: "var(--token-color-ink)" }}
              >
                {item.title}
              </h3>
              <span
                className="text-xs font-medium"
                style={{ color: "var(--token-color-inkSoft)" }}
              >
                {item.subtitle}
              </span>
            </div>

            <span
              className="shrink-0 text-sm font-semibold tracking-wide"
              style={{ color: "var(--token-color-ink)" }}
            >
              ${item.price.toFixed(2)}
            </span>
          </div>
        ))}
      </div>

      <div className="h-px" style={{ backgroundColor: "var(--token-color-border)" }} />

      <div className="flex flex-col gap-2 py-2">
        <div className="flex items-center justify-between">
          <span style={{ color: "var(--token-color-inkSoft)" }}>Subtotal</span>
          <span style={{ color: "var(--token-color-inkSoft)" }}>
            ${subtotal.toFixed(2)}
          </span>
        </div>
        <div className="flex items-center justify-between">
          <span style={{ color: "var(--token-color-inkSoft)" }}>
            Tax (Calculated at next step)
          </span>
          <span style={{ color: "var(--token-color-inkSoft)" }}>--</span>
        </div>
      </div>

      <div className="h-px" style={{ backgroundColor: "var(--token-color-border)" }} />

      <div className="flex items-end justify-between py-6">
        <span
          className="text-2xl font-semibold"
          style={{ color: "var(--token-color-ink)" }}
        >
          Total
        </span>
        <span
          className="text-5xl font-bold leading-none"
          style={{ color: "var(--token-color-amber)" }}
        >
          ${subtotal.toFixed(2)}
        </span>
      </div>

      <button
        type="button"
        onClick={onCompletePurchase}
        className="flex h-11 items-center justify-center gap-2 rounded-[var(--token-radius-md)] text-sm font-semibold tracking-wide text-white shadow-[var(--token-shadow-sm)]"
        style={{ backgroundColor: "var(--token-color-amber)" }}
      >
        <Lock size={14} />
        Complete Purchase
      </button>

      <div className="flex items-center justify-center gap-1 pt-2">
        <ShieldCheck size={14} color="var(--token-color-inkSoft)" />
        <span
          className="text-xs font-medium"
          style={{ color: "var(--token-color-inkSoft)" }}
        >
          Payments are securely processed.
        </span>
      </div>
    </div>
  );
}
