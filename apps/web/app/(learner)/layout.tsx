import type { ReactNode } from "react";
import { LearnerShell } from "./_components/LearnerShell";

export default function LearnerLayout({ children }: { children: ReactNode }) {
  return <LearnerShell>{children}</LearnerShell>;
}