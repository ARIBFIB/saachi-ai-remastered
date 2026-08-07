import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_COURSES,
  ADMIN_DUMMY_CATEGORIES,
  type AdminCourse,
  type AdminCourseStatus,
  type AdminCategory
} from "../dummy-data-admin-courses";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Admin-Courses / Categories API (Doc 3).
let COURSES_STATE: AdminCourse[] = [...ADMIN_DUMMY_COURSES];
let CATEGORIES_STATE: AdminCategory[] = [...ADMIN_DUMMY_CATEGORIES];

export const adminCourseKeys = {
  all: ["admin", "courses"] as const,
  moderationQueue: ["admin", "courses", "moderation-queue"] as const,
  catalog: (filters?: Record<string, unknown>) => ["admin", "courses", "catalog", filters] as const,
  categories: ["admin", "categories"] as const
};

export function useAdminModerationQueue() {
  return useQuery({
    queryKey: adminCourseKeys.moderationQueue,
    queryFn: async () => delay(COURSES_STATE.filter((c) => c.status === "pending_review"))
  });
}

export type AdminCourseCatalogFilters = {
  search?: string;
  categoryId?: string;
  status?: string;
};

export function useAdminCourseCatalog(filters: AdminCourseCatalogFilters = {}) {
  return useQuery({
    queryKey: adminCourseKeys.catalog(filters),
    queryFn: async () => {
      let items = [...COURSES_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((c) => c.title.toLowerCase().includes(q) || c.instructorName.toLowerCase().includes(q));
      }
      if (filters.categoryId) items = items.filter((c) => c.categoryId === filters.categoryId);
      if (filters.status) items = items.filter((c) => c.status === filters.status);
      return delay(items);
    }
  });
}

export function useModerateCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      decision,
      reason
    }: {
      id: string;
      decision: "published" | "rejected";
      reason?: string;
    }) => {
      COURSES_STATE = COURSES_STATE.map((c) =>
        c.id === id ? { ...c, status: decision as AdminCourseStatus, rejectionReason: reason } : c
      );
      return delay({ id, decision }, 400);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.all });
    }
  });
}

export function useToggleCourseFlag() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, field }: { id: string; field: "featured" | "pinned" }) => {
      COURSES_STATE = COURSES_STATE.map((c) => (c.id === id ? { ...c, [field]: !c[field] } : c));
      return delay({ id, field }, 200);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.all });
    }
  });
}

export function useAdminCategoryList() {
  return useQuery({
    queryKey: adminCourseKeys.categories,
    queryFn: async () => delay([...CATEGORIES_STATE])
  });
}

export function useCreateCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { name: string; tags: string[] }) => {
      const slug = input.name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
      const created: AdminCategory = { id: slug, name: input.name, slug, courseCount: 0, tags: input.tags };
      CATEGORIES_STATE = [...CATEGORIES_STATE, created];
      return delay(created, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.categories });
    }
  });
}

export function useUpdateCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, name, tags }: { id: string; name: string; tags: string[] }) => {
      CATEGORIES_STATE = CATEGORIES_STATE.map((c) => (c.id === id ? { ...c, name, tags } : c));
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.categories });
    }
  });
}

export function useDeleteCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      CATEGORIES_STATE = CATEGORIES_STATE.filter((c) => c.id !== id);
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.categories });
    }
  });
}