"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { CalendarDays, Clock } from "lucide-react";
import { Button, Card, EmptyState } from "@saachi/ui";

type MentorSlot = {
  id: string;
  instructorName: string;
  expertise: string;
  rate: string;
  slots: string[];
};

const MENTORS: MentorSlot[] = [
  {
    id: "m1",
    instructorName: "Ayesha Khan",
    expertise: "AI Automation & Workflow Tools",
    rate: "$40 / 30 min",
    slots: ["Mon 10:00 AM", "Wed 2:00 PM", "Fri 11:00 AM"]
  },
  {
    id: "m2",
    instructorName: "Hamza Malik",
    expertise: "AI Integration for Developers",
    rate: "$55 / 45 min",
    slots: ["Tue 4:00 PM", "Thu 9:00 AM"]
  }
];

export default function MentorshipBookingPage() {
  const [selectedMentor, setSelectedMentor] = useState<string | null>(null);
  const [selectedSlot, setSelectedSlot] = useState<string | null>(null);
  const [booked, setBooked] = useState(false);

  const mentor = useMemo(() => MENTORS.find((m) => m.id === selectedMentor), [selectedMentor]);

  function handleBook() {
    if (!mentor || !selectedSlot) return;
    // NOTE: demo-only booking, no payment/calendar integration wired up yet.
    setBooked(true);
  }

  if (booked && mentor) {
    return (
      <div className="mx-auto max-w-lg py-16 text-center">
        <EmptyState
          title="Session booked"
          description={`Your session with ${mentor.instructorName} on ${selectedSlot} is confirmed. Check My Mentorship Sessions for the call link.`}
          action={
            <Link href="/mentorship/sessions">
              <Button>View my sessions</Button>
            </Link>
          }
        />
      </div>
    );
  }

  return (
    <div>
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Book mentorship</h1>
      <p className="mb-8 text-[14px] text-ink-soft">1-on-1 sessions with verified instructors.</p>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        {MENTORS.map((m) => (
          <Card
            key={m.id}
            className={`cursor-pointer p-5 transition-colors ${
              selectedMentor === m.id ? "border-gold-dark/60" : ""
            }`}
            onClick={() => {
              setSelectedMentor(m.id);
              setSelectedSlot(null);
            }}
          >
            <h3 className="text-[15px] font-semibold text-ink">{m.instructorName}</h3>
            <p className="mt-1 text-[13px] text-ink-soft">{m.expertise}</p>
            <p className="mt-2 font-mono text-[14px] font-semibold text-ink">{m.rate}</p>
          </Card>
        ))}
      </div>

      {mentor && (
        <div className="mt-8 rounded-card border border-line bg-card p-6">
          <h2 className="mb-4 flex items-center gap-2 text-[15px] font-semibold text-ink">
            <CalendarDays size={16} />
            Available slots with {mentor.instructorName}
          </h2>
          <div className="flex flex-wrap gap-2">
            {mentor.slots.map((slot) => (
              <button
                key={slot}
                type="button"
                onClick={() => setSelectedSlot(slot)}
                className={`flex items-center gap-1.5 rounded-control border px-3 py-2 text-[13px] font-medium transition-colors ${
                  selectedSlot === slot
                    ? "border-gold-dark bg-gold-tint text-ink"
                    : "border-line text-ink-soft hover:bg-paper-dim"
                }`}
              >
                <Clock size={13} />
                {slot}
              </button>
            ))}
          </div>

          <Button className="mt-6" disabled={!selectedSlot} onClick={handleBook}>
            Confirm booking
          </Button>
        </div>
      )}
    </div>
  );
}