"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import Link from "next/link";
import { Save, ListTree, DollarSign, Eye } from "lucide-react";
import { Button, Input, Select, Textarea, Badge } from "@saachi/ui";
import { CATEGORIES } from "../../../../../lib/categories";

const LEVEL_OPTIONS = [
  { label: "Beginner", value: "beginner" },
  { label: "Intermediate", value: "intermediate" },
  { label: "Advanced", value: "advanced" }
];

const LANGUAGE_OPTIONS = [
  { label: "English", value: "en" },
  { label: "Urdu", value: "ur" }
];

export default function EditCoursePage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();

  // NOTE: demo-only local state, prefilled with placeholders. Replace with
  // useInstructorCourseDetail(params.id) once the backend endpoint and typed
  // hook are available.
  const [title, setTitle] = useState("");
  const [subtitle, setSubtitle] = useState("");
  const [category, setCategory] = useState(CATEGORIES[0]?.id ?? "");
  const [level, setLevel] = useState("beginner");
  const [language, setLanguage] = useState("en");
  const [saved, setSaved] = useState(false);

  function handleSave() {
    // NOTE: demo-only, no backend course-update mutation wired up yet.
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div className="mx-auto max-w-2xl">
      <div className="mb-1 flex items-center gap-2">
        <h1 className="font-display text-[26px] font-bold text-ink">Edit course</h1>
        <Badge>Draft</Badge>
      </div>
      <p className="mb-8 text-[14px] text-ink-soft">Course ID: {params.id}</p>

      <div className="mb-6 flex flex-wrap gap-2">
        <Link href={`/instructor/courses/${params.id}/curriculum`}>
          <Button size="sm" variant="secondary">
            <ListTree size={14} className="mr-1.5" />
            Curriculum
          </Button>
        </Link>
        <Link href={`/instructor/courses/${params.id}/pricing`}>
          <Button size="sm" variant="secondary">
            <DollarSign size={14} className="mr-1.5" />
            Pricing
          </Button>
        </Link>
        <Link href={`/instructor/courses/${params.id}/preview`}>
          <Button size="sm" variant="secondary">
            <Eye size={14} className="mr-1.5" />
            Preview
          </Button>
        </Link>
      </div>

      <div className="flex flex-col gap-4 rounded-card border border-line bg-card p-6">
        <Input
          label="Course title"
          required
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="e.g. n8n Automation Bootcamp"
        />
        <Input
          label="Subtitle"
          value={subtitle}
          onChange={(e) => setSubtitle(e.target.value)}
          placeholder="A short one-line summary"
        />
        <Select
          label="Category"
          options={CATEGORIES.map((c) => ({ label: c.name, value: c.id }))}
          value={category}
          onChange={(e) => setCategory(e.target.value)}
        />
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Select label="Level" options={LEVEL_OPTIONS} value={level} onChange={(e) => setLevel(e.target.value)} />
          <Select
            label="Language"
            options={LANGUAGE_OPTIONS}
            value={language}
            onChange={(e) => setLanguage(e.target.value)}
          />
        </div>
        <Textarea label="Description" rows={5} placeholder="Full course description" />
      </div>

      <div className="mt-6 flex items-center gap-3">
        <Button size="lg" onClick={handleSave}>
          <Save size={15} className="mr-1.5" />
          {saved ? "Saved" : "Save changes"}
        </Button>
        <Button size="lg" variant="secondary" onClick={() => router.push("/instructor/courses")}>
          Cancel
        </Button>
      </div>
    </div>
  );
}