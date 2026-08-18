"use client";

import { useEffect, useRef, useState } from "react";
import {
  DollarSign,
  BookOpen,
  MessageSquare,
  CalendarClock,
  Bell,
  RotateCcw,
  CheckCircle2,
  Mail,
  BellRing
} from "lucide-react";
import { useNotifPrefsStore, type InstructorNotifPrefs } from "@saachi/store";
import { Switch, Button, cn } from "@saachi/ui";

// â”€â”€â”€ Types â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

type PrefKey = keyof InstructorNotifPrefs;

type PrefRow = {
  key: PrefKey;
  label: string;
  description: string;
};

type PrefSection = {
  id: string;
  title: string;
  icon: typeof DollarSign;
  rows: PrefRow[];
};

// â”€â”€â”€ Config â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

const SECTIONS: PrefSection[] = [
  {
    id: "earnings",
    title: "Sales & Earnings",
    icon: DollarSign,
    rows: [
      {
        key: "newSale",
        label: "New sale",
        description: "Someone purchases one of your courses."
      },
      {
        key: "payoutApproved",
        label: "Payout approved",
        description: "Your payout request has been approved and is processing."
      },
      {
        key: "payoutRejected",
        label: "Payout rejected",
        description: "Your payout request needs attention."
      }
    ]
  },
  {
    id: "courses",
    title: "Courses",
    icon: BookOpen,
    rows: [
      {
        key: "courseApproved",
        label: "Course approved",
        description: "A submitted course passes moderation and goes live."
      },
      {
        key: "courseRejected",
        label: "Course rejected",
        description: "A submitted course needs changes before it can publish."
      },
      {
        key: "newEnrollment",
        label: "New enrollment",
        description: "Each time a learner enrolls in any of your courses."
      }
    ]
  },
  {
    id: "community",
    title: "Community",
    icon: MessageSquare,
    rows: [
      {
        key: "newQaQuestion",
        label: "New Q&A question",
        description: "A learner asks a question in your course Q&A."
      },
      {
        key: "newReview",
        label: "New review",
        description: "A learner leaves a rating or written review on your course."
      }
    ]
  },
  {
    id: "mentorship",
    title: "Mentorship",
    icon: CalendarClock,
    rows: [
      {
        key: "sessionBooked",
        label: "Session booked",
        description: "A learner books a paid mentorship session with you."
      },
      {
        key: "sessionCancelled",
        label: "Session cancelled",
        description: "A booked mentorship session is cancelled."
      }
    ]
  },
  {
    id: "system",
    title: "Platform",
    icon: Bell,
    rows: [
      {
        key: "platformAnnouncements",
        label: "Platform announcements",
        description: "Important updates about Saachi AI policies or features."
      },
      {
        key: "weeklyDigest",
        label: "Weekly digest",
        description: "A weekly email summary of your course performance."
      }
    ]
  }
];

// â”€â”€â”€ Row component â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function PrefToggleRow({
  row,
  emailValue,
  inAppValue,
  onEmailChange,
  onInAppChange
}: {
  row: PrefRow;
  emailValue: boolean;
  inAppValue: boolean;
  onEmailChange: (v: boolean) => void;
  onInAppChange: (v: boolean) => void;
}) {
  return (
    <div className="flex items-center gap-4 py-3.5 border-b border-line last:border-0">
      {/* Label */}
      <div className="min-w-0 flex-1">
        <p className="text-[13.5px] font-medium text-ink">{row.label}</p>
        <p className="text-[12px] text-ink-soft mt-0.5 leading-snug">
          {row.description}
        </p>
      </div>

      {/* Email toggle */}
      <div className="flex w-16 shrink-0 justify-center">
        <Switch
          checked={emailValue}
          onChange={() => onEmailChange(!emailValue)}
          label={`${row.label} email`}
        />
      </div>

      {/* In-app toggle */}
      <div className="flex w-16 shrink-0 justify-center">
        <Switch
          checked={inAppValue}
          onChange={() => onInAppChange(!inAppValue)}
          label={`${row.label} in-app`}
        />
      </div>
    </div>
  );
}

// â”€â”€â”€ Auto-save feedback hook â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

