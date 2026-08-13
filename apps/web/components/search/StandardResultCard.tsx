import Image from "next/image";
import { ImageOff } from "lucide-react";

export interface StandardResultCardProps {
  title: string;
  description: string;
  meta: string;
  price: string;
  image?: string;
}

export function StandardResultCard({ title, description, meta, price, image }: StandardResultCardProps) {
  return (
    <article className="overflow-hidden rounded-xl border-2 border-[var(--token-color-border)] bg-[var(--token-color-surface)] shadow-[var(--token-shadow-sm)]">
      <div className="relative h-40 w-full bg-zinc-200">
        {image ? (
          <Image src={image} alt={title} fill sizes="400px" className="object-cover" />
        ) : (
          <div className="flex h-full w-full items-center justify-center">
            <ImageOff className="h-10 w-10 text-[var(--token-color-inkSoft)]/30" />
          </div>
        )}
      </div>

      <div className="flex flex-col gap-2 p-4">
        <h3 className="line-clamp-1 text-lg font-bold leading-7 text-[var(--token-color-ink)]">{title}</h3>
        <p className="line-clamp-2 text-xs font-medium text-[var(--token-color-inkSoft)]">{description}</p>

        <div className="flex items-center justify-between border-t border-[var(--token-color-border)] pt-3">
          <span className="text-xs font-medium text-[var(--token-color-inkSoft)]">{meta}</span>
          <span className="text-xs font-bold text-[var(--token-color-primary)]">{price}</span>
        </div>
      </div>
    </article>
  );
}