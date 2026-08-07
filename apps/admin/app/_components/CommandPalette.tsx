"use client";

import { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { Search, CornerDownLeft } from "lucide-react";
import { ADMIN_NAV } from "../../lib/nav-config";

type FlatItem = {
  label: string;
  href: string;
  section: string;
  icon: (typeof ADMIN_NAV)[number]["items"][number]["icon"];
};

export function CommandPalette() {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [activeIndex, setActiveIndex] = useState(0);

  const flatItems: FlatItem[] = useMemo(
    () =>
      ADMIN_NAV.flatMap((section) =>
        section.items.map((item) => ({
          label: item.label,
          href: item.href,
          section: section.title,
          icon: item.icon
        }))
      ),
    []
  );

  const filtered = useMemo(() => {
    if (!query.trim()) return flatItems;
    const q = query.trim().toLowerCase();
    return flatItems.filter(
      (item) => item.label.toLowerCase().includes(q) || item.section.toLowerCase().includes(q)
    );
  }, [flatItems, query]);

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      const isCmdK = (e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k";
      if (isCmdK) {
        e.preventDefault();
        setOpen((v) => !v);
      }
      if (e.key === "Escape") {
        setOpen(false);
      }
    };
    window.addEventListener("keydown", handler);
    return () => window.removeEventListener("keydown", handler);
  }, []);

  useEffect(() => {
    if (open) {
      setQuery("");
      setActiveIndex(0);
    }
  }, [open]);

  useEffect(() => {
    setActiveIndex(0);
  }, [query]);

  const navigate = (href: string) => {
    router.push(href);
    setOpen(false);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setActiveIndex((i) => Math.min(i + 1, filtered.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setActiveIndex((i) => Math.max(i - 1, 0));
    } else if (e.key === "Enter") {
      e.preventDefault();
      const target = filtered[activeIndex];
      if (target) navigate(target.href);
    }
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[100] flex items-start justify-center bg-ink/40 px-4 pt-[12vh]">
      <div className="absolute inset-0" onClick={() => setOpen(false)} />
      <div className="relative w-full max-w-[560px] overflow-hidden rounded-card border border-line bg-card shadow-xl">
        <div className="flex items-center gap-2.5 border-b border-line px-4 py-3">
          <Search size={16} strokeWidth={1.75} className="shrink-0 text-ink-soft" />
          <input
            autoFocus
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Jump to a page... (Users, Payouts, Settings)"
            className="h-6 w-full bg-transparent text-[14px] text-ink outline-none placeholder:text-ink-soft/60"
          />
          <kbd className="hidden shrink-0 rounded border border-line-strong px-1.5 py-0.5 text-[10px] font-medium text-ink-soft sm:block">
            Esc
          </kbd>
        </div>

        <div className="max-h-[360px] overflow-y-auto p-2">
          {filtered.length === 0 ? (
            <p className="px-3 py-6 text-center text-[13px] text-ink-soft">No matching pages.</p>
          ) : (
            filtered.map((item, index) => (
              <button
                key={item.href}
                type="button"
                onClick={() => navigate(item.href)}
                onMouseEnter={() => setActiveIndex(index)}
                className={`flex w-full items-center gap-3 rounded-control px-3 py-2.5 text-left text-[13px] transition-colors duration-100 ease-out ${
                  index === activeIndex ? "bg-accent text-paper" : "text-ink hover:bg-paper-dim"
                }`}
              >
                <item.icon size={15} strokeWidth={1.75} className="shrink-0" />
                <span className="flex-1 truncate">{item.label}</span>
                <span
                  className={`shrink-0 text-[11px] ${index === activeIndex ? "text-paper/70" : "text-ink-soft/60"}`}
                >
                  {item.section}
                </span>
                {index === activeIndex && <CornerDownLeft size={12} strokeWidth={1.75} className="shrink-0" />}
              </button>
            ))
          )}
        </div>
      </div>
    </div>
  );
}