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
              className="h-[18px] w-[18px] text-[#3525CD]"
              fill="currentColor"
              strokeWidth={0}
            />
            <span className="text-base font-bold text-[#3525CD]">
              Saachi AI
            </span>
          </Link>
          <p className="text-sm text-[#3F3F46]">
            Empowering the next generation of builders with cutting-edge
            artificial intelligence skills.
          </p>
        </div>

        {columns.map((col) => (
          <div key={col.title} className="flex flex-col gap-4">
            <h4 className="text-sm font-bold tracking-wide text-[#18181B]">
              {col.title}
            </h4>
            <nav className="flex flex-col gap-2">
              {col.links.map((link) => (
                <Link
                  key={link.label}
                  href={link.href}
                  className="text-sm text-[#3F3F46] hover:text-[#3525CD]"
                >
                  {link.label}
                </Link>
              ))}
            </nav>
          </div>
        ))}
      </div>

      <div className="mx-auto flex max-w-[1280px] items-center justify-between border-t border-[#CBD5E1] px-6 py-6">
        <p className="text-xs font-medium text-[#3F3F46]">
          © {new Date().getFullYear()} Saachi AI Marketplace. Empowering the
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
