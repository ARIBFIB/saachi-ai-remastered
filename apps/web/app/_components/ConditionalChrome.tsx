"use client";

import { usePathname } from "next/navigation";
import type { ReactNode } from "react";
import { SiteHeader } from "./SiteHeader";
import { SiteFooter } from "./SiteFooter";

// Routes that render their own header/shell (e.g. InstructorShell) and
// should NOT also get the public SiteHeader/SiteFooter.
const CHROME_EXCLUDED_PREFIXES = ["/instructor"];

export function ConditionalChrome({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const hideChrome = CHROME_EXCLUDED_PREFIXES.some((prefix) => pathname?.startsWith(prefix));

  if (hideChrome) {
    return <>{children}</>;
  }

  return (
    <>
      <SiteHeader />
      <main>{children}</main>
      <SiteFooter />
    </>
  );
}


