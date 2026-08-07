import { Star, BadgeCheck } from "lucide-react";
import { cn } from "../cn";

export type ReviewCardProps = {
  authorName: string;
  authorAvatarUrl?: string;
  rating: number;
  comment: string;
  createdAt: string;
  verifiedPurchase?: boolean;
  className?: string;
};

export function ReviewCard({
  authorName,
  authorAvatarUrl,
  rating,
  comment,
  createdAt,
  verifiedPurchase,
  className
}: ReviewCardProps) {
  const formattedDate = new Intl.DateTimeFormat("en-US", {
    year: "numeric",
    month: "short",
    day: "numeric"
  }).format(new Date(createdAt));

  return (
    <div className={cn("rounded-card border border-line bg-card p-6", className)}>
      <div className="mb-3 flex items-center gap-1">
        {Array.from({ length: 5 }).map((_, i) => (
          <Star key={i} size={15} className={i < Math.round(rating) ? "fill-gold text-gold" : "text-line-strong"} />
        ))}
      </div>

      <p className="mb-4 text-[15px] leading-relaxed text-ink">{comment}</p>

      <div className="flex items-center gap-3">
        <div className="flex h-9 w-9 items-center justify-center overflow-hidden rounded-full bg-teal-light text-[13px] font-semibold text-teal">
          {authorAvatarUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={authorAvatarUrl} alt={authorName} className="h-full w-full object-cover" />
          ) : (
            authorName.charAt(0).toUpperCase()
          )}
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <span className="text-[13px] font-semibold text-ink">{authorName}</span>
            {verifiedPurchase && <BadgeCheck size={14} className="text-teal" />}
          </div>
          <span className="text-[12px] text-ink-soft/60">{formattedDate}</span>
        </div>
      </div>
    </div>
  );
}