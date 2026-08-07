import { create } from "zustand";
import { persist } from "zustand/middleware";

export type ActivePromotion = {
  courseId: string;
  courseTitle: string;
  tier: "bronze" | "silver" | "gold";
  purchasedAt: string;
  expiresAt: string;
};

type PromotionState = {
  active: ActivePromotion[];
  purchase: (courseId: string, courseTitle: string, tier: ActivePromotion["tier"]) => void;
};

export const usePromotionStore = create<PromotionState>()(
  persist(
    (set, get) => ({
      active: [],
      purchase: (courseId, courseTitle, tier) => {
        const now = new Date();
        const expires = new Date(now.getTime() + 1000 * 60 * 60 * 24 * 14);
        set({
          active: [
            ...get().active.filter((p) => p.courseId !== courseId),
            { courseId, courseTitle, tier, purchasedAt: now.toISOString(), expiresAt: expires.toISOString() }
          ]
        });
      }
    }),
    { name: "saachi-promotions" }
  )
);