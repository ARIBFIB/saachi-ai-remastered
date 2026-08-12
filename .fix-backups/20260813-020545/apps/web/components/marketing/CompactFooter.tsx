import Link from "next/link";

const links = [
  { label: "About Us", href: "/about" },
  { label: "Careers", href: "/careers" },
  { label: "Privacy Policy", href: "/legal/privacy" },
  { label: "Terms of Service", href: "/legal/terms" },
  { label: "Instructor Handbook", href: "/instructor/handbook" },
];

export function CompactFooter() {
  return (
    <footer className="w-full bg-zinc-200">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-6 px-6 py-10">
        <div className="flex items-center justify-between border-b border-slate-300 pb-6">
          <span className="text-base font-bold text-[#3525CD]">Saachi AI</span>
          <nav className="flex gap-4">
            {links.map((link) => (
              <Link
                key={link.label}
                href={link.href}
                className="text-xs font-medium text-gray-700 hover:text-[#3525CD]"
              >
                {link.label}
              </Link>
            ))}
          </nav>
        </div>

        <p className="text-center text-base text-gray-700">
          Â© {new Date().getFullYear()} Saachi AI Marketplace. Empowering the
          future of skills.
        </p>
      </div>
    </footer>
  );
}
