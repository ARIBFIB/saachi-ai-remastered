import { SupportHeader } from "@/components/support/SupportHeader";
import { SupportFooter } from "@/components/support/SupportFooter";
import { ContactForm } from "@/components/support/ContactForm";
import { DirectContactCard } from "@/components/support/DirectContactCard";
import { OfficeMapCard } from "@/components/support/OfficeMapCard";

export default function ContactPage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <SupportHeader />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-10 px-6 py-10">
        <div className="flex max-w-[768px] flex-col gap-1.5">
          <h1 className="text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">Get in Touch</h1>
          <p className="text-lg leading-7 text-[var(--token-color-inkSoft)]">
            Our team is here to support your learning journey. Reach out with questions, technical issues, or
            feedback.
          </p>
        </div>

        <div className="grid grid-cols-1 items-start gap-6 lg:grid-cols-3">
          <div className="lg:col-span-2">
            <ContactForm />
          </div>

          <div className="flex flex-col gap-6">
            <DirectContactCard />
            <OfficeMapCard />
          </div>
        </div>
      </main>

      <SupportFooter />
    </div>
  );
}