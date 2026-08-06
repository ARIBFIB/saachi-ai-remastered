export default function AdminLoginPage() {
  return (
    <main
      style={{
        minHeight: "100vh",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        background: "var(--surface-bg)"
      }}
    >
      <div
        style={{
          background: "var(--surface-card)",
          padding: "40px",
          borderRadius: "16px",
          boxShadow: "0 4px 20px rgba(30,64,175,0.10)",
          width: "360px"
        }}
      >
        <h1 style={{ fontSize: "22px", fontWeight: 600, marginBottom: "8px" }}>
          Saachi AI - Admin
        </h1>
        <p style={{ color: "var(--text-secondary)", fontSize: "14px", marginBottom: "24px" }}>
          Internal staff access only. 2FA required.
        </p>
        {/* Login form + 2FA step to be wired in a later step */}
      </div>
    </main>
  );
}
