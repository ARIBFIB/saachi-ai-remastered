<#
  Fix-StatusPill-Sessions.ps1
  ---------------------------------------------------------------------------
  Fixes the Vercel build error:
    "Property 'children' does not exist on type 'IntrinsicAttributes & StatusPillProps'"
    at app/(learner)/mentorship/sessions/page.tsx:43

  StatusPill does not accept JSX children. Replaces both <StatusPill status="...">Text</StatusPill>
  usages with a plain styled <span> instead, since StatusPillProps' exact label/text
  prop name is unknown - this avoids guessing wrong a second time.

  Run from the SAI2 repo root:
    powershell -ExecutionPolicy Bypass -File .\Fix-StatusPill-Sessions.ps1
#>

$ErrorActionPreference = "Stop"
$Root = (Get-Location).Path

function Write-Utf8NoBom {
    param([string]$RelativePath, [string]$Content)
    $fullPath = Join-Path $Root $RelativePath
    $dir = Split-Path $fullPath -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($fullPath, $Content, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  wrote $RelativePath"
}

Write-Host "== SAI2 :: Fix StatusPill children error ==" -ForegroundColor Cyan

$targetPath = "apps/web/app/(learner)/mentorship/sessions/page.tsx"
$fullTargetPath = Join-Path $Root $targetPath

if (Test-Path $fullTargetPath) {
    $backupPath = "$fullTargetPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $fullTargetPath $backupPath
    Write-Host "  backed up existing file -> $backupPath"
}

Write-Utf8NoBom $targetPath @'
"use client";

import { Video, CalendarDays } from "lucide-react";
import { Button, EmptyState } from "@saachi/ui";

type Session = {
  id: string;
  instructorName: string;
  topic: string;
  when: string;
  status: "upcoming" | "past";
};

const SESSIONS: Session[] = [
  { id: "s1", instructorName: "Ayesha Khan", topic: "n8n workflow review", when: "Mon, 10:00 AM", status: "upcoming" },
  { id: "s2", instructorName: "Hamza Malik", topic: "API integration Q&A", when: "Last Thu, 9:00 AM", status: "past" }
];

export default function MyMentorshipSessionsPage() {
  const upcoming = SESSIONS.filter((s) => s.status === "upcoming");
  const past = SESSIONS.filter((s) => s.status === "past");

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">My Mentorship Sessions</h1>

      <h2 className="mb-3 text-[15px] font-semibold text-ink">Upcoming</h2>
      {upcoming.length === 0 ? (
        <EmptyState title="No upcoming sessions" description="Book a mentorship session to see it here." />
      ) : (
        <div className="mb-8 flex flex-col gap-3">
          {upcoming.map((s) => (
            <div key={s.id} className="flex items-center gap-4 rounded-card border border-line bg-card p-4">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-gold-tint text-gold-dark">
                <CalendarDays size={16} />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[14px] font-semibold text-ink">{s.topic}</p>
                <p className="text-[13px] text-ink-soft">
                  with {s.instructorName} - {s.when}
                </p>
              </div>
              <span className="shrink-0 rounded-full bg-gold-tint px-2.5 py-1 text-[11px] font-semibold text-gold-dark">
                Upcoming
              </span>
              <Button size="sm">
                <Video size={14} className="mr-1.5" />
                Join call
              </Button>
            </div>
          ))}
        </div>
      )}

      <h2 className="mb-3 text-[15px] font-semibold text-ink">Past</h2>
      {past.length === 0 ? (
        <EmptyState title="No past sessions" description="Completed sessions will show up here." />
      ) : (
        <div className="flex flex-col gap-3">
          {past.map((s) => (
            <div key={s.id} className="flex items-center gap-4 rounded-card border border-line bg-card p-4 opacity-80">
              <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-paper-dim text-ink-soft">
                <CalendarDays size={16} />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[14px] font-semibold text-ink">{s.topic}</p>
                <p className="text-[13px] text-ink-soft">
                  with {s.instructorName} - {s.when}
                </p>
              </div>
              <span className="shrink-0 rounded-full bg-paper-dim px-2.5 py-1 text-[11px] font-semibold text-ink-soft">
                Completed
              </span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
'@

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Fixed: apps/web/app/(learner)/mentorship/sessions/page.tsx"
Write-Host "apps/admin was NOT touched."
Write-Host ""
Write-Host "Now run: pnpm --filter web build"