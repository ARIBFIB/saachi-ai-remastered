import { create } from "zustand";
import { persist } from "zustand/middleware";

export type SentMessage = {
  id: string;
  mode: "broadcast" | "direct";
  target: string; // course title (broadcast) or student name (direct)
  body: string;
  sentAt: string;
};

// NOTE: demo-only seed data. Replace with real Messaging API once available.
const SEED_MESSAGES: SentMessage[] = [
  {
    id: "msg_1",
    mode: "broadcast",
    target: "Automate Everything with n8n & AI",
    body: "New bonus module on error handling just went live - check it out!",
    sentAt: new Date(Date.now() - 1000 * 60 * 60 * 24 * 3).toISOString()
  },
  {
    id: "msg_2",
    mode: "direct",
    target: "Sara Iqbal",
    body: "Hey Sara, noticed you paused at module 2 - let me know if you're stuck on anything!",
    sentAt: new Date(Date.now() - 1000 * 60 * 60 * 24).toISOString()
  }
];

type InstructorMessagesState = {
  messages: SentMessage[];
  sendMessage: (mode: "broadcast" | "direct", target: string, body: string) => void;
};

export const useInstructorMessagesStore = create<InstructorMessagesState>()(
  persist(
    (set, get) => ({
      messages: SEED_MESSAGES,
      sendMessage: (mode, target, body) => {
        const newMessage: SentMessage = {
          id: `msg_${Math.random().toString(36).slice(2, 9)}`,
          mode,
          target,
          body,
          sentAt: new Date().toISOString()
        };
        set({ messages: [newMessage, ...get().messages] });
      }
    }),
    { name: "saachi-instructor-messages" }
  )
);