function useAutoSaveFeedback(deps: unknown) {
  const [saved, setSaved] = useState(false);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const isFirst = useRef(true);

  useEffect(() => {
    if (isFirst.current) {
      isFirst.current = false;
      return;
    }
    setSaved(true);
    if (timerRef.current) clearTimeout(timerRef.current);
    timerRef.current = setTimeout(() => setSaved(false), 2200);
    return () => {
      if (timerRef.current) clearTimeout(timerRef.current);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [JSON.stringify(deps)]);

  return saved;
}

// â”€â”€â”€ Main page â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

export default function InstructorSettingsNotificationsPage() {
  const prefs = useNotifPrefsStore((s) => s.prefs);
  const setChannel = useNotifPrefsStore((s) => s.setChannel);
  const resetToDefaults = useNotifPrefsStore((s) => s.resetToDefaults);

  const saved = useAutoSaveFeedback(prefs);

  return (
    <div className="mx-auto max-w-3xl">
      {/* â”€â”€ Page header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */}
      <div className="mb-8 flex flex-wrap items-start justify-between gap-3">
        <div>
          <h1 className="mb-1 font-display text-[26px] font-bold text-ink">
            Notification Preferences
          </h1>
          <p className="text-[14px] text-ink-soft">
            Choose which events send you an email or an in-app notification.
            Changes save automatically.
          </p>
        </div>

        <div className="flex items-center gap-3">
          {saved && (
            <span className="flex items-center gap-1.5 text-[12.5px] font-medium text-teal animate-in fade-in duration-200">
              <CheckCircle2 size={14} />
              Saved
            </span>
          )}
          <Button
            size="sm"
            variant="secondary"
            onClick={resetToDefaults}
          >
            <RotateCcw size={13} className="mr-1.5" />
            Reset to defaults
          </Button>
        </div>
      </div>

      {/* â”€â”€ Column headers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */}
      <div className="mb-2 flex items-center gap-4 px-1">
        <div className="flex-1" />
        <div className="flex w-16 shrink-0 flex-col items-center gap-0.5">
          <Mail size={14} className="text-ink-soft" />
          <span className="text-[10.5px] font-semibold uppercase tracking-[0.06em] text-ink-soft">
            Email
          </span>
        </div>
        <div className="flex w-16 shrink-0 flex-col items-center gap-0.5">
          <BellRing size={14} className="text-ink-soft" />
          <span className="text-[10.5px] font-semibold uppercase tracking-[0.06em] text-ink-soft">
            In-app
          </span>
        </div>
      </div>

      {/* â”€â”€ Sections â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */}
      <div className="flex flex-col gap-4">
        {SECTIONS.map((section) => {
          const Icon = section.icon;

          // Section-level "all on" state for quick-toggle header
          const allEmailOn = section.rows.every((r) => prefs[r.key].email);
          const allInAppOn = section.rows.every((r) => prefs[r.key].inApp);

          function toggleAllEmail() {
            const next = !allEmailOn;
            section.rows.forEach((r) => setChannel(r.key, "email", next));
          }

          function toggleAllInApp() {
            const next = !allInAppOn;
            section.rows.forEach((r) => setChannel(r.key, "inApp", next));
          }

          return (
            <div
              key={section.id}
              className="rounded-card border border-line bg-card overflow-hidden"
            >
              {/* Section header */}
              <div className="flex items-center gap-4 border-b border-line bg-paper-dim/60 px-5 py-3">
                <div className="flex min-w-0 flex-1 items-center gap-2">
                  <Icon size={15} className="shrink-0 text-gold-dark" />
                  <span className="text-[13px] font-semibold text-ink">
                    {section.title}
                  </span>
                </div>

                {/* Section-level quick toggles */}
                <div
                  className="flex w-16 shrink-0 justify-center"
                  title={allEmailOn ? "Disable all email" : "Enable all email"}
                >
                  <Switch
                    checked={allEmailOn}
                    onChange={toggleAllEmail}
                    label={`All ${section.title} email`}
                  />
                </div>
                <div
                  className="flex w-16 shrink-0 justify-center"
                  title={allInAppOn ? "Disable all in-app" : "Enable all in-app"}
                >
                  <Switch
                    checked={allInAppOn}
                    onChange={toggleAllInApp}
                    label={`All ${section.title} in-app`}
                  />
                </div>
              </div>

              {/* Rows */}
              <div className="px-5">
                {section.rows.map((row) => (
                  <PrefToggleRow
                    key={row.key}
                    row={row}
                    emailValue={prefs[row.key].email}
                    inAppValue={prefs[row.key].inApp}
                    onEmailChange={(v) => setChannel(row.key, "email", v)}
                    onInAppChange={(v) => setChannel(row.key, "inApp", v)}
                  />
                ))}
              </div>
            </div>
          );
        })}
      </div>

      {/* â”€â”€ Footer note â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ */}
      <p className="mt-6 text-[12px] text-ink-soft/60 text-center">
        Email notifications are sent to the address on your instructor account.
        In-app notifications appear in the bell icon in the top bar.
      </p>
    </div>
  );
}