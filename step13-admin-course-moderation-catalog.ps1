# step13-admin-course-moderation-catalog.ps1
# Run from: SAI2 root folder
# Builds: Course Moderation Queue (approve/reject + feedback), Course Catalog Management
# (feature/pin controls), Category & Tag Management (CRUD).

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

Write-Host "Step 13: Admin Course Moderation + Catalog + Categories..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Dummy data - admin courses (moderation queue + catalog) + categories
# ---------------------------------------------------------------------------
$adminCourseDummyData = @'
export type AdminCourseStatus = "draft" | "pending_review" | "published" | "rejected" | "archived";

export type AdminCourse = {
  id: string;
  title: string;
  instructorName: string;
  instructorId: string;
  categoryId: string;
  price: number;
  currency: string;
  status: AdminCourseStatus;
  submittedAt: string;
  thumbnailUrl?: string;
  featured: boolean;
  pinned: boolean;
  rating: number;
  enrollmentCount: number;
  rejectionReason?: string;
};

export type AdminCategory = {
  id: string;
  name: string;
  slug: string;
  courseCount: number;
  tags: string[];
};

function img(seed: string): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/400/225`;
}

function daysAgoIso(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_CATEGORIES: AdminCategory[] = [
  { id: "ai-fundamentals", name: "AI Fundamentals & Prompt Engineering", slug: "ai-fundamentals", courseCount: 14, tags: ["prompting", "chatgpt", "beginner"] },
  { id: "ai-marketing", name: "AI for Marketing & Sales", slug: "ai-marketing", courseCount: 9, tags: ["copywriting", "ads", "leadgen"] },
  { id: "ai-automation", name: "AI Automation & Workflow Tools", slug: "ai-automation", courseCount: 11, tags: ["n8n", "zapier", "make.com"] },
  { id: "ai-support", name: "AI Customer Support & Communication", slug: "ai-support", courseCount: 6, tags: ["whatsapp", "chatbot", "callcenter"] },
  { id: "ai-dev", name: "AI Website & App Development", slug: "ai-dev", courseCount: 8, tags: ["nocode", "builder", "scaffolding"] },
  { id: "ai-integration", name: "AI Integration for Developers", slug: "ai-integration", courseCount: 7, tags: ["api", "openai", "nodejs"] },
  { id: "ai-design", name: "AI Design & Creative Tools", slug: "ai-design", courseCount: 5, tags: ["midjourney", "figma", "dalle"] },
  { id: "ai-career", name: "AI for Careers & Job Search", slug: "ai-career", courseCount: 3, tags: ["resume", "interview"] }
];

export const ADMIN_DUMMY_COURSES: AdminCourse[] = [
  { id: "crs_a1", title: "WhatsApp AI Auto-Responder for Local Retailers", instructorName: "Bilal Ahmed", instructorId: "usr_1002", categoryId: "ai-support", price: 59, currency: "USD", status: "pending_review", submittedAt: daysAgoIso(1), thumbnailUrl: img("whatsapp-ai-retail"), featured: false, pinned: false, rating: 0, enrollmentCount: 0 },
  { id: "crs_a2", title: "Cold Email Sequences with Claude & GPT-4", instructorName: "Zara Farooq", instructorId: "usr_1008", categoryId: "ai-marketing", price: 39, currency: "USD", status: "pending_review", submittedAt: daysAgoIso(2), thumbnailUrl: img("cold-email-ai"), featured: false, pinned: false, rating: 0, enrollmentCount: 0 },
  { id: "crs_a3", title: "n8n + OpenAI: Five Production Automations", instructorName: "Ayesha Khan", instructorId: "usr_1001", categoryId: "ai-automation", price: 45, currency: "USD", status: "pending_review", submittedAt: daysAgoIso(3), thumbnailUrl: img("n8n-openai-automations"), featured: false, pinned: false, rating: 0, enrollmentCount: 0 },
  { id: "crs_a4", title: "Prompt Engineering Fundamentals", instructorName: "Sana Rizvi", instructorId: "usr_1005", categoryId: "ai-fundamentals", price: 29, currency: "USD", status: "published", submittedAt: daysAgoIso(180), thumbnailUrl: img("prompt-engineering-fundamentals"), featured: true, pinned: true, rating: 4.8, enrollmentCount: 1240 },
  { id: "crs_a5", title: "AI-Powered Marketing Campaigns", instructorName: "Zara Farooq", instructorId: "usr_1008", categoryId: "ai-marketing", price: 49, currency: "USD", status: "published", submittedAt: daysAgoIso(150), thumbnailUrl: img("ai-powered-marketing-campaigns"), featured: false, pinned: false, rating: 4.6, enrollmentCount: 812 },
  { id: "crs_a6", title: "Automate Everything with n8n & AI", instructorName: "Ayesha Khan", instructorId: "usr_1001", categoryId: "ai-automation", price: 39, currency: "USD", status: "published", submittedAt: daysAgoIso(140), thumbnailUrl: img("automate-everything-with-n8n-and-ai"), featured: true, pinned: false, rating: 4.7, enrollmentCount: 654 },
  { id: "crs_a7", title: "Build a WhatsApp AI Auto-Responder", instructorName: "Bilal Ahmed", instructorId: "usr_1002", categoryId: "ai-support", price: 59, currency: "USD", status: "published", submittedAt: daysAgoIso(120), thumbnailUrl: img("build-a-whatsapp-ai-auto-responder"), featured: false, pinned: false, rating: 4.9, enrollmentCount: 401 },
  { id: "crs_a8", title: "Ship Your First AI-Powered Web App", instructorName: "Hamza Tariq", instructorId: "usr_1011", categoryId: "ai-dev", price: 45, currency: "USD", status: "published", submittedAt: daysAgoIso(100), thumbnailUrl: img("ship-your-first-ai-powered-web-app"), featured: false, pinned: false, rating: 4.5, enrollmentCount: 588 },
  { id: "crs_a9", title: "Integrating OpenAI & Claude APIs into Node.js Apps", instructorName: "Usman Ali", instructorId: "usr_1007", categoryId: "ai-integration", price: 65, currency: "USD", status: "published", submittedAt: daysAgoIso(90), thumbnailUrl: img("integrating-openai-and-claude-apis-into-node"), featured: true, pinned: false, rating: 4.9, enrollmentCount: 320 },
  { id: "crs_a10", title: "AI Video Scripts for YouTube Growth", instructorName: "Danish Raza", instructorId: "usr_1009", categoryId: "ai-marketing", price: 35, currency: "USD", status: "rejected", submittedAt: daysAgoIso(14), thumbnailUrl: img("ai-video-scripts"), featured: false, pinned: false, rating: 0, enrollmentCount: 0, rejectionReason: "Curriculum lacked hands-on exercises; resubmit with a project-based module." },
  { id: "crs_a11", title: "Midjourney for Product Mockups", instructorName: "Sara Iqbal", instructorId: "usr_1010", categoryId: "ai-design", price: 25, currency: "USD", status: "draft", submittedAt: daysAgoIso(0), thumbnailUrl: img("midjourney-product-mockups"), featured: false, pinned: false, rating: 0, enrollmentCount: 0 },
  { id: "crs_a12", title: "AI Resume & Interview Prep Toolkit", instructorName: "Hina Malik", instructorId: "usr_1003", categoryId: "ai-career", price: 19, currency: "USD", status: "archived", submittedAt: daysAgoIso(365), thumbnailUrl: img("ai-resume-toolkit"), featured: false, pinned: false, rating: 4.1, enrollmentCount: 210 }
];
'@
Write-Utf8NoBom -Path "packages\api-client\src\dummy-data-admin-courses.ts" -Content $adminCourseDummyData

Patch-File -Path "packages\api-client\src\index.ts" `
  -OldStr 'export * from "./hooks/useAdminUsers";' `
  -NewStr @'
export * from "./hooks/useAdminUsers";
export * from "./dummy-data-admin-courses";
export * from "./hooks/useAdminCourses";
'@ `
  -Label "export admin course dummy data + hooks"

