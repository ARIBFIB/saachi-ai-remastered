import { Info } from "lucide-react";

interface LegalSectionProps {
  heading: string;
  paragraphs?: string[];
  eyebrow?: string;
  listItems?: string[];
  callout?: { title: string; body: string };
}

export function LegalSection({ heading, paragraphs, eyebrow, listItems, callout }: LegalSectionProps) {
  return (
    <section className="flex flex-col gap-3.5">
      <h2 className="text-2xl font-semibold text-[var(--token-color-ink)]">{heading}</h2>

      {eyebrow && (
        <p className="text-xs font-semibold uppercase tracking-tight text-[var(--token-color-inkSoft)]">
          {eyebrow}
        </p>
      )}

      {paragraphs?.map((p) => (
        <p key={p.slice(0, 40)} className="text-lg leading-7 text-gray-700">
          {p}
        </p>
      ))}

      {listItems && (
        <ul className="flex list-disc flex-col gap-2 pl-6 text-base leading-6 text-gray-700">
          {listItems.map((item) => (
            <li key={item.slice(0, 40)}>{item}</li>
          ))}
        </ul>
      )}

      {callout && (
        <div className="flex flex-col gap-1 rounded-[var(--token-radius-md)] border-2 border-[var(--token-color-border)]/20 bg-[var(--token-color-surfaceAlt)] px-4 py-4">
          <h4 className="flex items-center gap-1.5 text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
            <Info className="h-3 w-3 text-[var(--token-color-amber)]" />
            {callout.title}
          </h4>
          <p className="text-base text-[var(--token-color-inkSoft)]">{callout.body}</p>
        </div>
      )}
    </section>
  );
}