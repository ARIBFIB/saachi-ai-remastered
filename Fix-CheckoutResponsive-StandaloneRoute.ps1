#Requires -Version 5.1
<#
.SYNOPSIS
    1. Fixes credit-card-form.tsx responsiveness (no more horizontal
       overflow / clipped form on narrower containers or mobile).
    2. Moves the checkout page OUT of the (learner) route group into a
       standalone /checkout route with its own minimal layout - no
       sidebar, no top search bar, no site header/footer. Just a slim
       bar with the logo, a back link, and a "secure checkout" badge.

.DESCRIPTION
    Run this from the SAI2 project root (same folder as pnpm-workspace.yaml).

.NOTES
    UI-only. No real payment gateway is wired up.
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

$componentsUiDir     = Join-Path $webApp "components\ui"
$oldCheckoutDir       = Join-Path $webApp "app\(learner)\checkout"
$newCheckoutDir       = Join-Path $webApp "app\checkout"
$conditionalChromePath = Join-Path $webApp "app\_components\ConditionalChrome.tsx"

New-Item -ItemType Directory -Force -Path $componentsUiDir | Out-Null
New-Item -ItemType Directory -Force -Path $newCheckoutDir  | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Backup-IfExists($path) {
    if (Test-Path $path) {
        $backup = "$path.bak-$timestamp"
        Copy-Item $path $backup
        Write-Host "Backed up -> $backup" -ForegroundColor Yellow
    }
}

# ---------------------------------------------------------------------------
# 1. Fix credit-card-form.tsx responsiveness
#    - Replace the fixed-breakpoint 2-col grid with a wrapping flexbox so
#      it never clips, regardless of parent container width.
#    - .ccp no longer forces its own padding/centering (parent controls that).
# ---------------------------------------------------------------------------
$cardFormPath = Join-Path $componentsUiDir "credit-card-form.tsx"

if (-not (Test-Path $cardFormPath)) {
    Write-Error "credit-card-form.tsx not found at $cardFormPath - run the previous setup script first."
    exit 1
}

Backup-IfExists $cardFormPath

$cardFormText = Get-Content -Path $cardFormPath -Raw

# --- Replace the .ccp / .wrap CSS block with a responsive, wrapping version ---
$oldCssBlock = @'
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
'@

$newCssBlock = @'
        .ccp {
          width: 100%;
          display: flex;
          justify-content: center;
          padding: 20px;
          background: transparent;
          color: #0d0c22;
          box-sizing: border-box;
        }
        .wrap {
          width: 100%;
          max-width: 1000px;
          display: flex;
          flex-wrap: wrap;
          gap: 24px;
          align-items: flex-start;
          justify-content: center;
        }
        .wrap > :global(section#card) {
          flex: 0 1 380px;
        }
        .wrap > :global(form.form) {
          flex: 1 1 320px;
          min-width: 0;
        }
'@

if ($cardFormText -notmatch [regex]::Escape($oldCssBlock)) {
    Write-Warning "Could not find the exact .ccp/.wrap CSS block to patch - skipping CSS patch. Please verify credit-card-form.tsx manually."
} else {
    $cardFormText = $cardFormText.Replace($oldCssBlock, $newCssBlock)
}

# --- Make the card + form width caps flexible instead of hard max-width:420/600 clipping ---
$cardFormText = $cardFormText.Replace(
@'
        .card {
          position: relative;
          width: 100%;
          max-width: 420px;
          margin: 0 auto;
          transform-style: preserve-3d;
          transition: 0.8s;
          perspective: 1000px;
        }
'@,
@'
        .card {
          position: relative;
          width: 100%;
          max-width: 380px;
          min-width: 260px;
          margin: 0 auto;
          transform-style: preserve-3d;
          transition: 0.8s;
          perspective: 1000px;
        }
'@
)

