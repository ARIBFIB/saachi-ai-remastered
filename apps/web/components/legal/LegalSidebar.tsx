"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { ScrollText, Shield, RefreshCcw, Cookie } from "lucide-react";
import type { LucideIcon } from "lucide-react";

interface LegalNavItem {
  label: string;
  href: string;
  icon: LucideIcon;
}

const navItems: LegalNavItem[] = [
  { label: "Terms of Service", href: "/legal/terms", icon: ScrollText },
  { label: "Privacy Policy", href: "/legal/privacy", icon: Shield },
  { label: "Refund Policy", href: "/legal/refund", icon: RefreshCcw },
  { label: "Cookie Policy", href: "/legal/cookies", icon: Cookie },
];

export function LegalSidebar() {
  const pathname = usePathname();

  return (
    <aside className="w-72 shrink-0 self-start rounded-[var(--token-radius-lg)] border-2 border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] px-4 pb-4 pt-3.5 shadow-[var(--token-shadow-sm)]">
      <h3 className="px-2 pb-4 text-xs font-medium uppercase tracking-wide text-[var(--token-color-inkSoft)]">
        Legal Policies
      </h3>

      <nav className="flex flex-col gap-2">
        {navItems.map(({ label, href, icon: Icon }) => {
          const isActive = pathname === href;
          return (
            <Link
              key={href}
              href={href}
              className={`flex h-12 items-center gap-3 rounded-[var(--token-radius-md)] border-l-4 pl-4 pr-2 text-sm font-semibold tracking-wide transition ${
                isActive
                  ? "border-[var(--token-color-amber)] bg-[var(--token-color-amberTint)] text-[var(--token-color-amber)]"
                  : "border-transparent text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surfaceAlt)]"
              }`}
            >
              <Icon className="h-4 w-4 shrink-0" />
              {label}
            </Link>
          );
        })}
      </nav>
    </aside>
  );
}