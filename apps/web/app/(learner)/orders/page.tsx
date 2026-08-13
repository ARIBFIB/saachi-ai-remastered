"use client";

import { Suspense } from "react";
import { useSearchParams } from "next/navigation";
import { CheckCircle2 } from "lucide-react";
import { useOrderStore } from "@saachi/store";
import { EmptyState } from "@saachi/ui";

function OrderSuccessBanner() {
  const searchParams = useSearchParams();
  const successId = searchParams.get("success");

  if (!successId) return null;

  return (
    <div className="mb-6 flex items-center gap-3 rounded-card border border-teal/30 bg-teal-light px-4 py-3">
      <CheckCircle2 size={18} className="text-teal" />
      <p className="text-[14px] text-ink">
        Payment successful. Order <span className="font-semibold">{successId}</span> is confirmed - your
        courses are now available in My Courses.
      </p>
    </div>
  );
}

function OrdersTable() {
  const orders = useOrderStore((s) => s.orders);

  if (orders.length === 0) {
    return <EmptyState title="No orders yet" description="Your purchase history will show up here." />;
  }

  return (
    <div className="overflow-hidden rounded-card border border-line bg-card">
      <table className="w-full text-left text-[13px]">
        <thead className="border-b border-line bg-paper-dim">
          <tr>
            <th className="px-4 py-3 font-semibold text-ink-soft">Order</th>
            <th className="px-4 py-3 font-semibold text-ink-soft">Items</th>
            <th className="px-4 py-3 font-semibold text-ink-soft">Total</th>
            <th className="px-4 py-3 font-semibold text-ink-soft">Status</th>
            <th className="px-4 py-3 font-semibold text-ink-soft">Date</th>
          </tr>
        </thead>
        <tbody>
          {orders.map((order) => (
            <tr key={order.id} className="border-b border-line last:border-0">
              <td className="px-4 py-3.5 font-medium text-ink">{order.id}</td>
              <td className="px-4 py-3.5 text-ink-soft">{order.items.map((i) => i.title).join(", ")}</td>
              <td className="px-4 py-3.5 font-mono text-ink">
                {new Intl.NumberFormat("en-US", { style: "currency", currency: order.currency }).format(order.total)}
              </td>
              <td className="px-4 py-3.5 capitalize text-ink-soft">{order.status}</td>
              <td className="px-4 py-3.5 text-ink-soft">
                {new Intl.DateTimeFormat("en-US", { dateStyle: "medium" }).format(new Date(order.createdAt))}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default function OrdersPage() {
  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Order History</h1>

      <Suspense fallback={null}>
        <OrderSuccessBanner />
      </Suspense>

      <OrdersTable />
    </div>
  );
}