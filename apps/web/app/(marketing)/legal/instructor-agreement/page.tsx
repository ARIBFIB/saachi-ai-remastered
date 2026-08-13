export default function InstructorAgreementPage() {
  return (
    <div className="mx-auto max-w-3xl px-4 py-16 md:px-0">
      <h1 className="mb-6 font-display text-[30px] font-bold text-ink">Instructor Agreement</h1>
      <div className="flex flex-col gap-5 text-[15px] leading-relaxed text-ink-soft">
        <p>
          This Instructor Agreement governs the relationship between Saachi AI and instructors
          who create, publish, and sell courses on the Platform. By submitting a course for
          review or completing the instructor onboarding process, you agree to these terms.
        </p>

        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">1. Content ownership</h2>
        <p>
          Instructors retain ownership of the course content they create. By publishing on
          Saachi AI, you grant the Platform a non-exclusive license to host, stream, and deliver
          that content to enrolled learners.
        </p>

        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">2. Content standards</h2>
        <p>
          Courses must be original work or properly licensed. Plagiarism, unverifiable "get rich
          quick" claims, and use of copyrighted third-party material without rights are strictly
          prohibited and grounds for content removal or account suspension.
        </p>

        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">3. Review &amp; approval</h2>
        <p>
          All courses are reviewed by the Saachi AI moderation team before going live. Admins may
          approve, reject with feedback, or request changes prior to publication.
        </p>

        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">4. Commission &amp; payouts</h2>
        <p>
          Saachi AI retains a platform commission on each course sale, disclosed at the time of
          course submission. Commission rates may vary based on instructor trust tier (New,
          Verified, Top-Rated, Partner). Net earnings are credited to your instructor wallet and
          may be withdrawn according to the payout schedule and method you configure.
        </p>

        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">5. Instructor verification</h2>
        <p>
          Instructors may be required to submit identity or business verification documents and
          portfolio/proof-of-work links. Verification status affects trust tier eligibility and
          may be reviewed periodically.
        </p>

        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">6. Refunds &amp; disputes</h2>
        <p>
          Learner-initiated refunds within the Platform&apos;s refund policy window may reduce your
          earned balance accordingly. Repeated disputes or complaints against your courses may
          trigger a content review.
        </p>

        <h2 className="mt-4 font-display text-[18px] font-semibold text-ink">7. Termination</h2>
        <p>
          Saachi AI reserves the right to suspend or terminate an instructor account for violation
          of this Agreement, the Terms &amp; Conditions, or applicable law.
        </p>

        <p className="mt-6 text-[13px] text-ink-soft/70">
          This is placeholder legal text. Replace with content reviewed by legal counsel before
          launch.
        </p>
      </div>
    </div>
  );
}