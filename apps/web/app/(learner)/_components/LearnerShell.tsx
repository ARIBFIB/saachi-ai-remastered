"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState, type ReactNode } from "react";
import {
  LayoutDashboard,
  BookOpen,
  Heart,
  ShoppingCart,
  Award,
  Bell,
  Settings,
  LogOut,
  Menu,
  X,
  Receipt,
  Users2
} from "lucide-react";
import { useSession, useLogout } from "@saachi/api-client";
import { useCartStore, useNotificationStore } from "@saachi/store";
import { useRealtimeNotifications } from "../../../hooks/useRealtimeNotifications";
import { cn } from "@saachi/ui";

const NAV_ITEMS = [
  { label: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { label: "My Courses", href: "/my-courses", icon: BookOpen },
  { label: "Wishlist", href: "/wishlist", icon: Heart },
  { label: "Cart", href: "/cart", icon: ShoppingCart },
  { label: "Certificates", href: "/certificates", icon: Award },
  { label: "Orders", href: "/orders", icon: Receipt },
  { label: "Mentorship", href: "/mentorship", icon: Users2 },
  { label: "Notifications", href: "/notifications", icon: Bell },
  { label: "Settings", href: "/settings/profile", icon: Settings }
];

export function LearnerShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const cartCount = useCartStore((s) => s.items.length);
  const unreadCount = useNotificationStore((s) => s.items.filter((n) => !n.read).length);
  const [mobileOpen, setMobileOpen] = useState(false);

  useRealtimeNotifications(true);

  const handleLogout = async () => {
    await logout.mutateAsync();
    router.push("/");
  };

  const sidebarContent = (
    <div className="flex h-full flex-col">
      <Link href="/" className="flex items-center gap-2.5 px-6 py-6">
        <span className="flex h-9 w-9 items-center justify-center rounded-full border-2 border-ink bg-gold font-display text-[15px] font-bold text-ink">
          S
        </span>
        <span className="font-display text-[17px] font-semibold text-ink">Saachi AI</span>
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
                active ? "bg-gold-tint text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
              )}
            >
              <item.icon size={18} />
              {item.label}
              {item.href === "/cart" && cartCount > 0 && (
                <span className="ml-auto flex h-5 min-w-[20px] items-center justify-center rounded-full bg-gold px-1.5 text-[11px] font-bold text-ink">
                  {cartCount}
                </span>
              )}
              {item.href === "/notifications" && unreadCount > 0 && (
                <span className="ml-auto flex h-5 min-w-[20px] items-center justify-center rounded-full bg-error px-1.5 text-[11px] font-bold text-white">
                  {unreadCount}
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-line px-3 py-4">
        <div className="mb-3 flex items-center gap-3 px-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[13px] font-semibold text-teal">
            {session?.avatarUrl ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img src={session.avatarUrl} alt={session.fullName} className="h-full w-full object-cover" />
            ) : (
              session?.fullName?.charAt(0) ?? "?"
            )}
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
        <Link href="/" className="flex items-center gap-2">
          <span className="flex h-8 w-8 items-center justify-center rounded-full border-2 border-ink bg-gold font-display text-[13px] font-bold text-ink">
            S
          </span>
          <span className="font-display text-[15px] font-semibold text-ink">Saachi AI</span>
        </Link>
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