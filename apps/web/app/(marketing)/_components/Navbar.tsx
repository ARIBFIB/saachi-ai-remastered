"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { Menu, X, Sparkles } from "lucide-react";
import { Button } from "@saachi/ui";

const NAV_LINKS = [
  { label: "Explore Courses", href: "/courses" },
  { label: "Become an Instructor", href: "/register" },
  { label: "Pricing", href: "/pricing" },
  { label: "About", href: "/about" }
];

export function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 40);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  return (
    <header
      className={[
        "sticky top-0 z-50 w-full transition-all duration-200 ease-out",
        scrolled ? "glass shadow-[var(--shadow-sm)] border-b border-[var(--border-hairline)]" : "bg-transparent"
      ].join(" ")}
    >
      <div className="mx-auto flex h-[72px] max-w-[1120px] items-center justify-between px-6">
        <Link href="/" className="flex items-center gap-2">
          <span
            className="flex h-8 w-8 items-center justify-center rounded-[10px] text-white"
            style={{ background: "var(--gradient-primary)" }}
          >
            <Sparkles size={17} />
          </span>
          <span className="text-[17px] font-bold tracking-[-0.01em] text-[var(--text-primary)]">
            Saachi AI
          </span>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="group relative text-[14px] font-medium text-[var(--text-secondary)] transition-colors duration-150 ease-out hover:text-[var(--blue-600)]"
            >
              {link.label}
              <span className="absolute -bottom-1 left-0 h-[2px] w-full origin-center scale-x-0 bg-[var(--gradient-primary)] transition-transform duration-150 ease-out group-hover:scale-x-100" />
            </Link>
          ))}
        </nav>

        <div className="hidden items-center gap-3 md:flex">
          <Link href="/login">
            <Button variant="ghost" size="sm">
              Log in
            </Button>
          </Link>
          <Link href="/register">
            <Button variant="primary" size="sm">
              Get Started
            </Button>
          </Link>
        </div>

        <button
          type="button"
          onClick={() => setMobileOpen((v) => !v)}
          className="flex h-10 w-10 items-center justify-center rounded-[10px] text-[var(--text-primary)] md:hidden"
          aria-label="Toggle menu"
        >
          {mobileOpen ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {mobileOpen && (
        <div className="glass border-t border-[var(--border-hairline)] px-6 py-6 md:hidden">
          <nav className="flex flex-col gap-4">
            {NAV_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={() => setMobileOpen(false)}
                className="text-[15px] font-medium text-[var(--text-primary)]"
              >
                {link.label}
              </Link>
            ))}
          </nav>
          <div className="mt-6 flex flex-col gap-3">
            <Link href="/login" onClick={() => setMobileOpen(false)}>
              <Button variant="secondary" size="md" className="w-full">
                Log in
              </Button>
            </Link>
            <Link href="/register" onClick={() => setMobileOpen(false)}>
              <Button variant="primary" size="md" className="w-full">
                Get Started
              </Button>
            </Link>
          </div>
        </div>
      )}
    </header>
  );
}
