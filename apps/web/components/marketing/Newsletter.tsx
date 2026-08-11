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
    <div className="mx-auto flex w-full max-w-[896px] flex-col items-center justify-between gap-6 rounded-xl bg-[var(--token-color-primary)] p-10 shadow-[var(--token-shadow-lg)] md:flex-row">
      <div className="flex max-w-96 flex-col gap-2">
        <h2 className="text-2xl font-semibold text-white">
          Stay ahead of the curve.
        </h2>
        <p className="text-base text-violet-300">
          Join our newsletter for weekly AI insights, course updates, and
          exclusive discounts.
        </p>
      </div>

      <form
        onSubmit={handleSubmit}
        className="flex h-12 w-full max-w-96 items-center overflow-hidden rounded-sm bg-white shadow-[var(--token-shadow-sm)]"
      >
        <input
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Enter your email"
          className="h-full flex-1 px-4 py-2.5 text-base text-[var(--token-color-ink)] placeholder:text-gray-500 focus:outline-none"
        />
        <button
          type="submit"
          className="m-1 rounded-sm bg-slate-600 px-6 py-2 text-sm font-semibold tracking-wide text-white hover:bg-slate-700"
        >
          Subscribe
        </button>
      </form>
    </div>
  );
}
