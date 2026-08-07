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
import { Button, Card, Input, Textarea, Select, Modal, StatusPill, ShimmerKpiCard, EmptyState , HelpTooltip } from "@saachi/ui";
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
            <div className="flex items-center gap-1.5"><h1 className="text-[22px] font-semibold text-ink">Homepage Banners</h1><HelpTooltip text="Promotional banners shown on the homepage. Use the arrows to reorder, and schedule start/end dates to control when each one is active." /></div>
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