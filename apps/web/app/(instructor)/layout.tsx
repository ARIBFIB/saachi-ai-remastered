"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import {
  LayoutDashboard,
  BookOpen,
  PlusCircle,
  BarChart3,
  Wallet,
  Banknote,
  Megaphone,
  GraduationCap,
  Star,
  Users,
  Settings,
  ShieldCheck
} from "lucide-react";
import { cn } from "@saachi/ui";

const NAV_ITEMS = [
  { href: "/instructor/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/instructor/courses", label: "My Courses", icon: BookOpen },
  { href: "/instructor/courses/new", label: "New Course", icon: PlusCircle },
  { href: "/instructor/analytics", label: "Analytics", icon: BarChart3 },
  { href: "/instructor/earnings", label: "Earnings", icon: Wallet },
  { href: "/instructor/payouts", label: "Payouts", icon: Banknote },
  { href: "/instructor/promotions", label: "Promotions", icon: Megaphone },
  { href: "/instructor/mentorship", label: "Mentorship", icon: GraduationCap },
  { href: "/instructor/reviews", label: "Reviews", icon: Star },
  { href: "/instructor/students", label: "Students", icon: Users },
  { href: "/instructor/settings", label: "Settings", icon: Settings },
  { href: "/instructor/verification", label: "Verification", icon: ShieldCheck }
];

export default function InstructorLayout({ children }: { children: ReactNode }) {
  const pathname = usePathname();

  return (
    <div className="mx-auto flex max-w-7xl gap-8 px-4 py-8 md:px-8">
      <aside className="hidden w-56 shrink-0 md:block">
        <div className="sticky top-24">
          <p className="mb-4 px-2 text-[11px] font-semibold uppercase tracking-[0.06em] text-ink-soft/60">
            Instructor
          </p>
          <nav className="flex flex-col gap-1">
            {NAV_ITEMS.map((item) => {
              const active = pathname === item.href || pathname?.startsWith(item.href + "/");
              const Icon = item.icon;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={cn(
                    "flex items-center gap-2.5 rounded-control px-3 py-2 text-[13px] font-medium transition-colors",
                    active ? "bg-gold-tint text-gold-dark" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
                  )}
                >
                  <Icon size={15} />
                  {item.label}
                </Link>
              );
            })}
          </nav>
        </div>
      </aside>

      <div className="min-w-0 flex-1">{children}</div>
    </div>
  );
}