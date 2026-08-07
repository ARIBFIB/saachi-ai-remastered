import Link from "next/link";
import { Twitter, Linkedin, Youtube } from "lucide-react";

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
    <footer className="bg-ink text-[#9AA0AE]">
      <div className="mx-auto max-w-[1140px] px-6 py-20">
        <div className="grid grid-cols-1 gap-12 md:grid-cols-[1.4fr_1fr_1fr_1fr] md:gap-8">
          <div>
            <div className="flex items-center gap-2.5">
              <span className="flex h-9 w-9 items-center justify-center rounded-full border-2 border-gold font-display text-[15px] font-bold text-gold">
                S
              </span>
              <span className="font-display text-[17px] font-semibold text-white">Saachi AI</span>
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
                  className="flex h-9 w-9 items-center justify-center rounded-full border border-white/10 text-[#9AA0AE] transition-colors duration-150 ease-out hover:border-gold hover:text-gold"
                >
                  <Icon size={16} />
                </a>
              ))}
            </div>
          </div>

          {FOOTER_COLUMNS.map((col) => (
            <div key={col.title}>
              <h4 className="text-[13px] font-semibold uppercase tracking-[0.06em] text-[#6B7280]">
                {col.title}
              </h4>
              <ul className="mt-4 flex flex-col gap-3">
                {col.links.map((link) => (
                  <li key={link.label}>
                    <Link href={link.href} className="text-[14px] transition-colors duration-150 ease-out hover:text-gold">
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-16 flex flex-col gap-6 border-t border-white/10 pt-8 md:flex-row md:items-center md:justify-between">
          <p className="text-[13px]">Â© {new Date().getFullYear()} Saachi AI. All rights reserved.</p>

          <form className="flex w-full max-w-[360px] items-center gap-2">
            <input
              type="email"
              placeholder="Your email"
              className="h-11 w-full rounded-full border border-white/10 bg-white/5 px-4 text-[14px] text-white placeholder:text-[#6B7280] outline-none focus:border-gold"
            />
            <button
              type="submit"
              className="h-11 shrink-0 rounded-full bg-gold px-5 text-[14px] font-semibold text-ink transition-colors duration-150 ease-out hover:bg-gold-dark"
            >
              Subscribe
            </button>
          </form>
        </div>
      </div>
    </footer>
  );
}