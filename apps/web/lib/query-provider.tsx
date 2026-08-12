"use client";

import { useState } from "react";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

/**
 * Wraps the app with a TanStack Query QueryClient.
 *
 * IMPORTANT: the QueryClient is created inside useState so that each
 * request/browser session gets its own instance (avoids sharing cached
 * data across different users on the server, and avoids the
 * "No QueryClient set" error during Next.js static prerendering).
 *
 * See: https://tanstack.com/query/latest/docs/framework/react/guides/ssr#using-the-app-router
 */
export function QueryProvider({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: {
            staleTime: 60 * 1000,
            refetchOnWindowFocus: false
          }
        }
      })
  );

  return <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;
}