import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_TRANSACTIONS,
  ADMIN_DUMMY_PAYOUTS,
  ADMIN_DUMMY_REFUNDS,
  ADMIN_DUMMY_TAX_RULES,
  type AdminTransaction,
  type AdminPayout,
  type PayoutStatus,
  type AdminRefund,
  type RefundStatus,
  type TaxRule
} from "../dummy-data-admin-finance";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Finance/Payouts/Refunds/Tax API (Doc 3).
let TRANSACTIONS_STATE: AdminTransaction[] = [...ADMIN_DUMMY_TRANSACTIONS];
let PAYOUTS_STATE: AdminPayout[] = [...ADMIN_DUMMY_PAYOUTS];
let REFUNDS_STATE: AdminRefund[] = [...ADMIN_DUMMY_REFUNDS];
let TAX_RULES_STATE: TaxRule[] = [...ADMIN_DUMMY_TAX_RULES];

export const adminFinanceKeys = {
  all: ["admin", "finance"] as const,
  transactions: (filters?: Record<string, unknown>) => ["admin", "finance", "transactions", filters] as const,
  payouts: (filters?: Record<string, unknown>) => ["admin", "finance", "payouts", filters] as const,
  refunds: (filters?: Record<string, unknown>) => ["admin", "finance", "refunds", filters] as const,
  taxRules: ["admin", "finance", "tax-rules"] as const
};

export type TransactionFilters = {
  search?: string;
  status?: string;
  gateway?: string;
};

export function useAdminTransactions(filters: TransactionFilters = {}) {
  return useQuery({
    queryKey: adminFinanceKeys.transactions(filters),
    queryFn: async () => {
      let items = [...TRANSACTIONS_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter(
          (t) =>
            t.courseTitle.toLowerCase().includes(q) ||
            t.learnerName.toLowerCase().includes(q) ||
            t.instructorName.toLowerCase().includes(q) ||
            t.id.toLowerCase().includes(q)
        );
      }
      if (filters.status) items = items.filter((t) => t.status === filters.status);
      if (filters.gateway) items = items.filter((t) => t.gateway === filters.gateway);
      return delay(items);
    }
  });
}

export type PayoutFilters = {
  status?: string;
};

export function useAdminPayouts(filters: PayoutFilters = {}) {
  return useQuery({
    queryKey: adminFinanceKeys.payouts(filters),
    queryFn: async () => {
      let items = [...PAYOUTS_STATE];
      if (filters.status) items = items.filter((p) => p.status === filters.status);
      return delay(items);
    }
  });
}

export function useUpdatePayoutStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: PayoutStatus }) => {
      PAYOUTS_STATE = PAYOUTS_STATE.map((p) =>
        p.id === id
          ? { ...p, status, processedAt: status === "paid" ? new Date().toISOString() : p.processedAt }
          : p
      );
      return delay({ id, status }, 400);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminFinanceKeys.all });
    }
  });
}

export type RefundFilters = {
  status?: string;
};

export function useAdminRefunds(filters: RefundFilters = {}) {
  return useQuery({
    queryKey: adminFinanceKeys.refunds(filters),
    queryFn: async () => {
      let items = [...REFUNDS_STATE];
      if (filters.status) items = items.filter((r) => r.status === filters.status);
      return delay(items);
    }
  });
}

export function useResolveRefund() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: RefundStatus }) => {
      REFUNDS_STATE = REFUNDS_STATE.map((r) => (r.id === id ? { ...r, status } : r));
      if (status === "approved") {
        const refund = REFUNDS_STATE.find((r) => r.id === id);
        if (refund) {
          TRANSACTIONS_STATE = TRANSACTIONS_STATE.map((t) =>
            t.id === refund.transactionId ? { ...t, status: "refunded" as const } : t
          );
        }
      }
      return delay({ id, status }, 400);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminFinanceKeys.all });
    }
  });
}

export function useAdminTaxRules() {
  return useQuery({
    queryKey: adminFinanceKeys.taxRules,
    queryFn: async () => delay([...TAX_RULES_STATE])
  });
}

export function useUpdateTaxRule() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ratePercent, active }: { id: string; ratePercent: number; active: boolean }) => {
      TAX_RULES_STATE = TAX_RULES_STATE.map((r) => (r.id === id ? { ...r, ratePercent, active } : r));
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminFinanceKeys.taxRules });
    }
  });
}

export function useCreateTaxRule() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { region: string; ratePercent: number; appliesTo: string }) => {
      const created: TaxRule = {
        id: `tax_${Math.random().toString(36).slice(2, 8)}`,
        region: input.region,
        ratePercent: input.ratePercent,
        appliesTo: input.appliesTo,
        active: true
      };
      TAX_RULES_STATE = [...TAX_RULES_STATE, created];
      return delay(created, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminFinanceKeys.taxRules });
    }
  });
}