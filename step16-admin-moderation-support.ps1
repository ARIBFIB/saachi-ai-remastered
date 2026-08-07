# step16-admin-moderation-support.ps1
# Run from: SAI2 root folder
# Builds: Content Moderation - Flagged Reviews, Flagged Forum Posts,
# and Support Ticket Queue + Ticket Detail.

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}

function Patch-File {
    param([string]$Path, [string]$OldStr, [string]$NewStr, [string]$Label)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP (file not found): $fullPath" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Path $fullPath -Raw
    if ($content.Contains($OldStr)) {
        $updated = $content.Replace($OldStr, $NewStr)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($fullPath, $updated, $enc)
        Write-Host "  patched ($Label): $fullPath"
    } else {
        Write-Host "  WARNING: pattern for '$Label' not found - skipped." -ForegroundColor Yellow
    }
}

Write-Host "Step 16: Content Moderation + Support Ticket Queue..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Dummy data - flagged reviews, flagged forum posts, support tickets
# ---------------------------------------------------------------------------
$adminModSupportDummyData = @'
export type FlagStatus = "pending" | "removed" | "dismissed" | "warned";

export type FlaggedReview = {
  id: string;
  courseTitle: string;
  authorName: string;
  comment: string;
  rating: number;
  flagReason: string;
  flaggedBy: string;
  status: FlagStatus;
  createdAt: string;
};

export type FlaggedForumPost = {
  id: string;
  courseTitle: string;
  authorName: string;
  body: string;
  flagReason: string;
  flaggedBy: string;
  status: FlagStatus;
  createdAt: string;
};

export type TicketStatus = "open" | "in_progress" | "resolved" | "closed";
export type TicketPriority = "low" | "medium" | "high" | "urgent";

export type TicketMessage = {
  id: string;
  authorName: string;
  isInternal: boolean;
  isStaff: boolean;
  body: string;
  createdAt: string;
};

export type SupportTicket = {
  id: string;
  subject: string;
  requesterName: string;
  requesterEmail: string;
  category: string;
  priority: TicketPriority;
  status: TicketStatus;
  assignedTo?: string;
  createdAt: string;
  slaDueAt: string;
  messages: TicketMessage[];
};

function hoursAgoIso(n: number): string {
  return new Date(Date.now() - n * 60 * 60 * 1000).toISOString();
}

