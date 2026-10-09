import React, { useState } from 'react'
import { ImportRowItem } from '../types'

interface ImportPreviewTableProps {
  rows: ImportRowItem[]
  activeFilter: 'ALL' | 'ERRORS_WARNINGS' | 'VALID'
  onFilterChange: (filter: 'ALL' | 'ERRORS_WARNINGS' | 'VALID') => void
  onRefresh?: () => void
  totalRowsCount: number
  errorWarningCount: number
  validCount: number
}

export const ImportPreviewTable: React.FC<ImportPreviewTableProps> = ({
  rows,
  activeFilter,
  onFilterChange,
  onRefresh,
  totalRowsCount,
  errorWarningCount,
  validCount,
}) => {
  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 4
  const totalPages = Math.ceil(rows.length / pageSize) || 1

  const paginatedRows = rows.slice(
    (currentPage - 1) * pageSize,
    currentPage * pageSize
  )

  const handlePageChange = (newPage: number) => {
    if (newPage >= 1 && newPage <= totalPages) {
      setCurrentPage(newPage)
    }
  }

  return (
    <div className="space-y-3">
      {/* Filter Toggle Tabs & Actions Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-2">
        {/* Segmented Filter Pills */}
        <div className="flex items-center p-1 bg-[#222327] rounded-xl border border-[#292a2f] w-fit">
          <button
            type="button"
            onClick={() => {
              onFilterChange('ALL')
              setCurrentPage(1)
            }}
            className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              activeFilter === 'ALL'
                ? 'bg-[#17181b] text-[#f5f5f6] shadow-sm border border-[#34363b]'
                : 'text-[#a7a9ae] hover:text-[#f5f5f6]'
            }`}
          >
            Tất cả ({totalRowsCount})
          </button>

          <button
            type="button"
            onClick={() => {
              onFilterChange('ERRORS_WARNINGS')
              setCurrentPage(1)
            }}
            className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1.5 transition-all ${
              activeFilter === 'ERRORS_WARNINGS'
                ? 'bg-[#17181b] text-[#ff5a5f] shadow-sm border border-[#34363b]'
                : 'text-[#ff5a5f] hover:text-[#f5f5f6]'
            }`}
          >
            <span className="w-2 h-2 rounded-full bg-[#ff5a5f]"></span>
            Chỉ hiện lỗi &amp; cảnh báo ({errorWarningCount})
          </button>

          <button
            type="button"
            onClick={() => {
              onFilterChange('VALID')
              setCurrentPage(1)
            }}
            className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all ${
              activeFilter === 'VALID'
                ? 'bg-[#17181b] text-[#35c76f] shadow-sm border border-[#34363b]'
                : 'text-[#a7a9ae] hover:text-[#f5f5f6]'
            }`}
          >
            Hợp lệ ({validCount})
          </button>
        </div>

        {/* Table View Micro-controls */}
        <div className="flex items-center gap-3">
          <span className="text-xs text-[#8a8d93]">
            Hiển thị {paginatedRows.length} trên tổng {rows.length} bản ghi
          </span>
          <button
            type="button"
            onClick={onRefresh}
            className="p-1.5 rounded-lg border border-[#292a2f] text-[#8a8d93] hover:text-[#f5f5f6] hover:border-[#34363b] bg-[#17181b] transition-colors"
            title="Làm mới bảng"
          >
            <span className="material-symbols-outlined text-[18px]">refresh</span>
          </button>
        </div>
      </div>

      {/* Table Container */}
      <div className="bg-[#17181b] rounded-2xl border border-[#292a2f] overflow-hidden shadow-sm">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="h-11 bg-[#17181b] border-b border-[#292a2f] text-xs font-semibold text-[#f5f5f6] select-none">
                <th className="py-2.5 px-4 w-16 text-center">Dòng</th>
                <th className="py-2.5 px-4 w-36">Trạng thái</th>
                <th className="py-2.5 px-4 min-w-[200px]">Mã SKU / Tên tiếng Việt</th>
                <th className="py-2.5 px-4 min-w-[170px]">Tên tiếng Anh (International)</th>
                <th className="py-2.5 px-4 w-40">Nhóm cơ chính</th>
                <th className="py-2.5 px-4 w-32">Thiết bị</th>
                <th className="py-2.5 px-4 min-w-[280px]">Chi tiết kiểm tra &amp; Gợi ý sửa</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#292a2f]/70 text-sm">
              {paginatedRows.length === 0 ? (
                <tr>
                  <td colSpan={7} className="py-10 text-center text-[#8a8d93]">
                    <div className="flex flex-col items-center justify-center gap-2">
                      <span className="material-symbols-outlined text-3xl text-[#8a8d93]">
                        search_off
                      </span>
                      <span>Không tìm thấy bản ghi nào phù hợp bộ lọc</span>
                    </div>
                  </td>
                </tr>
              ) : (
                paginatedRows.map((row) => {
                  const isWarning = row.status === 'WARNING'
                  const isEnumError = row.status === 'ERROR_ENUM'
                  const isDupError = row.status === 'ERROR_DUPLICATE'
                  const isValid = row.status === 'VALID'

                  const rowBg = isWarning
                    ? 'bg-[#f4b740]/5 hover:bg-[#f4b740]/10'
                    : isEnumError || isDupError
                      ? 'bg-[#ff5a5f]/5 hover:bg-[#ff5a5f]/10'
                      : 'hover:bg-[#1c1d21]'

                  return (
                    <tr
                      key={row.id}
                      className={`transition-colors duration-150 ${rowBg}`}
                    >
                      {/* Row Index */}
                      <td className="py-3.5 px-4 text-center font-mono text-xs text-[#8a8d93]">
                        {row.rowNumber}
                      </td>

                      {/* Status Badge */}
                      <td className="py-3.5 px-4">
                        {isValid && (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/30">
                            <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]"></span>
                            Hợp lệ
                          </span>
                        )}

                        {isWarning && (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#f4b740]/15 text-[#f4b740] border border-[#f4b740]/30">
                            <span className="w-1.5 h-1.5 rounded-full bg-[#f4b740]"></span>
                            Cảnh báo
                          </span>
                        )}

                        {isEnumError && (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#ff5a5f]/15 text-[#ff5a5f] border border-[#ff5a5f]/30">
                            <span className="w-1.5 h-1.5 rounded-full bg-[#ff5a5f]"></span>
                            Lỗi dữ liệu
                          </span>
                        )}

                        {isDupError && (
                          <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#ff5a5f]/15 text-[#ff5a5f] border border-[#ff5a5f]/30">
                            <span className="w-1.5 h-1.5 rounded-full bg-[#ff5a5f]"></span>
                            Lỗi trùng mã
                          </span>
                        )}
                      </td>

                      {/* Name & SKU */}
                      <td className="py-3.5 px-4">
                        <div className="flex flex-col">
                          <span className="font-semibold text-[#f5f5f6]">
                            {row.nameVi}
                          </span>
                          <span
                            className={`font-mono text-[11px] ${
                              isDupError
                                ? 'text-[#ff5a5f] font-bold'
                                : 'text-[#8a8d93]'
                            }`}
                          >
                            {isDupError ? row.sku : `SKU: ${row.sku}`}
                          </span>
                        </div>
                      </td>

                      {/* English Name */}
                      <td className="py-3.5 px-4 text-[#a7a9ae] italic text-xs">
                        {row.nameEn}
                      </td>

                      {/* Primary Muscle / Category */}
                      <td className="py-3.5 px-4">
                        {isEnumError ? (
                          <span className="px-2 py-0.5 rounded bg-[#ff5a5f]/20 border border-[#ff5a5f]/40 text-xs text-[#ff5a5f] font-medium line-through">
                            {row.primaryCategory}
                          </span>
                        ) : (
                          <span
                            className="px-2 py-0.5 rounded bg-[#222327] border border-[#292a2f] text-xs font-medium"
                            style={{
                              color: row.categoryBadgeColor || '#2cc7b5',
                            }}
                          >
                            {row.primaryCategory}
                          </span>
                        )}
                      </td>

                      {/* Equipment */}
                      <td className="py-3.5 px-4 text-[#a7a9ae] text-xs">
                        {row.secondaryInfo}
                      </td>

                      {/* Validation Details & Fix Suggestions */}
                      <td className="py-3.5 px-4">
                        {isValid && (
                          <div className="flex items-center gap-1.5 text-xs text-[#35c76f] font-medium">
                            <span className="material-symbols-outlined text-[16px]">
                              check_circle
                            </span>
                            <span>{row.validationTitle}</span>
                          </div>
                        )}

                        {isWarning && (
                          <div className="flex flex-col gap-0.5">
                            <div className="flex items-center gap-1 text-xs text-[#f4b740] font-medium">
                              <span className="material-symbols-outlined text-[16px]">
                                warning
                              </span>
                              <span>{row.validationTitle}</span>
                            </div>
                            <span className="text-[11px] text-[#a7a9ae] leading-snug">
                              {row.validationDetail}
                            </span>
                          </div>
                        )}

                        {(isEnumError || isDupError) && (
                          <div className="flex flex-col gap-1 p-2 rounded-lg bg-[#222327] border border-[#ff5a5f]/30">
                            <div className="flex items-center gap-1 text-xs text-[#ff5a5f] font-medium">
                              <span className="material-symbols-outlined text-[16px]">
                                {isDupError ? 'content_copy' : 'error'}
                              </span>
                              <span>{row.validationTitle}</span>
                            </div>
                            <span className="text-[11px] text-[#a7a9ae] leading-snug">
                              {row.validationDetail}
                            </span>
                            {row.suggestedFix && (
                              <span className="text-[10px] text-[#cdbdff] font-mono mt-0.5">
                                Gợi ý: {row.suggestedFix}
                              </span>
                            )}
                          </div>
                        )}
                      </td>
                    </tr>
                  )
                })
              )}
            </tbody>
          </table>
        </div>

        {/* Table Footer Pagination Bar */}
        <div className="h-12 px-4 bg-[#222327]/50 border-t border-[#292a2f] flex items-center justify-between text-xs text-[#a7a9ae]">
          <span>
            Hiển thị {paginatedRows.length} trên tổng số {rows.length} bản ghi
          </span>
          <div className="flex items-center gap-2">
            <span className="text-[#8a8d93]">
              Trang {currentPage} / {totalPages}
            </span>
            <div className="flex items-center gap-1">
              <button
                type="button"
                onClick={() => handlePageChange(currentPage - 1)}
                disabled={currentPage === 1}
                className={`p-1 rounded transition-colors ${
                  currentPage === 1
                    ? 'text-[#8a8d93] opacity-40 cursor-not-allowed'
                    : 'text-[#f5f5f6] hover:bg-[#1c1d21]'
                }`}
                title="Trang trước"
              >
                <span className="material-symbols-outlined text-[16px]">
                  chevron_left
                </span>
              </button>
              <button
                type="button"
                onClick={() => handlePageChange(currentPage + 1)}
                disabled={currentPage === totalPages}
                className={`p-1 rounded transition-colors ${
                  currentPage === totalPages
                    ? 'text-[#8a8d93] opacity-40 cursor-not-allowed'
                    : 'text-[#f5f5f6] hover:bg-[#1c1d21]'
                }`}
                title="Trang sau"
              >
                <span className="material-symbols-outlined text-[16px]">
                  chevron_right
                </span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
