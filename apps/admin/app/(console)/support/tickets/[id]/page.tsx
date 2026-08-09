"use client";

import { useEffect, useRef, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { toast } from "sonner";
import {
  ArrowLeft,
  Send,
  User,
  Headset,
  AlertTriangle,
  CheckCircle2,
  Clock,
  Tag,
  UserCog
} from "lucide-react";
import { Button, Card, Select, StatusPill, Textarea, ShimmerKpiCard } from "@saachi/ui";
import { formatDate, formatRelativeTime } from "@saachi/utils";

type TicketStatus = "open" | "in_progress" | "resolved" | "closed";
type TicketPriority = "low" | "medium" | "high" | "urgent";

type ThreadEntry = {
  id: string;
  author: string;
  authorType: "requester" | "staff";
  body: string;
  createdAt: string;
};

type TicketDetail = {
  id: string;
  subject: string;
  requesterName: string;
  requesterEmail: string;
  category: string;
  status: TicketStatus;
  priority: TicketPriority;
  assignedTo: string | null;
  slaDueAt: string;
  createdAt: string;
  thread: ThreadEntry[];
};

const STATUS_OPTIONS = [
  { label: "Open", value: "open" },
  { label: "In progress", value: "in_progress" },
  { label: "Resolved", value: "resolved" },
  { label: "Closed", value: "closed" }
];

const PRIORITY_OPTIONS = [
  { label: "Low", value: "low" },
  { label: "Medium", value: "medium" },
  { label: "High", value: "high" },
  { label: "Urgent", value: "urgent" }
];

const ASSIGNEE_OPTIONS = [
  { label: "Unassigned", value: "" },
  { label: "Support Desk", value: "Support Desk" },
  { label: "Finance Desk", value: "Finance Desk" },
  { label: "Abdul Rehman Irfan", value: "Abdul Rehman Irfan" }
];

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
  "Thanks for reaching out - we're looking into this and will update you shortly.",
  "This has been resolved on our end. Please let us know if the issue persists.",
  "Could you share a screenshot or transaction ID so we can investigate further?"
];

function buildMockTicket(id: string): TicketDetail {
  return {
    id,
    subject: "Payout not received for July batch",
    requesterName: "Hassan Raza",
    requesterEmail: "hassan.raza@example.com",
    category: "Payouts",
    status: "open",
    priority: "high",
    assignedTo: "Finance Desk",
    slaDueAt: "2026-08-11T12:00:00Z",
    createdAt: "2026-08-08T09:30:00Z",
    thread: [
      {
        id: "t1",
        author: "Hassan Raza",
        authorType: "requester",
        body: "Hi, I still haven't received my payout for the July batch. My payout method is set up correctly and my balance shows as paid out, but nothing has arrived in my bank account. Can someone check this?",
        createdAt: "2026-08-08T09:30:00Z"
      },
      {
        id: "t2",
        author: "Finance Desk",
        authorType: "staff",
        body: "Thanks for flagging this, Hassan. We're checking with our payment processor for the July batch and will get back to you within 24 hours.",
        createdAt: "2026-08-08T11:15:00Z"
      }
    ]
  };
}

