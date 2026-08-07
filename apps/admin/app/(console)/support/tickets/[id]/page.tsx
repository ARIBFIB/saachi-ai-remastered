"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Send, CheckCircle2, AlertTriangle, StickyNote } from "lucide-react";
import {
  useAdminTicketDetail,
  useReplyToTicket,
  useAddInternalNote,
  useResolveTicket,
  useAdminCannedResponses
} from "@saachi/api-client";
import { Button, Card, Select, StatusPill, Shimmer, EmptyState } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Open", value: "open" },
  { label: "In progress", value: "in_progress" },
  { label: "Resolved", value: "resolved" },
  { label: "Closed", value: "closed" }
];

export default function SupportTicketDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { data: ticket, isLoading } = useAdminTicketDetail(params.id);
  const { data: cannedResponses } = useAdminCannedResponses();
  const reply = useReplyToTicket();
  const addNote = useAddInternalNote();
  const resolveTicket = useResolveTicket();

  const [message, setMessage] = useState("");
  const [note, setNote] = useState("");
  const [mode, setMode] = useState<"reply" | "note">("reply");

  const handleSend = () => {
    if (!ticket) return;
    if (mode === "reply" && message.trim()) {
      reply.mutate({ id: ticket.id, message: message.trim() });
      setMessage("");
    } else if (mode === "note" && note.trim()) {
      addNote.mutate({ id: ticket.id, note: note.trim() });
      setNote("");
    }
  };

  const applyCanned = (value: string) => {
    if (!value) return;
    setMode("reply");
    setMessage(value);
  };

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <Shimmer className="mb-6 h-8 w-48" />
        <Shimmer className="h-64 w-full rounded-card" />
      </main>
    );
  }

  if (!ticket) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <EmptyState icon={<AlertTriangle size={22} strokeWidth={1.75} />} title="Ticket not found" description="It may have been merged or removed." />
      </main>
    );
  }

  const overdue =
    new Date(ticket.slaDueAt).getTime() < Date.now() && ticket.status !== "resolved" && ticket.status !== "closed";

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/support/tickets")}
        className="mb-5 flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to Ticket Queue
      </button>

      <Card className="mb-6 p-6">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <h1 className="text-[19px] font-semibold text-ink">{ticket.subject}</h1>
            <p className="mt-1 text-[13px] text-ink-soft">
              {ticket.requesterName} - {ticket.category} - opened {formatRelativeTime(ticket.createdAt)}
            </p>
          </div>
          <div className="flex items-center gap-2">
            {overdue && (
              <span className="flex items-center gap-1.5 rounded-full bg-error-tint px-2.5 py-1 text-[11px] font-semibold text-error">
                <AlertTriangle size={12} strokeWidth={1.75} /> SLA overdue
              </span>
            )}
            <StatusPill label={ticket.priority} tone={ticket.priority === "urgent" || ticket.priority === "high" ? "error" : "neutral"} />
          </div>
        </div>

        <div className="mt-4 flex flex-wrap items-center gap-3">
          <div className="w-[180px]">
            <Select
              options={STATUS_OPTIONS}
              value={ticket.status}
              onChange={(e) => resolveTicket.mutate({ id: ticket.id, status: e.target.value as typeof ticket.status })}
            />
          </div>
          {ticket.status !== "resolved" && ticket.status !== "closed" && (
            <Button size="sm" variant="secondary" onClick={() => resolveTicket.mutate({ id: ticket.id, status: "resolved" })}>
              <CheckCircle2 size={14} strokeWidth={1.75} /> Mark resolved
            </Button>
          )}
        </div>
      </Card>

      <p className="mb-3 text-[14px] font-semibold text-ink">Conversation</p>
      <div className="mb-6 flex flex-col gap-3">
        {(ticket.thread ?? []).map((entry) => (
          <div
            key={entry.id}
            className={`max-w-[85%] rounded-card border p-4 ${
              entry.authorType === "staff"
                ? "ml-auto border-line-strong bg-paper-dim"
                : entry.authorType === "internal_note"
                  ? "border-warning-tint bg-warning-tint/40"
                  : "border-line bg-card"
            }`}
          >
            <div className="mb-1.5 flex items-center gap-2">
              {entry.authorType === "internal_note" && <StickyNote size={12} strokeWidth={1.75} className="text-warning" />}
              <span className="text-[12.5px] font-semibold text-ink">{entry.authorName}</span>
              <span className="text-[11px] text-ink-soft">{formatRelativeTime(entry.createdAt)}</span>
            </div>
            <p className="text-[13.5px] leading-relaxed text-ink">{entry.message}</p>
          </div>
        ))}
        {(!ticket.thread || ticket.thread.length === 0) && (
          <p className="text-[13px] text-ink-soft">No messages yet - the original request is shown above.</p>
        )}
      </div>

      <Card className="p-5">
        <div className="mb-3 flex items-center gap-2">
          <button
            type="button"
            onClick={() => setMode("reply")}
            className={`rounded-control px-3 py-1.5 text-[12.5px] font-medium transition-colors duration-150 ease-out ${
              mode === "reply" ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
            }`}
          >
            Reply to requester
          </button>
          <button
            type="button"
            onClick={() => setMode("note")}
            className={`rounded-control px-3 py-1.5 text-[12.5px] font-medium transition-colors duration-150 ease-out ${
              mode === "note" ? "bg-ink text-paper" : "bg-paper-dim text-ink-soft hover:text-ink"
            }`}
          >
            Internal note
          </button>
          {mode === "reply" && cannedResponses && cannedResponses.length > 0 && (
            <div className="ml-auto w-[220px]">
              <Select
                placeholder="Insert canned response"
                options={cannedResponses.map((c) => ({ label: c.title, value: c.body }))}
                value=""
                onChange={(e) => applyCanned(e.target.value)}
              />
            </div>
          )}
        </div>

        <textarea
          rows={4}
          value={mode === "reply" ? message : note}
          onChange={(e) => (mode === "reply" ? setMessage(e.target.value) : setNote(e.target.value))}
          placeholder={mode === "reply" ? "Write a reply to the requester..." : "Add a note visible only to staff..."}
          className="w-full rounded-control border border-line bg-card p-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
        />

        <div className="mt-3 flex justify-end">
          <Button
            size="sm"
            onClick={handleSend}
            disabled={
              (mode === "reply" && (!message.trim() || reply.isPending)) ||
              (mode === "note" && (!note.trim() || addNote.isPending))
            }
          >
            <Send size={14} strokeWidth={1.75} />
            {mode === "reply" ? (reply.isPending ? "Sending..." : "Send reply") : addNote.isPending ? "Saving..." : "Add note"}
          </Button>
        </div>
      </Card>
    </main>
  );
}