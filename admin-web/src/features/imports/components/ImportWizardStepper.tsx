import React from 'react'
import { ImportStep } from '../types'

interface ImportWizardStepperProps {
  currentStep: ImportStep
  onStepClick?: (step: ImportStep) => void
}

export const ImportWizardStepper: React.FC<ImportWizardStepperProps> = ({
  currentStep,
  onStepClick,
}) => {
  const steps = [
    { number: 1 as ImportStep, title: 'Bước 1', subtitle: 'Tải file lên' },
    { number: 2 as ImportStep, title: 'Bước 2', subtitle: 'Ánh xạ & Kiểm tra' },
    { number: 3 as ImportStep, title: 'Bước 3', subtitle: 'Xác nhận ghi dữ liệu' },
    { number: 4 as ImportStep, title: 'Bước 4', subtitle: 'Kết quả import' },
  ]

  // Calculate progress bar width
  const progressPercent =
    currentStep === 1
      ? 12
      : currentStep === 2
        ? 40
        : currentStep === 3
          ? 70
          : 100

  return (
    <div className="bg-[#17181b] rounded-2xl border border-[#292a2f] p-5 mb-7 shadow-sm">
      <div className="max-w-4xl mx-auto">
        <div className="grid grid-cols-4 relative">
          {/* Step Connectors */}
          <div className="absolute top-5 left-[12%] right-[12%] h-[2px] bg-[#292a2f] z-0">
            <div
              className="h-full bg-gradient-to-r from-[#35c76f] via-[#ff506d] to-[#ff506d] transition-all duration-300"
              style={{ width: `${progressPercent}%` }}
            />
          </div>

          {steps.map((step) => {
            const isCompleted = step.number < currentStep
            const isActive = step.number === currentStep
            const isUpcoming = step.number > currentStep

            return (
              <button
                type="button"
                key={step.number}
                onClick={() => onStepClick && onStepClick(step.number)}
                className={`relative z-10 flex flex-col items-center text-center transition-all focus:outline-none ${
                  isUpcoming ? 'opacity-60 hover:opacity-80' : 'cursor-pointer'
                }`}
              >
                {isCompleted ? (
                  <div className="w-10 h-10 rounded-full bg-[#35c76f]/20 border-2 border-[#35c76f] text-[#35c76f] flex items-center justify-center font-bold text-sm bg-[#17181b] shadow-md transition-all">
                    <span className="material-symbols-outlined text-[20px]">check</span>
                  </div>
                ) : isActive ? (
                  <div className="w-10 h-10 rounded-full bg-[#ff506d] text-white flex items-center justify-center font-bold text-sm shadow-lg shadow-[#ff506d]/40 ring-4 ring-[#ff506d]/20 bg-[#17181b] transition-all">
                    {step.number}
                  </div>
                ) : (
                  <div className="w-10 h-10 rounded-full bg-[#222327] border border-[#292a2f] text-[#8a8d93] flex items-center justify-center font-bold text-sm bg-[#17181b] transition-all">
                    {step.number}
                  </div>
                )}

                <span
                  className={`text-sm mt-2 font-semibold ${
                    isActive ? 'text-[#ff506d]' : isCompleted ? 'text-[#f5f5f6]' : 'text-[#8a8d93]'
                  }`}
                >
                  {step.title}
                </span>
                <span
                  className={`text-xs ${
                    isActive ? 'text-[#f5f5f6] font-medium' : 'text-[#8a8d93]'
                  }`}
                >
                  {step.subtitle}
                </span>
              </button>
            )
          })}
        </div>
      </div>
    </div>
  )
}
