"use client";

import { Bell } from "lucide-react";
import { useNotificationStore } from "@saachi/store";
import { Button, EmptyState, cn } from "@saachi/ui";

export default function NotificationsPage() {
  const items = useNotificationStore((s) => s.items);
  const markRead = useNotificationStore((s) => s.markRead);
  const markAllRead = useNotificationStore((s) => s.markAllRead);

  return (
    <div>
      <div className="mb-6 flex items-center justify-between">
        <h1 className="font-display text-[26px] font-bold text-ink">Notifications</h1>
        <Button size="sm" variant="secondary" onClick={markAllRead}>
          Mark all as read
        </Button>
      </div>

      {items.length === 0 ? (
        <EmptyState title="No notifications" description="You're all caught up." />
      ) : (
        <div className="flex flex-col gap-2">
          {items.map((n) => (
            <button
              key={n.id}
              type="button"
              onClick={() => markRead(n.id)}
              className={cn(
                "flex items-start gap-3 rounded-card border border-line p-4 text-left transition-colors",
                n.read ? "bg-card" : "bg-gold-tint/40"
              )}
            >
              <div className="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-paper-dim text-ink-soft">
                <Bell size={14} />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[14px] font-semibold text-ink">{n.title}</p>
                <p className="text-[13px] text-ink-soft">{n.body}</p>
                <p className="mt-1 text-[12px] text-ink-soft/60">
                  {new Intl.DateTimeFormat("en-US", { dateStyle: "medium", timeStyle: "short" }).format(
                    new Date(n.createdAt)
                  )}
                </p>
              </div>
              {!n.read && <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-gold-dark" />}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}