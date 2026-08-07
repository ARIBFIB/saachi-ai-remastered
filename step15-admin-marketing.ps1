# step15-admin-marketing.ps1
# Run from: SAI2 root folder
# Builds: Marketing module - Homepage Banner CMS, Coupon Management,
# Promotion Package Sales Tracking.

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

Write-Host "Step 15: Admin Marketing (Banners, Coupons, Promotion Sales)..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Dummy data - banners, coupons, promotion sales
# ---------------------------------------------------------------------------
$adminMarketingDummyData = @'
export type BannerStatus = "scheduled" | "active" | "expired" | "draft";

export type AdminBanner = {
  id: string;
  title: string;
  subtitle?: string;
  imageUrl: string;
  linkUrl: string;
  status: BannerStatus;
  startsAt: string;
  endsAt: string;
  order: number;
};

export type CouponType = "percent" | "fixed";

export type AdminCoupon = {
  id: string;
  code: string;
  type: CouponType;
  value: number;
  scope: "platform_wide" | "category" | "course";
  usageLimit: number;
  usageCount: number;
  expiresAt: string;
  active: boolean;
};

export type PromotionTier = "bronze" | "silver" | "gold";

export type PromotionSale = {
  id: string;
  courseTitle: string;
  instructorName: string;
  tier: PromotionTier;
  amount: number;
  currency: string;
  purchasedAt: string;
  expiresAt: string;
};

function img(seed: string): string {
  return `https://picsum.photos/seed/${encodeURIComponent(seed)}/1200/400`;
}

function daysAgoIso(n: number): string {
  return new Date(Date.now() - n * 24 * 60 * 60 * 1000).toISOString();
}

function daysFromNowIso(n: number): string {
  return new Date(Date.now() + n * 24 * 60 * 60 * 1000).toISOString();
}

export const ADMIN_DUMMY_BANNERS: AdminBanner[] = [
  { id: "ban_1", title: "Founding Instructor Spots Open", subtitle: "Join early access and get featured placement", imageUrl: img("founding-instructor-banner"), linkUrl: "/register", status: "active", startsAt: daysAgoIso(5), endsAt: daysFromNowIso(10), order: 1 },
  { id: "ban_2", title: "New: AI Automation Track", subtitle: "Five new n8n + AI courses just launched", imageUrl: img("automation-track-banner"), linkUrl: "/categories/ai-automation", status: "active", startsAt: daysAgoIso(2), endsAt: daysFromNowIso(12), order: 2 },
  { id: "ban_3", title: "Ramadan Learning Sale", subtitle: "25% off with code SAACHI25", imageUrl: img("ramadan-sale-banner"), linkUrl: "/courses", status: "scheduled", startsAt: daysFromNowIso(20), endsAt: daysFromNowIso(35), order: 3 },
  { id: "ban_4", title: "Saachi AI Pro Launch", subtitle: "Unlimited access to Standard-tier courses", imageUrl: img("pro-launch-banner"), linkUrl: "/pricing", status: "expired", startsAt: daysAgoIso(60), endsAt: daysAgoIso(30), order: 4 },
  { id: "ban_5", title: "Corporate Team Plans", subtitle: "Bulk seats for your team - contact sales", imageUrl: img("corporate-banner"), linkUrl: "/contact", status: "draft", startsAt: daysFromNowIso(5), endsAt: daysFromNowIso(45), order: 5 }
];

export const ADMIN_DUMMY_COUPONS: AdminCoupon[] = [
  { id: "cpn_1", code: "SAACHI10", type: "percent", value: 10, scope: "platform_wide", usageLimit: 1000, usageCount: 412, expiresAt: daysFromNowIso(60), active: true },
  { id: "cpn_2", code: "SAACHI25", type: "percent", value: 25, scope: "platform_wide", usageLimit: 500, usageCount: 88, expiresAt: daysFromNowIso(15), active: true },
  { id: "cpn_3", code: "AUTOMATE20", type: "percent", value: 20, scope: "category", usageLimit: 200, usageCount: 200, expiresAt: daysAgoIso(3), active: false },
  { id: "cpn_4", code: "WELCOME5", type: "fixed", value: 5, scope: "platform_wide", usageLimit: 2000, usageCount: 1560, expiresAt: daysFromNowIso(90), active: true },
  { id: "cpn_5", code: "WHATSAPP15", type: "fixed", value: 15, scope: "course", usageLimit: 100, usageCount: 34, expiresAt: daysFromNowIso(30), active: true }
];

