import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_FLAGGED_REVIEWS,
  ADMIN_DUMMY_FLAGGED_FORUM_POSTS,
  type FlaggedReview,
  type FlaggedForumPost,
  type FlagStatus
} from "../dummy-data-admin-mod-support";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Content Moderation API (Doc 3).
let FLAGGED_REVIEWS_STATE: FlaggedReview[] = [...ADMIN_DUMMY_FLAGGED_REVIEWS];
let FLAGGED_FORUM_STATE: FlaggedForumPost[] = [...ADMIN_DUMMY_FLAGGED_FORUM_POSTS];

export const adminModerationKeys = {
  reviews: (filters?: Record<string, unknown>) => ["admin", "moderation", "reviews", filters] as const,
  forum: (filters?: Record<string, unknown>) => ["admin", "moderation", "forum", filters] as const
};

export type ModerationFilters = {
  status?: string;
};

export function useFlaggedReviews(filters: ModerationFilters = {}) {
  return useQuery({
    queryKey: adminModerationKeys.reviews(filters),
    queryFn: async () => {
      let items = [...FLAGGED_REVIEWS_STATE];
      if (filters.status) items = items.filter((r) => r.status === filters.status);
      return delay(items);
    }
  });
}

export function useResolveFlaggedReview() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: FlagStatus }) => {
      FLAGGED_REVIEWS_STATE = FLAGGED_REVIEWS_STATE.map((r) => (r.id === id ? { ...r, status } : r));
      return delay({ id, status }, 350);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "moderation", "reviews"] });
    }
  });
}

export function useFlaggedForumPosts(filters: ModerationFilters = {}) {
  return useQuery({
    queryKey: adminModerationKeys.forum(filters),
    queryFn: async () => {
      let items = [...FLAGGED_FORUM_STATE];
      if (filters.status) items = items.filter((p) => p.status === filters.status);
      return delay(items);
    }
  });
}

export function useResolveFlaggedForumPost() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: FlagStatus }) => {
      FLAGGED_FORUM_STATE = FLAGGED_FORUM_STATE.map((p) => (p.id === id ? { ...p, status } : p));
      return delay({ id, status }, 350);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "moderation", "forum"] });
    }
  });
}