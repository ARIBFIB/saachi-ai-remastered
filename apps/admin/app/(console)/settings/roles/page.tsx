"use client";

import { useState } from "react";
import { ShieldCheck, Plus, Check, X } from "lucide-react";
import { Button, Card, Input, Select, Modal, Badge } from "@saachi/ui";

type StaffRole = "super_admin" | "admin" | "finance_officer" | "support_officer";

type StaffAccount = {
  id: string;
  name: string;
  email: string;
  role: StaffRole;
};

const ROLE_OPTIONS = [
  { label: "Super Admin", value: "super_admin" },
  { label: "Admin", value: "admin" },
  { label: "Finance Officer", value: "finance_officer" },
  { label: "Support Officer", value: "support_officer" }
];

const ROLE_LABEL: Record<StaffRole, string> = {
  super_admin: "Super Admin",
  admin: "Admin",
  finance_officer: "Finance Officer",
  support_officer: "Support Officer"
};

const PERMISSION_MATRIX: { capability: string; roles: Record<StaffRole, boolean> }[] = [
  { capability: "Manage internal admin accounts", roles: { super_admin: true, admin: false, finance_officer: false, support_officer: false } },
  { capability: "Approve/reject courses", roles: { super_admin: true, admin: true, finance_officer: false, support_officer: false } },
  { capability: "Process payouts", roles: { super_admin: true, admin: true, finance_officer: true, support_officer: false } },
  { capability: "Issue refunds", roles: { super_admin: true, admin: true, finance_officer: true, support_officer: false } },
  { capability: "Ban/suspend users", roles: { super_admin: true, admin: true, finance_officer: false, support_officer: true } },
  { capability: "Handle support tickets", roles: { super_admin: true, admin: true, finance_officer: false, support_officer: true } },
  { capability: "Configure commission rates", roles: { super_admin: true, admin: false, finance_officer: false, support_officer: false } },
  { capability: "View financial reports", roles: { super_admin: true, admin: true, finance_officer: true, support_officer: false } },
  { capability: "Configure payment gateways", roles: { super_admin: true, admin: false, finance_officer: false, support_officer: false } }
];

const INITIAL_STAFF: StaffAccount[] = [
  { id: "1", name: "Abdul Rehman Irfan", email: "abdulrehman@saachi.ai", role: "super_admin" },
  { id: "2", name: "Finance Desk", email: "finance@saachi.ai", role: "finance_officer" },
  { id: "3", name: "Support Desk", email: "support@saachi.ai", role: "support_officer" }
];

export default function RolesPermissionsPage() {
  const [staff, setStaff] = useState(INITIAL_STAFF);
  const [showCreate, setShowCreate] = useState(false);
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [role, setRole] = useState<StaffRole>("support_officer");

  const handleCreate = () => {
    if (!name.trim() || !email.trim()) return;
    setStaff((prev) => [...prev, { id: String(Date.now()), name: name.trim(), email: email.trim(), role }]);
    setShowCreate(false);
    setName("");
    setEmail("");
    setRole("support_officer");
  };

  return (
    <main className="mx-auto max-w-[1000px] px-4 py-8 md:px-8 md:py-10">
      <div className="mb-6 flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-control border border-line text-ink">
            <ShieldCheck size={17} strokeWidth={1.75} />
          </div>
          <div>
            <h1 className="text-[22px] font-semibold text-ink">Roles & Permissions</h1>
            <p className="mt-0.5 text-[13px] text-ink-soft">Internal staff accounts and their permission scope.</p>
          </div>
        </div>
        <Button size="sm" onClick={() => setShowCreate(true)}>
          <Plus size={14} strokeWidth={1.75} /> New staff account
        </Button>
      </div>

      <div className="mb-8 flex flex-col gap-3">
        {staff.map((account) => (
          <Card key={account.id} className="flex items-center justify-between gap-4 p-4">
            <div>
              <p className="text-[14px] font-semibold text-ink">{account.name}</p>
              <p className="mt-0.5 text-[12.5px] text-ink-soft">{account.email}</p>
            </div>
            <Badge>{ROLE_LABEL[account.role]}</Badge>
          </Card>
        ))}
      </div>

      <p className="mb-3 text-[14px] font-semibold text-ink">Permission matrix</p>
      <div className="overflow-x-auto rounded-card border border-line bg-card">
        <table className="w-full min-w-[720px] border-collapse text-[13px]">
          <thead>
            <tr className="border-b border-line text-left text-ink-soft">
              <th className="px-4 py-3 font-medium">Capability</th>
              <th className="px-4 py-3 font-medium">Super Admin</th>
              <th className="px-4 py-3 font-medium">Admin</th>
              <th className="px-4 py-3 font-medium">Finance Officer</th>
              <th className="px-4 py-3 font-medium">Support Officer</th>
            </tr>
          </thead>
          <tbody>
            {PERMISSION_MATRIX.map((row) => (
              <tr key={row.capability} className="border-b border-line last:border-0">
                <td className="px-4 py-3 font-medium text-ink">{row.capability}</td>
                {(["super_admin", "admin", "finance_officer", "support_officer"] as StaffRole[]).map((r) => (
                  <td key={r} className="px-4 py-3">
                    {row.roles[r] ? (
                      <Check size={15} strokeWidth={2} className="text-success" />
                    ) : (
                      <X size={15} strokeWidth={2} className="text-ink-soft/40" />
                    )}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Modal
        open={showCreate}
        onClose={() => setShowCreate(false)}
        title="New staff account"
        footer={
          <>
            <Button variant="ghost" onClick={() => setShowCreate(false)}>Cancel</Button>
            <Button onClick={handleCreate} disabled={!name.trim() || !email.trim()}>Create account</Button>
          </>
        }
      >
        <div className="flex flex-col gap-4">
          <Input label="Full name" value={name} onChange={(e) => setName(e.target.value)} />
          <Input label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
          <Select label="Role" options={ROLE_OPTIONS} value={role} onChange={(e) => setRole(e.target.value as StaffRole)} />
        </div>
      </Modal>
    </main>
  );
}