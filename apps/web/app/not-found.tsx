import Link from "next/link";
import { Button } from "@saachi/ui";

export default function NotFound() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-paper px-6 text-center">
      <span className="font-display text-[80px] font-semibold leading-none text-gold-tint">404</span>
      <h1 className="mt-4 font-display text-[24px] font-semibold text-ink">Page not found</h1>
      <p className="mt-2 max-w-[420px] text-[14px] text-ink-soft">
        The page you're looking for doesn't exist or may have moved.
      </p>
      <Link href="/" className="mt-6">
        <Button>Back to homepage</Button>
      </Link>
    </main>
  );
}