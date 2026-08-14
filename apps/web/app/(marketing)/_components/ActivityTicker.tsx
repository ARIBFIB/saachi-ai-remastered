"use client";

import { useEffect, useState } from "react";
import { Sparkle } from "lucide-react";
import { ACTIVITY_FEED } from "./landing-fake-data";

export function ActivityTicker() {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const id = setInterval(() => {
      setIndex((i) => (i + 1) % ACTIVITY_FEED.length);
    }, 3200);
    return () => clearInterval(id);
  }, []);

  const item = ACTIVITY_FEED[index];

  return (
    <div className="mx-auto flex w-fit max-w-full items-center gap-2 rounded-full border border-line bg-card px-4 py-2 shadow-sm">
      <span className="flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-teal-light text-teal">
        <Sparkle size={11} />
      </span>
      <span key={item.id} className="truncate text-[12.5px] text-ink-soft duration-300 animate-in fade-in slide-in-from-bottom-1">
        {item.text}
      </span>
    </div>
  );
}