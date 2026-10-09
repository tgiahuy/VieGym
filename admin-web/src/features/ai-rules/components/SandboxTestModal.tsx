import React, { useState } from 'react'
import { PromptTemplateItem } from '../types'

interface SandboxTestModalProps {
  isOpen: boolean
  template: PromptTemplateItem
  onClose: () => void
}

export const SandboxTestModal: React.FC<SandboxTestModalProps> = ({
  isOpen,
  template,
  onClose,
}) => {
  const [fitnessLevel, setFitnessLevel] = useState('intermediate')
  const [primaryGoal, setPrimaryGoal] = useState('hypertrophy')
  const [hasBackInjury, setHasBackInjury] = useState(true)
  const [splitDays, setSplitDays] = useState('4')
  const [isRunning, setIsRunning] = useState(false)
  const [mockOutput, setMockOutput] = useState<string | null>(null)

  if (!isOpen) return null

  const handleRun = () => {
    setIsRunning(true)
    setMockOutput(null)
    setTimeout(() => {
      setIsRunning(false)
      if (hasBackInjury) {
        setMockOutput(`{
  "workout_plan_version": "v3.4",
  "user_goal": "${primaryGoal}",
  "split_days": ${splitDays},
  "guardrail_status": "TRIGGERED (Lower Back Injury Detected)",
  "modifications": [
    "Đã loại bỏ Barbell Back Squat -> Thay thế bằng Leg Press 45° (3 sets x 10 reps, RPE 7.5)",
    "Đã loại bỏ Conventional Deadlift -> Thay thế bằng Cable Pull-Through & Bulgarian Split Squat",
    "Gán bài tập phục hồi: Bird Dog & McGill Big 3 khởi động"
  ],
  "estimated_session_duration": "48 mins",
  "rpe_target": "7.0 - 8.0"
}`)
      } else {
        setMockOutput(`{
  "workout_plan_version": "v3.4",
  "user_goal": "${primaryGoal}",
  "split_days": ${splitDays},
  "guardrail_status": "CLEARED (No acute injury flags)",
  "schedule": [
    "Day 1: Upper Body Power (Barbell Bench Press, Barbell Row, Overhead Press)",
    "Day 2: Lower Body Strength (Barbell Back Squat, Romanian Deadlift, Calf Raise)",
    "Day 3: Rest & Mobility",
    "Day 4: Upper Body Hypertrophy (Incline DB Press, Lat Pulldown, Lateral Raise)"
  ],
  "rpe_target": "7.5 - 8.5"
}`)
      }
    }, 600)
  }

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/64 backdrop-blur-sm p-4 overflow-y-auto animate-fadeIn"
      onClick={onClose}
    >
      <div
        className="w-full max-w-[680px] bg-[#1c1d21] rounded-2xl border border-[#292a2f] shadow-2xl flex flex-col my-auto relative animate-in fade-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="h-16 px-6 border-b border-[#292a2f] flex items-center justify-between shrink-0">
          <div className="flex items-center gap-2.5">
            <span className="material-symbols-outlined text-[#4d8dff] text-xl">play_arrow</span>
            <div>
              <h3 className="text-base font-bold text-[#f5f5f6]">
                AI Sandbox Simulator — {template.code}
              </h3>
              <p className="text-xs text-[#8a8d93]">Kiểm thử mô phỏng với context hội viên</p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-lg bg-[#222327] hover:bg-[#17181b] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f] flex items-center justify-center transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-lg">close</span>
          </button>
        </div>

        {/* Body */}
        <div className="p-6 space-y-4 max-h-[70vh] overflow-y-auto">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-[#a7a9ae] mb-1.5">
                Cấp độ hội viên
              </label>
              <select
                value={fitnessLevel}
                onChange={(e) => setFitnessLevel(e.target.value)}
                className="w-full h-10 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-xs focus:outline-none"
              >
                <option value="beginner">Mới bắt đầu (Beginner)</option>
                <option value="intermediate">Trung bình (Intermediate)</option>
                <option value="advanced">Nâng cao (Advanced)</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#a7a9ae] mb-1.5">
                Mục tiêu chính
              </label>
              <select
                value={primaryGoal}
                onChange={(e) => setPrimaryGoal(e.target.value)}
                className="w-full h-10 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-xs focus:outline-none"
              >
                <option value="hypertrophy">Tăng cơ (Hypertrophy)</option>
                <option value="strength">Tăng sức mạnh (Strength)</option>
                <option value="fat_loss">Giảm mỡ (Fat Loss)</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-[#a7a9ae] mb-1.5">
                Cờ chấn thương lưng dưới (Lower Back)
              </label>
              <button
                type="button"
                onClick={() => setHasBackInjury(!hasBackInjury)}
                className={`w-full h-10 px-3.5 rounded-xl border text-xs font-semibold flex items-center justify-between transition-colors cursor-pointer ${
                  hasBackInjury
                    ? 'bg-[#ff5a5f]/15 text-[#ff5a5f] border-[#ff5a5f]/40'
                    : 'bg-[#222327] text-[#a7a9ae] border-[#292a2f]'
                }`}
              >
                <span>{hasBackInjury ? 'Có chấn thương (True)' : 'Bình thường (False)'}</span>
                <span className="material-symbols-outlined text-base">
                  {hasBackInjury ? 'warning' : 'check'}
                </span>
              </button>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#a7a9ae] mb-1.5">
                Số ngày tập/tuần
              </label>
              <select
                value={splitDays}
                onChange={(e) => setSplitDays(e.target.value)}
                className="w-full h-10 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-xs focus:outline-none"
              >
                <option value="3">3 ngày / tuần</option>
                <option value="4">4 ngày / tuần</option>
                <option value="5">5 ngày / tuần</option>
              </select>
            </div>
          </div>

          <button
            type="button"
            disabled={isRunning}
            onClick={handleRun}
            className="w-full h-11 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white text-sm font-semibold flex items-center justify-center gap-2 transition-all cursor-pointer disabled:opacity-50"
          >
            <span className="material-symbols-outlined text-lg">play_arrow</span>
            <span>{isRunning ? 'Đang chạy mô phỏng AI...' : 'Chạy thử nghiệm Sandbox'}</span>
          </button>

          {mockOutput && (
            <div className="space-y-1.5 pt-2">
              <span className="text-xs font-semibold text-[#35c76f] flex items-center gap-1">
                <span className="material-symbols-outlined text-sm">check_circle</span>
                Kết quả JSON schema phản hồi từ AI Gateway (580ms):
              </span>
              <pre className="p-4 rounded-xl bg-[#131417] border border-[#292a2f] text-xs font-mono text-[#f5f5f6] whitespace-pre-wrap overflow-x-auto">
                {mockOutput}
              </pre>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