function hoursFromNowIso(n: number): string {
  return new Date(Date.now() + n * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_FLAGGED_REVIEWS: FlaggedReview[] = [
  { id: "frv_1", courseTitle: "Prompt Engineering Fundamentals", authorName: "Danish Raza", comment: "This course is a scam, don't waste your money, the instructor never responds and it's all recycled content from free YouTube videos.", rating: 1, flagReason: "Potentially defamatory / unverified claims", flaggedBy: "Sana Rizvi (instructor)", status: "pending", createdAt: hoursAgoIso(6) },
  { id: "frv_2", courseTitle: "AI-Powered Marketing Campaigns", authorName: "Anonymous User", comment: "Check out my own course instead, link in bio, way better content for half the price!", rating: 3, flagReason: "Self-promotion / spam", flaggedBy: "system", status: "pending", createdAt: hoursAgoIso(20) },
  { id: "frv_3", courseTitle: "Build a WhatsApp AI Auto-Responder", authorName: "Omar Sheikh", comment: "Genuinely one of the worst experiences, the guy is an idiot and clearly doesn't know what he's teaching.", rating: 1, flagReason: "Harassment / abusive language toward instructor", flaggedBy: "Bilal Ahmed (instructor)", status: "pending", createdAt: hoursAgoIso(30) },
  { id: "frv_4", courseTitle: "Automate Everything with n8n & AI", authorName: "Hina Malik", comment: "Solid course but the pricing section felt rushed.", rating: 4, flagReason: "Flagged in error by automated filter", flaggedBy: "system", status: "dismissed", createdAt: hoursAgoIso(72) }
];

export const ADMIN_DUMMY_FLAGGED_FORUM_POSTS: FlaggedForumPost[] = [
  { id: "ffp_1", courseTitle: "Prompt Engineering Fundamentals", authorName: "Noor Fatima", body: "Does anyone want to share their personal WhatsApp number so we can form a study group outside the platform?", flagReason: "Requesting off-platform contact info", flaggedBy: "system", status: "pending", createdAt: hoursAgoIso(10) },
  { id: "ffp_2", courseTitle: "AI Automation & Workflow Tools", authorName: "Ali Raza", body: "Here's a cracked version of the paid n8n cloud plan if anyone wants the download link.", flagReason: "Promoting pirated / unauthorized software", flaggedBy: "Ayesha Khan (instructor)", status: "pending", createdAt: hoursAgoIso(15) },
  { id: "ffp_3", courseTitle: "Build a WhatsApp AI Auto-Responder", authorName: "Sara Iqbal", body: "This module completely contradicts what was taught earlier, is this course even reviewed before publishing?", flagReason: "Flagged in error - legitimate question", flaggedBy: "system", status: "dismissed", createdAt: hoursAgoIso(48) },
  { id: "ffp_4", courseTitle: "AI-Powered Marketing Campaigns", authorName: "Fatima Noor", body: "Anyone else think the instructor is overselling results here? Feels dishonest tbh.", flagReason: "Reported by instructor as harassment", flaggedBy: "Zara Farooq (instructor)", status: "pending", createdAt: hoursAgoIso(5) }
];

export const ADMIN_DUMMY_TICKETS: SupportTicket[] = [
  {
    id: "tkt_5001",
    subject: "Payment charged twice for the same course",
    requesterName: "Hina Malik",
    requesterEmail: "hina.malik@example.com",
    category: "Billing",
    priority: "urgent",
    status: "open",
    assignedTo: undefined,
    createdAt: hoursAgoIso(2),
    slaDueAt: hoursFromNowIso(2),
    messages: [
      { id: "m1", authorName: "Hina Malik", isInternal: false, isStaff: false, body: "I was charged twice for Prompt Engineering Fundamentals - $29 shows up twice on my card statement. Please refund the duplicate.", createdAt: hoursAgoIso(2) }
    ]
  },
  {
    id: "tkt_5002",
    subject: "Can't access course after purchase",
    requesterName: "Omar Sheikh",
    requesterEmail: "omar.sheikh@example.com",
    category: "Technical",
    priority: "high",
    status: "in_progress",
    assignedTo: "admin@saachi.ai",
    createdAt: hoursAgoIso(18),
    slaDueAt: hoursFromNowIso(-2),
    messages: [
      { id: "m1", authorName: "Omar Sheikh", isInternal: false, isStaff: false, body: "I purchased AI-Powered Marketing Campaigns but my dashboard still shows it as locked.", createdAt: hoursAgoIso(18) },
      { id: "m2", authorName: "Admin", isInternal: false, isStaff: true, body: "Thanks for flagging this - can you confirm the email used at checkout matches your account email?", createdAt: hoursAgoIso(16) },
      { id: "m3", authorName: "Admin", isInternal: true, isStaff: true, body: "Checked transaction ledger - payment shows completed but enrollment record is missing. Escalating to backend team once available.", createdAt: hoursAgoIso(15) }
    ]
  },
  {
    id: "tkt_5003",
    subject: "Question about instructor payout timeline",
    requesterName: "Ayesha Khan",
    requesterEmail: "ayesha.khan@example.com",
    category: "Payouts",
    priority: "medium",
    status: "open",
    assignedTo: undefined,
    createdAt: hoursAgoIso(30),
    slaDueAt: hoursFromNowIso(18),
    messages: [
      { id: "m1", authorName: "Ayesha Khan", isInternal: false, isStaff: false, body: "I requested a payout 5 days ago and haven't heard anything - what's the usual processing time?", createdAt: hoursAgoIso(30) }
    ]
  },
  {
    id: "tkt_5004",
    subject: "Refund request follow-up",
    requesterName: "Sara Iqbal",
    requesterEmail: "sara.iqbal@example.com",
    category: "Billing",
    priority: "low",
    status: "resolved",
    assignedTo: "admin@saachi.ai",
    createdAt: hoursAgoIso(96),
    slaDueAt: hoursAgoIso(72),
    messages: [
      { id: "m1", authorName: "Sara Iqbal", isInternal: false, isStaff: false, body: "Following up on my refund request from last week.", createdAt: hoursAgoIso(96) },
      { id: "m2", authorName: "Admin", isInternal: false, isStaff: true, body: "Your refund was approved and processed - you should see it in 5-7 business days.", createdAt: hoursAgoIso(90) }
    ]
  },
  {
    id: "tkt_5005",
    subject: "How do I become a verified instructor?",
    requesterName: "Hamza Tariq",
    requesterEmail: "hamza.tariq@example.com",
    category: "Instructor",
    priority: "low",
    status: "closed",
    assignedTo: "admin@saachi.ai",
    createdAt: hoursAgoIso(200),
    slaDueAt: hoursAgoIso(176),
    messages: [
      { id: "m1", authorName: "Hamza Tariq", isInternal: false, isStaff: false, body: "What are the requirements to get the Verified Instructor badge?", createdAt: hoursAgoIso(200) },
      { id: "m2", authorName: "Admin", isInternal: false, isStaff: true, body: "You'll need ID verification, 3+ published courses, and a 4.0+ average rating. You can submit documents from the Verification tab.", createdAt: hoursAgoIso(195) }
    ]
  }
];
'@
Write-Utf8NoBom -Path "packages\api-client\src\dummy-data-admin-mod-support.ts" -Content $adminModSupportDummyData

Patch-File -Path "packages\api-client\src\index.ts" `
  -OldStr 'export * from "./hooks/useAdminMarketing";' `
  -NewStr @'
export * from "./hooks/useAdminMarketing";
export * from "./dummy-data-admin-mod-support";
export * from "./hooks/useAdminModeration";
export * from "./hooks/useAdminSupport";
'@ `
  -Label "export admin moderation + support dummy data and hooks"

# ---------------------------------------------------------------------------
# 2. useAdminModeration hooks (flagged reviews + forum posts)
# ---------------------------------------------------------------------------
$useAdminModeration = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_FLAGGED_REVIEWS,
  ADMIN_DUMMY_FLAGGED_FORUM_POSTS,
  type FlaggedReview,
  type FlaggedForumPost,
  type FlagStatus
} from "../dummy-data-admin-mod-support";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Content Moderation API (Doc 3).
let FLAGGED_REVIEWS_STATE: FlaggedReview[] = [...ADMIN_DUMMY_FLAGGED_REVIEWS];
let FLAGGED_FORUM_STATE: FlaggedForumPost[] = [...ADMIN_DUMMY_FLAGGED_FORUM_POSTS];

export const adminModerationKeys = {
  reviews: (filters?: Record<string, unknown>) => ["admin", "moderation", "reviews", filters] as const,
  forum: (filters?: Record<string, unknown>) => ["admin", "moderation", "forum", filters] as const
};

export type ModerationFilters = {
  status?: string;
};

export function useFlaggedReviews(filters: ModerationFilters = {}) {
  return useQuery({
    queryKey: adminModerationKeys.reviews(filters),
    queryFn: async () => {
      let items = [...FLAGGED_REVIEWS_STATE];
      if (filters.status) items = items.filter((r) => r.status === filters.status);
      return delay(items);
    }
  });
}

export function useResolveFlaggedReview() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: FlagStatus }) => {
      FLAGGED_REVIEWS_STATE = FLAGGED_REVIEWS_STATE.map((r) => (r.id === id ? { ...r, status } : r));
      return delay({ id, status }, 350);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "moderation", "reviews"] });
    }
  });
}

