"use client";

import Link from "next/link";
import { useState } from "react";
import { X } from "lucide-react";
import { useRouter } from "next/navigation";
import { useCartStore } from "@saachi/store";
import { Button, EmptyState, Input } from "@saachi/ui";

export default function CartPage() {
  const router = useRouter();
  const items = useCartStore((s) => s.items);
  const coupon = useCartStore((s) => s.coupon);
  const removeItem = useCartStore((s) => s.removeItem);
  const applyCoupon = useCartStore((s) => s.applyCoupon);
  const removeCoupon = useCartStore((s) => s.removeCoupon);
  const subtotal = useCartStore((s) => s.subtotal());
  const discount = useCartStore((s) => s.discount());
  const total = useCartStore((s) => s.total());

  const [couponCode, setCouponCode] = useState("");
  const [couponMessage, setCouponMessage] = useState<string | null>(null);

  function handleApplyCoupon() {
    const result = applyCoupon(couponCode);
    setCouponMessage(result.message);
  }

  const currency = items[0]?.currency ?? "USD";
  const fmt = (n: number) => new Intl.NumberFormat("en-US", { style: "currency", currency }).format(n);

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Cart</h1>

      {items.length === 0 ? (
        <EmptyState
          title="Your cart is empty"
          description="Add a course to get started."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="grid grid-cols-1 gap-8 md:grid-cols-[1fr_320px]">
          <div className="flex flex-col gap-3">
            {items.map((item) => (
              <div key={item.courseId} className="flex items-center gap-4 rounded-card border border-line bg-card p-4">
                {item.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={item.thumbnailUrl}
                    alt={item.title}
                    className="h-16 w-28 shrink-0 rounded-control object-cover"
                  />
                )}
                <div className="min-w-0 flex-1">
                  <Link href={`/courses/${item.slug}`} className="truncate text-[15px] font-semibold text-ink hover:underline">
                    {item.title}
                  </Link>
                  <p className="text-[13px] text-ink-soft">{item.instructorName}</p>
                </div>
                <span className="font-mono text-[15px] font-semibold text-ink">
                  {new Intl.NumberFormat("en-US", { style: "currency", currency: item.currency }).format(item.price)}
                </span>
                <button
                  type="button"
                  aria-label="Remove from cart"
                  onClick={() => removeItem(item.courseId)}
                  className="flex h-9 w-9 shrink-0 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
                >
                  <X size={16} />
                </button>
              </div>
            ))}
          </div>

          <aside className="h-fit rounded-card border border-line bg-card p-6">
            <h2 className="mb-4 text-[15px] font-semibold text-ink">Order summary</h2>

            {coupon ? (
              <div className="mb-4 flex items-center justify-between rounded-control bg-gold-tint px-3 py-2 text-[13px]">
                <span className="font-semibold text-gold-dark">{coupon.code} applied</span>
                <button type="button" onClick={removeCoupon} className="text-ink-soft hover:text-ink">
                  Remove
                </button>
              </div>
            ) : (
              <div className="mb-4 flex gap-2">
                <Input
                  placeholder="Coupon code"
                  value={couponCode}
                  onChange={(e) => setCouponCode(e.target.value)}
                  className="flex-1"
                />
                <Button variant="secondary" onClick={handleApplyCoupon}>
                  Apply
                </Button>
              </div>
            )}
            {couponMessage && <p className="mb-4 text-[12px] text-ink-soft">{couponMessage}</p>}

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

            <Button size="lg" className="mt-5 w-full" onClick={() => router.push("/checkout")}>
              Proceed to checkout
            </Button>
          </aside>
        </div>
      )}
    </div>
  );
}