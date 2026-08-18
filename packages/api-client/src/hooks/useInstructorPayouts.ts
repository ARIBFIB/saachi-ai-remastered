"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

// NOTE: demo-only, in-memory. Replace with real Instructor Payouts API (Doc 3)
// once the backend is available. Follows the same delay()/module-state pattern
// used across the other api-client hooks (see useAdminFinance.ts, useAuth.ts).

export type PayoutMethodType = "bank_transfer" | "easypaisa" | "jazzcash" | "stripe_connect";

export type InstructorPayoutMethod = {
  id: string;
  type: PayoutMethodType;
  label: string;
  accountName: string;
  accountNumber: string; // masked for display
  isDefault: boolean;
  addedAt: string;
};

export type InstructorPayoutStatus = "pending" | "processing" | "paid" | "rejected";

export type InstructorPayoutRequest = {
  id: string;
  amount: number;
  currency: string;
  methodId: string;
  methodLabel: string;
  status: InstructorPayoutStatus;
  requestedAt: string;
  processedAt?: string;
  note?: string;
};

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

function daysAgoIso(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

function genId(prefix: string) {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

// ---------------------------------------------------------------------------
// Seed / module-level state
// ---------------------------------------------------------------------------

let METHODS_STATE: InstructorPayoutMethod[] = [
  {
    id: "pm_1",
    type: "bank_transfer",
    label: "Meezan Bank",
    accountName: "Ayesha Khan",
    accountNumber: "â€¢â€¢â€¢â€¢ â€¢â€¢â€¢â€¢ 4821",
    isDefault: true,
    addedAt: daysAgoIso(120)
  },
  {
    id: "pm_2",
    type: "easypaisa",
    label: "Easypaisa",
    accountName: "Ayesha Khan",
    accountNumber: "0301 â€¢â€¢â€¢â€¢ 219",
    isDefault: false,
    addedAt: daysAgoIso(60)
  }
];

let REQUESTS_STATE: InstructorPayoutRequest[] = [
  {
    id: "po_9001",
    amount: 420,
    currency: "USD",
    methodId: "pm_1",
    methodLabel: "Meezan Bank â€¢â€¢â€¢â€¢ 4821",
    status: "pending",
    requestedAt: daysAgoIso(1)
  },
  {
    id: "po_9002",
    amount: 610,
    currency: "USD",
    methodId: "pm_1",
    methodLabel: "Meezan Bank â€¢â€¢â€¢â€¢ 4821",
    status: "paid",
    requestedAt: daysAgoIso(20),
    processedAt: daysAgoIso(17)
  },
  {
    id: "po_9003",
    amount: 275,
    currency: "USD",
    methodId: "pm_2",
    methodLabel: "Easypaisa 0301 â€¢â€¢â€¢â€¢ 219",
    status: "paid",
    requestedAt: daysAgoIso(45),
    processedAt: daysAgoIso(42)
  },
  {
    id: "po_9004",
    amount: 150,
    currency: "USD",
    methodId: "pm_2",
    methodLabel: "Easypaisa 0301 â€¢â€¢â€¢â€¢ 219",
    status: "rejected",
    requestedAt: daysAgoIso(60),
    processedAt: daysAgoIso(58),
    note: "Account name mismatch - please update payout method details."
  }
];

// Demo-only balance figures, mirrors the KPI cards on /instructor/earnings.
const AVAILABLE_BALANCE = 1240;
const MIN_PAYOUT_AMOUNT = 20;

export const instructorPayoutKeys = {
  methods: ["instructor", "payouts", "methods"] as const,
  requests: (filters?: Record<string, unknown>) => ["instructor", "payouts", "requests", filters] as const,
  balance: ["instructor", "payouts", "balance"] as const
};

// ---------------------------------------------------------------------------
// Balance
// ---------------------------------------------------------------------------

export function useInstructorPayoutBalance() {
  return useQuery({
    queryKey: instructorPayoutKeys.balance,
    queryFn: async () => {
      const pendingTotal = REQUESTS_STATE.filter((r) => r.status === "pending" || r.status === "processing").reduce(
        (sum, r) => sum + r.amount,
        0
      );
      return delay({
        availableBalance: AVAILABLE_BALANCE,
        pendingTotal,
        minPayoutAmount: MIN_PAYOUT_AMOUNT,
        currency: "USD"
      });
    }
  });
}

// ---------------------------------------------------------------------------
// Payout methods
// ---------------------------------------------------------------------------

export function useInstructorPayoutMethods() {
  return useQuery({
    queryKey: instructorPayoutKeys.methods,
    queryFn: async () => delay([...METHODS_STATE])
  });
}

export function useAddPayoutMethod() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: {
      type: PayoutMethodType;
      label: string;
      accountName: string;
      accountNumber: string;
    }) => {
      const masked =
        input.accountNumber.length > 4
          ? `â€¢â€¢â€¢â€¢ ${input.accountNumber.slice(-4)}`
          : input.accountNumber;
      const created: InstructorPayoutMethod = {
        id: genId("pm"),
        type: input.type,
        label: input.label,
        accountName: input.accountName,
        accountNumber: masked,
        isDefault: METHODS_STATE.length === 0,
        addedAt: new Date().toISOString()
      };
      METHODS_STATE = [...METHODS_STATE, created];
      return delay(created, 400);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: instructorPayoutKeys.methods });
    }
  });
}

export function useSetDefaultPayoutMethod() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      METHODS_STATE = METHODS_STATE.map((m) => ({ ...m, isDefault: m.id === id }));
      return delay({ id }, 250);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: instructorPayoutKeys.methods });
    }
  });
}

export function useRemovePayoutMethod() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const wasDefault = METHODS_STATE.find((m) => m.id === id)?.isDefault;
      METHODS_STATE = METHODS_STATE.filter((m) => m.id !== id);
      if (wasDefault && METHODS_STATE.length > 0) {
        METHODS_STATE = METHODS_STATE.map((m, i) => ({ ...m, isDefault: i === 0 }));
      }
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: instructorPayoutKeys.methods });
    }
  });
}

// ---------------------------------------------------------------------------
// Payout requests
// ---------------------------------------------------------------------------

export type InstructorPayoutFilters = {
  status?: string;
};

export function useInstructorPayoutRequests(filters: InstructorPayoutFilters = {}) {
  return useQuery({
    queryKey: instructorPayoutKeys.requests(filters),
    queryFn: async () => {
      let items = [...REQUESTS_STATE];
      if (filters.status) items = items.filter((r) => r.status === filters.status);
      return delay(items.sort((a, b) => new Date(b.requestedAt).getTime() - new Date(a.requestedAt).getTime()));
    }
  });
}

export function useRequestPayout() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { amount: number; methodId: string }) => {
      const method = METHODS_STATE.find((m) => m.id === input.methodId);
      if (!method) throw new Error("Select a payout method");
      if (input.amount < MIN_PAYOUT_AMOUNT) throw new Error(`Minimum payout is $${MIN_PAYOUT_AMOUNT}`);
      if (input.amount > AVAILABLE_BALANCE) throw new Error("Amount exceeds available balance");

      const created: InstructorPayoutRequest = {
        id: genId("po"),
        amount: input.amount,
        currency: "USD",
        methodId: method.id,
        methodLabel: `${method.label} ${method.accountNumber}`,
        status: "pending",
        requestedAt: new Date().toISOString()
      };
      REQUESTS_STATE = [created, ...REQUESTS_STATE];
      return delay(created, 500);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["instructor", "payouts"] });
    }
  });
}
