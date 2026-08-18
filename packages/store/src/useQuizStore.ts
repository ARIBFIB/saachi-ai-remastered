import { create } from "zustand";
import { persist } from "zustand/middleware";

// â”€â”€â”€ Types â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

export type QuizOption = {
  id: string;
  text: string;
};

export type QuizQuestion = {
  id: string;
  questionText: string;
  options: QuizOption[];
  correctOptionId: string;
  explanation: string;
};

export type QuizLesson = {
  id: string;
  courseId: string;
  moduleId: string;
  title: string;
  description: string;
  questions: QuizQuestion[];
  updatedAt: string;
};

// â”€â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function genId(prefix: string): string {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

function now(): string {
  return new Date().toISOString();
}

function blankOption(): QuizOption {
  return { id: genId("opt"), text: "" };
}

function blankQuestion(): QuizQuestion {
  const optA = blankOption();
  const optB = blankOption();
  const optC = blankOption();
  const optD = blankOption();
  return {
    id: genId("q"),
    questionText: "",
    options: [optA, optB, optC, optD],
    correctOptionId: optA.id,
    explanation: ""
  };
}

// â”€â”€â”€ Seed (demo) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const SEED_QUIZZES: QuizLesson[] = [
  {
    id: "quiz_demo_1",
    courseId: "crs_i1",
    moduleId: "mod_i1_1",
    title: "n8n Basics Check",
    description: "Quick knowledge check after the n8n fundamentals module.",
    updatedAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 3).toISOString(),
    questions: [
      {
        id: "q_demo_1",
        questionText: "What is the primary purpose of an n8n workflow?",
        options: [
          { id: "opt_a", text: "To write backend API code" },
          { id: "opt_b", text: "To visually connect services and automate tasks" },
          { id: "opt_c", text: "To host static websites" },
          { id: "opt_d", text: "To manage DNS records" }
        ],
        correctOptionId: "opt_b",
        explanation: "n8n is a no-code/low-code automation platform that lets you connect different services visually and automate repetitive tasks."
      },
      {
        id: "q_demo_2",
        questionText: "Which node type in n8n is used to trigger a workflow based on an incoming HTTP request?",
        options: [
          { id: "opt_e", text: "Schedule Trigger" },
          { id: "opt_f", text: "Webhook" },
          { id: "opt_g", text: "Manual Trigger" },
          { id: "opt_h", text: "Email Trigger" }
        ],
        correctOptionId: "opt_f",
        explanation: "The Webhook node listens for incoming HTTP requests and uses them to trigger the workflow automatically."
      }
    ]
  }
];

// â”€â”€â”€ Store â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

type QuizState = {
  quizzes: QuizLesson[];

  /** Upsert a whole quiz (create or replace by id) */
  saveQuiz: (quiz: QuizLesson) => void;

  /** Delete a quiz by id */
  deleteQuiz: (quizId: string) => void;

  /** Get all quizzes for a given course */
  getQuizzesForCourse: (courseId: string) => QuizLesson[];

  /** Get a specific quiz by id */
  getQuiz: (quizId: string) => QuizLesson | undefined;
};

export const useQuizStore = create<QuizState>()(
  persist(
    (set, get) => ({
      quizzes: SEED_QUIZZES,

      saveQuiz: (quiz) => {
        const exists = get().quizzes.some((q) => q.id === quiz.id);
        if (exists) {
          set({ quizzes: get().quizzes.map((q) => (q.id === quiz.id ? quiz : q)) });
        } else {
          set({ quizzes: [...get().quizzes, quiz] });
        }
      },

      deleteQuiz: (quizId) => {
        set({ quizzes: get().quizzes.filter((q) => q.id !== quizId) });
      },

      getQuizzesForCourse: (courseId) =>
        get().quizzes.filter((q) => q.courseId === courseId),

      getQuiz: (quizId) => get().quizzes.find((q) => q.id === quizId)
    }),
    { name: "saachi-quizzes" }
  )
);

// â”€â”€â”€ Exported helpers (used by the page) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

export { genId, blankQuestion, blankOption };