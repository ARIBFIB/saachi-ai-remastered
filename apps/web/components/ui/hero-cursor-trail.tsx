"use client";

import { ImageCursorTrail } from "@/components/ui/image-cursor-trail";

// Course/AI-relevant imagery for the hero-side trail effect.
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

export function HeroCursorTrail() {
  return (
    <div className="pointer-events-auto absolute right-0 top-0 hidden h-[420px] w-[360px] lg:block xl:right-4 xl:h-[480px] xl:w-[420px]">
      <ImageCursorTrail
        items={SHOWCASE_IMAGES}
        maxNumberOfImages={5}
        distance={22}
        imgClass="w-24 h-28 xl:w-28 xl:h-32"
        className="!h-full !w-full rounded-2xl border border-line/60 bg-card/40 backdrop-blur-sm"
      />
    </div>
  );
}

export default HeroCursorTrail;