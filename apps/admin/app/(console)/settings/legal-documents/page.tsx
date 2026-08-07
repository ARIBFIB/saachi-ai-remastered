"use client";

import { useEffect, useState } from "react";
import { toast } from "sonner";
import { ScrollText, Pencil, History } from "lucide-react";
import { Button, Card, Textarea, Modal, ShimmerTableRow , HelpTooltip } from "@saachi/ui";
import { formatDate } from "@saachi/utils";

type LegalDoc = {
  id: string;
  title: string;
  version: string;
  updatedAt: string;
  content: string;
};

const INITIAL_DOCS: LegalDoc[] = [
  { id: "terms", title: "Terms & Conditions", version: "v1.0", updatedAt: "2026-06-01T00:00:00Z", content: "Draft pending client legal counsel review." },
  { id: "privacy", title: "Privacy Policy", version: "v1.0", updatedAt: "2026-06-01T00:00:00Z", content: "Draft pending client legal counsel review." },
  { id: "refund", title: "Refund Policy", version: "v1.0", updatedAt: "2026-06-01T00:00:00Z", content: "7-day / 30% completion threshold refund window - to be finalized." },
  { id: "instructor_agreement", title: "Instructor Agreement", version: "v1.0", updatedAt: "2026-06-01T00:00:00Z", content: "Draft pending client legal counsel review." }
];

export default function LegalDocumentManagementPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [docs, setDocs] = useState(INITIAL_DOCS);
  const [editing, setEditing] = useState<LegalDoc | null>(null);
  const [draft, setDraft] = useState("");

  useEffect(() => {
    const t = setTimeout(() => setIsLoading(false), 500);
    return () => clearTimeout(t);
  }, []);

  const openEdit = (doc: LegalDoc) => {
    setEditing(doc);
    setDraft(doc.content);
  };

  const handlePublish = () => {
    if (!editing) return;
    const [major, minor] = editing.version.replace("v", "").split(".").map(Number);
    const nextVersion = `v${major}.${minor + 1}`;
    setDocs((prev) =>
      prev.map((d) =>
        d.id === editing.id ? { ...d, content: draft, version: nextVersion, updatedAt: new Date().toISOString() } : d
      )
    );
    toast.success(`Published ${editing.title} ${nextVersion}`);
    setEditing(null);
  };

  return (
    <main className="mx-auto max-w-[900px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center gap-3">
        <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
          <ScrollText size={17} strokeWidth={1.75} />
        </div>
        <div>
          <div className="flex items-center gap-1.5"><h1 className="text-[22px] font-semibold text-ink">Legal Document Management</h1><HelpTooltip text="Versioned legal documents shown to users. Publishing an edit bumps the version number and updates the live copy." /></div>
          <p className="mt-0.5 text-[13px] text-ink-soft">Versioned editor for Terms, Privacy, Refund Policy, and Instructor Agreement.</p>
        </div>
      </div>

      {isLoading ? (
        <div className="overflow-hidden rounded-card border border-line bg-card">
          {Array.from({ length: 4 }).map((_, i) => (
            <ShimmerTableRow key={i} columns={2} />
          ))}
        </div>
      ) : (
        <div className="flex flex-col gap-3">
          {docs.map((doc) => (
            <Card key={doc.id} className="flex flex-col gap-4 p-5 sm:flex-row sm:items-center sm:justify-between">
              <div>
                <div className="flex items-center gap-2.5">
                  <p className="text-[14px] font-semibold text-ink">{doc.title}</p>
                  <span className="rounded-full border border-line-strong px-2 py-0.5 font-mono text-[11px] text-ink-soft">{doc.version}</span>
                </div>
                <p className="mt-1 flex items-center gap-1.5 text-[12px] text-ink-soft">
                  <History size={12} strokeWidth={1.75} /> Last updated {formatDate(doc.updatedAt)}
                </p>
              </div>
              <Button size="sm" variant="secondary" onClick={() => openEdit(doc)}>
                <Pencil size={14} strokeWidth={1.75} /> Edit
              </Button>
            </Card>
          ))}
        </div>
      )}

      <Modal
        open={Boolean(editing)}
        onClose={() => setEditing(null)}
        title={`Edit - ${editing?.title ?? ""}`}
        size="lg"
        footer={
          <>
            <Button variant="ghost" onClick={() => setEditing(null)}>Cancel</Button>
            <Button onClick={handlePublish}>Publish new version</Button>
          </>
        }
      >
        <Textarea label="Document content" rows={12} value={draft} onChange={(e) => setDraft(e.target.value)} />
      </Modal>
    </main>
  );
}