import Link from "next/link";
import { Zap, Globe, Share2 } from "lucide-react";

const columns = [
  {
    title: "Platform",
    links: [
      { label: "Marketplace", href: "/courses" },
      { label: "Enterprise", href: "/pricing" },
      { label: "Instructor Handbook", href: "/instructor/handbook" },
    ],
  },
  {
    title: "Company",
    links: [
      { label: "About Us", href: "/about" },
      { label: "Careers", href: "/careers" },
      { label: "Contact", href: "/contact" },
    ],
  },
  {
    title: "Legal",
    links: [
      { label: "Privacy Policy", href: "/legal/privacy" },
      { label: "Terms of Service", href: "/legal/terms" },
    ],
  },
];

export function Footer() {
  return (
    <footer className="w-full bg-zinc-200">
      <div className="mx-auto grid max-w-[1280px] grid-cols-1 gap-8 px-6 py-10 md:grid-cols-4">
        <div className="flex flex-col gap-4">
          <Link href="/" className="flex items-center gap-1">
            <Zap
              className="h-[18px] w-[18px] text-[var(--token-color-primary)]"
              fill="currentColor"
              strokeWidth={0}
            />
            <span className="text-base font-bold text-[var(--token-color-primary)]">
              Saachi AI
            </span>
          </Link>
          <p className="text-sm text-[var(--token-color-inkSoft)]">
            Empowering the next generation of builders with cutting-edge
            artificial intelligence skills.
          </p>
        </div>

        {columns.map((col) => (
          <div key={col.title} className="flex flex-col gap-4">
            <h4 className="text-sm font-bold tracking-wide text-[var(--token-color-ink)]">
              {col.title}
            </h4>
            <nav className="flex flex-col gap-2">
              {col.links.map((link) => (
                <Link
                  key={link.label}
                  href={link.href}
                  className="text-sm text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
                >
                  {link.label}
                </Link>
              ))}
            </nav>
          </div>
        ))}
      </div>

      <div className="mx-auto flex max-w-[1280px] items-center justify-between border-t border-[var(--token-color-border)] px-6 py-6">
        <p className="text-xs font-medium text-[var(--token-color-inkSoft)]">
          Â© {new Date().getFullYear()} Saachi AI Marketplace. Empowering the
          future of skills.
        </p>
        <div className="flex items-center gap-4 text-slate-600">
          <Globe className="h-[18px] w-[18px]" />
          <Share2 className="h-[18px] w-[18px]" />
        </div>
      </div>
    </footer>
  );
}
