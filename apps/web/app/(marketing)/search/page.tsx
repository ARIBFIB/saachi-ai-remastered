import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { ResultFilterTabs, type FilterTab } from "@/components/search/ResultFilterTabs";
import { FeaturedResultCard } from "@/components/search/FeaturedResultCard";
import { InstructorResultCard } from "@/components/search/InstructorResultCard";
import { StandardResultCard } from "@/components/search/StandardResultCard";
import { ResultsPagination } from "@/components/search/ResultsPagination";

const filterTabs: FilterTab[] = [
  { label: "All Results", count: 0 },
  { label: "Courses", count: 120 },
  { label: "Instructors", count: 22 },
];

const standardResults = [
  {
    title: "Practical ML for Product Managers",
    description: "Bridge the gap between business requirements and AI capabilities.",
    meta: "8 Weeks â€¢ Intermediate",
    price: "Â£299",
    image:
      "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Computer Vision Fundamentals",
    description: "Implement image recognition systems from scratch using PyTorch.",
    meta: "12 Weeks â€¢ Advanced",
    price: "Â£450",
    image:
      "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "MLOps: Deploying Models",
    description: "Learn to scale and monitor machine learning pipelines in production.",
    meta: "6 Weeks â€¢ Intermediate",
    price: "Â£199",
    // no image -- design shows a placeholder icon tile for this card
  },
];

interface SearchPageProps {
  searchParams: Promise<{ q?: string }>;
}

export default async function SearchResultsPage({ searchParams }: SearchPageProps) {
  const resolvedParams = await searchParams;
  const query = resolvedParams.q ?? "Machine Learning";

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-8 px-12 py-10">
        <div className="flex flex-col gap-2">
          <h1 className="text-5xl font-bold leading-[52.8px] text-[var(--token-color-ink)]">
            Results for &quot;{query}&quot;
          </h1>
          <p className="text-base text-[var(--token-color-inkSoft)]">Found 142 results across all categories</p>
          <ResultFilterTabs tabs={filterTabs} />
        </div>

        <div className="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <FeaturedResultCard
            badge="Bestseller"
            pathLabel="Data Science Path"
            title="Advanced Machine Learning Specialization"
            description="Master deep learning, neural networks, and scalable AI infrastructure with industry-leading mentors."
            instructorName="Dr. Elena Rostova"
            instructorAvatar="https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=100&q=80"
            rating={4.9}
            reviews="2.1k"
            image="https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=800&q=80"
          />

          <InstructorResultCard
            name="Marcus Chen"
            title="Principal AI Engineer @ TechFlow"
            avatar="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=200&q=80"
            tags={["Python", "TensorFlow"]}
            bio="Helping professionals transition into scalable AI engineering roles."
          />
        </div>

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {standardResults.map((result) => (
            <StandardResultCard key={result.title} {...result} />
          ))}
        </div>

        <ResultsPagination totalPages={12} />
      </main>

      <CompactFooter />
    </div>
  );
}
