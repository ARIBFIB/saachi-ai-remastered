import { Header } from "@/components/marketing/Header";
import { HeroSection } from "@/components/marketing/HeroSection";
import { TrendingCourses } from "@/components/marketing/TrendingCourses";
import { CategoryGrid } from "@/components/marketing/CategoryGrid";
import { WhySaachi } from "@/components/marketing/WhySaachi";
import { Newsletter } from "@/components/marketing/Newsletter";
import { Footer } from "@/components/marketing/Footer";

export default function HomePage() {
  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="flex flex-1 flex-col items-center pb-10">
        <HeroSection />
        <TrendingCourses />
        <CategoryGrid />
        <WhySaachi />
        <Newsletter />
      </main>

      <Footer />
    </div>
  );
}