export const ADMIN_DUMMY_PROMOTION_SALES: PromotionSale[] = [
  { id: "ps_1", courseTitle: "Prompt Engineering Fundamentals", instructorName: "Sana Rizvi", tier: "gold", amount: 75, currency: "USD", purchasedAt: daysAgoIso(1), expiresAt: daysFromNowIso(13) },
  { id: "ps_2", courseTitle: "Automate Everything with n8n & AI", instructorName: "Ayesha Khan", tier: "silver", amount: 35, currency: "USD", purchasedAt: daysAgoIso(3), expiresAt: daysFromNowIso(11) },
  { id: "ps_3", courseTitle: "AI-Powered Marketing Campaigns", instructorName: "Zara Farooq", tier: "bronze", amount: 15, currency: "USD", purchasedAt: daysAgoIso(5), expiresAt: daysFromNowIso(9) },
  { id: "ps_4", courseTitle: "Integrating OpenAI & Claude APIs into Node.js Apps", instructorName: "Usman Ali", tier: "gold", amount: 75, currency: "USD", purchasedAt: daysAgoIso(8), expiresAt: daysFromNowIso(6) },
  { id: "ps_5", courseTitle: "Build a WhatsApp AI Auto-Responder", instructorName: "Bilal Ahmed", tier: "silver", amount: 35, currency: "USD", purchasedAt: daysAgoIso(20), expiresAt: daysAgoIso(6) },
  { id: "ps_6", courseTitle: "Ship Your First AI-Powered Web App", instructorName: "Hamza Tariq", tier: "bronze", amount: 15, currency: "USD", purchasedAt: daysAgoIso(25), expiresAt: daysAgoIso(11) }
];
'@
Write-Utf8NoBom -Path "packages\api-client\src\dummy-data-admin-marketing.ts" -Content $adminMarketingDummyData

Patch-File -Path "packages\api-client\src\index.ts" `
  -OldStr 'export * from "./hooks/useAdminFinance";' `
  -NewStr @'
export * from "./hooks/useAdminFinance";
export * from "./dummy-data-admin-marketing";
export * from "./hooks/useAdminMarketing";
'@ `
  -Label "export admin marketing dummy data + hooks"

# ---------------------------------------------------------------------------
# 2. useAdminMarketing hooks
# ---------------------------------------------------------------------------
$useAdminMarketing = @'
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  ADMIN_DUMMY_BANNERS,
  ADMIN_DUMMY_COUPONS,
  ADMIN_DUMMY_PROMOTION_SALES,
  type AdminBanner,
  type AdminCoupon,
  type PromotionSale
} from "../dummy-data-admin-marketing";

function delay<T>(value: T, ms = 350): Promise<T> {
  return new Promise((resolve) => setTimeout(() => resolve(value), ms));
}

// NOTE: demo-only, in-memory. Replace with real Marketing API (Doc 3) once available.
let BANNERS_STATE: AdminBanner[] = [...ADMIN_DUMMY_BANNERS];
let COUPONS_STATE: AdminCoupon[] = [...ADMIN_DUMMY_COUPONS];
let PROMOTION_SALES_STATE: PromotionSale[] = [...ADMIN_DUMMY_PROMOTION_SALES];

export const adminMarketingKeys = {
  banners: ["admin", "marketing", "banners"] as const,
  coupons: (filters?: Record<string, unknown>) => ["admin", "marketing", "coupons", filters] as const,
  promotionSales: ["admin", "marketing", "promotion-sales"] as const
};

