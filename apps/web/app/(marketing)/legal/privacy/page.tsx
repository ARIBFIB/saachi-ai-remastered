export default function PrivacyPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
      <h1 className="mb-6 font-display text-[30px] font-bold text-ink">Privacy Policy</h1>
      <div className="flex flex-col gap-5 text-[15px] leading-relaxed text-ink-soft">
        <p>
          This Privacy Policy explains how Saachi AI collects, uses, and protects your personal
          information when you use the Platform.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">1. Information we collect</h2>
        <p>
          Account information (name, email), course activity (progress, completions), and payment
          metadata (never raw card details - those are handled by our PCI-DSS-compliant payment
          gateways).
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">2. How we use your data</h2>
        <p>
          To operate your account, process payments, deliver course content, and improve the
          Platform. We do not sell personal data to third parties.
        </p>
        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">3. Your rights</h2>
        <p>
          You may request a copy of your data or request account/data deletion at any time from
          your account settings.
        </p>
        <p className="mt-6 text-[13px] text-ink-soft/70">
          This is placeholder legal text. Replace with content reviewed by legal counsel before
          launch.
        </p>
      </div>
    </div>
  );
}