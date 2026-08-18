<#
  SAI2 - Fix build errors: avatar.tsx / dropdown-menu.tsx parse errors +
  missing dashboard imports (ActivityChartCard / BentoGrid / BentoCard)
  Run from repo root:
  D:\Rozmarrah-CUST\Saim Ashraf\Saachi AI\Working\Code\Saachi_ai_1\SAI2
  Usage: powershell -ExecutionPolicy Bypass -File .\fix-build-errors.ps1
#>

$ErrorActionPreference = "Stop"

$root = Get-Location
Write-Host "Running in: $root" -ForegroundColor Cyan

$uiDir         = Join-Path $root "apps\web\components\ui"
$avatarFile    = Join-Path $uiDir "avatar.tsx"
$dropdownFile  = Join-Path $uiDir "dropdown-menu.tsx"
$dashboardFile = Join-Path $root "apps\web\app\(learner)\dashboard\page.tsx"

foreach ($f in @($avatarFile, $dropdownFile, $dashboardFile)) {
    if (-not (Test-Path $f)) {
        Write-Host "ERROR: file not found: $f" -ForegroundColor Red
        exit 1
    }
}

# =========================================================================
# 1) Rewrite avatar.tsx - single-line generics for forwardRef
# =========================================================================
$avatarContent = @'
"use client";

import * as React from "react";
import * as AvatarPrimitive from "@radix-ui/react-avatar";
import { cn } from "@saachi/ui";

type AvatarRootProps = React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Root>;
type AvatarImageProps = React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Image>;
type AvatarFallbackProps = React.ComponentPropsWithoutRef<typeof AvatarPrimitive.Fallback>;

const Avatar = React.forwardRef<React.ElementRef<typeof AvatarPrimitive.Root>, AvatarRootProps>(function Avatar(
  { className, ...props },
  ref
) {
  return (
    <AvatarPrimitive.Root
      ref={ref}
      className={cn("relative flex h-10 w-10 shrink-0 overflow-hidden rounded-full", className)}
      {...props}
    />
  );
});
Avatar.displayName = AvatarPrimitive.Root.displayName;

const AvatarImage = React.forwardRef<React.ElementRef<typeof AvatarPrimitive.Image>, AvatarImageProps>(
  function AvatarImage({ className, ...props }, ref) {
    return <AvatarPrimitive.Image ref={ref} className={cn("aspect-square h-full w-full object-cover", className)} {...props} />;
  }
);
AvatarImage.displayName = AvatarPrimitive.Image.displayName;

const AvatarFallback = React.forwardRef<React.ElementRef<typeof AvatarPrimitive.Fallback>, AvatarFallbackProps>(
  function AvatarFallback({ className, ...props }, ref) {
    return (
      <AvatarPrimitive.Fallback
        ref={ref}
        className={cn(
          "flex h-full w-full items-center justify-center rounded-full bg-gold-tint text-[13px] font-semibold text-gold-dark",
          className
        )}
        {...props}
      />
    );
  }
);
AvatarFallback.displayName = AvatarPrimitive.Fallback.displayName;

export { Avatar, AvatarImage, AvatarFallback };
'@

Set-Content -Path $avatarFile -Value $avatarContent -Encoding UTF8
Write-Host "Rewrote: $avatarFile" -ForegroundColor Green

# =========================================================================
# 2) Rewrite dropdown-menu.tsx - single-line generics for forwardRef
# =========================================================================
$dropdownContent = @'
"use client";

import * as React from "react";
import * as DropdownMenuPrimitive from "@radix-ui/react-dropdown-menu";
import { Circle } from "lucide-react";
import { cn } from "@saachi/ui";

const DropdownMenu = DropdownMenuPrimitive.Root;
const DropdownMenuTrigger = DropdownMenuPrimitive.Trigger;
const DropdownMenuGroup = DropdownMenuPrimitive.Group;
const DropdownMenuPortal = DropdownMenuPrimitive.Portal;
const DropdownMenuRadioGroup = DropdownMenuPrimitive.RadioGroup;

type DropdownContentProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Content>;
type DropdownItemProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Item> & { inset?: boolean };
type DropdownRadioItemProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.RadioItem>;
type DropdownLabelProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Label> & { inset?: boolean };
type DropdownSeparatorProps = React.ComponentPropsWithoutRef<typeof DropdownMenuPrimitive.Separator>;

const DropdownMenuContent = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.Content>, DropdownContentProps>(
  function DropdownMenuContent({ className, sideOffset = 6, ...props }, ref) {
    return (
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
    );
  }
);
DropdownMenuContent.displayName = DropdownMenuPrimitive.Content.displayName;

