"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { ShieldCheck, AlertCircle } from "lucide-react";
import { Button, Card, Input, ThemeToggle } from "@saachi/ui";
import { findStaffUser, setAuthCookies, ROLE_LABEL, type StaffRole } from "../../lib/permissions";

const DEMO_CREDENTIALS: { role: StaffRole; email: string; password: string }[] = [
  { role: "super_admin", email: "superadmin@saachi.ai", password: "super123" },
  { role: "admin", email: "admin@saachi.ai", password: "admin123" },
  { role: "finance_officer", email: "finance@saachi.ai", password: "finance123" },
  { role: "support_officer", email: "support@saachi.ai", password: "support123" }
];

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    const user = findStaffUser(email, password);
    if (!user) {
      setError("Invalid email or password. Check the demo credentials below.");
      return;
    }

    setLoading(true);
    setAuthCookies(user);
    setTimeout(() => router.push("/dashboard"), 500);
  };

  const fillDemo = (cred: (typeof DEMO_CREDENTIALS)[number]) => {
    setEmail(cred.email);
    setPassword(cred.password);
    setError("");
  };

  return (
    <main className="flex min-h-screen items-center justify-center bg-paper px-4 py-10">
      <div className="absolute right-5 top-5">
        <ThemeToggle />
      </div>

      <div className="flex w-full max-w-[860px] flex-col gap-6 lg:flex-row lg:items-start">
        <Card className="w-full max-w-[400px] p-8 lg:mx-auto">
          <div className="mb-6 flex flex-col items-center text-center">
            <span className="mb-4 flex h-11 w-11 items-center justify-center rounded-full border border-ink text-[15px] font-bold text-ink">
              S
            </span>
            <h1 className="text-[20px] font-semibold text-ink">Saachi AI - Admin</h1>
            <p className="mt-1.5 text-[13px] text-ink-soft">Internal staff access only.</p>
          </div>

          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <Input
              label="Email"
              type="email"
              placeholder="you@saachi.ai"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
            <Input
              label="Password"
              type="password"
              placeholder="********"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />

            {error && (
              <div className="flex items-start gap-2 rounded-control border border-error bg-error-tint px-3 py-2.5 text-[12.5px] text-error">
                <AlertCircle size={14} strokeWidth={1.75} className="mt-0.5 shrink-0" />
                <span>{error}</span>
              </div>
            )}

            <Button type="submit" size="lg" disabled={loading}>
              {loading ? "Verifying..." : "Continue"}
            </Button>
          </form>

          <div className="mt-5 flex items-center justify-center gap-1.5 text-[12px] text-ink-soft">
            <ShieldCheck size={13} strokeWidth={1.75} />
            Role-based access control demo
          </div>
        </Card>

        <Card className="w-full max-w-[400px] p-6 lg:mx-auto">
          <p className="mb-1 text-[13px] font-semibold text-ink">Demo credentials</p>
          <p className="mb-4 text-[12px] text-ink-soft">
            No backend yet - click a role below to auto-fill and try each access level.
          </p>
          <div className="flex flex-col gap-2">
            {DEMO_CREDENTIALS.map((cred) => (
              <button
                key={cred.role}
                type="button"
                onClick={() => fillDemo(cred)}
                className="flex flex-col items-start rounded-control border border-line px-3.5 py-2.5 text-left transition-colors duration-150 ease-out hover:border-line-strong hover:bg-paper-dim"
              >
                <span className="text-[13px] font-semibold text-ink">{ROLE_LABEL[cred.role]}</span>
                <span className="mt-0.5 font-mono text-[11.5px] text-ink-soft">{cred.email}</span>
                <span className="font-mono text-[11.5px] text-ink-soft">{cred.password}</span>
              </button>
            ))}
          </div>
        </Card>
      </div>
    </main>
  );
}