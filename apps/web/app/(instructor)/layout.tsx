import type { ReactNode } from "react";
import { InstructorShell } from "./_components/InstructorShell";

export default function InstructorLayout({ children }: { children: ReactNode }) {
  return <InstructorShell>{children}</InstructorShell>;
}
