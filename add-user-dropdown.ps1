<#
  SAI2 - User Dropdown (Learner Topbar) - frontend-only, dummy/session data
  Run from: D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
  Usage:    powershell -ExecutionPolicy Bypass -File .\add-user-dropdown.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
Write-Host "Running in: $root" -ForegroundColor Cyan

$uiDir       = Join-Path $root "apps\web\components\ui"
$layoutFile  = Join-Path $root "apps\web\app\(learner)\layout.tsx"

# --- sanity checks -----------------------------------------------------
if (-not (Test-Path (Join-Path $root "apps\web"))) {
    Write-Host "ERROR: 'apps\web' not found. Run this script from the SAI2 repo root." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $layoutFile)) {
    Write-Host "ERROR: (learner)\layout.tsx not found at expected path:`n$layoutFile" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $uiDir | Out-Null

# =========================================================================
# 1) apps\web\components\ui\avatar.tsx
# =========================================================================
$avatarPath = Join-Path $uiDir "avatar.tsx"

$avatarContent = @'
"use client";

import * as React from "react";
import * as AvatarPrimitive from "@radix-ui/react-avatar";
import { cn } from "@saachi/ui";

const Avatar = React.forwardRef
  React.ElementRef<typeof AvatarPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Root>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Root
    ref={ref}
    className={cn("relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full", className)}
    {...props}
  />
));
Avatar.displayName = AvatarPrimitive.Root.displayName;

const AvatarImage = React.forwardRef
  React.ElementRef<typeof AvatarPrimitive.Image>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Image>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Image ref={ref} className={cn("aspect-square h-full w-full object-cover", className)} {...props} />
));
AvatarImage.displayName = AvatarPrimitive.Image.displayName;

const AvatarFallback = React.forwardRef
  React.ElementRef<typeof AvatarPrimitive.Fallback>,
  React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Fallback>
>(({ className, ...props }, ref) => (
  <AvatarPrimitive.Fallback
    ref={ref}
    className={cn(
      "flex h-full w-full items-center justify-center rounded-full bg-gold-tint text-[13px] font-semibold text-gold-dark",
      className
    )}
    {...props}
  />
));
AvatarFallback.displayName = AvatarPrimitive.Fallback.displayName;

export { Avatar, AvatarImage, AvatarFallback };
'@

Set-Content -Path $avatarPath -Value $avatarContent -Encoding UTF8
Write-Host "Created: $avatarPath" -ForegroundColor Green

# =========================================================================
# 2) apps\web\components\ui\badge.tsx
# =========================================================================
$badgePath = Join-Path $uiDir "badge.tsx"

$badgeContent = @'
import * as React from "react";
import { cn } from "@saachi/ui";

export interface BadgeProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: "default" | "teal" | "gold" | "muted" | "error";
}

const VARIANT_CLASSES: Record<NonNullable<BadgeProps["variant"]>, string> = {
  default: "border-line bg-paper-dim text-ink-soft",
  teal: "border-teal/30 bg-teal-light text-teal",
  gold: "border-gold-dark/30 bg-gold-tint text-gold-dark",
  muted: "border-line bg-paper-dim text-ink-soft",
  error: "border-error/30 bg-error-tint text-error"
};

function Badge({ className, variant = "default", ...props }: BadgeProps) {
  return (
    <div
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-0.5 text-[11px] font-semibold capitalize",
        VARIANT_CLASSES[variant],
        className
      )}
      {...props}
    />
  );
}

export { Badge };
'@

Set-Content -Path $badgePath -Value $badgeContent -Encoding UTF8
Write-Host "Created: $badgePath" -ForegroundColor Green

# =========================================================================
# 3) apps\web\components\ui\dropdown-menu.tsx
# =========================================================================
$dropdownMenuPath = Join-Path $uiDir "dropdown-menu.tsx"

$dropdownMenuContent = @'
"use client";

import * as React from "react";
import * as DropdownMenuPrimitive from "@radix-ui/react-dropdown-menu";
import { Check, Circle } from "lucide-react";
import { cn } from "@saachi/ui";

