import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_TICKETS,
  type SupportTicket,
  type TicketStatus,
  type TicketMessage
} from "../dummy-data-admin-mod-support";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Support/Helpdesk API (Doc 3).
let TICKETS_STATE: SupportTicket[] = [...ADMIN_DUMMY_TICKETS];

export const adminSupportKeys = {
  list: (filters?: Record<string, unknown>) => ["admin", "support", "tickets", filters] as const,
  detail: (id: string) => ["admin", "support", "tickets", "detail", id] as const
};

export type TicketFilters = {
  search?: string;
  status?: string;
  priority?: string;
};

export function useAdminTickets(filters: TicketFilters = {}) {
  return useQuery({
    queryKey: adminSupportKeys.list(filters),
    queryFn: async () => {
      let items = [...TICKETS_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter(
          (t) => t.subject.toLowerCase().includes(q) || t.requesterName.toLowerCase().includes(q)
        );
      }
      if (filters.status) items = items.filter((t) => t.status === filters.status);
      if (filters.priority) items = items.filter((t) => t.priority === filters.priority);
      return delay(items);
    }
  });
}

export function useAdminTicketDetail(id: string) {
  return useQuery({
    queryKey: adminSupportKeys.detail(id),
    queryFn: async () => {
      const found = TICKETS_STATE.find((t) => t.id === id);
      if (!found) throw new Error("Ticket not found");
      return delay(found);
    },
    enabled: Boolean(id)
  });
}

export function useUpdateTicketStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: TicketStatus }) => {
      TICKETS_STATE = TICKETS_STATE.map((t) => (t.id === id ? { ...t, status } : t));
      return delay({ id, status }, 300);
    },
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "support", "tickets"] });
      queryClient.invalidateQueries({ queryKey: adminSupportKeys.detail(variables.id) });
    }
  });
}

export function useAssignTicket() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, assignedTo }: { id: string; assignedTo: string }) => {
      TICKETS_STATE = TICKETS_STATE.map((t) => (t.id === id ? { ...t, assignedTo } : t));
      return delay({ id, assignedTo }, 300);
    },
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "support", "tickets"] });
      queryClient.invalidateQueries({ queryKey: adminSupportKeys.detail(variables.id) });
    }
  });
}

export function useAddTicketMessage() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body, isInternal }: { id: string; body: string; isInternal: boolean }) => {
      const message: TicketMessage = {
        id: `m_${Math.random().toString(36).slice(2, 8)}`,
        authorName: "Admin",
        isInternal,
        isStaff: true,
        body,
        createdAt: new Date().toISOString()
      };
      TICKETS_STATE = TICKETS_STATE.map((t) =>
        t.id === id ? { ...t, messages: [...t.messages, message], status: t.status === "open" ? "in_progress" : t.status } : t
      );
      return delay(message, 300);
    },
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "support", "tickets"] });
      queryClient.invalidateQueries({ queryKey: adminSupportKeys.detail(variables.id) });
    }
  });
}