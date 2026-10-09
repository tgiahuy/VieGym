import React, { useEffect } from 'react'
import { AuditLogItem } from '../types'

interface AuditDetailDrawerProps {
  isOpen: boolean
  log: AuditLogItem | null
  onClose: () => void
  onCopyCorrelationId: (id: string) => void
}

export const AuditDetailDrawer: React.FC<AuditDetailDrawerProps> = ({
  isOpen,
  log,
  onClose,
  onCopyCorrelationId,
}) => {
  // ESC key handler
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose()
      }
    }
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [isOpen, onClose])

  if (!isOpen || !log) return null

  return (
    <div
      className="fixed inset-0 z-50 flex justify-end bg-black/64 backdrop-blur-sm transition-opacity duration-200 animate-fadeIn"
      onClick={onClose}
    >
      {/* Drawer Panel Canvas: 760px width */}
      <div
        className="w-full max-w-[760px] h-full bg-[#1c1d21] border-l border-[#292a2f] flex flex-col justify-between shadow-2xl overflow-hidden relative animate-in slide-in-from-right duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Drawer Header (Sticky) */}
        <div className="p-6 bg-[#1c1d21] border-b border-[#292a2f] flex items-start justify-between shrink-0">
          <div className="flex items-start gap-3.5">
            <div className="w-11 h-11 rounded-xl bg-[#9b7bff]/15 border border-[#9b7bff]/30 text-[#9b7bff] flex items-center justify-center shrink-0 shadow-inner">
              <span className="material-symbols-outlined text-2xl">verified</span>
            </div>
            <div className="flex flex-col">
              <div className="flex items-center gap-2">
                <h2 className="text-xl font-bold text-[#f5f5f6]">Chi tiết sự kiện kiểm toán</h2>
                <span className="px-2 py-0.5 rounded-full text-xs font-semibold bg-[#4d8dff]/15 text-[#4d8dff] border border-[#4d8dff]/30">
                  {log.action}
                </span>
              </div>
              <p className="text-xs text-[#a7a9ae] mt-0.5">
                Sự kiện <span className="font-mono text-[#f5f5f6] font-bold">#{log.eventId}</span>{' '}
                · Phân loại: <strong className="text-[#f5f5f6]">{log.targetType}</strong>
              </p>
            </div>
          </div>

          {/* Close Drawer Trigger */}
          <button
            type="button"
            onClick={onClose}
            className="p-2 rounded-xl text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#222327] border border-[#292a2f] transition-colors cursor-pointer"
            title="Đóng ngăn chi tiết (Esc)"
          >
            <span className="material-symbols-outlined text-xl">close</span>
          </button>
        </div>

        {/* Drawer Body: Scrollable Independent Content */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          {/* Sanitized Security Notice Banner */}
          <div className="p-3.5 rounded-xl bg-[#222327] border border-[#34363b] flex items-start gap-3">
            <span className="material-symbols-outlined text-[#f4b740] text-lg mt-0.5 shrink-0">
              lock
            </span>
            <div className="text-xs text-[#a7a9ae] leading-relaxed">
              <strong className="text-[#f5f5f6]">Dữ liệu đã được chuẩn hóa bảo mật:</strong> Mọi thông tin nhạy cảm, số nhận diện cá nhân (PII), mật khẩu và khóa API được tự động ẩn mã hóa dưới định dạng{' '}
              <span className="font-mono font-bold text-[#8a8d93] bg-[#17181b] px-1.5 py-0.5 rounded border border-[#292a2f]">
                [REDACTED]
              </span>{' '}
              trước khi lưu vào sổ cái kiểm toán.
            </div>
          </div>

          {/* PHÂN KHU 1: SIÊU DỮ LIỆU SỰ KIỆN (Event Metadata Grid) */}
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-bold text-[#f5f5f6] flex items-center gap-2">
                <span className="material-symbols-outlined text-sm text-[#ff506d]">info</span>
                Siêu dữ liệu kiểm toán (Audit Metadata)
              </h3>
              <span className="text-xs font-mono text-[#8a8d93]">ISO 8601 Compliance</span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 p-4 rounded-xl bg-[#17181b] border border-[#292a2f]">
              {/* Metadata Item 1 */}
              <div className="flex flex-col p-2.5 rounded-lg bg-[#222327] border border-[#292a2f]/60">
                <span className="text-[11px] font-medium text-[#a7a9ae]">Thời gian ghi nhận</span>
                <span className="text-xs font-semibold text-[#f5f5f6] font-mono mt-0.5">
                  {log.timestamp} <span className="text-[#8a8d93] text-[11px]">(Asia/HCM)</span>
                </span>
              </div>

              {/* Metadata Item 2 */}
              <div className="flex flex-col p-2.5 rounded-lg bg-[#222327] border border-[#292a2f]/60">
                <span className="text-[11px] font-medium text-[#a7a9ae]">Người thực hiện (Actor)</span>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <span className="text-xs font-semibold text-[#f5f5f6] truncate">
                    {log.actor.email}
                  </span>
                  <span className="px-1.5 py-0.2 rounded text-[10px] font-bold bg-[rgba(242,48,90,0.15)] text-[#ff506d]">
                    {log.actor.role}
                  </span>
                </div>
                {log.actor.sessionId && (
                  <span className="text-[10px] text-[#8a8d93] font-mono mt-0.5">
                    Phiên: {log.actor.sessionId}
                  </span>
                )}
              </div>

              {/* Metadata Item 3 */}
              <div className="flex flex-col p-2.5 rounded-lg bg-[#222327] border border-[#292a2f]/60">
                <span className="text-[11px] font-medium text-[#a7a9ae]">Hành động (Action)</span>
                <div className="flex items-center gap-2 mt-0.5">
                  <span className="text-xs font-bold text-[#4d8dff]">{log.action}</span>
                  <span className="text-xs text-[#a7a9ae]">({log.actionDesc})</span>
                </div>
              </div>

              {/* Metadata Item 4 */}
              <div className="flex flex-col p-2.5 rounded-lg bg-[#222327] border border-[#292a2f]/60">
                <span className="text-[11px] font-medium text-[#a7a9ae]">
                  Đối tượng tác động (Target)
                </span>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <span className="font-mono text-xs font-bold text-[#2cc7b5]">
                    {log.targetType} {log.targetId}
                  </span>
                  <span className="text-xs text-[#f5f5f6] truncate">({log.targetName})</span>
                </div>
              </div>

              {/* Metadata Item 5 */}
              <div className="flex flex-col p-2.5 rounded-lg bg-[#222327] border border-[#292a2f]/60">
                <span className="text-[11px] font-medium text-[#a7a9ae]">Kết quả thực thi</span>
                <div className="flex items-center gap-2 mt-0.5">
                  <span className="text-xs font-bold text-[#35c76f] flex items-center gap-1">
                    <span className="material-symbols-outlined text-sm">check_circle</span>{' '}
                    {log.resultMessage}
                  </span>
                  <span className="text-xs font-mono text-[#a7a9ae]">
                    ({log.httpStatus || 'HTTP 200 OK'} · {log.latencyMs || 48}ms)
                  </span>
                </div>
              </div>

              {/* Metadata Item 6 */}
              <div className="flex flex-col p-2.5 rounded-lg bg-[#222327] border border-[#292a2f]/60">
                <span className="text-[11px] font-medium text-[#a7a9ae]">Địa chỉ IP &amp; Client</span>
                <div className="flex items-center gap-1.5 mt-0.5">
                  <span className="text-xs font-mono text-[#f5f5f6]">{log.ipAddress}</span>
                  <span className="text-[11px] text-[#a7a9ae]">({log.clientInfo})</span>
                </div>
                <span className="text-[10px] text-[#8a8d93]">
                  Giao thức: {log.protocol || 'TLS 1.3 AES-GCM-256'}
                </span>
              </div>

              {/* Metadata Item 7: Full Width Correlation ID */}
              <div className="sm:col-span-2 flex items-center justify-between p-2.5 rounded-lg bg-[#222327] border border-[#292a2f]/60">
                <div className="flex flex-col min-w-0 pr-2">
                  <span className="text-[11px] font-medium text-[#a7a9ae]">
                    Correlation ID (Request Trace)
                  </span>
                  <span className="text-xs font-mono text-[#ff506d] truncate mt-0.5">
                    {log.correlationId}
                  </span>
                </div>
                <button
                  type="button"
                  onClick={() => onCopyCorrelationId(log.correlationId)}
                  className="p-1.5 rounded-lg text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#1c1d21] transition-colors shrink-0 cursor-pointer"
                  title="Sao chép Correlation ID"
                >
                  <span className="material-symbols-outlined text-base">content_copy</span>
                </button>
              </div>
            </div>
          </div>

          {/* PHÂN KHU 2: BẢNG SO SÁNH THAY ĐỔI (Change Diff Table) */}
          {log.diffFields && log.diffFields.length > 0 && (
            <div className="space-y-3">
              <div className="flex items-center justify-between">
                <h3 className="text-sm font-bold text-[#f5f5f6] flex items-center gap-2">
                  <span className="material-symbols-outlined text-sm text-[#35c76f]">
                    difference
                  </span>
                  Bảng so sánh thay đổi giá trị (Data Diff)
                </h3>
                <span className="px-2 py-0.5 rounded text-[11px] font-medium bg-[#222327] text-[#a7a9ae] border border-[#292a2f]">
                  {log.diffFields.length} trường thay đổi
                </span>
              </div>

              <div className="rounded-xl border border-[#292a2f] bg-[#17181b] overflow-hidden">
                <table className="w-full text-left border-collapse">
                  <thead>
                    <tr className="h-10 bg-[#222327] border-b border-[#292a2f] text-[#f5f5f6] text-[12px] font-semibold">
                      <th className="px-4 py-2 w-[180px]">Trường thông tin</th>
                      <th className="px-4 py-2 w-[220px]">Giá trị trước (Before)</th>
                      <th className="px-4 py-2">Giá trị sau (After)</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-[#292a2f]/60 font-mono text-xs">
                    {log.diffFields.map((diff, idx) => (
                      <tr
                        key={idx}
                        className={`hover:bg-[#222327]/50 transition-colors ${
                          diff.isRedacted ? 'bg-[#222327]/20' : ''
                        }`}
                      >
                        <td className="px-4 py-3 font-semibold text-[#f5f5f6] font-sans flex items-center gap-1.5">
                          {diff.colorDot && (
                            <span
                              className="w-2 h-2 rounded-full"
                              style={{ backgroundColor: diff.colorDot }}
                            />
                          )}
                          {diff.isRedacted && (
                            <span className="material-symbols-outlined text-xs text-[#8a8d93]">
                              lock
                            </span>
                          )}
                          <span>{diff.fieldName}</span>
                        </td>
                        <td className="px-4 py-3 text-[#a7a9ae] line-through">
                          {diff.beforeValue}
                        </td>
                        <td className="px-4 py-3 bg-[#35c76f]/5 text-[#35c76f] font-bold">
                          <div className="flex items-center justify-between gap-2">
                            <span>{diff.afterValue}</span>
                            {diff.deltaBadge && (
                              <span className="px-1.5 py-0.2 rounded text-[10px] font-sans font-semibold bg-[#35c76f]/20 text-[#35c76f] border border-[#35c76f]/30">
                                {diff.deltaBadge}
                              </span>
                            )}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          )}

          {/* PHÂN KHU 3: PAYLOAD RAW JSON SANITIZED */}
          {log.rawPayload && (
            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <h3 className="text-xs font-semibold text-[#a7a9ae] uppercase tracking-wider flex items-center gap-1.5">
                  <span className="material-symbols-outlined text-sm">code</span>
                  Raw Audit Payload (JSON View)
                </h3>
                <span className="text-[11px] text-[#8a8d93] font-mono">
                  Payload Size: ~1.2 KB
                </span>
              </div>
              <div className="p-4 rounded-xl bg-[#0f1012] border border-[#292a2f] font-mono overflow-x-auto leading-relaxed text-xs">
                <pre className="text-[#a7a9ae] whitespace-pre-wrap">
                  {JSON.stringify(log.rawPayload, null, 2)}
                </pre>
              </div>
            </div>
          )}
        </div>

        {/* Drawer Sticky Footer (72px Standard) - STRICT READ-ONLY */}
        <div className="h-[72px] px-6 bg-[#1c1d21] border-t border-[#292a2f] flex items-center justify-between shrink-0">
          <button
            type="button"
            onClick={() => onCopyCorrelationId(log.correlationId)}
            className="h-11 px-4 rounded-xl bg-[#222327] hover:bg-[#17181b] border border-[#292a2f] text-[#f5f5f6] text-xs font-semibold flex items-center gap-2 transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-base text-[#a7a9ae]">content_copy</span>
            <span>Sao chép Correlation ID</span>
          </button>
          <button
            type="button"
            onClick={onClose}
            className="h-11 px-6 rounded-xl bg-[#222327] hover:bg-[#343537] text-[#f5f5f6] border border-[#34363b] text-xs font-semibold transition-colors cursor-pointer"
          >
            Đóng chi tiết
          </button>
        </div>
      </div>
    </div>
  )
}
