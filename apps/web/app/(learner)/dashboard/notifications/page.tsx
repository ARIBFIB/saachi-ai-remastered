"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Button } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  CheckCheck,
  SlidersHorizontal,
  BookOpen,
  Users,
  Info,
  AlertTriangle,
} from "lucide-react";

// TODO: replace with useNotifications() hook from @saachi/api-client
type NotificationCategory = "course" | "mentorship" | "system";

interface BaseNotification {
  id: string;
  timestamp: string;
  title: string;
  description: string;
  read: boolean;
}

interface CourseNotification extends BaseNotification {
  actionLabel?: string;
  actionHref?: string;
}

interface MentorshipNotification extends BaseNotification {
  mentorName: string;
  mentorTitle: string;
  mentorAvatar: string;
  actionLabel?: string;
}

interface SystemNotification extends BaseNotification {
  actionRequired?: boolean;
  actionLabel?: string;
}

const initialCourseNotifications: CourseNotification[] = [
  {
    id: "course-1",
    timestamp: "2 hours ago",
    title: "New Module Available",
    description:
      '"Advanced Neural Networks" module is now unlocked in your Deep Learning track.',
    read: false,
    actionLabel: "View Module",
    actionHref: "/dashboard/my-courses",
  },
  {
    id: "course-2",
    timestamp: "Yesterday",
    title: "Assignment Graded",
    description:
      'Your submission for "Data Preprocessing" has been graded. Score: 95/100.',
    read: true,
  },
];

const initialMentorshipNotifications: MentorshipNotification[] = [
  {
    id: "mentorship-1",
    timestamp: "5 hours ago",
    title: "Mentor Response",
    description:
      "Responded to your question about backpropagation optimization strategies.",
    read: false,
    mentorName: "Sarah Jenkins",
    mentorTitle: "Senior ML Engineer",
    mentorAvatar: "https://i.pravatar.cc/80?img=32",
    actionLabel: "Reply",
  },
];

const initialSystemNotifications: SystemNotification[] = [
  {
    id: "system-1",
    timestamp: "Today",
    title: "Subscription Expiring Soon",
    description:
      "Your Saachi Pro subscription will expire in 3 days. Renew now to avoid losing access to premium courses.",
    read: false,
    actionRequired: true,
    actionLabel: "Renew Subscription",
  },
  {
    id: "system-2",
    timestamp: "Oct 12",
    title: "Scheduled Maintenance",
    description:
      "The platform will undergo maintenance on Oct 15th from 02:00 AM to 04:00 AM UTC.",
    read: true,
  },
];

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

