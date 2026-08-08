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