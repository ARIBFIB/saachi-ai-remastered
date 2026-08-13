import { CoursePlayerClient } from "./CoursePlayerClient";

interface CoursePlayerPageProps {
  params: Promise<{ slug: string }>;
}

export default async function CoursePlayerPage({ params }: CoursePlayerPageProps) {
  const { slug } = await params;
  return <CoursePlayerClient courseSlug={slug} />;
}