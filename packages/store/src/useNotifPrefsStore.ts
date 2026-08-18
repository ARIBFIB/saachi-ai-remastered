import { create } from "zustand";
import { persist } from "zustand/middleware";

// â”€â”€â”€ Types â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

export type NotifChannel = {
  email: boolean;
  inApp: boolean;
};

export type InstructorNotifPrefs = {
  // Sales & Earnings
  newSale: NotifChannel;
  payoutApproved: NotifChannel;
  payoutRejected: NotifChannel;

  // Courses
  courseApproved: NotifChannel;
  courseRejected: NotifChannel;
  newEnrollment: NotifChannel;

  // Community
  newQaQuestion: NotifChannel;
  newReview: NotifChannel;

  // Mentorship
  sessionBooked: NotifChannel;
  sessionCancelled: NotifChannel;

  // System
  platformAnnouncements: NotifChannel;
  weeklyDigest: NotifChannel;
};

type NotifPrefsState = {
  prefs: InstructorNotifPrefs;
  setChannel: (
    key: keyof InstructorNotifPrefs,
    channel: "email" | "inApp",
    value: boolean
  ) => void;
  resetToDefaults: () => void;
};

// â”€â”€â”€ Defaults â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const DEFAULTS: InstructorNotifPrefs = {
  newSale:               { email: true,  inApp: true  },
  payoutApproved:        { email: true,  inApp: true  },
  payoutRejected:        { email: true,  inApp: true  },
  courseApproved:        { email: true,  inApp: true  },
  courseRejected:        { email: true,  inApp: true  },
  newEnrollment:         { email: false, inApp: true  },
  newQaQuestion:         { email: true,  inApp: true  },
  newReview:             { email: false, inApp: true  },
  sessionBooked:         { email: true,  inApp: true  },
  sessionCancelled:      { email: true,  inApp: true  },
  platformAnnouncements: { email: true,  inApp: false },
  weeklyDigest:          { email: true,  inApp: false },
};

// â”€â”€â”€ Store â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

export const useNotifPrefsStore = create<NotifPrefsState>()(
  persist(
    (set) => ({
      prefs: { ...DEFAULTS },

      setChannel: (key, channel, value) =>
        set((state) => ({
          prefs: {
            ...state.prefs,
            [key]: { ...state.prefs[key], [channel]: value }
          }
        })),

      resetToDefaults: () => set({ prefs: { ...DEFAULTS } })
    }),
    { name: "saachi-notif-prefs" }
  )
);