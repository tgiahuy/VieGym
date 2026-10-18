import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { aiRulesApi } from '../../ai-rules/api'
import type { AiMetrics } from '../../ai-rules/types'

export const AiOutcomeCard: React.FC = () => {
  const navigate = useNavigate()
  const [metrics, setMetrics] = useState<AiMetrics | null>(null)
  const [error, setError] = useState(false)

  useEffect(() => {
    aiRulesApi.metrics().then(setMetrics).catch(() => setError(true))
  }, [])

  const values = metrics
    ? [
        ['Requests', metrics.requests24h, '24 giờ qua'],
        ['Succeeded', metrics.succeeded24h, 'Hoàn tất'],
        ['Failed', metrics.failed24h, 'Lỗi provider/output'],
        ['Blocked', metrics.blocked24h, 'Guardrail'],
      ] as const
    : []

  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-[18px] p-6 flex flex-col justify-between">
      <div>
        <div className="flex items-center justify-between pb-4 border-b border-[#292a2f]">
          <div>
            <h2 className="text-[16px] font-bold text-[#f5f5f6]">AI Outcome &amp; Recommendations</h2>
            <p className="text-xs text-[#a7a9ae] mt-0.5">Telemetry thực từ AI requests trong 24 giờ</p>
          </div>
          {metrics && (
            <span className="px-2 py-0.5 rounded text-[11px] font-semibold bg-[#9b7bff]/15 text-[#9b7bff] border border-[#9b7bff]/25 font-mono">
              Latency: {metrics.averageLatencyMs === null ? 'N/A' : `${metrics.averageLatencyMs} ms`}
            </span>
          )}
        </div>

        {error && <div className="py-8 text-sm text-[#ff5a5f]">Không thể tải telemetry AI.</div>}
        {!error && !metrics && <div className="py-8 text-sm text-[#8a8d93]">Đang tải telemetry AI...</div>}
        {metrics && (
          <>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 my-4">
              {values.map(([label, value, note]) => (
                <div key={label} className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex flex-col">
                  <span className="text-[11px] text-[#8a8d93] uppercase font-semibold">{label}</span>
                  <span className="text-lg font-bold text-[#f5f5f6] mt-1">{value}</span>
                  <span className="text-[10px] text-[#a7a9ae] mt-0.5">{note}</span>
                </div>
              ))}
            </div>
            <div className="p-4 rounded-xl bg-[#222327] border border-[#9b7bff]/20 text-sm text-[#a7a9ae]">
              Provider: <strong className="text-[#f5f5f6]">{metrics.provider}</strong> · Model:{' '}
              <strong className="text-[#f5f5f6]">{metrics.model}</strong> · Service:{' '}
              <strong className={metrics.serviceReachable ? 'text-[#35c76f]' : 'text-[#ff5a5f]'}>
                {metrics.serviceReachable ? 'reachable' : 'unavailable'}
              </strong>
            </div>
          </>
        )}
      </div>

      <div className="pt-4 mt-4 border-t border-[#292a2f]/60 flex items-center justify-between text-xs">
        <span className="text-[#8a8d93]">Không sử dụng số liệu mẫu</span>
        <button type="button" onClick={() => navigate('/ai-config')} className="text-[#9b7bff] hover:underline font-semibold flex items-center gap-1 cursor-pointer">
          <span>Cấu hình mô hình AI</span>
          <span className="material-symbols-outlined text-xs">chevron_right</span>
        </button>
      </div>
    </div>
  )
}