$cardFormText = $cardFormText.Replace(
@'
        .card__front,
        .card__back {
          width: 100%;
          max-width: 420px;
          height: 233px;
'@,
@'
        .card__front,
        .card__back {
          width: 100%;
          max-width: 380px;
          height: 233px;
'@
)

$cardFormText = $cardFormText.Replace(
@'
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
'@,
@'
        .form {
          border-radius: 12px;
          background: #fff;
          width: 100%;
          max-width: 420px;
          min-width: 0;
          margin: 0 auto;
          padding: 24px;
          border: 1px solid #f1f1f1;
          box-shadow: 0 0 40px rgba(50, 55, 63, 0.16);
          display: grid;
          gap: 12px;
          color: #0d0c22;
          box-sizing: border-box;
        }
'@
)

# input/select: ensure box-sizing so 100% width never overflows on small screens
$cardFormText = $cardFormText.Replace(
@'
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
'@,
@'
        input,
        select {
          height: 52px;
          display: block;
          width: 100%;
          border: 1px solid #6b7280;
          padding: 18px 16px;
          transition: outline 200ms ease, box-shadow 200ms ease;
          border-radius: 12px;
          outline: none;
          background-color: #fff;
          color: #0d0c22;
          font-size: 16px;
          box-sizing: border-box;
        }
'@
)

Set-Content -Path $cardFormPath -Value $cardFormText -Encoding UTF8
Write-Host "Patched responsiveness in: $cardFormPath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2. Move checkout OUT of (learner) group -> standalone /checkout route
# ---------------------------------------------------------------------------

# 2a. Retire the old (learner)/checkout/page.tsx so it stops resolving to /checkout
if (Test-Path $oldCheckoutDir) {
    $oldPage = Join-Path $oldCheckoutDir "page.tsx"
    if (Test-Path $oldPage) {
        $retired = Join-Path $oldCheckoutDir "page.tsx.moved-$timestamp.bak"
        Move-Item -Path $oldPage -Destination $retired -Force
        Write-Host "Retired old route: $oldPage -> $retired" -ForegroundColor Yellow
    }
}

# 2b. New standalone layout.tsx - minimal chrome only
$checkoutLayoutPath = Join-Path $newCheckoutDir "layout.tsx"
Backup-IfExists $checkoutLayoutPath

$checkoutLayoutContent = @'
import Link from "next/link";
import type { ReactNode } from "react";
import { ArrowLeft, ShieldCheck } from "lucide-react";

/**
 * Standalone checkout layout - intentionally minimal.
 * No SiteHeader, no SiteFooter, no learner sidebar, no search bar.
 * Just a slim top bar: logo, back link, and a secure-checkout badge.
 */
export default function CheckoutLayout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-paper">
      <header className="sticky top-0 z-40 border-b border-line bg-card/95 backdrop-blur-sm">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 md:px-8">
          <Link href="/" className="font-display text-[18px] font-bold text-ink">
            Saachi<span className="text-gold-dark">AI</span>
          </Link>

          <div className="hidden items-center gap-1.5 text-[12.5px] font-semibold text-ink-soft sm:flex">
            <ShieldCheck size={14} className="text-teal" />
            Secure checkout
          </div>

          <Link
            href="/cart"
            className="flex items-center gap-1.5 text-[13px] font-medium text-ink-soft transition-colors hover:text-ink"
          >
            <ArrowLeft size={15} />
            Back to cart
          </Link>
        </div>
      </header>

      <main>{children}</main>
    </div>
  );
}
'@

Set-Content -Path $checkoutLayoutPath -Value $checkoutLayoutContent -Encoding UTF8
Write-Host "Created: $checkoutLayoutPath" -ForegroundColor Green

# 2c. New standalone page.tsx - responsive checkout content
$checkoutPagePath = Join-Path $newCheckoutDir "page.tsx"
Backup-IfExists $checkoutPagePath

$checkoutPageContent = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { ShieldCheck } from "lucide-react";
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
    <div className="mx-auto max-w-6xl px-4 py-10 md:px-8">
      <h1 className="mb-2 font-display text-[24px] font-bold text-ink md:text-[26px]">Checkout</h1>
      <p className="mb-8 text-[13.5px] text-ink-soft">
        Enter your card details below to complete your purchase.
      </p>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-[minmax(0,1fr)_320px] lg:gap-8">
        <div className="min-w-0 rounded-card border border-line bg-card p-4 sm:p-6">
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

Set-Content -Path $checkoutPagePath -Value $checkoutPageContent -Encoding UTF8
Write-Host "Created: $checkoutPagePath" -ForegroundColor Green

# ---------------------------------------------------------------------------
# 3. Exclude /checkout from the public SiteHeader/SiteFooter chrome
# ---------------------------------------------------------------------------
if (-not (Test-Path $conditionalChromePath)) {
    Write-Warning "ConditionalChrome.tsx not found at $conditionalChromePath - skipping chrome exclusion step."
} else {
    Backup-IfExists $conditionalChromePath
    $chromeText = Get-Content -Path $conditionalChromePath -Raw

    $oldLine = 'const CHROME_EXCLUDED_PREFIXES = ["/instructor"];'
    $newLine = 'const CHROME_EXCLUDED_PREFIXES = ["/instructor", "/checkout"];'

    if ($chromeText -match [regex]::Escape($oldLine)) {
        $chromeText = $chromeText.Replace($oldLine, $newLine)
        Set-Content -Path $conditionalChromePath -Value $chromeText -Encoding UTF8
        Write-Host "Patched: $conditionalChromePath (added /checkout to excluded prefixes)" -ForegroundColor Green
    } else {
        Write-Warning "Could not find the expected CHROME_EXCLUDED_PREFIXES line - please add '/checkout' to it manually in $conditionalChromePath"
    }
}

Write-Host ""
Write-Host "Done. Summary:" -ForegroundColor Cyan
Write-Host "  - credit-card-form.tsx is now fully responsive (wraps instead of clipping)."
Write-Host "  - /checkout is now a standalone route at apps/web/app/checkout/"
Write-Host "    (moved out of the (learner) group, so no sidebar/search bar)."
Write-Host "  - Old (learner)/checkout/page.tsx was retired (renamed to .moved-*.bak)."
Write-Host "  - ConditionalChrome now also hides the public SiteHeader/Footer on /checkout."
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd apps\web"
Write-Host "  2. pnpm dev  (or npm run dev)"
Write-Host "  3. Add a course to your cart, then visit /checkout"
Write-Host "  4. Resize the browser / test on mobile - the card+form should now wrap cleanly with no clipping."
Write-Host ""
Write-Host "Reminder: this wires a UI-only card form. No real gateway is connected." -ForegroundColor Yellow