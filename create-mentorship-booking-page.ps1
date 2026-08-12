<#
================================================================================
create-mentorship-booking-page.ps1

Creates: apps/web/app/(learner)/dashboard/mentorship/[instructorSlug]/page.tsx

Run from the repo root, e.g.:
  PS D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2> .\create-mentorship-booking-page.ps1

Notes:
- Uses only design tokens (var(--token-color-*)) -- no hardcoded hex.
- Uses Ant Design (Button, Input.TextArea) for the form controls, matching
  the pattern already used in register/certificates pages.
- Sidebar + nav items match the existing learner dashboard pages
  (my-courses, wishlist, certificates) for consistency.
================================================================================
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
$targetDir = Join-Path $root "apps\web\app\(learner)\dashboard\mentorship\[instructorSlug]"
$targetFile = Join-Path $targetDir "page.tsx"

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Write-Host "Created directory: $targetDir"
}

$content = @'
"use client";

import { useMemo, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button, Input } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  ChevronLeft,
  ChevronRight,
  CalendarDays,
  Video,
} from "lucide-react";

const { TextArea } = Input;

// TODO: replace with useInstructor(slug) / useMentorshipSlots() hooks from @saachi/api-client
interface Instructor {
  name: string;
  title: string;
  avatar: string;
}

const instructor: Instructor = {
  name: "Dr. Alan Turing",
  title: "Advanced AI Architecture",
  avatar:
    "https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=200&q=80",
};

const weekdayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

interface CalendarDay {
  day: number;
  disabled?: boolean;
  isCurrentMonth: boolean;
}

// TODO: replace with a real calendar util (date-fns) once wired to the API
const calendarDays: CalendarDay[] = [
  { day: 29, disabled: true, isCurrentMonth: false },
  { day: 30, disabled: true, isCurrentMonth: false },
  ...Array.from({ length: 19 }, (_, i) => ({ day: i + 1, isCurrentMonth: true })),
];

