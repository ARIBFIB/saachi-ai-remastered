"use client";

import Lottie from "lottie-react";
import animationData from "../../public/animations/loading.json";

type LoadingSpinnerProps = {
  size?: number;
  label?: string;
  fullScreen?: boolean;
};

export function LoadingSpinner({ size = 72, label, fullScreen = false }: LoadingSpinnerProps) {
  const content = (
    <div className="flex flex-col items-center justify-center gap-3">
      <div style={{ width: size, height: size }}>
        <Lottie animationData={animationData} loop autoplay />
      </div>
      {label && <p className="text-[12.5px] text-ink-soft">{label}</p>}
    </div>
  );

  if (fullScreen) {
    return <div className="flex min-h-[60vh] w-full items-center justify-center">{content}</div>;
  }

  return content;
}

export function InlineSpinner({ size = 18 }: { size?: number }) {
  return (
    <div style={{ width: size, height: size }} className="inline-block">
      <Lottie animationData={animationData} loop autoplay />
    </div>
  );
}