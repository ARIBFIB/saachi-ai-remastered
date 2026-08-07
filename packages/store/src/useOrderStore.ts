import { create } from "zustand";
import { persist } from "zustand/middleware";

export type OrderLineItem = {
  courseId: string;
  title: string;
  price: number;
};

export type Order = {
  id: string;
  items: OrderLineItem[];
  subtotal: number;
  discount: number;
  total: number;
  currency: string;
  paymentMethod: string;
  createdAt: string;
  status: "paid" | "refunded";
};

type OrderState = {
  orders: Order[];
  addOrder: (order: Omit<Order, "id" | "createdAt" | "status">) => Order;
};

export const useOrderStore = create<OrderState>()(
  persist(
    (set, get) => ({
      orders: [],
      addOrder: (order) => {
        const newOrder: Order = {
          ...order,
          id: `ORD-${Date.now().toString(36).toUpperCase()}`,
          createdAt: new Date().toISOString(),
          status: "paid"
        };
        set({ orders: [newOrder, ...get().orders] });
        return newOrder;
      }
    }),
    { name: "saachi-orders" }
  )
);