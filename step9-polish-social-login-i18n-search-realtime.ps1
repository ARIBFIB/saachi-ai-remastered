# step9-polish-social-login-i18n-search-realtime.ps1
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

function Patch-File {
    param([string]$Path, [string]$OldStr, [string]$NewStr, [string]$Label)
    $fullPath = Join-Path -Path (Get-Location).Path -ChildPath $Path
    if (-not (Test-Path $fullPath)) {
        Write-Host "  SKIP (file not found): $fullPath" -ForegroundColor Yellow
        return
    }
    $content = Get-Content -Path $fullPath -Raw
    if ($content.Contains($OldStr)) {
        $updated = $content.Replace($OldStr, $NewStr)
        $enc = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($fullPath, $updated, $enc)
        Write-Host "  patched ($Label): $fullPath"
    } else {
        Write-Host "  WARNING: pattern for '$Label' not found in $fullPath - skipped." -ForegroundColor Yellow
    }
}

Write-Host "Step 9: social login buttons + locale switcher + navbar search + realtime notification stub..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Social login buttons component (shared)
# ---------------------------------------------------------------------------
$socialLoginButtons = @'
"use client";

import { Button } from "./Button";

export type SocialLoginButtonsProps = {
  onGoogle?: () => void;
  onMicrosoft?: () => void;
  label?: string;
};

export function SocialLoginButtons({ onGoogle, onMicrosoft, label = "Or continue with" }: SocialLoginButtonsProps) {
  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center gap-3">
        <div className="h-px flex-1 bg-line" />
        <span className="text-[12px] text-ink-soft">{label}</span>
        <div className="h-px flex-1 bg-line" />
      </div>
      <div className="grid grid-cols-2 gap-3">
        <Button type="button" variant="secondary" onClick={onGoogle}>
          <svg width="16" height="16" viewBox="0 0 24 24" aria-hidden="true">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 0 1-2.2 3.32v2.77h3.55c2.08-1.92 3.28-4.74 3.28-8.1z" />
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.55-2.77c-.98.66-2.24 1.06-3.73 1.06-2.87 0-5.3-1.94-6.16-4.53H2.18v2.85A11 11 0 0 0 12 23z" />
            <path fill="#FBBC05" d="M5.84 14.1a6.6 6.6 0 0 1 0-4.2V7.05H2.18a11 11 0 0 0 0 9.9l3.66-2.85z" />
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1a11 11 0 0 0-9.82 6.05l3.66 2.85C6.7 7.32 9.13 5.38 12 5.38z" />
          </svg>
          Google
        </Button>
        <Button type="button" variant="secondary" onClick={onMicrosoft}>
          <svg width="16" height="16" viewBox="0 0 24 24" aria-hidden="true">
            <rect x="2" y="2" width="9" height="9" fill="#F25022" />
            <rect x="13" y="2" width="9" height="9" fill="#7FBA00" />
            <rect x="2" y="13" width="9" height="9" fill="#00A4EF" />
            <rect x="13" y="13" width="9" height="9" fill="#FFB900" />
          </svg>
          Microsoft
        </Button>
      </div>
    </div>
  );
}
'@
Write-Utf8NoBom -Path "packages\ui\src\components\SocialLoginButtons.tsx" -Content $socialLoginButtons

Patch-File -Path "packages\ui\src\index.ts" `
  -OldStr 'export * from "./components/ReviewCard";' `
  -NewStr @'
export * from "./components/ReviewCard";
export * from "./components/SocialLoginButtons";
'@ `
  -Label "export SocialLoginButtons"

# ---------------------------------------------------------------------------
# 2. Wire social buttons into Login page
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(auth)\login\page.tsx" `
  -OldStr 'import { Button, Card, Input } from "@saachi/ui";' `
  -NewStr 'import { Button, Card, Input, SocialLoginButtons } from "@saachi/ui";' `
  -Label "import SocialLoginButtons in login"

Patch-File -Path "apps\web\app\(auth)\login\page.tsx" `
  -OldStr '        <Button type="submit" size="lg" disabled={isSubmitting || loginMutation.isPending}>
          {isSubmitting || loginMutation.isPending ? "Logging inâ€¦" : "Log In"}
        </Button>
      </form>' `
  -NewStr @'
        <Button type="submit" size="lg" disabled={isSubmitting || loginMutation.isPending}>
          {isSubmitting || loginMutation.isPending ? "Logging in..." : "Log In"}
        </Button>
      </form>

      <div className="mt-6">
        <SocialLoginButtons
          onGoogle={() => onSubmit({ email: "demo.google@saachi.ai", password: "demo-oauth" })}
          onMicrosoft={() => onSubmit({ email: "demo.microsoft@saachi.ai", password: "demo-oauth" })}
        />
      </div>
'@ `
  -Label "add social buttons to login form"

