import React from 'react'
import { ImportFileMeta } from '../types'

interface ValidationKpiCardsProps {
  fileMeta: ImportFileMeta
  activeFilter?: 'ALL' | 'ERRORS_WARNINGS' | 'VALID'
  onSelectFilter?: (filter: 'ALL' | 'ERRORS_WARNINGS' | 'VALID') => void
}

export const ValidationKpiCards: React.FC<ValidationKpiCardsProps> = ({
  fileMeta,
  activeFilter,
  onSelectFilter,
}) => {
  const validPercent = ((fileMeta.validRows / fileMeta.totalRows) * 100).toFixed(1)

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {/* Total Rows */}
      <div
        onClick={() => onSelectFilter && onSelectFilter('ALL')}
        className={`bg-[#17181b] rounded-2xl border ${
          activeFilter === 'ALL' ? 'border-[#ff506d]' : 'border-[#292a2f]'
        } p-4 flex flex-col justify-between min-h-[110px] cursor-pointer hover:bg-[#1c1d21] transition-all`}
      >
        <div className="flex items-center justify-between text-[#a7a9ae] text-xs">
          <span>Tổng số dòng</span>
          <span className="material-symbols-outlined text-[20px] text-[#8a8d93]">
            format_list_numbered
          </span>
        </div>
        <div className="flex items-baseline justify-between mt-2">
          <span className="text-[28px] font-bold text-[#f5f5f6] font-mono leading-none">
            {fileMeta.totalRows}
          </span>
          <span className="text-xs text-[#8a8d93]">100% dung lượng file</span>
        </div>
      </div>

      {/* Valid Rows */}
      <div
        onClick={() => onSelectFilter && onSelectFilter('VALID')}
        className={`bg-[#17181b] rounded-2xl border ${
          activeFilter === 'VALID' ? 'border-[#35c76f]' : 'border-[#292a2f]'
        } p-4 flex flex-col justify-between min-h-[110px] relative overflow-hidden cursor-pointer hover:bg-[#1c1d21] transition-all`}
      >
        <div className="absolute top-0 left-0 bottom-0 w-1 bg-[#35c76f]"></div>
        <div className="flex items-center justify-between text-[#a7a9ae] text-xs">
          <span className="text-[#35c76f] font-semibold">Hợp lệ</span>
          <span className="material-symbols-outlined text-[20px] text-[#35c76f]">
            check_circle
          </span>
        </div>
        <div className="flex items-baseline justify-between mt-2">
          <span className="text-[28px] font-bold text-[#35c76f] font-mono leading-none">
            {fileMeta.validRows}
          </span>
          <span className="text-xs text-[#35c76f]/80 font-mono">
            {validPercent}% tổng bản ghi
          </span>
        </div>
      </div>

      {/* Warning Rows */}
      <div
        onClick={() => onSelectFilter && onSelectFilter('ERRORS_WARNINGS')}
        className={`bg-[#17181b] rounded-2xl border ${
          activeFilter === 'ERRORS_WARNINGS' ? 'border-[#f4b740]' : 'border-[#292a2f]'
        } p-4 flex flex-col justify-between min-h-[110px] relative overflow-hidden cursor-pointer hover:bg-[#1c1d21] transition-all`}
      >
        <div className="absolute top-0 left-0 bottom-0 w-1 bg-[#f4b740]"></div>
        <div className="flex items-center justify-between text-[#a7a9ae] text-xs">
          <span className="text-[#f4b740] font-semibold">Cảnh báo</span>
          <span className="material-symbols-outlined text-[20px] text-[#f4b740]">warning</span>
        </div>
        <div className="flex items-baseline justify-between mt-2">
          <span className="text-[28px] font-bold text-[#f4b740] font-mono leading-none">
            {fileMeta.warningRows}
          </span>
          <span className="text-xs text-[#f4b740]/80">Có thể tự xử lý</span>
        </div>
      </div>

      {/* Structural Errors */}
      <div
        onClick={() => onSelectFilter && onSelectFilter('ERRORS_WARNINGS')}
        className={`bg-[#17181b] rounded-2xl border ${
          activeFilter === 'ERRORS_WARNINGS' ? 'border-[#ff5a5f]' : 'border-[#292a2f]'
        } p-4 flex flex-col justify-between min-h-[110px] relative overflow-hidden cursor-pointer hover:bg-[#1c1d21] transition-all`}
      >
        <div className="absolute top-0 left-0 bottom-0 w-1 bg-[#ff5a5f]"></div>
        <div className="flex items-center justify-between text-[#a7a9ae] text-xs">
          <span className="text-[#ff5a5f] font-semibold">Lỗi cấu trúc</span>
          <span className="material-symbols-outlined text-[20px] text-[#ff5a5f]">cancel</span>
        </div>
        <div className="flex items-baseline justify-between mt-2">
          <span className="text-[28px] font-bold text-[#ff5a5f] font-mono leading-none">
            {fileMeta.errorRows}
          </span>
          <span className="text-xs text-[#ff5a5f]/80">Cần can thiệp sửa</span>
        </div>
      </div>
    </div>
  )
}
