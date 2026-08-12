import Link from "next/link";

const links = [
  { label: "Privacy Policy", href: "/legal/privacy" },
  { label: "Terms of Service", href: "/legal/terms" },
  { label: "Help Center", href: "/support" },
];

export function CheckoutFooter() {
  return (
    <footer className="w-full bg-zinc-200 px-6 py-10">
      <div className="mx-auto flex max-w-[1280px] flex-col justify-between gap-6 sm:flex-row sm:items-start">
        <div className="flex flex-col gap-2">
          <span className="text-base font-bold text-[var(--token-color-primary)]">
            Saachi AI
          </span>
          <p className="text-base text-gray-700">
            &copy; {new Date().getFullYear()} Saachi AI Marketplace.
            <br />
            Empowering the future of skills.
          </p>
        </div>

        <nav className="flex items-center gap-4 sm:pt-1">
          {links.map((link) => (
            <Link
              key={link.label}
              href={link.href}
              className="text-xs font-medium text-gray-700 hover:text-[var(--token-color-primary)]"
            >
              {link.label}
            </Link>
          ))}
        </nav>
      </div>
    </footer>
  );
}
