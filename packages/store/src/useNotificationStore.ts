import { create } from "zustand";
import { persist } from "zustand/middleware";

export type NotificationItem = {
  id: string;
  title: string;
  body: string;
  createdAt: string;
  read: boolean;
  type: "course" | "system" | "community" | "payment";
};

const SEED_NOTIFICATIONS: NotificationItem[] = [
  {
    id: "ntf_1",
    title: "Welcome to Saachi AI",
    body: "Your account is ready. Explore practical AI courses to get started.",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString(),
    read: false,
    type: "system"
  },
  {
    id: "ntf_2",
    title: "New reply in Prompt Engineering Fundamentals",
    body: "An instructor answered your question in the course Q&A.",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 26).toISOString(),
    read: false,
    type: "community"
  },
  {
    id: "ntf_3",
    title: "Course completed",
    body: "You finished all lessons in a course. Your certificate is ready.",
    createdAt: new Date(Date.now() - 1000 * 60 * 60 * 72).toISOString(),
    read: true,
    type: "course"
  }
];

type NotificationState = {
  items: NotificationItem[];
  markAllRead: () => void;
  markRead: (id: string) => void;
};

export const useNotificationStore = create<NotificationState>()(
  persist(
    (set, get) => ({
      items: SEED_NOTIFICATIONS,
      markAllRead: () => set({ items: get().items.map((n) => ({ ...n, read: true })) }),
      markRead: (id) =>
        set({ items: get().items.map((n) => (n.id === id ? { ...n, read: true } : n)) })
    }),
    { name: "saachi-notifications" }
  )
);