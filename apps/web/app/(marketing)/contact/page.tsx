"use client";

import { useState } from "react";
import { Mail, MessageCircle } from "lucide-react";
import { Button, Card, Input, Textarea } from "@saachi/ui";
import { Navbar } from "../_components/Navbar";
import { Footer } from "../_components/Footer";

export default function ContactPage() {
  const [sent, setSent] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // NOTE: demo-only. Replace with real Support/Helpdesk API call once backend exists.
    setSent(true);
  };

  return (
    <>
      <Navbar />
      <main className="mx-auto max-w-[900px] px-6 py-16">
        <div className="mb-10 text-center">
          <h1 className="font-display text-[28px] font-semibold text-ink">Get in touch</h1>
          <p className="mt-2 text-[15px] text-ink-soft">
            Questions about courses, instructor applications, or your account? We're here to help.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-[1fr_320px]">
          <Card className="p-6">
            {sent ? (
              <div className="py-8 text-center">
                <h2 className="text-[18px] font-semibold text-ink">Message sent</h2>
                <p className="mt-2 text-[14px] text-ink-soft">
                  This is a demo form - no message was actually delivered. We'll typically reply
                  within 1 business day once live support is connected.
                </p>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="flex flex-col gap-4">
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <Input label="Your name" placeholder="Full name" required />
                  <Input label="Email" type="email" placeholder="you@example.com" required />
                </div>
                <Input label="Subject" placeholder="What's this about?" required />
                <Textarea label="Message" placeholder="Tell us more..." rows={6} required />
                <Button type="submit" size="lg" className="mt-2 w-fit">
                  Send message
                </Button>
              </form>
            )}
          </Card>

          <div className="flex flex-col gap-4">
            <Card className="flex items-start gap-3 p-5">
              <Mail size={18} className="mt-0.5 shrink-0 text-teal" />
              <div>
                <p className="text-[14px] font-semibold text-ink">Email support</p>
                <p className="mt-1 text-[13px] text-ink-soft">support@saachi.ai</p>
              </div>
            </Card>
            <Card className="flex items-start gap-3 p-5">
              <MessageCircle size={18} className="mt-0.5 shrink-0 text-teal" />
              <div>
                <p className="text-[14px] font-semibold text-ink">Community</p>
                <p className="mt-1 text-[13px] text-ink-soft">
                  Enrolled learners can ask questions directly in any course's Q&A tab.
                </p>
              </div>
            </Card>
          </div>
        </div>
      </main>
      <Footer />
    </>
  );
}