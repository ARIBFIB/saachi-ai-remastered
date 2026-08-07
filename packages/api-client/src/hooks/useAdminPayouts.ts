"use client";

import { useMemo } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

export type AdminPayoutStatus = "pending" | "approved" | "paid" | "rejected";
export type AdminPayoutMethod = "bank_transfer" | "stripe_connect" | "easypaisa" | "jazzcash";

export type AdminPayout = {
  id: string;
  instructorId: string;
  instructorName: string;
  amount: number;
  currency: string;
  method: AdminPayoutMethod;
  status: AdminPayoutStatus;
  requestedAt: string;
  processedAt?: string;
  rejectionReason?: string;
};

const MOCK_PAYOUTS: AdminPayout[] = [
  {
    id: "PAYOUT-2026-0913",
    instructorId: "inst_1",
    instructorName: "Hassan Raza",
    amount: 1240,
    currency: "USD",
    method: "bank_transfer",
    status: "pending",
    requestedAt: "2026-08-05T10:12:00Z"
  },
  {
    id: "PAYOUT-2026-0914",
    instructorId: "inst_2",
    instructorName: "Fatima Noor",
    amount: 860,
    currency: "USD",
    method: "easypaisa",
    status: "pending",
    requestedAt: "2026-08-06T08:40:00Z"
  },
  {
    id: "PAYOUT-2026-0912",
    instructorId: "inst_3",
    instructorName: "Ali Bukhari",
    amount: 2100,
    currency: "USD",
    method: "stripe_connect",
    status: "approved",
    requestedAt: "2026-08-01T09:00:00Z"
  },
  {
    id: "PAYOUT-2026-0908",
    instructorId: "inst_4",
    instructorName: "Sana Iqbal",
    amount: 540,
    currency: "USD",
    method: "jazzcash",
    status: "paid",
    requestedAt: "2026-07-28T14:20:00Z",
    processedAt: "2026-07-30T11:00:00Z"
  },
  {
    id: "PAYOUT-2026-0902",
    instructorId: "inst_5",
    instructorName: "Zeeshan Tariq",
    amount: 310,
    currency: "USD",
    method: "bank_transfer",
    status: "rejected",
    requestedAt: "2026-07-20T12:00:00Z",
    processedAt: "2026-07-21T10:00:00Z",
    rejectionReason: "Bank details on file could not be verified."
  }
];

let payoutStore: AdminPayout[] = [...MOCK_PAYOUTS];

const PAYOUTS_KEY = ["admin", "payouts"] as const;

type PayoutFilters = {
  status?: string;
  method?: string;
  search?: string;
};

async function fetchPayouts(filters: PayoutFilters): Promise<AdminPayout[]> {
  await new Promise((r) => setTimeout(r, 350));
  return payoutStore.filter((p) => {
    const matchesStatus = !filters.status || p.status === filters.status;
    const matchesMethod = !filters.method || p.method === filters.method;
    const matchesSearch =
      !filters.search ||
      p.instructorName.toLowerCase().includes(filters.search.toLowerCase()) ||
      p.id.toLowerCase().includes(filters.search.toLowerCase());
    return matchesStatus && matchesMethod && matchesSearch;
  });
}

export function useAdminPayouts(filters: PayoutFilters = {}) {
  const key = useMemo(
    () => [...PAYOUTS_KEY, filters.status ?? "", filters.method ?? "", filters.search ?? ""],
    [filters.status, filters.method, filters.search]
  );
  return useQuery({
    queryKey: key,
    queryFn: () => fetchPayouts(filters)
  });
}

export function useProcessPayout() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; decision: "approved" | "paid" | "rejected"; reason?: string }) => {
      await new Promise((r) => setTimeout(r, 300));
      payoutStore = payoutStore.map((p) =>
        p.id === input.id
          ? {
              ...p,
              status: input.decision,
              processedAt: new Date().toISOString(),
              rejectionReason: input.decision === "rejected" ? input.reason : undefined
            }
          : p
      );
      return payoutStore.find((p) => p.id === input.id);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PAYOUTS_KEY });
    }
  });
}

export function useBatchProcessPayouts() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { ids: string[]; decision: "approved" | "paid" | "rejected" }) => {
      await new Promise((r) => setTimeout(r, 400));
      payoutStore = payoutStore.map((p) =>
        input.ids.includes(p.id) ? { ...p, status: input.decision, processedAt: new Date().toISOString() } : p
      );
      return payoutStore.filter((p) => input.ids.includes(p.id));
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: PAYOUTS_KEY });
    }
  });
}