const DropdownMenuItem = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.Item>, DropdownItemProps>(
  function DropdownMenuItem({ className, inset, ...props }, ref) {
    return (
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
    );
  }
);
DropdownMenuItem.displayName = DropdownMenuPrimitive.Item.displayName;

const DropdownMenuRadioItem = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.RadioItem>, DropdownRadioItemProps>(
  function DropdownMenuRadioItem({ className, children, ...props }, ref) {
    return (
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
    );
  }
);
DropdownMenuRadioItem.displayName = DropdownMenuPrimitive.RadioItem.displayName;

const DropdownMenuLabel = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.Label>, DropdownLabelProps>(
  function DropdownMenuLabel({ className, inset, ...props }, ref) {
    return (
      <DropdownMenuPrimitive.Label
        ref={ref}
        className={cn("px-2.5 py-1.5 text-[12px] font-semibold text-ink-soft", inset && "pl-8", className)}
        {...props}
      />
    );
  }
);
DropdownMenuLabel.displayName = DropdownMenuPrimitive.Label.displayName;

const DropdownMenuSeparator = React.forwardRef<React.ElementRef<typeof DropdownMenuPrimitive.Separator>, DropdownSeparatorProps>(
  function DropdownMenuSeparator({ className, ...props }, ref) {
    return <DropdownMenuPrimitive.Separator ref={ref} className={cn("-mx-1 my-1 h-px bg-line", className)} {...props} />;
  }
);
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

Set-Content -Path $dropdownFile -Value $dropdownContent -Encoding UTF8
Write-Host "Rewrote: $dropdownFile" -ForegroundColor Green

# =========================================================================
# 3) Fix dashboard/page.tsx - ensure imports for the new widgets exist
# =========================================================================
$dashboardContent = Get-Content -Path $dashboardFile -Raw

if ($dashboardContent -match [regex]::Escape('import { ActivityChartCard } from "@/components/ui/activity-chart-card";')) {
    Write-Host "dashboard/page.tsx: ActivityChartCard import already present - skipping." -ForegroundColor Yellow
} else {
    $anchor = 'import { LearnerOnboardingChecklist } from "@/components/ui/learner-onboarding-checklist";'
    if ($dashboardContent -notmatch [regex]::Escape($anchor)) {
        Write-Host "ERROR: could not find anchor import line in dashboard/page.tsx to insert missing imports." -ForegroundColor Red
        Write-Host "Manually add these lines near the top imports of dashboard/page.tsx:" -ForegroundColor Yellow
        Write-Host '  import { ActivityChartCard } from "@/components/ui/activity-chart-card";'
        Write-Host '  import { BentoCard, BentoGrid } from "@/components/ui/bento-grid";'
        Write-Host '  import { BookOpen as BentoBookOpen, Award as BentoAward, Users as BentoUsers, Heart as BentoHeart, MessageCircle as BentoMessageCircle, GraduationCap as BentoGraduationCap } from "lucide-react";'
    } else {
        $insert = $anchor + "`r`nimport { ActivityChartCard } from `"@/components/ui/activity-chart-card`";`r`nimport { BentoCard, BentoGrid } from `"@/components/ui/bento-grid`";`r`nimport {`r`n  BookOpen as BentoBookOpen,`r`n  Award as BentoAward,`r`n  Users as BentoUsers,`r`n  Heart as BentoHeart,`r`n  MessageCircle as BentoMessageCircle,`r`n  GraduationCap as BentoGraduationCap`r`n} from `"lucide-react`";"
        $dashboardContent = $dashboardContent.Replace($anchor, $insert)
        Set-Content -Path $dashboardFile -Value $dashboardContent -Encoding UTF8
        Write-Host "Patched: $dashboardFile (added missing widget imports)" -ForegroundColor Green
    }
}

# =========================================================================
# Summary
# =========================================================================
Write-Host ""
Write-Host "Done. Now run locally before pushing:" -ForegroundColor Cyan
Write-Host "  cd apps\web"
Write-Host "  npx tsc --noEmit"
Write-Host "  npx next build"
Write-Host ""
Write-Host "If tsc still reports 'Expression expected' on avatar.tsx or dropdown-menu.tsx," -ForegroundColor Yellow
Write-Host "open those two files and confirm every 'React.forwardRef<' actually has its '<' character -" -ForegroundColor Yellow
Write-Host "that's the exact character that went missing last time." -ForegroundColor Yellow