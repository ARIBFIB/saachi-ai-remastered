"use client";

import Link from "next/link";
import { useState } from "react";

import { ShoppingCart, Heart, Menu as MenuIcon, X, LogOut } from "lucide-react";
import { Button } from "@saachi/ui";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";
import { useSession, useLogout } from "@saachi/api-client";
import { Menu, MenuItem, HoveredLink } from "@/components/ui/navbar-menu";
import { CATEGORIES } from "../../lib/categories";

const MOBILE_NAV_LINKS = [
  { href: "/courses",                   label: "All courses" },
  { href: "/categories/ai-automation",  label: "Automation" },
  { href: "/categories/ai-marketing",   label: "Marketing" },
  { href: "/pricing",                   label: "Pricing" },
  { href: "/about",                     label: "About" }
];

export function SiteHeader() {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [active, setActive]         = useState<string | null>(null);

  const cartCount     = useCartStore((s) => s.items.length);
  const wishlistCount = useWishlistStore((s) => s.items.length);
  const { data: session } = useSession();
  const logout = useLogout();

  // single scroll listener Ã¢â‚¬â€ shared by TopSearchBar visibility
  return (
    /*
     * The entire header is sticky. TopSearchBar lives INSIDE it so it
     * naturally hides behind the nav bar when collapsed Ã¢â‚¬â€ no z-index tricks.
     */
    <header className="sticky top-0 z-40 border-b border-line bg-card/90 backdrop-blur">
      {/* Ã¢â€â‚¬Ã¢â€â‚¬ top nav row Ã¢â€â‚¬Ã¢â€â‚¬ */}
      <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-4 md:px-8">
        <Link href="/" className="font-display text-[20px] font-bold text-ink">
          Saachi<span className="text-gold-dark">AI</span>
        </Link>

        <div className="ml-3 hidden items-center gap-1 rounded-full border border-line bg-paper-dim px-2.5 py-1 text-[11px] font-semibold text-ink-soft lg:flex">
          <span className="text-gold-dark">4.8</span>
          <span aria-hidden="true">&#9733;</span>
          <span>Rated by learners</span>
        </div>

        {/* desktop nav */}
        <div className="hidden md:block">
          <Menu setActive={setActive}>
            <MenuItem setActive={setActive} active={active} item="Courses">
              <div className="grid grid-cols-2 gap-x-10 gap-y-2 p-1 text-sm">
                {CATEGORIES.map((cat) => (
                  <HoveredLink key={cat.id} href={`/categories/${cat.slug}`}>
                    {cat.name}
                  </HoveredLink>
                ))}
                <HoveredLink href="/courses" className="font-semibold text-gold-dark">
                  Browse all courses &rarr;
                </HoveredLink>
              </div>
            </MenuItem>

            <MenuItem setActive={setActive} active={active} item="For Instructors">
              <div className="flex flex-col gap-3 text-sm">
                <HoveredLink href="/register">Become an instructor</HoveredLink>
                <HoveredLink href="/mentorship">Offer mentorship</HoveredLink>
                <HoveredLink href="/legal/instructor-agreement">Instructor agreement</HoveredLink>
              </div>
            </MenuItem>

            <MenuItem setActive={setActive} active={active} item="Company">
              <div className="flex flex-col gap-3 text-sm">
                <HoveredLink href="/about">About us</HoveredLink>
                <HoveredLink href="/pricing">Pricing</HoveredLink>
                <HoveredLink href="/contact">Contact</HoveredLink>
              </div>
            </MenuItem>
          </Menu>
        </div>

        {/* right icons */}
        <div className="flex items-center gap-2">
          <AnimatedThemeToggler />

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
              <Button size="sm" variant="ghost" onClick={() => logout.mutate()} aria-label="Log out">
                <LogOut size={14} />
              </Button>
            </div>
          ) : (
            <div className="hidden items-center gap-2 md:flex">
              <Link href="/login">
                <Button size="sm" variant="secondary">Log in</Button>
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
            {mobileOpen ? <X size={20} /> : <MenuIcon size={20} />}
          </button>
        </div>
      </div>

      {/* Ã¢â€â‚¬Ã¢â€â‚¬ search bar row Ã¢â‚¬â€ inside header, collapses on scroll Ã¢â€â‚¬Ã¢â€â‚¬ */}
      {/* Ã¢â€â‚¬Ã¢â€â‚¬ mobile nav Ã¢â€â‚¬Ã¢â€â‚¬ */}
      {mobileOpen && (
        <div className="border-t border-line bg-card px-4 py-4 md:hidden">
          <nav className="flex flex-col gap-3">
            {MOBILE_NAV_LINKS.map((link) => (
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
                    <Button size="sm" variant="secondary" className="w-full">Log in</Button>
                  </Link>
                  <Link href="/register" className="flex-1">
                    <Button size="sm" variant="brand" className="w-full">Sign up</Button>
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
