# step9-fix-and-continue.ps1
# Run from: SAI2 root folder — completes what step9 didn't finish

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
        Write-Host "  WARNING: pattern for '$Label' not found - skipped." -ForegroundColor Yellow
    }
}

Write-Host "Fixing + continuing Step 9..." -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# 1. Login form - add social buttons (safe single-line OldStr, no mojibake)
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(auth)\login\page.tsx" `
  -OldStr '</form>

      <div className="mt-5 text-center text-[14px] text-ink-soft">' `
  -NewStr @'
</form>

      <div className="mt-6">
        <SocialLoginButtons
          onGoogle={() => onSubmit({ email: "demo.google@saachi.ai", password: "demo-oauth" })}
          onMicrosoft={() => onSubmit({ email: "demo.microsoft@saachi.ai", password: "demo-oauth" })}
        />
      </div>

      <div className="mt-5 text-center text-[14px] text-ink-soft">
'@ `
  -Label "add social buttons to login form"

# ---------------------------------------------------------------------------
# 2. Register page - import SocialLoginButtons
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(auth)\register\page.tsx" `
  -OldStr 'import { Button, Card, Input } from "@saachi/ui";' `
  -NewStr 'import { Button, Card, Input, SocialLoginButtons } from "@saachi/ui";' `
  -Label "import SocialLoginButtons in register"

# ---------------------------------------------------------------------------
# 3. Register form - add social buttons
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(auth)\register\page.tsx" `
  -OldStr '</form>

      <div className="mt-5 text-center text-[14px] text-ink-soft">' `
  -NewStr @'
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

      <div className="mt-5 text-center text-[14px] text-ink-soft">
'@ `
  -Label "add social buttons to register form"

# ---------------------------------------------------------------------------
# 4. useLocaleStore
# ---------------------------------------------------------------------------
$localeStore = @'
import { create } from "zustand";
import { persist } from "zustand/middleware";

export type Locale = "en" | "ur";

type LocaleState = {
  locale: Locale;
  setLocale: (locale: Locale) => void;
};

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
# 5. LocaleSwitcher
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
# 6. Navbar - search icon + locale switcher
# ---------------------------------------------------------------------------
Patch-File -Path "apps\web\app\(marketing)\_components\Navbar.tsx" `
  -OldStr 'import { Menu, X, ShoppingCart } from "lucide-react";
import { Button } from "@saachi/ui";
import { useSession, useLogout } from "@saachi/api-client";' `
  -NewStr @'
import { Menu, X, ShoppingCart, Search } from "lucide-react";
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
# 7. useRealtimeNotifications hook
# ---------------------------------------------------------------------------
$realtimeHook = @'
"use client";

import { useEffect } from "react";
import { useNotificationStore } from "@saachi/store";

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
# 8. Wire realtime hook + unread badge into LearnerShell
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
  -OldStr '              {item.href === "/cart" && cartCount > 0 && (
                <span className="ml-auto flex h-5 min-w-[20px] items-center justify-center rounded-full bg-gold px-1.5 text-[11px] font-bold text-ink">
                  {cartCount}
                </span>
              )}
            </Link>' `
  -NewStr @'
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
Write-Host "Fix + continuation done." -ForegroundColor Green
Write-Host "Run: pnpm dev:web" -ForegroundColor Green