// ---------------------------------------------------------------------------
// Banners
// ---------------------------------------------------------------------------
export function useAdminBanners() {
  return useQuery({
    queryKey: adminMarketingKeys.banners,
    queryFn: async () => delay([...BANNERS_STATE].sort((a, b) => a.order - b.order))
  });
}

export function useCreateBanner() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: Omit<AdminBanner, "id" | "order">) => {
      const created: AdminBanner = {
        ...input,
        id: `ban_${Math.random().toString(36).slice(2, 8)}`,
        order: BANNERS_STATE.length + 1
      };
      BANNERS_STATE = [...BANNERS_STATE, created];
      return delay(created, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminMarketingKeys.banners });
    }
  });
}

export function useUpdateBanner() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, ...patch }: Partial<AdminBanner> & { id: string }) => {
      BANNERS_STATE = BANNERS_STATE.map((b) => (b.id === id ? { ...b, ...patch } : b));
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminMarketingKeys.banners });
    }
  });
}

export function useDeleteBanner() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      BANNERS_STATE = BANNERS_STATE.filter((b) => b.id !== id);
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminMarketingKeys.banners });
    }
  });
}

export function useReorderBanner() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, direction }: { id: string; direction: "up" | "down" }) => {
      const sorted = [...BANNERS_STATE].sort((a, b) => a.order - b.order);
      const index = sorted.findIndex((b) => b.id === id);
      const swapWith = direction === "up" ? index - 1 : index + 1;
      if (swapWith < 0 || swapWith >= sorted.length) return delay({ id }, 100);
      const a = sorted[index];
      const b = sorted[swapWith];
      const aOrder = a.order;
      a.order = b.order;
      b.order = aOrder;
      BANNERS_STATE = sorted;
      return delay({ id }, 250);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: adminMarketingKeys.banners });
    }
  });
}

// ---------------------------------------------------------------------------
// Coupons
// ---------------------------------------------------------------------------
export type CouponFilters = {
  search?: string;
  active?: boolean;
};

export function useAdminCoupons(filters: CouponFilters = {}) {
  return useQuery({
    queryKey: adminMarketingKeys.coupons(filters),
    queryFn: async () => {
      let items = [...COUPONS_STATE];
      if (filters.search) {
        const q = filters.search.toLowerCase();
        items = items.filter((c) => c.code.toLowerCase().includes(q));
      }
      if (typeof filters.active === "boolean") items = items.filter((c) => c.active === filters.active);
      return delay(items);
    }
  });
}

export function useCreateCoupon() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: Omit<AdminCoupon, "id" | "usageCount">) => {
      const created: AdminCoupon = {
        ...input,
        id: `cpn_${Math.random().toString(36).slice(2, 8)}`,
        usageCount: 0
      };
      COUPONS_STATE = [...COUPONS_STATE, created];
      return delay(created, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "marketing", "coupons"] });
    }
  });
}

export function useToggleCouponActive() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      COUPONS_STATE = COUPONS_STATE.map((c) => (c.id === id ? { ...c, active: !c.active } : c));
      return delay({ id }, 200);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "marketing", "coupons"] });
    }
  });
}

export function useDeleteCoupon() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      COUPONS_STATE = COUPONS_STATE.filter((c) => c.id !== id);
      return delay({ id }, 300);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "marketing", "coupons"] });
    }
  });
}

// ---------------------------------------------------------------------------
// Promotion package sales tracking
// ---------------------------------------------------------------------------
export function useAdminPromotionSales() {
  return useQuery({
    queryKey: adminMarketingKeys.promotionSales,
    queryFn: async () => delay([...PROMOTION_SALES_STATE])
  });
}
'@
Write-Utf8NoBom -Path "packages\api-client\src\hooks\useAdminMarketing.ts" -Content $useAdminMarketing

# ---------------------------------------------------------------------------
# 3. Homepage Banner CMS page
# ---------------------------------------------------------------------------
$bannersPage = @'
"use client";