export function useFlaggedForumPosts(filters: ModerationFilters = {}) {
  return useQuery({
    queryKey: adminModerationKeys.forum(filters),
    queryFn: async () => {
      let items = [...FLAGGED_FORUM_STATE];
      if (filters.status) items = items.filter((p) => p.status === filters.status);
      return delay(items);
    }
  });
}

export function useResolveFlaggedForumPost() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: FlagStatus }) => {
      FLAGGED_FORUM_STATE = FLAGGED_FORUM_STATE.map((p) => (p.id === id ? { ...p, status } : p));
      return delay({ id, status }, 350);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "moderation", "forum"] });
    }
  });
}
'@
Write-Utf8NoBom -Path "packages\api-client\src\hooks\useAdminModeration.ts" -Content $useAdminModeration

# ---------------------------------------------------------------------------
# 3. useAdminSupport hooks (ticket queue + detail)
# ---------------------------------------------------------------------------
$useAdminSupport = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_TICKETS,
  type SupportTicket,
  type TicketStatus,
  type TicketMessage
} from "../dummy-data-admin-mod-support";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Support/Helpdesk API (Doc 3).
let TICKETS_STATE: SupportTicket[] = [...ADMIN_DUMMY_TICKETS];

export const adminSupportKeys = {
  list: (filters?: Record<string, unknown>) => ["admin", "support", "tickets", filters] as const,
  detail: (id: string) => ["admin", "support", "tickets", "detail", id] as const
};

