import type { LucideIcon } from "lucide-react";
import {
  LayoutDashboard,
  BookOpen,
  PlusCircle,
  Star,
  Users,
  Rocket,
  BarChart3,
  Wallet,
  CalendarClock,
  Settings,
  ShieldCheck
} from "lucide-react";

export type InstructorNavItem = {
  label: string;
  href: string;
  icon: LucideIcon;
};

export type InstructorNavSection = {
  title: string;
  items: InstructorNavItem[];
};

export const INSTRUCTOR_NAV: InstructorNavSection[] = [
  {
    title: "Overview",
    items: [{ label: "Dashboard", href: "/instructor/dashboard", icon: LayoutDashboard }]
  },
  {
    title: "Courses",
    items: [
      { label: "My Courses", href: "/instructor/courses", icon: BookOpen },
      { label: "Create Course", href: "/instructor/courses/new", icon: PlusCircle }
    ]
  },
  {
    title: "Engagement",
    items: [
      { label: "Reviews", href: "/instructor/reviews", icon: Star },
      { label: "Students", href: "/instructor/students", icon: Users }
    ]
  },
  {
    title: "Growth",
    items: [
      { label: "Promotions", href: "/instructor/promotions", icon: Rocket },
      { label: "Analytics", href: "/instructor/analytics", icon: BarChart3 }
    ]
  },
  {
    title: "Finance",
    items: [{ label: "Earnings", href: "/instructor/earnings", icon: Wallet }]
  },
  {
    title: "Mentorship",
    items: [{ label: "Mentorship Settings", href: "/instructor/mentorship", icon: CalendarClock }]
  },
  {
    title: "Account",
    items: [
      { label: "Settings", href: "/instructor/settings", icon: Settings },
      { label: "Verification", href: "/instructor/verification", icon: ShieldCheck }
    ]
  }
];
