const columns = [
  { links: [{ label: "About Us", href: "/about" }, { label: "Careers", href: "/careers" }] },
  { links: [{ label: "Privacy Policy", href: "/legal/privacy" }, { label: "Terms of Service", href: "/legal/terms" }] },
  { links: [{ label: "Instructor Handbook", href: "/instructor/handbook" }] },
];

export function DetailFooter() {
  return (
    <footer className="w-full bg-zinc-200 px-6 py-10">
      <div className="mx-auto flex max-w-[1280px] flex-col gap-8 sm:flex-row sm:items-end sm:gap-6">
        <div className="flex flex-1 flex-col gap-4">
          <span className="text-base font-bold text-[#3525CD]">Saachi AI</span>
          <p className="text-base text-gray-700">
            Â© {new Date().getFullYear()} Saachi AI Marketplace.
            <br />
            Empowering the future of skills.
          </p>
        </div>

        {columns.map((col, i) => (
          <div key={i} className="flex flex-1 flex-col gap-1.5">
            {col.links.map((link) => (
              <a
                key={link.label}
                href={link.href}
                className="text-xs font-medium text-gray-700 hover:text-[#3525CD]"
              >
                {link.label}
              </a>
            ))}
          </div>
        ))}
      </div>
    </footer>
  );
}
