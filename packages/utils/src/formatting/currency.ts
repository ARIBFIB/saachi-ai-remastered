const CURRENCY_LOCALE: Record<string, string> = {
  USD: "en-US",
  PKR: "en-PK",
  GBP: "en-GB"
};

export function formatCurrency(amount: number, currency: string = "USD"): string {
  const locale = CURRENCY_LOCALE[currency] ?? "en-US";
  return new Intl.NumberFormat(locale, {
    style: "currency",
    currency,
    minimumFractionDigits: 2
  }).format(amount);
}

export function formatCompactNumber(value: number): string {
  return new Intl.NumberFormat("en-US", {
    notation: "compact",
    maximumFractionDigits: 1
  }).format(value);
}
