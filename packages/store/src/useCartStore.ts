import { create } from "zustand";
import { persist } from "zustand/middleware";

export type CartItem = {
  courseId: string;
  slug: string;
  title: string;
  thumbnailUrl?: string;
  instructorName: string;
  price: number;
  currency: string;
};

export type CouponState = {
  code: string;
  percentOff: number;
} | null;

// NOTE: demo-only coupon codes, validated client-side. Replace with a real
// Coupons API call once the backend (Doc 3) is available.
const KNOWN_COUPONS: Record<string, number> = {
  SAACHI10: 10,
  SAACHI25: 25
};

type CartState = {
  items: CartItem[];
  coupon: CouponState;
  addItem: (item: CartItem) => void;
  removeItem: (courseId: string) => void;
  clear: () => void;
  applyCoupon: (code: string) => { success: boolean; message: string };
  removeCoupon: () => void;
  isInCart: (courseId: string) => boolean;
  subtotal: () => number;
  discount: () => number;
  total: () => number;
};

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],
      coupon: null,

      addItem: (item) => {
        const exists = get().items.some((i) => i.courseId === item.courseId);
        if (exists) return;
        set({ items: [...get().items, item] });
      },

      removeItem: (courseId) => {
        set({ items: get().items.filter((i) => i.courseId !== courseId) });
      },

      clear: () => set({ items: [], coupon: null }),

      applyCoupon: (code) => {
        const normalized = code.trim().toUpperCase();
        const percentOff = KNOWN_COUPONS[normalized];
        if (!percentOff) {
          return { success: false, message: "That coupon code isn't valid." };
        }
        set({ coupon: { code: normalized, percentOff } });
        return { success: true, message: `${percentOff}% discount applied.` };
      },

      removeCoupon: () => set({ coupon: null }),

      isInCart: (courseId) => get().items.some((i) => i.courseId === courseId),

      subtotal: () => get().items.reduce((sum, i) => sum + i.price, 0),

      discount: () => {
        const coupon = get().coupon;
        if (!coupon) return 0;
        return Math.round(get().subtotal() * (coupon.percentOff / 100) * 100) / 100;
      },

      total: () => Math.max(0, get().subtotal() - get().discount())
    }),
    { name: "saachi-cart" }
  )
);