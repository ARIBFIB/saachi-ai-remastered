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
    <div
      className={cn(
        "rounded-2xl border border-[var(--border-hairline,rgba(15,23,42,0.08))] bg-[var(--surface-card,#FFFFFF)] p-6",
        className
      )}
    >
      <div className="mb-3 flex items-center gap-1">
        {Array.from({ length: 5 }).map((_, i) => (
          <Star
            key={i}
            size={15}
            className={
              i < Math.round(rating)
                ? "fill-[var(--blue-500,#3B82F6)] text-[var(--blue-500,#3B82F6)]"
                : "text-[var(--border-hairline-strong,rgba(15,23,42,0.14))]"
            }
          />
        ))}
      </div>

      <p className="mb-4 text-[15px] leading-relaxed text-[var(--text-primary,#0F172A)]">
        {comment}
      </p>

      <div className="flex items-center gap-3">
        <div className="flex h-9 w-9 items-center justify-center overflow-hidden rounded-full bg-[var(--blue-50,#EFF6FF)] text-[13px] font-semibold text-[var(--blue-600,#2563EB)]">
          {authorAvatarUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={authorAvatarUrl} alt={authorName} className="h-full w-full object-cover" />
          ) : (
            authorName.charAt(0).toUpperCase()
          )}
        </div>
        <div>
          <div className="flex items-center gap-1.5">
            <span className="text-[13px] font-semibold text-[var(--text-primary,#0F172A)]">
              {authorName}
            </span>
            {verifiedPurchase && (
              <BadgeCheck size={14} className="text-[var(--success,#14B8A6)]" />
            )}
          </div>
          <span className="text-[12px] text-[var(--text-muted,#94A3B8)]">{formattedDate}</span>
        </div>
      </div>
    </div>
  );
}
