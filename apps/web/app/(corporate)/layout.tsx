import type { ReactNode } from "react";
import { CorporateShell } from "./_components/CorporateShell";

export default function CorporateLayout({ children }: { children: ReactNode }) {
  return <CorporateShell>{children}</CorporateShell>;
}