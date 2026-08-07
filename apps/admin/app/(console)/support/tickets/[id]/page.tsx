"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Send, Lock, CheckCircle2, XCircle } from "lucide-react";
import {
  useAdminTicketDetail,
  useUpdateTicketStatus,
  useAssignTicket,
  useAddTicketMessage,
  type SupportTicket
} from "@saachi/api-client";
import { Button, Card, Textarea, StatusPill, Shimmer } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

const STATUS_TONE: Record<SupportTicket["status"], "warning" | "info" | "success" | "neutral"> = {
  open: "warning",
  in_progress: "info",
  resolved: "success",
  closed: "neutral"
};

const PRIORITY_TONE: Record<SupportTicket["priority"], "neutral" | "info" | "warning" | "error"> = {
  low: "neutral",
  medium: "info",
  high: "warning",
  urgent: "error"
};

const CANNED_RESPONSES = [
  "Thanks for reaching out - we're looking into this now and will update you shortly.",
  "This has been resolved on our end - please refresh and let us know if the issue persists.",
  "Could you share a screenshot or the order ID so we can investigate further?"
];

export default function SupportTicketDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { data: ticket, isLoading } = useAdminTicketDetail(params.id);
  const updateStatus = useUpdateTicketStatus();
  const assignTicket = useAssignTicket();
  const addMessage = useAddTicketMessage();

  const [reply, setReply] = useState("");
  const [internalNote, setInternalNote] = useState("");

  if (isLoading || !ticket) {
    return (
      <main className="mx-auto max-w-[800px] px-4 py-8 md:px-8 md:py-10">
        <Shimmer className="mb-6 h-8 w-64" />
        <Shimmer className="h-64 w-full" />
      </main>
    );
  }

  const handleSendReply = () => {
    if (!reply.trim()) return;
    addMessage.mutate({ id: ticket.id, body: reply.trim(), isInternal: false });
    setReply("");
  };

  const handleAddNote = () => {
    if (!internalNote.trim()) return;
    addMessage.mutate({ id: ticket.id, body: internalNote.trim(), isInternal: true });
    setInternalNote("");
  };

  return (
    <main className="mx-auto max-w-[800px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/support/tickets")}
        className="mb-5 flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to queue
      </button>

      <div className="mb-6 flex flex-wrap items-start justify-between gap-3">
        <div>
          <div className="flex flex-wrap items-center gap-2.5">
            <h1 className="text-[20px] font-semibold text-ink">{ticket.subject}</h1>
            <StatusPill label={ticket.status.replace("_", " ")} tone={STATUS_TONE[ticket.status]} />
            <StatusPill label={ticket.priority} tone={PRIORITY_TONE[ticket.priority]} />
          </div>
          <p className="mt-1 text-[13px] text-ink-soft">
            {ticket.requesterName} ({ticket.requesterEmail}) - {ticket.category} - opened {formatDate(ticket.createdAt)}
          </p>
        </div>
      </div>

      <Card className="mb-6 flex flex-wrap items-center gap-3 p-4">
        <span className="text-[12.5px] text-ink-soft">
          Assigned to: <span className="font-semibold text-ink">{ticket.assignedTo ?? "Unassigned"}</span>
        </span>
        {!ticket.assignedTo && (
          <Button size="sm" variant="secondary" onClick={() => assignTicket.mutate({ id: ticket.id, assignedTo: "admin@saachi.ai" })}>
            Assign to me
          </Button>
        )}
        <div className="ml-auto flex gap-2">
          {ticket.status !== "resolved" && (
            <Button size="sm" variant="secondary" onClick={() => updateStatus.mutate({ id: ticket.id, status: "resolved" })}>
              <CheckCircle2 size={14} strokeWidth={1.75} /> Mark resolved
            </Button>
          )}
          {ticket.status !== "closed" && (
            <Button size="sm" variant="ghost" onClick={() => updateStatus.mutate({ id: ticket.id, status: "closed" })}>
              <XCircle size={14} strokeWidth={1.75} /> Close ticket
            </Button>
          )}
        </div>
      </Card>

      <div className="mb-6 flex flex-col gap-3">
        {ticket.messages.map((message) => (
          <div
            key={message.id}
            className={
              message.isInternal
                ? "rounded-control border border-warning/30 bg-warning-tint p-4"
                : message.isStaff
                  ? "rounded-control border border-line bg-paper-dim p-4"
                  : "rounded-control border border-line bg-card p-4"
            }
          >
            <div className="mb-1.5 flex items-center gap-2 text-[12px] text-ink-soft">
              <span className="font-semibold text-ink">{message.authorName}</span>
              {message.isInternal && (
                <span className="flex items-center gap-1 text-[11px] font-semibold uppercase tracking-[0.04em] text-warning">
                  <Lock size={10} strokeWidth={2} /> Internal note
                </span>
              )}
              <span>- {formatDate(message.createdAt)}</span>
            </div>
            <p className="text-[13.5px] leading-relaxed text-ink">{message.body}</p>
          </div>
        ))}
      </div>

      <Card className="mb-4 p-5">
        <h2 className="mb-3 text-[14px] font-semibold text-ink">Reply to requester</h2>
        <div className="mb-3 flex flex-wrap gap-2">
          {CANNED_RESPONSES.map((c, i) => (
            <button
              key={i}
              type="button"
              onClick={() => setReply(c)}
              className="rounded-full border border-line-strong px-3 py-1.5 text-[12px] font-medium text-ink-soft hover:border-ink hover:text-ink"
            >
              Canned response {i + 1}
            </button>
          ))}
        </div>
        <Textarea rows={4} value={reply} onChange={(e) => setReply(e.target.value)} placeholder="Type your reply..." />
        <div className="mt-3 flex justify-end">
          <Button size="sm" onClick={handleSendReply} disabled={!reply.trim() || addMessage.isPending}>
            <Send size={14} strokeWidth={1.75} /> Send reply
          </Button>
        </div>
      </Card>

      <Card className="p-5">
        <h2 className="mb-3 flex items-center gap-1.5 text-[14px] font-semibold text-ink">
          <Lock size={13} strokeWidth={1.75} /> Internal note (not visible to requester)
        </h2>
        <Textarea rows={3} value={internalNote} onChange={(e) => setInternalNote(e.target.value)} placeholder="Add a note for other staff..." />
        <div className="mt-3 flex justify-end">
          <Button size="sm" variant="secondary" onClick={handleAddNote} disabled={!internalNote.trim() || addMessage.isPending}>
            Add note
          </Button>
        </div>
      </Card>
    </main>
  );
}