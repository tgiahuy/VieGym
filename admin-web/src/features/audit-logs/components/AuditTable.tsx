import React, { useState } from 'react'
import { AuditAction, AuditLogItem, AuditResultStatus } from '../types'

interface AuditTableProps {
  logs: AuditLogItem[]
  selectedLogId?: string
  onSelectLog: (log: AuditLogItem) => void
}

export const AuditTable: React.FC<AuditTableProps> = ({
  logs,
  selectedLogId,
  onSelectLog,
}) => {
  const [currentPage, setCurrentPage] = useState(1)
  const [pageSize, setPageSize] = useState(25)

  const totalLogs = logs.length
  const totalPages = Math.ceil(totalLogs / pageSize) || 1
  const startIndex = (currentPage - 1) * pageSize
  const paginatedLogs = logs.slice(startIndex, startIndex + pageSize)

  const renderActionBadge = (action: AuditAction) => {
    switch (action) {
      case 'CREATE':
        return (
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/30">
            CREATE
          </span>
        )
      case 'UPDATE':
        return (
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#4d8dff]/10 text-[#4d8dff] border border-[#4d8dff]/30">
            UPDATE
          </span>
        )
      case 'HIDE':
        return (
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#f4b740]/10 text-[#f4b740] border border-[#f4b740]/30">
            HIDE
          </span>
        )
      case 'LOCK':
        return (
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#ff5a5f]/10 text-[#ff5a5f] border border-[#ff5a5f]/30">
            LOCK
          </span>
        )
      case 'DELETE':
        return (
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#ff5a5f]/20 text-[#ff5a5f] border border-[#ff5a5f]/40">
            DELETE
          </span>
        )
      default:
        return (
          <span className="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#222327] text-[#a7a9ae] border border-[#34363b]">
            {action}
          </span>
        )
    }
  }

  const renderResultBadge = (status: AuditResultStatus) => {
    switch (status) {
      case 'SUCCESS':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/30">
            <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
            Thành công
          </span>
        )
      case 'WARNING':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-[#f4b740]/10 text-[#f4b740] border border-[#f4b740]/30">
            <span className="w-1.5 h-1.5 rounded-full bg-[#f4b740]" />
            Cảnh báo
          </span>
        )
      case 'FAILED':
        return (
          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-[#ff5a5f]/10 text-[#ff5a5f] border border-[#ff5a5f]/30">
            <span className="w-1.5 h-1.5 rounded-full bg-[#ff5a5f]" />
            Thất bại
          </span>
        )
    }
  }

  const renderTargetIdColor = (type: string) => {
    switch (type) {
      case 'FOOD':
        return 'text-[#2cc7b5]'
      case 'EXERCISE':
        return 'text-[#f5f5f6]'
      case 'USER':
        return 'text-[#cdbdff]'
      case 'RULE':
        return 'text-[#f4b740]'
      case 'PROMPT':
        return 'text-[#9b7bff]'
      default:
        return 'text-[#a7a9ae]'
    }
  }

  return (
    <section className="rounded-xl border border-[#292a2f] bg-[#17181b] overflow-hidden shadow-none flex flex-col">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="h-11 bg-[#17181b] border-b border-[#292a2f] text-[#f5f5f6] text-[12px] font-semibold tracking-wider">
              <th className="px-5 py-3 w-[190px]">Thời gian (Asia/HCM)</th>
              <th className="px-4 py-3">Người thực hiện</th>
              <th className="px-4 py-3 w-[110px]">Action</th>
              <th className="px-4 py-3">Đối tượng tác động</th>
              <th className="px-4 py-3 w-[140px]">Kết quả</th>
              <th className="px-4 py-3 w-[160px]">Địa chỉ IP</th>
              <th className="px-5 py-3 text-right w-[90px]">Chi tiết</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#292a2f]/60 text-sm font-normal">
            {paginatedLogs.length === 0 ? (
              <tr>
                <td colSpan={7} className="py-12 text-center text-[#8a8d93]">
                  <div className="flex flex-col items-center justify-center gap-2">
                    <span className="material-symbols-outlined text-4xl text-[#8a8d93]">history</span>
                    <p className="text-sm">Không tìm thấy bản ghi kiểm toán nào phù hợp với bộ lọc</p>
                  </div>
                </td>
              </tr>
            ) : (
              paginatedLogs.map((log) => {
                const isSelected = selectedLogId === log.id
                return (
                  <tr
                    key={log.id}
                    onClick={() => onSelectLog(log)}
                    className={`h-14 transition-colors cursor-pointer group ${
                      isSelected
                        ? 'bg-[#222327] border-l-4 border-l-[#ff506d]'
                        : 'hover:bg-[#1c1d21]'
                    }`}
                  >
                    {/* Time */}
                    <td className="px-5 py-3 font-mono text-xs text-[#f5f5f6]">
                      {log.timestamp.split(' ')[0]}{' '}
                      <span className="text-[#a7a9ae]">{log.timestamp.split(' ')[1]}</span>
                    </td>

                    {/* Actor */}
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <span className="w-6 h-6 rounded-full bg-[rgba(242,48,90,0.15)] text-[#ff506d] flex items-center justify-center text-xs font-bold shrink-0">
                          {log.actor.avatarLabel}
                        </span>
                        <span className="text-xs font-medium text-[#f5f5f6] truncate max-w-[180px]">
                          {log.actor.email}
                        </span>
                      </div>
                    </td>

                    {/* Action */}
                    <td className="px-4 py-3">{renderActionBadge(log.action)}</td>

                    {/* Target */}
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <span
                          className={`font-mono text-xs font-bold ${renderTargetIdColor(
                            log.targetType
                          )}`}
                        >
                          {log.targetId}
                        </span>
                        <span className="text-xs text-[#a7a9ae] truncate max-w-[220px]">
                          {log.targetName}
                        </span>
                      </div>
                    </td>

                    {/* Result */}
                    <td className="px-4 py-3">{renderResultBadge(log.resultStatus)}</td>

                    {/* IP */}
                    <td className="px-4 py-3 font-mono text-xs text-[#a7a9ae]">
                      {log.ipAddress}
                    </td>

                    {/* Details button */}
                    <td className="px-5 py-3 text-right">
                      <button
                        type="button"
                        onClick={(e) => {
                          e.stopPropagation()
                          onSelectLog(log)
                        }}
                        className={`w-8 h-8 rounded-lg inline-flex items-center justify-center transition-colors cursor-pointer ${
                          isSelected
                            ? 'bg-[#ff506d]/20 text-[#ff506d]'
                            : 'bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#1c1d21]'
                        }`}
                        title="Xem chi tiết sự kiện"
                      >
                        <span className="material-symbols-outlined text-base">visibility</span>
                      </button>
                    </td>
                  </tr>
                )
              })
            )}
          </tbody>
        </table>
      </div>

      {/* Table Pagination Footer */}
      <div className="p-4 bg-[#17181b] border-t border-[#292a2f] flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-[#a7a9ae]">
        <div className="flex items-center gap-3">
          <span>
            Hiển thị{' '}
            <strong className="text-[#f5f5f6] tabular-nums">
              {totalLogs > 0 ? startIndex + 1 : 0} - {Math.min(startIndex + pageSize, totalLogs)}
            </strong>{' '}
            trên <strong className="text-[#f5f5f6] tabular-nums">{totalLogs}</strong> sự kiện kiểm toán
          </span>
          <div className="h-4 w-px bg-[#292a2f]" />
          <div className="flex items-center gap-1.5">
            <span>Dòng:</span>
            <select
              value={pageSize}
              onChange={(e) => {
                setPageSize(Number(e.target.value))
                setCurrentPage(1)
              }}
              className="h-7 px-2 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-xs font-medium focus:outline-none cursor-pointer"
            >
              <option value="25">25 / trang</option>
              <option value="50">50 / trang</option>
              <option value="100">100 / trang</option>
            </select>
          </div>
        </div>

        <div className="flex items-center gap-1">
          <button
            type="button"
            disabled={currentPage <= 1}
            onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            className="w-8 h-8 rounded-lg border border-[#292a2f] bg-[#222327] flex items-center justify-center hover:bg-[#1c1d21] disabled:opacity-40 transition-colors cursor-pointer disabled:cursor-not-allowed"
          >
            <span className="material-symbols-outlined text-sm">chevron_left</span>
          </button>
          <span className="px-3 text-xs font-mono font-semibold text-[#f5f5f6]">
            {currentPage} / {totalPages}
          </span>
          <button
            type="button"
            disabled={currentPage >= totalPages}
            onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
            className="w-8 h-8 rounded-lg border border-[#292a2f] bg-[#222327] flex items-center justify-center hover:bg-[#1c1d21] disabled:opacity-40 transition-colors cursor-pointer disabled:cursor-not-allowed"
          >
            <span className="material-symbols-outlined text-sm">chevron_right</span>
          </button>
        </div>
      </div>
    </section>
  )
}
