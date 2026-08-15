"use client";

import { motion } from "framer-motion";

const COLLAGE_IMAGES = [
  {
    src: "https://media2.gogoprint.com/product-config/ggp-v1/product-part/CertificateNameOptions.png",
    alt: "Course certificate preview",
    className: "absolute right-6 top-2 w-[150px] rotate-[6deg]",
    delay: 0.1
  },
  {
    src: "https://media2.gogoprint.com/wysiwyg/GGP250919_Product%20Images_Assorted%202_Product%20Banner_V1_Certificates.png",
    alt: "Printed certificate stack",
    className: "absolute right-[130px] top-[110px] w-[130px] -rotate-[8deg]",
    delay: 0.2
  },
  {
    src: "https://img.magnific.com/free-photo/elevated-view-laptop-stationeries-blue-backdrop_23-2147880457.jpg?semt=ais_test_b&w=740&q=80",
    alt: "Laptop and study desk",
    className: "absolute right-2 top-[210px] w-[170px] rotate-[3deg]",
    delay: 0.3
  }
];

const TRUST_BADGES = [
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRXw__JGEVPoYpshYYG8UuBjH7gxWJmlNu82dtp0iM3ww&s=10",
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7yozzI-aiXLy--A4tQX80TWaWt1YSSBDA-fDrcggKhQ&s=10",
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSpa2Z8Pb_yaZthxdUoOsXaA8DsXMl4S980UXIUadYBxg&s=10",
  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTxV1v7Hc6n9DsaX6YdAE3CpbR9E5z8NRWut6CWeS0Y5Q&s=10"
];

export function HeroMediaCollage() {
  return (
    <div className="pointer-events-none absolute right-0 top-0 hidden h-[320px] w-[280px] lg:block xl:right-4">
      {COLLAGE_IMAGES.map((img) => (
        <motion.div
          key={img.src}
          initial={{ opacity: 0, y: 24, scale: 0.92 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ duration: 0.6, delay: img.delay, ease: [0.16, 1, 0.3, 1] }}
          className={img.className}
        >
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={img.src}
            alt={img.alt}
            className="aspect-square w-full rounded-2xl border border-line/60 bg-card object-cover shadow-xl"
          />
        </motion.div>
      ))}

      <motion.div
        initial={{ opacity: 0, y: 16 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6, delay: 0.5, ease: [0.16, 1, 0.3, 1] }}
        className="pointer-events-auto absolute bottom-0 right-2 flex items-center gap-1.5 rounded-full border border-line bg-card/95 px-3 py-2 shadow-md backdrop-blur-sm"
      >
        {TRUST_BADGES.map((src, i) => (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            key={src + i}
            src={src}
            alt="Trust badge"
            className="h-6 w-6 rounded-full border border-line object-cover grayscale transition-all duration-200 hover:grayscale-0"
            style={{ marginLeft: i === 0 ? 0 : -8 }}
          />
        ))}
        <span className="ml-1.5 whitespace-nowrap text-[10px] font-semibold text-ink-soft">Trusted &amp; Certified</span>
      </motion.div>
    </div>
  );
}
