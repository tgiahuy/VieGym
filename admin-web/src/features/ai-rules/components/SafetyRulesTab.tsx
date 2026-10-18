import React, { useEffect, useState } from 'react'
import { aiRulesApi } from '../api'
import { SafetyRuleItem } from '../types'

interface SafetyRulesTabProps {
  onNotify: (msg: string) => void
}

export const SafetyRulesTab: React.FC<SafetyRulesTabProps> = ({ onNotify }) => {
  const [rules, setRules] = useState<SafetyRuleItem[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [updatingId, setUpdatingId] = useState<string | null>(null)

  useEffect(() => {
    aiRulesApi.listSafetyRules()
      .then(setRules)
      .catch((error: unknown) => {
        onNotify(error instanceof Error ? error.message : 'Không thể tải quy tắc an toàn')
      })
      .finally(() => setIsLoading(false))
  }, [onNotify])

  const handleToggle = async (rule: SafetyRuleItem) => {
    const next = !rule.isActive
    setUpdatingId(rule.id)
    try {
      const saved = await aiRulesApi.updateSafetyRule(rule, next)
      setRules((prev) => prev.map((item) => item.id === saved.id ? saved : item))
      onNotify(`${next ? 'Đã kích hoạt' : 'Đã vô hiệu hóa'} quy tắc an toàn #${rule.code}`)
    } catch (error) {
      onNotify(error instanceof Error ? error.message : 'Không thể cập nhật quy tắc an toàn')
    } finally {
      setUpdatingId(null)
    }
  }

  return (
    <div className="space-y-6">
      {/* Header Info */}
      <div className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-bold text-[#f5f5f6]">
            Danh mục Quy tắc an toàn Y tế &amp; Giới hạn sinh học
          </h3>
          <p className="text-xs text-[#a7a9ae] mt-1">
            Các quy tắc cứng (Hard Constraints) được kiểm tra bởi bộ lọc Guardrail trước khi xuất kết quả cho người dùng.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs text-[#35c76f] font-semibold bg-[#35c76f]/10 border border-[#35c76f]/20 px-3 py-1.5 rounded-xl flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-[#35c76f]" />
            {rules.filter((rule) => rule.isActive).length}/{rules.length} Guardrail Active
          </span>
        </div>
      </div>

      {/* Rules Table */}
      <div className="rounded-2xl border border-[#292a2f] bg-[#17181b] overflow-hidden">
        <div className="divide-y divide-[#292a2f]">
          {isLoading && (
            <div className="p-6 text-sm text-[#a7a9ae]">Đang tải quy tắc từ backend...</div>
          )}
          {!isLoading && rules.length === 0 && (
            <div className="p-6 text-sm text-[#a7a9ae]">Chưa có quy tắc an toàn.</div>
          )}
          {rules.map((rule) => (
            <div
              key={rule.id}
              className="p-5 flex flex-col lg:flex-row lg:items-center justify-between gap-4 hover:bg-[#1c1d21] transition-colors"
            >
              <div className="flex items-start gap-3.5 flex-1">
                <span
                  className={`material-symbols-outlined text-2xl mt-0.5 ${
                    rule.severity === 'critical'
                      ? 'text-[#ff5a5f]'
                      : rule.severity === 'warning'
                      ? 'text-[#f4b740]'
                      : 'text-[#4d8dff]'
                  }`}
                >
                  {rule.severity === 'critical'
                    ? 'emergency'
                    : rule.severity === 'warning'
                    ? 'warning'
                    : 'info'}
                </span>
                <div className="space-y-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className="font-mono text-xs font-bold px-2 py-0.5 rounded bg-[#222327] text-[#ff506d] border border-[#292a2f]">
                      #{rule.code}
                    </span>
                    <h4 className="text-sm font-bold text-[#f5f5f6]">{rule.name}</h4>
                    <span
                      className={`text-[10px] uppercase font-bold px-2 py-0.5 rounded-full ${
                        rule.severity === 'critical'
                          ? 'bg-[#ff5a5f]/15 text-[#ff5a5f] border border-[#ff5a5f]/25'
                          : 'bg-[#f4b740]/15 text-[#f4b740] border border-[#f4b740]/25'
                      }`}
                    >
                      {rule.severity}
                    </span>
                  </div>
                  <p className="text-xs text-[#a7a9ae] leading-relaxed">{rule.description}</p>
                  <div className="text-xs text-[#35c76f] flex items-center gap-1 font-medium pt-1">
                    <span className="material-symbols-outlined text-sm">auto_fix_high</span>
                    <span>Hành động tự động: {rule.action}</span>
                  </div>
                </div>
              </div>

              {/* Status Toggle */}
              <div className="flex items-center gap-3 self-end lg:self-center shrink-0">
                <span className="text-xs font-semibold text-[#a7a9ae]">
                  {rule.isActive ? 'Đang kích hoạt' : 'Tạm tắt'}
                </span>
                <button
                  type="button"
                onClick={() => void handleToggle(rule)}
                disabled={updatingId === rule.id}
                  className={`w-12 h-6 flex items-center rounded-full p-1 cursor-pointer transition-colors duration-200 ${
                    rule.isActive ? 'bg-[#f2305a]' : 'bg-[#292a2f]'
                  }`}
                >
                  <div
                    className={`bg-white w-4 h-4 rounded-full shadow-md transform transition-transform duration-200 ${
                      rule.isActive ? 'translate-x-6' : 'translate-x-0'
                    }`}
                  />
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
