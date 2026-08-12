"use client";

import Link from "next/link";
import { Search, ShoppingCart, Bell } from "lucide-react";
import { Button } from "antd";

interface CartHeaderProps {
  cartCount: number;
}

export function CartHeader({ cartCount }: CartHeaderProps) {
  return (
    <header className="sticky top-0 z-50 w-full bg-[var(--token-color-bg)] shadow-[var(--token-shadow-sm)]">
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        <div className="flex items-center gap-6">
          <Link
            href="/"
            className="text-2xl font-black text-[var(--token-color-primary)]"
          >
            Saachi AI
          </Link>

          <nav className="flex items-center gap-4">
            <Link
              href="/courses"
              className="text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
            >
              Marketplace
            </Link>
            <Link
              href="/categories"
              className="text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
            >
              Categories
            </Link>
          </nav>
        </div>

        <div className="flex items-center gap-6">
          <button
            type="button"
            aria-label="Search"
            className="text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
          >
            <Search size={18} />
          </button>

          <div className="flex items-center gap-4">
            <Link
              href="/cart"
              className="relative flex items-center text-[var(--token-color-primary)]"
              aria-label="Shopping cart"
            >
              <ShoppingCart size={20} />
              {cartCount > 0 && (
                <span
                  className="absolute -right-2 -top-1 flex h-4 w-4 items-center justify-center rounded-full text-[10px] font-bold text-white"
                  style={{ backgroundColor: "var(--token-color-error)" }}
                >
                  {cartCount}
                </span>
              )}
            </Link>

            <button
              type="button"
              aria-label="Notifications"
              className="text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-primary)]"
            >
              <Bell size={18} />
            </button>

            <Link href="/login">
              <Button type="primary">Sign In</Button>
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}
