// ============================================================================
// dashboard-nav-config.ts
// SINGLE SOURCE OF TRUTH for the learner dashboard sidebar nav.
// Every dashboard page/layout should import `dashboardNavItems` from here
// instead of redefining its own local `navItems` array. This file was
// generated because multiple dashboard pages had drifted out of sync
// (e.g. the Mentorship page was missing its own nav entry).
//
// To add a new dashboard route: add ONE entry here. Do not copy this
// array into individual page files.
// ============================================================================
import type { LucideIcon } from "lucide-react";
import {
  LayoutGrid,
  GraduationCap,
  Award,
  Users,
  Heart,
  Bell,
  Settings,
} from "lucide-react";

export interface DashboardNavItem {
  icon: LucideIcon;
  label: string;
  href: string;
}

export const dashboardNavItems: DashboardNavItem[] = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Award, label: "Certificates", href: "/dashboard/certificates" },
  { icon: Users, label: "Mentorship", href: "/dashboard/mentorship" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Bell, label: "Notifications", href: "/dashboard/notifications" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];
