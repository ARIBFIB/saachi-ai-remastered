import Link from "next/link";

const links = [
  { label: "About Us", href: "/about" },
  { label: "Careers", href: "/careers" },
  { label: "Privacy Policy", href: "/legal/privacy" },
  { label: "Terms of Service", href: "/legal/terms" },
  { label: "Instructor Handbook", href: "/instructor/handbook" },
];

export function SupportFooter() {
  return (
    <footer className="w-full border-t border-[var(--token-color-border)]/20 bg-zinc-900 px-6 py-10">
      <div className="mx-auto flex max-w-[1280px] flex-col justify-between gap-6 sm:flex-row sm:items-start">
        <div className="flex flex-col gap-1">
          <span className="text-base font-bold text-[var(--token-color-primary)]">Saachi AI</span>
          <p className="text-xs font-medium text-zinc-200">
            Â© {new Date().getFullYear()} Saachi AI Marketplace. Empowering the future of skills.
          </p>
        </div>

        <nav className="flex flex-wrap gap-6">
          {links.map((link) => (
            <Link key={link.label} href={link.href} className="text-base text-zinc-200 hover:text-white">
              {link.label}
            </Link>
          ))}
        </nav>
      </div>
    </footer>
  );
}