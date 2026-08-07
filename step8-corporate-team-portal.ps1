# step8-corporate-team-portal.ps1
# Run from: SAI2 root folder

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param([string]$Path, [string]$Content)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    $dir = Split-Path -Parent $fullPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($fullPath, $Content, $enc)
    Write-Host "  wrote $fullPath"
}

Write-Host "Step 8: Corporate/Team Portal (Phase 2, per Doc 1 Section 6.2 + 15)..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. useCorporateStore - team roster, assignments, seats
# ---------------------------------------------------------------------------
$corporateStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type TeamMember = {
  id: string;
  name: string;
  email: string;
  status: "invited" | "active";
  assignedCourseIds: string[];
  completedCourseIds: string[];
};

export type CorporateAccount = {
  companyName: string;
  seatsPurchased: number;
  seatsUsed: number;
};

const SEED_TEAM: TeamMember[] = [
  {
    id: "tm_1",
    name: "Zainab Rehman",
    email: "zainab@acmeagency.com",
    status: "active",
    assignedCourseIds: ["crs_001", "crs_002"],
    completedCourseIds: ["crs_001"]
  },
  {
    id: "tm_2",
    name: "Ali Raza",
    email: "ali@acmeagency.com",
    status: "active",
    assignedCourseIds: ["crs_003"],
    completedCourseIds: []
  },
  {
    id: "tm_3",
    name: "Mahnoor Fatima",
    email: "mahnoor@acmeagency.com",
    status: "invited",
    assignedCourseIds: [],
    completedCourseIds: []
  }
];

type CorporateState = {
  account: CorporateAccount;
  team: TeamMember[];
  inviteMember: (name: string, email: string) => void;
  removeMember: (id: string) => void;
  assignCourse: (memberId: string, courseId: string) => void;
  purchaseSeats: (count: number) => void;
};

