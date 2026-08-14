"use client";

import Link from "next/link";
import { useState } from "react";
import { ShoppingCart, Heart, Menu, X, LogOut } from "lucide-react";
import { Button, ThemeToggle } from "@saachi/ui";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { useSession, useLogout } from "@saachi/api-client";

const NAV_LINKS = [
  { href: "/courses", label: "Courses" },
  { href: "/categories/ai-automation", label: "Automation" },
  { href: "/categories/ai-marketing", label: "Marketing" },
  { href: "/about", label: "About" }
];

export function SiteHeader() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const cartCount = useCartStore((s) => s.items.length);
  const wishlistCount = useWishlistStore((s) => s.items.length);
  const { data: session } = useSession();
  const logout = useLogout();

  return (
    <header className="sticky top-0 z-40 border-b border-line bg-card/90 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 md:px-8">
        <Link href="/" className="font-display text-[20px] font-bold text-ink">
          Saachi<span className="text-gold-dark">AI</span>
        </Link>

        <nav className="hidden items-center gap-6 md:flex">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="text-[14px] font-medium text-ink-soft transition-colors hover:text-ink"
            >
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="flex items-center gap-2">
          <ThemeToggle />

          <Link
            href="/wishlist"
            aria-label="Wishlist"
            className="relative flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
          >
            <Heart size={18} />
            {wishlistCount > 0 && (
              <span className="absolute -right-0.5 -top-0.5 flex h-4 w-4 items-center justify-center rounded-full bg-gold text-[10px] font-bold text-ink">
                {wishlistCount}
              </span>
            )}
          </Link>

          <Link
            href="/cart"
            aria-label="Cart"
            className="relative flex h-9 w-9 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
          >
            <ShoppingCart size={18} />
            {cartCount > 0 && (
              <span className="absolute -right-0.5 -top-0.5 flex h-4 w-4 items-center justify-center rounded-full bg-gold text-[10px] font-bold text-ink">
                {cartCount}
              </span>
            )}
          </Link>

          {session ? (
            <div className="hidden items-center gap-2 md:flex">
              <span className="text-[13px] text-ink-soft">{session.fullName}</span>
              <Button
                size="sm"
                variant="ghost"
                onClick={() => logout.mutate()}
                aria-label="Log out"
              >
                <LogOut size={14} />
              </Button>
            </div>
          ) : (
            <div className="hidden items-center gap-2 md:flex">
              <Link href="/login">
                <Button size="sm" variant="secondary">
                  Log in
                </Button>
              </Link>
              <Link href="/register">
                <Button size="sm" variant="brand">Sign up</Button>
              </Link>
            </div>
          )}

          <button
            type="button"
            className="flex h-9 w-9 items-center justify-center rounded-control text-ink-soft md:hidden"
            onClick={() => setMobileOpen((v) => !v)}
            aria-label="Toggle menu"
          >
            {mobileOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>
      </div>

      {mobileOpen && (
        <div className="border-t border-line bg-card px-4 py-4 md:hidden">
          <nav className="flex flex-col gap-3">
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
            <div className="mt-2 flex gap-2">
              {session ? (
                <Button size="sm" variant="secondary" onClick={() => logout.mutate()} className="w-full">
                  Log out
                </Button>
              ) : (
                <>
                  <Link href="/login" className="flex-1">
                    <Button size="sm" variant="secondary" className="w-full">
                      Log in
                    </Button>
                  </Link>
                  <Link href="/register" className="flex-1">
                    <Button size="sm" variant="brand" className="w-full">
                      Sign up
                    </Button>
                  </Link>
                </>
              )}
            </div>
          </nav>
        </div>
      )}
    </header>
  );
}