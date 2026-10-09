import React from 'react'
import { ALLOWLIST_VARIABLES } from '../mockData'

interface VariableAllowlistProps {
  onCopyVariable: (tag: string) => void
}

export const VariableAllowlist: React.FC<VariableAllowlistProps> = ({ onCopyVariable }) => {
  return (
    <div className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] flex flex-col gap-3">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="material-symbols-outlined text-[#9b7bff] text-lg">vpn_key</span>
          <h3 className="text-sm font-bold text-[#f5f5f6]">
            Biến hệ thống được phép (Strict Allowlist — ADR-008 Compliance)
          </h3>
        </div>
        <span className="text-[11px] text-[#8a8d93]">Nhấp vào thẻ để sao chép tag</span>
      </div>

      {/* Tag Cloud */}
      <div className="flex flex-wrap gap-2 pt-1">
        {ALLOWLIST_VARIABLES.map((v) => (
          <button
            key={v.tag}
            type="button"
            onClick={() => onCopyVariable(v.tag)}
            className="group px-3 py-1.5 rounded-lg bg-[#222327] hover:bg-[#1c1d21] border border-[#292a2f] hover:border-[#f2305a]/50 text-left transition-colors cursor-pointer"
          >
            <div
              className="font-mono text-xs font-semibold group-hover:text-[#ff506d] transition-colors"
              style={{ color: v.color }}
            >
              {v.tag}
            </div>
            <div className="text-[10px] text-[#8a8d93]">{v.typeDesc}</div>
          </button>
        ))}
      </div>

      {/* PII Sanitization Notice */}
      <div className="mt-1 flex items-center gap-2 text-xs text-[#8a8d93] pt-2 border-t border-[#292a2f]/60">
        <span className="material-symbols-outlined text-sm text-[#f4b740]">lock</span>
        <span>
          <strong className="text-[#f5f5f6]">Bảo mật PII:</strong> Biến định danh cá nhân (tên thật, số điện thoại, email) bị chặn tuyệt đối ở tầng Sanitizer trước khi đưa vào context AI.
        </span>
      </div>
    </div>
  )
}
