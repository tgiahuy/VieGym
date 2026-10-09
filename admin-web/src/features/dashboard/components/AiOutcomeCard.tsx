import React from 'react'
import { useNavigate } from 'react-router-dom'

export const AiOutcomeCard: React.FC = () => {
  const navigate = useNavigate()

  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-[18px] p-6 flex flex-col justify-between">
      <div>
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-[#292a2f]">
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-lg bg-[#9b7bff]/15 flex items-center justify-center text-[#9b7bff]">
              <span className="material-symbols-outlined text-lg">neurology</span>
            </div>
            <div>
              <h2 className="text-[16px] font-bold text-[#f5f5f6]">
                AI Outcome &amp; Recommendations
              </h2>
              <p className="text-xs text-[#a7a9ae] mt-0.5">
                Hiệu suất và tỷ lệ chấp nhận khuyến nghị AI tự động
              </p>
            </div>
          </div>
          <span className="px-2 py-0.5 rounded text-[11px] font-semibold bg-[#9b7bff]/15 text-[#9b7bff] border border-[#9b7bff]/25 font-mono">
            Latency: 3.4s
          </span>
        </div>

        {/* AI Telemetry Grid (Tím Accent #9b7bff) */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 my-4">
          {/* Metric 1: Created */}
          <div className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex flex-col">
            <span className="text-[11px] text-[#8a8d93] uppercase font-semibold">Created</span>
            <span className="text-lg font-bold text-[#f5f5f6] mt-1">8,920</span>
            <span className="text-[10px] text-[#a7a9ae] mt-0.5">Khuyến nghị tạo</span>
          </div>

          {/* Metric 2: Applied */}
          <div className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex flex-col">
            <span className="text-[11px] text-[#9b7bff] font-semibold uppercase">Applied</span>
            <span className="text-lg font-bold text-[#9b7bff] mt-1">5,708</span>
            <span className="text-[10px] text-[#35c76f] font-medium mt-0.5">64% Chấp nhận</span>
          </div>

          {/* Metric 3: Dismissed */}
          <div className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex flex-col">
            <span className="text-[11px] text-[#8a8d93] uppercase font-semibold">Dismissed</span>
            <span className="text-lg font-bold text-[#a7a9ae] mt-1">3,212</span>
            <span className="text-[10px] text-[#8a8d93] mt-0.5">Bỏ qua / Đổi lịch</span>
          </div>

          {/* Metric 4: Timeout/Fallback */}
          <div className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex flex-col">
            <span className="text-[11px] text-[#ff5a5f] uppercase font-semibold">Fallback</span>
            <span className="text-lg font-bold text-[#ff5a5f] mt-1">0.12%</span>
            <span className="text-[10px] text-[#8a8d93] mt-0.5">Chuyển Rule-Engine</span>
          </div>
        </div>

        {/* AI Pipeline Operational Breakdown */}
        <div className="p-4 rounded-xl bg-[#222327] border border-[#9b7bff]/20 space-y-3">
          <div className="flex items-center justify-between text-xs">
            <span className="font-semibold text-[#f5f5f6] flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-[#9b7bff] animate-pulse" />
              Gợi ý điều chỉnh mức tạ tự động (RPE Auto-Progression)
            </span>
            <span className="text-[#9b7bff] font-semibold">72.4% Applied</span>
          </div>
          <div className="h-1.5 w-full bg-[#1f2022] rounded-full overflow-hidden">
            <div className="h-full bg-[#9b7bff]" style={{ width: '72.4%' }} />
          </div>

          <div className="flex items-center justify-between text-xs pt-1">
            <span className="font-semibold text-[#f5f5f6] flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-[#9b7bff]" />
              Tái cân bằng Macro theo lịch tập thực tế
            </span>
            <span className="text-[#9b7bff] font-semibold">58.1% Applied</span>
          </div>
          <div className="h-1.5 w-full bg-[#1f2022] rounded-full overflow-hidden">
            <div className="h-full bg-[#9b7bff]" style={{ width: '58.1%' }} />
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="pt-4 mt-4 border-t border-[#292a2f]/60 flex items-center justify-between text-xs">
        <span className="text-[#8a8d93]">
          Mô hình AI: VieGym-LLM v3.4 Fine-tuned Sports Nutrition
        </span>
        <button
          type="button"
          onClick={() => navigate('/ai-config')}
          className="text-[#9b7bff] hover:underline font-semibold flex items-center gap-1 cursor-pointer"
        >
          <span>Cấu hình mô hình AI</span>
          <span className="material-symbols-outlined text-xs">chevron_right</span>
        </button>
      </div>
    </div>
  )
}
