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

// NOTE: demo-only seed data so the Curriculum Builder has real content to
// edit out of the box. Mirrors the dummy courses shown on
// apps/web/app/(instructor)/instructor/courses/page.tsx (crs_i1..crs_i4).
// Replace with a real fetch-and-hydrate from the backend once available.
const SEED_COURSES: InstructorCourse[] = [
  {
    id: "crs_i1",
    title: "Automate Everything with n8n & AI",
    subtitle: "Connect AI models into no-code workflows that run themselves.",
    categoryId: "ai-automation",
    language: "en",
    level: "intermediate",
    price: 39,
    currency: "USD",
    status: "published",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 140).toISOString(),
    enrollmentCount: 654,
    revenue: 8420,
    rating: 4.7,
    modules: [
      {
        id: "mod_i1_1",
        title: "n8n Basics",
        lessons: [
          { id: "les_i1_1", title: "Installing and connecting n8n", type: "video" },
          { id: "les_i1_2", title: "Your first AI node", type: "video" },
          { id: "les_i1_3", title: "Knowledge check", type: "quiz" }
        ]
      },
      {
        id: "mod_i1_2",
        title: "Five Real Automations",
        lessons: [
          { id: "les_i1_4", title: "Lead qualification bot", type: "video" },
          { id: "les_i1_5", title: "Invoice parsing pipeline", type: "video" },
          { id: "les_i1_6", title: "Starter workflow files", type: "resource" }
        ]
      }
    ]
  },
  {
    id: "crs_i2",
    title: "AI Chatbots for WhatsApp Support",
    subtitle: "Ship a working AI customer-support bot on WhatsApp.",
    categoryId: "ai-support",
    language: "en",
    level: "advanced",
    price: 59,
    currency: "USD",
    status: "pending_review",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 12).toISOString(),
    enrollmentCount: 0,
    revenue: 0,
    rating: 0,
    modules: [
      {
        id: "mod_i2_1",
        title: "WhatsApp API Setup",
        lessons: [
          { id: "les_i2_1", title: "WhatsApp Business API basics", type: "video" },
          { id: "les_i2_2", title: "Webhook configuration", type: "text" }
        ]
      },
      {
        id: "mod_i2_2",
        title: "Building the AI Layer",
        lessons: [{ id: "les_i2_3", title: "Knowledge base + retrieval", type: "video" }]
      }
    ]
  },
  {
    id: "crs_i3",
    title: "Prompt Engineering for Client Work",
    subtitle: "Practical prompting techniques for freelance and agency work.",
    categoryId: "ai-fundamentals",
    language: "en",
    level: "beginner",
    price: 29,
    currency: "USD",
    status: "draft",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 4).toISOString(),
    enrollmentCount: 0,
    revenue: 0,
    rating: 0,
    modules: [
      {
        id: "mod_i3_1",
        title: "Getting Started",
        lessons: [{ id: "les_i3_1", title: "Why prompting is a skill", type: "video" }]
      }
    ]
  },
  {
    id: "crs_i4",
    title: "Cold Outreach with Claude",
    subtitle: "AI-assisted cold email sequences that book meetings.",
    categoryId: "ai-marketing",
    language: "en",
    level: "intermediate",
    price: 35,
    currency: "USD",
    status: "draft",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 30).toISOString(),
    enrollmentCount: 0,
    revenue: 0,
    rating: 0,
    modules: []
  }
];

type InstructorCourseState = {
  courses: InstructorCourse[];
  addCourse: (course: InstructorCourse) => void;
  updateCourse: (id: string, patch: Partial<InstructorCourse>) => void;
  removeCourse: (id: string) => void;
  setModules: (courseId: string, modules: InstructorCourseModule[]) => void;
};

export const useInstructorCourseStore = create<InstructorCourseState>()(
  persist(
    (set, get) => ({
      courses: SEED_COURSES,
      addCourse: (course) => set({ courses: [course, ...get().courses] }),
      updateCourse: (id, patch) =>
        set({ courses: get().courses.map((c) => (c.id === id ? { ...c, ...patch } : c)) }),
      removeCourse: (id) => set({ courses: get().courses.filter((c) => c.id !== id) }),
      setModules: (courseId, modules) =>
        set({ courses: get().courses.map((c) => (c.id === courseId ? { ...c, modules } : c)) })
    }),
    { name: "saachi-instructor-courses" }
  )
);
