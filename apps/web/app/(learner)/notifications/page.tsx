"use client";

import { Bell, BookOpen, MessageSquare, CreditCard, Info } from "lucide-react";
import { useNotificationStore } from "@saachi/store";
import { Button, Card, EmptyState, Badge } from "@saachi/ui";
import { formatRelativeTime } from "@saachi/utils";

const TYPE_ICON = {
  course: BookOpen,
  system: Info,
  community: MessageSquare,
  payment: CreditCard
} as const;

export default function NotificationsPage() {
  const { items, markAllRead, markRead } = useNotificationStore();
  const unreadCount = items.filter((n) => !n.read).length;

  return (
    <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="font-display text-[26px] font-semibold text-ink">Notifications</h1>
          <p className="mt-1 text-[14px] text-ink-soft">
            {unreadCount > 0 ? `${unreadCount} unread` : "You're all caught up"}
          </p>
        </div>
        {unreadCount > 0 && (
          <Button size="sm" variant="secondary" onClick={markAllRead}>
            Mark all as read
          </Button>
        )}
      </div>

      {items.length === 0 ? (
        <EmptyState icon={<Bell size={22} />} title="No notifications" description="Nothing here yet." />
      ) : (
        <div className="flex flex-col gap-3">
          {items.map((n) => {
            const Icon = TYPE_ICON[n.type];
            return (
              <Card
                key={n.id}
                onClick={() => markRead(n.id)}
                className={[
                  "flex cursor-pointer items-start gap-4 p-4",
                  !n.read ? "border-gold-dark/40 bg-gold-tint/40" : ""
                ].join(" ")}
              >
                <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-teal-light text-teal">
                  <Icon size={16} />
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <h3 className="text-[14px] font-semibold text-ink">{n.title}</h3>
                    {!n.read && <Badge variant="gold">New</Badge>}
                  </div>
                  <p className="mt-1 text-[13px] text-ink-soft">{n.body}</p>
                  <p className="mt-2 text-[12px] text-ink-soft/60">{formatRelativeTime(n.createdAt)}</p>
                </div>
              </Card>
            );
          })}
        </div>
      )}
    </main>
  );
}