export type TicketFilters = {
  search?: string;
  status?: string;
  priority?: string;
};

export function useAdminTickets(filters: TicketFilters = {}) {
  return useQuery({
    queryKey: adminSupportKeys.list(filters),
    queryFn: async () => {
      let items = [...TICKETS_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter(
          (t) => t.subject.toLowerCase().includes(q) || t.requesterName.toLowerCase().includes(q)
        );
      }
      if (filters.status) items = items.filter((t) => t.status === filters.status);
      if (filters.priority) items = items.filter((t) => t.priority === filters.priority);
      return delay(items);
    }
  });
}

export function useAdminTicketDetail(id: string) {
  return useQuery({
    queryKey: adminSupportKeys.detail(id),
    queryFn: async () => {
      const found = TICKETS_STATE.find((t) => t.id === id);
      if (!found) throw new Error("Ticket not found");
      return delay(found);
    },
    enabled: Boolean(id)
  });
}

export function useUpdateTicketStatus() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, status }: { id: string; status: TicketStatus }) => {
      TICKETS_STATE = TICKETS_STATE.map((t) => (t.id === id ? { ...t, status } : t));
      return delay({ id, status }, 300);
    },
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "support", "tickets"] });
      queryClient.invalidateQueries({ queryKey: adminSupportKeys.detail(variables.id) });
    }
  });
}

export function useAssignTicket() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, assignedTo }: { id: string; assignedTo: string }) => {
      TICKETS_STATE = TICKETS_STATE.map((t) => (t.id === id ? { ...t, assignedTo } : t));
      return delay({ id, assignedTo }, 300);
    },
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "support", "tickets"] });
      queryClient.invalidateQueries({ queryKey: adminSupportKeys.detail(variables.id) });
    }
  });
}

export function useAddTicketMessage() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, body, isInternal }: { id: string; body: string; isInternal: boolean }) => {
      const message: TicketMessage = {
        id: `m_${Math.random().toString(36).slice(2, 8)}`,
        authorName: "Admin",
        isInternal,
        isStaff: true,
        body,
        createdAt: new Date().toISOString()
      };
      TICKETS_STATE = TICKETS_STATE.map((t) =>
        t.id === id ? { ...t, messages: [...t.messages, message], status: t.status === "open" ? "in_progress" : t.status } : t
      );
      return delay(message, 300);
    },
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "support", "tickets"] });
      queryClient.invalidateQueries({ queryKey: adminSupportKeys.detail(variables.id) });
    }
  });
}
'@
Write-Utf8NoBom -Path "packages\api-client\src\hooks\useAdminSupport.ts" -Content $useAdminSupport

