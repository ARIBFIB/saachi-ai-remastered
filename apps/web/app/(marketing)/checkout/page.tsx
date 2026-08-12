"use client";

import { useState } from "react";
import { CheckoutHeader } from "@/components/checkout/CheckoutHeader";
import { CheckoutFooter } from "@/components/checkout/CheckoutFooter";
import {
  BillingInformationCard,
  type BillingDetails,
} from "@/components/checkout/BillingInformationCard";
import {
  PaymentMethodCard,
  type PaymentMethod,
  type CardDetails,
} from "@/components/checkout/PaymentMethodCard";
import {
  CheckoutOrderSummary,
  type CheckoutItem,
} from "@/components/checkout/CheckoutOrderSummary";

// TODO: replace with useCart() / useCheckout() hooks from @saachi/api-client
const orderItems: CheckoutItem[] = [
  {
    id: "i1",
    title: "Advanced AI Model Training Masterclass",
    subtitle: "Lifetime Access",
    price: 299,
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=200&q=80",
  },
  {
    id: "i2",
    title: "Neural Network Optimization Toolkit",
    subtitle: "Digital Download",
    price: 49,
    image:
      "https://images.unsplash.com/photo-1518186285589-2f7649de83e0?auto=format&fit=crop&w=200&q=80",
  },
];

export default function CheckoutPage() {
  const [billing, setBilling] = useState<BillingDetails>({
    fullName: "",
    email: "",
    country: "United States",
    zip: "",
  });
  const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>("card");
  const [cardDetails, setCardDetails] = useState<CardDetails>({
    number: "",
    expiry: "",
    cvc: "",
  });

  const subtotal = orderItems.reduce((sum, item) => sum + item.price, 0);

  function handleCompletePurchase() {
    // TODO: wire to checkout/payment API (packages/api-client)
    console.log("complete purchase", { billing, paymentMethod, cardDetails });
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)] pt-16">
      <CheckoutHeader />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-10 px-6 py-12">
        <div className="flex flex-col gap-2">
          <h1
            className="text-3xl font-bold leading-10"
            style={{ color: "var(--token-color-ink)" }}
          >
            Complete Your Purchase
          </h1>
          <p className="text-base" style={{ color: "var(--token-color-inkSoft)" }}>
            You&apos;re almost there. Please enter your billing details below.
          </p>
        </div>

        <div className="grid grid-cols-1 items-start gap-6 lg:grid-cols-3">
          <div className="flex flex-col gap-6 lg:col-span-2">
            <BillingInformationCard details={billing} onChange={setBilling} />
            <PaymentMethodCard
              value={paymentMethod}
              onChange={setPaymentMethod}
              cardDetails={cardDetails}
              onCardDetailsChange={setCardDetails}
            />
          </div>

          <CheckoutOrderSummary
            items={orderItems}
            subtotal={subtotal}
            onCompletePurchase={handleCompletePurchase}
          />
        </div>
      </main>

      <CheckoutFooter />
    </div>
  );
}
