#Requires -Version 5.1
<#
.SYNOPSIS
    Adds the ORIGINAL (exact design) credit-card payment form component,
    wires it into the checkout page, and repoints pricing "Start Pro" /
    "Start Your Journey" / "Claim This Offer" buttons to the checkout flow.

.DESCRIPTION
    Run this from the SAI2 project root (same folder as pnpm-workspace.yaml).

    It will:
      1. Create apps/web/components/ui/credit-card-form.tsx
         - EXACT copy of the design you shared (styled-jsx, dark gradient
           card, mastercard logo, purple/blue glow rings, white form).
      2. Create/overwrite apps/web/app/(learner)/checkout/page.tsx
         wired to useCartStore + useOrderStore.
      3. Update pricing CTA buttons so they point to /checkout instead of
         /register in:
           - apps/web/app/(marketing)/_components/PricingTeaser.tsx
           - apps/web/app/(marketing)/pricing/page.tsx
           - apps/web/components/ui/limited-time-offer-pricing.tsx
      All existing files are backed up first (timestamped .bak).

.NOTES
    UI-only. No real payment gateway is wired up - card details never
    leave the browser. Wire a real gateway (Stripe/PayPal/Easypaisa/
    JazzCash) before going live.
#>

[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

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

$componentsUiDir  = Join-Path $webApp "components\ui"
$checkoutDir      = Join-Path $webApp "app\(learner)\checkout"
$marketingCompDir = Join-Path $webApp "app\(marketing)\_components"

New-Item -ItemType Directory -Force -Path $componentsUiDir | Out-Null
New-Item -ItemType Directory -Force -Path $checkoutDir     | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Backup-IfExists($path) {
    if (Test-Path $path) {
        $backup = "$path.bak-$timestamp"
        Copy-Item $path $backup
        Write-Host "Backed up -> $backup" -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------------------
# 1. credit-card-form.tsx  (EXACT original design, styled-jsx)
# ---------------------------------------------------------------------------
$cardFormPath = Join-Path $componentsUiDir "credit-card-form.tsx"

$cardFormContent = @'
"use client";

import React, { useEffect, useMemo, useState } from "react";

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
  ring1?: string;
  ring2?: string;
  showSubmit?: boolean;
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

const CreditCardForm = ({
  defaultNumber = "",
  defaultHolder = "",
  defaultMonth = "",
  defaultYear = "",
  defaultCVV = "",
  maskMiddle = true,
  ring1 = "#ff6be7",
  ring2 = "#7288ff",
  showSubmit = true,
  onChange,
  onSubmit,
  className = "",
}: Props) => {
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
  }, [number, holder, month, year, cvv, validity, onChange]);

  const displayDigits = useMemo(() => number.slice(0, 16).split(""), [number]);

  const displayedSlots = useMemo(() => {
    const arr: { textTop: string; filed: boolean }[] = [];
    for (let i = 0; i < 16; i++) {
      let content = "#";
      if (i < displayDigits.length) {
        const d = displayDigits[i];
        const shouldMask = maskMiddle && i >= 4 && i <= 11;
        content = shouldMask ? "*" : d;
      }
      arr.push({ textTop: content, filed: i < displayDigits.length });
    }
    return arr;
  }, [displayDigits, maskMiddle]);

  const highlightClass = (() => {
    switch (focusField) {
      case "number":
        return "highlight__number";
      case "holder":
        return "highlight__holder";
      case "expire":
        return "highlight__expire";
      case "cvv":
        return "highlight__cvv";
      default:
        return "hidden";
    }
  })();

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSubmit?.({ number, holder, month, year, cvv }, validity);
  };

  return (
    <section className={`ccp ${className}`}>
      <div className="wrap">
        <section id="card" className={`card ${flip ? "flip" : ""}`}>
          <div id="highlight" className={highlightClass} />

          <section className="card__front" style={{ ["--ring1" as any]: ring1, ["--ring2" as any]: ring2 }}>
            <div className="card__header">
              <div>CreditCard</div>
              <svg xmlns="http://www.w3.org/2000/svg" height="40" width="60" viewBox="-96 -98.908 832 593.448">
                <path fill="#ff5f00" d="M224.833 42.298h190.416v311.005H224.833z" />
                <path
                  d="M244.446 197.828a197.448 197.448 0 0175.54-155.475 197.777 197.777 0 100 311.004 197.448 197.448 0 01-75.54-155.53z"
                  fill="#eb001b"
                />
                <path
                  d="M621.101 320.394v-6.372h2.747v-1.319h-6.537v1.319h2.582v6.373zm12.691 0v-7.69h-1.978l-2.307 5.493-2.308-5.494h-1.977v7.691h1.428v-5.823l2.143 5h1.483l2.143-5v5.823z"
                  fill="#f79e1b"
                />
                <path
                  d="M640 197.828a197.777 197.777 0 01-320.015 155.474 197.777 197.777 0 000-311.004A197.777 197.777 0 01640 197.773z"
                  fill="#f79e1b"
                />
              </svg>
            </div>

          <div id="card_number" className="card__number" aria-label="Card number">
            {displayedSlots.map((slot, idx) => (
              <span key={idx} className="slot">
                <span className={`digit ${slot.filed ? "filed" : ""}`}>
                  <span className="row placeholder">#</span>
                  <span className="row value">{slot.textTop}</span>
                </span>
              </span>
            ))}
           </div>

            <div className="card__footer">
              <div className="card__holder">
                <div className="card__section__title">Card Holder</div>
                <div id="card_holder">{holder || "NAME ON CARD"}</div>
              </div>
              <div className="card__expires">
                <div className="card__section__title">Expires</div>
                <span id="card_expires_month">{month || "MM"}</span>/
                <span id="card_expires_year">{year ? year.slice(-2) : "YY"}</span>
              </div>
            </div>
          </section>

          <section className="card__back" style={{ ["--ring1" as any]: ring1, ["--ring2" as any]: ring2 }}>
            <div className="card__hide_line" />
            <div className="card_cvv">
              <span>CVV</span>
              <div id="card_cvv_field" className="card_cvv_field">
                {"*".repeat(cvv.length)}
              </div>
            </div>
          </section>
        </section>

        <form className="form" onSubmit={handleSubmit} noValidate>
          <div>
            <label htmlFor="number">Card Number</label>
            <input
              id="number"
              inputMode="numeric"
              autoComplete="cc-number"
              placeholder="1234 5678 9012 3456"
              value={formatNumberSpaces(number)}
              onChange={(e) => setNumber(clampDigits(e.target.value, 19))}
              onFocus={() => setFocusField("number")}
              onBlur={() => setFocusField(null)}
              aria-invalid={!validity.number}
            />
            {!validity.number && number.length >= 13 && (
              <small className="err">Card number looks invalid</small>
            )}
          </div>

          <div>
            <label htmlFor="holder">Card Holder</label>
            <input
              id="holder"
              type="text"
              autoComplete="cc-name"
              placeholder="JANE DOE"
              value={holder}
              onChange={(e) => setHolder(e.target.value.toUpperCase())}
              onFocus={() => setFocusField("holder")}
              onBlur={() => setFocusField(null)}
              aria-invalid={!validity.holder}
            />
          </div>

          <div className="filed__group">
            <div>
              <label>Expiration Date</label>
              <div className="filed__date">
                <select
                  id="expiration_month"
                  value={month || ""}
                  onChange={(e) => setMonth(e.target.value)}
                  onFocus={() => setFocusField("expire")}
                  onBlur={() => setFocusField(null)}
                  aria-invalid={!validity.month}
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
                  id="expiration_year"
                  value={year || ""}
                  onChange={(e) => setYear(e.target.value)}
                  onFocus={() => setFocusField("expire")}
                  onBlur={() => setFocusField(null)}
                  aria-invalid={!validity.year}
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
              <label htmlFor="cvv">CVV</label>
              <input
                id="cvv"
                inputMode="numeric"
                autoComplete="cc-csc"
                placeholder="***"
                value={cvv}
                onChange={(e) => setCVV(clampDigits(e.target.value, 4))}
                onFocus={() => setFocusField("cvv")}
                onBlur={() => setFocusField(null)}
                aria-invalid={!validity.cvv}
              />
            </div>
          </div>

          {showSubmit && (
            <button className="submit" type="submit" disabled={!validity.allValid} aria-disabled={!validity.allValid}>
              {validity.allValid ? "Submit" : "Complete all fields"}
            </button>
          )}
        </form>
      </div>

      <style jsx>{`
        .ccp {
          width: 100%;
          display: flex;
          justify-content: center;
          padding: 24px;
          background: transparent;
          color: #0d0c22;
        }
        .wrap {
          width: 100%;
          max-width: 1000px;
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 24px;
          align-items: start;
        }

        @media (max-width: 920px) {
          .wrap {
            grid-template-columns: 1fr;
          }
        }

        * {
          box-sizing: border-box;
        }

        #highlight {
          position: absolute;
          border: 1px solid #fff;
          border-radius: 12px;
          z-index: 1;
          width: 0;
          height: 0;
          top: 0;
          left: 0;
          box-shadow: 0 0 5px #fff;
          transition: 0.3s;
        }
        #highlight.highlight__number {
          width: 346px;
          height: 40px;
          top: 92px;
          left: 18px;
        }
        #highlight.highlight__holder {
          width: 264px;
          height: 56px;
          top: 156px;
          left: 18px;
        }
        #highlight.highlight__expire {
          width: 86px;
          height: 56px;
          top: 156px;
          left: 323px;
        }
        #highlight.highlight__cvv {
          width: 381px;
          height: 91px;
          top: 83px;
          left: 18px;
        }
        #highlight.hidden {
          display: none;
        }

        .card {
          position: relative;
          width: 100%;
          max-width: 420px;
          margin: 0 auto;
          transform-style: preserve-3d;
          transition: 0.8s;
          perspective: 1000px;
        }
        .card.flip {
          transform: rotateY(180deg);
        }

        .card__front,
        .card__back {
          width: 100%;
          max-width: 420px;
          height: 233px;
          border-radius: 20px;
          padding: 24px 30px 30px;
          background: linear-gradient(to right bottom, #323941, #061018);
          box-shadow: 0 33px 50px -15px rgba(50, 55, 63, 0.66);
          color: #fff;
          overflow: hidden;
          margin: 0 auto;
          backface-visibility: hidden;
          position: relative;
        }

        @media (max-width: 450px) {
          .card__front,
          .card__back {
            padding: 12px 14px 16px;
            height: 206px;
          }
          #highlight.highlight__number {
            width: 300px;
            left: 14px;
          }
          #highlight.highlight__holder {
            width: 220px;
            left: 14px;
          }
          #highlight.highlight__expire {
            left: 280px;
          }
          #highlight.highlight__cvv {
            width: 330px;
            left: 14px;
          }
        }

        .card__back {
          position: absolute;
          top: 0;
          left: 0;
          transform: rotateY(180deg);
          padding: 24px 0 0;
        }

        .card__front::before,
        .card__back::before {
          content: "";
          position: absolute;
          border: 16px solid var(--ring1, ${ring1});
          border-radius: 100%;
          left: -17%;
          top: -45px;
          height: 300px;
          width: 300px;
          filter: blur(13px);
        }

        .card__front::after,
        .card__back::after {
          content: "";
          position: absolute;
          border: 16px solid var(--ring2, ${ring2});
          border-radius: 100%;
          width: 300px;
          top: 55%;
          left: -200px;
          height: 300px;
          filter: blur(13px);
        }

        .card__hide_line {
          height: 40px;
          width: 100%;
          background-color: #6b7280;
          position: relative;
          z-index: 1;
        }

        .card_cvv {
          position: relative;
          z-index: 1;
          margin-top: 24px;
          padding: 0 32px;
          display: flex;
          flex-direction: column;
          align-items: end;
          font-size: 14px;
          font-weight: 600;
          text-transform: uppercase;
        }
        .card_cvv_field {
          margin-top: 6px;
          background-color: #fff;
          border-radius: 12px;
          height: 44px;
          width: 100%;
          color: #000;
          display: flex;
          align-items: center;
          justify-content: end;
          padding: 0 12px;
          font-size: 25px;
          line-height: 21px;
        }

        .card__header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          font-weight: 600;
          margin-bottom: 32px;
          position: relative;
          z-index: 1;
        }

        .card__number {
          font-size: 22px;
          margin-bottom: 32px;
          position: relative;
          z-index: 1;
          display: flex;
          height: 33px;
          overflow: hidden;
          color: #fff;
        }

        .card__number .slot {
          display: inline-flex;
          margin-right: 0;
        }

        .card__number .slot:nth-child(4n) {
          margin-right: 10px;
        }

        .card__number .digit {
          display: flex;
          flex-direction: column;
          height: 33px;
          line-height: 33px;
          transition: transform 0.2s;
        }

        .card__number .digit.filed {
          transform: translateY(-33px);
        }

        .card__number .row {
          height: 33px;
          display: block;
        }

        .card__footer {
          display: flex;
          align-items: center;
          justify-content: space-between;
          position: relative;
          z-index: 1;
        }
        .card__holder {
          text-transform: uppercase;
        }
        .card__section__title {
          font-size: 14px;
          font-weight: 600;
          text-transform: uppercase;
        }

        .form {
          border-radius: 12px;
          background: #fff;
          width: 100%;
          max-width: 600px;
          margin: 0 auto;
          padding: 24px;
          border: 1px solid #f1f1f1;
          box-shadow: 0 0 40px rgba(50, 55, 63, 0.16);
          display: grid;
          gap: 12px;
          color: #0d0c22;
        }

        label {
          display: block;
          margin: 6px 0 4px;
          color: #0d0c22;
          font-weight: 500;
        }

        input,
        select {
          height: 52px;
          display: block;
          width: 100%;
          border: 1px solid #6b7280;
          padding: 18px 20px;
          transition: outline 200ms ease, box-shadow 200ms ease;
          border-radius: 12px;
          outline: none;
          background-color: #fff;
          color: #0d0c22;
          font-size: 16px;
        }

        input:focus,
        select:focus {
          border: 1px solid #000;
          outline: 4px solid rgba(0, 0, 0, 0.1);
        }

        select {
          padding: 0 20px;
        }

        .filed__group {
          display: grid;
          grid-template-columns: 2fr 1fr;
          gap: 24px;
        }

        @media (max-width: 560px) {
          .filed__group {
            grid-template-columns: 1fr;
          }
        }

        .filed__date {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 12px;
        }

        .err {
          color: #b42318;
          font-size: 12px;
          margin-top: 4px;
        }

        .submit {
          margin-top: 8px;
          height: 48px;
          border: none;
          border-radius: 10px;
          background: #0d0c22;
          color: #fff;
          font-weight: 600;
          cursor: pointer;
          opacity: ${validity.allValid ? 1 : 0.6};
        }
      `}</style>
    </section>
  );
};

