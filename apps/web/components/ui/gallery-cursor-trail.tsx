"use client";

import { useState } from "react";
import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";
import { ImageGallery } from "@/components/ui/image-gallery";

const TRAIL_IMAGES = [
  "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1550439062-609e1531270e?w=480&h=600&fit=crop&q=70&auto=format"
];

/**
 * Renders the image gallery. When the user hovers/points over the
 * gallery area, the ImageCursorTrail effect activates on top of it.
 * Outside of hover, the trail is inactive and invisible.
 */
export function GalleryCursorTrail() {
  const [hovering, setHovering] = useState(false);

  return (
    <div
      className="relative w-full"
      onMouseEnter={() => setHovering(true)}
      onMouseLeave={() => setHovering(false)}
    >
      <ImageGallery />

      <ImageCursorTrail
        items={TRAIL_IMAGES}
        active={hovering}
        maxNumberOfImages={4}
        distance={18}
        imgClass="w-24 h-28"
        className="!absolute !inset-0 !h-full !w-full !rounded-lg !bg-transparent"
      />
    </div>
  );
}

export default GalleryCursorTrail;