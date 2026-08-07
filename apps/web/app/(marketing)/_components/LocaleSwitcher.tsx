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