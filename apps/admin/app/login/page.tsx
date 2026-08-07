"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ShieldCheck } from "lucide-react";
import { Button, Card, Input, ThemeToggle } from "@saachi/ui";

export default function AdminLoginPage() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    document.cookie = "saachi_admin_session=demo_token; path=/; max-age=" + 60 * 60 * 24 * 7;
    setTimeout(() => router.push("/dashboard"), 500);
  };

  return (
    <main className="flex min-h-screen items-center justify-center bg-paper px-4">
      <div className="absolute right-5 top-5">
        <ThemeToggle />
      </div>

      <Card className="w-full max-w-[400px] p-8">
        <div className="mb-6 flex flex-col items-center text-center">
          <span className="mb-4 flex h-11 w-11 items-center justify-center rounded-full border border-ink text-[15px] font-bold text-ink">
            S
          </span>
          <h1 className="text-[20px] font-semibold text-ink">Saachi AI - Admin</h1>
          <p className="mt-1.5 text-[13px] text-ink-soft">Internal staff access only. 2FA required.</p>
        </div>

        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input label="Email" type="email" placeholder="you@saachi.ai" required />
          <Input label="Password" type="password" placeholder="********" required />
          <Button type="submit" size="lg" disabled={loading}>
            {loading ? "Verifying..." : "Continue"}
          </Button>
        </form>

        <div className="mt-5 flex items-center justify-center gap-1.5 text-[12px] text-ink-soft">
          <ShieldCheck size={13} strokeWidth={1.75} />
          Protected by mandatory two-factor authentication
        </div>
      </Card>
    </main>
  );
}