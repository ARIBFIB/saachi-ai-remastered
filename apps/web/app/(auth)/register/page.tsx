"use client";

import { useState } from "react";
import Link from "next/link";
import { Form, Input, Checkbox, Button, Typography, Avatar, Divider } from "antd";
import { GraduationCap, Video } from "lucide-react";
import { useRegister } from "@saachi/api-client";
import { useRouter } from "next/navigation";

const { Title, Text } = Typography;

type Role = "learner" | "instructor";

interface RegisterFormValues {
  fullName: string;
  email: string;
  password: string;
  agree: boolean;
}

export default function CreateAccountPage() {
  const router = useRouter();
  const registerMutation = useRegister();
  const [role, setRole] = useState<Role>("learner");
  const [form] = Form.useForm<RegisterFormValues>();

  async function handleFinish(values: RegisterFormValues) {
    try {
      await registerMutation.mutateAsync({
        fullName: values.fullName,
        email: values.email,
        password: values.password,
        confirmPassword: values.password,
        role
      });
      router.push("/dashboard");
    } catch {
      // registerMutation.isError below drives the inline antd message
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-[var(--token-color-bg)] px-4 py-24">
      <div className="flex w-full max-w-[1000px] overflow-hidden rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] shadow-[var(--token-shadow-md)]">
        {/* Left panel: brand + graphic */}
        <div
          className="relative hidden w-96 shrink-0 flex-col justify-between overflow-hidden p-10 md:flex"
          style={{
            background:
              "linear-gradient(160deg, var(--token-color-amber) 0%, var(--token-color-inkDeep) 100%)",
          }}
        >
          <div className="pointer-events-none absolute -top-32 left-1/2 h-64 w-64 -translate-x-1/2 rounded-full bg-[var(--token-color-surface)]/10 blur-[32px]" />
          <div className="pointer-events-none absolute -left-20 bottom-24 h-80 w-80 rounded-full bg-[var(--token-color-decorativeCyan)]/20 blur-[32px]" />

          <span className="relative text-2xl font-black text-[var(--token-color-surface)]">
            Saachi AI
          </span>

          <div className="relative flex flex-col gap-3.5 pb-6">
            <h1 className="text-3xl font-bold leading-10 text-[var(--token-color-surface)]">
              Empowering the
              <br />
              future of skills.
            </h1>
            <p className="text-lg leading-7 text-[var(--token-color-amberTint)]">
              Join our network of learners and industry experts to accelerate
              your AI journey.
            </p>
          </div>

          <div className="relative flex items-center">
            <Avatar.Group>
              <Avatar src="https://i.pravatar.cc/64?img=12" />
              <Avatar src="https://i.pravatar.cc/64?img=32" />
              <Avatar src="https://i.pravatar.cc/64?img=45" />
              <Avatar
                style={{
                  backgroundColor: "var(--token-color-amberDark)",
                  color: "var(--token-color-amberTint)",
                }}
              >
                +5k
              </Avatar>
            </Avatar.Group>
          </div>
        </div>

        {/* Right panel: form */}
        <div className="flex w-full flex-col gap-6 px-8 py-12 sm:px-16">
          <div className="flex flex-col gap-2">
            <Title level={2} style={{ margin: 0, color: "var(--token-color-ink)" }}>
              Create an account
            </Title>
            <Text style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-base)" }}>
              Join Saachi AI to start your journey.
            </Text>
          </div>

          {/* Role selector */}
          <div className="flex flex-col gap-2">
            <Text strong style={{ color: "var(--token-color-ink)", fontSize: "var(--token-font-size-sm)" }}>
              I am joining as a:
            </Text>
            <div className="flex gap-2">
              <RoleCard
                icon={<GraduationCap size={22} color="var(--token-color-amber)" />}
                label="Learner"
                selected={role === "learner"}
                onSelect={() => setRole("learner")}
              />
              <RoleCard
                icon={<Video size={20} color="var(--token-color-amber)" />}
                label="Instructor"
                selected={role === "instructor"}
                onSelect={() => setRole("instructor")}
              />
            </div>
          </div>

          <Form
            form={form}
            layout="vertical"
            requiredMark={false}
            onFinish={handleFinish}
            className="flex flex-col"
          >
            <Form.Item
              label="Full Name"
              name="fullName"
              rules={[{ required: true, message: "Please enter your full name" }]}
            >
              <Input size="large" placeholder="John Doe" />
            </Form.Item>

            <Form.Item
              label="Email Address"
              name="email"
              rules={[{ required: true, type: "email", message: "Please enter a valid email" }]}
            >
              <Input size="large" placeholder="john@example.com" />
            </Form.Item>

            <Form.Item
              label="Password"
              name="password"
              rules={[{ required: true, min: 8, message: "Must be at least 8 characters long." }]}
              extra={
                <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
                  Must be at least 8 characters long.
                </span>
              }
            >
              <Input.Password size="large" placeholder="Enter your password" />
            </Form.Item>

            <Form.Item
              name="agree"
              valuePropName="checked"
              rules={[
                {
                  validator: (_, value) =>
                    value ? Promise.resolve() : Promise.reject(new Error("You must agree before continuing")),
                },
              ]}
            >
              <Checkbox>
                <span style={{ color: "var(--token-color-inkSoft)" }}>
                  I agree to the{" "}
                  <Link href="/legal/terms" style={{ color: "var(--token-color-amber)" }}>
                    Terms of Service
                  </Link>{" "}
                  and{" "}
                  <Link href="/legal/privacy" style={{ color: "var(--token-color-amber)" }}>
                    Privacy Policy
                  </Link>
                  .
                </span>
              </Checkbox>
            </Form.Item>

            <Button type="primary" htmlType="submit" size="large" block>
              Create Account
            </Button>
          </Form>

          <Divider
            style={{ borderColor: "var(--token-color-inkDeep)", borderWidth: "2px", borderStyle: "solid" }}
            plain
          >
            <span style={{ color: "var(--token-color-inkSoft)", fontSize: "var(--token-font-size-xs)" }}>
              Or continue with
            </span>
          </Divider>

          <div className="flex gap-4">
            <Button size="large" block icon={<GoogleIcon />}>
              Google
            </Button>
            <Button size="large" block icon={<GithubIcon />}>
              GitHub
            </Button>
          </div>

          <p className="text-center text-base" style={{ color: "var(--token-color-inkSoft)" }}>
            Already have an account?{" "}
            <Link href="/login" style={{ color: "var(--token-color-amber)" }}>
              Sign in
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}

function RoleCard({
  icon,
  label,
  selected,
  onSelect,
}: {
  icon: React.ReactNode;
  label: string;
  selected: boolean;
  onSelect: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onSelect}
      className="flex flex-1 flex-col items-center gap-2 rounded-[var(--token-radius-md)] border px-4 pb-4 pt-3.5 text-sm font-semibold tracking-wide transition"
      style={{
        backgroundColor: selected ? "var(--token-color-amberTint)" : "var(--token-color-bg)",
        borderColor: selected ? "var(--token-color-amber)" : "var(--token-color-border)",
        color: "var(--token-color-ink)",
      }}
    >
      {icon}
      {label}
    </button>
  );
}

