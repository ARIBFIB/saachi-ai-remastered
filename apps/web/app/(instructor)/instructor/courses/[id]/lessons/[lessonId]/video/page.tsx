"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { UploadCloud, FileText, Trash2 } from "lucide-react";
import { Button, Input, EmptyState } from "@saachi/ui";

type ResourceFile = { id: string; name: string };

export default function VideoLessonEditorPage() {
  const router = useRouter();
  const params = useParams<{ id: string; lessonId: string }>();

  const [title, setTitle] = useState("");
  const [videoFileName, setVideoFileName] = useState<string | null>(null);
  const [captionsFileName, setCaptionsFileName] = useState<string | null>(null);
  const [resources, setResources] = useState<ResourceFile[]>([]);
  const [uploadProgress, setUploadProgress] = useState<number | null>(null);
  const [saved, setSaved] = useState(false);

  function handleVideoSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setVideoFileName(file.name);
    // NOTE: demo-only progress simulation. Real implementation needs the
    // resumable/chunked signed-URL upload flow described in Doc 2 Section 8.1/16.
    setUploadProgress(0);
    const interval = setInterval(() => {
      setUploadProgress((p) => {
        if (p === null) return null;
        if (p >= 100) {
          clearInterval(interval);
          return 100;
        }
        return p + 20;
      });
    }, 250);
  }

  function handleCaptionsSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) setCaptionsFileName(file.name);
  }

  function handleResourceSelect(e: React.ChangeEvent<HTMLInputElement>) {
    const files = e.target.files;
    if (!files) return;
    const added: ResourceFile[] = Array.from(files).map((f, i) => ({
      id: `${Date.now()}-${i}`,
      name: f.name
    }));
    setResources((prev) => [...prev, ...added]);
  }

  function removeResource(id: string) {
    setResources((prev) => prev.filter((r) => r.id !== id));
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
          description="Your video lesson has been saved to the curriculum."
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
      <h1 className="mb-1 font-display text-[24px] font-bold text-ink">Video Lesson Editor</h1>
      <p className="mb-8 text-[14px] text-ink-soft">Lesson ID: {params.lessonId}</p>

      <div className="flex flex-col gap-6">
        <Input label="Lesson title" required value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. Setting up your first workflow" />

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Video file</p>
          <label className="flex cursor-pointer flex-col items-center gap-2 rounded-card border-2 border-dashed border-line px-6 py-8 text-center hover:border-gold-dark/40">
            <UploadCloud size={22} className="text-ink-soft" />
            <span className="text-[13px] text-ink-soft">
              {videoFileName ?? "Click to select a video file (mp4, mov)"}
            </span>
            <input type="file" accept="video/*" className="hidden" onChange={handleVideoSelect} />
          </label>
          {uploadProgress !== null && (
            <div className="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-paper-dim">
              <div
                className="h-full rounded-full bg-gold transition-all"
                style={{ width: `${uploadProgress}%` }}
              />
            </div>
          )}
        </div>

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Captions (optional)</p>
          <label className="flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
            <FileText size={16} />
            {captionsFileName ?? "Upload .vtt or .srt file"}
            <input type="file" accept=".vtt,.srt" className="hidden" onChange={handleCaptionsSelect} />
          </label>
        </div>

        <div>
          <p className="mb-2 text-[13px] font-medium text-ink">Resource attachments</p>
          <label className="mb-3 flex cursor-pointer items-center gap-2 rounded-control border border-line px-4 py-3 text-[13px] text-ink-soft hover:border-gold-dark/40">
            <UploadCloud size={16} />
            Attach PDF, ZIP, or code files
            <input type="file" multiple className="hidden" onChange={handleResourceSelect} />
          </label>
          {resources.length > 0 && (
            <ul className="flex flex-col gap-1.5">
              {resources.map((r) => (
                <li key={r.id} className="flex items-center justify-between rounded-control bg-paper-dim px-3 py-2 text-[13px] text-ink">
                  {r.name}
                  <button type="button" onClick={() => removeResource(r.id)} aria-label="Remove file" className="text-ink-soft hover:text-error">
                    <Trash2 size={14} />
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        <Button size="lg" className="self-start" disabled={!title.trim()} onClick={handleSave}>
          Save lesson
        </Button>
      </div>
    </div>
  );
}