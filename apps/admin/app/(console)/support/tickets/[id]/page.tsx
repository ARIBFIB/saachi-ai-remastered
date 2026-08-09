"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Send, CheckCircle2, Clock, AlertTriangle, StickyNote } from "lucide-react";
import { Button, Card, StatusPill, Select, Textarea, Badge } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

type TicketStatus = "open" | "in_progress" | "resolved" | "closed";
type TicketPriority = "low" | "medium" | "high" | "urgent";

const STATUS_TONE: Record<TicketStatus, "warning" | "info" | "success" | "neutral"> = {
  open: "warning",
  in_progress: "info",
  resolved: "success",
  closed: "neutral"
};

const PRIORITY_TONE: Record<TicketPriority, "neutral" | "info" | "warning" | "error"> = {
  low: "neutral",
  medium: "info",
  high: "warning",
  urgent: "error"
};

const CANNED_RESPONSES = [
  { label: "Payout timing explanation", value: "Payouts are processed weekly in batches. Your request has been received and will be included in the next scheduled batch, typically disbursed within 3-5 business days after approval." },
  { label: "Refund policy info", value: "Our refund policy allows requests within 7 days of purchase, provided less than 30% of the course has been completed. I've forwarded your request to our Finance team for review." },
  { label: "Certificate not generated", value: "Certificates are generated automatically once all lessons and quizzes in a course are marked complete. Please confirm all sections show 100% and let us know if the issue persists." }
];

type Message = {
  id: string;
  author: string;
  role: "requester" | "staff";
  body: string;
  createdAt: string;
};

const INITIAL_THREAD: Message[] = [
  { id: "m1", author: "Ali Bukhari", role: "requester", body: "Hi, I requested a payout 5 days ago and haven't received it yet. Can someone check the status?", createdAt: "2026-08-07T22:15:00Z" },
  { id: "m2", author: "Support Desk", role: "staff", body: "Thanks for reaching out - I can see your request in the queue. Let me check with the Finance team and get back to you shortly.", createdAt: "2026-08-08T08:30:00Z" }
];

const INTERNAL_NOTES_INITIAL = [
  { id: "n1", author: "Support Desk", body: "Verified payout request PO-4471 is in this week's batch, pending Finance approval.", createdAt: "2026-08-08T08:32:00Z" }
];

// Dummy ticket - would normally be fetched by params.id
const DUMMY_TICKET = {
  subject: "Payout not received",
  requesterName: "Ali Bukhari",
  requesterEmail: "ali.bukhari@example.com",
  category: "Payments",
  priority: "high" as TicketPriority,
  slaDueAt: "2026-08-10T22:15:00Z",
  createdAt: "2026-08-07T22:15:00Z"
};

