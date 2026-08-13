"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { Button, Input, Textarea } from "@saachi/ui";

export default function TextLessonEditorPage() {
  const params = useParams<{ id: string; lessonId: string }>();
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only plain textarea. Replace with the Tiptap rich text
    // editor + lesson-content save mutation once available.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Text lesson</h1>
      <p className="mb-8 text-[13px] text-ink-soft">
        Course {params.id} - Lesson {params.lessonId}
      </p>

      <div className="flex flex-col gap-4 rounded-card border border-line bg-card p-6">
        <Input label="Lesson title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. Key concepts recap" />
        <Textarea
          label="Lesson content"
          rows={14}
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Write the lesson content here. This will be replaced with the Tiptap rich text editor."
        />
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save lesson"}
      </Button>
    </div>
  );
}