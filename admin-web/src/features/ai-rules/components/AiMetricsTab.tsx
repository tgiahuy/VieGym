import React, { useEffect, useState } from 'react'
import { aiRulesApi } from '../api'
import type { AiMetrics } from '../types'

export const AiMetricsTab: React.FC = () => {
  const [metrics, setMetrics] = useState<AiMetrics | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    aiRulesApi.metrics()
      .then((value) => {
        setMetrics(value)
        setError(null)
      })
      .catch((reason: unknown) => {
        setError(reason instanceof Error ? reason.message : 'Không thể tải chỉ số AI')
      })
  }, [])

  if (error) {
    return (
      <div className="p-5 rounded-2xl bg-[#f2305a]/10 border border-[#f2305a]/30 text-[#ff506d] text-sm">
        {error}
      </div>
    )
  }

  if (!metrics) {
    return <div className="p-5 text-sm text-[#a7a9ae]">Đang tải telemetry AI từ backend...</div>
  }

  const successRate = metrics.requests24h === 0
    ? null
    : Math.round((metrics.succeeded24h / metrics.requests24h) * 10_000) / 100
  const cards = [
    { name: 'Yêu cầu AI (24 giờ)', value: String(metrics.requests24h), description: 'Ghi nhận từ bảng ai_requests' },
    { name: 'Tỷ lệ thành công', value: successRate === null ? 'Chưa có dữ liệu' : `${successRate}%`, description: `${metrics.succeeded24h} thành công / ${metrics.failed24h} thất bại` },
    { name: 'Guardrail đã chặn', value: String(metrics.blocked24h), description: 'Yêu cầu bị chặn trước khi trả kết quả' },
    { name: 'Độ trễ trung bình', value: metrics.averageLatencyMs === null ? 'Chưa có dữ liệu' : `${metrics.averageLatencyMs} ms`, description: 'Từ lúc bắt đầu đến khi hoàn tất request' },
  ]

  return (
    <div className="space-y-6">
      {metrics.warnings.map((warning) => (
        <div key={warning} className="p-4 rounded-xl bg-[#f4b740]/10 border border-[#f4b740]/30 text-[#f4b740] text-sm">
          {warning}
        </div>
      ))}
      <div className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] flex flex-wrap items-center justify-between gap-4">
        <div>
          <div className="text-xs text-[#8a8d93]">Provider đang hoạt động</div>
          <div className="mt-1 text-lg font-bold text-[#f5f5f6]">{metrics.provider} / {metrics.model}</div>
        </div>
        <span className={`px-3 py-1.5 rounded-full text-xs font-semibold border ${metrics.serviceReachable ? 'bg-[#35c76f]/10 text-[#35c76f] border-[#35c76f]/20' : 'bg-[#ff5a5f]/10 text-[#ff5a5f] border-[#ff5a5f]/20'}`}>
          {metrics.serviceReachable ? 'AI service reachable' : 'AI service unavailable'}
        </span>
      </div>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {cards.map((metric) => (
          <div key={metric.name} className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-3 shadow-sm">
            <div className="text-xs font-medium text-[#8a8d93]">{metric.name}</div>
            <div className="text-2xl font-bold font-mono text-[#f5f5f6]">{metric.value}</div>
            <p className="text-[11px] text-[#a7a9ae] border-t border-[#292a2f] pt-2">{metric.description}</p>
          </div>
        ))}
      </div>
    </div>
  )
}