const DropdownMenu = DropdownMenuPrimitive.Root;
const DropdownMenuTrigger = DropdownMenuPrimitive.Trigger;
const DropdownMenuGroup = DropdownMenuPrimitive.Group;
const DropdownMenuPortal = DropdownMenuPrimitive.Portal;
const DropdownMenuRadioGroup = DropdownMenuPrimitive.RadioGroup;

const DropdownMenuContent = React.forwardRef
  React.ElementRef<typeof DropdownMenuPrimitive.Content>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Content>
>(({ className, sideOffset = 6, ...props }, ref) => (
  <DropdownMenuPrimitive.Portal>
    <DropdownMenuPrimitive.Content
      ref={ref}
      sideOffset={sideOffset}
      className={cn(
        "z-50 min-w-[8rem] overflow-hidden rounded-card border border-line bg-card p-1 shadow-lg",
        "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
        "data-[side=bottom]:slide-in-from-top-2 data-[side=top]:slide-in-from-bottom-2",
        className
      )}
      {...props}
    />
  </DropdownMenuPrimitive.Portal>
));
DropdownMenuContent.displayName = DropdownMenuPrimitive.Content.displayName;

const DropdownMenuItem = React.forwardRef
  React.ElementRef<typeof DropdownMenuPrimitive.Item>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Item> & { inset?: boolean }
>(({ className, inset, ...props }, ref) => (
  <DropdownMenuPrimitive.Item
    ref={ref}
    className={cn(
      "relative flex cursor-pointer select-none items-center gap-1.5 rounded-control px-2.5 py-2 text-[13.5px] font-medium text-ink outline-none transition-colors",
      "focus:bg-paper-dim data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
      inset && "pl-8",
      className
    )}
    {...props}
  />
));
DropdownMenuItem.displayName = DropdownMenuPrimitive.Item.displayName;

const DropdownMenuRadioItem = React.forwardRef
  React.ElementRef<typeof DropdownMenuPrimitive.RadioItem>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.RadioItem>
>(({ className, children, ...props }, ref) => (
  <DropdownMenuPrimitive.RadioItem
    ref={ref}
    className={cn(
      "relative flex cursor-pointer select-none items-center gap-1.5 rounded-control py-2 pl-8 pr-2.5 text-[13.5px] font-medium text-ink outline-none transition-colors",
      "focus:bg-paper-dim data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
      className
    )}
    {...props}
  >
    <span className="absolute left-2.5 flex h-3.5 w-3.5 items-center justify-center">
      <DropdownMenuPrimitive.ItemIndicator>
        <Circle className="h-2 w-2 fill-current text-gold-dark" />
      </DropdownMenuPrimitive.ItemIndicator>
    </span>
    {children}
  </DropdownMenuPrimitive.RadioItem>
));
DropdownMenuRadioItem.displayName = DropdownMenuPrimitive.RadioItem.displayName;

const DropdownMenuLabel = React.forwardRef
  React.ElementRef<typeof DropdownMenuPrimitive.Label>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Label> & { inset?: boolean }
>(({ className, inset, ...props }, ref) => (
  <DropdownMenuPrimitive.Label
    ref={ref}
    className={cn("px-2.5 py-1.5 text-[12px] font-semibold text-ink-soft", inset && "pl-8", className)}
    {...props}
  />
));
DropdownMenuLabel.displayName = DropdownMenuPrimitive.Label.displayName;

const DropdownMenuSeparator = React.forwardRef
  React.ElementRef<typeof DropdownMenuPrimitive.Separator>,
  React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Separator>
>(({ className, ...props }, ref) => (
  <DropdownMenuPrimitive.Separator ref={ref} className={cn("-mx-1 my-1 h-px bg-line", className)} {...props} />
));
DropdownMenuSeparator.displayName = DropdownMenuPrimitive.Separator.displayName;

export {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuRadioItem,
  DropdownMenuRadioGroup,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuGroup,
  DropdownMenuPortal
};
'@

