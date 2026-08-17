"use client";

// Compatibility shim: the two-level sidebar now lives in
// components/ui/instructor-sidebar-v2.tsx (InstructorSidebarMobile).
// This file is kept so any existing import of InstructorTwoLevelSidebar
// keeps working without changes elsewhere.

import { InstructorSidebarMobile } from "@/components/ui/instructor-sidebar-v2";

export function InstructorTwoLevelSidebar({ onNavigate }: { onNavigate?: () => void }) {
  return <InstructorSidebarMobile onNavigate={onNavigate} />;
}

export default InstructorTwoLevelSidebar;
