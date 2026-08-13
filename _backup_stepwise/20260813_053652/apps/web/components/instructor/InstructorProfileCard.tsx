import Image from "next/image";
import { Mail } from "lucide-react";

interface InstructorProfileCardProps {
  name: string;
  title: string;
  bio: string;
  avatar: string;
  tags: string[];
}

export function InstructorProfileCard({
  name,
  title,
  bio,
  avatar,
  tags,
}: InstructorProfileCardProps) {
  return (
    <div className="flex flex-1 items-start gap-6 rounded-xl border-2 border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]">
      <span className="relative block h-32 w-32 shrink-0 overflow-hidden rounded-full ring-4 ring-[var(--token-color-surfaceAlt)]">
        <Image src={avatar} alt={name} fill sizes="128px" className="object-cover" />
      </span>

      <div className="flex flex-1 flex-col gap-4">
        <div className="flex items-start justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold leading-10 text-[var(--token-color-ink)]">{name}</h1>
            <p className="text-lg leading-7 text-[var(--token-color-inkSoft)]">{title}</p>
          </div>

          <button
            type="button"
            className="flex shrink-0 items-center gap-2 rounded-lg bg-[var(--token-color-primary)] px-4 py-2 text-sm font-semibold tracking-wide text-white hover:bg-[var(--token-color-primaryHover)]"
          >
            <Mail className="h-3.5 w-3.5" />
            Message Instructor
          </button>
        </div>

        <div className="flex flex-wrap gap-2">
          {tags.map((tag) => (
            <span
              key={tag}
              className="rounded-sm bg-[var(--token-color-primaryTint)] px-3 pb-1 pt-[3px] text-xs font-medium text-[var(--token-color-primary)]"
            >
              {tag}
            </span>
          ))}
        </div>

        <p className="max-w-2xl text-base text-[var(--token-color-inkSoft)]">{bio}</p>
      </div>
    </div>
  );
}