export { CreditCardForm };
export type { CardState, CardValidity };
'@

Backup-IfExists $cardFormPath
Set-Content -Path $cardFormPath -Value $cardFormContent -Encoding UTF8
Write-Host "Created: $cardFormPath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2. checkout/page.tsx - wired to cart + order store, uses exact design
# ---------------------------------------------------------------------------
$checkoutPagePath = Join-Path $checkoutDir "page.tsx"

$checkoutPageContent = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { ShieldCheck, Lock } from "lucide-react";
import { useCartStore, useOrderStore } from "@saachi/store";
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

  const [processing, setProcessing] = useState(false);

  const currency = items[0]?.currency ?? "USD";
  const fmt = (n: number) =>
    new Intl.NumberFormat("en-US", { style: "currency", currency }).format(n);

  function handleCardSubmit(_state: CardState, validity: CardValidity) {
    if (!validity.allValid || items.length === 0 || processing) return;

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

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-[1fr_320px]">
        <div className="overflow-hidden rounded-card border border-line bg-card">
          <CreditCardForm onSubmit={handleCardSubmit} />
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
        </aside>
      </div>
    </div>
  );
}
'@

Backup-IfExists $checkoutPagePath
Set-Content -Path $checkoutPagePath -Value $checkoutPageContent -Encoding UTF8
Write-Host "Created: $checkoutPagePath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 3. Repoint pricing CTA buttons to /checkout instead of /register
# ---------------------------------------------------------------------------
# Pricing plans currently link to /register because they represent a
# subscription signup, not a course purchase. We repoint the PAID plan CTAs
# (Pro / Monthly / Yearly) to /checkout so "Start Pro" / "Start Your
# Journey" / "Claim This Offer" land on the same payment/card-details flow
# as course checkout. Free "Basic" plan keeps pointing at /register.

