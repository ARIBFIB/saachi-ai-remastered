"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";

type TicketDetailStatus = "open" | "in_progress" | "resolved" | "closed";
type TicketDetailPriority = "low" | "medium" | "high" | "urgent";
type ThreadAuthorType = "requester" | "staff" | "internal_note";

type TicketThreadEntry = {
  id: string;
  authorType: ThreadAuthorType;
  authorName: string;
  message: string;
  createdAt: string;
};

type TicketDetailRecord = {
  id: string;
  subject: string;
  requesterName: string;
  category: string;
  status: TicketDetailStatus;
  priority: TicketDetailPriority;
  assignedTo?: string;
  slaDueAt: string;
  createdAt: string;
  thread: TicketThreadEntry[];
};

type CannedResponse = { title: string; body: string };

const CANNED_RESPONSES: CannedResponse[] = [
  { title: "Ack - looking into it", body: "Thanks for reaching out - we're looking into this now and will update you shortly." },
  { title: "Resolved - closing", body: "This issue has been resolved on our end. Let us know if you run into it again." },
  { title: "Need more info", body: "Could you share a bit more detail (screenshots, steps to reproduce) so we can help faster?" }
];

const MOCK_TICKETS: Record<string, TicketDetailRecord> = {};

function buildFallbackTicket(id: string): TicketDetailRecord {
  return {
    id,
    subject: "Support request",
    requesterName: "Demo Requester",
    category: "General",
    status: "open",
    priority: "medium",
    slaDueAt: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    createdAt: new Date().toISOString(),
    thread: []
  };
}

let ticketStore: Record<string, TicketDetailRecord> = { ...MOCK_TICKETS };

async function fetchTicketDetail(id: string): Promise<TicketDetailRecord> {
  await new Promise((r) => setTimeout(r, 300));
  if (!ticketStore[id]) {
    ticketStore[id] = buildFallbackTicket(id);
  }
  return ticketStore[id];
}

export function useAdminTicketDetailPage(id: string) {
  return useQuery({
    queryKey: ["admin", "ticket-detail", id],
    queryFn: () => fetchTicketDetail(id),
    enabled: Boolean(id)
  });
}

export function useAdminCannedResponses() {
  return useQuery({
    queryKey: ["admin", "canned-responses"],
    queryFn: async () => {
      await new Promise((r) => setTimeout(r, 100));
      return CANNED_RESPONSES;
    }
  });
}

export function useReplyToTicket() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; message: string }) => {
      await new Promise((r) => setTimeout(r, 300));
      const current = ticketStore[input.id] ?? buildFallbackTicket(input.id);
      const updated: TicketDetailRecord = {
        ...current,
        status: current.status === "open" ? "in_progress" : current.status,
        thread: [
          ...current.thread,
          { id: `msg_${Date.now()}`, authorType: "staff", authorName: "Admin", message: input.message, createdAt: new Date().toISOString() }
        ]
      };
      ticketStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "ticket-detail", data.id] });
      queryClient.invalidateQueries({ queryKey: ["admin", "tickets"] });
    }
  });
}

export function useAddInternalNote() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; note: string }) => {
      await new Promise((r) => setTimeout(r, 300));
      const current = ticketStore[input.id] ?? buildFallbackTicket(input.id);
      const updated: TicketDetailRecord = {
        ...current,
        thread: [
          ...current.thread,
          { id: `note_${Date.now()}`, authorType: "internal_note", authorName: "Admin", message: input.note, createdAt: new Date().toISOString() }
        ]
      };
      ticketStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "ticket-detail", data.id] });
    }
  });
}

export function useResolveTicket() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; status: TicketDetailStatus }) => {
      await new Promise((r) => setTimeout(r, 250));
      const current = ticketStore[input.id] ?? buildFallbackTicket(input.id);
      const updated: TicketDetailRecord = { ...current, status: input.status };
      ticketStore[input.id] = updated;
      return updated;
    },
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "ticket-detail", data.id] });
      queryClient.invalidateQueries({ queryKey: ["admin", "tickets"] });
    }
  });
}