# ---------------------------------------------------------------------------
# 2. useAdminCourses hooks - moderation queue, catalog, categories CRUD
# ---------------------------------------------------------------------------
$useAdminCourses = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_COURSES,
  ADMIN_DUMMY_CATEGORIES,
  type AdminCourse,
  type AdminCourseStatus,
  type AdminCategory
} from "../dummy-data-admin-courses";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Admin-Courses / Categories API (Doc 3).
let COURSES_STATE: AdminCourse[] = [...ADMIN_DUMMY_COURSES];
let CATEGORIES_STATE: AdminCategory[] = [...ADMIN_DUMMY_CATEGORIES];

export const adminCourseKeys = {
  all: ["admin", "courses"] as const,
  moderationQueue: ["admin", "courses", "moderation-queue"] as const,
  catalog: (filters?: Record<string, unknown>) => ["admin", "courses", "catalog", filters] as const,
  categories: ["admin", "categories"] as const
};

export function useAdminModerationQueue() {
  return useQuery({
    queryKey: adminCourseKeys.moderationQueue,
    queryFn: async () => delay(COURSES_STATE.filter((c) => c.status === "pending_review"))
  });
}

export type AdminCourseCatalogFilters = {
  search?: string;
  categoryId?: string;
  status?: string;
};

export function useAdminCourseCatalog(filters: AdminCourseCatalogFilters = {}) {
  return useQuery({
    queryKey: adminCourseKeys.catalog(filters),
    queryFn: async () => {
      let items = [...COURSES_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((c) => c.title.toLowerCase().includes(q) || c.instructorName.toLowerCase().includes(q));
      }
      if (filters.categoryId) items = items.filter((c) => c.categoryId === filters.categoryId);
      if (filters.status) items = items.filter((c) => c.status === filters.status);
      return delay(items);
    }
  });
}

