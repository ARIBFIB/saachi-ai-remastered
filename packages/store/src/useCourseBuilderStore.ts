import { create } from "zustand";
import type { InstructorCourseModule } from "./useInstructorCourseStore";

export type CourseBuilderDraft = {
  title: string;
  subtitle: string;
  categoryId: string;
  language: string;
  level: "beginner" | "intermediate" | "advanced";
  tags: string[];
  price: number;
  currency: "USD" | "PKR" | "GBP";
  subscriptionIncluded: boolean;
  modules: InstructorCourseModule[];
  thumbnailSeed: string;
};

const EMPTY_DRAFT: CourseBuilderDraft = {
  title: "",
  subtitle: "",
  categoryId: "",
  language: "en",
  level: "beginner",
  tags: [],
  price: 0,
  currency: "USD",
  subscriptionIncluded: false,
  modules: [],
  thumbnailSeed: ""
};

type CourseBuilderState = {
  step: number;
  draft: CourseBuilderDraft;
  setStep: (step: number) => void;
  updateDraft: (patch: Partial<CourseBuilderDraft>) => void;
  addModule: () => void;
  removeModule: (moduleId: string) => void;
  updateModuleTitle: (moduleId: string, title: string) => void;
  addLesson: (moduleId: string, type: InstructorCourseModule["lessons"][number]["type"]) => void;
  removeLesson: (moduleId: string, lessonId: string) => void;
  updateLessonTitle: (moduleId: string, lessonId: string, title: string) => void;
  reset: () => void;
};

function genId(prefix: string) {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

export const useCourseBuilderStore = create<CourseBuilderState>()((set, get) => ({
  step: 1,
  draft: EMPTY_DRAFT,

  setStep: (step) => set({ step }),

  updateDraft: (patch) => set({ draft: { ...get().draft, ...patch } }),

  addModule: () =>
    set({
      draft: {
        ...get().draft,
        modules: [...get().draft.modules, { id: genId("mod"), title: "New module", lessons: [] }]
      }
    }),

  removeModule: (moduleId) =>
    set({ draft: { ...get().draft, modules: get().draft.modules.filter((m) => m.id !== moduleId) } }),

  updateModuleTitle: (moduleId, title) =>
    set({
      draft: {
        ...get().draft,
        modules: get().draft.modules.map((m) => (m.id === moduleId ? { ...m, title } : m))
      }
    }),

  addLesson: (moduleId, type) =>
    set({
      draft: {
        ...get().draft,
        modules: get().draft.modules.map((m) =>
          m.id === moduleId
            ? { ...m, lessons: [...m.lessons, { id: genId("les"), title: "New lesson", type }] }
            : m
        )
      }
    }),

  removeLesson: (moduleId, lessonId) =>
    set({
      draft: {
        ...get().draft,
        modules: get().draft.modules.map((m) =>
          m.id === moduleId ? { ...m, lessons: m.lessons.filter((l) => l.id !== lessonId) } : m
        )
      }
    }),

  updateLessonTitle: (moduleId, lessonId, title) =>
    set({
      draft: {
        ...get().draft,
        modules: get().draft.modules.map((m) =>
          m.id === moduleId
            ? { ...m, lessons: m.lessons.map((l) => (l.id === lessonId ? { ...l, title } : l)) }
            : m
        )
      }
    }),

  reset: () => set({ step: 1, draft: EMPTY_DRAFT })
}));