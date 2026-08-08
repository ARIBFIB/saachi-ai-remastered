<#
  Fix-SwitchAndButton-Final.ps1
  - Rewrites Switch.tsx using inline CSS-var styles (bypasses any Tailwind
    JIT/purge issue with dynamic template-literal classes) - guaranteed to
    render a visible on/off pill+knob.
  - Rewrites Button.tsx with a clearly visible hover (lift + shadow + stronger
    brightness shift) so it's noticeable even on the solid-black primary variant.

  Usage:
    PS D:\...\SAI2> .\Fix-SwitchAndButton-Final.ps1
#>

param(
    [string]$ProjectRoot = (Get-Location).Path
)

$uiSrc = Join-Path $ProjectRoot "packages\ui\src"

if (-not (Test-Path $uiSrc)) {
    Write-Host "ERROR: packages\ui\src not found at -> $uiSrc" -ForegroundColor Red
    exit 1
}

# ---------------------------------------------------------------------------
# 1) Switch.tsx - inline-style based, bulletproof rendering
# ---------------------------------------------------------------------------
$switchPath = Join-Path $uiSrc "Switch.tsx"
if (Test-Path $switchPath) { Copy-Item $switchPath "$switchPath.bak-final" -Force }

$switchCode = @'
"use client";

import { useState } from "react";

type SwitchProps = {
  checked: boolean;
  onChange: () => void;
  disabled?: boolean;
  label?: string;
  className?: string;
};

export function Switch({ checked, onChange, disabled = false, label, className = "" }: SwitchProps) {
  const [hover, setHover] = useState(false);

  const trackStyle: React.CSSProperties = {
    position: "relative",
    display: "inline-flex",
    alignItems: "center",
    width: 44,
    height: 24,
    borderRadius: 999,
    border: "1px solid",
    borderColor: checked ? "var(--color-ink)" : "var(--color-line-strong)",
    backgroundColor: checked ? "var(--color-ink)" : "var(--color-paper-dim)",
    opacity: disabled ? 0.4 : hover ? 0.85 : 1,
    cursor: disabled ? "not-allowed" : "pointer",
    transition: "background-color 180ms ease-out, border-color 180ms ease-out, opacity 150ms ease-out",
    outline: "none",
    padding: 0,
    flexShrink: 0
  };

  const knobStyle: React.CSSProperties = {
    position: "absolute",
    top: 2,
    left: checked ? 22 : 2,
    width: 18,
    height: 18,
    borderRadius: "50%",
    backgroundColor: "var(--color-paper)",
    boxShadow: "0 1px 3px rgba(0,0,0,0.35)",
    transition: "left 180ms ease-out"
  };

  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      aria-label={label}
      disabled={disabled}
      onClick={onChange}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => setHover(false)}
      style={trackStyle}
      className={className}
    >
      <span style={knobStyle} />
    </button>
  );
}
'@

Set-Content -LiteralPath $switchPath -Value $switchCode -NoNewline
Write-Host "[OK] Switch.tsx rewritten with inline styles (guaranteed rendering)." -ForegroundColor Green

# ---------------------------------------------------------------------------
# 2) Button.tsx - clearly visible hover feedback
# ---------------------------------------------------------------------------
$buttonPath = Join-Path $uiSrc "Button.tsx"
if (Test-Path $buttonPath) { Copy-Item $buttonPath "$buttonPath.bak-final" -Force }

$buttonCode = @'
"use client";

import { forwardRef, useState } from "react";
import type { ButtonHTMLAttributes, CSSProperties } from "react";

type ButtonVariant = "primary" | "secondary" | "ghost" | "danger";
type ButtonSize = "sm" | "md" | "lg";

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
  size?: ButtonSize;
};

const SIZE_CLASSES: Record<ButtonSize, string> = {
  sm: "h-8 px-3 text-[12.5px]",
  md: "h-9 px-4 text-[13px]",
  lg: "h-11 px-5 text-[14px]"
};

