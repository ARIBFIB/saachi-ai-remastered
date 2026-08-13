import Link from "next/link";
import { Button } from "@saachi/ui";

export default function NotFound() {
  return (
    <div className="mx-auto flex max-w-lg flex-col items-center px-4 py-24 text-center md:px-0">
      <span className="font-mono text-[64px] font-bold text-gold-dark">404</span>
      <h1 className="mt-2 font-display text-[24px] font-bold text-ink">Page not found</h1>
      <p className="mt-2 text-[14px] text-ink-soft">
        The page you&apos;re looking for doesn&apos;t exist or has been moved.
      </p>
      <div className="mt-8 flex gap-3">
        <Link href="/">
          <Button>Back to homepage</Button>
        </Link>
        <Link href="/courses">
          <Button variant="secondary">Browse courses</Button>
        </Link>
      </div>
    </div>
  );
}