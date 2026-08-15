<#
.SYNOPSIS
    Adds a themed credit-card payment form component and wires it into
    apps/web/app/(learner)/checkout/page.tsx for the Saachi AI web app.

.DESCRIPTION
    Run this from the SAI2 project root (same folder as pnpm-workspace.yaml).
    It will:
      1. Create apps/web/components/ui/credit-card-form.tsx
         (Tailwind + design-token version of the shared card component)
      2. Create/overwrite apps/web/app/(learner)/checkout/page.tsx
         wired to useCartStore + useOrderStore, redirecting to
         /orders?success=ORDER_ID on submit.
      3. Back up any existing checkout/page.tsx first (timestamped .bak).

.NOTES
    This is UI-only. No real payment gateway (Stripe/PayPal/Easypaisa/
    JazzCash) is wired up - card details are validated client-side only
    and never sent anywhere. Wire a real gateway before going live.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# 0. Locate project root / target paths
# ---------------------------------------------------------------------------
$root = Get-Location
$webApp = Join-Path $root "apps\web"

if (-not (Test-Path (Join-Path $root "pnpm-workspace.yaml"))) {
    Write-Warning "pnpm-workspace.yaml not found in current directory."
    Write-Warning "Please run this script from the SAI2 project root."
    exit 1
}

if (-not (Test-Path $webApp)) {
    Write-Error "Could not find apps\web - are you in the right folder?"
    exit 1
}

$componentsUiDir = Join-Path $webApp "components\ui"
$checkoutDir     = Join-Path $webApp "app\(learner)\checkout"

New-Item -ItemType Directory -Force -Path $componentsUiDir | Out-Null
New-Item -ItemType Directory -Force -Path $checkoutDir     | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ---------------------------------------------------------------------------
# 1. credit-card-form.tsx  (Tailwind + design-token version)
# ---------------------------------------------------------------------------
$cardFormPath = Join-Path $componentsUiDir "credit-card-form.tsx"

$cardFormContent = @'
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
'@

if (Test-Path $cardFormPath) {
    $backup = "$cardFormPath.bak-$timestamp"
    Copy-Item $cardFormPath $backup
    Write-Host "Backed up existing credit-card-form.tsx -> $backup" -ForegroundColor Yellow
}

Set-Content -Path $cardFormPath -Value $cardFormContent -Encoding UTF8
Write-Host "Created: $cardFormPath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2. checkout/page.tsx
# ---------------------------------------------------------------------------
$checkoutPagePath = Join-Path $checkoutDir "page.tsx"

$checkoutPageContent = @'
"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { ShieldCheck, Lock } from "lucide-react";
import { useCartStore } from "@saachi/store";
import { useOrderStore } from "@saachi/store";
import { Button, EmptyState } from "@saachi/ui";
import { CreditCardForm, type CardState, type CardValidity } from "@/components/ui/credit-card-form";

