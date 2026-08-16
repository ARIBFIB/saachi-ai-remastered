#Requires -Version 5.1
<#
.SYNOPSIS
    Refines the /checkout page layout:
      1. Restores the normal SiteHeader (logo, nav, cart, login/signup) -
         only the search bar row is hidden specifically on /checkout.
      2. Removes the custom minimal checkout layout (no longer needed).
      3. Adds a "Back to cart" link ABOVE the "Checkout" heading.
      4. Widens the payment section so the card and form sit side by side
         properly instead of being squeezed by a sidebar.
      5. Moves "Order summary" OUT of the sidebar and into its own
         section BELOW the payment form (as a "next step").

.DESCRIPTION
    Run this from the SAI2 project root (same folder as pnpm-workspace.yaml).
    Requires the earlier setup scripts to have already been run.
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

$checkoutDir            = Join-Path $webApp "app\checkout"
$conditionalChromePath  = Join-Path $webApp "app\_components\ConditionalChrome.tsx"
$siteHeaderPath         = Join-Path $webApp "app\_components\SiteHeader.tsx"

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Backup-IfExists($path) {
    if (Test-Path $path) {
        $backup = "$path.bak-$timestamp"
        Copy-Item $path $backup
        Write-Host "Backed up -> $backup" -ForegroundColor Yellow
    }
}

if (-not (Test-Path $checkoutDir)) {
    Write-Error "apps\web\app\checkout not found - run the previous standalone-route script first."
    exit 1
}

