"use client";

import Link from "next/link";
import { Heart } from "lucide-react";
import { useWishlistStore, useCartStore } from "@saachi/store";
import { Button, Card, EmptyState, CourseCard } from "@saachi/ui";

export default function WishlistPage() {
  const wishlist = useWishlistStore();
  const cart = useCartStore();

  const moveToCart = (item: (typeof wishlist.items)[number]) => {
    cart.addItem({
      courseId: item.courseId,
      slug: item.slug,
      title: item.title,
      thumbnailUrl: item.thumbnailUrl,
      instructorName: item.instructorName,
      price: item.price,
      currency: item.currency
    });
    wishlist.remove(item.courseId);
  };

  return (
    <main className="mx-auto max-w-[1000px] px-6 py-10 md:px-10">
      <div className="mb-8">
        <h1 className="font-display text-[26px] font-semibold text-ink">Wishlist</h1>
        <p className="mt-1 text-[14px] text-ink-soft">Courses you've saved for later.</p>
      </div>

      {wishlist.items.length === 0 ? (
        <EmptyState
          icon={<Heart size={22} />}
          title="Your wishlist is empty"
          description="Save courses you're interested in and come back to them anytime."
          action={
            <Link href="/courses">
              <Button>Browse courses</Button>
            </Link>
          }
        />
      ) : (
        <div className="flex flex-col gap-4">
          {wishlist.items.map((item) => (
            <Card key={item.courseId} className="flex flex-col gap-4 p-4 sm:flex-row sm:items-center">
              <Link href={`/courses/${item.slug}`} className="block h-[90px] w-[160px] shrink-0 overflow-hidden rounded-control bg-paper-dim">
                {item.thumbnailUrl && (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img src={item.thumbnailUrl} alt={item.title} className="h-full w-full object-cover" />
                )}
              </Link>
              <div className="flex-1">
                <Link href={`/courses/${item.slug}`} className="text-[15px] font-semibold text-ink hover:text-gold-dark">
                  {item.title}
                </Link>
                <p className="mt-1 text-[13px] text-ink-soft">{item.instructorName}</p>
                <p className="mt-1 font-mono text-[15px] font-semibold text-ink">
                  {new Intl.NumberFormat("en-US", { style: "currency", currency: item.currency }).format(item.price)}
                </p>
              </div>
              <div className="flex shrink-0 gap-2">
                <Button size="sm" onClick={() => moveToCart(item)}>
                  Add to cart
                </Button>
                <Button size="sm" variant="ghost" onClick={() => wishlist.remove(item.courseId)}>
                  Remove
                </Button>
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}