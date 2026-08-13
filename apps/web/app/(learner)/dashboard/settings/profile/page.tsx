"use client";

import { useRef, useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Form, Input, Button as AntButton, message } from "antd";
import {
  LayoutGrid,
  GraduationCap,
  Heart,
  Settings,
  HelpCircle,
  User,
  Link2,
  Linkedin,
  Github,
} from "lucide-react";
import { SettingsNav } from "@/components/settings/SettingsNav";

// TODO: replace with useAuth() / useProfile() hooks from @saachi/api-client
interface ProfileFormValues {
  firstName: string;
  lastName: string;
  headline: string;
  bio: string;
  linkedin: string;
  github: string;
}

const initialProfile: ProfileFormValues = {
  firstName: "Alex",
  lastName: "Morgan",
  headline: "Senior Data Scientist @ TechCorp",
  bio: "Passionate about machine learning and building scalable AI solutions. Always eager to learn and share knowledge with the community.",
  linkedin: "",
  github: "",
};

const navItems = [
  { icon: LayoutGrid, label: "Dashboard", href: "/dashboard" },
  { icon: GraduationCap, label: "My Courses", href: "/dashboard/my-courses" },
  { icon: Heart, label: "Wishlist", href: "/dashboard/wishlist" },
  { icon: Settings, label: "Settings", href: "/dashboard/settings" },
];

