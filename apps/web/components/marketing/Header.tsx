import Link from "next/link";
import { Search, ShoppingCart, Bell, Zap } from "lucide-react";

export function Header() {
  return (
    <header className="sticky top-0 z-50 w-full bg-[var(--token-color-bg)] shadow-[var(--token-shadow-sm)]">
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        {/* Left: Logo + Search */}
        <div className="flex items-center gap-10">
          <Link href="/" className="flex items-center gap-2">
            <Zap
              className="h-[18px] w-[18px] text-[var(--token-color-primary)]"
              fill="currentColor"
              strokeWidth={0}
            />
            <span className="text-2xl font-black text-[var(--token-color-primary)]">
              Saachi AI
            </span>
          </Link>

          <div className="flex items-center gap-1 rounded-sm border border-[var(--token-color-border)] bg-gray-100 px-2 py-1">
            <Search className="h-[15px] w-[15px] text-slate-500" />
            <input
              type="text"
              placeholder="Search courses, skills..."
              className="w-64 bg-transparent px-3 py-2 text-sm font-semibold tracking-wide text-slate-600 placeholder:text-slate-600 focus:outline-none"
            />
          </div>
        </div>

        {/* Right: Nav links + actions */}
        <div className="flex items-center gap-6">
          <nav className="flex items-center gap-5">
            <Link
              href="/courses"
              className="border-b-2 border-[var(--token-color-primary)] pb-[3px] text-sm font-bold tracking-wide text-[var(--token-color-primary)]"
            >
              Marketplace
            </Link>
            <Link
              href="/categories"
              className="text-sm font-semibold tracking-wide text-slate-600 hover:text-[var(--token-color-primary)]"
            >
              Categories
            </Link>
          </nav>

          <div className="flex items-center gap-2">
            <button
              aria-label="Cart"
              className="rounded-full p-2 text-slate-600 hover:bg-gray-100"
            >
              <ShoppingCart className="h-5 w-5" />
            </button>
            <button
              aria-label="Notifications"
              className="rounded-full p-2 text-slate-600 hover:bg-gray-100"
            >
              <Bell className="h-5 w-5" />
            </button>

            <Link
              href="/login"
              className="ml-2 rounded-sm bg-[var(--token-color-primary)] px-6 py-2 text-sm font-semibold tracking-wide text-white shadow-[var(--token-shadow-sm)] hover:bg-[var(--token-color-primaryHover)]"
            >
              Sign In
            </Link>

            <Link href="/settings/profile" className="ml-2">
              <span className="block h-8 w-8 overflow-hidden rounded-full border border-[var(--token-color-border)] bg-gray-200" />
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}