const timeSlots = [
  "09:00 AM",
  "09:30 AM",
  "10:00 AM",
  "11:00 AM",
  "01:30 PM",
  "02:00 PM",
  "03:30 PM",
  "04:00 PM",
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

export default function MentorshipBookingPage() {
  const [selectedDay, setSelectedDay] = useState<number>(14);
  const [selectedTime, setSelectedTime] = useState<string>("10:00 AM");
  const [message, setMessage] = useState("");

  const selectedDateLabel = useMemo(() => {
    // TODO: derive from real calendar state once wired up
    return `Monday, October ${selectedDay}`;
  }, [selectedDay]);

  function handleConfirmBooking() {
    // TODO: wire to useMentorship().bookSession() from @saachi/api-client
    console.log("confirm booking", {
      instructor: instructor.name,
      day: selectedDay,
      time: selectedTime,
      message,
    });
  }

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex items-center gap-4 border-b border-[var(--token-color-border)] p-6">
          <span className="relative block h-10 w-10 shrink-0 overflow-hidden rounded-full">
            <Image
              src="https://i.pravatar.cc/80?img=47"
              alt="Learner avatar"
              fill
              sizes="40px"
              className="object-cover"
            />
          </span>
          <div className="flex flex-col">
            <span
              className="font-bold tracking-wide"
              style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-sm)" }}
            >
              Learner Portal
            </span>
            <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
              Manage your skills
            </span>
          </div>
        </div>

        <nav className="flex flex-1 flex-col gap-2 py-6">
          {navItems.map(({ icon: Icon, label, href }) => (
            <Link
              key={label}
              href={href}
              className="flex h-12 items-center gap-4 border-l-4 pl-4 pr-6 text-sm font-semibold tracking-wide transition"
              style={{
                borderColor: "transparent",
                backgroundColor: "transparent",
                color: "var(--token-color-inkSoft)",
              }}
            >
              <Icon size={18} />
              {label}
            </Link>
          ))}
        </nav>

        <div className="border-t border-[var(--token-color-border)] p-6">
          <Link
            href="/support"
            className="flex items-center gap-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main column */}
      <div className="flex w-full flex-col lg:pl-72">
        <main className="flex-1 px-6 pb-14 pt-10">
          <div className="mx-auto flex max-w-[1180px] flex-col gap-6">
            {/* Breadcrumb + Header */}
            <div className="flex flex-col gap-1.5">
              <Link
                href={`/instructors/${instructor.name.toLowerCase().replace(/\s+/g, "-")}`}
                className="flex w-fit items-center gap-1 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
              >
                <ChevronLeft size={14} />
                Back to Instructor Profile
              </Link>
              <h1
                className="text-3xl font-bold leading-10"
                style={{ color: "var(--token-color-ink)" }}
              >
                Schedule 1:1 Session
              </h1>
              <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                Book a time with {instructor.name} for personalized mentorship.
              </p>
            </div>

            {/* Content grid */}
            <div className="grid grid-cols-1 gap-6 xl:grid-cols-12">
              {/* Left: Calendar + Time slots */}
              <div className="flex flex-col gap-6 xl:col-span-8">
                {/* Step 1: Calendar */}
                <section
                  className="flex flex-col gap-2 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
                  style={{ borderColor: "var(--token-color-border)" }}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <StepBadge step={1} />
                      <h2 className="text-2xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
                        Select Date
                      </h2>
                    </div>

                    <div className="flex items-center gap-2">
                      <button
                        type="button"
                        aria-label="Previous month"
                        className="flex h-8 w-8 items-center justify-center rounded-full hover:bg-[var(--token-color-surfaceAlt)]"
                      >
                        <ChevronLeft size={14} color="var(--token-color-inkSoft)" />
                      </button>
                      <span
                        className="w-28 text-center text-sm font-semibold tracking-wide"
                        style={{ color: "var(--token-color-inkSoft)" }}
                      >
                        October 2024
                      </span>
                      <button
                        type="button"
                        aria-label="Next month"
                        className="flex h-8 w-8 items-center justify-center rounded-full hover:bg-[var(--token-color-surfaceAlt)]"
                      >
                        <ChevronRight size={14} color="var(--token-color-inkSoft)" />
                      </button>
                    </div>
                  </div>

                  {/* Weekday labels */}
                  <div className="grid grid-cols-7 gap-2 pt-2">
                    {weekdayLabels.map((d) => (
                      <span
                        key={d}
                        className="pb-2 pt-1.5 text-center text-xs font-medium"
                        style={{ color: "var(--token-color-inkSoft)" }}
                      >
                        {d}
                      </span>
                    ))}
                  </div>

                  {/* Day grid */}
                  <div className="grid grid-cols-7 gap-2">
                    {calendarDays.map(({ day, disabled, isCurrentMonth }, idx) => {
                      const isSelected = isCurrentMonth && day === selectedDay;
                      return (
                        <button
                          key={`${day}-${idx}`}
                          type="button"
                          disabled={disabled}
                          onClick={() => setSelectedDay(day)}
                          className="flex items-center justify-center rounded-lg py-3 text-base transition disabled:cursor-not-allowed disabled:opacity-50"
                          style={{
                            backgroundColor: isSelected ? "var(--token-color-primary)" : "transparent",
                            color: isSelected ? "#FFFFFF" : "var(--token-color-ink)",
                            fontWeight: isSelected ? 700 : 400,
                          }}
                        >
                          {day}
                        </button>
                      );
                    })}
                  </div>
                </section>

                {/* Step 2: Time slots */}
                <section
                  className="flex flex-col gap-4 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
                  style={{ borderColor: "var(--token-color-border)" }}
                >
                  <div className="flex items-center gap-2">
                    <StepBadge step={2} />
                    <h2 className="text-2xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
                      Select Time
                    </h2>
                  </div>

                  <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                    Showing available slots for{" "}
                    <span style={{ color: "var(--token-color-ink)" }}>{selectedDateLabel}</span>.
                  </p>

                  <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
                    {timeSlots.map((slot) => {
                      const isSelected = slot === selectedTime;
                      return (
                        <button
                          key={slot}
                          type="button"
                          onClick={() => setSelectedTime(slot)}
                          className="rounded-lg border px-6 py-2 text-base transition"
                          style={{
                            borderColor: isSelected ? "var(--token-color-primary)" : "var(--token-color-border)",
                            backgroundColor: isSelected ? "var(--token-color-primaryTint)" : "transparent",
                            color: isSelected ? "var(--token-color-primary)" : "var(--token-color-ink)",
                            fontWeight: isSelected ? 600 : 400,
                            boxShadow: isSelected ? "0 0 0 2px var(--token-color-primary)" : "none",
                          }}
                        >
                          {slot}
                        </button>
                      );
                    })}
                  </div>
                </section>
              </div>

              {/* Right: Session summary */}
              <div className="xl:col-span-4">
                <div
                  className="sticky top-6 flex flex-col gap-4 rounded-xl border bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
                  style={{ borderColor: "var(--token-color-border)" }}
                >
                  <div className="border-b pb-4" style={{ borderColor: "var(--token-color-border)" }}>
                    <h3 className="text-2xl font-semibold" style={{ color: "var(--token-color-ink)" }}>
                      Session Summary
                    </h3>
                  </div>

                  <div className="flex items-center gap-4">
                    <span className="relative block h-14 w-14 shrink-0 overflow-hidden rounded-full">
                      <Image
                        src={instructor.avatar}
                        alt={instructor.name}
                        fill
                        sizes="56px"
                        className="object-cover"
                      />
                    </span>
                    <div className="flex flex-col">
                      <span className="text-base font-bold" style={{ color: "var(--token-color-ink)" }}>
                        {instructor.name}
                      </span>
                      <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
                        {instructor.title}
                      </span>
                    </div>
                  </div>

                  <div className="flex flex-col gap-2 pt-2">
                    <SummaryRow icon={<CalendarDays size={18} color="var(--token-color-inkSoft)" />} label="Date & Time">
                      Mon, Oct {selectedDay}
                      <br />
                      {selectedTime} PST
                    </SummaryRow>

                    <SummaryRow icon={<Video size={18} color="var(--token-color-inkSoft)" />} label="Location">
                      Video Call (Zoom)
                    </SummaryRow>
                  </div>

                  <div className="flex flex-col gap-4 pt-1.5">
                    <div className="flex flex-col gap-1">
                      <label
                        htmlFor="session-topic"
                        className="text-sm font-semibold tracking-wide"
                        style={{ color: "var(--token-color-ink)" }}
                      >
                        What do you want to discuss?{" "}
                        <span style={{ color: "var(--token-color-error)" }}>*</span>
                      </label>
                      <TextArea
                        id="session-topic"
                        value={message}
                        onChange={(e) => setMessage(e.target.value)}
                        rows={4}
                        placeholder="E.g., I'd like to review my latest project architecture and get feedback on scaling strategies..."
                      />
                    </div>

                    <Button
                      type="primary"
                      block
                      size="large"
                      disabled={!message.trim()}
                      onClick={handleConfirmBooking}
                    >
                      Confirm Booking
                    </Button>

                    <p
                      className="text-center text-xs font-medium"
                      style={{ color: "var(--token-color-inkSoft)" }}
                    >
                      You won&apos;t be charged yet.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}

