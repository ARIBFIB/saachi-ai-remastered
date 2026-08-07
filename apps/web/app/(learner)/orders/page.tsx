"use client";

import Link from "next/link";
import { Receipt, Download } from "lucide-react";
import { useOrderStore } from "@saachi/store";
import { Button, Card, Badge, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

export default function OrdersPage() {
  const { orders } = useOrderStore();

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Order History</h1>
        <p className="mt-1 text-[14px] text-ink-soft">All your past purchases on Saachi AI.</p>
      </div>

      {orders.length === 0 ? (
        <EmptyState
          icon={<Receipt size={22} />}
          title="No orders yet"
          description="Once you complete a purchase, it will show up here."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-4">
          {orders.map((order) => (
            <Card key={order.id} className="p-5">
              <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
                <div>
                  <p className="text-[14px] font-semibold text-ink">{order.id}</p>
                  <p className="mt-0.5 text-[12px] text-ink-soft">{formatDate(order.createdAt)}</p>
                </div>
                <div className="flex items-center gap-3">
                  <Badge variant={order.status === "paid" ? "success" : "error"}>
                    {order.status === "paid" ? "Paid" : "Refunded"}
                  </Badge>
                  <Button size="sm" variant="secondary">
                    <Download size={14} /> Invoice
                  </Button>
                </div>
              </div>

              <div className="flex flex-col gap-1 border-t border-line pt-3">
                {order.items.map((item) => (
                  <div key={item.courseId} className="flex justify-between text-[13px] text-ink-soft">
                    <span className="line-clamp-1 pr-2">{item.title}</span>
                    <span className="shrink-0 text-ink">{formatCurrency(item.price, order.currency)}</span>
                  </div>
                ))}
              </div>

              <div className="mt-3 flex justify-between border-t border-line pt-3 text-[14px] font-semibold text-ink">
                <span>Total ({order.paymentMethod.replace("_", " ")})</span>
                <span>{formatCurrency(order.total, order.currency)}</span>
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}