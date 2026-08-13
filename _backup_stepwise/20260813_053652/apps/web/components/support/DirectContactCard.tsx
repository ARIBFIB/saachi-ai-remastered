import { Headset, Phone, Building2 } from "lucide-react";

export function DirectContactCard() {
  return (
    <div className="flex flex-col gap-4 rounded-xl border-2 border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-sm)]">
      <h3 className="text-2xl font-semibold text-[var(--token-color-ink)]">Direct Contact</h3>

      <div className="flex flex-col gap-6">
        <ContactItem icon={<Headset className="h-5 w-4 text-[var(--token-color-primary)]" />} label="Support Email">
          <a href="mailto:support@saachi.ai" className="text-base text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]">
            support@saachi.ai
          </a>
        </ContactItem>

        <ContactItem icon={<Phone className="h-5 w-[18px] text-[var(--token-color-primary)]" />} label="Phone Support">
          <p className="text-base text-[var(--token-color-inkSoft)]">+1 (800) 555-0199</p>
          <p className="text-xs font-medium text-gray-500">Mon-Fri, 9am - 6pm EST</p>
        </ContactItem>

        <ContactItem icon={<Building2 className="h-5 w-5 text-[var(--token-color-primary)]" />} label="Headquarters">
          <p className="text-base leading-6 text-[var(--token-color-inkSoft)]">
            100 Innovation Way
            <br />
            Suite 400
            <br />
            San Francisco, CA 94105
          </p>
        </ContactItem>
      </div>
    </div>
  );
}

function ContactItem({
  icon,
  label,
  children,
}: {
  icon: React.ReactNode;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <div className="flex items-start gap-4">
      <span className="flex h-10 w-9 shrink-0 items-center justify-center rounded bg-[var(--token-color-primaryTint)]">
        {icon}
      </span>
      <div>
        <p className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">{label}</p>
        {children}
      </div>
    </div>
  );
}