import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { courseKeys } from "../query-keys";
import type { Course, CourseDetail, Paginated } from "../types";
import { DUMMY_COURSES, type DummyCourse } from "../dummy-data";

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

function delay<T>(value: T, ms = 400): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

function toSummary(course: DummyCourse): Course {
  return {
    id: course.id,
    slug: course.slug,
    title: course.title,
    subtitle: course.subtitle,
    thumbnailUrl: course.thumbnailUrl,
    price: course.price,
    currency: course.currency,
    rating: course.rating,
    ratingCount: course.ratingCount,
    instructor: course.instructor,
    status: course.status
  };
}

export function useCourseList(filters: CourseListFilters = {}) {
  return useQuery({
    queryKey: courseKeys.list(filters),
    queryFn: async () => {
      let items = [...DUMMY_COURSES];

      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter(
          (c) => c.title.toLowerCase().includes(q) || c.instructor.fullName.toLowerCase().includes(q)
        );
      }
      if (filters.category) {
        items = items.filter((c) => c.categoryId === filters.category);
      }
      if (filters.level) {
        items = items.filter((c) => c.level === filters.level);
      }
      if (filters.language) {
        items = items.filter((c) => c.language === filters.language);
      }
      if (typeof filters.priceMin === "number") {
        items = items.filter((c) => c.price >= (filters.priceMin as number));
      }
      if (typeof filters.priceMax === "number") {
        items = items.filter((c) => c.price <= (filters.priceMax as number));
      }

      switch (filters.sort) {
        case "newest":
          items = [...items].reverse();
          break;
        case "price_asc":
          items = [...items].sort((a, b) => a.price - b.price);
          break;
        case "price_desc":
          items = [...items].sort((a, b) => b.price - a.price);
          break;
        case "rating":
          items = [...items].sort((a, b) => b.rating - a.rating);
          break;
        case "popular":
        default:
          items = [...items].sort((a, b) => b.ratingCount - a.ratingCount);
      }

      const page = filters.page ?? 1;
      const pageSize = 12;
      const start = (page - 1) * pageSize;
      const pageItems = items.slice(start, start + pageSize).map(toSummary);

      return delay<Paginated<Course>>({
        items: pageItems,
        total: items.length,
        page,
        pageSize
      });
    }
  });
}

export function useCourseDetail(idOrSlug: string) {
  return useQuery({
    queryKey: courseKeys.detail(idOrSlug),
    queryFn: async () => {
      const found = DUMMY_COURSES.find((c) => c.slug === idOrSlug || c.id === idOrSlug);
      if (!found) throw new Error("Course not found");
      const { categoryId, level, language, ...detail } = found;
      return delay<CourseDetail>(detail);
    },
    enabled: Boolean(idOrSlug)
  });
}

export function useCreateCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: Partial<Course>) => {
      const created: Course = {
        id: `crs_${Math.random().toString(36).slice(2, 8)}`,
        slug: (input.slug as string) ?? "new-course",
        title: input.title ?? "Untitled course",
        price: input.price ?? 0,
        currency: input.currency ?? "USD",
        rating: 0,
        ratingCount: 0,
        instructor: input.instructor ?? { id: "ins_demo", fullName: "Demo Instructor" },
        status: "draft"
      };
      return delay(created);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: courseKeys.all });
    }
  });
}

export function useUpdateCourse(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: Partial<Course>) => {
      const existing = DUMMY_COURSES.find((c) => c.id === id);
      const base: Course = existing
        ? toSummary(existing)
        : {
            id,
            slug: id,
            title: "Untitled",
            price: 0,
            currency: "USD",
            rating: 0,
            ratingCount: 0,
            instructor: { id: "ins_demo", fullName: "Demo Instructor" },
            status: "draft"
          };
      const updated: Course = { ...base, ...input };
      return delay(updated);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: courseKeys.detail(id) });
      queryClient.invalidateQueries({ queryKey: courseKeys.all });
    }
  });
}