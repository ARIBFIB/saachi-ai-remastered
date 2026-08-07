"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, Send, CheckCircle2, UserPlus } from "lucide-react";
import {
  useAdminTicketDetail,
  useAssignTicket,
  useAddTicketMessage,
  useUpdateTicketStatus,
  type SupportTicket
} from "@saachi/api-client";
import { Button, Card, Textarea, StatusPill, Shimmer, EmptyState } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const STATUS_TONE: Record<SupportTicket["status"], "warning" | "info" | "success" | "neutral"> = {
  open: "warning",
  in_progress: "info",
  resolved: "success",
  closed: "neutral"
};

const CANNED_RESPONSES = [
  "Thanks for reaching out - we're looking into this and will follow up shortly.",
  "This has been resolved. Please let us know if the issue persists.",
  "Could you share a screenshot or more detail so we can investigate further?"
];

export default function AdminTicketDetailPage() {
  const router = useRouter();
  const params = useParams<{ id: string }>();
  const ticketId = params.id;

  const { data: ticket, isLoading } = useAdminTicketDetail(ticketId);
  const assignTicket = useAssignTicket();
  const addMessage = useAddTicketMessage();
  const updateStatus = useUpdateTicketStatus();

  const [reply, setReply] = useState("");
  const [internalNote, setInternalNote] = useState("");

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
        <EmptyState title="Ticket not found" description="This ticket may have been removed." />
      </main>
    );
  }

  const handleSendReply = () => {
    if (!reply.trim()) return;
    addMessage.mutate({ ticketId, body: reply.trim(), internal: false });
    setReply("");
  };

  const handleAddNote = () => {
    if (!internalNote.trim()) return;
    addMessage.mutate({ ticketId, body: internalNote.trim(), internal: true });
    setInternalNote("");
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/support/tickets")}
        className="mb-5 flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to queue
      </button>

      <Card className="mb-6 flex flex-col gap-3 p-6">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <div>
            <div className="flex items-center gap-2.5">
              <h1 className="text-[18px] font-semibold text-ink">{ticket.subject}</h1>
              <StatusPill label={ticket.status.replace("_", " ")} tone={STATUS_TONE[ticket.status]} />
            </div>
            <p className="mt-1 text-[12.5px] text-ink-soft">
              {ticket.requesterName} - {ticket.category} - opened {formatRelativeTime(ticket.createdAt)}
            </p>
          </div>
          <div className="flex gap-2">
            <Button size="sm" variant="secondary" onClick={() => assignTicket.mutate({ id: ticketId, assignee: "me" })}>
              <UserPlus size={14} strokeWidth={1.75} /> {ticket.assignedTo ? ticket.assignedTo : "Assign to me"}
            </Button>
            {ticket.status !== "resolved" && (
              <Button size="sm" onClick={() => updateStatus.mutate({ id: ticketId, status: "resolved" })} disabled={updateStatus.isPending}>
                <CheckCircle2 size={14} strokeWidth={1.75} /> Resolve
              </Button>
            )}
          </div>
        </div>
      </Card>

      <div className="mb-6">
        <p className="mb-3 text-[14px] font-semibold text-ink">Conversation</p>
        <Card className="divide-y divide-line p-0">
          {(ticket.messages ?? []).map((msg) => (
            <div key={msg.id} className={`px-5 py-4 ${msg.internal ? "bg-warning-tint" : ""}`}>
              <div className="mb-1 flex items-center justify-between">
                <span className="text-[13px] font-semibold text-ink">
                  {msg.authorName} {msg.internal && <span className="ml-1.5 text-[11px] font-medium text-warning">Internal note</span>}
                </span>
                <span className="text-[12px] text-ink-soft">{formatRelativeTime(msg.createdAt)}</span>
              </div>
              <p className="text-[13.5px] leading-relaxed text-ink-soft">{msg.body}</p>
            </div>
          ))}
        </Card>
      </div>

      <div className="mb-6">
        <p className="mb-2 text-[14px] font-semibold text-ink">Reply to requester</p>
        <Textarea rows={4} value={reply} onChange={(e) => setReply(e.target.value)} placeholder="Type a reply..." />
        <div className="mt-2 flex flex-wrap items-center justify-between gap-2">
          <div className="flex flex-wrap gap-1.5">
            {CANNED_RESPONSES.map((canned, i) => (
              <button
                key={i}
                type="button"
                onClick={() => setReply(canned)}
                className="rounded-full border border-line-strong px-3 py-1 text-[11.5px] text-ink-soft hover:border-ink hover:text-ink"
              >
                Canned reply {i + 1}
              </button>
            ))}
          </div>
          <Button size="sm" onClick={handleSendReply} disabled={!reply.trim() || addMessage.isPending}>
            <Send size={14} strokeWidth={1.75} /> Send reply
          </Button>
        </div>
      </div>

      <div>
        <p className="mb-2 text-[14px] font-semibold text-ink">Internal note</p>
        <Textarea rows={3} value={internalNote} onChange={(e) => setInternalNote(e.target.value)} placeholder="Visible to staff only..." />
        <div className="mt-2 flex justify-end">
          <Button size="sm" variant="secondary" onClick={handleAddNote} disabled={!internalNote.trim() || addMessage.isPending}>
            Add note
          </Button>
        </div>
      </div>
    </main>
  );
}