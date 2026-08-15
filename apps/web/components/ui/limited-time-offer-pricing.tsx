"use client";

import * as React from "react";
import { PlusIcon, ShieldCheckIcon, TimerIcon } from "lucide-react";
import { motion } from "framer-motion";
import { Badge } from "@saachi/ui";
import { cn } from "@/lib/utils";
import { BorderTrail } from "./border-trail";

// NOTE: demo-only offer window. Replace with a real campaign end-date
// from the backend once the promotions API is wired up.
const OFFER_DURATION_MS = 5 * 24 * 60 * 60 * 1000; // 5 days

type TimeLeft = {
  days: number;
  hours: number;
  minutes: number;
  seconds: number;
  expired: boolean;
};

function getTimeLeft(target: number): TimeLeft {
  const diff = target - Date.now();
  if (diff <= 0) {
    return { days: 0, hours: 0, minutes: 0, seconds: 0, expired: true };
  }
  const days = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours = Math.floor((diff / (1000 * 60 * 60)) % 24);
  const minutes = Math.floor((diff / (1000 * 60)) % 60);
  const seconds = Math.floor((diff / 1000) % 60);
  return { days, hours, minutes, seconds, expired: false };
}

function pad(n: number) {
  return n.toString().padStart(2, "0");
}

function CountdownUnit({ value, label }: { value: number; label: string }) {
  return (
    <div className="flex flex-col items-center">
      <span className="font-mono text-[20px] font-bold leading-none text-ink md:text-[24px]">{pad(value)}</span>
      <span className="mt-1 text-[10px] font-medium uppercase tracking-[0.08em] text-ink-soft">{label}</span>
    </div>
  );
}

const monthlyCtaClassName =
  "inline-flex h-11 w-full items-center justify-center gap-2 rounded-full border border-line-strong bg-card text-[15px] font-semibold text-ink transition-colors duration-150 ease-out hover:bg-paper-dim";

const yearlyCtaClassName =
  "inline-flex h-11 w-full items-center justify-center gap-2 rounded-full text-[15px] font-semibold text-white transition-transform duration-150 ease-out hover:brightness-110";

const yearlyCtaStyle = { backgroundImage: "var(--color-accent-gradient)" };

