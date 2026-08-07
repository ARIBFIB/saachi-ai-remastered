import { create } from "zustand";
import { persist } from "zustand/middleware";

export type TeamMember = {
  id: string;
  name: string;
  email: string;
  status: "invited" | "active";
  assignedCourseIds: string[];
  completedCourseIds: string[];
};

export type CorporateAccount = {
  companyName: string;
  seatsPurchased: number;
  seatsUsed: number;
};

const SEED_TEAM: TeamMember[] = [
  {
    id: "tm_1",
    name: "Zainab Rehman",
    email: "zainab@acmeagency.com",
    status: "active",
    assignedCourseIds: ["crs_001", "crs_002"],
    completedCourseIds: ["crs_001"]
  },
  {
    id: "tm_2",
    name: "Ali Raza",
    email: "ali@acmeagency.com",
    status: "active",
    assignedCourseIds: ["crs_003"],
    completedCourseIds: []
  },
  {
    id: "tm_3",
    name: "Mahnoor Fatima",
    email: "mahnoor@acmeagency.com",
    status: "invited",
    assignedCourseIds: [],
    completedCourseIds: []
  }
];

type CorporateState = {
  account: CorporateAccount;
  team: TeamMember[];
  inviteMember: (name: string, email: string) => void;
  removeMember: (id: string) => void;
  assignCourse: (memberId: string, courseId: string) => void;
  purchaseSeats: (count: number) => void;
};

export const useCorporateStore = create<CorporateState>()(
  persist(
    (set, get) => ({
      account: { companyName: "Acme Agency", seatsPurchased: 10, seatsUsed: 3 },
      team: SEED_TEAM,

      inviteMember: (name, email) => {
        const newMember: TeamMember = {
          id: `tm_${Math.random().toString(36).slice(2, 9)}`,
          name,
          email,
          status: "invited",
          assignedCourseIds: [],
          completedCourseIds: []
        };
        set({
          team: [...get().team, newMember],
          account: { ...get().account, seatsUsed: get().account.seatsUsed + 1 }
        });
      },

      removeMember: (id) => {
        set({
          team: get().team.filter((m) => m.id !== id),
          account: { ...get().account, seatsUsed: Math.max(0, get().account.seatsUsed - 1) }
        });
      },

      assignCourse: (memberId, courseId) => {
        set({
          team: get().team.map((m) =>
            m.id === memberId && !m.assignedCourseIds.includes(courseId)
              ? { ...m, assignedCourseIds: [...m.assignedCourseIds, courseId] }
              : m
          )
        });
      },

      purchaseSeats: (count) => {
        set({ account: { ...get().account, seatsPurchased: get().account.seatsPurchased + count } });
      }
    }),
    { name: "saachi-corporate" }
  )
);