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
  courseTitle?: string;
  authorName: string;
  body: string;
  createdAt: string;
  upvotes: number;
  answers: CommunityAnswer[];
};

// NOTE: demo-only seed data. The first two questions mirror the public
// marketplace dummy courses (crs_001 etc.); the ones below are tied to the
// instructor's own demo courses (crs_i1..crs_i3, see
// packages/store/src/useInstructorCourseStore.ts) so the Instructor ->
// Community Q&A screen has realistic unanswered questions to reply to.
const SEED_QUESTIONS: CommunityQuestion[] = [
  {
    id: "q_1",
    courseId: "crs_001",
    courseTitle: "Prompt Engineering Fundamentals",
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
    courseTitle: "Prompt Engineering Fundamentals",
    authorName: "Bilal Ahmed",
    body: "Does the prompt library template work with Claude and Gemini too, or is it ChatGPT-specific?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 10).toISOString(),
    upvotes: 2,
    answers: []
  },
  {
    id: "q_i1",
    courseId: "crs_i1",
    courseTitle: "Automate Everything with n8n & AI",
    authorName: "Omar Sheikh",
    body: "Does the invoice parsing workflow from module 2 work on n8n cloud, or only self-hosted?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 5).toISOString(),
    upvotes: 4,
    answers: []
  },
  {
    id: "q_i2",
    courseId: "crs_i1",
    courseTitle: "Automate Everything with n8n & AI",
    authorName: "Noor Fatima",
    body: "I'm getting a rate-limit error on the OpenAI node when the workflow runs on a schedule. Any tips on handling that gracefully?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 14).toISOString(),
    upvotes: 3,
    answers: []
  },
  {
    id: "q_i3",
    courseId: "crs_i1",
    courseTitle: "Automate Everything with n8n & AI",
    authorName: "Ali Raza",
    body: "Thanks for the lead-qualification workflow, saved me hours already! Quick question - is there a way to route hot leads straight to WhatsApp instead of Slack?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 40).toISOString(),
    upvotes: 7,
    answers: [
      {
        id: "a_i3_1",
        authorName: "Ayesha Khan",
        isInstructor: true,
        body: "Glad it helped! Yes - swap the Slack node for a WhatsApp Business API node and map the same fields, it's a drop-in replacement.",
        createdAt: new Date(Date.now() - 1000 * 60 * 60 * 36).toISOString(),
        upvotes: 5
      }
    ]
  },
  {
    id: "q_i4",
    courseId: "crs_i2",
    courseTitle: "AI Chatbots for WhatsApp Support",
    authorName: "Sara Iqbal",
    body: "How long did WhatsApp Business API approval take for you? Mine has been pending for 4 days.",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 8).toISOString(),
    upvotes: 5,
    answers: []
  },
  {
    id: "q_i5",
    courseId: "crs_i3",
    courseTitle: "Prompt Engineering for Client Work",
    authorName: "Danish Iqbal",
    body: "Is there a template for pitching this to clients who don't know what prompt engineering even is?",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 60).toISOString(),
    upvotes: 2,
    answers: []
  }
];

type CommunityState = {
  questions: CommunityQuestion[];
  addQuestion: (courseId: string, authorName: string, body: string, courseTitle?: string) => void;
  addAnswer: (questionId: string, authorName: string, body: string, isInstructor?: boolean) => void;
  upvoteQuestion: (questionId: string) => void;
};

function genId(prefix: string) {
  return `${prefix}_${Math.random().toString(36).slice(2, 9)}`;
}

export const useCommunityStore = create<CommunityState>()(
  persist(
    (set, get) => ({
      questions: SEED_QUESTIONS,

      addQuestion: (courseId, authorName, body, courseTitle) => {
        const newQuestion: CommunityQuestion = {
          id: genId("q"),
          courseId,
          courseTitle,
          authorName,
          body,
          createdAt: new Date().toISOString(),
          upvotes: 0,
          answers: []
        };
        set({ questions: [newQuestion, ...get().questions] });
      },

      addAnswer: (questionId, authorName, body, isInstructor = false) => {
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
                      isInstructor,
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
