import { create } from "zustand";
import { persist } from "zustand/middleware";

export type EnrollmentRecord = {
  courseId: string;
  slug: string;
  title: string;
  thumbnailUrl?: string;
  instructorName: string;
  progressPercent: number;
  purchasedAt: string;
  completedLessonIds: string[];
};

type EnrollmentState = {
  enrollments: EnrollmentRecord[];
  isEnrolled: (courseId: string) => boolean;
  enroll: (records: Omit<EnrollmentRecord, "progressPercent" | "purchasedAt" | "completedLessonIds">[]) => void;
  markLessonComplete: (courseId: string, lessonId: string, totalLessons: number) => void;
  getEnrollment: (courseId: string) => EnrollmentRecord | undefined;
};

export const useEnrollmentStore = create<EnrollmentState>()(
  persist(
    (set, get) => ({
      enrollments: [],

      isEnrolled: (courseId) => get().enrollments.some((e) => e.courseId === courseId),

      getEnrollment: (courseId) => get().enrollments.find((e) => e.courseId === courseId),

      enroll: (records) => {
        const now = new Date().toISOString();
        const existingIds = new Set(get().enrollments.map((e) => e.courseId));
        const fresh = records
          .filter((r) => !existingIds.has(r.courseId))
          .map((r) => ({ ...r, progressPercent: 0, purchasedAt: now, completedLessonIds: [] as string[] }));
        if (fresh.length === 0) return;
        set({ enrollments: [...get().enrollments, ...fresh] });
      },

      markLessonComplete: (courseId, lessonId, totalLessons) => {
        set({
          enrollments: get().enrollments.map((e) => {
            if (e.courseId !== courseId) return e;
            const completedLessonIds = e.completedLessonIds.includes(lessonId)
              ? e.completedLessonIds
              : [...e.completedLessonIds, lessonId];
            const progressPercent =
              totalLessons > 0 ? Math.round((completedLessonIds.length / totalLessons) * 100) : 0;
            return { ...e, completedLessonIds, progressPercent };
          })
        });
      }
    }),
    { name: "saachi-enrollments" }
  )
);