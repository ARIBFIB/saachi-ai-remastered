import Link from "next/link";
import { Search, ShoppingCart, Bell } from "lucide-react";

export function Header() {
  return (
    <header
      className="sticky top-0 z-50 w-full border-b"
      style={{
        backgroundColor: "var(--token-color-paper)",
        borderColor: "var(--token-color-blueprintLineSoft)",
      }}
    >
      <div className="mx-auto flex h-16 max-w-[1280px] items-center justify-between px-6">
        <div className="flex items-center gap-10">
          <Link href="/" className="flex items-center gap-2">
            <span
              className="flex h-6 w-6 items-center justify-center text-xs font-bold"
              style={{
                backgroundColor: "var(--token-color-amber)",
                color: "var(--token-color-inkDeep)",
                fontFamily: "var(--token-font-monoFamily)",
              }}
            >
              S
            </span>
            <span
              className="text-xl font-semibold tracking-tight"
              style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-inkDeep)" }}
            >
              Saachi AI
            </span>
          </Link>

          <div
            className="flex items-center gap-2 rounded-sm border-2 px-3 py-1.5"
            style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-surface)" }}
          >
            <Search size={14} color="var(--token-color-inkDeepSoft)" />
            <input
              type="text"
              placeholder="Search skills, e.g. 'WhatsApp AI bot'"
              className="w-64 bg-transparent text-sm placeholder:text-[var(--token-color-inkDeepSoft)] focus:outline-none"
              style={{ fontFamily: "var(--token-font-bodyFamily)", color: "var(--token-color-inkDeep)" }}
            />
          </div>
        </div>

        <div className="flex items-center gap-6">
          <nav className="flex items-center gap-5">
            <Link
              href="/courses"
              className="border-b-2 pb-[3px] text-sm font-semibold tracking-wide"
              style={{ borderColor: "var(--token-color-amber)", color: "var(--token-color-inkDeep)" }}
            >
              Marketplace
            </Link>
            <Link
              href="/categories"
              className="text-sm font-semibold tracking-wide hover:opacity-70"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              Categories
            </Link>
            <Link
              href="/become-instructor"
              className="text-sm font-semibold tracking-wide hover:opacity-70"
              style={{ color: "var(--token-color-inkDeepSoft)" }}
            >
              Teach
            </Link>
          </nav>

          <div className="flex items-center gap-3">
            <button aria-label="Cart" className="p-2" style={{ color: "var(--token-color-inkDeepSoft)" }}>
              <ShoppingCart size={18} />
            </button>
            <button aria-label="Notifications" className="p-2" style={{ color: "var(--token-color-inkDeepSoft)" }}>
              <Bell size={18} />
            </button>

            <Link
              href="/login"
              className="ml-1 px-5 py-2 text-sm font-semibold tracking-wide"
              style={{ backgroundColor: "var(--token-color-inkDeep)", color: "var(--token-color-paper)" }}
            >
              Sign In
            </Link>
          </div>
        </div>
      </div>
    </header>
  );
}