export default function NotificationsPage() {
  const [courseNotifications, setCourseNotifications] = useState(initialCourseNotifications);
  const [mentorshipNotifications, setMentorshipNotifications] = useState(
    initialMentorshipNotifications
  );
  const [systemNotifications, setSystemNotifications] = useState(initialSystemNotifications);

  const unreadCourseCount = courseNotifications.filter((n) => !n.read).length;
  const unreadMentorshipCount = mentorshipNotifications.filter((n) => !n.read).length;

  function handleMarkAllAsRead() {
    // TODO: wire to useNotifications().markAllAsRead() from @saachi/api-client
    setCourseNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
    setMentorshipNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
    setSystemNotifications((prev) => prev.map((n) => ({ ...n, read: true })));
  }

  function handleOpenPreferences() {
    // TODO: navigate to /dashboard/settings/notifications once that route exists
    console.log("open notification preferences");
  }

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col justify-between border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex flex-col">
          <div className="flex items-center gap-4 border-b border-[var(--token-color-border)] p-6">
            <span className="relative block h-12 w-12 shrink-0 overflow-hidden rounded-full">
              <Image
                src="https://i.pravatar.cc/96?img=47"
                alt="Learner avatar"
                fill
                sizes="48px"
                className="object-cover"
              />
            </span>
            <div className="flex flex-col">
              <span className="text-lg font-bold" style={{ color: "var(--token-color-ink)" }}>
                Learner Portal
              </span>
              <span
                style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}
              >
                Manage your skills
              </span>
            </div>
          </div>

          <nav className="flex flex-col gap-2 py-6">
            {navItems.map(({ icon: Icon, label, href }) => (
              <Link
                key={label}
                href={href}
                className="flex h-12 items-center gap-4 border-l-4 border-transparent pl-4 pr-6 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] transition hover:bg-[var(--token-color-surface)]"
              >
                <Icon size={18} />
                {label}
              </Link>
            ))}
          </nav>
        </div>

        <div className="border-t border-[var(--token-color-border)] p-4">
          <Link
            href="/support"
            className="flex h-12 items-center gap-4 rounded-[var(--token-radius-md)] pl-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surface)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main column */}
      <div className="flex w-full flex-col lg:pl-72">
        <main className="flex-1 px-12 py-10">
          <div className="flex flex-col gap-10">
            {/* Header */}
            <div className="flex items-end justify-between gap-6">
              <div className="flex flex-col gap-1">
                <h1 className="text-3xl font-bold leading-10" style={{ color: "var(--token-color-ink)" }}>
                  Notifications
                </h1>
                <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                  Stay updated with your courses, mentorships, and system alerts.
                </p>
              </div>

              <div className="flex items-center gap-2">
                <Button icon={<CheckCheck size={14} />} onClick={handleMarkAllAsRead}>
                  Mark all as read
                </Button>
                <Button icon={<SlidersHorizontal size={14} />} onClick={handleOpenPreferences}>
                  Preferences
                </Button>
              </div>
            </div>

            {/* Bento grid */}
            <div className="grid grid-cols-1 items-start gap-6 lg:grid-cols-3">
              {/* Column 1: Course Updates */}
              <section className="flex flex-col gap-4">
                <ColumnHeader
                  icon={<BookOpen size={20} color="var(--token-color-amber)" />}
                  label="Course Updates"
                  count={unreadCourseCount}
                  countBg="var(--token-color-amberTint)"
                  countColor="var(--token-color-amber)"
                />

                {courseNotifications.map((notification) => (
                  <NotificationCard
                    key={notification.id}
                    timestamp={notification.timestamp}
                    title={notification.title}
                    description={notification.description}
                    read={notification.read}
                    accentColor="var(--token-color-amber)"
                    action={
                      notification.actionLabel
                        ? {
                            label: notification.actionLabel,
                            variant: "link",
                            color: "var(--token-color-amber)",
                          }
                        : undefined
                    }
                  />
                ))}
              </section>

              {/* Column 2: Mentorship */}
              <section className="flex flex-col gap-4">
                <ColumnHeader
                  icon={<Users size={20} color="var(--token-color-success)" />}
                  label="Mentorship"
                  count={unreadMentorshipCount}
                  countBg="var(--token-color-successTint)"
                  countColor="var(--token-color-success)"
                />

                {mentorshipNotifications.map((notification) => (
                  <NotificationCard
                    key={notification.id}
                    timestamp={notification.timestamp}
                    title={notification.title}
                    description={notification.description}
                    read={notification.read}
                    accentColor="var(--token-color-success)"
                    avatar={{
                      name: notification.mentorName,
                      title: notification.mentorTitle,
                      image: notification.mentorAvatar,
                    }}
                    action={
                      notification.actionLabel
                        ? {
                            label: notification.actionLabel,
                            variant: "solid",
                            color: "var(--token-color-success)",
                          }
                        : undefined
                    }
                  />
                ))}

                {mentorshipNotifications.length === 0 && <EmptyColumn label="No mentorship activity yet." />}
              </section>

              {/* Column 3: System */}
              <section className="flex flex-col gap-4">
                <ColumnHeader
                  icon={<Info size={20} color="var(--token-color-inkSoft)" />}
                  label="System"
                />

                {systemNotifications.map((notification) => (
                  <NotificationCard
                    key={notification.id}
                    timestamp={notification.timestamp}
                    title={notification.title}
                    description={notification.description}
                    read={notification.read}
                    actionRequired={notification.actionRequired}
                    action={
                      notification.actionLabel
                        ? {
                            label: notification.actionLabel,
                            variant: notification.actionRequired ? "outline-danger" : "solid",
                            color: "var(--token-color-error)",
                          }
                        : undefined
                    }
                  />
                ))}
              </section>
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="bg-[var(--token-color-surfaceAlt)]/60 px-6 py-10">
          <div className="mx-auto flex max-w-[1000px] flex-col gap-6 sm:flex-row sm:items-start sm:justify-between">
            <div className="flex flex-col gap-4">
              <span className="text-base font-bold text-[var(--token-color-amber)]">
                Saachi AI
              </span>
              <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                &copy; {new Date().getFullYear()} Saachi AI Marketplace.
                <br />
                Empowering the future of skills.
              </p>
            </div>

            <nav className="flex flex-wrap gap-6">
              {[
                { label: "About Us", href: "/about" },
                { label: "Careers", href: "/careers" },
                { label: "Privacy Policy", href: "/legal/privacy" },
                { label: "Terms of Service", href: "/legal/terms" },
                { label: "Instructor Handbook", href: "/instructor/handbook" },
              ].map((link) => (
                <Link
                  key={link.label}
                  href={link.href}
                  className="text-xs font-medium text-[var(--token-color-inkSoft)] hover:text-[var(--token-color-amber)]"
                >
                  {link.label}
                </Link>
              ))}
            </nav>
          </div>
        </footer>
      </div>
    </div>
  );
}

