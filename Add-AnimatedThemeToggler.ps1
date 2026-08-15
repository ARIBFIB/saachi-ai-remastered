# Add-AnimatedThemeToggler.ps1
# Run this from: SAI2 root

$ErrorActionPreference = "Stop"

$webRoot     = Join-Path $PSScriptRoot "apps\web"
$uiDir       = Join-Path $webRoot "components\ui"
$siteHeader  = Join-Path $webRoot "app\_components\SiteHeader.tsx"
$instrShell  = Join-Path $webRoot "app\(instructor)\_components\InstructorShell.tsx"

if (-not (Test-Path $webRoot)) {
    Write-Host "ERROR: apps\web not found. Run this from SAI2 root." -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Force -Path $uiDir | Out-Null

# ------------------------------------------------------------------
# 1. animated-theme-toggler.tsx
# ------------------------------------------------------------------
$togglerLines = @(
'"use client";'
''
'import { useCallback, useRef } from "react";'
'import { flushSync } from "react-dom";'
'import { Moon, Sun } from "lucide-react";'
'import { motion, AnimatePresence } from "framer-motion";'
'import { useThemeStore } from "@saachi/store";'
'import { cn } from "@/lib/utils";'
''
'type AnimatedThemeTogglerProps = {'
'  className?: string;'
'};'
''
'export function AnimatedThemeToggler({ className }: AnimatedThemeTogglerProps) {'
'  const buttonRef = useRef<HTMLButtonElement>(null);'
'  const theme = useThemeStore((s) => s.theme);'
'  const setTheme = useThemeStore((s) => s.setTheme);'
'  const isDark = theme === "dark";'
''
'  const onToggle = useCallback(async () => {'
'    if (!buttonRef.current) return;'
''
'    const next = isDark ? "light" : "dark";'
''
'    const supportsViewTransition ='
'      typeof document !== "undefined" && "startViewTransition" in document;'
''
'    if (!supportsViewTransition) {'
'      setTheme(next);'
'      return;'
'    }'
''
'    // eslint-disable-next-line @typescript-eslint/no-explicit-any'
'    const transition = (document as any).startViewTransition(() => {'
'      flushSync(() => {'
'        setTheme(next);'
'      });'
'    });'
''
'    await transition.ready;'
''
'    const { left, top, width, height } = buttonRef.current.getBoundingClientRect();'
'    const centerX = left + width / 2;'
'    const centerY = top + height / 2;'
'    const maxDistance = Math.hypot('
'      Math.max(centerX, window.innerWidth - centerX),'
'      Math.max(centerY, window.innerHeight - centerY)'
'    );'
''
'    document.documentElement.animate('
'      {'
'        clipPath: ['
'          `circle(0px at ${centerX}px ${centerY}px)`,'
'          `circle(${maxDistance}px at ${centerX}px ${centerY}px)`'
'        ]'
'      },'
'      {'
'        duration: 700,'
'        easing: "ease-in-out",'
'        pseudoElement: "::view-transition-new(root)"'
'      }'
'    );'
'  }, [isDark, setTheme]);'
''
'  return ('
'    <button'
'      ref={buttonRef}'
'      onClick={onToggle}'
'      aria-label={isDark ? "Switch to light mode" : "Switch to dark mode"}'
'      type="button"'
'      className={cn('
'        "flex h-9 w-9 shrink-0 items-center justify-center rounded-control border border-line text-ink outline-none transition-colors duration-150 ease-out hover:bg-paper-dim focus:outline-none focus:ring-0",'
'        className'
'      )}'
'    >'
'      <AnimatePresence mode="wait" initial={false}>'
'        {isDark ? ('
'          <motion.span'
'            key="sun-icon"'
'            initial={{ opacity: 0, scale: 0.55, rotate: 25 }}'
'            animate={{ opacity: 1, scale: 1, rotate: 0 }}'
'            exit={{ opacity: 0 }}'
'            transition={{ duration: 0.33 }}'
'            className="flex items-center justify-center"'
'          >'
'            <Sun size={16} strokeWidth={1.75} />'
'          </motion.span>'
'        ) : ('
'          <motion.span'
'            key="moon-icon"'
'            initial={{ opacity: 0, scale: 0.55, rotate: -25 }}'
'            animate={{ opacity: 1, scale: 1, rotate: 0 }}'
'            exit={{ opacity: 0 }}'
'            transition={{ duration: 0.33 }}'
'            className="flex items-center justify-center"'
'          >'
'            <Moon size={16} strokeWidth={1.75} />'
'          </motion.span>'
'        )}'
'      </AnimatePresence>'
'    </button>'
'  );'
'}'
)

$togglerPath = Join-Path $uiDir "animated-theme-toggler.tsx"
Set-Content -Path $togglerPath -Value $togglerLines -Encoding UTF8
Write-Host "Created: $togglerPath" -ForegroundColor Green

# ------------------------------------------------------------------
# 2. Patch SiteHeader.tsx
# ------------------------------------------------------------------
if (Test-Path $siteHeader) {
    $content = Get-Content -Path $siteHeader -Raw

    if ($content -match "AnimatedThemeToggler") {
        Write-Host "SiteHeader.tsx already uses AnimatedThemeToggler, skipping." -ForegroundColor Yellow
    } else {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        Copy-Item -Path $siteHeader -Destination "$siteHeader.bak-$timestamp" -Force
        Write-Host "Backed up: $siteHeader.bak-$timestamp" -ForegroundColor Yellow

        # Remove ThemeToggle from the @saachi/ui import line
        $content = $content -replace 'import \{ Button, ThemeToggle \} from "@saachi/ui";', 'import { Button } from "@saachi/ui";'

        # Add new import after the @saachi/store import line
        $storeImportPattern = 'import \{ useCartStore, useWishlistStore \} from "@saachi/store";'
        if ($content -match $storeImportPattern) {
            $content = [regex]::Replace(
                $content,
                $storeImportPattern,
                { param($m) $m.Value + "`r`nimport { AnimatedThemeToggler } from `"@/components/ui/animated-theme-toggler`";" },
                1
            )
        } else {
            Write-Host "WARNING: Could not find store import anchor in SiteHeader.tsx, appending import at top instead." -ForegroundColor Yellow
            $content = "import { AnimatedThemeToggler } from `"@/components/ui/animated-theme-toggler`";`r`n" + $content
        }

        # Replace usage
        $content = $content -replace '<ThemeToggle\s*/>', '<AnimatedThemeToggler />'

        Set-Content -Path $siteHeader -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Patched: $siteHeader" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: SiteHeader.tsx not found at expected path, skipped." -ForegroundColor Yellow
}

# ------------------------------------------------------------------
# 3. Patch InstructorShell.tsx
# ------------------------------------------------------------------
if (Test-Path $instrShell) {
    $content = Get-Content -Path $instrShell -Raw

    if ($content -match "AnimatedThemeToggler") {
        Write-Host "InstructorShell.tsx already uses AnimatedThemeToggler, skipping." -ForegroundColor Yellow
    } else {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        Copy-Item -Path $instrShell -Destination "$instrShell.bak-$timestamp" -Force
        Write-Host "Backed up: $instrShell.bak-$timestamp" -ForegroundColor Yellow

        $content = $content -replace 'import \{ ThemeToggle \} from "@saachi/ui";', 'import { AnimatedThemeToggler } from "@/components/ui/animated-theme-toggler";'
        $content = $content -replace '<ThemeToggle\s*/>', '<AnimatedThemeToggler />'

        Set-Content -Path $instrShell -Value $content -Encoding UTF8 -NoNewline
        Write-Host "Patched: $instrShell" -ForegroundColor Green
    }
} else {
    Write-Host "WARNING: InstructorShell.tsx not found at expected path, skipped." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Animated theme toggler wired into your existing useThemeStore (light/dark) instead of a separate class/localStorage mechanism." -ForegroundColor Cyan
Write-Host "Now run: cd apps\web; pnpm run build" -ForegroundColor DarkGray