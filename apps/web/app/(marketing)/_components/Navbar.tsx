"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { Menu, X, ShoppingCart } from "lucide-react";
import { Button } from "@saachi/ui";
import { useSession, useLogout } from "@saachi/api-client";

const NAV_LINKS = [
  { label: "Explore Courses", href: "/courses" },
  { label: "Become an Instructor", href: "/instructor/dashboard" },
  { label: "Pricing", href: "/pricing" },
  { label: "About", href: "/about" }
];

export function Navbar() {
  const router = useRouter();
  const [scrolled, setScrolled] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const { data: session } = useSession();
  const logout = useLogout();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  const handleLogout = async () => {
    await logout.mutateAsync();
    setMobileOpen(false);
    router.push("/");
  };

  return (
    <header
      className={[
        "sticky top-0 z-50 w-full border-b transition-colors duration-200 ease-out",
        scrolled ? "border-line bg-paper/95 backdrop-blur-sm" : "border-transparent bg-paper"
      ].join(" ")}
    >
      <div className="mx-auto flex h-[72px] max-w-[1140px] items-center justify-between px-6">
        <Link href="/" className="flex items-center gap-2.5">
          <span className="flex h-9 w-9 items-center justify-center rounded-full border-2 border-ink bg-gold font-display text-[15px] font-bold text-ink">
            S
          </span>
          <span className="font-display text-[18px] font-semibold tracking-[-0.01em] text-ink">
            Saachi AI
          </span>
        </Link>

        <nav className="hidden items-center gap-8 md:flex">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-[14px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:text-ink"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="hidden items-center gap-3 md:flex">
          {session ? (
            <>
              <Link
                href="/cart"
                aria-label="Cart"
                className="flex h-10 w-10 items-center justify-center rounded-full text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
              >
                <ShoppingCart size={19} />
              </Link>
              <Link
                href="/dashboard"
                className="flex items-center gap-2 rounded-full border border-line-strong bg-card py-1.5 pl-1.5 pr-4 transition-colors duration-150 ease-out hover:border-ink"
              >
                <span className="flex h-7 w-7 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[12px] font-semibold text-teal">
                  {session.avatarUrl ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={session.avatarUrl} alt={session.fullName} className="h-full w-full object-cover" />
                  ) : (
                    session.fullName.charAt(0)
                  )}
                </span>
                <span className="text-[13px] font-semibold text-ink">{session.fullName.split(" ")[0]}</span>
              </Link>
              <Button variant="ghost" size="sm" onClick={handleLogout} disabled={logout.isPending}>
                {logout.isPending ? "..." : "Log out"}
              </Button>
            </>
          ) : (
            <>
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
            </>
          )}
        </div>

        <button
          type="button"
          onClick={() => setMobileOpen((v) => !v)}
          className="flex h-10 w-10 items-center justify-center rounded-control text-ink md:hidden"
          aria-label="Toggle menu"
        >
          {mobileOpen ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {mobileOpen && (
        <div className="border-t border-line bg-paper px-6 py-6 md:hidden">
          <nav className="flex flex-col gap-4">
            {NAV_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                onClick={() => setMobileOpen(false)}
                className="text-[15px] font-medium text-ink"
              >
                {link.label}
              </Link>
            ))}
          </nav>
          <div className="mt-6 flex flex-col gap-3">
            {session ? (
              <>
                <Link href="/dashboard" onClick={() => setMobileOpen(false)}>
                  <Button variant="secondary" size="md" className="w-full">
                    Dashboard
                  </Button>
                </Link>
                <Link href="/cart" onClick={() => setMobileOpen(false)}>
                  <Button variant="secondary" size="md" className="w-full">
                    Cart
                  </Button>
                </Link>
                <Button
                  variant="ghost"
                  size="md"
                  className="w-full"
                  onClick={handleLogout}
                  disabled={logout.isPending}
                >
                  {logout.isPending ? "Logging out..." : "Log out"}
                </Button>
              </>
            ) : (
              <>
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
              </>
            )}
          </div>
        </div>
      )}
    </header>
  );
}