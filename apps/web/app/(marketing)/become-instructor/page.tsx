import Link from "next/link";
import Image from "next/image";
import { ArrowRight } from "lucide-react";
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";

// TODO: replace with data from a CMS/marketing content API once available
const instructorSpotlight = {
  quote: '"Saachi AI amplified my reach tenfold."',
  image:
    "https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=80",
};

export default function BecomeInstructorPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-6 px-6 py-24 md:flex-row">
        {/* Left: copy card */}
        <div
          className="flex flex-1 flex-col justify-center gap-6 rounded-xl bg-[var(--token-color-surface)] px-10 py-24 shadow-[var(--token-shadow-md)]"
          style={{ border: "1px solid color-mix(in srgb, var(--token-color-border) 30%, transparent)" }}
        >
          <h1
            className="max-w-[732px] text-5xl font-bold leading-[52.8px]"
            style={{ color: "var(--token-color-ink)" }}
          >
            Inspire the Next Generation of AI Professionals.
          </h1>

          <p
            className="max-w-[672px] text-lg leading-7"
            style={{ color: "var(--token-color-inkSoft)" }}
          >
            Join our elite network of instructors. Share your expertise, monetize your knowledge, and
            shape the future of artificial intelligence learning globally.
          </p>

          <div>
            <Link
              href="/instructors/onboarding"
              className="inline-flex items-center gap-2 rounded-lg px-6 py-3 text-sm font-semibold tracking-wide text-white shadow-[var(--token-shadow-sm)]"
              style={{ backgroundColor: "var(--token-color-primary)" }}
            >
              Start Your Application
              <ArrowRight size={12} />
            </Link>
          </div>
        </div>

        {/* Right: spotlight image */}
        <div className="relative min-h-72 flex-1 overflow-hidden rounded-xl shadow-[var(--token-shadow-md)]">
          <Image
            src={instructorSpotlight.image}
            alt="Instructor spotlight"
            fill
            sizes="(max-width: 768px) 100vw, 396px"
            className="object-cover"
            priority
          />

          <div
            className="absolute inset-0 flex items-end p-6"
            style={{
              background:
                "linear-gradient(0deg, rgba(0,0,0,0.6) 0%, rgba(0,0,0,0) 60%)",
            }}
          >
            <div className="flex flex-col gap-1">
              <span
                className="text-sm font-semibold uppercase tracking-wide"
                style={{ color: "var(--token-color-primaryTint)" }}
              >
                Instructor Spotlight
              </span>
              <span className="text-base font-semibold text-white">{instructorSpotlight.quote}</span>
            </div>
          </div>
        </div>
      </main>

      <CompactFooter />
    </div>
  );
}