// Google and GitHub brand marks use their official fixed multi-color logos --
// these are not theme colors and are intentionally not tokenized, since
// substituting them would break brand recognition.
function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M18.8 10.2083C18.8 9.55825 18.7417 8.93325 18.6333 8.33325H10V11.8833H14.9333C14.7167 13.0249 14.0667 13.9916 13.0917 14.6416V16.9499H16.0667C17.8 15.3499 18.8 12.9999 18.8 10.2083Z" fill="#4285F4" />
      <path d="M9.99974 19.1667C12.4747 19.1667 14.5497 18.35 16.0664 16.95L13.0914 14.6417C12.2747 15.1917 11.2331 15.525 9.99974 15.525C7.61641 15.525 5.59141 13.9167 4.86641 11.75H1.81641V14.1167C3.32474 17.1083 6.41641 19.1667 9.99974 19.1667Z" fill="#34A853" />
      <path d="M4.86634 11.7416C4.68301 11.1916 4.57467 10.6083 4.57467 9.99993C4.57467 9.3916 4.68301 8.80827 4.86634 8.25827V5.8916H1.81634C1.19134 7.12493 0.833008 8.5166 0.833008 9.99993C0.833008 11.4833 1.19134 12.8749 1.81634 14.1083L4.19134 12.2583L4.86634 11.7416Z" fill="#FBBC05" />
      <path d="M9.99974 4.48325C11.3497 4.48325 12.5497 4.94992 13.5081 5.84992L16.1331 3.22492C14.5414 1.74159 12.4747 0.833252 9.99974 0.833252C6.41641 0.833252 3.32474 2.89159 1.81641 5.89159L4.86641 8.25825C5.59141 6.09159 7.61641 4.48325 9.99974 4.48325Z" fill="#EA4335" />
    </svg>
  );
}

function GithubIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        fillRule="evenodd"
        clipRule="evenodd"
        d="M10.0003 1.66675C5.39783 1.66675 1.66699 5.40341 1.66699 10.0142C1.66699 13.7017 4.05449 16.8309 7.36616 17.9342C7.78282 18.0109 7.93449 17.7534 7.93449 17.5317C7.93449 17.3342 7.92783 16.8084 7.92366 16.1126C5.60533 16.6167 5.11616 14.9934 5.11616 14.9934C4.73783 14.0284 4.19116 13.7717 4.19116 13.7717C3.43449 13.2551 4.24866 13.2651 4.24866 13.2651C5.08449 13.3234 5.52449 14.1251 5.52449 14.1251C6.26783 15.4001 7.47533 15.0317 7.94949 14.8184C8.02616 14.2792 8.24116 13.9117 8.47949 13.7034C6.62949 13.4926 4.68366 12.7759 4.68366 9.57758C4.68366 8.66675 5.00866 7.92091 5.54116 7.33758C5.45533 7.12675 5.16949 6.27758 5.62283 5.12925C5.62283 5.12925 6.32283 4.90425 7.91449 5.98425C8.5943 5.79884 9.29569 5.70441 10.0003 5.70341C10.7087 5.70675 11.4212 5.79925 12.087 5.98425C13.6778 4.90425 14.3762 5.12841 14.3762 5.12841C14.8312 6.27758 14.5445 7.12675 14.4595 7.33758C14.9928 7.92091 15.3162 8.66675 15.3162 9.57758C15.3162 12.7842 13.367 13.4901 11.5112 13.6967C11.8103 13.9542 12.0762 14.4634 12.0762 15.2426C12.0762 16.3576 12.0662 17.2584 12.0662 17.5317C12.0662 17.7551 12.2162 18.0151 12.6395 17.9334C16.0424 16.792 18.3351 13.6035 18.3337 10.0142C18.3337 5.40341 14.602 1.66675 10.0003 1.66675Z"
        fill="#191C1E"
      />
    </svg>
  );
}