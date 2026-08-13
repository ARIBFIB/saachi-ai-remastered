"use client";

import { useState, type FormEvent } from "react";
import { useRouter } from "next/navigation";
import { GraduationCap } from "lucide-react";
import { useSession } from "@saachi/api-client";
import { Button, EmptyState, Input, Textarea } from "@saachi/ui";

export default function BecomeInstructorPage() {
  const router = useRouter();
  const { data: session } = useSession();
  const [bio, setBio] = useState("");
  const [expertise, setExpertise] = useState("");
  const [portfolioUrl, setPortfolioUrl] = useState("");
  const [submitted, setSubmitted] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  if (!session) {
    return <EmptyState title="Not logged in" description="Log in to apply as an instructor." />;
  }

  function handleSubmit(e: FormEvent) {
    e.preventDefault();
    setSubmitting(true);
    // NOTE: demo-only, no backend application-review workflow wired up yet.
    setTimeout(() => {
      setSubmitting(false);
      setSubmitted(true);
    }, 600);
  }

  if (submitted) {
    return (
      <div className="mx-auto max-w-lg py-16">
        <EmptyState
          title="Application submitted"
          description="Our team will review your instructor application and get back to you by email."
          action={<Button onClick={() => router.push("/dashboard")}>Back to dashboard</Button>}
        />
      </div>
    );
  }

  return (
    <div className="mx-auto max-w-2xl">
      <h1 className="mb-1 flex items-center gap-2 font-display text-[26px] font-bold text-ink">
        <GraduationCap size={24} />
        Become an instructor
      </h1>
      <p className="mb-8 text-[14px] text-ink-soft">
        Tell us about your expertise. Applications are reviewed manually before approval.
      </p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Textarea
          label="Bio"
          required
          rows={4}
          value={bio}
          onChange={(e) => setBio(e.target.value)}
          placeholder="Tell learners about your background and experience"
        />
        <Input
          label="Area of expertise"
          required
          value={expertise}
          onChange={(e) => setExpertise(e.target.value)}
          placeholder="e.g. AI Automation & Workflow Tools"
        />
        <Input
          label="Portfolio link"
          value={portfolioUrl}
          onChange={(e) => setPortfolioUrl(e.target.value)}
          placeholder="GitHub, LinkedIn, or personal site"
        />
        <Button type="submit" size="lg" loading={submitting} className="self-start">
          Submit application
        </Button>
      </form>
    </div>
  );
}