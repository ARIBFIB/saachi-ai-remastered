"use client";

import { useState } from "react";

export function Newsletter() {
  const [email, setEmail] = useState("");

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // TODO: wire to Newsletter API (packages/api-client)
    console.log("subscribe:", email);
  }

  return (
    <div className="mx-auto w-full max-w-[1280px] px-6 pb-16">
      <div
        className="flex flex-col items-center justify-between gap-6 border-2 p-10 md:flex-row"
        style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-inkDeep)" }}
      >
        <div className="flex max-w-96 flex-col gap-2">
          <h2
            className="text-2xl font-semibold"
            style={{ fontFamily: "var(--token-font-displayFamily)", color: "var(--token-color-paper)" }}
          >
            Get one practical AI tip a week.
          </h2>
          <p className="text-sm" style={{ color: "var(--token-color-blueprintLine)" }}>
            New courses, real build breakdowns, no hype.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="flex w-full max-w-96 gap-2">
          <input
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            className="h-11 flex-1 border-2 px-4 text-sm focus:outline-none"
            style={{ borderColor: "var(--token-color-blueprintLine)", backgroundColor: "var(--token-color-paper)", color: "var(--token-color-inkDeep)" }}
          />
          <button
            type="submit"
            className="h-11 shrink-0 px-6 text-sm font-semibold tracking-wide"
            style={{ backgroundColor: "var(--token-color-amber)", color: "var(--token-color-inkDeep)" }}
          >
            Subscribe
          </button>
        </form>
      </div>
    </div>
  );
}