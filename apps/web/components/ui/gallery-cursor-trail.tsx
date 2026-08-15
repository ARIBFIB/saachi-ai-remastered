"use client";

import { useState } from "react";
import { cn } from "@/lib/utils";
import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";

// Single shared image set: same images render as the gallery strip AND
// as the cursor-trail images, so the trail always matches what's shown.
export const GALLERY_IMAGES = [
  "https://images.unsplash.com/photo-1555949963-aa79dcee981c?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1531482615713-2afd69097998?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1550439062-609e1531270e?q=80&h=800&w=800&auto=format&fit=crop",
  "https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&h=800&w=800&auto=format&fit=crop"
];

/**
 * Renders the gallery strip. On hovering any single image, the cursor
 * trail activates using THAT SAME IMAGE (repeated) so the trail is
 * always directly related to the image being hovered.
 *
 * `orientation="vertical"` renders a compact right-column-friendly
 * layout (fewer, taller cards) instead of the full-width horizontal
 * strip.
 */
export function GalleryCursorTrail({
  orientation = "horizontal"
}: {
  orientation?: "horizontal" | "vertical";
}) {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  const images = orientation === "vertical" ? GALLERY_IMAGES.slice(0, 4) : GALLERY_IMAGES;

  return (
    <div
      className={cn(
        "relative flex w-full",
        orientation === "vertical"
          ? "h-[440px] flex-col gap-2"
          : "h-[320px] items-center gap-2"
      )}
    >
      {images.map((src, idx) => (
        <div
          key={idx}
          onMouseEnter={() => setHoveredIndex(idx)}
          onMouseLeave={() => setHoveredIndex(null)}
          className={cn(
            "group relative flex-grow overflow-hidden rounded-lg transition-all duration-500",
            orientation === "vertical" ? "w-full h-24 hover:h-full" : "h-[320px] w-40 hover:w-full"
          )}
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            className="h-full w-full object-cover object-center"
            src={src}
            alt={`saachi-ai-gallery-${idx}`}
          />

          <ImageCursorTrail
            items={[src, src, src]}
            active={hoveredIndex === idx}
            maxNumberOfImages={3}
            distance={14}
            imgClass="w-20 h-24"
            className="!absolute !inset-0 !h-full !w-full !rounded-lg !bg-transparent"
          />
        </div>
      ))}
    </div>
  );
}

export default GalleryCursorTrail;