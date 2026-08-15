"use client";

/**
 * SearchCommand
 * cmdk-based command palette that powers the TopSearchBar dropdown.
 * Keyboard-navigable, grouped by content type, zero custom CSS hacks.
 */
import { useEffect, useRef, type ReactNode } from "react";
import { Command } from "cmdk";
import Link from "next/link";
import {
  GraduationCap,
  Newspaper,
  BookOpen,
  Users,
  Award,
  ArrowUpRight,
  Search
} from "lucide-react";
import { cn } from "@/lib/utils";

export type SearchGroup = {
  key: string;
  label: string;
  icon: ReactNode;
  items: { id: string; title: string; href: string; sub?: string }[];
};

type SearchCommandProps = {
  query: string;
  groups: SearchGroup[];
  onClose: () => void;
  className?: string;
};

export function SearchCommand({ query, groups, onClose, className }: SearchCommandProps) {
  const ref = useRef<HTMLDivElement>(null);

  // close on outside click
  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) onClose();
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, [onClose]);

  const totalItems = groups.reduce((s, g) => s + g.items.length, 0);
  const isEmpty = totalItems === 0;

  return (
    <div
      ref={ref}
      className={cn(
        "absolute left-0 right-0 top-[calc(100%+8px)] z-50 overflow-hidden rounded-xl border border-line bg-card shadow-2xl",
        className
      )}
    >
      <Command className="w-full" shouldFilter={false}>
        <Command.List className="max-h-[420px] overflow-y-auto p-1.5">
          {isEmpty ? (
            <Command.Empty className="py-10 text-center text-[13px] text-ink-soft">
              {query.trim()
                ? `No results for "${query}"`
                : "Start typing to search across courses, news, blog, and more."}
            </Command.Empty>
          ) : (
            groups.map((group) => {
              if (group.items.length === 0) return null;
              return (
                <Command.Group
                  key={group.key}
                  heading={
                    <div className="mb-1 flex items-center gap-1.5 px-2 pt-2 pb-0.5 text-[10.5px] font-semibold uppercase tracking-[0.08em] text-ink-soft/60">
                      {group.icon}
                      {group.label}
                    </div>
                  }
                >
                  {group.items.map((item) => (
                    <Command.Item
                      key={item.id}
                      value={item.id}
                      asChild
                      className="cursor-pointer rounded-lg px-3 py-2.5 text-[13px] transition-colors aria-selected:bg-gold-tint aria-selected:text-ink"
                      onSelect={() => onClose()}
                    >
                      <Link
                        href={item.href}
                        onClick={onClose}
                        className="flex items-center justify-between gap-3 outline-none"
                      >
                        <div className="min-w-0">
                          <p className="truncate font-medium text-ink">{item.title}</p>
                          {item.sub && (
                            <p className="mt-0.5 truncate text-[11.5px] text-ink-soft">{item.sub}</p>
                          )}
                        </div>
                        <ArrowUpRight size={13} className="shrink-0 text-ink-soft/60" />
                      </Link>
                    </Command.Item>
                  ))}
                </Command.Group>
              );
            })
          )}

          {/* footer: see all */}
          {query.trim() && (
            <div className="border-t border-line mt-1 pt-1">
              <Command.Item
                value="__see_all__"
                asChild
                className="cursor-pointer rounded-lg aria-selected:bg-gold-tint"
                onSelect={onClose}
              >
                <Link
                  href={`/search?q=${encodeURIComponent(query)}`}
                  onClick={onClose}
                  className="flex items-center justify-center gap-2 py-2.5 text-[12.5px] font-semibold text-accent-violet outline-none hover:underline"
                >
                  <Search size={13} />
                  See all results for &quot;{query}&quot;
                </Link>
              </Command.Item>
            </div>
          )}
        </Command.List>
      </Command>
    </div>
  );
}