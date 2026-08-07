"use client";

import Link from "next/link";
import { CheckCircle2 } from "lucide-react";
import { Button, Card } from "@saachi/ui";

export default function OrderConfirmationPage() {
  return (
    <main className="mx-auto flex max-w-[640px] flex-col items-center px-6 py-16 text-center md:px-10">
      <div className="mb-6 flex h-16 w-16 items-center justify-center rounded-full bg-teal-light text-teal">
        <CheckCircle2 size={32} />
      </div>
      <h1 className="font-display text-[26px] font-semibold text-ink">Payment successful</h1>
      <p className="mt-2 text-[14px] text-ink-soft">
        You're enrolled. Your course is now available under My Courses.
      </p>

      <Card className="mt-8 w-full p-6 text-left">
        <p className="text-[13px] text-ink-soft">
          This is demo data - no real order or invoice was generated. Once the backend is
          connected, this page will show the real order ID and invoice download link.
        </p>
      </Card>

      <div className="mt-8 flex flex-col gap-3 sm:flex-row">
        <Link href="/my-courses">
          <Button size="lg">Go to My Courses</Button>
        </Link>
        <Link href="/courses">
          <Button size="lg" variant="secondary">
            Browse more courses
          </Button>
        </Link>
      </div>
    </main>
  );
}