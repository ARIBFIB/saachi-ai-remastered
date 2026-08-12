"use client";

import { useState } from "react";
import { Button, Input } from "antd";
import { ArrowRight } from "lucide-react";

interface OrderSummaryProps {
  subtotal: number;
  /** Decimal tax rate, e.g. 0.08 for 8%. Swap for a real quote from the
   * checkout/tax API once available -- kept as a prop so it's never
   * hardcoded inside this component. */
  taxRate?: number;
}

export function OrderSummary({ subtotal, taxRate = 0.08 }: OrderSummaryProps) {
  const [coupon, setCoupon] = useState("");
  const tax = subtotal * taxRate;
  const total = subtotal + tax;

  function handleApplyCoupon() {
    // TODO: wire to coupon validation API (packages/api-client)
    console.log("apply coupon", coupon);
  }

  function handleCheckout() {
    // TODO: wire to checkout flow (packages/api-client)
    console.log("proceed to checkout");
  }

  return (
    <div
      className="flex flex-col gap-1.5 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
      style={{ borderColor: "var(--token-color-border)" }}
    >
      <div className="border-b pb-2" style={{ borderColor: "var(--token-color-border)" }}>
        <h2 className="text-2xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
          Order Summary
        </h2>
      </div>

      <div className="flex items-center justify-between pb-2 pt-4">
        <span style={{ color: "var(--token-color-inkSoft)" }}>Subtotal</span>
        <span className="font-semibold" style={{ color: "var(--token-color-ink)" }}>
          ${subtotal.toFixed(2)}
        </span>
      </div>

      <div
        className="flex items-center justify-between border-b pb-4"
        style={{ borderColor: "var(--token-color-border)" }}
      >
        <span style={{ color: "var(--token-color-inkSoft)" }}>Estimated Tax</span>
        <span className="font-semibold" style={{ color: "var(--token-color-ink)" }}>
          ${tax.toFixed(2)}
        </span>
      </div>

      <div className="flex items-center justify-between pt-4">
        <span className="text-lg font-bold" style={{ color: "var(--token-color-ink)" }}>
          Total
        </span>
        <span className="text-3xl font-black" style={{ color: "var(--token-color-primary)" }}>
          ${total.toFixed(2)}
        </span>
      </div>

      <div className="flex flex-col gap-2 py-4">
        <label
          className="text-sm font-semibold tracking-wide"
          style={{ color: "var(--token-color-inkSoft)" }}
        >
          Gift Card or Discount Code
        </label>
        <div className="flex gap-2">
          <Input
            value={coupon}
            onChange={(e) => setCoupon(e.target.value)}
            placeholder="Enter code"
            size="large"
          />
          <Button size="large" onClick={handleApplyCoupon}>
            Apply
          </Button>
        </div>
      </div>

      <Button
        type="primary"
        block
        size="large"
        icon={<ArrowRight size={12} />}
        iconPosition="end"
        onClick={handleCheckout}
      >
        Proceed to Checkout
      </Button>

      <p
        className="pt-2 text-center text-xs font-medium"
        style={{ color: "var(--token-color-inkSoft)" }}
      >
        30-Day Money-Back Guarantee
      </p>
    </div>
  );
}
