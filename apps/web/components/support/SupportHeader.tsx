import Link from "next/link";
import { Search, ShoppingCart, Bell } from "lucide-react";

export function SupportHeader() {
  return (
    <header className="sticky top-0 z-50 w-full bg-zinc-900 shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]">
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        <div className="flex flex-1 items-center gap-6">
          <Link href="/" className="text-2xl font-black text-violet-300">
            Saachi AI
          </Link>

          <div className="relative w-full max-w-96">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-[var(--token-color-textMuted)]" />
            <input
              type="text"
              placeholder="Search courses, skills, instructors..."
              className="w-full rounded-none border border-[var(--token-color-border)] bg-[var(--token-color-surface)] py-2.5 pl-10 pr-2 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:outline-none"
            />
          </div>
        </div>

        <nav className="flex items-center gap-6">
          <Link href="/courses" className="text-sm font-semibold tracking-wide text-slate-300 hover:text-white">
            Marketplace
          </Link>
          <Link href="/categories" className="text-sm font-semibold tracking-wide text-slate-300 hover:text-white">
            Categories
          </Link>
        </nav>

        <div className="flex items-center gap-4 pl-6">
          <button aria-label="Cart" className="rounded-full p-2 text-[#BEC6E0] hover:bg-white/10">
            <ShoppingCart className="h-5 w-5" />
          </button>
          <button aria-label="Notifications" className="rounded-full p-2 text-[#BEC6E0] hover:bg-white/10">
            <Bell className="h-5 w-5" />
          </button>
          <Link
            href="/login"
            className="rounded-lg bg-[var(--token-color-primary)] px-4 py-2 text-sm font-semibold tracking-wide text-white hover:bg-[var(--token-color-primaryHover)]"
          >
            Sign In
          </Link>
          <Link href="/settings/profile">
            <span className="block h-8 w-8 overflow-hidden rounded-full border border-[var(--token-color-border)] bg-zinc-200" />
          </Link>
        </div>
      </div>
    </header>
  );
}