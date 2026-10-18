import React, { useState } from 'react'
import { PromptTemplateItem } from '../types'

interface PromptEditorProps {
  template: PromptTemplateItem
  content: string
  onChangeContent: (val: string) => void
  onOpenDiff: () => void
  onOpenSandbox: () => void
}

export const PromptEditor: React.FC<PromptEditorProps> = ({
  template,
  content,
  onChangeContent,
  onOpenDiff,
  onOpenSandbox,
}) => {
  const [isEditMode, setIsEditMode] = useState(false)

  const lines = content.split('\n')
  const charCount = content.length
  const approxTokens = Math.ceil(charCount / 4)

  return (
    <div className="flex flex-col gap-4">
      {/* Template Header Card */}
      <div className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] flex flex-col gap-4">
        <div className="flex flex-col xl:flex-row xl:items-center justify-between gap-4 pb-4 border-b border-[#292a2f]">
          {/* Title & Model Meta */}
          <div className="flex flex-col gap-1.5">
            <div className="flex flex-wrap items-center gap-2.5">
              <h2 className="text-xl font-bold text-[#f5f5f6]">{template.title}</h2>
              <span className="font-mono text-xs px-2 py-0.5 rounded bg-[#222327] text-[#a7a9ae] border border-[#292a2f]">
                #{template.code}
              </span>
            </div>
            <div className="flex flex-wrap items-center gap-3 text-xs text-[#a7a9ae]">
              <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/30 font-medium">
                <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
                Phiên bản hiện hành: {template.version} ({template.status === 'production' ? 'Production' : 'Có bản nháp chưa phát hành'})
              </span>
              <span>•</span>
              <span className="flex items-center gap-1 font-mono text-[#9b7bff] font-medium">
                <span className="material-symbols-outlined text-sm">memory</span>
                Model: {template.model} / Fallback: {template.fallbackModel}
              </span>
            </div>
          </div>

          {/* Top Detail Actions */}
          <div className="flex items-center gap-2 shrink-0">
            <button
              type="button"
              onClick={onOpenDiff}
              className="h-9 px-3 rounded-lg bg-[#222327] hover:bg-[#1c1d21] text-[#f5f5f6] border border-[#292a2f] text-xs font-semibold flex items-center gap-1.5 transition-colors cursor-pointer"
            >
              <span className="material-symbols-outlined text-sm text-[#8a8d93]">difference</span>
              <span>So sánh Diff</span>
            </button>
            <button
              type="button"
              onClick={onOpenSandbox}
              className="h-9 px-3 rounded-lg bg-[#222327] hover:bg-[#1c1d21] text-[#f5f5f6] border border-[#292a2f] text-xs font-semibold flex items-center gap-1.5 transition-colors cursor-pointer"
            >
              <span className="material-symbols-outlined text-sm text-[#4d8dff]">play_arrow</span>
              <span>Sandbox Test</span>
            </button>
            <button
              type="button"
              onClick={() => setIsEditMode(!isEditMode)}
              className={`h-9 px-3 rounded-lg border text-xs font-semibold flex items-center gap-1.5 transition-colors cursor-pointer ${
                isEditMode
                  ? 'bg-[rgba(242,48,90,0.15)] text-[#ff506d] border-[#ff506d]/40'
                  : 'bg-[#222327] hover:bg-[#1c1d21] text-[#a7a9ae] hover:text-[#f5f5f6] border-[#292a2f]'
              }`}
            >
              <span className="material-symbols-outlined text-sm">
                {isEditMode ? 'visibility' : 'edit'}
              </span>
              <span>{isEditMode ? 'Xem định dạng' : 'Soạn thảo'}</span>
            </button>
          </div>
        </div>

        {/* Production Safety Warning Banner */}
        <div className="p-3.5 rounded-xl bg-[#f4b740]/10 border border-[#f4b740]/30 flex items-start gap-3">
          <span className="material-symbols-outlined text-[#f4b740] text-xl shrink-0 mt-0.5">
            bolt
          </span>
          <div className="text-xs leading-relaxed text-[#f5f5f6]">
            <strong className="text-[#f4b740] font-semibold">Đang dùng trong Production —</strong>{' '}
            Mọi thay đổi cần tạo bản nháp (Draft), chạy kiểm thử an toàn y tế và được phê duyệt
            trước khi Publish kích hoạt để phòng ngừa rủi ro chấn thương người dùng thực.
          </div>
        </div>
      </div>

      {/* Prompt Editor Container */}
      <div className="rounded-2xl bg-[#17181b] border border-[#292a2f] overflow-hidden">
        {/* Code Editor Header Bar */}
        <div className="h-11 px-4 bg-[#222327] border-b border-[#292a2f] flex items-center justify-between text-xs">
          <div className="flex items-center gap-3">
            <span className="font-semibold text-[#f5f5f6] flex items-center gap-1.5">
              <span className="material-symbols-outlined text-sm text-[#9b7bff]">description</span>
              System &amp; Task Instructions (Markdown/Monospace)
            </span>
            <span className="px-2 py-0.5 rounded text-[11px] bg-[#17181b] text-[#8a8d93] border border-[#292a2f] font-mono">
              UTF-8
            </span>
          </div>
          <div className="flex items-center gap-4 text-[#a7a9ae]">
            <div className="flex items-center gap-1.5">
              <span className="text-[#8a8d93]">Estimated:</span>
              <span className="font-mono font-semibold text-[#f5f5f6]">
                {approxTokens} tokens
              </span>
            </div>
            <div className="h-3 w-px bg-[#292a2f]" />
            <div className="flex items-center gap-2">
              <span className="text-[#8a8d93]">Context:</span>
              <div className="w-24 h-2 rounded-full bg-[#17181b] overflow-hidden border border-[#292a2f]">
                <div
                  className="bg-[#9b7bff] h-full rounded-full transition-all"
                  style={{ width: `${Math.min(100, template.contextWindowPct)}%` }}
                />
              </div>
              <span className="font-mono text-[11px] text-[#f5f5f6]">
                {template.contextWindowPct}% / 128k
              </span>
            </div>
          </div>
        </div>

        {/* Monospace Editor Body */}
        {isEditMode ? (
          <div className="p-4 bg-[#131417]">
            <textarea
              rows={18}
              value={content}
              onChange={(e) => onChangeContent(e.target.value)}
              className="w-full bg-[#17181b] border border-[#292a2f] rounded-xl p-4 font-mono text-sm leading-6 text-[#f5f5f6] focus:outline-none focus:border-[#ff506d] resize-y"
              placeholder="Nhập prompt template..."
            />
          </div>
        ) : (
          <div className="bg-[#131417] p-4 font-mono text-sm leading-6 overflow-x-auto selection:bg-[#f2305a]/30">
            <div className="grid grid-cols-[36px_1fr] gap-4">
              {/* Line Numbers */}
              <div className="select-none text-right text-[#8a8d93]/50 font-normal pr-2 border-r border-[#292a2f]">
                {lines.map((_, i) => (
                  <div key={i}>{i + 1}</div>
                ))}
              </div>
              {/* Highlighted Code Contents */}
              <div className="text-[#f5f5f6] font-normal whitespace-pre-wrap">
                {lines.map((line, idx) => {
                  if (line.startsWith('#')) {
                    return (
                      <div key={idx} className="text-[#8a8d93] italic font-semibold">
                        {line}
                      </div>
                    )
                  }
                  if (line.includes('TUYỆT ĐỐI KHÔNG')) {
                    return (
                      <div key={idx}>
                        <span className="text-[#ff5a5f] font-bold">TUYỆT ĐỐI KHÔNG</span>
                        {line.replace('TUYỆT ĐỐI KHÔNG', '')}
                      </div>
                    )
                  }
                  return <div key={idx}>{line}</div>
                })}
              </div>
            </div>
          </div>
        )}

        {/* Footer Meta in Editor */}
        <div className="px-4 py-2 bg-[#222327]/50 border-t border-[#292a2f] flex items-center justify-between text-xs text-[#8a8d93]">
          <span className="flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-[#35c76f]" />
            Nội dung đang hiển thị từ cấu hình đã lưu trên server
          </span>
          <span>
            {lines.length} dòng · {charCount} ký tự
          </span>
        </div>
      </div>
    </div>
  )
}
