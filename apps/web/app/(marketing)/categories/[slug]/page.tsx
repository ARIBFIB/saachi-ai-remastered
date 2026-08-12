import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { CategoryBanner } from "@/components/marketplace/CategoryBanner";
import { CategoryChips } from "@/components/marketplace/CategoryChips";
import { CategoryCourseCard, type CategoryCourseCardProps } from "@/components/marketplace/CategoryCourseCard";

// TODO: replace with useCategory(slug) hook from @saachi/api-client
interface CategoryDetail {
  slug: string;
  title: string;
  description: string;
  image: string;
  chips: string[];
  courses: CategoryCourseCardProps[];
}

const DUMMY_CATEGORIES: Record<string, CategoryDetail> = {
  "nlp": {
    slug: "nlp",
    title: "NLP & Language",
    description:
      "Learn to build, fine-tune, and deploy natural language processing systems -- from tokenizers to production-grade LLM pipelines.",
    image:
      "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [
      {
        title: "Natural Language Processing with Transformers",
        description: "Build production NLP pipelines using modern transformer architectures.",
        levelTag: "Intermediate",
        rating: 4.7,
        reviews: "2.3k",
        price: "$129.99",
        image:
          "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
      },
    ],
  },
  "computer-vision": {
    slug: "computer-vision",
    title: "Computer Vision",
    description: "Implement image recognition and detection systems from first principles.",
    image:
      "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [
      {
        title: "Computer Vision Fundamentals",
        description: "Implement image recognition systems from scratch using PyTorch.",
        levelTag: "Advanced",
        rating: 4.7,
        reviews: "1.1k",
        price: "$149.00",
        image:
          "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80",
      },
    ],
  },
  "robotics": {
    slug: "robotics",
    title: "Robotics",
    description: "From kinematics to reinforcement learning -- build intelligent robotic systems.",
    image:
      "https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [],
  },
  "ai-strategy": {
    slug: "ai-strategy",
    title: "AI Strategy",
    description: "Learn how leaders plan, govern, and scale AI initiatives across an organization.",
    image:
      "https://images.unsplash.com/photo-1551288049-bebda4e38f71?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [],
  },
};

function getCategoryBySlug(slug: string): CategoryDetail | null {
  return DUMMY_CATEGORIES[slug] ?? null;
}

interface CategoryPageProps {
  params: Promise<{ slug: string }>;
}

export default async function CategoryPage({ params }: CategoryPageProps) {
  const { slug } = await params;
  const category = getCategoryBySlug(slug);

  if (!category) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-6 px-6 py-10">
        <CategoryBanner title={category.title} description={category.description} image={category.image} />

        <CategoryChips chips={category.chips} />

        {category.courses.length === 0 ? (
          <div className="flex flex-col items-center gap-2 rounded-xl border border-[var(--token-color-border)] bg-[var(--token-color-surface)] py-20 text-center">
            <p className="text-lg font-semibold text-[var(--token-color-ink)]">
              No courses yet in this category
            </p>
            <p className="text-[var(--token-color-inkSoft)]">Check back soon -- new courses are added weekly.</p>
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-6 pt-4 sm:grid-cols-2 lg:grid-cols-3">
            {category.courses.map((course) => (
              <CategoryCourseCard key={course.title} {...course} />
            ))}
          </div>
        )}
      </main>

      <CompactFooter />
    </div>
  );
}