export default function ProfileSettingsPage() {
  const [form] = Form.useForm<ProfileFormValues>();
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [avatarUrl, setAvatarUrl] = useState("https://i.pravatar.cc/128?img=47");
  const [displayName, setDisplayName] = useState(`${initialProfile.firstName} ${initialProfile.lastName}`);
  const [displayHeadline, setDisplayHeadline] = useState(initialProfile.headline);

  function handleChangeAvatarClick() {
    fileInputRef.current?.click();
  }

  function handleAvatarFileSelected(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    // TODO: wire to useProfile().uploadAvatar(file) from @saachi/api-client
    const previewUrl = URL.createObjectURL(file);
    setAvatarUrl(previewUrl);
  }

  function handleSubmit(values: ProfileFormValues) {
    // TODO: wire to useProfile().updateProfile(values) from @saachi/api-client
    console.log("save profile", values);
    setDisplayName(`${values.firstName} ${values.lastName}`);
    setDisplayHeadline(values.headline);
    message.success("Profile updated successfully.");
  }

  function handleCancel() {
    form.resetFields();
  }

  return (
    <div className="flex min-h-screen bg-[var(--token-color-bg)]">
      {/* Sidebar */}
      <aside className="fixed inset-y-0 left-0 hidden w-72 flex-col justify-between border-r border-[var(--token-color-border)] bg-[var(--token-color-surfaceAlt)] lg:flex">
        <div className="flex flex-col">
          <div className="flex items-center gap-4 border-b border-[var(--token-color-border)] p-6">
            <span className="relative block h-12 w-12 shrink-0 overflow-hidden rounded-full">
              <Image
                src="https://i.pravatar.cc/96?img=47"
                alt="Learner avatar"
                fill
                sizes="48px"
                className="object-cover"
              />
            </span>
            <div className="flex flex-col">
              <span className="text-lg font-bold" style={{ color: "var(--token-color-ink)" }}>
                Learner Portal
              </span>
              <span
                style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}
              >
                Manage your skills
              </span>
            </div>
          </div>

          <nav className="flex flex-col gap-2 p-4">
            {navItems.map(({ icon: Icon, label, href }) => {
              const isActive = label === "Settings";
              return (
                <Link
                  key={label}
                  href={href}
                  className="flex items-center gap-4 rounded-[var(--token-radius-md)] border-l-4 px-4 py-3 text-sm font-semibold tracking-wide transition"
                  style={{
                    borderColor: isActive ? "var(--token-color-amber)" : "transparent",
                    backgroundColor: isActive ? "var(--token-color-amberTint)" : "transparent",
                    color: isActive ? "var(--token-color-amber)" : "var(--token-color-inkSoft)",
                  }}
                >
                  <Icon size={18} />
                  {label}
                </Link>
              );
            })}
          </nav>
        </div>

        <div className="border-t border-[var(--token-color-border)] p-4">
          <Link
            href="/support"
            className="flex h-12 items-center gap-4 rounded-[var(--token-radius-md)] pl-4 text-sm font-semibold tracking-wide text-[var(--token-color-inkSoft)] hover:bg-[var(--token-color-surface)]"
          >
            <HelpCircle size={18} />
            Help Center
          </Link>
        </div>
      </aside>

      {/* Main column */}
      <div className="flex w-full flex-col lg:pl-72">
        <main className="flex-1 px-12 pb-28 pt-12">
          <div className="mx-auto flex w-full max-w-[896px] flex-col gap-10">
            {/* Header */}
            <div className="flex flex-col gap-2">
              <h1 className="text-3xl font-bold leading-10" style={{ color: "var(--token-color-ink)" }}>
                Profile Settings
              </h1>
              <p style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
                Manage your personal information and social connections.
              </p>
            </div>

            <div className="flex flex-col gap-10 lg:flex-row lg:items-start">
              <SettingsNav />

              <Form
                form={form}
                layout="vertical"
                requiredMark={false}
                initialValues={initialProfile}
                onFinish={handleSubmit}
                className="flex w-full flex-1 flex-col gap-6 lg:grid lg:grid-cols-[1fr_2fr] lg:items-start lg:gap-6"
              >
                {/* Avatar & Quick Info Card */}
                <div
                  className="flex flex-col items-center gap-1 rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] p-6 pb-8 pt-8 text-center shadow-[var(--token-shadow-md)]"
                >
                  <span className="relative block h-32 w-32 shrink-0 overflow-hidden rounded-full shadow-[var(--token-shadow-sm)]">
                    <Image src={avatarUrl} alt={displayName} fill sizes="128px" className="object-cover" />
                  </span>

                  <input
                    ref={fileInputRef}
                    type="file"
                    accept="image/*"
                    className="hidden"
                    onChange={handleAvatarFileSelected}
                  />

                  <h2 className="pt-4 text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                    {displayName}
                  </h2>
                  <span className="text-xs font-medium" style={{ color: "var(--token-color-inkSoft)" }}>
                    {displayHeadline}
                  </span>

                  <AntButton className="mt-6 w-full" onClick={handleChangeAvatarClick}>
                    Change Avatar
                  </AntButton>
                </div>

                {/* Right column */}
                <div className="flex flex-col gap-6">
                  {/* Personal Information */}
                  <div className="flex flex-col gap-6 rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]">
                    <h2 className="flex items-center gap-2 text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                      <User size={18} color="var(--token-color-amber)" />
                      Personal Information
                    </h2>

                    <div className="flex flex-col gap-6">
                      <div className="grid grid-cols-1 gap-6 sm:grid-cols-2">
                        <Form.Item
                          label="First Name"
                          name="firstName"
                          rules={[{ required: true, message: "Please enter your first name" }]}
                          className="mb-0"
                        >
                          <Input size="large" />
                        </Form.Item>

                        <Form.Item
                          label="Last Name"
                          name="lastName"
                          rules={[{ required: true, message: "Please enter your last name" }]}
                          className="mb-0"
                        >
                          <Input size="large" />
                        </Form.Item>
                      </div>

                      <Form.Item label="Professional Headline" name="headline" className="mb-0">
                        <Input size="large" placeholder="e.g. Senior Data Scientist @ TechCorp" />
                      </Form.Item>

                      <Form.Item label="Bio" name="bio" className="mb-0">
                        <Input.TextArea rows={4} placeholder="Tell us a bit about yourself" />
                      </Form.Item>
                    </div>
                  </div>

                  {/* Social Links */}
                  <div className="flex flex-col gap-6 rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] p-6 shadow-[var(--token-shadow-md)]">
                    <h2 className="flex items-center gap-2 text-2xl font-semibold leading-8" style={{ color: "var(--token-color-ink)" }}>
                      <Link2 size={16} color="var(--token-color-amber)" />
                      Social Links
                    </h2>

                    <div className="flex flex-col gap-3.5">
                      <Form.Item label="LinkedIn" name="linkedin" className="mb-0">
                        <Input
                          size="large"
                          prefix={<Linkedin size={16} color="var(--token-color-inkSoft)" />}
                          placeholder="https://linkedin.com/in/username"
                        />
                      </Form.Item>

                      <Form.Item label="GitHub" name="github" className="mb-0">
                        <Input
                          size="large"
                          prefix={<Github size={16} color="var(--token-color-inkSoft)" />}
                          placeholder="https://github.com/username"
                        />
                      </Form.Item>
                    </div>
                  </div>

                  {/* Action buttons */}
                  <div className="flex justify-end gap-4 pt-1">
                    <AntButton onClick={handleCancel}>Cancel</AntButton>
                    <AntButton type="primary" htmlType="submit">
                      Save Changes
                    </AntButton>
                  </div>
                </div>
              </Form>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
