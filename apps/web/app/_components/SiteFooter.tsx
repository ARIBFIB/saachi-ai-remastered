import Link from "next/link";

const FOOTER_COLUMNS = [
  {
    title: "Platform",
    links: [
      { href: "/courses", label: "Browse courses" },
      { href: "/pricing", label: "Pricing" },
      { href: "/register", label: "Become an instructor" }
    ]
  },
  {
    title: "Company",
    links: [
      { href: "/about", label: "About us" },
      { href: "/contact", label: "Contact" }
    ]
  },
  {
    title: "Legal",
    links: [
      { href: "/legal/terms", label: "Terms & Conditions" },
      { href: "/legal/privacy", label: "Privacy Policy" },
      { href: "/legal/refund-policy", label: "Refund Policy" }
    ]
  }
];

export function SiteFooter() {
  return (
    <footer className="mt-24 border-t border-line bg-card">
      <div className="mx-auto grid max-w-7xl gap-10 px-4 py-14 md:grid-cols-4 md:px-8">
        <div>
          <span className="font-display text-[20px] font-bold text-ink">
            Saachi<span className="text-gold-dark">AI</span>
          </span>
          <p className="mt-3 max-w-[240px] text-[13px] leading-relaxed text-ink-soft">
            A skills exchange for the AI era. Learn practical AI skills, and sell what you know.
          </p>
        </div>

        {FOOTER_COLUMNS.map((col) => (
          <div key={col.title}>
            <h4 className="mb-3 text-[13px] font-semibold uppercase tracking-[0.06em] text-ink-soft/70">
              {col.title}
            </h4>
            <ul className="flex flex-col gap-2">
              {col.links.map((link) => (
                <li key={link.href}>
                  <Link href={link.href} className="text-[13px] text-ink-soft hover:text-ink">
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>

      <div className="border-t border-line px-4 py-5 text-center text-[12px] text-ink-soft/60 md:px-8">
        (c) {new Date().getFullYear()} Saachi AI. All rights reserved.
      </div>
    </footer>
  );
}