export default function CheckoutPage() {
  const router = useRouter();

  const items = useCartStore((s) => s.items);
  const coupon = useCartStore((s) => s.coupon);
  const subtotal = useCartStore((s) => s.subtotal());
  const discount = useCartStore((s) => s.discount());
  const total = useCartStore((s) => s.total());
  const clearCart = useCartStore((s) => s.clear);

  const addOrder = useOrderStore((s) => s.addOrder);

  const [validity, setValidity] = useState<CardValidity | null>(null);
  const [processing, setProcessing] = useState(false);

  const currency = items[0]?.currency ?? "USD";
  const fmt = (n: number) =>
    new Intl.NumberFormat("en-US", { style: "currency", currency }).format(n);

  const canPay = useMemo(() => items.length > 0 && validity?.allValid, [items, validity]);

  function handleCardChange(_state: CardState, v: CardValidity) {
    setValidity(v);
  }

  function handleCardSubmit(_state: CardState, v: CardValidity) {
    if (!v.allValid || items.length === 0 || processing) return;

    setProcessing(true);

    // NOTE: demo-only. No real payment gateway is wired up here.
    // Card details never leave the browser - swap this block for a real
    // gateway call (Stripe/PayPal/Easypaisa/JazzCash) before going live.
    setTimeout(() => {
      const order = addOrder({
        items: items.map((i) => ({ courseId: i.courseId, title: i.title, price: i.price })),
        subtotal,
        discount,
        total,
        currency,
        paymentMethod: "card"
      });

      clearCart();
      setProcessing(false);
      router.push(`/orders?success=${order.id}`);
    }, 900);
  }

  if (items.length === 0) {
    return (
      <div className="mx-auto max-w-lg px-4 py-20 md:px-0">
        <EmptyState
          title="Your cart is empty"
          description="Add a course to your cart before checking out."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-6xl px-4 py-12 md:px-8">
      <h1 className="mb-2 font-display text-[26px] font-bold text-ink">Checkout</h1>
      <p className="mb-8 flex items-center gap-1.5 text-[13.5px] text-ink-soft">
        <Lock size={13} />
        Secure checkout - your card details never leave your browser in this demo.
      </p>

      <div className="grid grid-cols-1 gap-8 md:grid-cols-[1fr_320px]">
        <div className="rounded-card border border-line bg-card p-6 md:p-8">
          <CreditCardForm
            onChange={handleCardChange}
            onSubmit={handleCardSubmit}
            submitLabel={processing ? "Processing..." : `Pay ${fmt(total)}`}
          />
        </div>

        <aside className="h-fit rounded-card border border-line bg-card p-6">
          <h2 className="mb-4 text-[15px] font-semibold text-ink">Order summary</h2>

          <div className="mb-4 flex flex-col gap-3">
            {items.map((item) => (
              <div key={item.courseId} className="flex items-center justify-between gap-3 text-[13.5px]">
                <span className="min-w-0 truncate text-ink">{item.title}</span>
                <span className="shrink-0 font-mono text-ink-soft">
                  {new Intl.NumberFormat("en-US", { style: "currency", currency: item.currency }).format(item.price)}
                </span>
              </div>
            ))}
          </div>

          {coupon && (
            <div className="mb-4 rounded-control bg-gold-tint px-3 py-2 text-[13px] font-semibold text-gold-dark">
              {coupon.code} applied (-{coupon.percentOff}%)
            </div>
          )}

          <div className="flex flex-col gap-2 border-t border-line pt-4 text-[14px]">
            <div className="flex justify-between text-ink-soft">
              <span>Subtotal</span>
              <span>{fmt(subtotal)}</span>
            </div>
            {discount > 0 && (
              <div className="flex justify-between text-teal">
                <span>Discount</span>
                <span>-{fmt(discount)}</span>
              </div>
            )}
            <div className="mt-2 flex justify-between border-t border-line pt-2 text-[16px] font-semibold text-ink">
              <span>Total</span>
              <span>{fmt(total)}</span>
            </div>
          </div>

          <div className="mt-6 flex items-center gap-2 text-[12px] text-ink-soft">
            <ShieldCheck size={14} className="shrink-0 text-teal" />
            7-day refund window on all courses.
          </div>

          {!canPay && (
            <p className="mt-4 text-[12.5px] text-ink-soft">
              Fill in valid card details on the left to enable payment.
            </p>
          )}
        </aside>
      </div>
    </div>
  );
}
'@

if (Test-Path $checkoutPagePath) {
    $backup = "$checkoutPagePath.bak-$timestamp"
    Copy-Item $checkoutPagePath $backup
    Write-Host "Backed up existing checkout/page.tsx -> $backup" -ForegroundColor Yellow
}

Set-Content -Path $checkoutPagePath -Value $checkoutPageContent -Encoding UTF8
Write-Host "Created: $checkoutPagePath" -ForegroundColor Green

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd apps\web"
Write-Host "  2. pnpm dev  (or npm run dev)"
Write-Host "  3. Add a course to your cart, then visit /checkout"
Write-Host ""
Write-Host "Reminder: this wires a UI-only card form. No real gateway (Stripe/" -ForegroundColor Yellow
Write-Host "PayPal/Easypaisa/JazzCash) is connected - card data never leaves the browser." -ForegroundColor Yellow