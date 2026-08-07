import { create } from "zustand";
import { persist } from "zustand/middleware";

export type WishlistItem = {
  courseId: string;
  slug: string;
  title: string;
  thumbnailUrl?: string;
  instructorName: string;
  price: number;
  currency: string;
  rating: number;
  ratingCount: number;
};

type WishlistState = {
  items: WishlistItem[];
  toggle: (item: WishlistItem) => void;
  remove: (courseId: string) => void;
  isWishlisted: (courseId: string) => boolean;
};

export const useWishlistStore = create<WishlistState>()(
  persist(
    (set, get) => ({
      items: [],

      toggle: (item) => {
        const exists = get().items.some((i) => i.courseId === item.courseId);
        if (exists) {
          set({ items: get().items.filter((i) => i.courseId !== item.courseId) });
        } else {
          set({ items: [...get().items, item] });
        }
      },

      remove: (courseId) => {
        set({ items: get().items.filter((i) => i.courseId !== courseId) });
      },

      isWishlisted: (courseId) => get().items.some((i) => i.courseId === courseId)
    }),
    { name: "saachi-wishlist" }
  )
);