import Link from "next/link";
import Image from "next/image";
import { CheckCircle2, GraduationCap, FileText } from "lucide-react";

// TODO: replace with useOrder(orderId) hook from @saachi/api-client
interface OrderItem {
  id: string;
  title: string;
  instructor: string;
  price: number;
  image: string;
}

const orderNumber = "#ORD-2024-98765";

const orderItems: OrderItem[] = [
  {
    id: "o1",
    title: "Advanced Machine Learning Nanodegree",
    instructor: "Dr. Sarah Chen",
    price: 299,
    image:
      "https://images.unsplash.com/photo-1620712943543-bcc4688e7485?auto=format&fit=crop&w=200&q=80",
  },
  {
    id: "o2",
    title: "Python for Data Science Bootcamp",
    instructor: "Mark Johnson",
    price: 149,
    image:
      "https://images.unsplash.com/photo-1526379879527-8559ecfcaec0?auto=format&fit=crop&w=200&q=80",
  },
];

export default function OrderConfirmationPage() {
  const total = orderItems.reduce((sum, item) => sum + item.price, 0);

  return (
    <div className="flex min-h-screen items-center justify-center bg-[var(--token-color-bg)] px-6 py-24">
      <div className="flex w-full max-w-[672px] flex-col items-center rounded-[var(--token-radius-lg)] bg-[var(--token-color-surface)] p-10 shadow-[var(--token-shadow-sm)]">
        <div className="flex h-24 w-24 items-center justify-center rounded-full bg-[var(--token-color-success)]/10">
          <CheckCircle2
            size={40}
            color="var(--token-color-success)"
            strokeWidth={2.5}
          />
        </div>

        <h1
          className="pt-6 text-center text-5xl font-bold leading-[52.8px]"
          style={{ color: "var(--token-color-ink)" }}
        >
          Payment Successful!
        </h1>

        <p
          className="max-w-[544px] pt-2 text-center text-lg leading-7"
          style={{ color: "var(--token-color-inkSoft)" }}
        >
          Thank you for your purchase. Your learning journey begins now.
        </p>

        {/* Order summary */}
        <div
          className="mt-10 flex w-full flex-col gap-3.5 rounded-[var(--token-radius-md)] bg-[var(--token-color-surfaceAlt)] p-6"
          style={{ border: "1px solid var(--token-color-border)" }}
        >
          <div
            className="flex items-center justify-between border-b pb-4"
            style={{ borderColor: "var(--token-color-border)" }}
          >
            <span
              className="text-sm font-semibold tracking-wide"
              style={{ color: "var(--token-color-inkSoft)" }}
            >
              Order Number
            </span>
            <span
              className="text-base font-semibold"
              style={{ color: "var(--token-color-ink)" }}
            >
              {orderNumber}
            </span>
          </div>

          <span
            className="text-sm font-semibold tracking-wide"
            style={{ color: "var(--token-color-inkSoft)" }}
          >
            Summary
          </span>

          <div className="flex flex-col gap-4">
            {orderItems.map((item) => (
              <div key={item.id} className="flex items-start gap-4">
                <div className="relative h-16 w-16 shrink-0 overflow-hidden rounded-sm bg-[var(--token-color-border)]/30">
                  <Image
                    src={item.image}
                    alt={item.title}
                    fill
                    sizes="64px"
                    className="object-cover"
                  />
                </div>

                <div className="flex flex-1 flex-col">
                  <h4
                    className="text-lg font-semibold leading-7"
                    style={{ color: "var(--token-color-ink)" }}
                  >
                    {item.title}
                  </h4>
                  <span
                    className="text-sm"
                    style={{ color: "var(--token-color-inkSoft)" }}
                  >
                    Instructor: {item.instructor}
                  </span>
                </div>

                <span
                  className="shrink-0 text-2xl font-semibold"
                  style={{ color: "var(--token-color-ink)" }}
                >
                  ${item.price.toFixed(2)}
                </span>
              </div>
            ))}
          </div>

          <div
            className="flex items-center justify-between border-t pt-4"
            style={{ borderColor: "var(--token-color-border)" }}
          >
            <span
              className="text-2xl font-semibold"
              style={{ color: "var(--token-color-ink)" }}
            >
              Total
            </span>
            <span
              className="text-5xl font-bold leading-none"
              style={{ color: "var(--token-color-amber)" }}
            >
              ${total.toFixed(2)}
            </span>
          </div>
        </div>

        {/* Actions */}
        <div className="flex items-center justify-center gap-4 pt-10">
          <Link
            href="/dashboard/my-courses"
            className="flex h-11 w-56 items-center justify-center gap-2 rounded-[var(--token-radius-md)] text-sm font-semibold tracking-wide text-white shadow-[var(--token-shadow-sm)]"
            style={{ backgroundColor: "var(--token-color-amber)" }}
          >
            <GraduationCap size={16} />
            Go to My Courses
          </Link>

          <Link
            href="/invoice"
            className="flex h-11 w-44 items-center justify-center gap-2 rounded-[var(--token-radius-md)] border-2 text-sm font-semibold tracking-wide"
            style={{
              borderColor: "var(--token-color-border)",
              color: "var(--token-color-inkSoft)",
              backgroundColor: "var(--token-color-surface)",
            }}
          >
            <FileText size={14} />
            View Invoice
          </Link>
        </div>

        <p
          className="max-w-96 pt-6 text-center text-sm"
          style={{ color: "var(--token-color-inkSoft)" }}
        >
          A confirmation email has been sent to your registered email address.
        </p>
      </div>
    </div>
  );
}