export function useModerateCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      decision,
      reason
    }: {
      id: string;
      decision: "published" | "rejected";
      reason?: string;
    }) => {
      COURSES_STATE = COURSES_STATE.map((c) =>
        c.id === id ? { ...c, status: decision as AdminCourseStatus, rejectionReason: reason } : c
      );
      return delay({ id, decision }, 400);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.all });
    }
  });
}

export function useToggleCourseFlag() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, field }: { id: string; field: "featured" | "pinned" }) => {
      COURSES_STATE = COURSES_STATE.map((c) => (c.id === id ? { ...c, [field]: !c[field] } : c));
      return delay({ id, field }, 200);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.all });
    }
  });
}

export function useAdminCategoryList() {
  return useQuery({
    queryKey: adminCourseKeys.categories,
    queryFn: async () => delay([...CATEGORIES_STATE])
  });
}

export function useCreateCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { name: string; tags: string[] }) => {
      const slug = input.name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/(^-|-$)/g, "");
      const created: AdminCategory = { id: slug, name: input.name, slug, courseCount: 0, tags: input.tags };
      CATEGORIES_STATE = [...CATEGORIES_STATE, created];
      return delay(created, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.categories });
    }
  });
}

export function useUpdateCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, name, tags }: { id: string; name: string; tags: string[] }) => {
      CATEGORIES_STATE = CATEGORIES_STATE.map((c) => (c.id === id ? { ...c, name, tags } : c));
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.categories });
    }
  });
}

export function useDeleteCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      CATEGORIES_STATE = CATEGORIES_STATE.filter((c) => c.id !== id);
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminCourseKeys.categories });
    }
  });
}
'@
Write-Utf8NoBom -Path "packages\api-client\src\hooks\useAdminCourses.ts" -Content $useAdminCourses

# ---------------------------------------------------------------------------
# 3. Course Moderation Queue page - card queue, approve/reject with feedback
# ---------------------------------------------------------------------------
$moderationPage = @'
"use client";

