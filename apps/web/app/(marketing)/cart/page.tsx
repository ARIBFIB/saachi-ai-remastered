"use client";

import { useMemo, useState } from "react";
import { CartHeader } from "@/components/cart/CartHeader";
import { CartItemCard, type CartItem } from "@/components/cart/CartItemCard";
import { OrderSummary } from "@/components/cart/OrderSummary";
import { DetailFooter } from "@/components/course-detail/DetailFooter";

// TODO: replace with useCart() hook from @saachi/api-client
const initialItems: CartItem[] = [
  {
    id: "c1",
    title: "Advanced Machine Learning Algorithms for Predictive Analytics",
    instructor: "Dr. Emily Chen, Lead Data Scientist",
    price: 149.99,
    rating: 4.8,
    reviews: "2.4k",
    badge: "Bestseller",
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=400&q=80",
  },
  {
    id: "c2",
    title: "Full-Stack React & Node.js Masterclass: Zero to Deployment",
    instructor: "Marcus Rodriguez, Senior Engineer",
    price: 89.5,
    rating: 4.6,
    reviews: "1.1k",
    image:
      "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=400&q=80",
  },
];

export default function CartPage() {
  const [items, setItems] = useState<CartItem[]>(initialItems);

  const subtotal = useMemo(
    () => items.reduce((sum, item) => sum + item.price, 0),
    [items]
  );

  function handleRemove(id: string) {
    setItems((prev) => prev.filter((item) => item.id !== id));
  }

  function handleSaveForLater(id: string) {
    // TODO: wire to wishlist/saved-items API (packages/api-client)
    console.log("save for later", id);
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <CartHeader cartCount={items.length} />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-6 px-6 pb-32 pt-10">
        <h1
          className="text-3xl font-bold leading-10"
          style={{ color: "var(--token-color-ink)" }}
        >
          Shopping Cart
        </h1>

        {items.length === 0 ? (
          <EmptyCart />
        ) : (
          <div className="grid grid-cols-1 gap-8 lg:grid-cols-3">
            <div className="flex flex-col gap-4 lg:col-span-2">
              <p style={{ color: "var(--token-color-inkSoft)" }}>
                {items.length} {items.length === 1 ? "Course" : "Courses"} in Cart
              </p>

              {items.map((item) => (
                <CartItemCard
                  key={item.id}
                  item={item}
                  onRemove={handleRemove}
                  onSaveForLater={handleSaveForLater}
                />
              ))}
            </div>

            <div className="pb-10">
              <OrderSummary subtotal={subtotal} />
            </div>
          </div>
        )}
      </main>

      <DetailFooter />
    </div>
  );
}

function EmptyCart() {
  return (
    <div
      className="flex flex-col items-center gap-2 rounded-xl border-2 bg-[var(--token-color-surface)] py-20 text-center"
      style={{ borderColor: "var(--token-color-border)" }}
    >
      <p className="text-lg font-semibold" style={{ color: "var(--token-color-ink)" }}>
        Your cart is empty
      </p>
      <p style={{ color: "var(--token-color-inkSoft)" }}>
        Browse the marketplace to find your next course.
      </p>
    </div>
  );
}
