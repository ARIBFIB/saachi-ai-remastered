"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { useCartStore, useEnrollmentStore, useOrderStore } from "@saachi/store";
import { Button, Input, Select } from "@saachi/ui";

const PAYMENT_METHODS = [
  { label: "Card (Stripe)", value: "stripe" },
  { label: "PayPal", value: "paypal" },
  { label: "Easypaisa", value: "easypaisa" },
  { label: "JazzCash", value: "jazzcash" }
];

export default function CheckoutPage() {
  const router = useRouter();
  const items = useCartStore((s) => s.items);
  const coupon = useCartStore((s) => s.coupon);
  const subtotal = useCartStore((s) => s.subtotal());
  const discount = useCartStore((s) => s.discount());
  const total = useCartStore((s) => s.total());
  const clearCart = useCartStore((s) => s.clear);
  const enroll = useEnrollmentStore((s) => s.enroll);
  const addOrder = useOrderStore((s) => s.addOrder);

  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [paymentMethod, setPaymentMethod] = useState("stripe");
  const [isProcessing, setIsProcessing] = useState(false);

  const currency = items[0]?.currency ?? "USD";
  const fmt = (n: number) => new Intl.NumberFormat("en-US", { style: "currency", currency }).format(n);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    if (items.length === 0) return;
    setIsProcessing(true);

    // NOTE: demo-only checkout, no real payment gateway wired up yet.
    setTimeout(() => {
      const order = addOrder({
        items: items.map((i) => ({ courseId: i.courseId, title: i.title, price: i.price })),
        subtotal,
        discount,
        total,
        currency,
        paymentMethod
      });

      enroll(
        items.map((i) => ({
          courseId: i.courseId,
          slug: i.slug,
          title: i.title,
          thumbnailUrl: i.thumbnailUrl,
          instructorName: i.instructorName
        }))
      );

      clearCart();
      setIsProcessing(false);
      router.push(`/orders?success=${order.id}`);
    }, 800);
  }

  if (items.length === 0) {
    return (
      <div className="mx-auto max-w-md py-16 text-center">
        <p className="text-ink-soft">Your cart is empty. Add a course before checking out.</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 gap-8 md:grid-cols-[1fr_320px]">
      <div>
        <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Checkout</h1>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input label="Full name" required value={fullName} onChange={(e) => setFullName(e.target.value)} />
          <Input
            label="Email"
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <Select
            label="Payment method"
            options={PAYMENT_METHODS}
            value={paymentMethod}
            onChange={(e) => setPaymentMethod(e.target.value)}
          />
          <Button type="submit" size="lg" loading={isProcessing} className="mt-2">
            Pay {fmt(total)}
          </Button>
        </form>
      </div>

      <aside className="h-fit rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Order summary</h2>
        <div className="flex flex-col gap-3">
          {items.map((item) => (
            <div key={item.courseId} className="flex justify-between text-[13px]">
              <span className="text-ink-soft">{item.title}</span>
              <span className="font-medium text-ink">{fmt(item.price)}</span>
            </div>
          ))}
        </div>
        <div className="mt-4 flex flex-col gap-2 border-t border-line pt-4 text-[14px]">
          <div className="flex justify-between text-ink-soft">
            <span>Subtotal</span>
            <span>{fmt(subtotal)}</span>
          </div>
          {coupon && (
            <div className="flex justify-between text-teal">
              <span>Discount ({coupon.code})</span>
              <span>-{fmt(discount)}</span>
            </div>
          )}
          <div className="mt-2 flex justify-between border-t border-line pt-2 text-[16px] font-semibold text-ink">
            <span>Total</span>
            <span>{fmt(total)}</span>
          </div>
        </div>
      </aside>
    </div>
  );
}