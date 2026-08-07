"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { CreditCard, Wallet, Building2, ShieldCheck } from "lucide-react";
import { useCartStore, useEnrollmentStore, useOrderStore } from "@saachi/store";
import { useSession } from "@saachi/api-client";
import { Button, Card, Input, EmptyState } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

const PAYMENT_METHODS = [
  { id: "card", label: "Credit / Debit Card", icon: CreditCard },
  { id: "easypaisa", label: "Easypaisa", icon: Wallet },
  { id: "bank_transfer", label: "Bank Transfer", icon: Building2 }
] as const;

export default function CheckoutPage() {
  const router = useRouter();
  const cart = useCartStore();
  const enrollment = useEnrollmentStore();
  const orders = useOrderStore();
  const { data: session } = useSession();

  const [method, setMethod] = useState<(typeof PAYMENT_METHODS)[number]["id"]>("card");
  const [isPaying, setIsPaying] = useState(false);
  const [billingName, setBillingName] = useState(session?.fullName ?? "");
  const [billingEmail, setBillingEmail] = useState(session?.email ?? "");

  const currency = cart.items[0]?.currency ?? "USD";

  if (cart.items.length === 0) {
    return (
      <main className="mx-auto max-w-[720px] px-6 py-10 md:px-10">
        <EmptyState
          title="Nothing to check out"
          description="Your cart is empty. Add a course before starting checkout."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      </main>
    );
  }

  const handlePay = async () => {
    setIsPaying(true);
    // NOTE: demo-only. Replace with real Payments/Orders API call (Doc 3)
    // once the backend is available.
    await new Promise((resolve) => setTimeout(resolve, 1200));

    enrollment.enroll(
      cart.items.map((item) => ({
        courseId: item.courseId,
        slug: item.slug,
        title: item.title,
        thumbnailUrl: item.thumbnailUrl,
        instructorName: item.instructorName
      }))
    );

    orders.addOrder({
      items: cart.items.map((item) => ({
        courseId: item.courseId,
        title: item.title,
        price: item.price
      })),
      subtotal: cart.subtotal(),
      discount: cart.discount(),
      total: cart.total(),
      currency: currency,
      paymentMethod: method
    });

    cart.clear();
    setIsPaying(false);
    router.push("/checkout/confirmation");
  };

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Checkout</h1>

      <div className="grid grid-cols-1 gap-8 lg:grid-cols-[1fr_360px]">
        <div className="flex flex-col gap-8">
          <Card className="p-6">
            <h2 className="mb-4 text-[16px] font-semibold text-ink">Billing details</h2>
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <Input label="Full name" value={billingName} onChange={(e) => setBillingName(e.target.value)} />
              <Input
                label="Email"
                type="email"
                value={billingEmail}
                onChange={(e) => setBillingEmail(e.target.value)}
              />
            </div>
          </Card>

          <Card className="p-6">
            <h2 className="mb-4 text-[16px] font-semibold text-ink">Payment method</h2>
            <div className="flex flex-col gap-3">
              {PAYMENT_METHODS.map((pm) => (
                <button
                  key={pm.id}
                  type="button"
                  onClick={() => setMethod(pm.id)}
                  className={[
                    "flex items-center gap-3 rounded-control border px-4 py-3.5 text-left text-[14px] font-medium transition-colors duration-150 ease-out",
                    method === pm.id
                      ? "border-gold bg-gold-tint text-ink"
                      : "border-line-strong text-ink-soft hover:border-ink"
                  ].join(" ")}
                >
                  <pm.icon size={18} />
                  {pm.label}
                </button>
              ))}
            </div>
            <p className="mt-4 flex items-center gap-2 text-[12px] text-ink-soft">
              <ShieldCheck size={14} /> This is a demo checkout - no real payment is processed.
            </p>
          </Card>
        </div>

        <div className="lg:sticky lg:top-6 lg:self-start">
          <Card className="p-6">
            <h2 className="mb-4 text-[16px] font-semibold text-ink">Order summary</h2>
            <div className="flex flex-col gap-3 border-b border-line pb-4">
              {cart.items.map((item) => (
                <div key={item.courseId} className="flex justify-between text-[13px] text-ink-soft">
                  <span className="line-clamp-1 pr-2">{item.title}</span>
                  <span className="shrink-0 text-ink">{formatCurrency(item.price, item.currency)}</span>
                </div>
              ))}
            </div>
            <div className="flex flex-col gap-2 py-4 text-[14px]">
              <div className="flex justify-between text-ink-soft">
                <span>Subtotal</span>
                <span>{formatCurrency(cart.subtotal(), currency)}</span>
              </div>
              {cart.coupon && (
                <div className="flex justify-between text-teal">
                  <span>Discount</span>
                  <span>-{formatCurrency(cart.discount(), currency)}</span>
                </div>
              )}
              <div className="flex justify-between border-t border-line pt-2 text-[16px] font-semibold text-ink">
                <span>Total</span>
                <span>{formatCurrency(cart.total(), currency)}</span>
              </div>
            </div>
            <Button size="lg" className="w-full" onClick={handlePay} disabled={isPaying}>
              {isPaying ? "Processing..." : `Pay ${formatCurrency(cart.total(), currency)}`}
            </Button>
          </Card>
        </div>
      </div>
    </main>
  );
}