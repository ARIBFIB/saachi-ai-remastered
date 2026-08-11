import Link from "next/link";
import { Search, ShoppingCart, Bell, Zap } from "lucide-react";

export function Header() {
  return (
    <header className="sticky top-0 z-50 w-full bg-[#F8FAFC] shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)]">
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        {/* Left: Logo + Search */}
        <div className="flex items-center gap-10">
          <Link href="/" className="flex items-center gap-2">
            <Zap
              className="h-[18px] w-[18px] text-[#3525CD]"
              fill="currentColor"
              strokeWidth={0}
            />
            <span className="text-2xl font-black text-[#3525CD]">
              Saachi AI
            </span>
          </Link>

          <div className="flex items-center gap-1 rounded-sm border border-[#CBD5E1] bg-gray-100 px-2 py-1">
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
              className="border-b-2 border-[#3525CD] pb-[3px] text-sm font-bold tracking-wide text-[#3525CD]"
            >
              Marketplace
            </Link>
            <Link
              href="/categories"
              className="text-sm font-semibold tracking-wide text-slate-600 hover:text-[#3525CD]"
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
              className="ml-2 rounded-sm bg-[#3525CD] px-6 py-2 text-sm font-semibold tracking-wide text-white shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[#2A1DA3]"
            >
              Sign In
            </Link>

            <Link href="/settings/profile" className="ml-2">
              <span className="block h-8 w-8 overflow-hidden rounded-full border border-[#CBD5E1] bg-gray-200" />
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}
