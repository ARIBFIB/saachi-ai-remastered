"use client";

import { useState } from "react";
import { Mail, Send } from "lucide-react";

const subjects = ["Technical Support", "Billing Question", "Instructor Application", "Partnership", "Other"];

export function ContactForm() {
  const [subject, setSubject] = useState(subjects[0]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    // TODO: wire to support ticket API (packages/api-client)
    console.log("submit inquiry", { subject });
  }

  return (
    <div className="flex flex-1 flex-col rounded-[var(--token-radius-lg)] border-2 border-[var(--token-color-inkDeep)] bg-[var(--token-color-surface)] p-10 shadow-[var(--token-shadow-sm)]">
      <div className="flex flex-col gap-1 pb-6">
        <h2 className="flex items-center gap-2 text-2xl font-semibold text-[var(--token-color-ink)]">
          <Mail className="h-5 w-4 text-[var(--token-color-amber)]" />
          Send us a Message
        </h2>
        <p className="text-base text-[var(--token-color-inkSoft)]">
          We aim to respond to all inquiries within 24 hours.
        </p>
      </div>

      <form onSubmit={handleSubmit} className="flex flex-col gap-3.5">
        <div className="grid grid-cols-1 gap-3.5 sm:grid-cols-2">
          <div className="flex flex-col gap-1">
            <label htmlFor="name" className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
              Full Name
            </label>
            <input
              id="name"
              type="text"
              required
              placeholder="Jane Doe"
              className="border-2 border-[var(--token-color-border)] bg-[var(--token-color-surface)] px-4 py-2.5 text-base text-[var(--token-color-ink)] placeholder:text-[var(--token-color-inkSoft)]/50 focus:outline-none"
            />
          </div>

          <div className="flex flex-col gap-1">
            <label htmlFor="email" className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
              Email Address
            </label>
            <input
              id="email"
              type="email"
              required
              placeholder="jane@example.com"
              className="border-2 border-[var(--token-color-border)] bg-[var(--token-color-surface)] px-4 py-2.5 text-base text-[var(--token-color-ink)] placeholder:text-[var(--token-color-inkSoft)]/50 focus:outline-none"
            />
          </div>
        </div>

        <div className="flex flex-col gap-1">
          <label htmlFor="subject" className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
            Subject
          </label>
          <select
            id="subject"
            value={subject}
            onChange={(e) => setSubject(e.target.value)}
            className="border-2 border-[var(--token-color-border)] bg-[var(--token-color-surface)] px-4 py-2 text-base text-[var(--token-color-ink)] focus:outline-none"
          >
            {subjects.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        </div>

        <div className="flex flex-col gap-1 pb-2.5">
          <label htmlFor="message" className="text-sm font-semibold tracking-wide text-[var(--token-color-ink)]">
            Message
          </label>
          <textarea
            id="message"
            required
            rows={6}
            placeholder="How can we help you today?"
            className="resize-none border-2 border-[var(--token-color-border)] bg-[var(--token-color-surface)] px-4 py-2 text-base text-[var(--token-color-ink)] placeholder:text-[var(--token-color-inkSoft)]/50 focus:outline-none"
          />
        </div>

        <div className="flex justify-end pt-2">
          <button
            type="submit"
            className="flex w-48 items-center justify-center gap-2 rounded-[var(--token-radius-md)] bg-[var(--token-color-amber)] py-3 text-sm font-semibold tracking-wide text-white hover:bg-[var(--token-color-amberDark)]"
          >
            Submit Inquiry
            <Send className="h-3.5 w-4" />
          </button>
        </div>
      </form>
    </div>
  );
}