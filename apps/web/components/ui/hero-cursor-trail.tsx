"use client";

import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";

// Course/AI-relevant imagery for the hero cursor-trail effect.
const SHOWCASE_IMAGES = [
  "https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1531482615713-2afd69097998?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1526378722484-bd91ca387e72?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1550439062-609e1531270e?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=480&h=600&fit=crop&q=70&auto=format",
  "https://images.unsplash.com/photo-1571171637578-41bc2dd41cd2?w=480&h=600&fit=crop&q=70&auto=format"
];

/**
 * Covers the ENTIRE hero section (so the trail reacts to the mouse
 * anywhere in the hero, not just a small box), but fades out via a
 * mask-image gradient as it approaches the left text column so it
 * never overlaps the heading, paragraph, or CTA buttons. Shifted
 * slightly further right (pl-12) so it sits clear of the text column.
 */
export function HeroCursorTrail() {
  return (
    <div
      className="pointer-events-none absolute inset-0 z-0 hidden pl-12 lg:block xl:pl-20"
      style={{
        maskImage: "linear-gradient(to right, transparent 0%, transparent 44%, black 62%, black 100%)",
        WebkitMaskImage: "linear-gradient(to right, transparent 0%, transparent 44%, black 62%, black 100%)"
      }}
    >
      <ImageCursorTrail
        items={SHOWCASE_IMAGES}
        maxNumberOfImages={5}
        distance={20}
        imgClass="w-28 h-32 xl:w-32 xl:h-36"
        className="!h-full !w-full !rounded-none"
      />
    </div>
  );
}

export default HeroCursorTrail;