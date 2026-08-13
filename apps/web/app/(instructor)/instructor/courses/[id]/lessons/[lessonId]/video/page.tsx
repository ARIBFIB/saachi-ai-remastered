"use client";

import { useState } from "react";
import { useParams } from "next/navigation";
import { UploadCloud, Captions, Paperclip } from "lucide-react";
import { Button, Input, Textarea } from "@saachi/ui";

export default function VideoLessonEditorPage() {
  const params = useParams<{ id: string; lessonId: string }>();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [videoFileName, setVideoFileName] = useState<string | null>(null);
  const [captionsFileName, setCaptionsFileName] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only, no backend lesson-save mutation or resumable/chunked
    // upload signed-URL flow wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Video lesson</h1>
      <p className="mb-8 text-[13px] text-ink-soft">
        Course {params.id} - Lesson {params.lessonId}
      </p>

      <div className="flex flex-col gap-4 rounded-card border border-line bg-card p-6">
        <Input label="Lesson title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. Your first workflow" />
        <Textarea label="Description" rows={3} value={description} onChange={(e) => setDescription(e.target.value)} />

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Video file</p>
          <label className="flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
            <UploadCloud size={16} />
            {videoFileName ?? "Upload video (resumable/chunked upload pending backend)"}
            <input
              type="file"
              accept="video/*"
              className="hidden"
              onChange={(e) => setVideoFileName(e.target.files?.[0]?.name ?? null)}
            />
          </label>
        </div>

        <div>
          <p className="mb-2 flex items-center gap-1.5 text-[13px] font-medium text-ink">
            <Captions size={14} /> Captions (optional)
          </p>
          <label className="flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
            <Paperclip size={16} />
            {captionsFileName ?? "Upload .vtt / .srt file"}
            <input
              type="file"
              accept=".vtt,.srt"
              className="hidden"
              onChange={(e) => setCaptionsFileName(e.target.files?.[0]?.name ?? null)}
            />
          </label>
        </div>
      </div>

      <Button size="lg" className="mt-6" onClick={handleSave}>
        {saved ? "Saved" : "Save lesson"}
      </Button>
    </div>
  );
}