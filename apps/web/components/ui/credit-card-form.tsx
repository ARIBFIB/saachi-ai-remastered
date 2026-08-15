"use client";

import React, { useEffect, useMemo, useState } from "react";
import { cn } from "@/lib/utils";

type CardState = {
  number: string;
  holder: string;
  month: string;
  year: string;
  cvv: string;
};

type CardValidity = {
  number: boolean;
  holder: boolean;
  month: boolean;
  year: boolean;
  cvv: boolean;
  allValid: boolean;
};

type Props = {
  defaultNumber?: string;
  defaultHolder?: string;
  defaultMonth?: string;
  defaultYear?: string;
  defaultCVV?: string;
  maskMiddle?: boolean;
  showSubmit?: boolean;
  submitLabel?: string;
  onChange?: (state: CardState, validity: CardValidity) => void;
  onSubmit?: (state: CardState, validity: CardValidity) => void;
  className?: string;
};

function formatNumberSpaces(num: string): string {
  return num.replace(/\s+/g, "").replace(/(\d{4})(?=\d)/g, "$1 ");
}

function clampDigits(value: string, maxLen: number) {
  return value.replace(/\D/g, "").slice(0, maxLen);
}

export function CreditCardForm({
  defaultNumber = "",
  defaultHolder = "",
  defaultMonth = "",
  defaultYear = "",
  defaultCVV = "",
  maskMiddle = true,
  showSubmit = true,
  submitLabel,
  onChange,
  onSubmit,
  className = "",
}: Props) {
  const [number, setNumber] = useState(clampDigits(defaultNumber, 19));
  const [holder, setHolder] = useState(defaultHolder.toUpperCase());
  const [month, setMonth] = useState(defaultMonth);
  const [year, setYear] = useState(defaultYear);
  const [cvv, setCVV] = useState(clampDigits(defaultCVV, 4));
  const [focusField, setFocusField] = useState<null | "number" | "holder" | "expire" | "cvv">(null);

  const flip = focusField === "cvv";
  const years = useMemo(() => {
    const start = new Date().getFullYear();
    return Array.from({ length: 10 }, (_, i) => String(start + i));
  }, []);

  const validity: CardValidity = useMemo(() => {
    const numberValid = number.length >= 13;
    const holderValid = holder.trim().length >= 2;
    const monthValid = !!month && +month >= 1 && +month <= 12;
    const yearValid = !!year && +year >= new Date().getFullYear();
    const cvvValid = /^\d{3,4}$/.test(cvv);
    return {
      number: numberValid,
      holder: holderValid,
      month: monthValid,
      year: yearValid,
      cvv: cvvValid,
      allValid: numberValid && holderValid && monthValid && yearValid && cvvValid,
    };
  }, [number, holder, month, year, cvv]);

  useEffect(() => {
    onChange?.({ number, holder, month, year, cvv }, validity);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [number, holder, month, year, cvv, validity]);

  const displayDigits = useMemo(() => number.slice(0, 16).split(""), [number]);

  const displayedSlots = useMemo(() => {
    const arr: { text: string; filled: boolean }[] = [];
    for (let i = 0; i < 16; i++) {
      let content = "#";
      if (i < displayDigits.length) {
        const d = displayDigits[i];
        const shouldMask = maskMiddle && i >= 4 && i <= 11;
        content = shouldMask ? "*" : d;
      }
      arr.push({ text: content, filled: i < displayDigits.length });
    }
    return arr;
  }, [displayDigits, maskMiddle]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    onSubmit?.({ number, holder, month, year, cvv }, validity);
  }

  return (
    <div className={cn("w-full", className)}>
      <div className="grid grid-cols-1 gap-8 md:grid-cols-2 md:items-start">
        {/* CARD PREVIEW */}
        <div
          className="relative mx-auto w-full max-w-[380px]"
          style={{ perspective: "1000px" }}
        >
          <div
            className="relative h-[210px] w-full transition-transform duration-700"
            style={{
              transformStyle: "preserve-3d",
              transform: flip ? "rotateY(180deg)" : "rotateY(0deg)",
            }}
          >
            {/* FRONT */}
            <div
              className="absolute inset-0 overflow-hidden rounded-card p-6"
              style={{
                backfaceVisibility: "hidden",
                backgroundImage: "var(--color-accent-gradient)",
              }}
            >
              <div className="pointer-events-none absolute -right-10 -top-10 h-40 w-40 rounded-full bg-white/10 blur-2xl" />
              <div className="pointer-events-none absolute -bottom-14 -left-10 h-40 w-40 rounded-full bg-black/10 blur-2xl" />

              <div className="relative flex items-center justify-between text-white">
                <span className="font-display text-[14px] font-semibold tracking-wide">
                  Saachi<span className="opacity-80">AI</span>
                </span>
                <span className="text-[11px] font-medium uppercase tracking-[0.08em] opacity-80">
                  Credit Card
                </span>
              </div>

              <div className="relative mt-8 flex gap-2 font-mono text-[19px] font-medium text-white">
                {displayedSlots.map((slot, idx) => (
                  <span
                    key={idx}
                    className={cn(
                      "inline-block w-[13px] text-center",
                      idx > 0 && idx % 4 === 0 && "ml-1.5"
                    )}
                  >
                    {slot.text}
                  </span>
                ))}
              </div>

              <div className="relative mt-8 flex items-end justify-between text-white">
                <div className="min-w-0">
                  <div className="text-[10px] font-medium uppercase tracking-[0.08em] opacity-70">
                    Card holder
                  </div>
                  <div className="mt-1 truncate text-[13.5px] font-semibold uppercase">
                    {holder || "NAME ON CARD"}
                  </div>
                </div>
                <div className="shrink-0 text-right">
                  <div className="text-[10px] font-medium uppercase tracking-[0.08em] opacity-70">
                    Expires
                  </div>
                  <div className="mt-1 text-[13.5px] font-semibold">
                    {month || "MM"}/{year ? year.slice(-2) : "YY"}
                  </div>
                </div>
              </div>
            </div>

            {/* BACK */}
            <div
              className="absolute inset-0 overflow-hidden rounded-card bg-ink"
              style={{
                backfaceVisibility: "hidden",
                transform: "rotateY(180deg)",
              }}
            >
              <div className="mt-6 h-10 w-full bg-black/60" />
              <div className="mt-6 flex flex-col items-end gap-1.5 px-6">
                <span className="text-[11px] font-semibold uppercase tracking-wide text-white/70">
                  CVV
                </span>
                <div className="flex h-10 w-full items-center justify-end rounded-control bg-white px-3 font-mono text-[18px] tracking-widest text-ink">
                  {"*".repeat(cvv.length)}
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* FORM */}
        <form onSubmit={handleSubmit} noValidate className="flex flex-col gap-4">
          <div className="flex flex-col gap-1.5">
            <label htmlFor="cc-number" className="text-[13px] font-semibold text-ink">
              Card number
            </label>
            <input
              id="cc-number"
              inputMode="numeric"
              autoComplete="cc-number"
              placeholder="1234 5678 9012 3456"
              value={formatNumberSpaces(number)}
              onChange={(e) => setNumber(clampDigits(e.target.value, 19))}
              onFocus={() => setFocusField("number")}
              onBlur={() => setFocusField(null)}
              aria-invalid={!validity.number}
              className={cn(
                "h-11 w-full rounded-control border border-line-strong bg-card px-3.5 text-[15px] text-ink outline-none transition-colors duration-150 ease-out placeholder:text-ink-soft/50 focus:border-gold",
                !validity.number && number.length >= 13 && "border-error focus:border-error"
              )}
            />
            {!validity.number && number.length >= 13 && (
              <p className="text-[13px] text-error">Card number looks invalid</p>
            )}
          </div>

          <div className="flex flex-col gap-1.5">
            <label htmlFor="cc-holder" className="text-[13px] font-semibold text-ink">
              Card holder
            </label>
            <input
              id="cc-holder"
              type="text"
              autoComplete="cc-name"
              placeholder="JANE DOE"
              value={holder}
              onChange={(e) => setHolder(e.target.value.toUpperCase())}
              onFocus={() => setFocusField("holder")}
              onBlur={() => setFocusField(null)}
              aria-invalid={!validity.holder}
              className="h-11 w-full rounded-control border border-line-strong bg-card px-3.5 text-[15px] text-ink outline-none transition-colors duration-150 ease-out placeholder:text-ink-soft/50 focus:border-gold"
            />
          </div>

          <div className="grid grid-cols-2 gap-4 sm:grid-cols-[2fr_1fr]">
            <div>
              <label className="mb-1.5 block text-[13px] font-semibold text-ink">
                Expiration date
              </label>
              <div className="grid grid-cols-2 gap-2">
                <select
                  value={month}
                  onChange={(e) => setMonth(e.target.value)}
                  onFocus={() => setFocusField("expire")}
                  onBlur={() => setFocusField(null)}
                  aria-invalid={!validity.month}
                  className="h-11 w-full rounded-control border border-line-strong bg-card px-3 text-[14px] text-ink outline-none transition-colors duration-150 ease-out focus:border-gold"
                >
                  <option value="" disabled>
                    Month
                  </option>
                  {Array.from({ length: 12 }, (_, i) => String(i + 1).padStart(2, "0")).map((m) => (
                    <option key={m} value={m}>
                      {m}
                    </option>
                  ))}
                </select>
                <select
                  value={year}
                  onChange={(e) => setYear(e.target.value)}
                  onFocus={() => setFocusField("expire")}
                  onBlur={() => setFocusField(null)}
                  aria-invalid={!validity.year}
                  className="h-11 w-full rounded-control border border-line-strong bg-card px-3 text-[14px] text-ink outline-none transition-colors duration-150 ease-out focus:border-gold"
                >
                  <option value="" disabled>
                    Year
                  </option>
                  {years.map((y) => (
                    <option key={y} value={y}>
                      {y}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            <div>
              <label htmlFor="cc-cvv" className="mb-1.5 block text-[13px] font-semibold text-ink">
                CVV
              </label>
              <input
                id="cc-cvv"
                inputMode="numeric"
                autoComplete="cc-csc"
                placeholder="***"
                value={cvv}
                onChange={(e) => setCVV(clampDigits(e.target.value, 4))}
                onFocus={() => setFocusField("cvv")}
                onBlur={() => setFocusField(null)}
                aria-invalid={!validity.cvv}
                className="h-11 w-full rounded-control border border-line-strong bg-card px-3.5 text-[15px] text-ink outline-none transition-colors duration-150 ease-out placeholder:text-ink-soft/50 focus:border-gold"
              />
            </div>
          </div>

          {showSubmit && (
            <button
              type="submit"
              disabled={!validity.allValid}
              className={cn(
                "mt-2 inline-flex h-12 w-full items-center justify-center rounded-full text-[15px] font-semibold text-white transition-transform duration-150 ease-out",
                validity.allValid ? "hover:brightness-110" : "cursor-not-allowed opacity-50"
              )}
              style={{ backgroundImage: "var(--color-accent-gradient)" }}
            >
              {submitLabel ?? (validity.allValid ? "Pay now" : "Complete all fields")}
            </button>
          )}
        </form>
      </div>
    </div>
  );
}

export type { CardState, CardValidity };
