"use client";

import * as React from "react";
import Link from "next/link";
import { ShieldCheck } from "lucide-react";

export interface GlassCtaProps extends React.HTMLAttributes<HTMLDivElement> {}

const GlassCta = React.forwardRef<HTMLDivElement, GlassCtaProps>(
  ({ className, ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={`group relative w-full [perspective:1200px] ${className ?? ""}`}
        {...props}
      >
        <div className="relative overflow-hidden rounded-[40px] bg-gradient-to-br from-zinc-900 to-black p-10 text-center shadow-2xl transition-all duration-500 ease-in-out [transform-style:preserve-3d] md:p-16 group-hover:[box-shadow:rgba(0,0,0,0.35)_30px_50px_35px_-40px,rgba(0,0,0,0.15)_0px_25px_30px_0px] group-hover:[transform:rotate3d(1,1,0,4deg)]">
          <div className="pointer-events-none absolute inset-2 rounded-[34px] border-b border-l border-white/10 bg-gradient-to-b from-white/10 to-white/0 backdrop-blur-sm [transform-style:preserve-3d] [transform:translate3d(0,0,15px)]" />

          <div className="pointer-events-none absolute -right-16 -top-16 [transform-style:preserve-3d]">
            {[
              { size: "260px", z: "10px", delay: "0s" },
              { size: "200px", z: "30px", delay: "0.3s" },
              { size: "140px", z: "50px", delay: "0.6s" }
            ].map((circle, index) => (
              <div
                key={index}
                className="absolute aspect-square rounded-full bg-white/5 shadow-[rgba(124,58,237,0.25)_-10px_10px_40px_0px] transition-all duration-500 ease-in-out"
                style={{
                  width: circle.size,
                  top: "0px",
                  right: "0px",
                  transform: `translate3d(0, 0, ${circle.z})`,
                  transitionDelay: circle.delay
                }}
              />
            ))}
          </div>

          <div className="relative z-10 flex flex-col items-center [transform:translate3d(0,0,26px)]">
            <ShieldCheck size={28} className="mb-4 text-white/90" />
            <h2 className="font-display text-[26px] font-bold text-white md:text-[34px]">
              Your next skill is one course away.
            </h2>
            <p className="mx-auto mt-3 max-w-lg text-[14.5px] text-white/70">
              Join 42,000+ learners already building real AI projects. 7-day refund window, no risk.
            </p>
            <div className="mt-7 flex flex-wrap items-center justify-center gap-3">
              <Link href="/courses">
                <button className="rounded-full bg-white px-6 py-3 text-[14px] font-semibold text-black transition-transform hover:scale-105">
                  Start learning free
                </button>
              </Link>
              <Link href="/register">
                <button className="rounded-full border border-white/25 px-6 py-3 text-[14px] font-semibold text-white transition-colors hover:bg-white/10">
                  Become an instructor
                </button>
              </Link>
            </div>
          </div>
        </div>
      </div>
    );
  }
);

GlassCta.displayName = "GlassCta";

export default GlassCta;
