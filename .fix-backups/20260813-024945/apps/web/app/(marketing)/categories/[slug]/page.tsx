import { Header } from "@/components/marketing/Header";
import { CompactFooter } from "@/components/marketing/CompactFooter";
import { CategoryBanner } from "@/components/marketplace/CategoryBanner";
import { CategoryChips } from "@/components/marketplace/CategoryChips";
import {
  CategoryCourseCard,
  type CategoryCourseCardProps,
} from "@/components/marketplace/CategoryCourseCard";

const subCategories = ["NLP", "Computer Vision", "Robotics", "Deep Learning", "Generative AI"];

const courses: CategoryCourseCardProps[] = [
  {
    title: "Applied Natural Language\u2026",
    description: "Build real-world NLP applications using transformers, BERT, and\u2026",
    levelTag: "Intermediate",
    rating: 4.8,
    reviews: "1.2k",
    price: "$89.99",
    image:
      "https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Computer Vision with PyTorch",
    description: "Master object detection, image segmentation, and advanced CNN architectures.",
    levelTag: "Advanced",
    rating: 4.9,
    reviews: "850",
    price: "$99.99",
    image:
      "https://images.unsplash.com/photo-1555255707-c07966088b7b?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Introduction to Robotics",
    description: "Learn the fundamentals of kinematics, control systems, and robotic motion planning.",
    levelTag: "Beginner",
    rating: 4.7,
    reviews: "2.1k",
    price: "$49.99",
    image:
      "https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=600&q=80",
  },
  {
    title: "Generative AI Fundamentals",
    description: "Understand GANs, diffusion models, and the architecture behind modern generative\u2026",
    levelTag: "Intermediate",
    rating: 4.9,
    reviews: "3.5k",
    price: "$129.99",
    image:
      "https://images.unsplash.com/photo-1677442136019-21780ecad995?auto=format&fit=crop&w=600&q=80",
  },
];

const categoryContent: Record<string, { title: string; description: string }> = {
  "ai-machine-learning": {
    title: "AI & Machine Learning",
    description:
      "Master the foundational concepts and advanced techniques powering the AI revolution. From neural networks to reinforcement learning, build intelligent systems.",
  },
};

interface CategoryPageProps {
  params: Promise<{ slug: string }>;
}

export default async function CategoryPage({ params }: CategoryPageProps) {
  const { slug } = await params;
  const content = categoryContent[slug] ?? categoryContent["ai-machine-learning"];

  return (
    <div className="flex min-h-screen flex-col bg-[var(--token-color-bg)]">
      <Header />

      <main className="mx-auto flex w-full max-w-[1280px] flex-1 flex-col gap-6 px-12 pb-10 pt-24">
        <CategoryBanner title={content.title} description={content.description} />

        <CategoryChips chips={subCategories} />

        <div className="grid grid-cols-1 gap-6 pt-2 sm:grid-cols-2 lg:grid-cols-4">
          {courses.map((course) => (
            <CategoryCourseCard key={course.title} {...course} />
          ))}
        </div>
      </main>

      <CompactFooter />
    </div>
  );
}