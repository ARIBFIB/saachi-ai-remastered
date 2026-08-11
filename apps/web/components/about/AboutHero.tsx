import Image from "next/image";

interface AboutHeroProps {
  heading: string;
  description: string;
  image: string;
}

export function AboutHero({ heading, description, image }: AboutHeroProps) {
  return (
    <section className="flex w-full items-center gap-10">
      <div className="flex flex-1 flex-col gap-6">
        <h1 className="max-w-[572px] text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
          {heading}
        </h1>
        <p className="max-w-[572px] text-lg leading-7 text-[var(--token-color-inkSoft)]">
          {description}
        </p>
      </div>

      <div className="relative h-96 flex-1 overflow-hidden rounded-2xl shadow-lg">
        <Image src={image} alt="About Saachi AI" fill sizes="572px" className="object-cover" />
        <div className="absolute inset-0 bg-gradient-to-br from-[var(--token-color-primary)]/20 to-transparent" />
      </div>
    </section>
  );
}