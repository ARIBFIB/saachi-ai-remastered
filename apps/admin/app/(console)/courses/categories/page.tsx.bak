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