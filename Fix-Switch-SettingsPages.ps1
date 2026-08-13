<#
  Fix-Switch-SettingsPages.ps1
  ---------------------------------------------------------------------------
  Fixes the Vercel build error:
    "Type '(v: any) => void' is not assignable to type '() => void'"
    at app/(learner)/settings/privacy/page.tsx:28

  @saachi/ui's Switch.onChange takes zero arguments (its exact signature/prop
  name beyond that is unknown), so passing a value-taking callback breaks
  type-checking. Replaces Switch usage in both settings/privacy and
  settings/security with plain native <input type="checkbox"> toggles styled
  to match, avoiding another guess against the unverified Switch API.

  Run from the SAI2 repo root:
    powershell -ExecutionPolicy Bypass -File .\Fix-Switch-SettingsPages.ps1
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

function Backup-IfExists {
    param([string]$RelativePath)
    $fullPath = Join-Path $Root $RelativePath
    if (Test-Path $fullPath) {
        $backupPath = "$fullPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $fullPath $backupPath
        Write-Host "  backed up existing file -> $backupPath"
    }
}

Write-Host "== SAI2 :: Fix Switch onChange signature in settings pages ==" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Settings - Privacy
# ---------------------------------------------------------------------------

Backup-IfExists "apps/web/app/(learner)/settings/privacy/page.tsx"

Write-Utf8NoBom "apps/web/app/(learner)/settings/privacy/page.tsx" @'
"use client";

import { useState } from "react";
import { Download, ShieldAlert, Trash2 } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState } from "@saachi/ui";

export default function SettingsPrivacyPage() {
  const { data: session } = useSession();
  const [cookiePrefs, setCookiePrefs] = useState({ analytics: true, marketing: false });
  const [exportRequested, setExportRequested] = useState(false);

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your privacy settings." />;
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Privacy</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-3 text-[15px] font-semibold text-ink">Cookie preferences</h2>
        <div className="flex flex-col gap-3">
          <label className="flex items-center justify-between">
            <span className="text-[13px] text-ink-soft">Analytics cookies</span>
            <input
              type="checkbox"
              checked={cookiePrefs.analytics}
              onChange={(e) => setCookiePrefs((p) => ({ ...p, analytics: e.target.checked }))}
              aria-label="Toggle analytics cookies"
              className="h-4 w-4 accent-gold-dark"
            />
          </label>
          <label className="flex items-center justify-between">
            <span className="text-[13px] text-ink-soft">Marketing cookies</span>
            <input
              type="checkbox"
              checked={cookiePrefs.marketing}
              onChange={(e) => setCookiePrefs((p) => ({ ...p, marketing: e.target.checked }))}
              aria-label="Toggle marketing cookies"
              className="h-4 w-4 accent-gold-dark"
            />
          </label>
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-2 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <Download size={16} />
          Data export
        </h2>
        <p className="mb-4 text-[13px] text-ink-soft">
          Request a copy of the personal data associated with your account.
        </p>
        <Button variant="secondary" disabled={exportRequested} onClick={() => setExportRequested(true)}>
          {exportRequested ? "Export requested" : "Request data export"}
        </Button>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-error/30 bg-error-tint p-6">
        <h2 className="mb-2 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <ShieldAlert size={16} />
          Delete account
        </h2>
        <p className="mb-4 text-[13px] text-ink-soft">
          Permanently delete your account and all associated data. This cannot be undone.
        </p>
        <Button variant="danger">
          <Trash2 size={14} className="mr-1.5" />
          Request account deletion
        </Button>
      </div>
    </div>
  );
}
'@

# ---------------------------------------------------------------------------
# 2. Settings - Security
# ---------------------------------------------------------------------------

Backup-IfExists "apps/web/app/(learner)/settings/security/page.tsx"

Write-Utf8NoBom "apps/web/app/(learner)/settings/security/page.tsx" @'
"use client";

import { useState, type FormEvent } from "react";
import { ShieldCheck, Smartphone } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState, Input } from "@saachi/ui";

export default function SettingsSecurityPage() {
  const { data: session } = useSession();
  const [twoFactorEnabled, setTwoFactorEnabled] = useState(false);
  const [currentPassword, setCurrentPassword] = useState("");
  const [newPassword, setNewPassword] = useState("");

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to view and edit your security settings." />;
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    // NOTE: demo-only, no backend auth mutation wired up yet.
    setCurrentPassword("");
    setNewPassword("");
  }

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Security</h1>

      <div className="max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-4 flex items-center gap-2 text-[15px] font-semibold text-ink">
          <ShieldCheck size={16} />
          Change password
        </h2>
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <Input
            label="Current password"
            type="password"
            value={currentPassword}
            onChange={(e) => setCurrentPassword(e.target.value)}
          />
          <Input
            label="New password"
            type="password"
            value={newPassword}
            onChange={(e) => setNewPassword(e.target.value)}
          />
          <Button type="submit" className="self-start">
            Update password
          </Button>
        </form>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Smartphone size={16} className="text-ink-soft" />
            <div>
              <p className="text-[14px] font-semibold text-ink">Two-factor authentication</p>
              <p className="text-[13px] text-ink-soft">Add an extra layer of security to your account.</p>
            </div>
          </div>
          <input
            type="checkbox"
            checked={twoFactorEnabled}
            onChange={(e) => setTwoFactorEnabled(e.target.checked)}
            aria-label="Toggle two-factor authentication"
            className="h-4 w-4 accent-gold-dark"
          />
        </div>
      </div>

      <div className="mt-6 max-w-lg rounded-card border border-line bg-card p-6">
        <h2 className="mb-2 text-[15px] font-semibold text-ink">Active sessions</h2>
        <p className="text-[13px] text-ink-soft">This device - {session.email}</p>
      </div>
    </div>
  );
}
'@

Write-Host ""
Write-Host "== Done ==" -ForegroundColor Green
Write-Host "Fixed: apps/web/app/(learner)/settings/privacy/page.tsx"
Write-Host "Fixed: apps/web/app/(learner)/settings/security/page.tsx"
Write-Host "apps/admin was NOT touched."
Write-Host ""
Write-Host "Now run: pnpm --filter web build"