"use client";

import { useState } from "react";
import Link from "next/link";
import { Users2, Clock, Video, CheckCircle2 } from "lucide-react";
import { Button, Card, EmptyState } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

const MENTORS = [
  {
    id: "ins_003",
    name: "Ayesha Khan",
    expertise: "AI Automation & n8n Workflows",
    avatarSeed: "ayesha-khan-instructor",
    rate: 40,
    slots: ["Mon 3:00 PM", "Wed 11:00 AM", "Fri 4:30 PM"]
  },
  {
    id: "ins_004",
    name: "Bilal Ahmed",
    expertise: "AI Customer Support Systems",
    avatarSeed: "bilal-ahmed-instructor",
    rate: 55,
    slots: ["Tue 2:00 PM", "Thu 10:00 AM"]
  },
  {
    id: "ins_006",
    name: "Usman Ali",
    expertise: "AI API Integration for Developers",
    avatarSeed: "usman-ali",
    rate: 65,
    slots: ["Mon 6:00 PM", "Wed 7:00 PM", "Sat 12:00 PM"]
  }
];

export default function MentorshipPage() {
  const [booked, setBooked] = useState<Record<string, string>>({});

  const handleBook = (mentorId: string, slot: string) => {
    setBooked((prev) => ({ ...prev, [mentorId]: slot }));
  };

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Mentorship</h1>
        <p className="mt-1 text-[14px] text-ink-soft">
          Book 1-on-1 time with an instructor for personalized guidance.
        </p>
      </div>

      <div className="flex flex-col gap-4">
        {MENTORS.map((mentor) => {
          const bookedSlot = booked[mentor.id];
          return (
            <Card key={mentor.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div className="flex items-center gap-4">
                <div className="flex h-14 w-14 shrink-0 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[16px] font-semibold text-teal">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={`https://picsum.photos/seed/${mentor.avatarSeed}/150/150`}
                    alt={mentor.name}
                    className="h-full w-full object-cover"
                  />
                </div>
                <div>
                  <p className="text-[15px] font-semibold text-ink">{mentor.name}</p>
                  <p className="text-[13px] text-ink-soft">{mentor.expertise}</p>
                  <p className="mt-1 flex items-center gap-1 text-[12px] text-ink-soft">
                    <Clock size={12} /> {formatCurrency(mentor.rate, "USD")} / 30 min session
                  </p>
                </div>
              </div>

              {bookedSlot ? (
                <div className="flex items-center gap-2 rounded-control bg-teal-light px-4 py-2.5 text-[13px] font-semibold text-teal">
                  <CheckCircle2 size={16} /> Booked for {bookedSlot}
                </div>
              ) : (
                <div className="flex flex-wrap gap-2">
                  {mentor.slots.map((slot) => (
                    <button
                      key={slot}
                      type="button"
                      onClick={() => handleBook(mentor.id, slot)}
                      className="rounded-full border border-line-strong px-3.5 py-2 text-[12px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:border-ink hover:text-ink"
                    >
                      {slot}
                    </button>
                  ))}
                </div>
              )}
            </Card>
          );
        })}
      </div>

      {Object.keys(booked).length > 0 && (
        <Card className="mt-8 flex items-center gap-3 p-5">
          <Video size={18} className="shrink-0 text-teal" />
          <p className="text-[13px] text-ink-soft">
            This is a demo booking - no real calendar invite or payment was processed. Once the
            backend Mentorship module (Doc 1, Section 6.2) is live, this will generate a real
            video-call link and checkout.
          </p>
        </Card>
      )}
    </main>
  );
}