"use client";

import { useState } from "react";
import Image from "next/image";
import { Button } from "antd";
import { Clock, Video, CalendarDays } from "lucide-react";

// TODO: replace with useInstructorAvailability(instructorSlug) hook from @saachi/api-client
const timeSlots = ["9:00 AM", "10:30 AM", "1:00 PM", "2:30 PM", "4:00 PM"];
const days = ["Mon 21", "Tue 22", "Wed 23", "Thu 24", "Fri 25"];

function labelFromSlug(slug: string) {
  return slug
    .split("-")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");
}

export function MentorshipBookingClient({ instructorSlug }: { instructorSlug: string }) {
  const [selectedDay, setSelectedDay] = useState(days[0]);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);

  const mentorName = labelFromSlug(instructorSlug);

  function handleConfirmBooking() {
    if (!selectedTime) return;
    // TODO: wire to useBookMentorship() from @saachi/api-client (creates session + payment)
    console.log("book session", { instructorSlug, selectedDay, selectedTime });
  }

  return (
    <div className="mx-auto flex w-full max-w-[860px] flex-col gap-8 px-6 py-12">
      <div className="flex items-center gap-4">
        <span className="relative block h-16 w-16 shrink-0 overflow-hidden rounded-full">
          <Image src="https://i.pravatar.cc/128?img=32" alt={mentorName} fill sizes="64px" className="object-cover" />
        </span>
        <div className="flex flex-col">
          <h1 className="text-2xl font-bold" style={{ color: "var(--token-color-ink)" }}>
            Book a session with {mentorName}
          </h1>
          <p className="flex items-center gap-1 text-sm" style={{ color: "var(--token-color-inkSoft)" }}>
            <Video size={14} />
            45-min video call &bull; $60/session
          </p>
        </div>
      </div>

      <div
        className="flex flex-col gap-6 rounded-[var(--token-radius-lg)] border p-6"
        style={{ borderColor: "var(--token-color-inkDeep)", borderWidth: "2px", borderStyle: "solid", backgroundColor: "var(--token-color-surface)" }}
      >
        <div className="flex flex-col gap-3">
          <h2 className="flex items-center gap-2 text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
            <CalendarDays size={16} color="var(--token-color-amber)" />
            Select a day
          </h2>
          <div className="flex flex-wrap gap-2">
            {days.map((day) => (
              <button
                key={day}
                type="button"
                onClick={() => setSelectedDay(day)}
                className="rounded-[var(--token-radius-md)] border px-4 py-2 text-sm font-medium transition"
                style={{
                  borderColor: day === selectedDay ? "var(--token-color-amber)" : "var(--token-color-border)",
                  backgroundColor: day === selectedDay ? "var(--token-color-amberTint)" : "var(--token-color-bg)",
                  color: day === selectedDay ? "var(--token-color-amber)" : "var(--token-color-inkSoft)",
                }}
              >
                {day}
              </button>
            ))}
          </div>
        </div>

        <div className="flex flex-col gap-3">
          <h2 className="flex items-center gap-2 text-sm font-semibold" style={{ color: "var(--token-color-ink)" }}>
            <Clock size={16} color="var(--token-color-amber)" />
            Select a time
          </h2>
          <div className="flex flex-wrap gap-2">
            {timeSlots.map((time) => (
              <button
                key={time}
                type="button"
                onClick={() => setSelectedTime(time)}
                className="rounded-[var(--token-radius-md)] border px-4 py-2 text-sm font-medium transition"
                style={{
                  borderColor: time === selectedTime ? "var(--token-color-amber)" : "var(--token-color-border)",
                  backgroundColor: time === selectedTime ? "var(--token-color-amberTint)" : "var(--token-color-bg)",
                  color: time === selectedTime ? "var(--token-color-amber)" : "var(--token-color-inkSoft)",
                }}
              >
                {time}
              </button>
            ))}
          </div>
        </div>

        <div className="flex items-center justify-between border-t pt-4" style={{ borderColor: "var(--token-color-inkDeep)", borderWidth: "2px", borderStyle: "solid" }}>
          <span className="text-sm" style={{ color: "var(--token-color-inkSoft)" }}>
            {selectedTime ? `${selectedDay} at ${selectedTime}` : "Pick a day and time to continue"}
          </span>
          <Button type="primary" disabled={!selectedTime} onClick={handleConfirmBooking}>
            Confirm &amp; Pay $60
          </Button>
        </div>
      </div>
    </div>
  );
}