Set-Content -Path $dropdownMenuPath -Value $dropdownMenuContent -Encoding UTF8
Write-Host "Created: $dropdownMenuPath" -ForegroundColor Green

# =========================================================================
# 4) apps\web\components\ui\user-dropdown.tsx
# =========================================================================
$userDropdownPath = Join-Path $uiDir "user-dropdown.tsx"

$userDropdownContent = @'
"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import {
  UserCircle,
  Settings as SettingsIcon,
  Bell,
  GraduationCap,
  LogOut,
  Smile,
  Moon
} from "lucide-react";
import { useSession, useLogout } from "@saachi/api-client";
import { Avatar, AvatarImage, AvatarFallback } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger
} from "@/components/ui/dropdown-menu";

// NOTE: demo-only status toggle. Presence status has no backend concept yet -
// it's local UI state only and is not persisted or sent anywhere.

const STATUS_OPTIONS = [
  { value: "online", icon: Smile, label: "Active" },
  { value: "offline", icon: Moon, label: "Appear offline" }
];

function getInitials(name?: string) {
  if (!name) return "?";
  const parts = name.trim().split(/\s+/);
  const initials = parts.slice(0, 2).map((p) => p[0]?.toUpperCase() ?? "");
  return initials.join("") || "?";
}

export function UserDropdown() {
  const router = useRouter();
  const { data: session } = useSession();
  const logout = useLogout();
  const [status, setStatus] = useState("online");

  if (!session) return null;

  const initials = getInitials(session.fullName);

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button type="button" aria-label="Open account menu" className="rounded-full outline-none">
          <Avatar className="cursor-pointer border border-line">
            <AvatarImage src={session.avatarUrl} alt={session.fullName} />
            <AvatarFallback>{initials}</AvatarFallback>
          </Avatar>
        </button>
      </DropdownMenuTrigger>

      <DropdownMenuContent className="w-[280px]" align="end">
        <div className="flex items-center gap-2.5 px-2.5 py-2">
          <Avatar className="border border-line">
            <AvatarImage src={session.avatarUrl} alt={session.fullName} />
            <AvatarFallback>{initials}</AvatarFallback>
          </Avatar>
          <div className="min-w-0 flex-1">
            <p className="truncate text-[13.5px] font-semibold text-ink">{session.fullName}</p>
            <p className="truncate text-[12px] text-ink-soft">{session.email}</p>
          </div>
          <Badge variant={status === "online" ? "teal" : "muted"}>
            {status === "online" ? "Active" : "Offline"}
          </Badge>
        </div>

        <DropdownMenuSeparator />

        <DropdownMenuGroup>
          <DropdownMenuRadioGroup value={status} onValueChange={setStatus}>
            {STATUS_OPTIONS.map((opt) => {
              const Icon = opt.icon;
              return (
                <DropdownMenuRadioItem key={opt.value} value={opt.value}>
                  <Icon size={15} className="text-ink-soft" />
                  {opt.label}
                </DropdownMenuRadioItem>
              );
            })}
          </DropdownMenuRadioGroup>
        </DropdownMenuGroup>

        <DropdownMenuSeparator />

        <DropdownMenuGroup>
          <DropdownMenuItem onClick={() => router.push("/settings")}>
            <UserCircle size={16} className="text-ink-soft" />
            Your profile
          </DropdownMenuItem>
          <DropdownMenuItem onClick={() => router.push("/notifications")}>
            <Bell size={16} className="text-ink-soft" />
            Notifications
          </DropdownMenuItem>
          <DropdownMenuItem onClick={() => router.push("/settings")}>
            <SettingsIcon size={16} className="text-ink-soft" />
            Settings
          </DropdownMenuItem>
          <DropdownMenuItem onClick={() => router.push("/become-instructor")}>
            <GraduationCap size={16} className="text-ink-soft" />
            Become an instructor
          </DropdownMenuItem>
        </DropdownMenuGroup>

        <DropdownMenuSeparator />

        <DropdownMenuGroup>
          <DropdownMenuItem onClick={() => logout.mutate()} className="text-error">
            <LogOut size={16} />
            Log out
          </DropdownMenuItem>
        </DropdownMenuGroup>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

export default UserDropdown;
'@

Set-Content -Path $userDropdownPath -Value $userDropdownContent -Encoding UTF8
Write-Host "Created: $userDropdownPath" -ForegroundColor Green

# =========================================================================
# 5) Patch apps\web\app\(learner)\layout.tsx -> add topbar with UserDropdown
# =========================================================================
$layoutContent = Get-Content -Path $layoutFile -Raw

$oldImportBlock = 'import { cn } from "@saachi/ui";'
$newImportBlock = 'import { cn } from "@saachi/ui";
import { UserDropdown } from "@/components/ui/user-dropdown";'

$oldReturnOpen = 'return (
    <div className="mx-auto grid max-w-7xl grid-cols-1 gap-8 px-4 py-10 md:grid-cols-[220px_1fr] md:px-8">
      <aside className="h-fit rounded-card border border-line bg-card p-3 md:sticky md:top-24">'

$newReturnOpen = 'return (
    <div className="mx-auto max-w-7xl px-4 py-6 md:px-8">
      <header className="mb-6 flex items-center justify-between">
        <span className="font-display text-[15px] font-semibold text-ink">Saachi AI</span>
        <UserDropdown />
      </header>

      <div className="grid grid-cols-1 gap-8 md:grid-cols-[220px_1fr]">
      <aside className="h-fit rounded-card border border-line bg-card p-3 md:sticky md:top-24">'

$oldReturnClose = '      <div>{children}</div>
    </div>
  );
}'