import { useState } from "react";
import { Image as ImageIcon, Plus, Pencil, Trash2, ArrowUp, ArrowDown } from "lucide-react";
import {
  useAdminBanners,
  useCreateBanner,
  useUpdateBanner,
  useDeleteBanner,
  useReorderBanner,
  type AdminBanner
} from "@saachi/api-client";
import { Button, Card, Input, Textarea, Select, Modal, StatusPill, ShimmerKpiCard, EmptyState } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

const STATUS_OPTIONS = [
  { label: "Draft", value: "draft" },
  { label: "Scheduled", value: "scheduled" },
  { label: "Active", value: "active" },
  { label: "Expired", value: "expired" }
];

const STATUS_TONE: Record<AdminBanner["status"], "success" | "warning" | "error" | "info" | "neutral"> = {
  active: "success",
  scheduled: "info",
  expired: "error",
  draft: "neutral"
};

type FormState = {
  title: string;
  subtitle: string;
  imageUrl: string;
  linkUrl: string;
  status: AdminBanner["status"];
  startsAt: string;
  endsAt: string;
};

const EMPTY_FORM: FormState = {
  title: "",
  subtitle: "",
  imageUrl: "",
  linkUrl: "",
  status: "draft",
  startsAt: new Date().toISOString().slice(0, 10),
  endsAt: new Date(Date.now() + 14 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10)
};

