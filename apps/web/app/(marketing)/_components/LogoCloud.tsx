import { COMPANY_LOGOS } from "./landing-fake-data";

export function LogoCloud() {
  return (
    <div>
      <p className="mb-6 text-center text-[12.5px] font-medium uppercase tracking-[0.1em] text-ink-soft/70">
        Teams upskilling with Saachi AI
      </p>
      <div className="flex flex-wrap items-center justify-center gap-x-10 gap-y-5">
        {COMPANY_LOGOS.map((name) => (
          <span key={name} className="font-display text-[16px] font-bold text-ink-soft/50 transition-colors hover:text-ink-soft">
            {name}
          </span>
        ))}
      </div>
    </div>
  );
}