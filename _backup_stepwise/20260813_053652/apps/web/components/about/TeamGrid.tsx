import Image from "next/image";

export interface TeamMember {
  name: string;
  role: string;
  avatar: string;
}

interface TeamGridProps {
  heading: string;
  members: TeamMember[];
}

export function TeamGrid({ heading, members }: TeamGridProps) {
  return (
    <section className="flex w-full flex-col gap-6">
      <h2 className="text-3xl font-bold leading-10 text-[var(--token-color-ink)]">{heading}</h2>

      <div className="flex justify-center gap-6">
        {members.map((member) => (
          <div key={member.name} className="flex flex-1 flex-col items-center">
            <span className="relative mb-4 block h-48 w-48 overflow-hidden rounded-full shadow-sm ring-4 ring-[var(--token-color-surfaceAlt)]">
              <Image src={member.avatar} alt={member.name} fill sizes="192px" className="object-cover" />
            </span>
            <h3 className="text-xl font-semibold leading-7 text-[var(--token-color-ink)]">{member.name}</h3>
            <p className="pt-1 text-sm font-semibold tracking-wide text-[var(--token-color-primary)]">
              {member.role}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}