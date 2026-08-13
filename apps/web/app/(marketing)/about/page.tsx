export default function AboutPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
      <h1 className="mb-4 font-display text-[32px] font-bold text-ink">About Saachi AI</h1>
      <p className="mb-6 text-[16px] leading-relaxed text-ink-soft">
        Saachi AI is not a video platform. It is a skills exchange for the AI era - where you
        don&apos;t just watch AI in action, you learn to build with it, and you can sell what you know.
      </p>

      <h2 className="mb-3 mt-10 font-display text-[22px] font-semibold text-ink">Our mission</h2>
      <p className="mb-6 leading-relaxed text-ink-soft">
        We exist to close the gap between knowing that AI tools exist and knowing how to actually
        use them to produce real, sellable outcomes - websites, apps, automations, marketing
        campaigns, content pipelines, and customer support systems - by connecting people who have
        figured this out with people who want to learn it, inside a safe, paid, structured
        environment.
      </p>

      <h2 className="mb-3 mt-10 font-display text-[22px] font-semibold text-ink">What makes us different</h2>
      <ul className="flex flex-col gap-2 text-ink-soft">
        <li>- Outcome-based learning, not watch-time</li>
        <li>- Practical AI application skills only - no unrelated content</li>
        <li>- Local payment support for the Pakistani market</li>
        <li>- Verified instructors and certified completion</li>
      </ul>
    </div>
  );
}