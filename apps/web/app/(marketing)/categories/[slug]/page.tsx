import { notFound } from "next/navigation";
import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { CategoryBanner } from "@/components/marketplace/CategoryBanner";
import { CategoryChips } from "@/components/marketplace/CategoryChips";
import {
  CategoryCourseCard,
  type CategoryCourseCardProps,
} from "@/components/marketplace/CategoryCourseCard";

// TODO: replace with useCategory(slug) + useCourseList({category: slug}) from @saachi/api-client
interface CategoryData {
  slug: string;
  title: string;
  description: string;
  image: string;
  chips: string[];
  courses: CategoryCourseCardProps[];
}

const DUMMY_CATEGORIES: Record<string, CategoryData> = {
  nlp: {
    slug: "nlp",
    title: "NLP & Language",
    description:
      "Courses on natural language processing, transformers, prompt engineering, and language-model application building.",
    image:
      "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [
      {
        title: "Natural Language Processing with Transformers",
        description: "Fine-tune transformer models for real-world NLP tasks using Hugging Face.",
        levelTag: "Intermediate",
        rating: 4.7,
        reviews: "2.3k",
        price: "$129.99",
        image:
          "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
      },
      {
        title: "Prompt Engineering Masterclass",
        description: "Master zero-shot, few-shot, and chain-of-thought prompting techniques.",
        levelTag: "Beginner",
        rating: 4.8,
        reviews: "3.2k",
        price: "$89.99",
        image:
          "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
      },
    ],
  },
  "computer-vision": {
    slug: "computer-vision",
    title: "Computer Vision",
    description: "Build image recognition, object detection, and generative vision applications.",
    image:
      "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=1200&q=80",
    chips: ["All", "Beginner", "Intermediate", "Advanced"],
    courses: [
      {
        title: "Computer Vision Fundamentals",
        description: "Implement image recognition systems from scratch using PyTorch.",
        levelTag: "Advanced",
        rating: 4.6,
        reviews: "1.1k",
        price: "$149.00",
        image:
          "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80",
      },
    ],
  },
};

interface CategoryPageProps {
  params: Promise<{ slug: string }>;
}

export default async function CategoryPage({ params }: CategoryPageProps) {
  const { slug } = await params;
  const category = DUMMY_CATEGORIES[slug];

  if (!category) {
    notFound();
  }

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-8 px-6 py-10">
        <CategoryBanner title={category.title} description={category.description} image={category.image} />

        <CategoryChips chips={category.chips} />

        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {category.courses.map((course) => (
            <CategoryCourseCard key={course.title} {...course} />
          ))}
        </div>
      </main>

      <CompactFooter />
    </div>
  );
}