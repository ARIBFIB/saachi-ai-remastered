import { Map } from "lucide-react";

interface OfficeMapCardProps {
  image?: string;
  mapUrl?: string;
}

export function OfficeMapCard({ image, mapUrl = "#" }: OfficeMapCardProps) {
  return (
    <a
      href={mapUrl}
      className="relative block h-48 overflow-hidden rounded-xl border-2 border-[var(--token-color-border)]/30 bg-[var(--token-color-surface)] shadow-[var(--token-shadow-sm)]"
    >
      <img
        src={image ?? "https://placehold.co/393x190"}
        alt="Office location map"
        className="h-full w-full object-cover"
      />
      <div className="absolute inset-0 flex items-end justify-start bg-gradient-to-r from-white/80 to-transparent p-4">
        <span className="flex items-center gap-1 bg-[var(--token-color-surface)]/90 px-2 pb-1 pt-[3px] text-sm font-semibold text-[var(--token-color-ink)]">
          <Map className="h-3 w-3" />
          View on Map
        </span>
      </div>
    </a>
  );
}