# ---------------------------------------------------------------------------
# 1. Remove the custom minimal layout.tsx - checkout should inherit the
#    normal root layout (with SiteHeader/SiteFooter) again.
# ---------------------------------------------------------------------------
$checkoutLayoutPath = Join-Path $checkoutDir "layout.tsx"
if (Test-Path $checkoutLayoutPath) {
    $retired = Join-Path $checkoutDir "layout.tsx.retired-$timestamp.bak"
    Move-Item -Path $checkoutLayoutPath -Destination $retired -Force
    Write-Host "Retired custom checkout layout -> $retired" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# 2. Revert ConditionalChrome - /checkout should use the normal
#    SiteHeader/SiteFooter again (only the search row gets hidden, via
#    SiteHeader itself in step 3).
# ---------------------------------------------------------------------------
if (Test-Path $conditionalChromePath) {
    Backup-IfExists $conditionalChromePath
    $chromeText = Get-Content -Path $conditionalChromePath -Raw

    $withCheckout = 'const CHROME_EXCLUDED_PREFIXES = ["/instructor", "/checkout"];'
    $withoutCheckout = 'const CHROME_EXCLUDED_PREFIXES = ["/instructor"];'

    if ($chromeText -match [regex]::Escape($withCheckout)) {
        $chromeText = $chromeText.Replace($withCheckout, $withoutCheckout)
        Set-Content -Path $conditionalChromePath -Value $chromeText -Encoding UTF8
        Write-Host "Reverted: $conditionalChromePath (removed /checkout from excluded prefixes)" -ForegroundColor Green
    } else {
        Write-Host "ConditionalChrome.tsx already normal (no /checkout exclusion found) - skipping." -ForegroundColor DarkGray
    }
} else {
    Write-Warning "ConditionalChrome.tsx not found - skipping."
}

# ---------------------------------------------------------------------------
# 3. Patch SiteHeader.tsx - hide only the search bar row on /checkout,
#    keep logo / nav / cart / wishlist / login-signup as normal.
# ---------------------------------------------------------------------------
if (-not (Test-Path $siteHeaderPath)) {
    Write-Warning "SiteHeader.tsx not found at $siteHeaderPath - skipping search-bar patch."
} else {
    Backup-IfExists $siteHeaderPath
    $headerText = Get-Content -Path $siteHeaderPath -Raw

    # Add usePathname import if not already present
    if ($headerText -notmatch 'usePathname') {
        $headerText = $headerText.Replace(
            'import { useState } from "react";',
            'import { useState } from "react";' + "`r`n" + 'import { usePathname } from "next/navigation";'
        )
    }

    # Compute a flag right after the existing searchHidden hook line, then
    # OR it into what gets passed to <TopSearchBar hidden={...} />.
    $oldSearchHiddenDecl = '  const searchHidden = useSearchBarHidden();'
    $newSearchHiddenDecl = @'
  const searchHidden = useSearchBarHidden();
  const pathname = usePathname();
  const isCheckoutRoute = pathname?.startsWith("/checkout") ?? false;
'@

    if ($headerText -match [regex]::Escape($oldSearchHiddenDecl)) {
        $headerText = $headerText.Replace($oldSearchHiddenDecl, $newSearchHiddenDecl)
    } else {
        Write-Warning "Could not find 'const searchHidden = useSearchBarHidden();' in SiteHeader.tsx - please wire isCheckoutRoute manually."
    }

    $oldTopSearchBarUsage = '<TopSearchBar hidden={searchHidden} />'
    $newTopSearchBarUsage = '<TopSearchBar hidden={searchHidden || isCheckoutRoute} />'

    if ($headerText -match [regex]::Escape($oldTopSearchBarUsage)) {
        $headerText = $headerText.Replace($oldTopSearchBarUsage, $newTopSearchBarUsage)
        Set-Content -Path $siteHeaderPath -Value $headerText -Encoding UTF8
        Write-Host "Patched: $siteHeaderPath (search bar now also hides on /checkout)" -ForegroundColor Green
    } else {
        Write-Warning "Could not find '<TopSearchBar hidden={searchHidden} />' in SiteHeader.tsx - please update manually to hide it on /checkout."
    }
}

# ---------------------------------------------------------------------------
# 4. Rewrite checkout/page.tsx:
#    - Back-to-cart link ABOVE the heading
#    - Full-width payment panel so card + form sit side by side
#    - Order summary moved BELOW as its own "next step" section
# ---------------------------------------------------------------------------
$checkoutPagePath = Join-Path $checkoutDir "page.tsx"
Backup-IfExists $checkoutPagePath

$checkoutPageContent = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { ArrowLeft, ShieldCheck, ChevronRight } from "lucide-react";
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
    <div className="mx-auto max-w-4xl px-4 py-10 md:px-8">
      <Link
        href="/cart"
        className="mb-4 inline-flex items-center gap-1.5 text-[13px] font-medium text-ink-soft transition-colors hover:text-ink"
      >
        <ArrowLeft size={15} />
        Back to cart
      </Link>

      <h1 className="mb-2 font-display text-[24px] font-bold text-ink md:text-[26px]">Checkout</h1>
      <p className="mb-8 text-[13.5px] text-ink-soft">
        Enter your card details below to complete your purchase.
      </p>

      {/* STEP 1 - Payment */}
      <section className="rounded-card border border-line bg-card p-4 sm:p-6 md:p-8">
        <div className="mb-5 flex items-center gap-2">
          <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-ink text-[11px] font-bold text-paper">
            1
          </span>
          <h2 className="text-[15px] font-semibold text-ink">Payment details</h2>
        </div>
        <CreditCardForm onSubmit={handleCardSubmit} />
      </section>

      {/* STEP 2 - Order summary (next step, below the payment form) */}
      <section className="mt-8 rounded-card border border-line bg-card p-6 md:p-8">
        <div className="mb-5 flex items-center gap-2">
          <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-ink text-[11px] font-bold text-paper">
            2
          </span>
          <h2 className="text-[15px] font-semibold text-ink">Order summary</h2>
        </div>

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
      </section>
    </div>
  );
}
'@

Set-Content -Path $checkoutPagePath -Value $checkoutPageContent -Encoding UTF8
Write-Host "Rewrote: $checkoutPagePath" -ForegroundColor Green

Write-Host ""
Write-Host "Done. Summary:" -ForegroundColor Cyan
Write-Host "  - /checkout now uses the NORMAL site header (logo, nav, cart, login/signup)."
Write-Host "  - Only the search bar row is hidden, specifically on /checkout."
Write-Host "  - 'Back to cart' link now sits above the Checkout heading."
Write-Host "  - Payment section is full-width -> card and form sit side by side properly."
Write-Host "  - Order summary is now Step 2, its own section below the payment form."
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. cd apps\web"
Write-Host "  2. pnpm dev  (or npm run dev)"
Write-Host "  3. Add a course to your cart, then visit /checkout"