function ColumnHeader({
  icon,
  label,
  count,
  countBg,
  countColor,
}: {
  icon: React.ReactNode;
  label: string;
  count?: number;
  countBg?: string;
  countColor?: string;
}) {
  return (
    <div className="flex items-center justify-between px-2 pb-2">
      <div className="flex items-center gap-2">
        {icon}
        <h2 className="text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
          {label}
        </h2>
      </div>

      {typeof count === "number" && count > 0 && (
        <span
          className="rounded-full px-3 py-1 text-xs font-medium"
          style={{ backgroundColor: countBg, color: countColor }}
        >
          {count} New
        </span>
      )}
    </div>
  );
}

function NotificationCard({
  timestamp,
  title,
  description,
  read,
  accentColor,
  actionRequired,
  avatar,
  action,
}: {
  timestamp: string;
  title: string;
  description: string;
  read: boolean;
  accentColor?: string;
  actionRequired?: boolean;
  avatar?: { name: string; title: string; image: string };
  action?: { label: string; variant: "link" | "solid" | "outline-danger"; color: string };
}) {
  const isUnread = !read;

  return (
    <article
      className="flex flex-col gap-2 rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]"
      style={{
        opacity: read && !actionRequired ? 0.75 : 1,
        borderLeft: isUnread && accentColor ? `4px solid ${accentColor}` : undefined,
        border: actionRequired
          ? "1px solid color-mix(in srgb, var(--token-color-error) 30%, transparent)"
          : !isUnread
            ? "1px solid var(--token-color-border)"
            : undefined,
      }}
    >
      <div className="flex items-center justify-between">
        {actionRequired ? (
          <span className="flex items-center gap-2 text-xs font-medium" style={{ color: "var(--token-color-error)" }}>
            <AlertTriangle size={14} />
            Action Required
          </span>
        ) : (
          <span className="flex items-center gap-2">
            {isUnread && accentColor && (
              <span className="block h-2 w-2 rounded-full" style={{ backgroundColor: accentColor }} />
            )}
            <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
              {timestamp}
            </span>
          </span>
        )}
      </div>

      {avatar && (
        <div className="flex items-center gap-4 pt-1">
          <span className="relative block h-10 w-10 shrink-0 overflow-hidden rounded-full">
            <Image src={avatar.image} alt={avatar.name} fill sizes="40px" className="object-cover" />
          </span>
          <div className="flex flex-col">
            <span className="text-sm font-semibold tracking-wide" style={{ color: "var(--token-color-ink)" }}>
              {avatar.name}
            </span>
            <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
              {avatar.title}
            </span>
          </div>
        </div>
      )}

      <h3 className="pt-1 text-sm font-semibold tracking-wide" style={{ color: "var(--token-color-ink)" }}>
        {title}
      </h3>

      <p className="text-sm leading-5" style={{ color: "var(--token-color-inkSoft)" }}>
        {description}
      </p>

      {action && (
        <div className="pt-2">
          {action.variant === "link" && (
            <button
              type="button"
              className="text-xs font-semibold"
              style={{ color: action.color }}
              onClick={() => console.log("notification action:", action.label)}
            >
              {action.label}
            </button>
          )}

          {action.variant === "solid" && (
            <button
              type="button"
              className="rounded-[var(--token-radius-md)] px-3 py-1.5 text-xs font-medium text-white"
              style={{ backgroundColor: action.color }}
              onClick={() => console.log("notification action:", action.label)}
            >
              {action.label}
            </button>
          )}

          {action.variant === "outline-danger" && (
            <button
              type="button"
              className="rounded-[var(--token-radius-md)] border px-3 py-1.5 text-xs font-medium"
              style={{ borderColor: action.color, color: action.color }}
              onClick={() => console.log("notification action:", action.label)}
            >
              {action.label}
            </button>
          )}
        </div>
      )}
    </article>
  );
}

function EmptyColumn({ label }: { label: string }) {
  return (
    <div
      className="flex flex-col items-center gap-1 rounded-[var(--token-radius-lg)] border border-dashed p-8 text-center"
      style={{ borderColor: "var(--token-color-border)" }}
    >
      <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-sm)" }}>{label}</p>
    </div>
  );
}
