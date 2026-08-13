"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { Bold, Italic, List, Heading2, Link as LinkIcon } from "lucide-react";
import { Button, Input, EmptyState } from "@saachi/ui";

export default function TextLessonEditorPage() {
  const router = useRouter();
  const params = useParams<{ id: string; lessonId: string }>();

  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [saved, setSaved] = useState(false);

  // NOTE: demo-only plain textarea editor. Doc 2 Section 2/12 specifies Tiptap
  // as the rich text editor â€” swap this out once @tiptap/react wiring is confirmed
  // to work cleanly in this build (it's already a dependency in package.json).

  function insertMarker(marker: string) {
    setContent((prev) => `${prev}${marker}`);
  }

  function handleSave() {
    // NOTE: demo-only, no backend lesson-save mutation wired up yet.
    setSaved(true);
  }

  if (saved) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Lesson saved"
          description="Your text lesson has been saved to the curriculum."
          action={
            <Button onClick={() => router.push(`/instructor/courses/${params.id}/curriculum`)}>
              Back to curriculum
            </Button>
          }
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Text Lesson Editor</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Lesson ID: {params.lessonId}</p>

      <div className="flex flex-col gap-4">
        <Input label="Lesson title" required value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. Understanding prompt structure" />

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Content</p>
          <div className="mb-2 flex gap-1 rounded-control border border-line bg-paper-dim p-1">
            <button type="button" onClick={() => insertMarker("**bold**")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="Bold">
              <Bold size={14} />
            </button>
            <button type="button" onClick={() => insertMarker("*italic*")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="Italic">
              <Italic size={14} />
            </button>
            <button type="button" onClick={() => insertMarker("\n## Heading\n")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="Heading">
              <Heading2 size={14} />
            </button>
            <button type="button" onClick={() => insertMarker("\n- list item\n")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="List">
              <List size={14} />
            </button>
            <button type="button" onClick={() => insertMarker("[link text](https://)")} className="rounded p-1.5 text-ink-soft hover:bg-card" aria-label="Link">
              <LinkIcon size={14} />
            </button>
          </div>
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            rows={14}
            placeholder="Write your lesson content in Markdown..."
            className="w-full rounded-control border border-line bg-card p-4 font-mono text-[13px] text-ink outline-none focus:border-gold-dark/50"
          />
        </div>

        <Button size="lg" className="self-start" disabled={!title.trim()} onClick={handleSave}>
          Save lesson
        </Button>
      </div>
    </div>
  );
}