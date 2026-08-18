"use client";

import { Suspense, useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { Send, Radio, User, Clock } from "lucide-react";
import { useInstructorMessagesStore, useInstructorCourseStore } from "@saachi/store";
import { Button, Select, Textarea, EmptyState, cn } from "@saachi/ui";

// NOTE: demo-only dummy student list. Replace with useInstructorStudents() once confirmed.
const STUDENT_OPTIONS = [
  "Hina Malik",
  "Omar Sheikh",
  "Sara Iqbal",
  "Noor Fatima",
  "Ali Raza",
  "Danish Iqbal",
  "Zara Ahmed",
  "Usman Tariq"
];

type Mode = "broadcast" | "direct";

function MessageStudentsContent() {
  const searchParams = useSearchParams();
  const prefilledStudent = searchParams.get("to");

  const courses = useInstructorCourseStore((s) => s.courses);
  const messages = useInstructorMessagesStore((s) => s.messages);
  const sendMessage = useInstructorMessagesStore((s) => s.sendMessage);

  const [mode, setMode] = useState<Mode>(prefilledStudent ? "direct" : "broadcast");
  const [courseId, setCourseId] = useState(courses[0]?.id ?? "");
  const [studentName, setStudentName] = useState(prefilledStudent ?? STUDENT_OPTIONS[0]);
  const [body, setBody] = useState("");
  const [sentTick, setSentTick] = useState(0);

  const courseOptions = courses.map((c) => ({ label: c.title, value: c.id }));
  const studentOptions = STUDENT_OPTIONS.map((s) => ({ label: s, value: s }));

  const selectedCourseTitle = useMemo(
    () => courses.find((c) => c.id === courseId)?.title ?? "",
    [courses, courseId]
  );

  function handleSend() {
    if (!body.trim()) return;
    const target = mode === "broadcast" ? selectedCourseTitle : studentName;
    if (!target) return;
    sendMessage(mode, target, body.trim());
    setBody("");
    setSentTick((t) => t + 1);
    setTimeout(() => setSentTick(0), 2500);
  }

  return (
    <div>
      <div className="mb-6">
        <h1 className="mb-1 font-display text-[26px] font-bold text-ink">Message Students</h1>
        <p className="text-[14px] text-ink-soft">
          Broadcast an update to a whole course, or message a student directly.
        </p>
      </div>

      <div className="mb-6 flex gap-1.5">
        <button
          type="button"
          onClick={() => setMode("broadcast")}
          className={cn(
            "flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-[12.5px] font-semibold transition-colors duration-150 ease-out",
            mode === "broadcast" ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
          )}
        >
          <Radio size={13} />
          Broadcast to course
        </button>
        <button
          type="button"
          onClick={() => setMode("direct")}
          className={cn(
            "flex items-center gap-1.5 rounded-full px-3.5 py-1.5 text-[12.5px] font-semibold transition-colors duration-150 ease-out",
            mode === "direct" ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
          )}
        >
          <User size={13} />
          Direct message
        </button>
      </div>

      <div className="mb-8 rounded-card border border-line bg-card p-6">
        <div className="mb-4 max-w-sm">
          {mode === "broadcast" ? (
            <Select
              label="Course"
              options={courseOptions}
              value={courseId}
              onChange={(e) => setCourseId(e.target.value)}
            />
          ) : (
            <Select
              label="Student"
              options={studentOptions}
              value={studentName}
              onChange={(e) => setStudentName(e.target.value)}
            />
          )}
        </div>

        <Textarea
          label="Message"
          rows={5}
          value={body}
          onChange={(e) => setBody(e.target.value)}
          placeholder={
            mode === "broadcast"
              ? "Write an update for everyone enrolled in this course..."
              : "Write a direct message to this student..."
          }
        />

        <div className="mt-4 flex items-center gap-3">
          <Button disabled={!body.trim()} onClick={handleSend}>
            <Send size={14} className="mr-1.5" />
            {mode === "broadcast" ? "Send to course" : "Send message"}
          </Button>
          {sentTick > 0 && <span className="text-[12.5px] font-medium text-teal">Sent</span>}
        </div>
      </div>

      <h2 className="mb-4 font-display text-[18px] font-semibold text-ink">Sent messages</h2>
      {messages.length === 0 ? (
        <EmptyState title="No messages sent yet" description="Messages you send will show up here." />
      ) : (
        <div className="flex flex-col gap-3">
          {messages.map((m) => (
            <div key={m.id} className="rounded-card border border-line bg-card p-4">
              <div className="mb-1.5 flex flex-wrap items-center gap-2">
                <span
                  className={cn(
                    "flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[10.5px] font-semibold",
                    m.mode === "broadcast" ? "bg-gold-tint text-gold-dark" : "bg-teal-light text-teal"
                  )}
                >
                  {m.mode === "broadcast" ? <Radio size={10} /> : <User size={10} />}
                  {m.mode === "broadcast" ? "Broadcast" : "Direct"}
                </span>
                <span className="text-[13px] font-semibold text-ink">{m.target}</span>
                <span className="ml-auto flex items-center gap-1 text-[11.5px] text-ink-soft/60">
                  <Clock size={11} />
                  {new Intl.DateTimeFormat("en-US", { dateStyle: "medium", timeStyle: "short" }).format(
                    new Date(m.sentAt)
                  )}
                </span>
              </div>
              <p className="text-[13.5px] text-ink-soft">{m.body}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

export default function InstructorStudentsMessagesPage() {
  return (
    <Suspense fallback={null}>
      <MessageStudentsContent />
    </Suspense>
  );
}