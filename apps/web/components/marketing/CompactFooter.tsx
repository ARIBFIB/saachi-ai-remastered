import Link from "next/link";

const links = [
  { label: "About Us", href: "/about" },
  { label: "Careers", href: "/careers" },
  { label: "Privacy Policy", href: "/legal/privacy" },
  { label: "Terms of Service", href: "/legal/terms" },
  { label: "Teach a Skill", href: "/become-instructor" },
];

export function CompactFooter() {
  return (
    <footer className="w-full border-t" style={{ borderColor: "var(--token-color-blueprintLineSoft)", backgroundColor: "var(--token-color-paper)" }}>
      <div className="mx-auto flex max-w-[1280px] flex-col gap-6 px-6 py-10">
        <div
          className="flex flex-wrap items-center justify-between gap-4 border-b pb-6"
          style={{ borderColor: "var(--token-color-blueprintLineSoft)" }}
        >
          <span
            className="text-base font-semibold"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
          >
            Saachi AI
          </span>
          <nav className="flex flex-wrap gap-5">
            {links.map((link) => (
              <Link
                key={link.label}
                href={link.href}
                className="text-xs font-medium hover:opacity-70"
                style={{ color: "var(--token-color-inkDeepSoft)" }}
              >
                {link.label}
              </Link>
            ))}
          </nav>
        </div>

        <p
          className="text-center text-xs"
          style={{ fontFamily: "var(--token-font-monoFamily)", color: "var(--token-color-inkDeepSoft)" }}
        >
          &copy; {new Date().getFullYear()} Saachi AI Marketplace
        </p>
      </div>
    </footer>
  );
}