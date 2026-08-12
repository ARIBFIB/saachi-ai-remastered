"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button, message } from "antd";
import { ArrowLeft, Calendar, CheckCircle2 } from "lucide-react";
import type { MentorProfile } from "./page";

interface MentorshipBookingClientProps {
  mentor: MentorProfile;
}

export function MentorshipBookingClient({ mentor }: MentorshipBookingClientProps) {
  const [selectedSlotId, setSelectedSlotId] = useState<string | null>(null);
  const [booked, setBooked] = useState(false);

  function handleConfirmBooking() {
    if (!selectedSlotId) return;
    // TODO: wire to useMentorshipSessions().book(mentor.slug, selectedSlotId) from @saachi/api-client
    setBooked(true);
    message.success("Session booked! Check your dashboard for details.");
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)] px-6 py-10 lg:px-12">
      <div className="mx-auto flex w-full max-w-[720px] flex-col gap-8">
        <Link
          href="/dashboard/mentorship"
          className="flex w-fit items-center gap-2 text-sm font-semibold text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
        >
          <ArrowLeft size={14} />
          Back to Mentorship
        </Link>

        <div className="flex items-center gap-6 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]" style={{ borderColor: "var(--token-color-border)" }}>
          <span className="relative block h-20 w-20 shrink-0 overflow-hidden rounded-full">
            <Image src={mentor.avatar} alt={mentor.name} fill sizes="80px" className="object-cover" />
          </span>
          <div className="flex flex-col gap-1">
            <h1 className="text-2xl font-bold" style={{ color: "var(--token-color-ink)" }}>
              {mentor.name}
            </h1>
            <span className="text-sm font-semibold" style={{ color: "var(--token-color-primary)" }}>
              {mentor.title}
            </span>
            <p className="pt-1 text-sm" style={{ color: "var(--token-color-inkSoft)" }}>
              {mentor.bio}
            </p>
          </div>
        </div>

        {booked ? (
          <div className="flex flex-col items-center gap-3 rounded-xl border bg-[var(--token-color-surface)] p-10 text-center shadow-[var(--token-shadow-sm)]" style={{ borderColor: "var(--token-color-border)" }}>
            <CheckCircle2 size={40} color="var(--token-color-success)" />
            <h2 className="text-xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
              Session Confirmed
            </h2>
            <p style={{ color: "var(--token-color-inkSoft)" }}>
              Your session with {mentor.name} is booked. A calendar invite will be sent shortly.
            </p>
            <Link href="/dashboard/mentorship">
              <Button type="primary">Back to Mentorship</Button>
            </Link>
          </div>
        ) : (
          <div className="flex flex-col gap-4 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]" style={{ borderColor: "var(--token-color-border)" }}>
            <div className="flex items-center justify-between">
              <h2 className="flex items-center gap-2 text-xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
                <Calendar size={18} color="var(--token-color-primary)" />
                Choose a Time
              </h2>
              <span className="text-sm font-bold" style={{ color: "var(--token-color-primary)" }}>
                {mentor.rate}
              </span>
            </div>

            <div className="flex flex-col gap-2">
              {mentor.availableSlots.map((slot) => {
                const isSelected = slot.id === selectedSlotId;
                return (
                  <button
                    key={slot.id}
                    type="button"
                    onClick={() => setSelectedSlotId(slot.id)}
                    className="flex items-center justify-between rounded-lg border px-4 py-3 text-left text-sm font-semibold transition"
                    style={{
                      borderColor: isSelected ? "var(--token-color-primary)" : "var(--token-color-border)",
                      backgroundColor: isSelected ? "var(--token-color-primaryTint)" : "var(--token-color-bg)",
                      color: isSelected ? "var(--token-color-primary)" : "var(--token-color-ink)",
                    }}
                  >
                    {slot.label}
                    {isSelected && <CheckCircle2 size={16} />}
                  </button>
                );
              })}
            </div>

            <Button
              type="primary"
              size="large"
              disabled={!selectedSlotId}
              onClick={handleConfirmBooking}
              block
            >
              Confirm Booking
            </Button>
          </div>
        )}
      </div>
    </div>
  );
}