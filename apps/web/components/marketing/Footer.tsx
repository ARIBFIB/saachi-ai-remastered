import Link from "next/link";

const columns = [
  {
    title: "Platform",
    links: [
      { label: "Marketplace", href: "/courses" },
      { label: "Enterprise", href: "/pricing" },
      { label: "Teach a Skill", href: "/become-instructor" },
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
    <footer className="w-full border-t" style={{ borderColor: "var(--token-color-blueprintLineSoft)", backgroundColor: "var(--token-color-paper)" }}>
      <div className="mx-auto grid max-w-[1280px] grid-cols-1 gap-8 px-6 py-12 md:grid-cols-4">
        <div className="flex flex-col gap-4">
          <div className="flex items-center gap-2">
            <span
              className="flex h-6 w-6 items-center justify-center text-xs font-bold"
              style={{ backgroundColor: "var(--token-color-amber)", color: "var(--token-color-inkDeep)", fontFamily: "var(--token-font-monoFamily)" }}
            >
              S
            </span>
            <span
              className="text-base font-semibold"
              style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
            >
              Saachi AI
            </span>
          </div>
          <p className="text-sm" style={{ color: "var(--token-color-inkDeepSoft)" }}>
            A skills exchange for the AI era. Learn to build, not just watch.
          </p>
        </div>

        {columns.map((col) => (
          <div key={col.title} className="flex flex-col gap-4">
            <h4
              className="text-xs font-semibold uppercase tracking-[0.12em]"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              {col.title}
            </h4>
            <nav className="flex flex-col gap-2">
              {col.links.map((link) => (
                <Link
                  key={link.label}
                  href={link.href}
                  className="text-sm hover:opacity-70"
                  style={{ color: "var(--token-color-inkDeep)" }}
                >
                  {link.label}
                </Link>
              ))}
            </nav>
          </div>
        ))}
      </div>

      <div
        className="mx-auto flex max-w-[1280px] items-center justify-between border-t px-6 py-5"
        style={{ borderColor: "var(--token-color-blueprintLineSoft)", fontFamily: "var(--token-font-monoFamily)" }}
      >
        <p className="text-xs" style={{ color: "var(--token-color-inkDeepSoft)" }}>
          &copy; {new Date().getFullYear()} Saachi AI Marketplace
        </p>
      </div>
    </footer>
  );
}