"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { Home, ArrowLeft, SearchX } from "lucide-react";

export default function NotFound() {
  const router = useRouter();

  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-[var(--token-color-bg)] p-12">
      <div
        className="pointer-events-none absolute -top-28 right-0 h-[600px] w-[600px] rounded-full opacity-5 blur-[32px]"
        style={{ backgroundColor: "var(--token-color-primary)" }}
      />
      <div
        className="pointer-events-none absolute -left-32 bottom-0 h-[500px] w-[500px] rounded-full opacity-5 blur-[32px]"
        style={{ backgroundColor: "var(--token-color-inkSoft)" }}
      />

      <div className="relative flex w-full max-w-[800px] items-center justify-center gap-10">
        <div className="flex flex-1 flex-col gap-6">
          <span className="w-fit rounded-sm bg-[var(--token-color-errorTint)] px-2 pb-1 pt-[3px] text-xs font-medium uppercase tracking-wide text-[var(--token-color-error)]">
            Error 404
          </span>

          <h1 className="pt-2 text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
            Looks like you&apos;re lost in the <span className="text-[var(--token-color-primary)]">void</span>.
          </h1>

          <p className="max-w-96 text-lg leading-7 text-gray-700">
            We couldn&apos;t find the page you were looking for. It might have been moved, deleted, or perhaps it
            never existed in our training data.
          </p>

          <div className="flex items-center gap-4 pt-4">
            <Link
              href="/"
              className="flex items-center gap-2 rounded-lg bg-[var(--token-color-primary)] px-6 py-3 text-sm font-semibold tracking-wide text-white shadow-[0px_4px_14px_0px_rgba(53,37,205,0.25)] hover:bg-[var(--token-color-primaryHover)]"
            >
              <Home className="h-[18px] w-4" />
              Back to Home
            </Link>

            <button
              type="button"
              onClick={() => router.back()}
              className="flex items-center gap-2 rounded-lg border border-[var(--token-color-border)] bg-[var(--token-color-surface)] px-6 py-2.5 text-sm font-semibold tracking-wide text-[var(--token-color-ink)] shadow-[0px_1px_2px_0px_rgba(0,0,0,0.05)] hover:bg-[var(--token-color-surfaceAlt)]"
            >
              <ArrowLeft className="h-4 w-4" />
              Go Back
            </button>
          </div>
        </div>

        <div className="flex flex-1 justify-center">
          <div className="relative max-w-96 flex-1 overflow-hidden rounded-[32px] border border-white/20 bg-[var(--token-color-surface)]/70 shadow-[0px_10px_40px_0px_rgba(15,23,42,0.08)] backdrop-blur-[5px]">
            <img
              src="https://placehold.co/378x378/F8FAFC/CBD5E1?text=404"
              alt="Lost robot illustration"
              className="h-full w-full object-cover"
            />

            <div className="absolute -left-4 top-[289px] flex items-center gap-2 rounded-lg border border-[var(--token-color-border)] bg-[var(--token-color-surface)] p-2 shadow-lg">
              <span className="flex h-8 w-8 items-center justify-center rounded-full bg-[var(--token-color-error)]/10">
                <SearchX className="h-3.5 w-3.5 text-[var(--token-color-error)]" />
              </span>
              <div>
                <p className="text-xs font-medium text-[var(--token-color-ink)]">Target Not Found</p>
                <p className="text-[10px] text-[var(--token-color-inkSoft)]">Rerouting...</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}