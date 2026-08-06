import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { apiRequest } from "../http-client";
import { courseKeys } from "../query-keys";
import type { Course, CourseDetail, Paginated } from "../types";

export type CourseListFilters = {
  category?: string;
  search?: string;
  priceMin?: number;
  priceMax?: number;
  level?: string;
  language?: string;
  sort?: string;
  page?: number;
};

export function useCourseList(filters: CourseListFilters = {}) {
  return useQuery({
    queryKey: courseKeys.list(filters),
    queryFn: () =>
      apiRequest<Paginated<Course>>("/courses", { params: filters as Record<string, any> })
  });
}

export function useCourseDetail(idOrSlug: string) {
  return useQuery({
    queryKey: courseKeys.detail(idOrSlug),
    queryFn: () => apiRequest<CourseDetail>(`/courses/${idOrSlug}`),
    enabled: Boolean(idOrSlug)
  });
}

export function useCreateCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<Course>) =>
      apiRequest<Course>("/courses", { method: "POST", body: input }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: courseKeys.all });
    }
  });
}

export function useUpdateCourse(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: Partial<Course>) =>
      apiRequest<Course>(`/courses/${id}`, { method: "PATCH", body: input }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: courseKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: courseKeys.all });
    }
  });
}