export default function HomepageBannersPage() {
  const { data: banners, isLoading } = useAdminBanners();
  const createBanner = useCreateBanner();
  const updateBanner = useUpdateBanner();
  const deleteBanner = useDeleteBanner();
  const reorderBanner = useReorderBanner();

  const [editing, setEditing] = useState<AdminBanner | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [form, setForm] = useState<FormState>(EMPTY_FORM);
  const [deleteTarget, setDeleteTarget] = useState<AdminBanner | null>(null);

  const openCreate = () => {
    setForm(EMPTY_FORM);
    setShowCreate(true);
  };

  const openEdit = (banner: AdminBanner) => {
    setEditing(banner);
    setForm({
      title: banner.title,
      subtitle: banner.subtitle ?? "",
      imageUrl: banner.imageUrl,
      linkUrl: banner.linkUrl,
      status: banner.status,
      startsAt: banner.startsAt.slice(0, 10),
      endsAt: banner.endsAt.slice(0, 10)
    });
  };

  const closeModals = () => {
    setShowCreate(false);
    setEditing(null);
  };

  const handleSave = () => {
    if (!form.title.trim()) return;
    const payload = {
      title: form.title.trim(),
      subtitle: form.subtitle.trim() || undefined,
      imageUrl: form.imageUrl.trim() || `https://picsum.photos/seed/${encodeURIComponent(form.title)}/1200/400`,
      linkUrl: form.linkUrl.trim() || "/",
      status: form.status,
      startsAt: new Date(form.startsAt).toISOString(),
      endsAt: new Date(form.endsAt).toISOString()
    };
    if (editing) {
      updateBanner.mutate({ id: editing.id, ...payload });
    } else {
      createBanner.mutate(payload);
    }
    closeModals();
  };

  const handleDelete = () => {
    if (!deleteTarget) return;
    deleteBanner.mutate(deleteTarget.id);
    setDeleteTarget(null);
  };

  const modalOpen = showCreate || Boolean(editing);

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <ImageIcon size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Homepage Banners</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Create, schedule, and reorder homepage promotional banners.</p>
          </div>
        </div>
        <Button size="sm" onClick={openCreate}>
          <Plus size={14} strokeWidth={1.75} /> New banner
        </Button>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      ) : !banners || banners.length === 0 ? (
        <EmptyState icon={<ImageIcon size={22} strokeWidth={1.75} />} title="No banners yet" description="Create your first homepage banner." />
      ) : (
        <div className="flex flex-col gap-3">
          {banners.map((banner, index) => (
            <Card key={banner.id} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center">
              <div className="h-[64px] w-[140px] shrink-0 overflow-hidden rounded-control border border-line bg-paper-dim">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src={banner.imageUrl} alt={banner.title} className="h-full w-full object-cover" />
              </div>

              <div className="flex-1">
                <div className="flex items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{banner.title}</p>
                  <StatusPill label={banner.status} tone={STATUS_TONE[banner.status]} />
                </div>
                {banner.subtitle && <p className="mt-1 text-[12.5px] text-ink-soft">{banner.subtitle}</p>}
                <p className="mt-1 text-[12px] text-ink-soft/70">
                  {formatDate(banner.startsAt)} - {formatDate(banner.endsAt)} - links to {banner.linkUrl}
                </p>
              </div>

              <div className="flex shrink-0 items-center gap-1.5">
                <button
                  type="button"
                  disabled={index === 0}
                  onClick={() => reorderBanner.mutate({ id: banner.id, direction: "up" })}
                  className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink disabled:opacity-30"
                >
                  <ArrowUp size={14} strokeWidth={1.75} />
                </button>
                <button
                  type="button"
                  disabled={index === banners.length - 1}
                  onClick={() => reorderBanner.mutate({ id: banner.id, direction: "down" })}
                  className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink disabled:opacity-30"
                >
                  <ArrowDown size={14} strokeWidth={1.75} />
                </button>
                <button
                  type="button"
                  onClick={() => openEdit(banner)}
                  className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-ink"
                >
                  <Pencil size={14} strokeWidth={1.75} />
                </button>
                <button
                  type="button"
                  onClick={() => setDeleteTarget(banner)}
                  className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
                >
                  <Trash2 size={14} strokeWidth={1.75} />
                </button>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Modal
        open={modalOpen}
        onClose={closeModals}
        title={editing ? "Edit banner" : "New banner"}
        size="lg"
        footer={
          <>
            <Button variant="ghost" onClick={closeModals}>
              Cancel
            </Button>
            <Button onClick={handleSave} disabled={!form.title.trim() || createBanner.isPending || updateBanner.isPending}>
              {editing ? "Save changes" : "Create banner"}
            </Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input label="Title" value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder="e.g. Founding Instructor Spots Open" />
          <Textarea label="Subtitle" value={form.subtitle} onChange={(e) => setForm({ ...form, subtitle: e.target.value })} rows={2} placeholder="Optional supporting line" />
          <Input label="Image URL" value={form.imageUrl} onChange={(e) => setForm({ ...form, imageUrl: e.target.value })} placeholder="Leave blank to use a placeholder image" />
          <Input label="Link URL" value={form.linkUrl} onChange={(e) => setForm({ ...form, linkUrl: e.target.value })} placeholder="/courses" />
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            <Select label="Status" options={STATUS_OPTIONS} value={form.status} onChange={(e) => setForm({ ...form, status: e.target.value as AdminBanner["status"] })} />
            <Input label="Starts" type="date" value={form.startsAt} onChange={(e) => setForm({ ...form, startsAt: e.target.value })} />
            <Input label="Ends" type="date" value={form.endsAt} onChange={(e) => setForm({ ...form, endsAt: e.target.value })} />
          </div>
        </div>
      </Modal>

      <Modal
        open={Boolean(deleteTarget)}
        onClose={() => setDeleteTarget(null)}
        title="Delete banner?"
        footer={
          <>
            <Button variant="ghost" onClick={() => setDeleteTarget(null)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleDelete} disabled={deleteBanner.isPending}>
              Delete
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          This will remove <span className="font-semibold text-ink">{deleteTarget?.title}</span> from the homepage rotation.
        </p>
      </Modal>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\marketing\banners\page.tsx" -Content $bannersPage

# ---------------------------------------------------------------------------
# 4. Coupon Management page
# ---------------------------------------------------------------------------
$couponsPage = @'
"use client";

import { useState } from "react";
import { Ticket, Plus, Trash2, Search } from "lucide-react";
import {
  useAdminCoupons,
  useCreateCoupon,
  useToggleCouponActive,
  useDeleteCoupon,
  type AdminCoupon
} from "@saachi/api-client";
import { Button, Card, Input, Select, Modal, ShimmerTableRow, EmptyState } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

const TYPE_OPTIONS = [
  { label: "Percent off", value: "percent" },
  { label: "Fixed amount off", value: "fixed" }
];

const SCOPE_OPTIONS = [
  { label: "Platform-wide", value: "platform_wide" },
  { label: "Category", value: "category" },
  { label: "Course", value: "course" }
];

export default function CouponManagementPage() {
  const [search, setSearch] = useState("");
  const { data: coupons, isLoading } = useAdminCoupons({ search: search || undefined });
  const createCoupon = useCreateCoupon();
  const toggleActive = useToggleCouponActive();
  const deleteCoupon = useDeleteCoupon();

  const [showCreate, setShowCreate] = useState(false);
  const [code, setCode] = useState("");
  const [type, setType] = useState<AdminCoupon["type"]>("percent");
  const [value, setValue] = useState(10);
  const [scope, setScope] = useState<AdminCoupon["scope"]>("platform_wide");
  const [usageLimit, setUsageLimit] = useState(100);
  const [expiresAt, setExpiresAt] = useState(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10));
  const [deleteTarget, setDeleteTarget] = useState<AdminCoupon | null>(null);

  const resetForm = () => {
    setCode("");
    setType("percent");
    setValue(10);
    setScope("platform_wide");
    setUsageLimit(100);
    setExpiresAt(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().slice(0, 10));
  };

  const handleCreate = () => {
    if (!code.trim()) return;
    createCoupon.mutate({
      code: code.trim().toUpperCase(),
      type,
      value,
      scope,
      usageLimit,
      expiresAt: new Date(expiresAt).toISOString(),
      active: true
    });
    setShowCreate(false);
    resetForm();
  };

  const handleDelete = () => {
    if (!deleteTarget) return;
    deleteCoupon.mutate(deleteTarget.id);
    setDeleteTarget(null);
  };

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <Ticket size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Coupon Management</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Platform-wide and scoped promotional codes.</p>
          </div>
        </div>
        <Button size="sm" onClick={() => setShowCreate(true)}>
          <Plus size={14} strokeWidth={1.75} /> New coupon
        </Button>
      </div>

      <div className="relative mb-5 max-w-[320px]">
        <Search size={15} strokeWidth={1.75} className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-ink-soft" />
        <input
          placeholder="Search coupon code"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="h-10 w-full rounded-control border border-line bg-card pl-9 pr-3 text-[13px] text-ink outline-none placeholder:text-ink-soft/60 focus:border-line-strong"
        />
      </div>

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={5} />
          ))}
        </div>
      ) : !coupons || coupons.length === 0 ? (
        <EmptyState icon={<Ticket size={22} strokeWidth={1.75} />} title="No coupons found" description="Try a different search, or create a new coupon." />
      ) : (
        <div className="flex flex-col gap-3">
          {coupons.map((coupon) => {
            const usagePct = coupon.usageLimit > 0 ? Math.round((coupon.usageCount / coupon.usageLimit) * 100) : 0;
            return (
              <Card key={coupon.id} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center sm:justify-between">
                <div>
                  <div className="flex items-center gap-2.5">
                    <span className="rounded-control border border-line-strong px-2.5 py-1 font-mono text-[13px] font-semibold text-ink">
                      {coupon.code}
                    </span>
                    <span
                      className={
                        coupon.active
                          ? "rounded-full bg-success-tint px-2.5 py-0.5 text-[11px] font-semibold text-success"
                          : "rounded-full bg-paper-dim px-2.5 py-0.5 text-[11px] font-semibold text-ink-soft"
                      }
                    >
                      {coupon.active ? "Active" : "Inactive"}
                    </span>
                  </div>
                  <p className="mt-1.5 text-[12.5px] text-ink-soft">
                    {coupon.type === "percent" ? `${coupon.value}% off` : `$${coupon.value} off`} - {coupon.scope.replace("_", " ")} -
                    {" "}{coupon.usageCount}/{coupon.usageLimit} used ({usagePct}%) - expires {formatDate(coupon.expiresAt)}
                  </p>
                </div>

                <div className="flex shrink-0 items-center gap-2">
                  <Button size="sm" variant="secondary" onClick={() => toggleActive.mutate(coupon.id)}>
                    {coupon.active ? "Deactivate" : "Activate"}
                  </Button>
                  <button
                    type="button"
                    onClick={() => setDeleteTarget(coupon)}
                    className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
                  >
                    <Trash2 size={15} strokeWidth={1.75} />
                  </button>
                </div>
              </Card>
            );
          })}
        </div>
      )}

      <Modal
        open={showCreate}
        onClose={() => setShowCreate(false)}
        title="New coupon"
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowCreate(false)}>
              Cancel
            </Button>
            <Button onClick={handleCreate} disabled={!code.trim() || createCoupon.isPending}>
              Create coupon
            </Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input label="Coupon code" value={code} onChange={(e) => setCode(e.target.value.toUpperCase())} placeholder="e.g. SUMMER20" />
          <div className="grid grid-cols-2 gap-4">
            <Select label="Discount type" options={TYPE_OPTIONS} value={type} onChange={(e) => setType(e.target.value as AdminCoupon["type"])} />
            <Input
              label={type === "percent" ? "Percent off" : "Amount off ($)"}
              type="number"
              min={0}
              value={value}
              onChange={(e) => setValue(Number(e.target.value))}
            />
          </div>
          <Select label="Scope" options={SCOPE_OPTIONS} value={scope} onChange={(e) => setScope(e.target.value as AdminCoupon["scope"])} />
          <div className="grid grid-cols-2 gap-4">
            <Input label="Usage limit" type="number" min={1} value={usageLimit} onChange={(e) => setUsageLimit(Number(e.target.value))} />
            <Input label="Expires" type="date" value={expiresAt} onChange={(e) => setExpiresAt(e.target.value)} />
          </div>
        </div>
      </Modal>

      <Modal
        open={Boolean(deleteTarget)}
        onClose={() => setDeleteTarget(null)}
        title="Delete coupon?"
        footer={
          <>
            <Button variant="ghost" onClick={() => setDeleteTarget(null)}>
              Cancel
            </Button>
            <Button variant="danger" onClick={handleDelete} disabled={deleteCoupon.isPending}>
              Delete
            </Button>
          </>
        }
      >
        <p className="text-[14px] text-ink-soft">
          This will permanently remove <span className="font-semibold text-ink">{deleteTarget?.code}</span>. It can no
          longer be applied at checkout.
        </p>
      </Modal>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\marketing\coupons\page.tsx" -Content $couponsPage

