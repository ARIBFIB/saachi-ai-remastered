"use client";

import Link from "next/link";
import { X } from "lucide-react";
import { useCartStore, useWishlistStore } from "@saachi/store";
import { Button, EmptyState } from "@saachi/ui";

export default function WishlistPage() {
  const items = useWishlistStore((s) => s.items);
  const removeFromWishlist = useWishlistStore((s) => s.remove);
  const addToCart = useCartStore((s) => s.addItem);

  return (
    <div>
      <h1 className="mb-6 font-display text-[26px] font-bold text-ink">Wishlist</h1>

      {items.length === 0 ? (
        <EmptyState
          title="Your wishlist is empty"
          description="Save courses you're interested in to find them here later."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-3">
          {items.map((item) => (
            <div
              key={item.courseId}
              className="flex items-center gap-4 rounded-card border border-line bg-card p-4"
            >
              {item.thumbnailUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={item.thumbnailUrl}
                  alt={item.title}
                  className="h-16 w-28 shrink-0 rounded-control object-cover"
                />
              )}
              <div className="min-w-0 flex-1">
                <Link href={`/courses/${item.slug}`} className="truncate text-[15px] font-semibold text-ink hover:underline">
                  {item.title}
                </Link>
                <p className="text-[13px] text-ink-soft">{item.instructorName}</p>
              </div>
              <span className="font-mono text-[15px] font-semibold text-ink">
                {new Intl.NumberFormat("en-US", { style: "currency", currency: item.currency }).format(item.price)}
              </span>
              <Button
                size="sm"
                onClick={() =>
                  addToCart({
                    courseId: item.courseId,
                    slug: item.slug,
                    title: item.title,
                    thumbnailUrl: item.thumbnailUrl,
                    instructorName: item.instructorName,
                    price: item.price,
                    currency: item.currency
                  })
                }
              >
                Add to cart
              </Button>
              <button
                type="button"
                aria-label="Remove from wishlist"
                onClick={() => removeFromWishlist(item.courseId)}
                className="flex h-9 w-9 shrink-0 items-center justify-center rounded-control text-ink-soft hover:bg-paper-dim"
              >
                <X size={16} />
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}