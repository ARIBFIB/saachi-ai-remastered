import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_USERS,
  getAdminActivityLog,
  getAdminAuditLog,
  type AdminUser,
  type AdminUserStatus
} from "../dummy-data-admin";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Admin-Users API (Doc 3) once available.
let USERS_STATE: AdminUser[] = [...ADMIN_DUMMY_USERS];

export const adminUserKeys = {
  all: ["admin", "users"] as const,
  list: (filters?: Record<string, unknown>) => ["admin", "users", "list", filters] as const,
  detail: (id: string) => ["admin", "users", "detail", id] as const,
  activity: (id: string) => ["admin", "users", "activity", id] as const,
  audit: (id: string) => ["admin", "users", "audit", id] as const
};

export type AdminUserListFilters = {
  search?: string;
  role?: string;
  status?: string;
};

export function useAdminUserList(filters: AdminUserListFilters = {}) {
  return useQuery({
    queryKey: adminUserKeys.list(filters),
    queryFn: async () => {
      let items = [...USERS_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((u) => u.fullName.toLowerCase().includes(q) || u.email.toLowerCase().includes(q));
      }
      if (filters.role) items = items.filter((u) => u.role === filters.role);
      if (filters.status) items = items.filter((u) => u.status === filters.status);
      return delay(items);
    }
  });
}

export function useAdminUserDetail(id: string) {
  return useQuery({
    queryKey: adminUserKeys.detail(id),
    queryFn: async () => {
      const found = USERS_STATE.find((u) => u.id === id);
      if (!found) throw new Error("User not found");
      return delay(found);
    },
    enabled: Boolean(id)
  });
}

export function useAdminUserActivity(id: string) {
  return useQuery({
    queryKey: adminUserKeys.activity(id),
    queryFn: async () => delay(getAdminActivityLog(id)),
    enabled: Boolean(id)
  });
}

export function useAdminUserAudit(id: string) {
  return useQuery({
    queryKey: adminUserKeys.audit(id),
    queryFn: async () => delay(getAdminAuditLog(id)),
    enabled: Boolean(id)
  });
}

export function useUpdateAdminUserStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: AdminUserStatus }) => {
      USERS_STATE = USERS_STATE.map((u) => (u.id === id ? { ...u, status } : u));
      return delay({ id, status }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminUserKeys.all });
    }
  });
}

export function useUpdateAdminUserRole() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, role }: { id: string; role: AdminUser["role"] }) => {
      USERS_STATE = USERS_STATE.map((u) => (u.id === id ? { ...u, role } : u));
      return delay({ id, role }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminUserKeys.all });
    }
  });
}