# ---------------------------------------------------------------------------
# 5. Promotion Package Sales Tracking page
# ---------------------------------------------------------------------------
$promotionsPage = @'
"use client";

import { Megaphone, Crown } from "lucide-react";
import { useAdminPromotionSales, type PromotionSale } from "@saachi/api-client";
import { Card, StatusPill, ShimmerKpiCard, ShimmerTableRow, EmptyState } from "@saachi/ui";
import { formatCurrency, formatDate } from "@saachi/utils";

const TIER_TONE: Record<PromotionSale["tier"], "warning" | "info" | "success"> = {
  bronze: "warning",
  silver: "info",
  gold: "success"
};

export default function PromotionSalesPage() {
  const { data: sales, isLoading } = useAdminPromotionSales();

  const now = Date.now();
  const active = (sales ?? []).filter((s) => new Date(s.expiresAt).getTime() > now);
  const totalRevenue = (sales ?? []).reduce((sum, s) => sum + s.amount, 0);
  const tierCounts = {
    gold: (sales ?? []).filter((s) => s.tier === "gold").length,
    silver: (sales ?? []).filter((s) => s.tier === "silver").length,
    bronze: (sales ?? []).filter((s) => s.tier === "bronze").length
  };

  return (
    <main className="mx-auto max-w-[1100px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <Megaphone size={17} strokeWidth={1.75} />
        </div>
        <div>
          <h1 className="text-[22px] font-semibold text-ink">Promotion Package Sales</h1>
          <p className="mt-0.5 text-[13px] text-ink-soft">Instructor purchases of Bronze/Silver/Gold visibility boosts.</p>
        </div>
      </div>

      {isLoading ? (
        <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerKpiCard key={i} />
          ))}
        </div>
      ) : (
        <div className="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <Card className="p-5">
            <p className="text-[12px] text-ink-soft">Total revenue</p>
            <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{formatCurrency(totalRevenue, "USD")}</p>
          </Card>
          <Card className="p-5">
            <p className="text-[12px] text-ink-soft">Currently active</p>
            <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{active.length}</p>
          </Card>
          <Card className="p-5">
            <p className="flex items-center gap-1.5 text-[12px] text-ink-soft">
              <Crown size={12} strokeWidth={1.75} /> Gold sold
            </p>
            <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{tierCounts.gold}</p>
          </Card>
          <Card className="p-5">
            <p className="text-[12px] text-ink-soft">Silver + Bronze sold</p>
            <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{tierCounts.silver + tierCounts.bronze}</p>
          </Card>
        </div>
      )}

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 5 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={4} />
          ))}
        </div>
      ) : !sales || sales.length === 0 ? (
        <EmptyState icon={<Megaphone size={22} strokeWidth={1.75} />} title="No promotion sales yet" description="Boost package purchases will show up here." />
      ) : (
        <div className="flex flex-col gap-3">
          {sales.map((sale) => {
            const isActive = new Date(sale.expiresAt).getTime() > now;
            return (
              <Card key={sale.id} className="flex flex-col gap-3 p-4 sm:flex-row sm:items-center sm:justify-between">
                <div className="min-w-0">
                  <div className="flex items-center gap-2.5">
                    <p className="truncate text-[14px] font-semibold text-ink">{sale.courseTitle}</p>
                    <StatusPill label={sale.tier} tone={TIER_TONE[sale.tier]} />
                    {!isActive && <span className="text-[11px] font-medium text-ink-soft">Expired</span>}
                  </div>
                  <p className="mt-1 text-[12.5px] text-ink-soft">
                    {sale.instructorName} - purchased {formatDate(sale.purchasedAt)} - {isActive ? "expires" : "expired"} {formatDate(sale.expiresAt)}
                  </p>
                </div>
                <span className="shrink-0 font-mono text-[15px] font-semibold text-ink">
                  {formatCurrency(sale.amount, sale.currency)}
                </span>
              </Card>
            );
          })}
        </div>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\admin\app\(console)\marketing\promotions\page.tsx" -Content $promotionsPage

Write-Host ""
Write-Host "Step 15 done." -ForegroundColor Green
Write-Host "Run: pnpm install" -ForegroundColor Yellow
Write-Host "Then: pnpm dev:admin" -ForegroundColor Green
Write-Host ""
Write-Host "What this step built:" -ForegroundColor Cyan
Write-Host "  - Admin marketing dummy data (5 banners, 5 coupons, 6 promotion sales)"
Write-Host "  - useAdminMarketing hooks: banners (create/edit/delete/reorder up-down), coupons (create/toggle active/delete),"
Write-Host "    promotion sales (read-only tracking)"
Write-Host "  - /marketing/banners - banner list with image preview, up/down reorder, edit/create modal (schedule dates + status)"
Write-Host "  - /marketing/coupons - searchable coupon list with usage bar, activate/deactivate, create modal, delete confirm"
Write-Host "  - /marketing/promotions - KPI cards (revenue, active count, gold sold, silver+bronze sold) + sales list"
Write-Host ""
Write-Host "Next: Step 16 - Content Moderation (Flagged Reviews, Flagged Forum Posts) + Support Ticket Queue" -ForegroundColor Cyan