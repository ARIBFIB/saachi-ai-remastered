"use client";

import { useState, type FormEvent } from "react";
import { Button, Input, Textarea, EmptyState } from "@saachi/ui";

export default function ContactPage() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend yet. Replace with a real Support/Contact API call.
    setSubmitted(true);
  }

  return (
    <div className="mx-auto max-w-2xl px-4 py-16 md:px-0">
      <h1 className="mb-2 font-display text-[32px] font-bold text-ink">Contact us</h1>
      <p className="mb-8 text-[15px] text-ink-soft">
        Questions about courses, instructor applications, or anything else - send us a message.
      </p>

      {submitted ? (
        <EmptyState
          title="Message sent"
          description="Thanks for reaching out. We typically respond within 1-2 business days."
        />
      ) : (
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input label="Your name" required value={name} onChange={(e) => setName(e.target.value)} />
          <Input
            label="Email"
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
          <Textarea
            label="Message"
            required
            rows={6}
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            placeholder="How can we help?"
          />
          <Button type="submit" size="lg" className="self-start">
            Send message
          </Button>
        </form>
      )}

      <div className="mt-10 border-t border-line pt-6 text-[14px] text-ink-soft">
        <p>Support email: support@saachi.ai</p>
      </div>
    </div>
  );
}