"use client";

import { useEffect } from "react";
import { Button } from "@saachi/ui";

export default function GlobalError({
  error,
  reset
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {

    console.error(error);
  }, [error]);

  return (
    <div className="mx-auto flex max-w-lg flex-col items-center px-4 py-24 text-center md:px-0">
      <span className="font-mono text-[64px] font-bold text-error">500</span>
      <h1 className="mt-2 font-display text-[24px] font-bold text-ink">Something went wrong</h1>
      <p className="mt-2 text-[14px] text-ink-soft">
        An unexpected error occurred. Please try again.
      </p>
      <div className="mt-8 flex gap-3">
        <Button onClick={() => reset()}>Try again</Button>
      </div>
    </div>
  );
}
