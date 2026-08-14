$ErrorActionPreference = "Stop"
$root = Get-Location

$buttonPath = Join-Path $root "packages\ui\src\Button.tsx"

if (-not (Test-Path -LiteralPath $buttonPath)) {
    Write-Error "File not found: $buttonPath -- run this script from the SAI2 root."
    exit 1
}

$backupDir = Join-Path $root "theme-migration-backup\step5"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item -LiteralPath $buttonPath -Destination (Join-Path $backupDir "Button.tsx.bak") -Force
Write-Host "Backup saved to: $backupDir"

$newButtonContent = @'
"use client";
import { forwardRef, useState } from "react";
import type { ButtonHTMLAttributes, CSSProperties } from "react";

type ButtonVariant = "primary" | "secondary" | "ghost" | "danger" | "brand";
type ButtonSize = "sm" | "md" | "lg";

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
  size?: ButtonSize;
  loading?: boolean;
};

const SIZE_CLASSES: Record<ButtonSize, string> = {
  sm: "h-8 px-3 text-[12.5px]",
  md: "h-9 px-4 text-[13px]",
  lg: "h-11 px-5 text-[14px]"
};

type VariantStyle = {
  bg?: string;
  hoverBg?: string;
  bgImage?: string;
  hoverBgImage?: string;
  text: string;
  border: string;
  glow?: string;
};

const VARIANT_STYLE: Record<ButtonVariant, VariantStyle> = {
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
  },
  brand: {
    bgImage: "var(--color-accent-gradient)",
    hoverBgImage: "var(--color-accent-gradient)",
    text: "#ffffff",
    border: "transparent",
    glow: "0 0 32px -6px rgba(124,58,237,0.55)"
  }
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(function Button(
  {
    variant = "primary",
    size = "md",
    className = "",
    type = "button",
    style,
    disabled,
    loading = false,
    children,
    onMouseDown,
    onMouseUp,
    ...props
  },
  ref
) {
  const [hover, setHover] = useState(false);
  const [pressed, setPressed] = useState(false);

  const v = VARIANT_STYLE[variant];
  const isDisabled = disabled || loading;

  const usesGradient = Boolean(v.bgImage);

  const dynamicStyle: CSSProperties = {
    backgroundColor: usesGradient ? undefined : isDisabled ? v.bg : hover ? v.hoverBg : v.bg,
    backgroundImage: usesGradient ? (hover ? v.hoverBgImage ?? v.bgImage : v.bgImage) : undefined,
    color: v.text,
    borderColor: v.border,
    borderWidth: 1,
    borderStyle: "solid",
    opacity: isDisabled ? 0.6 : variant === "danger" && hover ? 0.9 : 1,
    filter: !isDisabled && hover && usesGradient ? "brightness(1.08)" : "none",
    transform: !isDisabled && hover ? (pressed ? "translateY(0) scale(0.97)" : "translateY(-1px)") : "translateY(0)",
    boxShadow: !isDisabled && hover ? (v.glow ?? "0 4px 10px rgba(0,0,0,0.18)") : v.glow ? "0 0 24px -8px rgba(124,58,237,0.35)" : "none",
    transition:
      "background-color 150ms ease-out, filter 150ms ease-out, transform 120ms ease-out, box-shadow 150ms ease-out, opacity 150ms ease-out",
    cursor: isDisabled ? "not-allowed" : "pointer",
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
      disabled={isDisabled}
      aria-busy={loading}
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
    >
      {loading ? "Working..." : children}
    </button>
  );
});
'@

Set-Content -LiteralPath $buttonPath -Value $newButtonContent -Encoding UTF8
Write-Host "Updated: $buttonPath"
Write-Host ""
Write-Host "Added a 'brand' variant using backgroundImage (gradient) instead"
Write-Host "of backgroundColor, since this component drives its colors via"
Write-Host "inline styles rather than Tailwind classes."
Write-Host ""
Write-Host "Run: pnpm --filter web build"