export function LimitedTimeOfferPricing() {
  const targetRef = React.useRef<number>(Date.now() + OFFER_DURATION_MS);
  const [timeLeft, setTimeLeft] = React.useState<TimeLeft>(() => getTimeLeft(targetRef.current));

  React.useEffect(() => {
    const id = setInterval(() => {
      setTimeLeft(getTimeLeft(targetRef.current));
    }, 1000);
    return () => clearInterval(id);
  }, []);

  return (
    <section className="relative overflow-hidden py-10 md:py-16">
      <div className="mx-auto w-full max-w-6xl space-y-5 px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
          viewport={{ once: true }}
          className="mx-auto max-w-xl space-y-5"
        >
          <div className="flex justify-center">
            <div className="flex items-center gap-2 rounded-lg border border-line bg-card px-4 py-1 font-mono text-[13px] text-ink-soft">
              <TimerIcon size={14} className="text-accent-violet" />
              Limited Time Offer
            </div>
          </div>
          <h2 className="mt-5 text-center font-display text-2xl font-bold tracking-tighter text-ink md:text-3xl lg:text-4xl">
            Lock In Early-Bird Pricing
          </h2>
          <p className="mt-5 text-center text-sm text-ink-soft md:text-base">
            This discount disappears when the timer hits zero. Same courses, same certificates, just less to pay while the offer lasts.
          </p>

          {!timeLeft.expired ? (
            <div className="mx-auto flex w-fit items-center gap-4 rounded-card border border-line bg-card px-6 py-3 shadow-sm md:gap-6">
              <CountdownUnit value={timeLeft.days} label="Days" />
              <span className="text-[20px] font-bold text-line-strong">:</span>
              <CountdownUnit value={timeLeft.hours} label="Hrs" />
              <span className="text-[20px] font-bold text-line-strong">:</span>
              <CountdownUnit value={timeLeft.minutes} label="Min" />
              <span className="text-[20px] font-bold text-line-strong">:</span>
              <CountdownUnit value={timeLeft.seconds} label="Sec" />
            </div>
          ) : (
            <div className="mx-auto w-fit rounded-card border border-line bg-card px-6 py-3 text-[13px] font-medium text-ink-soft">
              This offer has ended, check back soon for the next one.
            </div>
          )}
        </motion.div>

        <div className="relative">
          <div
            className={cn(
              "z--10 pointer-events-none absolute inset-0 size-full",
              "bg-[linear-gradient(to_right,--theme(--color-line/.3)_1px,transparent_1px),linear-gradient(to_bottom,--theme(--color-line/.3)_1px,transparent_1px)]",
              "bg-[size:32px_32px]",
              "[mask-image:radial-gradient(ellipse_at_center,var(--color-paper)_10%,transparent)]"
            )}
          />

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
            viewport={{ once: true }}
            className="mx-auto w-full max-w-2xl space-y-2"
          >
            <div className="relative grid border border-line bg-card p-4 md:grid-cols-2">
              <PlusIcon className="absolute -left-3 -top-3 size-5.5 text-ink-soft" />
              <PlusIcon className="absolute -right-3 -top-3 size-5.5 text-ink-soft" />
              <PlusIcon className="absolute -bottom-3 -left-3 size-5.5 text-ink-soft" />
              <PlusIcon className="absolute -bottom-3 -right-3 size-5.5 text-ink-soft" />

              <div className="w-full px-4 pb-4 pt-5">
                <div className="space-y-1">
                  <div className="flex items-center justify-between">
                    <h3 className="font-semibold leading-none text-ink">Monthly</h3>
                    <div className="flex items-center gap-x-1">
                      <span className="text-sm text-ink-soft line-through">$19</span>
                      <Badge>15% off</Badge>
                    </div>
                  </div>
                  <p className="text-sm text-ink-soft">Full Pro access, cancel anytime.</p>
                </div>
                <div className="mt-10 space-y-4">
                  <div className="flex items-end gap-0.5 text-xl text-ink-soft">
                    <span>$</span>
                    <span className="-mb-0.5 font-display text-4xl font-extrabold tracking-tighter text-ink md:text-5xl">16</span>
                    <span>/month</span>
                  </div>
                  <a href="/register" className={monthlyCtaClassName}>Start Your Journey</a>
                </div>
              </div>

              <div className="relative w-full rounded-lg border border-line px-4 pb-4 pt-5">
                <BorderTrail
                  style={{
                    boxShadow:
                      "0px 0px 60px 30px rgb(124 58 237 / 25%), 0 0 100px 60px rgb(236 72 153 / 15%), 0 0 140px 90px rgb(124 58 237 / 10%)"
                  }}
                  size={100}
                />
                <div className="space-y-1">
                  <div className="flex items-center justify-between">
                    <h3 className="font-semibold leading-none text-ink">Yearly</h3>
                    <div className="flex items-center gap-x-1">
                      <span className="text-sm text-ink-soft line-through">$19</span>
                      <Badge>32% off</Badge>
                    </div>
                  </div>
                  <p className="text-sm text-ink-soft">Unlock the best rate with an annual plan.</p>
                </div>
                <div className="mt-10 space-y-4">
                  <div className="flex items-end text-xl text-ink-soft">
                    <span>$</span>
                    <span className="-mb-0.5 font-display text-4xl font-extrabold tracking-tighter text-ink md:text-5xl">12.99</span>
                    <span>/month</span>
                  </div>
                  <a href="/register" className={yearlyCtaClassName} style={yearlyCtaStyle}>Claim This Offer</a>
                </div>
              </div>
            </div>

            <div className="flex items-center justify-center gap-x-2 text-sm text-ink-soft">
              <ShieldCheckIcon size={16} />
              <span>Access to all Pro features, no hidden fees</span>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}