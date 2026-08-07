import { create } from "zustand";
import { persist } from "zustand/middleware";

export type CommunityAnswer = {
  id: string;
  authorName: string;
  isInstructor: boolean;
  body: string;
  createdAt: string;
  upvotes: number;
};

export type CommunityQuestion = {
  id: string;
  courseId: string;
  authorName: string;
  body: string;
  createdAt: string;
  upvotes: number;
  answers: CommunityAnswer[];
};

const SEED_QUESTIONS: CommunityQuestion[] = [
  {
    id: "q_1",
    courseId: "crs_001",
    authorName: "Hina Malik",
    body: "For few-shot prompting, how many examples is usually enough before it stops improving results?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 30).toISOString(),
    upvotes: 6,
    answers: [
      {
        id: "a_1",
        authorName: "Sana Rizvi",
        isInstructor: true,
        body: "Usually 3-5 well-chosen examples get you most of the benefit - past that you're often better off improving instructions instead.",
        createdAt: new Date(Date.now() - 1000 * 60 * 60 * 20).toISOString(),
        upvotes: 9
      }
    ]
  },
  {
    id: "q_2",
    courseId: "crs_001",
    authorName: "Bilal Ahmed",
    body: "Does the prompt library template work with Claude and Gemini too, or is it ChatGPT-specific?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 10).toISOString(),
    upvotes: 2,
    answers: []
  }
];

type CommunityState = {
  questions: CommunityQuestion[];
  addQuestion: (courseId: string, authorName: string, body: string) => void;
  addAnswer: (questionId: string, authorName: string, body: string) => void;
  upvoteQuestion: (questionId: string) => void;
};

function genId(prefix: string) {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

export const useCommunityStore = create<CommunityState>()(
  persist(
    (set, get) => ({
      questions: SEED_QUESTIONS,

      addQuestion: (courseId, authorName, body) => {
        const newQuestion: CommunityQuestion = {
          id: genId("q"),
          courseId,
          authorName,
          body,
          createdAt: new Date().toISOString(),
          upvotes: 0,
          answers: []
        };
        set({ questions: [newQuestion, ...get().questions] });
      },

      addAnswer: (questionId, authorName, body) => {
        set({
          questions: get().questions.map((q) =>
            q.id === questionId
              ? {
                  ...q,
                  answers: [
                    ...q.answers,
                    {
                      id: genId("a"),
                      authorName,
                      isInstructor: false,
                      body,
                      createdAt: new Date().toISOString(),
                      upvotes: 0
                    }
                  ]
                }
              : q
          )
        });
      },

      upvoteQuestion: (questionId) => {
        set({
          questions: get().questions.map((q) =>
            q.id === questionId ? { ...q, upvotes: q.upvotes + 1 } : q
          )
        });
      }
    }),
    { name: "saachi-community" }
  )
);