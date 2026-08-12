import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { FilterSidebar } from "@/components/marketplace/FilterSidebar";
import { SortDropdown } from "@/components/marketplace/SortDropdown";
import { Pagination } from "@/components/marketplace/Pagination";
import {
  MarketplaceCourseCard,
  type MarketplaceCourseCardProps,
} from "@/components/marketplace/MarketplaceCourseCard";

const courses: MarketplaceCourseCardProps[] = [
  {
    title: "Complete A.I. & Machine Learning Bootcamp",
    provider: "Dr. Angela Yu",
    rating: 4.8,
    reviews: "12.4k",
    price: "$89.99",
    categoryTag: "Machine Learning",
    levelTag: "Beginner",
    badge: { label: "Bestseller", variant: "light" },
    image:
      "https://images.unsplash.com/photo-1550439062-609e1531270e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Deep Learning Specialization (Andrewâ€¦",
    provider: "DeepLearning.AI",
    rating: 4.9,
    reviews: "89.1k",
    price: "$49.00",
    priceSuffix: "/mo",
    categoryTag: "Deep Learning",
    levelTag: "Advanced",
    image:
      "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Natural Language Processing withâ€¦",
    provider: "Hugging Face",
    rating: 4.7,
    reviews: "2.3k",
    price: "$129.99",
    categoryTag: "NLP",
    levelTag: "Intermediate",
    badge: { label: "New", variant: "dark" },
    image:
      "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
];

export default function CourseMarketplacePage() {
  return (
    <div className="flex min-h-screen flex-col bg-slate-50">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-6 px-12 pb-40 pt-20 md:flex-row md:gap-8">
        <div className="w-full shrink-0 md:w-56">
          <FilterSidebar />
        </div>

        <div className="flex flex-1 flex-col gap-6">
          <div className="flex items-center justify-between pb-4">
            <div className="flex items-baseline gap-3">
              <h1 className="text-2xl font-semibold text-zinc-900">
                Explore Courses
              </h1>
              <span className="text-base text-slate-600">
                (1,204 results)
              </span>
            </div>
            <SortDropdown />
          </div>

          <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {courses.map((course) => (
              <MarketplaceCourseCard key={course.title} {...course} />
            ))}
          </div>

          <div className="pt-10">
            <Pagination totalPages={12} />
          </div>
        </div>
      </main>

      <CompactFooter />
    </div>
  );
}
