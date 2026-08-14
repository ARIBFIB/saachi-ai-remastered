"use client";

import { useState, type FormEvent } from "react";
import { Mail, CheckCircle2 } from "lucide-react";

export function NewsletterCard() {
  const [email, setEmail] = useState("");
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend newsletter-signup endpoint wired up yet.
    setSubmitted(true);
  }

  return (
    <div
      className="relative overflow-hidden rounded-card p-8 text-center md:p-12"
      style={{ backgroundImage: "var(--color-accent-gradient)" }}
    >
      <Mail size={26} className="mx-auto mb-3 text-white/90" />
      <h2 className="font-display text-[22px] font-bold text-white md:text-[26px]">
        Get new courses in your inbox
      </h2>
      <p className="mx-auto mt-2 max-w-md text-[13.5px] text-white/85">
        One email a week. New releases, instructor spotlights, and the occasional discount code.
      </p>

      {submitted ? (
        <div className="mx-auto mt-6 flex w-fit items-center gap-2 rounded-full bg-white/15 px-4 py-2 text-[13px] font-medium text-white">
          <CheckCircle2 size={16} />
          You&apos;re on the list -- check your inbox.
        </div>
      ) : (
        <form onSubmit={handleSubmit} className="mx-auto mt-6 flex max-w-md flex-col gap-2 sm:flex-row">
          <input
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
            className="w-full rounded-full border-0 px-4 py-2.5 text-[13.5px] text-ink outline-none placeholder:text-ink-soft/60 focus:ring-2 focus:ring-white/60"
          />
          <button
            type="submit"
            className="shrink-0 rounded-full bg-white px-5 py-2.5 text-[13.5px] font-semibold text-accent-violet transition-transform hover:scale-105"
          >
            Subscribe
          </button>
        </form>
      )}
    </div>
  );
}