$newReturnClose = '      <div>{children}</div>
      </div>
    </div>
  );
}'

if ($layoutContent -notmatch [regex]::Escape($oldImportBlock)) {
    Write-Host "WARNING: layout.tsx import block did not match - skipping import patch." -ForegroundColor Yellow
} else {
    $layoutContent = $layoutContent.Replace($oldImportBlock, $newImportBlock)
}

if ($layoutContent -notmatch [regex]::Escape($oldReturnOpen)) {
    Write-Host "WARNING: layout.tsx return-open block did not match - skipping structural patch." -ForegroundColor Yellow
    Write-Host "You'll need to manually wrap the sidebar+content grid and add <UserDropdown /> in a header." -ForegroundColor Yellow
} else {
    $layoutContent = $layoutContent.Replace($oldReturnOpen, $newReturnOpen)

    if ($layoutContent -notmatch [regex]::Escape($oldReturnClose)) {
        Write-Host "WARNING: layout.tsx return-close block did not match - grid div may not be closed properly." -ForegroundColor Yellow
        Write-Host "Manually add a closing </div> before the final </div> to close the new grid wrapper." -ForegroundColor Yellow
    } else {
        $layoutContent = $layoutContent.Replace($oldReturnClose, $newReturnClose)
    }
}

Set-Content -Path $layoutFile -Value $layoutContent -Encoding UTF8
Write-Host "Patched: $layoutFile (added topbar with UserDropdown)" -ForegroundColor Green

# =========================================================================
# Summary
# =========================================================================
Write-Host ""
Write-Host "Done. Summary:" -ForegroundColor Cyan
Write-Host " - apps\web\components\ui\avatar.tsx (new)"
Write-Host " - apps\web\components\ui\badge.tsx (new)"
Write-Host " - apps\web\components\ui\dropdown-menu.tsx (new)"
Write-Host " - apps\web\components\ui\user-dropdown.tsx (new)"
Write-Host " - apps\web\app\(learner)\layout.tsx (patched - topbar added)"
Write-Host ""
Write-Host "Install these npm deps if not already present:" -ForegroundColor Yellow
Write-Host "  npm install @radix-ui/react-dropdown-menu @radix-ui/react-avatar"
Write-Host ""
Write-Host "Frontend-only. Status toggle is local UI state, no backend call." -ForegroundColor Cyan
Write-Host "Uses existing useSession()/useLogout() hooks - no dummy user data." -ForegroundColor Cyan