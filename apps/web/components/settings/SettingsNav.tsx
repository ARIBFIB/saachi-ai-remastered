"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

// TODO: as each page is built, its route below is already wired -- just add
// the matching page.tsx file under app/(learner)/dashboard/settings/<route>.
const settingsNavItems = [
  { label: "Profile Details", href: "/dashboard/settings/profile" },
  { label: "Security", href: "/dashboard/settings/security" },
  { label: "Notifications", href: "/dashboard/settings/notifications" },
  { label: "Billing & Payments", href: "/dashboard/settings/billing" },
  { label: "Privacy & Data", href: "/dashboard/settings/privacy" },
];

export function SettingsNav() {
  const pathname = usePathname();

  return (
    <nav className="flex w-56 shrink-0 flex-col gap-2">
      {settingsNavItems.map((item) => {
        const isActive = pathname === item.href;
        return (
          <Link
            key={item.href}
            href={item.href}
            className="rounded-[var(--token-radius-md)] px-4 py-5 text-sm tracking-wide transition"
            style={{
              backgroundColor: isActive ? "var(--token-color-surfaceAlt)" : "transparent",
              borderLeft: isActive ? "4px solid var(--token-color-amber)" : "4px solid transparent",
              color: isActive ? "var(--token-color-ink)" : "var(--token-color-inkSoft)",
              fontWeight: isActive ? 700 : 600,
            }}
          >
            {item.label}
          </Link>
        );
      })}
    </nav>
  );
}
