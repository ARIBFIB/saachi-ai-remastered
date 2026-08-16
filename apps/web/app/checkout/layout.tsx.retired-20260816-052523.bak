import Link from "next/link";
import type { ReactNode } from "react";
import { ArrowLeft, ShieldCheck } from "lucide-react";

/**
 * Standalone checkout layout - intentionally minimal.
 * No SiteHeader, no SiteFooter, no learner sidebar, no search bar.
 * Just a slim top bar: logo, back link, and a secure-checkout badge.
 */
export default function CheckoutLayout({ children }: { children: ReactNode }) {
  return (
    <div className="min-h-screen bg-paper">
      <header className="sticky top-0 z-40 border-b border-line bg-card/95 backdrop-blur-sm">
        <div className="mx-auto flex h-16 max-w-6xl items-center justify-between px-4 md:px-8">
          <Link href="/" className="font-display text-[18px] font-bold text-ink">
            Saachi<span className="text-gold-dark">AI</span>
          </Link>

          <div className="hidden items-center gap-1.5 text-[12.5px] font-semibold text-ink-soft sm:flex">
            <ShieldCheck size={14} className="text-teal" />
            Secure checkout
          </div>

          <Link
            href="/cart"
            className="flex items-center gap-1.5 text-[13px] font-medium text-ink-soft transition-colors hover:text-ink"
          >
            <ArrowLeft size={15} />
            Back to cart
          </Link>
        </div>
      </header>

      <main>{children}</main>
    </div>
  );
}
