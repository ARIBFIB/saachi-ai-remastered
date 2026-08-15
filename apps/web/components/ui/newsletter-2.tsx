"use client";

import { RiArrowRightLine, RiLockLine } from "@remixicon/react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { Toaster } from "@/components/ui/sonner";

export default function NewsletterBlock() {
  return (
    <section className="flex w-full items-center justify-center rounded-card border border-line bg-card px-6 py-12 text-ink">
      <Toaster />
      <div className="w-full max-w-5xl px-2 py-2 sm:px-6 sm:py-4">
        <div className="flex flex-col gap-8 md:flex-row md:items-center md:justify-between md:gap-16">
          <div className="flex flex-col gap-3 md:max-w-sm">
            <p className="text-xs font-semibold tracking-widest text-ink-soft uppercase">
              Saachi AI Weekly
            </p>
            <h2 className="font-display text-2xl leading-tight font-bold tracking-tight text-ink sm:text-3xl">
              Get new courses in your inbox
            </h2>
            <p className="text-sm text-ink-soft">
              One email a week. New releases, instructor spotlights, and the
              occasional discount code.
            </p>
          </div>

          <div className="flex flex-col gap-3 md:max-w-md md:min-w-0 md:flex-1">
            <form
              className="flex flex-col gap-3"
              onSubmit={(e) => {
                e.preventDefault();
                toast.success("You're subscribed. See you Tuesday!");
              }}
            >
              <div className="flex flex-col gap-2 sm:flex-row">
                <input
                  type="email"
                  required
                  placeholder="you@example.com"
                  aria-label="Email address"
                  className="h-10 flex-1 rounded-control border border-line-strong bg-card px-3.5 text-[14px] text-ink outline-none transition-colors duration-150 ease-out placeholder:text-ink-soft/50 focus:border-gold"
                />
                <Button type="submit" variant="brand" className="shrink-0 rounded-full px-5">
                  Subscribe
                  <RiArrowRightLine aria-hidden="true" className="ml-1.5" size={16} />
                </Button>
              </div>
              <div className="flex items-center gap-2">
                <Checkbox id="newsletter-consent" name="consent" />
                <label
                  htmlFor="newsletter-consent"
                  className="text-sm font-normal text-ink-soft"
                >
                  I agree to receive the Saachi AI Weekly newsletter.
                </label>
              </div>
            </form>
            <p className="flex items-center gap-1.5 text-xs text-ink-soft">
              <RiLockLine aria-hidden="true" className="shrink-0" size={12} />
              Your data stays private. Unsubscribe any time, no questions asked.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}