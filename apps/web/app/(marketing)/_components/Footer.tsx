import Link from "next/link";
import { Sparkles, Twitter, Linkedin, Youtube } from "lucide-react";

const FOOTER_COLUMNS = [
  {
    title: "Platform",
    links: [
      { label: "Explore Courses", href: "/courses" },
      { label: "Become an Instructor", href: "/register" },
      { label: "Pricing", href: "/pricing" },
      { label: "Mentorship", href: "/mentorship" }
    ]
  },
  {
    title: "Company",
    links: [
      { label: "About Us", href: "/about" },
      { label: "Careers", href: "/about" },
      { label: "Contact", href: "/contact" }
    ]
  },
  {
    title: "Legal",
    links: [
      { label: "Terms & Conditions", href: "/legal/terms" },
      { label: "Privacy Policy", href: "/legal/privacy" },
      { label: "Refund Policy", href: "/legal/refund-policy" },
      { label: "Instructor Agreement", href: "/legal/instructor-agreement" }
    ]
  }
];

export function Footer() {
  return (
    <footer style={{ background: "var(--blue-950)" }} className="text-[#94A3B8]">
      <div className="mx-auto max-w-[1120px] px-6 py-20">
        <div className="grid grid-cols-1 gap-12 md:grid-cols-[1.4fr_1fr_1fr_1fr] md:gap-8">
          <div>
            <div className="flex items-center gap-2">
              <span
                className="flex h-8 w-8 items-center justify-center rounded-[10px] text-white"
                style={{ background: "var(--gradient-primary)" }}
              >
                <Sparkles size={17} />
              </span>
              <span className="text-[17px] font-bold text-white">Saachi AI</span>
            </div>
            <p className="mt-4 max-w-[280px] text-[14px] leading-relaxed">
              A skills exchange for the AI era. Learn to build with AI, and sell what you know.
            </p>
            <div className="mt-6 flex items-center gap-3">
              {[Twitter, Linkedin, Youtube].map((Icon, i) => (
                <a
                  key={i}
                  href="#"
                  aria-label="Social link"
                  className="flex h-9 w-9 items-center justify-center rounded-full border border-[rgba(96,165,250,0.16)] text-[#94A3B8] transition-colors duration-150 ease-out hover:border-[var(--blue-400)] hover:text-[var(--cyan-400)]"
                >
                  <Icon size={16} />
                </a>
              ))}
            </div>
          </div>

          {FOOTER_COLUMNS.map((col) => (
            <div key={col.title}>
              <h4 className="text-[13px] font-semibold uppercase tracking-[0.06em] text-[#64748B]">
                {col.title}
              </h4>
              <ul className="mt-4 flex flex-col gap-3">
                {col.links.map((link) => (
                  <li key={link.label}>
                    <Link
                      href={link.href}
                      className="text-[14px] transition-colors duration-150 ease-out hover:text-[var(--cyan-400)]"
                    >
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-16 flex flex-col gap-6 border-t border-[rgba(96,165,250,0.14)] pt-8 md:flex-row md:items-center md:justify-between">
          <p className="text-[13px]">Â© {new Date().getFullYear()} Saachi AI. All rights reserved.</p>

          <form className="flex w-full max-w-[360px] items-center gap-2">
            <input
              type="email"
              placeholder="Your email"
              className="h-11 w-full rounded-full border border-[rgba(96,165,250,0.18)] bg-[rgba(255,255,255,0.04)] px-4 text-[14px] text-white placeholder:text-[#64748B] outline-none focus:border-[var(--blue-400)] focus:shadow-[0_0_16px_rgba(59,130,246,0.25)]"
            />
            <button
              type="submit"
              className="h-11 shrink-0 rounded-full px-5 text-[14px] font-medium text-white transition-transform duration-150 ease-out hover:-translate-y-0.5"
              style={{ background: "var(--gradient-primary)" }}
            >
              Subscribe
            </button>
          </form>
        </div>
      </div>
    </footer>
  );
}
