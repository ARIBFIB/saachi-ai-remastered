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