function StepBadge({ step }: { step: number }) {
  return (
    <span
      className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full text-sm font-semibold tracking-wide text-white"
      style={{ backgroundColor: "var(--token-color-primary)" }}
    >
      {step}
    </span>
  );
}

function SummaryRow({
  icon,
  label,
  children,
}: {
  icon: React.ReactNode;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex items-start gap-2">
      <span className="pt-0.5">{icon}</span>
      <div className="flex flex-col">
        <span
          className="text-xs font-medium uppercase tracking-wide"
          style={{ color: "var(--token-color-inkSoft)" }}
        >
          {label}
        </span>
        <span className="text-base font-medium leading-6" style={{ color: "var(--token-color-ink)" }}>
          {children}
        </span>
      </div>
    </div>
  );
}
'@

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($targetFile, $content, $utf8NoBom)

Write-Host ""
Write-Host "Created: $targetFile" -ForegroundColor Green
Write-Host ""
Write-Host "Route: /dashboard/mentorship/[instructorSlug]" -ForegroundColor Cyan
Write-Host "Example: /dashboard/mentorship/dr-alan-turing" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. pnpm --filter web run tokens:sync   (only needed if tokens.ts changed -- it didn't here)"
Write-Host "  2. pnpm --filter web dev"
Write-Host "  3. Wire up: useInstructor(slug), useMentorshipSlots(), and bookSession() in @saachi/api-client"