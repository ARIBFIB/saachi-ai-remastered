"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState, type ReactNode } from "react";
import { LayoutDashboard, Users, BookOpen, BarChart3, CreditCard, LogOut, Menu, X } from "lucide-react";
import { useSession, useLogout } from "@saachi/api-client";
import { useCorporateStore } from "@saachi/store";
import { cn } from "@saachi/ui";

const NAV_ITEMS = [
  { label: "Dashboard", href: "/corporate/dashboard", icon: LayoutDashboard },
  { label: "Team Roster", href: "/corporate/team", icon: Users },
  { label: "Course Assignment", href: "/corporate/assignments", icon: BookOpen },
  { label: "Reports", href: "/corporate/reports", icon: BarChart3 },
  { label: "Billing", href: "/corporate/billing", icon: CreditCard }
];

export function CorporateShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const { account } = useCorporateStore();
  const [mobileOpen, setMobileOpen] = useState(false);

  const handleLogout = async () => {
    await logout.mutateAsync();
    router.push("/");
  };

  const sidebarContent = (
    <div className="flex h-full flex-col">
      <Link href="/" className="flex items-center gap-2.5 px-6 py-6">
        <span className="flex h-9 w-9 items-center justify-center rounded-full border-2 border-ink bg-ink font-display text-[15px] font-bold text-white">
          S
        </span>
        <div>
          <div className="font-display text-[15px] font-semibold leading-none text-ink">{account.companyName}</div>
          <div className="mt-1 text-[11px] font-medium uppercase tracking-[0.06em] text-ink-soft">
            Corporate Account
          </div>
        </div>
      </Link>

      <nav className="flex flex-1 flex-col gap-1 px-3">
        {NAV_ITEMS.map((item) => {
          const active = pathname === item.href || Boolean(pathname && pathname.startsWith(`${item.href}/`));
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setMobileOpen(false)}
              className={cn(
                "flex items-center gap-3 rounded-control px-3.5 py-2.5 text-[14px] font-medium transition-colors duration-150 ease-out",
                active ? "bg-paper-dim text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
              )}
            >
              <item.icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-line px-3 py-4">
        <div className="mb-3 px-3 text-[12px] text-ink-soft">
          {account.seatsUsed} / {account.seatsPurchased} seats used
        </div>
        <div className="mb-3 flex items-center gap-3 px-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[13px] font-semibold text-teal">
            {session?.fullName?.charAt(0) ?? "?"}
          </div>
          <div className="min-w-0">
            <div className="truncate text-[13px] font-semibold text-ink">{session?.fullName ?? "Guest"}</div>
            <div className="truncate text-[12px] text-ink-soft">{session?.email ?? ""}</div>
          </div>
        </div>
        <button
          type="button"
          onClick={handleLogout}
          disabled={logout.isPending}
          className="flex w-full items-center gap-3 rounded-control px-3.5 py-2.5 text-[14px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-error"
        >
          <LogOut size={18} />
          {logout.isPending ? "Logging out..." : "Log out"}
        </button>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-paper">
      <div className="hidden w-[260px] shrink-0 border-r border-line bg-card md:fixed md:inset-y-0 md:flex">
        {sidebarContent}
      </div>

      <div className="flex items-center justify-between border-b border-line bg-card px-4 py-3 md:hidden">
        <span className="font-display text-[15px] font-semibold text-ink">{account.companyName}</span>
        <button
          type="button"
          onClick={() => setMobileOpen(true)}
          aria-label="Open menu"
          className="flex h-9 w-9 items-center justify-center rounded-control text-ink"
        >
          <Menu size={20} />
        </button>
      </div>

      {mobileOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div className="absolute inset-0 bg-ink/40" onClick={() => setMobileOpen(false)} />
          <div className="relative flex h-full w-[280px] flex-col bg-card">
            <button
              type="button"
              onClick={() => setMobileOpen(false)}
              aria-label="Close menu"
              className="absolute right-3 top-3 flex h-9 w-9 items-center justify-center rounded-control text-ink"
            >
              <X size={20} />
            </button>
            {sidebarContent}
          </div>
        </div>
      )}

      <div className="md:pl-[260px]">{children}</div>
    </div>
  );
}