# ---------------------------------------------------------------------------
# 4. Flagged Reviews page
# ---------------------------------------------------------------------------
$flaggedReviewsPage = @'
"use client";

import { useState } from "react";
import { MessageSquareWarning, Trash2, ShieldAlert, CheckCircle2 } from "lucide-react";
import { useFlaggedReviews, useResolveFlaggedReview, type FlaggedReview } from "@saachi/api-client";
import { Button, Card, Select, StatusPill, ShimmerTableRow, EmptyState } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Removed", value: "removed" },
  { label: "Dismissed", value: "dismissed" },
  { label: "Warned", value: "warned" }
];

const STATUS_TONE: Record<FlaggedReview["status"], "warning" | "error" | "neutral" | "info"> = {
  pending: "warning",
  removed: "error",
  dismissed: "neutral",
  warned: "info"
};

export default function FlaggedReviewsPage() {
  const [statusFilter, setStatusFilter] = useState("pending");
  const { data: reviews, isLoading } = useFlaggedReviews({ status: statusFilter || undefined });
  const resolve = useResolveFlaggedReview();

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <MessageSquareWarning size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Flagged Reviews</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Course reviews reported by instructors, learners, or automated filters.</p>
          </div>
        </div>
        <div className="w-[180px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
      </div>

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={4} />
          ))}
        </div>
      ) : !reviews || reviews.length === 0 ? (
        <EmptyState icon={<MessageSquareWarning size={22} strokeWidth={1.75} />} title="Nothing flagged" description="No reviews match this filter." />
      ) : (
        <div className="flex flex-col gap-4">
          {reviews.map((review) => (
            <Card key={review.id} className="flex flex-col gap-4 p-5">
              <div className="flex flex-wrap items-start justify-between gap-3">
                <div>
                  <div className="flex items-center gap-2.5">
                    <p className="text-[14px] font-semibold text-ink">{review.authorName}</p>
                    <StatusPill label={review.status} tone={STATUS_TONE[review.status]} />
                  </div>
                  <p className="mt-1 text-[12.5px] text-ink-soft">
                    on {review.courseTitle} - {"\u2605".repeat(review.rating)}{"\u2606".repeat(5 - review.rating)} - {formatRelativeTime(review.createdAt)}
                  </p>
                </div>
              </div>

              <p className="rounded-control border border-line bg-paper-dim p-3.5 text-[13.5px] leading-relaxed text-ink">
                {review.comment}
              </p>

              <div className="flex items-center gap-2 text-[12.5px] text-ink-soft">
                <ShieldAlert size={13} strokeWidth={1.75} className="shrink-0 text-error" />
                Flagged by {review.flaggedBy} - reason: {review.flagReason}
              </div>

              {review.status === "pending" && (
                <div className="flex flex-wrap gap-2">
                  <Button size="sm" variant="secondary" onClick={() => resolve.mutate({ id: review.id, status: "dismissed" })}>
                    <CheckCircle2 size={14} strokeWidth={1.75} /> Dismiss flag
                  </Button>
                  <Button size="sm" variant="secondary" onClick={() => resolve.mutate({ id: review.id, status: "warned" })}>
                    Warn user
                  </Button>
                  <Button size="sm" variant="danger" onClick={() => resolve.mutate({ id: review.id, status: "removed" })}>
                    <Trash2 size={14} strokeWidth={1.75} /> Remove review
                  </Button>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\moderation\reviews\page.tsx" -Content $flaggedReviewsPage

# ---------------------------------------------------------------------------
# 5. Flagged Forum Posts page
# ---------------------------------------------------------------------------
$flaggedForumPage = @'
"use client";

import { useState } from "react";
import { MessagesSquare, Trash2, ShieldAlert, CheckCircle2 } from "lucide-react";
import { useFlaggedForumPosts, useResolveFlaggedForumPost, type FlaggedForumPost } from "@saachi/api-client";
import { Button, Card, Select, StatusPill, ShimmerTableRow, EmptyState } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Pending", value: "pending" },
  { label: "Removed", value: "removed" },
  { label: "Dismissed", value: "dismissed" },
  { label: "Warned", value: "warned" }
];

const STATUS_TONE: Record<FlaggedForumPost["status"], "warning" | "error" | "neutral" | "info"> = {
  pending: "warning",
  removed: "error",
  dismissed: "neutral",
  warned: "info"
};

export default function FlaggedForumPostsPage() {
  const [statusFilter, setStatusFilter] = useState("pending");
  const { data: posts, isLoading } = useFlaggedForumPosts({ status: statusFilter || undefined });
  const resolve = useResolveFlaggedForumPost();

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <MessagesSquare size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Flagged Forum Posts</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Community Q&A posts reported for review.</p>
          </div>
        </div>
        <div className="w-[180px]">
          <Select placeholder="All statuses" options={STATUS_OPTIONS} value={statusFilter} onChange={(e) => setStatusFilter(e.target.value)} />
        </div>
      </div>

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={4} />
          ))}
        </div>
      ) : !posts || posts.length === 0 ? (
        <EmptyState icon={<MessagesSquare size={22} strokeWidth={1.75} />} title="Nothing flagged" description="No forum posts match this filter." />
      ) : (
        <div className="flex flex-col gap-4">
          {posts.map((post) => (
            <Card key={post.id} className="flex flex-col gap-4 p-5">
              <div>
                <div className="flex items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{post.authorName}</p>
                  <StatusPill label={post.status} tone={STATUS_TONE[post.status]} />
                </div>
                <p className="mt-1 text-[12.5px] text-ink-soft">
                  in {post.courseTitle} - {formatRelativeTime(post.createdAt)}
                </p>
              </div>

              <p className="rounded-control border border-line bg-paper-dim p-3.5 text-[13.5px] leading-relaxed text-ink">
                {post.body}
              </p>

              <div className="flex items-center gap-2 text-[12.5px] text-ink-soft">
                <ShieldAlert size={13} strokeWidth={1.75} className="shrink-0 text-error" />
                Flagged by {post.flaggedBy} - reason: {post.flagReason}
              </div>

              {post.status === "pending" && (
                <div className="flex flex-wrap gap-2">
                  <Button size="sm" variant="secondary" onClick={() => resolve.mutate({ id: post.id, status: "dismissed" })}>
                    <CheckCircle2 size={14} strokeWidth={1.75} /> Dismiss flag
                  </Button>
                  <Button size="sm" variant="secondary" onClick={() => resolve.mutate({ id: post.id, status: "warned" })}>
                    Warn user
                  </Button>
                  <Button size="sm" variant="danger" onClick={() => resolve.mutate({ id: post.id, status: "removed" })}>
                    <Trash2 size={14} strokeWidth={1.75} /> Remove post
                  </Button>
                </div>
              )}
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\moderation\forum\page.tsx" -Content $flaggedForumPage

# ---------------------------------------------------------------------------
# 6. Support Ticket Queue page
# ---------------------------------------------------------------------------
$ticketQueuePage = @'
"use client";

import { useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, LifeBuoy, AlertTriangle } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { useAdminTickets, type SupportTicket } from "@saachi/api-client";
import { DataTable, StatusPill, Select } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

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

export default function SupportTicketQueuePage() {
  const router = useRouter();
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [priority, setPriority] = useState("");

  const { data, isLoading } = useAdminTickets({
    search: search || undefined,
    status: status || undefined,
    priority: priority || undefined
  });

  const columns = useMemo<ColumnDef<SupportTicket, any>[]>(
    () => [
      {
        header: "Subject",
        accessorKey: "subject",
        cell: ({ row }) => (
          <div className="max-w-[280px]">
            <div className="truncate font-medium text-ink">{row.original.subject}</div>
            <div className="text-[12px] text-ink-soft">{row.original.requesterName} - {row.original.category}</div>
          </div>
        )
      },
      {
        header: "Priority",
        accessorKey: "priority",
        cell: ({ getValue }) => {
          const value = getValue() as SupportTicket["priority"];
          return <StatusPill label={value} tone={PRIORITY_TONE[value]} />;
        }
      },
      {
        header: "Status",
        accessorKey: "status",
        cell: ({ getValue }) => {
          const value = getValue() as SupportTicket["status"];
          return <StatusPill label={value.replace("_", " ")} tone={STATUS_TONE[value]} />;
        }
      },
      {
        header: "Assigned to",
        accessorKey: "assignedTo",
        cell: ({ getValue }) => <span className="text-ink-soft">{(getValue() as string) ?? "Unassigned"}</span>
      },
      {
        header: "SLA",
        accessorKey: "slaDueAt",
        cell: ({ row }) => {
          const overdue = new Date(row.original.slaDueAt).getTime() < Date.now() && row.original.status !== "resolved" && row.original.status !== "closed";
          return overdue ? (
            <span className="flex items-center gap-1.5 font-medium text-error">
              <AlertTriangle size={13} strokeWidth={1.75} /> Overdue
            </span>
          ) : (
            <span className="text-ink-soft">{formatRelativeTime(row.original.slaDueAt)}</span>
          );
        }
      },
      {
        header: "Created",
        accessorKey: "createdAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatRelativeTime(getValue() as string)}</span>
      }
    ],
    []
  );

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <LifeBuoy size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Support Ticket Queue</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Learner and instructor support requests, tracked against SLA.</p>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={data ?? []}
        isLoading={isLoading}
        emptyTitle="No tickets found"
        emptyDescription="Try adjusting your search or filters."
        onRowClick={(row) => router.push(`/support/tickets/${row.id}`)}
        toolbar={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by subject or requester"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All statuses" options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All priorities" options={PRIORITY_OPTIONS} value={priority} onChange={(e) => setPriority(e.target.value)} />
            </div>
          </div>
        }
      />
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\support\tickets\page.tsx" -Content $ticketQueuePage

# ---------------------------------------------------------------------------
# 7. Support Ticket Detail page
# ---------------------------------------------------------------------------
$ticketDetailPage = @'
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
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\support\tickets\[id]\page.tsx" -Content $ticketDetailPage

Write-Host ""
Write-Host "Step 16 done." -ForegroundColor Green
Write-Host "Run: pnpm install" -ForegroundColor Yellow
Write-Host "Then: pnpm dev:admin" -ForegroundColor Green
Write-Host ""
Write-Host "What this step built:" -ForegroundColor Cyan
Write-Host "  - Admin moderation + support dummy data (4 flagged reviews, 4 flagged forum posts, 5 support tickets w/ message threads)"
Write-Host "  - useAdminModeration hooks: flagged reviews/forum (dismiss/warn/remove)"
Write-Host "  - useAdminSupport hooks: ticket list (search/status/priority filters), detail, status update, assign, reply + internal notes"
Write-Host "  - /moderation/reviews - flagged review cards, Dismiss/Warn/Remove actions"
Write-Host "  - /moderation/forum - flagged forum post cards, same action set"
Write-Host "  - /support/tickets - DataTable with SLA overdue indicator, click-through to detail"
Write-Host "  - /support/tickets/[id] - conversation thread, canned responses, internal notes (visually distinct), assign/resolve/close"
Write-Host ""
Write-Host "Next: Step 17 - Analytics (Overview + Cohort Analysis)" -ForegroundColor Cyan