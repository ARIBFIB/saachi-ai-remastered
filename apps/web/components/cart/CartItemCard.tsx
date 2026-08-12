import Image from "next/image";
import { Trash2, Bookmark, Star } from "lucide-react";

export interface CartItem {
  id: string;
  title: string;
  instructor: string;
  price: number;
  rating: number;
  reviews: string;
  image: string;
  badge?: string;
}

interface CartItemCardProps {
  item: CartItem;
  onRemove: (id: string) => void;
  onSaveForLater?: (id: string) => void;
}

export function CartItemCard({ item, onRemove, onSaveForLater }: CartItemCardProps) {
  return (
    <div
      className="flex w-full gap-6 rounded-xl border-2 bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-[var(--token-shadow-sm)])]"
      style={{ borderColor: "var(--token-color-border)" }}
    >
      <div className="relative h-24 w-40 shrink-0 overflow-hidden rounded-lg bg-[var(--token-color-surfaceAlt)]">
        <Image
          src={item.image}
          alt={item.title}
          fill
          sizes="160px"
          className="object-cover"
        />
      </div>

      <div className="flex flex-1 flex-col justify-between">
        <div className="flex flex-col gap-1.5 pb-4">
          <div className="flex items-start justify-between gap-4">
            <h3
              className="line-clamp-2 text-lg font-semibold leading-7"
              style={{ color: "var(--token-color-ink)" }}
            >
              {item.title}
            </h3>
            <span
              className="shrink-0 text-2xl font-bold"
              style={{ color: "var(--token-color-primary)" }}
            >
              ${item.price.toFixed(2)}
            </span>
          </div>

          <p
            className="text-sm font-semibold tracking-wide"
            style={{ color: "var(--token-color-inkSoft)" }}
          >
            By {item.instructor}
          </p>

          <div className="flex items-center gap-2 pt-2">
            {item.badge && (
              <span
                className="rounded-sm px-2 pb-1 pt-[3px] text-xs font-medium"
                style={{
                  backgroundColor: "var(--token-color-primaryTint)",
                  color: "var(--token-color-primary)",
                }}
              >
                {item.badge}
              </span>
            )}
            <span className="flex items-center gap-1">
              <Star size={14} color="var(--token-color-warning)" fill="var(--token-color-warning)" />
              <span
                className="text-xs font-medium"
                style={{ color: "var(--token-color-inkSoft)" }}
              >
                {item.rating} ({item.reviews} reviews)
              </span>
            </span>
          </div>
        </div>

        <div
          className="flex items-center gap-4 border-t pt-3"
          style={{ borderColor: "var(--token-color-border)" }}
        >
          <button
            type="button"
            onClick={() => onRemove(item.id)}
            className="flex items-center gap-1 text-xs font-medium transition hover:text-[var(--token-color-error)]"
            style={{ color: "var(--token-color-inkSoft)" }}
          >
            <Trash2 size={12} />
            Remove
          </button>
          <button
            type="button"
            onClick={() => onSaveForLater?.(item.id)}
            className="flex items-center gap-1 text-xs font-medium"
            style={{ color: "var(--token-color-primary)" }}
          >
            <Bookmark size={12} />
            Save for Later
          </button>
        </div>
      </div>
    </div>
  );
}
