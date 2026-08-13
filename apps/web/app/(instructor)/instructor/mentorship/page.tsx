"use client";

import { useState } from "react";
import { CalendarDays, Plus, Trash2 } from "lucide-react";
import { Button, Input, Select, EmptyState } from "@saachi/ui";

type Slot = { id: string; day: string; time: string };

const DAY_OPTIONS = [
  { label: "Monday", value: "Mon" },
  { label: "Tuesday", value: "Tue" },
  { label: "Wednesday", value: "Wed" },
  { label: "Thursday", value: "Thu" },
  { label: "Friday", value: "Fri" },
  { label: "Saturday", value: "Sat" },
  { label: "Sunday", value: "Sun" }
];

let slotCounter = 0;

export default function InstructorMentorshipSettingsPage() {
  const [enabled, setEnabled] = useState(false);
  const [hourlyRate, setHourlyRate] = useState("40");
  const [sessionLength, setSessionLength] = useState("30");
  const [day, setDay] = useState("Mon");
  const [time, setTime] = useState("");
  const [slots, setSlots] = useState<Slot[]>([]);
  const [saved, setSaved] = useState(false);

  function addSlot() {
    if (!time.trim()) return;
    slotCounter += 1;
    setSlots((prev) => [...prev, { id: `slot${slotCounter}`, day, time }]);
    setTime("");
  }

  function removeSlot(id: string) {
    setSlots((prev) => prev.filter((s) => s.id !== id));
  }

  function handleSave() {
    // NOTE: demo-only, no backend mentorship-settings mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Mentorship Settings</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Offer paid 1-on-1 mentorship sessions to learners.</p>

      <div className="mb-6 flex items-center justify-between rounded-card border border-line bg-card p-5">
        <div>
          <p className="text-[14px] font-semibold text-ink">Enable mentorship</p>
          <p className="text-[13px] text-ink-soft">Allow learners to book paid sessions with you.</p>
        </div>
        <input
          type="checkbox"
          checked={enabled}
          onChange={(e) => setEnabled(e.target.checked)}
          aria-label="Toggle mentorship availability"
          className="h-4 w-4 accent-gold-dark"
        />
      </div>

      {enabled && (
        <>
          <div className="mb-6 grid grid-cols-1 gap-4 rounded-card border border-line bg-card p-5 sm:grid-cols-2">
            <Input label="Hourly rate (USD)" type="number" value={hourlyRate} onChange={(e) => setHourlyRate(e.target.value)} />
            <Select
              label="Session length (minutes)"
              options={[
                { label: "30 minutes", value: "30" },
                { label: "45 minutes", value: "45" },
                { label: "60 minutes", value: "60" }
              ]}
              value={sessionLength}
              onChange={(e) => setSessionLength(e.target.value)}
            />
          </div>

          <div className="rounded-card border border-line bg-card p-5">
            <h2 className="mb-3 flex items-center gap-2 text-[15px] font-semibold text-ink">
              <CalendarDays size={16} />
              Weekly availability
            </h2>

            {slots.length === 0 ? (
              <EmptyState title="No availability set" description="Add time slots when learners can book you." />
            ) : (
              <ul className="mb-4 flex flex-col gap-2">
                {slots.map((s) => (
                  <li key={s.id} className="flex items-center justify-between rounded-control bg-paper-dim px-3 py-2 text-[13px] text-ink">
                    {s.day} â€” {s.time}
                    <button type="button" onClick={() => removeSlot(s.id)} aria-label="Remove slot" className="text-ink-soft hover:text-error">
                      <Trash2 size={14} />
                    </button>
                  </li>
                ))}
              </ul>
            )}

            <div className="flex flex-wrap items-end gap-2">
              <Select options={DAY_OPTIONS} value={day} onChange={(e) => setDay(e.target.value)} className="w-36" />
              <Input value={time} onChange={(e) => setTime(e.target.value)} placeholder="e.g. 10:00 AM" className="w-40" />
              <Button variant="secondary" onClick={addSlot}>
                <Plus size={14} className="mr-1.5" />
                Add slot
              </Button>
            </div>
          </div>
        </>
      )}

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save settings"}
      </Button>
    </div>
  );
}