import { useState } from "react";
import { CheckCircle2, XCircle, ClipboardCheck, User, Tag } from "lucide-react";
import { useAdminModerationQueue, useModerateCourse, type AdminCourse } from "@saachi/api-client";
import { Button, Card, Textarea, Modal, EmptyState, ShimmerKpiCard } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

export default function CourseModerationQueuePage() {
  const { data: queue, isLoading } = useAdminModerationQueue();
  const moderate = useModerateCourse();
  const [rejectTarget, setRejectTarget] = useState<AdminCourse | null>(null);
  const [reason, setReason] = useState("");

  const handleApprove = (course: AdminCourse) => {
    moderate.mutate({ id: course.id, decision: "published" });
  };

  const handleRejectSubmit = () => {
    if (!rejectTarget) return;
    moderate.mutate({ id: rejectTarget.id, decision: "rejected", reason });
    setRejectTarget(null);
    setReason("");
  };

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <ClipboardCheck size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Course Moderation Queue</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Review newly submitted courses before they go live.</p>
        </div>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          {Array.from({ length: 3 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      ) : !queue || queue.length === 0 ? (
        <EmptyState
          icon={<ClipboardCheck size={22} strokeWidth={1.75} />}
          title="Queue is clear"
          description="No courses are currently pending review."
        />
      ) : (
        <div className="flex flex-col gap-4">
          {queue.map((course) => (
            <Card key={course.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center">
              <div className="h-[90px] w-[160px] shrink-0 overflow-hidden rounded-control border border-line bg-paper-dim">
                {course.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={course.thumbnailUrl} alt={course.title} className="h-full w-full object-cover" />
                )}
              </div>

              <div className="flex-1">
                <h3 className="text-[15px] font-semibold text-ink">{course.title}</h3>
                <div className="mt-1.5 flex flex-wrap items-center gap-x-4 gap-y-1 text-[12.5px] text-ink-soft">
                  <span className="flex items-center gap-1.5">
                    <User size={13} strokeWidth={1.75} /> {course.instructorName}
                  </span>
                  <span className="flex items-center gap-1.5">
                    <Tag size={13} strokeWidth={1.75} /> {course.categoryId}
                  </span>
                  <span>Submitted {formatDate(course.submittedAt)}</span>
                  <span className="font-mono font-semibold text-ink">
                    {formatCurrency(course.price, course.currency)}
                  </span>
                </div>
              </div>

              <div className="flex shrink-0 gap-2">
                <Button size="sm" variant="secondary" onClick={() => setRejectTarget(course)}>
                  <XCircle size={14} strokeWidth={1.75} /> Reject
                </Button>
                <Button size="sm" onClick={() => handleApprove(course)} disabled={moderate.isPending}>
                  <CheckCircle2 size={14} strokeWidth={1.75} /> Approve
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal
        open={Boolean(rejectTarget)}
        onClose={() => setRejectTarget(null)}
        title="Reject course submission"
        footer={
          <>
            <Button variant="ghost" onClick={() => setRejectTarget(null)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleRejectSubmit} disabled={!reason.trim() || moderate.isPending}>
              {moderate.isPending ? "Sending..." : "Send feedback & reject"}
            </Button>
          </>
        }
      >
        <p className="mb-4 text-[13px] text-ink-soft">
          Rejecting <span className="font-semibold text-ink">{rejectTarget?.title}</span>. This feedback is sent to
          the instructor so they can revise and resubmit.
        </p>
        <Textarea
          label="Feedback for instructor"
          placeholder="Explain what needs to change before this course can be approved..."
          rows={5}
          value={reason}
          onChange={(e) => setReason(e.target.value)}
        />
      </Modal>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\courses\moderation\page.tsx" -Content $moderationPage

# ---------------------------------------------------------------------------
# 4. Course Catalog page - full DataTable, feature/pin toggle controls
# ---------------------------------------------------------------------------
$catalogPage = @'
"use client";

import { useMemo, useState } from "react";
import { Search, LibraryBig, Star, Pin } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import {
  useAdminCourseCatalog,
  useAdminCategoryList,
  useToggleCourseFlag,
  type AdminCourse
} from "@saachi/api-client";
import { DataTable, StatusPill, Select } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Draft", value: "draft" },
  { label: "Pending review", value: "pending_review" },
  { label: "Published", value: "published" },
  { label: "Rejected", value: "rejected" },
  { label: "Archived", value: "archived" }
];

const STATUS_TONE: Record<AdminCourse["status"], "success" | "warning" | "error" | "info" | "neutral"> = {
  draft: "neutral",
  pending_review: "warning",
  published: "success",
  rejected: "error",
  archived: "info"
};

export default function CourseCatalogPage() {
  const [search, setSearch] = useState("");
  const [categoryId, setCategoryId] = useState("");
  const [status, setStatus] = useState("");

  const { data: categories } = useAdminCategoryList();
  const { data, isLoading } = useAdminCourseCatalog({
    search: search || undefined,
    categoryId: categoryId || undefined,
    status: status || undefined
  });
  const toggleFlag = useToggleCourseFlag();

  const categoryOptions = useMemo(
    () => (categories ?? []).map((c) => ({ label: c.name, value: c.id })),
    [categories]
  );

  const columns = useMemo<ColumnDef<AdminCourse, any>[]>(
    () => [
      {
        header: "Course",
        accessorKey: "title",
        cell: ({ row }) => (
          <div className="flex items-center gap-3">
            <div className="h-9 w-16 shrink-0 overflow-hidden rounded-control border border-line bg-paper-dim">
              {row.original.thumbnailUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img src={row.original.thumbnailUrl} alt={row.original.title} className="h-full w-full object-cover" />
              )}
            </div>
            <div className="max-w-[260px]">
              <div className="truncate font-medium text-ink">{row.original.title}</div>
              <div className="text-[12px] text-ink-soft">{row.original.instructorName}</div>
            </div>
          </div>
        )
      },
      {
        header: "Category",
        accessorKey: "categoryId",
        cell: ({ getValue }) => <span className="text-ink-soft">{getValue()}</span>
      },
      {
        header: "Price",
        accessorKey: "price",
        cell: ({ row }) => (
          <span className="font-mono font-semibold text-ink">
            {formatCurrency(row.original.price, row.original.currency)}
          </span>
        )
      },
      {
        header: "Status",
        accessorKey: "status",
        cell: ({ getValue }) => {
          const value = getValue() as AdminCourse["status"];
          return <StatusPill label={value.replace("_", " ")} tone={STATUS_TONE[value]} />;
        }
      },
      {
        header: "Enrollments",
        accessorKey: "enrollmentCount",
        cell: ({ getValue }) => <span className="font-mono text-ink-soft">{(getValue() as number).toLocaleString()}</span>
      },
      {
        header: "Submitted",
        accessorKey: "submittedAt",
        cell: ({ getValue }) => <span className="text-ink-soft">{formatDate(getValue() as string)}</span>
      },
      {
        header: "Curate",
        id: "curate",
        cell: ({ row }) => (
          <div className="flex items-center gap-1.5">
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                toggleFlag.mutate({ id: row.original.id, field: "featured" });
              }}
              title="Toggle featured"
              className={`flex h-7 w-7 items-center justify-center rounded-control border transition-colors duration-150 ease-out ${
                row.original.featured ? "border-ink bg-ink text-paper" : "border-line text-ink-soft hover:text-ink"
              }`}
            >
              <Star size={13} strokeWidth={1.75} />
            </button>
            <button
              type="button"
              onClick={(e) => {
                e.stopPropagation();
                toggleFlag.mutate({ id: row.original.id, field: "pinned" });
              }}
              title="Toggle pinned"
              className={`flex h-7 w-7 items-center justify-center rounded-control border transition-colors duration-150 ease-out ${
                row.original.pinned ? "border-ink bg-ink text-paper" : "border-line text-ink-soft hover:text-ink"
              }`}
            >
              <Pin size={13} strokeWidth={1.75} />
            </button>
          </div>
        )
      }
    ],
    [toggleFlag]
  );

  return (
    <main className="mx-auto max-w-[1200px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <LibraryBig size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Course Catalog</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Full catalog across every status - feature or pin courses for curation.</p>
        </div>
      </div>

      <DataTable
        columns={columns}
        data={data ?? []}
        isLoading={isLoading}
        emptyTitle="No courses found"
        emptyDescription="Try adjusting your search or filters."
        toolbar={
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center">
            <div className="relative flex-1">
              <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
              <input
                placeholder="Search by title or instructor"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
              />
            </div>
            <div className="sm:w-[220px]">
              <Select placeholder="All categories" options={categoryOptions} value={categoryId} onChange={(e) => setCategoryId(e.target.value)} />
            </div>
            <div className="sm:w-[180px]">
              <Select placeholder="All statuses" options={STATUS_OPTIONS} value={status} onChange={(e) => setStatus(e.target.value)} />
            </div>
          </div>
        }
      />
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\courses\catalog\page.tsx" -Content $catalogPage

# ---------------------------------------------------------------------------
# 5. Category & Tag Management page - CRUD via modal
# ---------------------------------------------------------------------------
$categoriesPage = @'
"use client";

import { useState } from "react";
import { Tags, Plus, Pencil, Trash2, X } from "lucide-react";
import {
  useAdminCategoryList,
  useCreateCategory,
  useUpdateCategory,
  useDeleteCategory,
  type AdminCategory
} from "@saachi/api-client";
import { Button, Card, Input, Modal, ShimmerTableRow, Badge } from "@saachi/ui";

export default function CategoryManagementPage() {
  const { data: categories, isLoading } = useAdminCategoryList();
  const createCategory = useCreateCategory();
  const updateCategory = useUpdateCategory();
  const deleteCategory = useDeleteCategory();

  const [editing, setEditing] = useState<AdminCategory | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [name, setName] = useState("");
  const [tagInput, setTagInput] = useState("");
  const [tags, setTags] = useState<string[]>([]);
  const [deleteTarget, setDeleteTarget] = useState<AdminCategory | null>(null);

  const openCreate = () => {
    setName("");
    setTags([]);
    setTagInput("");
    setShowCreate(true);
  };

  const openEdit = (category: AdminCategory) => {
    setEditing(category);
    setName(category.name);
    setTags(category.tags);
    setTagInput("");
  };

  const addTag = () => {
    const value = tagInput.trim().toLowerCase();
    if (!value || tags.includes(value)) return;
    setTags((prev) => [...prev, value]);
    setTagInput("");
  };

  const handleSave = () => {
    if (!name.trim()) return;
    if (editing) {
      updateCategory.mutate({ id: editing.id, name: name.trim(), tags });
      setEditing(null);
    } else {
      createCategory.mutate({ name: name.trim(), tags });
      setShowCreate(false);
    }
  };

  const handleDelete = () => {
    if (!deleteTarget) return;
    deleteCategory.mutate(deleteTarget.id);
    setDeleteTarget(null);
  };

  const modalOpen = showCreate || Boolean(editing);

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Tags size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Category & Tag Management</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Taxonomy used across the marketplace and course builder.</p>
          </div>
        </div>
        <Button size="sm" onClick={openCreate}>
          <Plus size={14} strokeWidth={1.75} /> New category
        </Button>
      </div>

      <div className="overflow-hidden rounded-card border border-line bg-card">
        {isLoading ? (
          Array.from({ length: 5 }).map((_, i) => <ShimmerTableRow key={i} columns={3} />)
        ) : (
          categories?.map((category) => (
            <div key={category.id} className="flex flex-col gap-3 border-b border-line px-5 py-4 last:border-0 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <div className="flex items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{category.name}</p>
                  <span className="text-[12px] text-ink-soft">/{category.slug}</span>
                </div>
                <div className="mt-2 flex flex-wrap gap-1.5">
                  {category.tags.map((tag) => (
                    <Badge key={tag}>{tag}</Badge>
                  ))}
                </div>
              </div>
              <div className="flex shrink-0 items-center gap-4">
                <span className="text-[12px] text-ink-soft">{category.courseCount} courses</span>
                <div className="flex gap-1.5">
                  <button
                    type="button"
                    onClick={() => openEdit(category)}
                    className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
                  >
                    <Pencil size={14} strokeWidth={1.75} />
                  </button>
                  <button
                    type="button"
                    onClick={() => setDeleteTarget(category)}
                    className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
                  >
                    <Trash2 size={14} strokeWidth={1.75} />
                  </button>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      <Modal
        open={modalOpen}
        onClose={() => {
          setShowCreate(false);
          setEditing(null);
        }}
        title={editing ? "Edit category" : "New category"}
        footer={
          <>
            <Button
              variant="ghost"
              onClick={() => {
                setShowCreate(false);
                setEditing(null);
              }}
            >
              Cancel
            </Button>
            <Button onClick={handleSave} disabled={!name.trim() || createCategory.isPending || updateCategory.isPending}>
              {editing ? "Save changes" : "Create category"}
            </Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input label="Category name" value={name} onChange={(e) => setName(e.target.value)} placeholder="e.g. AI for Careers & Job Search" />
          <div>
            <label className="mb-1.5 block text-[13px] font-semibold text-ink">Tags</label>
            <div className="mb-2 flex flex-wrap gap-1.5">
              {tags.map((tag) => (
                <span key={tag} className="flex items-center gap-1.5 rounded-full border border-line-strong px-2.5 py-1 text-[12px] text-ink">
                  {tag}
                  <button type="button" onClick={() => setTags((prev) => prev.filter((t) => t !== tag))} className="text-ink-soft hover:text-error">
                    <X size={11} strokeWidth={2} />
                  </button>
                </span>
              ))}
            </div>
            <div className="flex gap-2">
              <Input
                placeholder="Add a tag and press Enter"
                value={tagInput}
                onChange={(e) => setTagInput(e.target.value)}
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    addTag();
                  }
                }}
                className="h-10 flex-1"
              />
              <Button type="button" size="sm" variant="secondary" onClick={addTag}>
                Add
              </Button>
            </div>
          </div>
        </div>
      </Modal>

      <Modal
        open={Boolean(deleteTarget)}
        onClose={() => setDeleteTarget(null)}
        title="Delete category?"
        footer={
          <>
            <Button variant="ghost" onClick={() => setDeleteTarget(null)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleDelete} disabled={deleteCategory.isPending}>
              Delete
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          This will remove <span className="font-semibold text-ink">{deleteTarget?.name}</span> from the taxonomy.
          Courses already assigned to it will need to be recategorized.
        </p>
      </Modal>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\courses\categories\page.tsx" -Content $categoriesPage

Write-Host ""
Write-Host "Step 13 done." -ForegroundColor Green
Write-Host "Run: pnpm install" -ForegroundColor Yellow
Write-Host "Then: pnpm dev:admin" -ForegroundColor Green
Write-Host ""
Write-Host "What this step built:" -ForegroundColor Cyan
Write-Host "  - Admin course + category dummy data (12 seeded courses across all statuses, 8 categories)"
Write-Host "  - useAdminCourses hooks: moderation queue, catalog (search/category/status filters), approve/reject,"
Write-Host "    feature/pin toggles, category CRUD"
Write-Host "  - /courses/moderation - pending-review queue cards, Approve, Reject-with-feedback modal"
Write-Host "  - /courses/catalog - full DataTable, feature (star) + pin toggle controls per row"
Write-Host "  - /courses/categories - taxonomy CRUD: create/edit/delete category with tag chips"
Write-Host ""
Write-Host "Next: Step 14 - Finance (Transactions, Payouts, Refunds, Tax Settings)" -ForegroundColor Cyan