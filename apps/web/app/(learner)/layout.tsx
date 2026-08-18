"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import {
  LayoutDashboard,
  BookOpen,
  Award,
  Heart,
  ShoppingCart,
  Receipt,
  Bell,
  Settings
} from "lucide-react";
import { cn } from "@saachi/ui";
import { UserDropdown } from "@/components/ui/user-dropdown";

const NAV_ITEMS = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/my-courses", label: "My Courses", icon: BookOpen },
  { href: "/certificates", label: "Certificates", icon: Award },
  { href: "/wishlist", label: "Wishlist", icon: Heart },
  { href: "/cart", label: "Cart", icon: ShoppingCart },
  { href: "/orders", label: "Orders", icon: Receipt },
  { href: "/notifications", label: "Notifications", icon: Bell },
  { href: "/settings", label: "Settings", icon: Settings }
];

export default function LearnerLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="mx-auto max-w-7xl px-4 py-6 md:px-8">
      <header className="mb-6 flex items-center justify-between">
        <span className="font-display text-[15px] font-semibold text-ink">Saachi AI</span>
        <UserDropdown />
      </header>

      <div className="grid grid-cols-1 gap-8 md:grid-cols-[220px_1fr]">
      <aside className="h-fit rounded-card border border-line bg-card p-3 md:sticky md:top-24">
        <nav className="flex flex-row gap-1 overflow-x-auto md:flex-col md:overflow-visible">
          {NAV_ITEMS.map((item) => {
            const active = pathname === item.href;
            const ONBOARD_MAP: Record<string, string> = {
              "/dashboard": "nav-dashboard",
              "/my-courses": "nav-my-courses",
              "/certificates": "nav-certificates",
              "/wishlist": "nav-wishlist",
              "/cart": "nav-cart",
              "/orders": "nav-orders",
              "/notifications": "nav-notifications",
              "/settings": "nav-settings"
            };
            const onboardAttr = ONBOARD_MAP[item.href] ? { "data-onboard": ONBOARD_MAP[item.href] } : {};
            const Icon = item.icon;
            return (
              <Link
                key={item.href}
                href={item.href}
                {...onboardAttr}
                className={cn(
                  "flex shrink-0 items-center gap-2.5 rounded-control px-3 py-2.5 text-[14px] font-medium transition-colors",
                  active ? "bg-gold text-ink" : "text-ink-soft hover:bg-paper-dim"
                )}
              >
                <Icon size={16} strokeWidth={1.75} />
                {item.label}
              </Link>
            );
          })}
        </nav>
      </aside>

      <div>{children}</div>
      </div>
    </div>
  );
}

