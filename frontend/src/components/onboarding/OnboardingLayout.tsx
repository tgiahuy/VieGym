import React from 'react';
import { FiArrowLeft } from 'react-icons/fi';
import { Progress } from '@/components/ui/progress';

interface OnboardingLayoutProps {
  step: number;
  totalSteps: number;
  title: string;
  onBack: () => void;
  children: React.ReactNode;
}

export const OnboardingLayout: React.FC<OnboardingLayoutProps> = ({ step, totalSteps, title, onBack, children }) => {
  const progressValue = (step / totalSteps) * 100;

  return (
    <div className="flex flex-col h-full">
      <div className="flex items-center justify-between">
        {step > 1 ? (
          <button
            onClick={onBack}
            className="flex items-center justify-center w-10 h-10 rounded-full bg-white/10 hover:bg-white/20"
            aria-label="Quay lại"
          >
            <FiArrowLeft className="w-5 h-5" />
          </button>
        ) : <div className="w-10 h-10" /> /* Placeholder for alignment */}
        <p className="text-sm font-bold text-muted-foreground">
          {step} / {totalSteps}
        </p>
      </div>

      <Progress value={progressValue} className="mt-4 h-1" />

      <div className="flex flex-col items-center flex-1 mt-12 text-center">
        <h1 className="text-4xl font-extrabold tracking-tight">{title}</h1>
        <div className="w-full max-w-sm mt-10">
          {children}
        </div>
      </div>
    </div>
  );
};