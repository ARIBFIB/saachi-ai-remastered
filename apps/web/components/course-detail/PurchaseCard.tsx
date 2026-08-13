import { PlayCircle, FileText, Award } from "lucide-react";

interface PurchaseCardProps {
  price: string;
  includes: string[];
}

const icons = [PlayCircle, FileText, Award];

export function PurchaseCard({ price, includes }: PurchaseCardProps) {
  return (
    <div className="sticky top-24 flex w-full flex-col gap-6 rounded-[var(--token-radius-lg)] border-2 border-[var(--token-color-inkDeep)] bg-slate-50 px-6 py-6 shadow-[var(--token-shadow-sm)]">
      <div className="flex flex-col items-center gap-1">
        <span className="text-5xl font-bold leading-[52.8px] text-zinc-900">{price}</span>
        <span className="text-xs font-medium text-gray-700">
          30-Day Money-Back Guarantee
        </span>
      </div>

      <div className="flex flex-col gap-3">
        <button
          type="button"
          className="w-full rounded-[var(--token-radius-md)] bg-[var(--token-color-amber)] py-3 text-sm font-bold tracking-wide text-white hover:bg-[var(--token-color-amberDark)]"
        >
          Buy Now
        </button>
        <button
          type="button"
          className="w-full rounded-[var(--token-radius-md)] border-2 border-gray-500 bg-white py-3 text-sm font-bold tracking-wide text-zinc-900 hover:bg-gray-50"
        >
          Add to Cart
        </button>
      </div>

      <div className="flex flex-col gap-3 border-t border-[var(--token-color-inkDeep)] pt-3.5">
        <h4 className="text-sm font-semibold tracking-wide text-zinc-900">
          This course includes:
        </h4>
        {includes.map((item, i) => {
          const Icon = icons[i % icons.length];
          return (
            <div key={item} className="flex items-center gap-3">
              <Icon className="h-5 w-5 shrink-0 text-[var(--token-color-amber)]" />
              <span className="text-base text-gray-700">{item}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}
