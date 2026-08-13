import Image from "next/image";

export interface InstructorResultCardProps {
  name: string;
  title: string;
  avatar: string;
  tags: string[];
  bio: string;
  profileUrl?: string;
}

export function InstructorResultCard({
  name,
  title,
  avatar,
  tags,
  bio,
  profileUrl = "#",
}: InstructorResultCardProps) {
  return (
    <div className="flex flex-col items-center justify-between rounded-[var(--token-radius-lg)] border-2 border-[var(--token-color-border)] bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]">
      <span className="relative mb-4 block h-24 w-24 overflow-hidden rounded-full border-4 border-[var(--token-color-surfaceAlt)]">
        <Image src={avatar} alt={name} fill sizes="96px" className="object-cover" />
      </span>

      <h3 className="text-2xl font-semibold text-[var(--token-color-ink)]">{name}</h3>
      <p className="pb-4 text-center text-xs font-medium text-[var(--token-color-amber)]">{title}</p>

      <div className="flex flex-wrap justify-center gap-2 pb-4">
        {tags.map((tag) => (
          <span key={tag} className="bg-[var(--token-color-surfaceAlt)] px-2 pb-1 pt-[3px] text-xs font-medium text-[var(--token-color-inkSoft)]">
            {tag}
          </span>
        ))}
      </div>

      <p className="pb-4 text-center text-sm leading-5 text-[var(--token-color-inkSoft)]">{bio}</p>

      <a
        href={profileUrl}
        className="w-full border-2 border-[var(--token-color-amber)] py-2 text-center text-sm font-semibold tracking-wide text-[var(--token-color-amber)] hover:bg-[var(--token-color-amberTint)]"
      >
        View Profile
      </a>
    </div>
  );
}