# ---------------------------------------------------------------------------
# 3. Wire social buttons into Register page
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(auth)\register\page.tsx" `
  -OldStr 'import { Button, Card, Input } from "@saachi/ui";' `
  -NewStr 'import { Button, Card, Input, SocialLoginButtons } from "@saachi/ui";' `
  -Label "import SocialLoginButtons in register"

Patch-File -Path "apps\web\app\(auth)\register\page.tsx" `
  -OldStr '        <Button type="submit" size="lg" disabled={isSubmitting || registerMutation.isPending}>
          {isSubmitting || registerMutation.isPending ? "Creating accountâ€¦" : "Create Account"}
        </Button>
      </form>' `
  -NewStr @'
        <Button type="submit" size="lg" disabled={isSubmitting || registerMutation.isPending}>
          {isSubmitting || registerMutation.isPending ? "Creating account..." : "Create Account"}
        </Button>
      </form>

      <div className="mt-6">
        <SocialLoginButtons
          onGoogle={() =>
            onSubmit({ fullName: "Google User", email: "demo.google@saachi.ai", password: "demo-oauth123", confirmPassword: "demo-oauth123", role: "learner" })
          }
          onMicrosoft={() =>
            onSubmit({ fullName: "Microsoft User", email: "demo.microsoft@saachi.ai", password: "demo-oauth123", confirmPassword: "demo-oauth123", role: "learner" })
          }
        />
      </div>
'@ `
  -Label "add social buttons to register form"

# ---------------------------------------------------------------------------
# 4. useLocaleStore - simple locale toggle (en / ur), structurally reserves i18n
# ---------------------------------------------------------------------------
$localeStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type Locale = "en" | "ur";

type LocaleState = {
  locale: Locale;
  setLocale: (locale: Locale) => void;
};

// NOTE: this is a structural placeholder for the next-intl locale routing
// described in Doc 2, Section 21. Full /en/... /ur/... route-based i18n with
// translation catalogs is a larger migration; this store lets the UI expose
// a working language switcher now, wired to real routing later.
export const useLocaleStore = create<LocaleState>()(
  persist(
    (set) => ({
      locale: "en",
      setLocale: (locale) => set({ locale })
    }),
    { name: "saachi-locale" }
  )
);
'@
Write-Utf8NoBom -Path "packages\store\src\useLocaleStore.ts" -Content $localeStore

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
export * from "./useLocaleStore";
'@
Write-Utf8NoBom -Path "packages\store\src\index.ts" -Content $storeIndexUpdated

# ---------------------------------------------------------------------------
# 5. LocaleSwitcher component
# ---------------------------------------------------------------------------
$localeSwitcher = @'
"use client";

import { Languages } from "lucide-react";
import { useLocaleStore } from "@saachi/store";

export function LocaleSwitcher() {
  const { locale, setLocale } = useLocaleStore();

  return (
    <button
      type="button"
      onClick={() => setLocale(locale === "en" ? "ur" : "en")}
      className="flex items-center gap-1.5 rounded-full border border-line-strong px-3 py-1.5 text-[12px] font-medium text-ink-soft transition-colors duration-150 ease-out hover:border-ink hover:text-ink"
      aria-label="Switch language"
      title={locale === "en" ? "Switch to Urdu" : "Switch to English"}
    >
      <Languages size={13} />
      {locale === "en" ? "EN" : "UR"}
    </button>
  );
}
'@
Write-Utf8NoBom -Path "apps\web\app\(marketing)\_components\LocaleSwitcher.tsx" -Content $localeSwitcher

# ---------------------------------------------------------------------------
# 6. Navbar - wire search input (routes to /search?q=...) + locale switcher
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(marketing)\_components\Navbar.tsx" `
  -OldStr 'import { Menu, X, ShoppingCart } from "lucide-react";
import { Button } from "@saachi/ui";
import { useSession, useLogout } from "@saachi/api-client";' `
  -NewStr @'
import { Menu, X, ShoppingCart, Search } from "lucide-react";
import { useState as useReactState } from "react";
import { Button } from "@saachi/ui";
import { useSession, useLogout } from "@saachi/api-client";
import { LocaleSwitcher } from "./LocaleSwitcher";
'@ `
  -Label "import search icon + LocaleSwitcher in Navbar"