const VARIANT_STYLE: Record<ButtonVariant, { bg: string; hoverBg: string; text: string; border: string }> = {
  primary: {
    bg: "var(--color-ink)",
    hoverBg: "var(--color-ink-soft)",
    text: "var(--color-paper)",
    border: "var(--color-ink)"
  },
  secondary: {
    bg: "var(--color-card)",
    hoverBg: "var(--color-paper-dim)",
    text: "var(--color-ink)",
    border: "var(--color-line-strong)"
  },
  ghost: {
    bg: "transparent",
    hoverBg: "var(--color-paper-dim)",
    text: "var(--color-ink-soft)",
    border: "transparent"
  },
  danger: {
    bg: "var(--color-error)",
    hoverBg: "var(--color-error)",
    text: "var(--color-paper)",
    border: "var(--color-error)"
  }
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  { variant = "primary", size = "md", className = "", type = "button", style, disabled, onMouseDown, onMouseUp, ...props },
  ref
) {
  const [hover, setHover] = useState(false);
  const [pressed, setPressed] = useState(false);

  const v = VARIANT_STYLE[variant];

  const dynamicStyle: CSSProperties = {
    backgroundColor: disabled ? v.bg : hover ? v.hoverBg : v.bg,
    color: v.text,
    borderColor: v.border,
    borderWidth: 1,
    borderStyle: "solid",
    opacity: disabled ? 0.45 : variant === "danger" && hover ? 0.9 : 1,
    transform: !disabled && hover ? (pressed ? "translateY(0) scale(0.97)" : "translateY(-1px)") : "translateY(0)",
    boxShadow: !disabled && hover ? "0 4px 10px rgba(0,0,0,0.18)" : "none",
    transition: "background-color 150ms ease-out, transform 120ms ease-out, box-shadow 150ms ease-out, opacity 150ms ease-out",
    cursor: disabled ? "not-allowed" : "pointer",
    ...style
  };

  const classes = [
    "inline-flex items-center justify-center gap-1.5 rounded-control font-medium whitespace-nowrap outline-none",
    "focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-ink",
    SIZE_CLASSES[size],
    className
  ]
    .filter(Boolean)
    .join(" ");

  return (
    <button
      ref={ref}
      type={type}
      disabled={disabled}
      className={classes}
      style={dynamicStyle}
      onMouseEnter={() => setHover(true)}
      onMouseLeave={() => {
        setHover(false);
        setPressed(false);
      }}
      onMouseDown={(e) => {
        setPressed(true);
        onMouseDown?.(e);
      }}
      onMouseUp={(e) => {
        setPressed(false);
        onMouseUp?.(e);
      }}
      {...props}
    />
  );
});
'@

Set-Content -LiteralPath $buttonPath -Value $buttonCode -NoNewline
Write-Host "[OK] Button.tsx rewritten with clearly visible hover/press feedback (lift + shadow)." -ForegroundColor Green

# ---------------------------------------------------------------------------
# 3) Ensure both exported from packages/ui index
# ---------------------------------------------------------------------------
$indexTs  = Join-Path $uiSrc "index.ts"
$indexTsx = Join-Path $uiSrc "index.tsx"
$indexFile = if (Test-Path $indexTs) { $indexTs } elseif (Test-Path $indexTsx) { $indexTsx } else { $null }

if ($indexFile) {
    $ic = Get-Content -Raw -LiteralPath $indexFile
    if ($ic -notmatch '\./Switch') { Add-Content -LiteralPath $indexFile -Value "`nexport * from `"./Switch`";" }
    if ($ic -notmatch '\./Button') { Add-Content -LiteralPath $indexFile -Value "`nexport * from `"./Button`";" }
    Write-Host "[OK] Verified exports in $indexFile" -ForegroundColor Green
} else {
    Write-Host "[WARN] index.ts(x) not found - export manually if needed:" -ForegroundColor Yellow
    Write-Host '        export * from "./Switch";'
    Write-Host '        export * from "./Button";'
}

Write-Host ""
Write-Host "Done." -ForegroundColor Cyan
Write-Host "IMPORTANT: Fully stop the dev server (Ctrl+C), delete .next cache if possible, restart, and hard-refresh (Ctrl+Shift+R)." -ForegroundColor Magenta