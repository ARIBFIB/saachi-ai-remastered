"use client";

import { useState } from "react";
import Link from "next/link";
import { ShoppingCart, X, Tag } from "lucide-react";
import { useRouter } from "next/navigation";
import { useCartStore } from "@saachi/store";
import { Button, Card, Input, EmptyState } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

export default function CartPage() {
  const router = useRouter();
  const cart = useCartStore();
  const [couponInput, setCouponInput] = useState("");
  const [couponMessage, setCouponMessage] = useState<{ text: string; ok: boolean } | null>(null);

  const currency = cart.items[0]?.currency ?? "USD";

  const handleApplyCoupon = () => {
    if (!couponInput.trim()) return;
    const result = cart.applyCoupon(couponInput);
    setCouponMessage({ text: result.message, ok: result.success });
  };

  if (cart.items.length === 0) {
    return (
      <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
        <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Your cart</h1>
        <EmptyState
          icon={<ShoppingCart size={22} />}
          title="Your cart is empty"
          description="Browse the marketplace and add a course to get started."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      </main>
    );
  }

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">
        Your cart <span className="text-ink-soft">({cart.items.length})</span>
      </h1>

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-[1fr_320px]">
        <div className="flex flex-col gap-4">
          {cart.items.map((item) => (
            <Card key={item.courseId} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center">
              <Link href={`/courses/${item.slug}`} className="block h-[90px] w-[160px] shrink-0 overflow-hidden rounded-control bg-paper-dim">
                {item.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={item.thumbnailUrl} alt={item.title} className="h-full w-full object-cover" />
                )}
              </Link>
              <div className="flex-1">
                <Link href={`/courses/${item.slug}`} className="text-[15px] font-semibold text-ink hover:text-gold-dark">
                  {item.title}
                </Link>
                <p className="mt-1 text-[13px] text-ink-soft">{item.instructorName}</p>
              </div>
              <div className="flex shrink-0 items-center gap-4">
                <span className="font-mono text-[16px] font-semibold text-ink">
                  {formatCurrency(item.price, item.currency)}
                </span>
                <button
                  type="button"
                  onClick={() => cart.removeItem(item.courseId)}
                  aria-label="Remove from cart"
                  className="flex h-8 w-8 items-center justify-center rounded-full text-ink-soft transition-colors hover:bg-paper-dim hover:text-error"
                >
                  <X size={16} />
                </button>
              </div>
            </Card>
          ))}
        </div>

        <div className="lg:sticky lg:top-6 lg:self-start">
          <Card className="p-6">
            <h2 className="mb-4 text-[16px] font-semibold text-ink">Order summary</h2>

            <div className="mb-4 flex flex-col gap-2">
              <div className="flex items-center gap-2">
                <Tag size={15} className="text-ink-soft" />
                <Input
                  placeholder="Coupon code"
                  value={couponInput}
                  onChange={(e) => setCouponInput(e.target.value)}
                  className="h-10"
                />
                <Button size="sm" variant="secondary" onClick={handleApplyCoupon}>
                  Apply
                </Button>
              </div>
              {couponMessage && (
                <p className={couponMessage.ok ? "text-[12px] text-teal" : "text-[12px] text-error"}>
                  {couponMessage.text}
                </p>
              )}
              {cart.coupon && (
                <div className="flex items-center justify-between text-[13px] text-ink-soft">
                  <span>Applied: {cart.coupon.code}</span>
                  <button type="button" onClick={() => cart.removeCoupon()} className="text-error hover:underline">
                    Remove
                  </button>
                </div>
              )}
            </div>

            <div className="flex flex-col gap-2 border-t border-line pt-4 text-[14px]">
              <div className="flex justify-between text-ink-soft">
                <span>Subtotal</span>
                <span>{formatCurrency(cart.subtotal(), currency)}</span>
              </div>
              {cart.coupon && (
                <div className="flex justify-between text-teal">
                  <span>Discount ({cart.coupon.percentOff}%)</span>
                  <span>-{formatCurrency(cart.discount(), currency)}</span>
                </div>
              )}
              <div className="flex justify-between border-t border-line pt-2 text-[16px] font-semibold text-ink">
                <span>Total</span>
                <span>{formatCurrency(cart.total(), currency)}</span>
              </div>
            </div>

            <Button size="lg" className="mt-6 w-full" onClick={() => router.push("/checkout")}>
              Proceed to checkout
            </Button>
          </Card>
        </div>
      </div>
    </main>
  );
}