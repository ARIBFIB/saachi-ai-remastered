"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { ArrowLeft, LifeBuoy, Send, CheckCircle2, AlertTriangle } from "lucide-react";
import {
  useAdminTicketDetail,
  useReplyToTicket,
  useAddInternalNote,
  useResolveTicket,
  useAssignTicket,
  type SupportTicket
} from "@saachi/api-client";
import { Button, Card, Select, StatusPill, Shimmer, Textarea, EmptyState, Badge } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Open", value: "open" },
  { label: "In progress", value: "in_progress" },
  { label: "Resolved", value: "resolved" },
  { label: "Closed", value: "closed" }
];

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
  { label: "Ask for order/transaction ID", value: "Could you please share your order or transaction ID so we can look into this further?" },
  { label: "Refund policy explanation", value: "Refund requests are reviewed within 7 days of purchase, subject to course completion below 30%." },
  { label: "Escalated to finance", value: "Thanks for the details - I have escalated this to our finance team and will follow up shortly." }
];

export default function SupportTicketDetailPage() {
  const router = useRouter();
  const params = useParams<{ id: string }>();
  const ticketId = params.id;

  const { data: ticket, isLoading } = useAdminTicketDetail(ticketId);
  const replyToTicket = useReplyToTicket();
  const addInternalNote = useAddInternalNote();
  const resolveTicket = useResolveTicket();
  const assignTicket = useAssignTicket();

  const [reply, setReply] = useState("");
  const [note, setNote] = useState("");
  const [mode, setMode] = useState<"reply" | "note">("reply");

  if (isLoading) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <Shimmer className="mb-6 h-10 w-48" />
        <Shimmer className="mb-4 h-32 w-full rounded-card" />
        <Shimmer className="h-64 w-full rounded-card" />
      </main>
    );
  }

  if (!ticket) {
    return (
      <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
        <EmptyState icon={<LifeBuoy size={22} strokeWidth={1.75} />} title="Ticket not found" description="This ticket may have been removed." />
      </main>
    );
  }

  const overdue =
    new Date(ticket.slaDueAt).getTime() < Date.now() && ticket.status !== "resolved" && ticket.status !== "closed";

  const handleSend = () => {
    if (mode === "reply") {
      if (!reply.trim()) return;
      replyToTicket.mutate({ id: ticket.id, message: reply.trim() });
      setReply("");
    } else {
      if (!note.trim()) return;
      addInternalNote.mutate({ id: ticket.id, note: note.trim() });
      setNote("");
    }
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/support/tickets")}
        className="mb-5 flex items-center gap-1.5 text-[13px] font-medium text-ink-soft hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to Ticket Queue
      </button>

      <Card className="mb-5 flex flex-col gap-4 p-6">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[18px] font-semibold text-ink">{ticket.subject}</h1>
              <StatusPill label={ticket.status.replace("_", " ")} tone={STATUS_TONE[ticket.status]} />
              <StatusPill label={ticket.priority} tone={PRIORITY_TONE[ticket.priority]} />
              {overdue && (
                <span className="flex items-center gap-1 text-[12px] font-medium text-error">
                  <AlertTriangle size={12} strokeWidth={1.75} /> SLA overdue
                </span>
              )}
            </div>
            <p className="mt-1.5 text-[12.5px] text-ink-soft">
              {ticket.requesterName} - {ticket.category} - opened {formatRelativeTime(ticket.createdAt)}
            </p>
          </div>

          {ticket.status !== "resolved" && ticket.status !== "closed" && (
            <Button size="sm" onClick={() => resolveTicket.mutate(ticket.id)} disabled={resolveTicket.isPending}>
              <CheckCircle2 size={14} strokeWidth={1.75} /> {resolveTicket.isPending ? "Resolving..." : "Mark resolved"}
            </Button>
          )}
        </div>

        <div className="flex flex-wrap items-center gap-3 border-t border-line pt-4">
          <div className="w-[220px]">
            <Select
              label="Assigned to"
              placeholder="Unassigned"
              options={[
                { label: "Support Desk", value: "support_desk" },
                { label: "Finance Desk", value: "finance_desk" },
                { label: "Abdul Rehman Irfan", value: "abdulrehman" }
              ]}
              value={ticket.assignedTo ?? ""}
              onChange={(e) => assignTicket.mutate({ id: ticket.id, assignedTo: e.target.value })}
            />
          </div>
        </div>
      </Card>

      <Card className="mb-5 flex flex-col gap-4 p-6">
        <p className="text-[14px] font-semibold text-ink">Conversation</p>
        <div className="flex flex-col gap-4">
          {ticket.messages.map((msg) => (
            <div
              key={msg.id}
              className={`flex flex-col gap-1 rounded-control border p-3.5 text-[13.5px] leading-relaxed ${
                msg.isInternalNote
                  ? "border-warning-tint bg-warning-tint/60"
                  : msg.fromStaff
                  ? "border-line bg-paper-dim"
                  : "border-line bg-card"
              }`}
            >
              <div className="flex items-center gap-2">
                <span className="font-semibold text-ink">{msg.authorName}</span>
                {msg.isInternalNote && <Badge>Internal note</Badge>}
                <span className="text-[11.5px] text-ink-soft">{formatRelativeTime(msg.createdAt)}</span>
              </div>
              <p className="text-ink">{msg.body}</p>
            </div>
          ))}
        </div>
      </Card>

      <Card className="flex flex-col gap-3 p-6">
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setMode("reply")}
            className={`rounded-control px-3 py-1.5 text-[12.5px] font-medium ${
              mode === "reply" ? "bg-ink text-paper" : "text-ink-soft hover:bg-paper-dim"
            }`}
          >
            Reply to requester
          </button>
          <button
            type="button"
            onClick={() => setMode("note")}
            className={`rounded-control px-3 py-1.5 text-[12.5px] font-medium ${
              mode === "note" ? "bg-ink text-paper" : "text-ink-soft hover:bg-paper-dim"
            }`}
          >
            Internal note
          </button>
        </div>

        {mode === "reply" && (
          <div className="flex flex-wrap gap-1.5">
            {CANNED_RESPONSES.map((c) => (
              <button
                key={c.label}
                type="button"
                onClick={() => setReply(c.value)}
                className="rounded-full border border-line-strong px-2.5 py-1 text-[11.5px] text-ink-soft hover:border-ink hover:text-ink"
              >
                {c.label}
              </button>
            ))}
          </div>
        )}

        <Textarea
          placeholder={mode === "reply" ? "Write a reply to the requester..." : "Add a note visible only to staff..."}
          rows={4}
          value={mode === "reply" ? reply : note}
          onChange={(e) => (mode === "reply" ? setReply(e.target.value) : setNote(e.target.value))}
        />

        <div className="flex justify-end">
          <Button
            size="sm"
            onClick={handleSend}
            disabled={
              (mode === "reply" ? !reply.trim() || replyToTicket.isPending : !note.trim() || addInternalNote.isPending)
            }
          >
            <Send size={14} strokeWidth={1.75} />
            {mode === "reply" ? (replyToTicket.isPending ? "Sending..." : "Send reply") : (addInternalNote.isPending ? "Saving..." : "Save note")}
          </Button>
        </div>
      </Card>
    </main>
  );
}