Patch-File -Path "apps\web\app\(marketing)\_components\Navbar.tsx" `
  -OldStr '        <div className="hidden items-center gap-3 md:flex">
          {session ? (
            <>
              <Link
                href="/cart"' `
  -NewStr @'
        <div className="hidden items-center gap-3 md:flex">
          <Link
            href="/search"
            aria-label="Search"
            className="flex h-10 w-10 items-center justify-center rounded-full text-ink-soft transition-colors duration-150 ease-out hover:bg-paper-dim hover:text-ink"
          >
            <Search size={18} />
          </Link>
          <LocaleSwitcher />
          {session ? (
            <>
              <Link
                href="/cart"
'@ `
  -Label "add search icon + locale switcher to Navbar"

# ---------------------------------------------------------------------------
# 7. useRealtimeNotifications hook - simulated WebSocket delivery (Doc 2 8.3)
# ---------------------------------------------------------------------------
$realtimeHook = @'
"use client";

import { useEffect } from "react";
import { useNotificationStore } from "@saachi/store";

// NOTE: demo-only simulation. Doc 2 Section 8.3 specifies a real WebSocket
// connection to the backend Gateway for live notification delivery, Q&A
// message indicators, and payout status changes. This hook fakes that
// channel client-side (setInterval) so the UI/UX for real-time delivery can
// be reviewed before the backend Gateway exists. Replace the interval body
// with a real socket.on("notification", ...) handler once available.
const DEMO_MESSAGES = [
  { title: "New course recommendation", body: "Based on your activity, you might like AI Automation & Workflow Tools.", type: "system" as const },
  { title: "Instructor replied", body: "Your question in the course Q&A received a new reply.", type: "community" as const },
  { title: "Payment reminder", body: "A saved cart item has a limited-time coupon expiring soon.", type: "payment" as const }
];

export function useRealtimeNotifications(enabled: boolean) {
  useEffect(() => {
    if (!enabled) return;

    const interval = setInterval(() => {
      const msg = DEMO_MESSAGES[Math.floor(Math.random() * DEMO_MESSAGES.length)];
      const store = useNotificationStore.getState();
      const alreadyExists = store.items.some((n) => n.title === msg.title && !n.read);
      if (alreadyExists) return;

      useNotificationStore.setState({
        items: [
          {
            id: `ntf_rt_${Date.now()}`,
            title: msg.title,
            body: msg.body,
            type: msg.type,
            createdAt: new Date().toISOString(),
            read: false
          },
          ...store.items
        ]
      });
    }, 45000);

    return () => clearInterval(interval);
  }, [enabled]);
}
'@
Write-Utf8NoBom -Path "apps\web\hooks\useRealtimeNotifications.ts" -Content $realtimeHook

# ---------------------------------------------------------------------------
# 8. Wire the realtime hook + a notification bell badge into LearnerShell
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(learner)\_components\LearnerShell.tsx" `
  -OldStr 'import { useSession, useLogout } from "@saachi/api-client";
import { useCartStore } from "@saachi/store";' `
  -NewStr @'
import { useSession, useLogout } from "@saachi/api-client";
import { useCartStore, useNotificationStore } from "@saachi/store";
import { useRealtimeNotifications } from "../../../hooks/useRealtimeNotifications";
'@ `
  -Label "import realtime hook + notification store in LearnerShell"

Patch-File -Path "apps\web\app\(learner)\_components\LearnerShell.tsx" `
  -OldStr '  const cartCount = useCartStore((s) => s.items.length);
  const [mobileOpen, setMobileOpen] = useState(false);' `
  -NewStr @'
  const cartCount = useCartStore((s) => s.items.length);
  const unreadCount = useNotificationStore((s) => s.items.filter((n) => !n.read).length);
  const [mobileOpen, setMobileOpen] = useState(false);

  useRealtimeNotifications(true);
'@ `
  -Label "wire realtime notifications + unread count in LearnerShell"

Patch-File -Path "apps\web\app\(learner)\_components\LearnerShell.tsx" `
  -OldStr '              <item.icon size={18} />
              {item.label}
              {item.href === "/cart" && cartCount > 0 && (
                <span className="ml-auto flex h-5 min-w-[20px] items-center justify-center rounded-full bg-gold px-1.5 text-[11px] font-bold text-ink">
                  {cartCount}
                </span>
              )}
            </Link>' `
  -NewStr @'
              <item.icon size={18} />
              {item.label}
              {item.href === "/cart" && cartCount > 0 && (
                <span className="ml-auto flex h-5 min-w-[20px] items-center justify-center rounded-full bg-gold px-1.5 text-[11px] font-bold text-ink">
                  {cartCount}
                </span>
              )}
              {item.href === "/notifications" && unreadCount > 0 && (
                <span className="ml-auto flex h-5 min-w-[20px] items-center justify-center rounded-full bg-error px-1.5 text-[11px] font-bold text-white">
                  {unreadCount}
                </span>
              )}
            </Link>
'@ `
  -Label "notification unread badge in sidebar nav"

Write-Host ""
Write-Host "Step 9 done." -ForegroundColor Green
Write-Host "Run: pnpm dev:web" -ForegroundColor Green
Write-Host "Test: /login and /register (social buttons - Google/Microsoft demo-login instantly), Navbar search icon -> /search, EN/UR locale toggle in Navbar, wait ~45s while logged in to see a live notification badge tick up in the learner sidebar" -ForegroundColor Green