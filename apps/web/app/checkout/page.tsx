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
