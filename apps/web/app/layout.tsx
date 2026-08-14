import type { Metadata } from "next";
import type { ReactNode } from "react";
import "./globals.css";
import { Providers } from "./providers";
import { ConditionalChrome } from "./_components/ConditionalChrome";

export const metadata: Metadata = {
  title: "Saachi AI \u2014 Learn practical AI skills",
  description: "A skills exchange for the AI era. Learn practical AI application skills and sell what you know."
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-paper text-ink antialiased">
        <Providers>
          <ConditionalChrome>{children}</ConditionalChrome>
        </Providers>
      </body>
    </html>
  );
}
