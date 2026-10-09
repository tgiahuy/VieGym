import React from 'react'
import { AI_METRICS } from '../mockData'

export const AiMetricsTab: React.FC = () => {
  return (
    <div className="space-y-6">
      {/* 4 Key Metrics Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {AI_METRICS.map((metric, idx) => (
          <div
            key={idx}
            className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] flex flex-col justify-between gap-3 shadow-sm"
          >
            <div className="flex items-center justify-between text-xs text-[#8a8d93]">
              <span className="font-medium">{metric.name}</span>
              <span className="material-symbols-outlined text-base text-[#9b7bff]">monitoring</span>
            </div>
            <div>
              <div className="text-2xl sm:text-3xl font-bold font-mono text-[#f5f5f6]">
                {metric.value}
              </div>
              <div className="flex items-center gap-1.5 text-xs text-[#35c76f] mt-1 font-medium">
                <span className="material-symbols-outlined text-sm">trending_up</span>
                <span>{metric.change}</span>
              </div>
            </div>
            <p className="text-[11px] text-[#a7a9ae] border-t border-[#292a2f] pt-2 mt-1">
              {metric.description}
            </p>
          </div>
        ))}
      </div>

      {/* Model Clusters & Telemetry Health */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Cluster 1 */}
        <div className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined text-[#9b7bff]">dns</span>
              <h4 className="text-sm font-bold text-[#f5f5f6]">Trạng thái cụm AI Gateway</h4>
            </div>
            <span className="px-2 py-0.5 rounded text-xs font-semibold bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/20">
              Optimal
            </span>
          </div>

          <div className="space-y-3 text-xs">
            <div className="flex items-center justify-between p-3 rounded-xl bg-[#222327] border border-[#292a2f]">
              <div className="flex items-center gap-2.5">
                <span className="w-2 h-2 rounded-full bg-[#35c76f]" />
                <span className="font-semibold text-[#f5f5f6]">Claude 3.5 Sonnet (Primary)</span>
              </div>
              <span className="font-mono text-[#a7a9ae]">120 req/phút · 520ms</span>
            </div>

            <div className="flex items-center justify-between p-3 rounded-xl bg-[#222327] border border-[#292a2f]">
              <div className="flex items-center gap-2.5">
                <span className="w-2 h-2 rounded-full bg-[#35c76f]" />
                <span className="font-semibold text-[#f5f5f6]">OpenAI GPT-4o (High-Load Fallback)</span>
              </div>
              <span className="font-mono text-[#a7a9ae]">45 req/phút · 680ms</span>
            </div>

            <div className="flex items-center justify-between p-3 rounded-xl bg-[#222327] border border-[#292a2f]">
              <div className="flex items-center gap-2.5">
                <span className="w-2 h-2 rounded-full bg-[#35c76f]" />
                <span className="font-semibold text-[#f5f5f6]">Llama 3.1 Guard 70B (Safety Gate)</span>
              </div>
              <span className="font-mono text-[#a7a9ae]">180 req/phút · 120ms</span>
            </div>
          </div>
        </div>

        {/* Cluster 2 */}
        <div className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-4">
          <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined text-[#35c76f]">verified</span>
              <h4 className="text-sm font-bold text-[#f5f5f6]">Chỉ số Giám sát An toàn (Guardrail)</h4>
            </div>
            <span className="text-xs text-[#8a8d93]">24 giờ qua</span>
          </div>

          <div className="space-y-3 text-xs">
            <div className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-between">
              <span className="text-[#a7a9ae]">Số lần chặn bài tập chấn thương lưng</span>
              <span className="font-mono font-bold text-[#ff5a5f]">742 ca</span>
            </div>
            <div className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-between">
              <span className="text-[#a7a9ae]">Số lần lọc dị ứng thực phẩm nghiêm trọng</span>
              <span className="font-mono font-bold text-[#f4b740]">418 ca</span>
            </div>
            <div className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-between">
              <span className="text-[#a7a9ae]">Lần can thiệp hạ RPE quá tải</span>
              <span className="font-mono font-bold text-[#35c76f]">120 ca</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
