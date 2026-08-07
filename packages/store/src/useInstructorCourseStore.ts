import { create } from "zustand";
import { persist } from "zustand/middleware";

export type InstructorCourseLesson = {
  id: string;
  title: string;
  type: "video" | "text" | "quiz" | "resource";
};

export type InstructorCourseModule = {
  id: string;
  title: string;
  lessons: InstructorCourseLesson[];
};

export type InstructorCourse = {
  id: string;
  title: string;
  subtitle: string;
  categoryId: string;
  language: string;
  level: "beginner" | "intermediate" | "advanced";
  price: number;
  currency: string;
  status: "draft" | "pending_review" | "published";
  modules: InstructorCourseModule[];
  createdAt: string;
  enrollmentCount: number;
  revenue: number;
  rating: number;
};

type InstructorCourseState = {
  courses: InstructorCourse[];
  addCourse: (course: InstructorCourse) => void;
  updateCourse: (id: string, patch: Partial<InstructorCourse>) => void;
  removeCourse: (id: string) => void;
};

export const useInstructorCourseStore = create<InstructorCourseState>()(
  persist(
    (set, get) => ({
      courses: [],
      addCourse: (course) => set({ courses: [course, ...get().courses] }),
      updateCourse: (id, patch) =>
        set({ courses: get().courses.map((c) => (c.id === id ? { ...c, ...patch } : c)) }),
      removeCourse: (id) => set({ courses: get().courses.filter((c) => c.id !== id) })
    }),
    { name: "saachi-instructor-courses" }
  )
);