$filesToPatch = @(
    (Join-Path $marketingCompDir "PricingTeaser.tsx"),
    (Join-Path $webApp "app\(marketing)\pricing\page.tsx"),
    (Join-Path $componentsUiDir "limited-time-offer-pricing.tsx")
)

foreach ($file in $filesToPatch) {
    if (-not (Test-Path $file)) {
        Write-Warning "Skipped (not found): $file"
        continue
    }

    Backup-IfExists $file

    $content = Get-Content -Path $file -Raw

    # 1) PricingTeaser.tsx & pricing/page.tsx: only the "pro" plan's buttonLink/href -> /checkout
    $content = $content -replace '(id:\s*"pro"[\s\S]*?buttonLink:\s*)"/register"', '$1"/checkout"'
    $content = $content -replace '(name:\s*"Pro"[\s\S]*?href:\s*)"/register"', '$1"/checkout"'

    # 2) limited-time-offer-pricing.tsx: both Monthly + Yearly CTA anchors -> /checkout
    $content = $content -replace '<a href="/register" className=\{monthlyCtaClassName\}>', '<a href="/checkout" className={monthlyCtaClassName}>'
    $content = $content -replace '<a href="/register" className=\{yearlyCtaClassName\}', '<a href="/checkout" className={yearlyCtaClassName}'

    Set-Content -Path $file -Value $content -Encoding UTF8
    Write-Host "Patched pricing CTA(s) in: $file" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd apps\web"
Write-Host "  2. pnpm dev  (or npm run dev)"
Write-Host "  3. Add a course to your cart, then visit /checkout - card design should match your screenshot exactly."
Write-Host "  4. Visit /pricing and the landing page pricing sections - 'Start Pro' / 'Start Your Journey' / 'Claim This Offer' now route to /checkout."
Write-Host ""
Write-Host "IMPORTANT: review the patched pricing files manually - regex-based" -ForegroundColor Yellow
Write-Host "replacement is best-effort. If a CTA still points to /register," -ForegroundColor Yellow
Write-Host "open that file and change the specific href/buttonLink to /checkout." -ForegroundColor Yellow
Write-Host ""
Write-Host "Reminder: this wires a UI-only card form. No real gateway (Stripe/" -ForegroundColor Yellow
Write-Host "PayPal/Easypaisa/JazzCash) is connected - card data never leaves the browser." -ForegroundColor Yellow