export default function SupportTicketDetailPage() {
  const params = useParams();
  const router = useRouter();
  const ticketId = params?.id as string;

  const [status, setStatus] = useState<TicketStatus>("in_progress");
  const [thread, setThread] = useState(INITIAL_THREAD);
  const [notes, setNotes] = useState(INTERNAL_NOTES_INITIAL);
  const [replyText, setReplyText] = useState("");
  const [noteText, setNoteText] = useState("");
  const [cannedValue, setCannedValue] = useState("");

  const isOverdue = new Date(DUMMY_TICKET.slaDueAt).getTime() < Date.now() && status !== "resolved" && status !== "closed";

  const sendReply = () => {
    if (!replyText.trim()) return;
    setThread((prev) => [
      ...prev,
      { id: `m${prev.length + 1}`, author: "Support Desk", role: "staff", body: replyText.trim(), createdAt: new Date().toISOString() }
    ]);
    setReplyText("");
    setCannedValue("");
    if (status === "open") setStatus("in_progress");
  };

  const addNote = () => {
    if (!noteText.trim()) return;
    setNotes((prev) => [...prev, { id: `n${prev.length + 1}`, author: "Support Desk", body: noteText.trim(), createdAt: new Date().toISOString() }]);
    setNoteText("");
  };

  const resolveTicket = () => {
    setStatus("resolved");
  };

  const applyCanned = (value: string) => {
    setCannedValue(value);
    const found = CANNED_RESPONSES.find((c) => c.value === value);
    if (found) setReplyText(found.value);
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/support/tickets")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to ticket queue
      </button>

      <Card className="mb-6 flex flex-col gap-4 p-6">
        <div className="flex flex-wrap items-start justify-between gap-4">
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[19px] font-semibold text-ink">{DUMMY_TICKET.subject}</h1>
              <StatusPill label={status.replace("_", " ")} tone={STATUS_TONE[status]} />
              <StatusPill label={DUMMY_TICKET.priority} tone={PRIORITY_TONE[DUMMY_TICKET.priority]} />
            </div>
            <p className="mt-1.5 text-[12.5px] text-ink-soft">
              {DUMMY_TICKET.requesterName} ({DUMMY_TICKET.requesterEmail}) - {DUMMY_TICKET.category} - Ticket #{ticketId}
            </p>
          </div>
          <div className="flex shrink-0 items-center gap-2">
            <div className="w-[160px]">
              <Select
                options={[
                  { label: "Open", value: "open" },
                  { label: "In progress", value: "in_progress" },
                  { label: "Resolved", value: "resolved" },
                  { label: "Closed", value: "closed" }
                ]}
                value={status}
                onChange={(e) => setStatus(e.target.value as TicketStatus)}
              />
            </div>
            {status !== "resolved" && status !== "closed" && (
              <Button size="sm" onClick={resolveTicket}>
                <CheckCircle2 size={14} strokeWidth={1.75} /> Resolve
              </Button>
            )}
          </div>
        </div>

        <div className={`flex items-center gap-2 rounded-control border px-3.5 py-2.5 text-[12.5px] ${isOverdue ? "border-error bg-error-tint text-error" : "border-line text-ink-soft"}`}>
          {isOverdue ? <AlertTriangle size={14} strokeWidth={1.75} /> : <Clock size={14} strokeWidth={1.75} />}
          SLA due {formatDate(DUMMY_TICKET.slaDueAt)} - {isOverdue ? "overdue" : formatRelativeTime(DUMMY_TICKET.slaDueAt)}
        </div>
      </Card>

      <div className="mb-6">
        <p className="mb-3 text-[14px] font-semibold text-ink">Conversation</p>
        <div className="flex flex-col gap-3">
          {thread.map((msg) => (
            <div
              key={msg.id}
              className={`max-w-[85%] rounded-card border p-4 ${
                msg.role === "staff" ? "ml-auto border-ink bg-paper-dim" : "border-line bg-card"
              }`}
            >
              <div className="mb-1.5 flex items-center justify-between gap-3">
                <span className="text-[12.5px] font-semibold text-ink">{msg.author}</span>
                <span className="text-[11px] text-ink-soft">{formatRelativeTime(msg.createdAt)}</span>
              </div>
              <p className="text-[13px] leading-relaxed text-ink">{msg.body}</p>
            </div>
          ))}
        </div>

        <Card className="mt-4 flex flex-col gap-3 p-4">
          <Select
            placeholder="Insert a canned response..."
            options={CANNED_RESPONSES.map((c) => ({ label: c.label, value: c.value }))}
            value={cannedValue}
            onChange={(e) => applyCanned(e.target.value)}
          />
          <Textarea rows={4} placeholder="Type your reply..." value={replyText} onChange={(e) => setReplyText(e.target.value)} />
          <div className="flex justify-end">
            <Button size="sm" onClick={sendReply} disabled={!replyText.trim()}>
              <Send size={14} strokeWidth={1.75} /> Send reply
            </Button>
          </div>
        </Card>
      </div>

      <div>
        <p className="mb-3 flex items-center gap-1.5 text-[14px] font-semibold text-ink">
          <StickyNote size={15} strokeWidth={1.75} /> Internal notes
        </p>
        <p className="mb-3 text-[12px] text-ink-soft">Only visible to admin staff - never shown to the requester.</p>
        <div className="mb-3 flex flex-col gap-2">
          {notes.map((note) => (
            <div key={note.id} className="rounded-control border border-warning bg-warning-tint px-3.5 py-3">
              <div className="mb-1 flex items-center justify-between gap-3">
                <span className="text-[12px] font-semibold text-ink">{note.author}</span>
                <span className="text-[11px] text-ink-soft">{formatRelativeTime(note.createdAt)}</span>
              </div>
              <p className="text-[12.5px] text-ink">{note.body}</p>
            </div>
          ))}
        </div>
        <div className="flex gap-2">
          <Textarea rows={2} placeholder="Add an internal note..." value={noteText} onChange={(e) => setNoteText(e.target.value)} className="flex-1" />
          <Button size="sm" variant="secondary" onClick={addNote} disabled={!noteText.trim()}>
            Add note
          </Button>
        </div>
      </div>
    </main>
  );
}