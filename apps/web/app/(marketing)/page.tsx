import Link from "next/link";
import { Button, Card, Badge } from "@saachi/ui";

const categories = [
  { title: "AI Automation & Workflow Tools", desc: "n8n, Zapier, Make.com" },
  { title: "AI for Marketing & Sales", desc: "Ad copy, lead gen, campaigns" },
  { title: "AI Website & App Development", desc: "Build with AI-assisted tools" },
  { title: "AI Integration for Developers", desc: "OpenAI, Claude, Gemini APIs" }
];

export default function HomePage() {
  return (
    <main>
      {/* Hero */}
      <section
        style={{
          textAlign: "center",
          padding: "96px 24px 64px",
          background:
            "radial-gradient(ellipse 60% 50% at 50% 0%, rgba(59,130,246,0.12), transparent 70%)"
        }}
      >
        <Badge variant="info">Now in early access</Badge>
        <h1
          style={{
            fontSize: "48px",
            fontWeight: 700,
            lineHeight: 1.12,
            marginTop: "20px",
            maxWidth: "760px",
            marginLeft: "auto",
            marginRight: "auto"
          }}
        >
          Learn practical{" "}
          <span
            style={{
              background: "linear-gradient(90deg, #60A5FA 0%, #22D3EE 50%, #818CF8 100%)",
              WebkitBackgroundClip: "text",
              backgroundClip: "text",
              color: "transparent"
            }}
          >
            AI skills
          </span>
          . Build real things. Get paid to teach.
        </h1>
        <p
          style={{
            color: "var(--text-secondary)",
            fontSize: "18px",
            maxWidth: "600px",
            margin: "24px auto 32px"
          }}
        >
          Saachi AI is a skills-first marketplace where practitioners teach and learners build,
          not just watch.
        </p>
        <div style={{ display: "flex", gap: "16px", justifyContent: "center" }}>
          <Link href="/register">
            <Button size="lg">Get Started</Button>
          </Link>
          <Link href="/courses">
            <Button size="lg" variant="secondary">
              Browse Courses
            </Button>
          </Link>
        </div>
      </section>

      {/* Category grid */}
      <section style={{ padding: "64px 24px", maxWidth: "1120px", margin: "0 auto" }}>
        <h2 style={{ fontSize: "28px", fontWeight: 700, textAlign: "center", marginBottom: "40px" }}>
          Explore top categories
        </h2>
        <div
          style={{
            display: "grid",
            gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))",
            gap: "24px"
          }}
        >
          {categories.map((c) => (
            <Card key={c.title}>
              <h3 style={{ fontSize: "18px", fontWeight: 600, marginBottom: "8px" }}>{c.title}</h3>
              <p style={{ color: "var(--text-secondary)", fontSize: "14px" }}>{c.desc}</p>
            </Card>
          ))}
        </div>
      </section>
    </main>
  );
}
