"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

type UserDetailRole = "learner" | "instructor" | "corporate" | "admin";
type UserDetailStatus = "active" | "suspended" | "banned" | "pending";

type UserActivityLogEntry = {
  id: string;
  description: string;
  createdAt: string;
};

type UserDetailRecord = {
  id: string;
  fullName: string;
  email: string;
  avatarUrl?: string;
  role: UserDetailRole;
  status: UserDetailStatus;
  location?: string;
  joinedAt: string;
  lastActiveAt: string;
  activityLog: UserActivityLogEntry[];
};

const MOCK_USER_DETAILS: Record<string, UserDetailRecord> = {
  usr_1001: {
    id: "usr_1001",
    fullName: "Hassan Raza",
    email: "hassan.raza@example.com",
    role: "instructor",
    status: "active",
    location: "Lahore, Pakistan",
    joinedAt: "2026-02-14T00:00:00Z",
    lastActiveAt: "2026-08-07T09:30:00Z",
    activityLog: [
      { id: "act_1", description: "Published course \"AI Automation with n8n\"", createdAt: "2026-07-30T10:00:00Z" },
      { id: "act_2", description: "Requested payout PAYOUT-2026-0913", createdAt: "2026-08-05T10:12:00Z" },
      { id: "act_3", description: "Responded to a learner review", createdAt: "2026-08-01T14:20:00Z" }
    ]
  }
};

function buildFallbackUser(id: string): UserDetailRecord {
  return {
    id,
    fullName: "Demo User",
    email: `${id}@example.com`,
    role: "learner",
    status: "active",
    location: "Unknown",
    joinedAt: "2026-01-01T00:00:00Z",
    lastActiveAt: new Date().toISOString(),
    activityLog: []
  };
}

let userDetailStore: Record<string, UserDetailRecord> = { ...MOCK_USER_DETAILS };

async function fetchUserDetail(id: string): Promise<UserDetailRecord> {
  await new Promise((r) => setTimeout(r, 350));
  if (!userDetailStore[id]) {
    userDetailStore[id] = buildFallbackUser(id);
  }
  return userDetailStore[id];
}

export function useAdminUserDetailPage(id: string) {
  return useQuery({
    queryKey: ["admin", "user-detail", id],
    queryFn: () => fetchUserDetail(id),
    enabled: Boolean(id)
  });
}

export function useUpdateUserStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; status: UserDetailStatus }) => {
      await new Promise((r) => setTimeout(r, 300));
      const current = userDetailStore[input.id] ?? buildFallbackUser(input.id);
      const updated: UserDetailRecord = {
        ...current,
        status: input.status,
        activityLog: [
          {
            id: `act_${Date.now()}`,
            description: `Status changed to "${input.status}"`,
            createdAt: new Date().toISOString()
          },
          ...current.activityLog
        ]
      };
      userDetailStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "user-detail", data.id] });
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
    }
  });
}

export function useUpdateUserRole() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; role: UserDetailRole }) => {
      await new Promise((r) => setTimeout(r, 300));
      const current = userDetailStore[input.id] ?? buildFallbackUser(input.id);
      const updated: UserDetailRecord = {
        ...current,
        role: input.role,
        activityLog: [
          {
            id: `act_${Date.now()}`,
            description: `Role changed to "${input.role}"`,
            createdAt: new Date().toISOString()
          },
          ...current.activityLog
        ]
      };
      userDetailStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "user-detail", data.id] });
      queryClient.invalidateQueries({ queryKey: ["admin", "users"] });
    }
  });
}