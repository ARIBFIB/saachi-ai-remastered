import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_BANNERS,
  ADMIN_DUMMY_COUPONS,
  ADMIN_DUMMY_PROMOTION_SALES,
  type AdminBanner,
  type AdminCoupon,
  type PromotionSale
} from "../dummy-data-admin-marketing";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Marketing API (Doc 3) once available.
let BANNERS_STATE: AdminBanner[] = [...ADMIN_DUMMY_BANNERS];
let COUPONS_STATE: AdminCoupon[] = [...ADMIN_DUMMY_COUPONS];
let PROMOTION_SALES_STATE: PromotionSale[] = [...ADMIN_DUMMY_PROMOTION_SALES];

export const adminMarketingKeys = {
  banners: ["admin", "marketing", "banners"] as const,
  coupons: (filters?: Record<string, unknown>) => ["admin", "marketing", "coupons", filters] as const,
  promotionSales: ["admin", "marketing", "promotion-sales"] as const
};

// ---------------------------------------------------------------------------
// Banners
// ---------------------------------------------------------------------------
export function useAdminBanners() {
  return useQuery({
    queryKey: adminMarketingKeys.banners,
    queryFn: async () => delay([...BANNERS_STATE].sort((a, b) => a.order - b.order))
  });
}

export function useCreateBanner() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: Omit<AdminBanner, "id" | "order">) => {
      const created: AdminBanner = {
        ...input,
        id: `ban_${Math.random().toString(36).slice(2, 8)}`,
        order: BANNERS_STATE.length + 1
      };
      BANNERS_STATE = [...BANNERS_STATE, created];
      return delay(created, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminMarketingKeys.banners });
    }
  });
}

export function useUpdateBanner() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ...patch }: Partial<AdminBanner> & { id: string }) => {
      BANNERS_STATE = BANNERS_STATE.map((b) => (b.id === id ? { ...b, ...patch } : b));
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminMarketingKeys.banners });
    }
  });
}

export function useDeleteBanner() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      BANNERS_STATE = BANNERS_STATE.filter((b) => b.id !== id);
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminMarketingKeys.banners });
    }
  });
}

export function useReorderBanner() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, direction }: { id: string; direction: "up" | "down" }) => {
      const sorted = [...BANNERS_STATE].sort((a, b) => a.order - b.order);
      const index = sorted.findIndex((b) => b.id === id);
      const swapWith = direction === "up" ? index - 1 : index + 1;
      if (swapWith < 0 || swapWith >= sorted.length) return delay({ id }, 100);
      const a = sorted[index];
      const b = sorted[swapWith];
      const aOrder = a.order;
      a.order = b.order;
      b.order = aOrder;
      BANNERS_STATE = sorted;
      return delay({ id }, 250);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminMarketingKeys.banners });
    }
  });
}

// ---------------------------------------------------------------------------
// Coupons
// ---------------------------------------------------------------------------
export type CouponFilters = {
  search?: string;
  active?: boolean;
};

export function useAdminCoupons(filters: CouponFilters = {}) {
  return useQuery({
    queryKey: adminMarketingKeys.coupons(filters),
    queryFn: async () => {
      let items = [...COUPONS_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((c) => c.code.toLowerCase().includes(q));
      }
      if (typeof filters.active === "boolean") items = items.filter((c) => c.active === filters.active);
      return delay(items);
    }
  });
}

export function useCreateCoupon() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: Omit<AdminCoupon, "id" | "usageCount">) => {
      const created: AdminCoupon = {
        ...input,
        id: `cpn_${Math.random().toString(36).slice(2, 8)}`,
        usageCount: 0
      };
      COUPONS_STATE = [...COUPONS_STATE, created];
      return delay(created, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "marketing", "coupons"] });
    }
  });
}

export function useToggleCouponActive() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      COUPONS_STATE = COUPONS_STATE.map((c) => (c.id === id ? { ...c, active: !c.active } : c));
      return delay({ id }, 200);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "marketing", "coupons"] });
    }
  });
}

export function useDeleteCoupon() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      COUPONS_STATE = COUPONS_STATE.filter((c) => c.id !== id);
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "marketing", "coupons"] });
    }
  });
}

// ---------------------------------------------------------------------------
// Promotion package sales tracking
// ---------------------------------------------------------------------------
export function useAdminPromotionSales() {
  return useQuery({
    queryKey: adminMarketingKeys.promotionSales,
    queryFn: async () => delay([...PROMOTION_SALES_STATE])
  });
}