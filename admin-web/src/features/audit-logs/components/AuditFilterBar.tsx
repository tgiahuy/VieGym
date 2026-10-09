import React from 'react'
import { AuditFilterState } from '../types'

interface AuditFilterBarProps {
  filters: AuditFilterState
  onFilterChange: (newFilters: Partial<AuditFilterState>) => void
  onReset: () => void
  onExport: () => void
}

export const AuditFilterBar: React.FC<AuditFilterBarProps> = ({
  filters,
  onFilterChange,
  onReset,
  onExport,
}) => {
  return (
    <section className="p-4 rounded-xl bg-[#17181b] border border-[#292a2f] space-y-3">
      {/* Dòng 1: Bộ lọc đa chiều */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-3">
        {/* Date Range Picker */}
        <div className="flex flex-col gap-1">
          <label className="text-[12px] font-semibold text-[#a7a9ae] flex items-center gap-1">
            <span className="material-symbols-outlined text-xs">calendar_today</span>
            <span>Khoảng thời gian</span>
          </label>
          <div className="relative">
            <select
              value={filters.dateRange}
              onChange={(e) => onFilterChange({ dateRange: e.target.value })}
              className="w-full h-11 px-3 pr-8 bg-[#222327] border border-[#292a2f] rounded-xl text-xs text-[#f5f5f6] font-mono appearance-none cursor-pointer focus:outline-none focus:border-[#ff506d]"
            >
              <option value="ALL">Toàn thời gian (90 ngày)</option>
              <option value="24H">24 giờ qua</option>
              <option value="7D">7 ngày qua (27/09 - 03/10)</option>
              <option value="30D">30 ngày qua</option>
            </select>
            <span className="material-symbols-outlined absolute right-2.5 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-base">
              arrow_drop_down
            </span>
          </div>
        </div>

        {/* Actor Select */}
        <div className="flex flex-col gap-1">
          <label className="text-[12px] font-semibold text-[#a7a9ae] flex items-center gap-1">
            <span className="material-symbols-outlined text-xs">person</span>
            <span>Actor (Tác tử)</span>
          </label>
          <div className="relative">
            <select
              value={filters.actor}
              onChange={(e) => onFilterChange({ actor: e.target.value })}
              className="w-full h-11 px-3 pr-8 bg-[#222327] border border-[#292a2f] rounded-xl text-xs text-[#f5f5f6] appearance-none cursor-pointer focus:outline-none focus:border-[#ff506d]"
            >
              <option value="ALL">Tất cả (Admin, System, AI)</option>
              <option value="ADMIN">Admin (Quản trị viên)</option>
              <option value="SYSTEM">System Scheduler (Tự động)</option>
              <option value="AI">AI Pipeline Curator</option>
            </select>
            <span className="material-symbols-outlined absolute right-2.5 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-base">
              unfold_more
            </span>
          </div>
        </div>

        {/* Action Select */}
        <div className="flex flex-col gap-1">
          <label className="text-[12px] font-semibold text-[#a7a9ae] flex items-center gap-1">
            <span className="material-symbols-outlined text-xs">bolt</span>
            <span>Action (Hành động)</span>
          </label>
          <div className="relative">
            <select
              value={filters.action}
              onChange={(e) => onFilterChange({ action: e.target.value })}
              className="w-full h-11 px-3 pr-8 bg-[#222327] border border-[#292a2f] rounded-xl text-xs text-[#f5f5f6] appearance-none cursor-pointer focus:outline-none focus:border-[#ff506d]"
            >
              <option value="ALL">Tất cả (CREATE, UPDATE...)</option>
              <option value="CREATE">CREATE (Tạo mới)</option>
              <option value="UPDATE">UPDATE (Cập nhật)</option>
              <option value="LOCK">LOCK (Khóa)</option>
              <option value="HIDE">HIDE (Ẩn)</option>
              <option value="DELETE">DELETE (Xóa)</option>
              <option value="PUBLISH">PUBLISH (Phát hành)</option>
            </select>
            <span className="material-symbols-outlined absolute right-2.5 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-base">
              unfold_more
            </span>
          </div>
        </div>

        {/* Target Type Select */}
        <div className="flex flex-col gap-1">
          <label className="text-[12px] font-semibold text-[#a7a9ae] flex items-center gap-1">
            <span className="material-symbols-outlined text-xs">category</span>
            <span>Đối tượng</span>
          </label>
          <div className="relative">
            <select
              value={filters.targetType}
              onChange={(e) => onFilterChange({ targetType: e.target.value })}
              className="w-full h-11 px-3 pr-8 bg-[#222327] border border-[#292a2f] rounded-xl text-xs text-[#f5f5f6] appearance-none cursor-pointer focus:outline-none focus:border-[#ff506d]"
            >
              <option value="ALL">Tất cả (FOOD, EXERCISE...)</option>
              <option value="FOOD">FOOD (Thực phẩm)</option>
              <option value="EXERCISE">EXERCISE (Bài tập)</option>
              <option value="USER">USER (Người dùng)</option>
              <option value="RULE">RULE (Quy tắc)</option>
              <option value="PROMPT">PROMPT (Prompt AI)</option>
            </select>
            <span className="material-symbols-outlined absolute right-2.5 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-base">
              unfold_more
            </span>
          </div>
        </div>

        {/* Execution Result Select */}
        <div className="flex flex-col gap-1">
          <label className="text-[12px] font-semibold text-[#a7a9ae] flex items-center gap-1">
            <span className="material-symbols-outlined text-xs">task_alt</span>
            <span>Kết quả thực thi</span>
          </label>
          <div className="relative">
            <select
              value={filters.resultStatus}
              onChange={(e) => onFilterChange({ resultStatus: e.target.value })}
              className="w-full h-11 px-3 pr-8 bg-[#222327] border border-[#292a2f] rounded-xl text-xs text-[#f5f5f6] appearance-none cursor-pointer focus:outline-none focus:border-[#ff506d]"
            >
              <option value="ALL">Tất cả (Thành công, Thất bại)</option>
              <option value="SUCCESS">Thành công (200 / 201)</option>
              <option value="WARNING">Cảnh báo / Rate Limit</option>
              <option value="FAILED">Thất bại (4xx / 5xx)</option>
            </select>
            <span className="material-symbols-outlined absolute right-2.5 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-base">
              unfold_more
            </span>
          </div>
        </div>
      </div>

      {/* Dòng 2: Ô tìm kiếm chuyên sâu & Nút reset / Export */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 pt-2 border-t border-[#292a2f]/60">
        <div className="relative w-full sm:w-[420px]">
          <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-[#8a8d93] text-base pointer-events-none">
            search
          </span>
          <input
            type="text"
            value={filters.search}
            onChange={(e) => onFilterChange({ search: e.target.value })}
            placeholder="Target ID (#FD-0284) / Correlation ID (req-94a1f...)"
            className="w-full h-11 pl-10 pr-9 bg-[#222327] border border-[#292a2f] rounded-xl text-xs text-[#f5f5f6] placeholder:text-[#8a8d93] focus:outline-none focus:border-[#ff506d] font-mono"
          />
          {filters.search && (
            <button
              type="button"
              onClick={() => onFilterChange({ search: '' })}
              className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] hover:text-[#f5f5f6] text-[16px] cursor-pointer"
            >
              close
            </button>
          )}
        </div>

        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={onReset}
            className="h-11 px-4 rounded-xl bg-transparent hover:bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f] text-xs font-semibold transition-colors flex items-center gap-1.5 cursor-pointer"
          >
            <span className="material-symbols-outlined text-sm">filter_alt_off</span>
            <span>Xóa bộ lọc</span>
          </button>
          <button
            type="button"
            onClick={onExport}
            className="h-11 px-4 rounded-xl bg-[#1c1d21] hover:bg-[#222327] text-[#f5f5f6] border border-[#34363b] text-xs font-semibold transition-colors flex items-center gap-1.5 cursor-pointer"
          >
            <span className="material-symbols-outlined text-sm">download</span>
            <span>Xuất kiểm toán (.CSV)</span>
          </button>
        </div>
      </div>
    </section>
  )
}
