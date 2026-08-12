"use client";

import Link from "next/link";
import { Lock } from "lucide-react";

export function CheckoutHeader() {
  return (
    <header className="fixed inset-x-0 top-0 z-50 h-16 w-full bg-[var(--token-color-bg)] shadow-[var(--token-shadow-sm)]">
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        <Link
          href="/"
          className="text-2xl font-black text-[var(--token-color-primary)]"
        >
          Saachi AI
        </Link>

        <div className="flex items-center gap-2 text-[var(--token-color-inkSoft)]">
          <Lock size={14} />
          <span className="text-sm font-semibold tracking-wide">
            Secure Checkout
          </span>
        </div>
      </div>
    </header>
  );
}
