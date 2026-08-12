"use client";

import { CreditCard as CreditCardIcon } from "lucide-react";

export type PaymentMethod = "card" | "paypal";

export interface CardDetails {
  number: string;
  expiry: string;
  cvc: string;
}

interface PaymentMethodCardProps {
  value: PaymentMethod;
  onChange: (method: PaymentMethod) => void;
  cardDetails: CardDetails;
  onCardDetailsChange: (details: CardDetails) => void;
}

export function PaymentMethodCard({
  value,
  onChange,
  cardDetails,
  onCardDetailsChange,
}: PaymentMethodCardProps) {
  function updateCard<K extends keyof CardDetails>(key: K, val: CardDetails[K]) {
    onCardDetailsChange({ ...cardDetails, [key]: val });
  }

  return (
    <section
      className="relative flex w-full flex-col gap-4 overflow-hidden rounded-xl border-2 bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]"
      style={{ borderColor: "var(--token-color-border)" }}
    >
      <div className="flex items-center gap-2">
        <CreditCardIcon size={18} color="var(--token-color-primary)" />
        <h2
          className="text-2xl font-semibold"
          style={{ color: "var(--token-color-ink)" }}
        >
          Payment Method
        </h2>
      </div>

      <div className="flex flex-col gap-4">
        {/* Credit Card option */}
        <div
          role="radio"
          aria-checked={value === "card"}
          tabIndex={0}
          onClick={() => onChange("card")}
          onKeyDown={(e) => e.key === "Enter" && onChange("card")}
          className={`flex cursor-pointer flex-col gap-4 rounded-lg p-4 transition ${
            value === "card"
              ? "bg-[var(--token-color-primary)]/5 outline outline-2 outline-offset-[-2px] outline-[var(--token-color-primary)]"
              : "bg-[var(--token-color-bg)] outline outline-1 outline-offset-[-1px] outline-[var(--token-color-border)]"
          }`}
        >
          <div className="flex items-start gap-4">
            <RadioDot selected={value === "card"} />
            <div className="flex flex-1 flex-col gap-4">
              <div className="flex items-center justify-between">
                <span
                  className="text-sm font-semibold tracking-wide"
                  style={{ color: "var(--token-color-ink)" }}
                >
                  Credit Card
                </span>
                <CreditCardIcon size={18} color="var(--token-color-inkSoft)" />
              </div>

              {value === "card" && (
                <div className="flex flex-col gap-3">
                  <input
                    type="text"
                    value={cardDetails.number}
                    onChange={(e) => updateCard("number", e.target.value)}
                    onClick={(e) => e.stopPropagation()}
                    placeholder="Card Number"
                    className="h-10 w-full rounded-lg border-2 bg-[var(--token-color-bg)] px-3 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:outline-none focus:border-[var(--token-color-primary)]"
                    style={{ borderColor: "var(--token-color-border)" }}
                  />
                  <div className="grid grid-cols-2 gap-3">
                    <input
                      type="text"
                      value={cardDetails.expiry}
                      onChange={(e) => updateCard("expiry", e.target.value)}
                      onClick={(e) => e.stopPropagation()}
                      placeholder="MM/YY"
                      className="h-10 w-full rounded-lg border-2 bg-[var(--token-color-bg)] px-3 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:outline-none focus:border-[var(--token-color-primary)]"
                      style={{ borderColor: "var(--token-color-border)" }}
                    />
                    <input
                      type="text"
                      value={cardDetails.cvc}
                      onChange={(e) => updateCard("cvc", e.target.value)}
                      onClick={(e) => e.stopPropagation()}
                      placeholder="CVC"
                      className="h-10 w-full rounded-lg border-2 bg-[var(--token-color-bg)] px-3 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:outline-none focus:border-[var(--token-color-primary)]"
                      style={{ borderColor: "var(--token-color-border)" }}
                    />
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>

        {/* PayPal option */}
        <div
          role="radio"
          aria-checked={value === "paypal"}
          tabIndex={0}
          onClick={() => onChange("paypal")}
          onKeyDown={(e) => e.key === "Enter" && onChange("paypal")}
          className={`flex cursor-pointer items-center gap-4 rounded-lg p-4 transition ${
            value === "paypal"
              ? "bg-[var(--token-color-primary)]/5 outline outline-2 outline-offset-[-2px] outline-[var(--token-color-primary)]"
              : "bg-[var(--token-color-bg)] outline outline-1 outline-offset-[-1px] outline-[var(--token-color-border)]"
          }`}
        >
          <RadioDot selected={value === "paypal"} />
          <div className="flex flex-1 items-center justify-between">
            <span
              className="text-sm font-semibold tracking-wide"
              style={{ color: "var(--token-color-ink)" }}
            >
              PayPal
            </span>
            <span
              className="text-xs font-medium"
              style={{ color: "var(--token-color-inkSoft)" }}
            >
              You will be redirected
            </span>
          </div>
        </div>
      </div>

      {/* Subtle decorative background element for trust */}
      <div className="pointer-events-none absolute -right-10 -top-10 h-40 w-40 rounded-full bg-[var(--token-color-primary)]/5 blur-xl" />
    </section>
  );
}

function RadioDot({ selected }: { selected: boolean }) {
  return (
    <span
      className="mt-0.5 flex h-4 w-4 shrink-0 items-center justify-center rounded-full border-2"
      style={{
        borderColor: selected
          ? "var(--token-color-primary)"
          : "var(--token-color-border)",
        backgroundColor: selected ? "var(--token-color-primary)" : "transparent",
      }}
    >
      {selected && <span className="h-1.5 w-1.5 rounded-full bg-white" />}
    </span>
  );
}
