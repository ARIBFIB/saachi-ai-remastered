interface CategoryBannerProps {
  title: string;
  description: string;
  image?: string;
}

export function CategoryBanner({ title, description, image }: CategoryBannerProps) {
  return (
    <div className="relative self-stretch overflow-hidden rounded-xl bg-[var(--token-color-surfaceAlt)]">
      <img
        src={image ?? "https://placehold.co/1184x320"}
        alt=""
        className="absolute left-0 top-0 h-80 w-full object-cover opacity-20"
      />

      <div className="relative flex min-h-80 flex-col justify-end gap-4 px-10 pb-10 pt-32">
        <h1 className="max-w-[1104px] text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
          {title}
        </h1>
        <p className="max-w-[672px] text-lg leading-7 text-[var(--token-color-inkSoft)]">
          {description}
        </p>
      </div>
    </div>
  );
}