export const useCorporateStore = create<CorporateState>()(
  persist(
    (set, get) => ({
      account: { companyName: "Acme Agency", seatsPurchased: 10, seatsUsed: 3 },
      team: SEED_TEAM,

      inviteMember: (name, email) => {
        const newMember: TeamMember = {
          id: `tm_${Math.random().toString(36).slice(2, 9)}`,
          name,
          email,
          status: "invited",
          assignedCourseIds: [],
          completedCourseIds: []
        };
        set({
          team: [...get().team, newMember],
          account: { ...get().account, seatsUsed: get().account.seatsUsed + 1 }
        });
      },

      removeMember: (id) => {
        set({
          team: get().team.filter((m) => m.id !== id),
          account: { ...get().account, seatsUsed: Math.max(0, get().account.seatsUsed - 1) }
        });
      },

      assignCourse: (memberId, courseId) => {
        set({
          team: get().team.map((m) =>
            m.id === memberId && !m.assignedCourseIds.includes(courseId)
              ? { ...m, assignedCourseIds: [...m.assignedCourseIds, courseId] }
              : m
          )
        });
      },

      purchaseSeats: (count) => {
        set({ account: { ...get().account, seatsPurchased: get().account.seatsPurchased + count } });
      }
    }),
    { name: "saachi-corporate" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useCorporateStore.ts" -Content $corporateStore

$storeIndexUpdated = @'
export * from "./useCartStore";
export * from "./useWishlistStore";
export * from "./useEnrollmentStore";
export * from "./useNotificationStore";
export * from "./useInstructorCourseStore";
export * from "./useCourseBuilderStore";
export * from "./useOrderStore";
export * from "./useCommunityStore";
export * from "./usePromotionStore";
export * from "./useCorporateStore";
'@
Write-Utf8NoBom -Path "packages\store\src\index.ts" -Content $storeIndexUpdated

# ---------------------------------------------------------------------------
# 2. Corporate shell (sidebar layout)
# ---------------------------------------------------------------------------
$corporateShell = @'
"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { useState, type ReactNode } from "react";
import { LayoutDashboard, Users, BookOpen, BarChart3, CreditCard, LogOut, Menu, X } from "lucide-react";
import { useSession, useLogout } from "@saachi/api-client";
import { useCorporateStore } from "@saachi/store";
import { cn } from "@saachi/ui";

const NAV_ITEMS = [
  { label: "Dashboard", href: "/corporate/dashboard", icon: LayoutDashboard },
  { label: "Team Roster", href: "/corporate/team", icon: Users },
  { label: "Course Assignment", href: "/corporate/assignments", icon: BookOpen },
  { label: "Reports", href: "/corporate/reports", icon: BarChart3 },
  { label: "Billing", href: "/corporate/billing", icon: CreditCard }
];

export function CorporateShell({ children }: { children: ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const { account } = useCorporateStore();
  const [mobileOpen, setMobileOpen] = useState(false);

  const handleLogout = async () => {
    await logout.mutateAsync();
    router.push("/");
  };

  const sidebarContent = (
    <div className="flex h-full flex-col">
      <Link href="/" className="flex items-center gap-2.5 px-6 py-6">
        <span className="flex h-9 w-9 items-center justify-center rounded-full border-2 border-ink bg-ink font-display text-[15px] font-bold text-white">
          S
        </span>
        <div>
          <div className="font-display text-[15px] font-semibold leading-none text-ink">{account.companyName}</div>
          <div className="mt-1 text-[11px] font-medium uppercase tracking-[0.06em] text-ink-soft">
            Corporate Account
          </div>
        </div>
      </Link>

      <nav className="flex flex-1 flex-col gap-1 px-3">
        {NAV_ITEMS.map((item) => {
          const active = pathname === item.href || Boolean(pathname && pathname.startsWith(`${item.href}/`));
          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setMobileOpen(false)}
              className={cn(
                "flex items-center gap-3 rounded-control px-3.5 py-2.5 text-[14px] font-medium transition-colors duration-150 ease-out",
                active ? "bg-paper-dim text-ink" : "text-ink-soft hover:bg-paper-dim hover:text-ink"
              )}
            >
              <item.icon size={18} />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-line px-3 py-4">
        <div className="mb-3 px-3 text-[12px] text-ink-soft">
          {account.seatsUsed} / {account.seatsPurchased} seats used
        </div>
        <div className="mb-3 flex items-center gap-3 px-3">
          <div className="flex h-9 w-9 shrink-0 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[13px] font-semibold text-teal">
            {session?.fullName?.charAt(0) ?? "?"}
          </div>
          <div className="min-w-0">
            <div className="truncate text-[13px] font-semibold text-ink">{session?.fullName ?? "Guest"}</div>
            <div className="truncate text-[12px] text-ink-soft">{session?.email ?? ""}</div>
          </div>
        </div>
        <button
          type="button"
          onClick={handleLogout}
          disabled={logout.isPending}
          className="flex w-full items-center gap-3 rounded-control px-3.5 py-2.5 text-[14px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-error"
        >
          <LogOut size={18} />
          {logout.isPending ? "Logging out..." : "Log out"}
        </button>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-paper">
      <div className="hidden w-[260px] shrink-0 border-r border-line bg-card md:fixed md:inset-y-0 md:flex">
        {sidebarContent}
      </div>

      <div className="flex items-center justify-between border-b border-line bg-card px-4 py-3 md:hidden">
        <span className="font-display text-[15px] font-semibold text-ink">{account.companyName}</span>
        <button
          type="button"
          onClick={() => setMobileOpen(true)}
          aria-label="Open menu"
          className="flex h-9 w-9 items-center justify-center rounded-control text-ink"
        >
          <Menu size={20} />
        </button>
      </div>

      {mobileOpen && (
        <div className="fixed inset-0 z-50 flex md:hidden">
          <div className="absolute inset-0 bg-ink/40" onClick={() => setMobileOpen(false)} />
          <div className="relative flex h-full w-[280px] flex-col bg-card">
            <button
              type="button"
              onClick={() => setMobileOpen(false)}
              aria-label="Close menu"
              className="absolute right-3 top-3 flex h-9 w-9 items-center justify-center rounded-control text-ink"
            >
              <X size={20} />
            </button>
            {sidebarContent}
          </div>
        </div>
      )}

      <div className="md:pl-[260px]">{children}</div>
    </div>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(corporate)\_components\CorporateShell.tsx" -Content $corporateShell

$corporateLayout = @'
import type { ReactNode } from "react";
import { CorporateShell } from "./_components/CorporateShell";

export default function CorporateLayout({ children }: { children: ReactNode }) {
  return <CorporateShell>{children}</CorporateShell>;
}
'@
Write-Utf8NoBom -Path "apps\web\app\(corporate)\layout.tsx" -Content $corporateLayout

# ---------------------------------------------------------------------------
# 3. Corporate Dashboard
# ---------------------------------------------------------------------------
$corporateDashboard = @'
"use client";

import { Users, BookOpen, TrendingUp, CreditCard } from "lucide-react";
import { useCorporateStore } from "@saachi/store";
import { Card } from "@saachi/ui";

export default function CorporateDashboardPage() {
  const { account, team } = useCorporateStore();

  const totalAssignments = team.reduce((sum, m) => sum + m.assignedCourseIds.length, 0);
  const totalCompletions = team.reduce((sum, m) => sum + m.completedCourseIds.length, 0);
  const completionRate = totalAssignments > 0 ? Math.round((totalCompletions / totalAssignments) * 100) : 0;
  const activeMembers = team.filter((m) => m.status === "active").length;

  const stats = [
    { label: "Team members", value: `${activeMembers}/${team.length}`, icon: Users },
    { label: "Seats available", value: `${account.seatsPurchased - account.seatsUsed}`, icon: CreditCard },
    { label: "Course assignments", value: String(totalAssignments), icon: BookOpen },
    { label: "Completion rate", value: `${completionRate}%`, icon: TrendingUp }
  ];

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">{account.companyName} Dashboard</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Team learning overview and seat usage.</p>
      </div>

      <div className="mb-10 grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <Card key={stat.label} className="p-5">
            <div className="mb-3 flex h-9 w-9 items-center justify-center rounded-control bg-paper-dim text-ink">
              <stat.icon size={17} />
            </div>
            <div className="font-mono text-[22px] font-semibold text-ink">{stat.value}</div>
            <div className="mt-1 text-[13px] text-ink-soft">{stat.label}</div>
          </Card>
        ))}
      </div>

      <h2 className="mb-4 font-display text-[18px] font-semibold text-ink">Recent activity</h2>
      <div className="flex flex-col gap-3">
        {team.slice(0, 5).map((member) => (
          <Card key={member.id} className="flex items-center justify-between p-4">
            <div>
              <p className="text-[14px] font-semibold text-ink">{member.name}</p>
              <p className="mt-0.5 text-[12px] text-ink-soft">
                {member.completedCourseIds.length} of {member.assignedCourseIds.length} assigned courses completed
              </p>
            </div>
            <span className="text-[12px] capitalize text-ink-soft">{member.status}</span>
          </Card>
        ))}
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(corporate)\corporate\dashboard\page.tsx" -Content $corporateDashboard

# ---------------------------------------------------------------------------
# 4. Team Roster Management
# ---------------------------------------------------------------------------
$teamRosterPage = @'
"use client";

import { useState } from "react";
import { UserPlus, Trash2 } from "lucide-react";
import { useCorporateStore } from "@saachi/store";
import { Button, Card, Input, Badge } from "@saachi/ui";

export default function TeamRosterPage() {
  const { team, account, inviteMember, removeMember } = useCorporateStore();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");

  const seatsRemaining = account.seatsPurchased - account.seatsUsed;

  const handleInvite = (e: React.FormEvent) => {
    e.preventDefault();
    if (!name.trim() || !email.trim() || seatsRemaining <= 0) return;
    inviteMember(name.trim(), email.trim());
    setName("");
    setEmail("");
  };

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Team Roster</h1>
        <p className="mt-1 text-[14px] text-ink-soft">
          {seatsRemaining} of {account.seatsPurchased} seats available
        </p>
      </div>

      <Card className="mb-8 p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Invite a team member</h2>
        <form onSubmit={handleInvite} className="flex flex-col gap-4 sm:flex-row sm:items-end">
          <Input label="Full name" placeholder="Team member's name" value={name} onChange={(e) => setName(e.target.value)} className="flex-1" />
          <Input label="Work email" type="email" placeholder="name@company.com" value={email} onChange={(e) => setEmail(e.target.value)} className="flex-1" />
          <Button type="submit" disabled={seatsRemaining <= 0}>
            <UserPlus size={16} /> Invite
          </Button>
        </form>
        {seatsRemaining <= 0 && (
          <p className="mt-3 text-[12px] text-error">No seats remaining - purchase more seats in Billing.</p>
        )}
      </Card>

      <div className="flex flex-col gap-3">
        {team.map((member) => (
          <Card key={member.id} className="flex items-center justify-between p-4">
            <div>
              <div className="flex items-center gap-2">
                <p className="text-[14px] font-semibold text-ink">{member.name}</p>
                <Badge variant={member.status === "active" ? "success" : "default"}>{member.status}</Badge>
              </div>
              <p className="mt-1 text-[12px] text-ink-soft">{member.email}</p>
            </div>
            <button
              type="button"
              onClick={() => removeMember(member.id)}
              className="flex h-8 w-8 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim hover:text-error"
              aria-label="Remove member"
            >
              <Trash2 size={15} />
            </button>
          </Card>
        ))}
      </div>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(corporate)\corporate\team\page.tsx" -Content $teamRosterPage

# ---------------------------------------------------------------------------
# 5. Course Assignment page
# ---------------------------------------------------------------------------
$assignmentsPage = @'
"use client";

import { useState } from "react";
import { useCorporateStore } from "@saachi/store";
import { DUMMY_COURSES } from "@saachi/api-client";
import { Button, Card, Select, Badge, EmptyState } from "@saachi/ui";
import { Users } from "lucide-react";

export default function CourseAssignmentPage() {
  const { team, assignCourse } = useCorporateStore();
  const [selectedMemberId, setSelectedMemberId] = useState(team[0]?.id ?? "");
  const [selectedCourseId, setSelectedCourseId] = useState(DUMMY_COURSES[0]?.id ?? "");

  const memberOptions = team.map((m) => ({ label: m.name, value: m.id }));
  const courseOptions = DUMMY_COURSES.map((c) => ({ label: c.title, value: c.id }));

  const handleAssign = () => {
    if (!selectedMemberId || !selectedCourseId) return;
    assignCourse(selectedMemberId, selectedCourseId);
  };

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Course Assignment</h1>

      {team.length === 0 ? (
        <EmptyState icon={<Users size={22} />} title="No team members yet" description="Invite team members first from Team Roster." />
      ) : (
        <>
          <Card className="mb-8 p-6">
            <h2 className="mb-4 text-[15px] font-semibold text-ink">Assign a course</h2>
            <div className="flex flex-col gap-4 sm:flex-row sm:items-end">
              <Select label="Team member" options={memberOptions} value={selectedMemberId} onChange={(e) => setSelectedMemberId(e.target.value)} className="flex-1" />
              <Select label="Course" options={courseOptions} value={selectedCourseId} onChange={(e) => setSelectedCourseId(e.target.value)} className="flex-1" />
              <Button onClick={handleAssign}>Assign</Button>
            </div>
          </Card>

          <div className="flex flex-col gap-3">
            {team.map((member) => (
              <Card key={member.id} className="p-4">
                <p className="mb-2 text-[14px] font-semibold text-ink">{member.name}</p>
                {member.assignedCourseIds.length === 0 ? (
                  <p className="text-[12px] text-ink-soft">No courses assigned yet.</p>
                ) : (
                  <div className="flex flex-wrap gap-2">
                    {member.assignedCourseIds.map((courseId) => {
                      const course = DUMMY_COURSES.find((c) => c.id === courseId);
                      const completed = member.completedCourseIds.includes(courseId);
                      return (
                        <Badge key={courseId} variant={completed ? "success" : "default"}>
                          {course?.title ?? courseId} {completed ? "- done" : ""}
                        </Badge>
                      );
                    })}
                  </div>
                )}
              </Card>
            ))}
          </div>
        </>
      )}
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(corporate)\corporate\assignments\page.tsx" -Content $assignmentsPage

# ---------------------------------------------------------------------------
# 6. Team Reports page
# ---------------------------------------------------------------------------
$reportsPage = @'
"use client";

import { Download } from "lucide-react";
import { useCorporateStore } from "@saachi/store";
import { Button, Card } from "@saachi/ui";

export default function TeamReportsPage() {
  const { team } = useCorporateStore();

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <div className="mb-8 flex items-center justify-between">
        <div>
          <h1 className="font-display text-[26px] font-semibold text-ink">Team Reports</h1>
          <p className="mt-1 text-[14px] text-ink-soft">Per-employee completion and compliance overview.</p>
        </div>
        <Button variant="secondary">
          <Download size={15} /> Export CSV
        </Button>
      </div>

      <Card className="overflow-hidden p-0">
        <table className="w-full text-left text-[13px]">
          <thead className="border-b border-line bg-paper-dim text-ink-soft">
            <tr>
              <th className="px-4 py-3 font-semibold">Name</th>
              <th className="px-4 py-3 font-semibold">Status</th>
              <th className="px-4 py-3 font-semibold">Assigned</th>
              <th className="px-4 py-3 font-semibold">Completed</th>
              <th className="px-4 py-3 font-semibold">Completion %</th>
            </tr>
          </thead>
          <tbody>
            {team.map((member) => {
              const pct =
                member.assignedCourseIds.length > 0
                  ? Math.round((member.completedCourseIds.length / member.assignedCourseIds.length) * 100)
                  : 0;
              return (
                <tr key={member.id} className="border-b border-line last:border-0">
                  <td className="px-4 py-3 text-ink">{member.name}</td>
                  <td className="px-4 py-3 capitalize text-ink-soft">{member.status}</td>
                  <td className="px-4 py-3 text-ink-soft">{member.assignedCourseIds.length}</td>
                  <td className="px-4 py-3 text-ink-soft">{member.completedCourseIds.length}</td>
                  <td className="px-4 py-3 font-semibold text-ink">{pct}%</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </Card>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(corporate)\corporate\reports\page.tsx" -Content $reportsPage

# ---------------------------------------------------------------------------
# 7. Corporate Billing page
# ---------------------------------------------------------------------------
$corporateBillingPage = @'
"use client";

import { useState } from "react";
import { CreditCard, FileText } from "lucide-react";
import { useCorporateStore } from "@saachi/store";
import { Button, Card, Input } from "@saachi/ui";
import { formatCurrency } from "@saachi/utils";

const SEAT_PRICE = 29;

export default function CorporateBillingPage() {
  const { account, purchaseSeats } = useCorporateStore();
  const [seatCount, setSeatCount] = useState(5);
  const [purchased, setPurchased] = useState(false);

  const handlePurchase = () => {
    purchaseSeats(seatCount);
    setPurchased(true);
    setTimeout(() => setPurchased(false), 2500);
  };

  return (
    <main className="mx-auto max-w-[800px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Billing</h1>

      <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Total seats</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{account.seatsPurchased}</p>
        </Card>
        <Card className="p-5">
          <p className="text-[13px] text-ink-soft">Seats used</p>
          <p className="mt-1 font-mono text-[22px] font-semibold text-ink">{account.seatsUsed}</p>
        </Card>
      </div>

      <Card className="mb-8 p-6">
        <h2 className="mb-4 text-[15px] font-semibold text-ink">Purchase additional seats</h2>
        <div className="flex flex-col gap-4 sm:flex-row sm:items-end">
          <Input
            label="Number of seats"
            type="number"
            min={1}
            value={seatCount}
            onChange={(e) => setSeatCount(Number(e.target.value))}
            className="sm:w-[180px]"
          />
          <div className="flex-1 text-[13px] text-ink-soft">
            {seatCount} seats &times; {formatCurrency(SEAT_PRICE, "USD")} ={" "}
            <span className="font-semibold text-ink">{formatCurrency(seatCount * SEAT_PRICE, "USD")}</span>
          </div>
          <Button onClick={handlePurchase}>
            <CreditCard size={16} /> Purchase seats
          </Button>
        </div>
        {purchased && <p className="mt-3 text-[13px] text-teal">Seats purchased (demo) - invoice sent to billing email.</p>}
      </Card>

      <Card className="p-6">
        <div className="flex items-center gap-3">
          <FileText size={18} className="text-ink-soft" />
          <div>
            <h2 className="text-[15px] font-semibold text-ink">PO-based billing</h2>
            <p className="text-[13px] text-ink-soft">
              Enterprise clients can request custom invoicing instead of card checkout - contact sales.
            </p>
          </div>
        </div>
      </Card>
    </main>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(corporate)\corporate\billing\page.tsx" -Content $corporateBillingPage

Write-Host ""
Write-Host "Step 8 done." -ForegroundColor Green
Write-Host "Run: pnpm dev:web" -ForegroundColor Green
Write-Host "Test: /corporate/dashboard, /corporate/team (invite a member), /corporate/assignments (assign a course), /corporate/reports, /corporate/billing (buy seats)" -ForegroundColor Green