export default function SupportTicketDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const ticketId = params?.id ?? "";

  const [isLoading, setIsLoading] = useState(true);
  const [ticket, setTicket] = useState<TicketDetail | null>(null);
  const [reply, setReply] = useState("");
  const [sending, setSending] = useState(false);
  const threadEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const t = setTimeout(() => {
      setTicket(buildMockTicket(ticketId));
      setIsLoading(false);
    }, 500);
    return () => clearTimeout(t);
  }, [ticketId]);

  useEffect(() => {
    threadEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [ticket?.thread.length]);

  const updateField = <K extends keyof TicketDetail>(key: K, value: TicketDetail[K]) => {
    setTicket((prev) => (prev ? { ...prev, [key]: value } : prev));
  };

  const handleSendReply = () => {
    if (!ticket || !reply.trim()) return;
    setSending(true);
    setTimeout(() => {
      const entry: ThreadEntry = {
        id: `t${ticket.thread.length + 1}`,
        author: "Support Desk",
        authorType: "staff",
        body: reply.trim(),
        createdAt: new Date().toISOString()
      };
      setTicket({ ...ticket, thread: [...ticket.thread, entry], status: ticket.status === "open" ? "in_progress" : ticket.status });
      setReply("");
      setSending(false);
      toast.success("Reply sent", { description: `${ticket.requesterName} will be notified by email.` });
    }, 500);
  };

  const handleResolve = () => {
    if (!ticket) return;
    updateField("status", "resolved");
    toast.success("Ticket marked as resolved");
  };

  if (isLoading || !ticket) {
    return (
      <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
        <div className="flex flex-col gap-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      </main>
    );
  }

  const overdue =
    new Date(ticket.slaDueAt).getTime() < Date.now() && ticket.status !== "resolved" && ticket.status !== "closed";

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <button
        type="button"
        onClick={() => router.push("/support/tickets")}
        className="mb-4 flex items-center gap-1.5 text-[12.5px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
      >
        <ArrowLeft size={14} strokeWidth={1.75} /> Back to Ticket Queue
      </button>

      <Card className="mb-6 flex flex-col gap-4 p-6">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div>
            <div className="flex flex-wrap items-center gap-2.5">
              <h1 className="text-[19px] font-semibold text-ink">{ticket.subject}</h1>
              <StatusPill label={ticket.status.replace("_", " ")} tone={STATUS_TONE[ticket.status]} />
              <StatusPill label={ticket.priority} tone={PRIORITY_TONE[ticket.priority]} />
            </div>
            <div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1 text-[12.5px] text-ink-soft">
              <span className="flex items-center gap-1.5">
                <User size={13} strokeWidth={1.75} /> {ticket.requesterName} ({ticket.requesterEmail})
              </span>
              <span className="flex items-center gap-1.5">
                <Tag size={13} strokeWidth={1.75} /> {ticket.category}
              </span>
              <span className="flex items-center gap-1.5">
                <Clock size={13} strokeWidth={1.75} /> Opened {formatRelativeTime(ticket.createdAt)}
              </span>
              {overdue ? (
                <span className="flex items-center gap-1.5 font-medium text-error">
                  <AlertTriangle size={13} strokeWidth={1.75} /> SLA overdue
                </span>
              ) : (
                <span>SLA due {formatDate(ticket.slaDueAt)}</span>
              )}
            </div>
          </div>
          {ticket.status !== "resolved" && ticket.status !== "closed" && (
            <Button size="sm" variant="secondary" onClick={handleResolve}>
              <CheckCircle2 size={14} strokeWidth={1.75} /> Mark resolved
            </Button>
          )}
        </div>

        <div className="grid grid-cols-1 gap-3 border-t border-line pt-4 sm:grid-cols-3">
          <Select
            label="Status"
            options={STATUS_OPTIONS}
            value={ticket.status}
            onChange={(e) => updateField("status", e.target.value as TicketStatus)}
          />
          <Select
            label="Priority"
            options={PRIORITY_OPTIONS}
            value={ticket.priority}
            onChange={(e) => updateField("priority", e.target.value as TicketPriority)}
          />
          <Select
            label="Assigned to"
            options={ASSIGNEE_OPTIONS}
            value={ticket.assignedTo ?? ""}
            onChange={(e) => updateField("assignedTo", e.target.value || null)}
          />
        </div>
      </Card>

      <Card className="mb-6 p-6">
        <p className="mb-4 flex items-center gap-2 text-[14px] font-semibold text-ink">
          <Headset size={15} strokeWidth={1.75} /> Conversation
        </p>
        <div className="mb-6 flex flex-col gap-3">
          {ticket.thread.map((entry) => (
            <div
              key={entry.id}
              className={`max-w-[85%] rounded-card border p-4 ${
                entry.authorType === "staff" ? "ml-auto border-line-strong bg-paper-dim" : "border-line bg-card"
              }`}
            >
              <div className="mb-1.5 flex items-center justify-between gap-3">
                <span className="flex items-center gap-1.5 text-[12.5px] font-semibold text-ink">
                  {entry.authorType === "staff" ? (
                    <UserCog size={13} strokeWidth={1.75} />
                  ) : (
                    <User size={13} strokeWidth={1.75} />
                  )}
                  {entry.author}
                </span>
                <span className="text-[11px] text-ink-soft">{formatRelativeTime(entry.createdAt)}</span>
              </div>
              <p className="text-[13.5px] leading-relaxed text-ink">{entry.body}</p>
            </div>
          ))}
          <div ref={threadEndRef} />
        </div>

        <div className="mb-3 flex flex-wrap gap-1.5">
          {CANNED_RESPONSES.map((canned, i) => (
            <button
              key={i}
              type="button"
              onClick={() => setReply(canned)}
              className="rounded-full border border-line px-3 py-1 text-[11.5px] text-ink-soft transition-colors duration-150 ease-out hover:border-line-strong hover:text-ink"
            >
              {canned.length > 40 ? `${canned.slice(0, 40)}...` : canned}
            </button>
          ))}
        </div>

        <Textarea
          label="Reply to requester"
          placeholder="Type your reply..."
          rows={4}
          value={reply}
          onChange={(e) => setReply(e.target.value)}
        />
        <div className="mt-3 flex justify-end">
          <Button onClick={handleSendReply} disabled={!reply.trim() || sending}>
            <Send size={14} strokeWidth={1.75} /> {sending ? "Sending..." : "Send reply"}
          </Button>
        </div>
      </Card>
    </main>
  );
}