import type { LucideIcon } from "lucide-react";
import {
  LayoutDashboard,
  Users,
  ClipboardCheck,
  LibraryBig,
  Tags,
  Receipt,
  Banknote,
  Undo2,
  Percent,
  Image,
  Ticket,
  Megaphone,
  MessageSquareWarning,
  MessagesSquare,
  LifeBuoy,
  BarChart3,
  Layers,
  SlidersHorizontal,
  Landmark,
  CreditCard,
  ScrollText,
  ShieldCheck,
  History
} from "lucide-react";

export type AdminNavItem = {
  label: string;
  href: string;
  icon: LucideIcon;
};

export type AdminNavSection = {
  title: string;
  items: AdminNavItem[];
};

export const ADMIN_NAV: AdminNavSection[] = [
  {
    title: "Overview",
    items: [{ label: "Dashboard", href: "/dashboard", icon: LayoutDashboard }]
  },
  {
    title: "Users",
    items: [{ label: "User Management", href: "/users", icon: Users }]
  },
  {
    title: "Courses",
    items: [
      { label: "Moderation Queue", href: "/courses/moderation", icon: ClipboardCheck },
      { label: "Course Catalog", href: "/courses/catalog", icon: LibraryBig },
      { label: "Categories & Tags", href: "/courses/categories", icon: Tags }
    ]
  },
  {
    title: "Finance",
    items: [
      { label: "Transactions", href: "/finance/transactions", icon: Receipt },
      { label: "Payouts", href: "/finance/payouts", icon: Banknote },
      { label: "Refunds", href: "/finance/refunds", icon: Undo2 },
      { label: "Tax / VAT Settings", href: "/finance/tax-settings", icon: Percent }
    ]
  },
  {
    title: "Marketing",
    items: [
      { label: "Homepage Banners", href: "/marketing/banners", icon: Image },
      { label: "Coupons", href: "/marketing/coupons", icon: Ticket },
      { label: "Promotion Sales", href: "/marketing/promotions", icon: Megaphone }
    ]
  },
  {
    title: "Moderation",
    items: [
      { label: "Flagged Reviews", href: "/moderation/reviews", icon: MessageSquareWarning },
      { label: "Flagged Forum Posts", href: "/moderation/forum", icon: MessagesSquare }
    ]
  },
  {
    title: "Support",
    items: [{ label: "Ticket Queue", href: "/support/tickets", icon: LifeBuoy }]
  },
  {
    title: "Analytics",
    items: [
      { label: "Overview", href: "/analytics/overview", icon: BarChart3 },
      { label: "Cohort Analysis", href: "/analytics/cohorts", icon: Layers }
    ]
  },
  {
    title: "Settings",
    items: [
      { label: "Platform Settings", href: "/settings/platform", icon: SlidersHorizontal },
      { label: "Commission Tiers", href: "/settings/commission-tiers", icon: Landmark },
      { label: "Payment Gateways", href: "/settings/payment-gateways", icon: CreditCard },
      { label: "Legal Documents", href: "/settings/legal-documents", icon: ScrollText },
      { label: "Roles & Permissions", href: "/settings/roles", icon: ShieldCheck }
    ]
  },
  {
    title: "System",
    items: [{ label: "Audit Log", href: "/logs/audit", icon: History }]
  }
];