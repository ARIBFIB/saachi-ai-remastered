import type { Metadata } from "next";
import type { ReactNode } from "react";
import { AntdProvider } from "@/lib/design-system";
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
        <AntdProvider>{children}</AntdProvider>
      </body>
    </html>
  );
}
