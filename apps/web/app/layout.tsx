import type { Metadata } from "next";
import type { ReactNode } from "react";
import { AntdProvider } from "@/lib/design-system";
import { QueryProvider } from "@/lib/query-provider";
import "./globals.css";

export const metadata: Metadata = {
  title: "Saachi AI — Master AI, Master the Future",
  description:
    "The world's leading AI-skills marketplace. Practical, expert-led artificial intelligence courses.",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>
        <QueryProvider>
        <AntdProvider>{children}</AntdProvider>
      </QueryProvider>
      </body>
    </html>
  );
}
