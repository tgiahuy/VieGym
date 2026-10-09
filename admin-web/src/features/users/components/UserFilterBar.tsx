import React from 'react'
import { UserFilterState } from '../types'

interface UserFilterBarProps {
  filters: UserFilterState
  onFilterChange: (newFilters: Partial<UserFilterState>) => void
  onReset: () => void
  totalCount: number
  activeCount: number
  lockedCount: number
  disabledCount: number
}

export const UserFilterBar: React.FC<UserFilterBarProps> = ({
  filters,
  onFilterChange,
  onReset,
  totalCount,
  activeCount,
  lockedCount,
  disabledCount,
}) => {
  return (
    <div className="space-y-3">
      {/* Filter Form Card */}
      <section className="p-4 rounded-xl bg-[#17181b] border border-[#292a2f] flex flex-col xl:flex-row items-stretch xl:items-center justify-between gap-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 flex-1">
          {/* Search Input */}
          <div className="relative flex items-center">
            <span className="material-symbols-outlined absolute left-3 text-[#8a8d93] text-lg pointer-events-none">
              search
            </span>
            <input
              type="text"
              value={filters.search}
              onChange={(e) => onFilterChange({ search: e.target.value })}
              placeholder="Email hoặc nickname..."
              className="w-full h-11 pl-10 pr-9 rounded-xl bg-[#222327] border border-[#292a2f] focus:border-[#ff506d] focus:ring-1 focus:ring-[#ff506d] text-[#f5f5f6] placeholder:text-[#8a8d93] text-sm transition-all"
            />
            {filters.search && (
              <button
                type="button"
                onClick={() => onFilterChange({ search: '' })}
                className="material-symbols-outlined absolute right-3 text-[#8a8d93] hover:text-[#f5f5f6] text-[16px] cursor-pointer"
                title="Xóa tìm kiếm"
              >
                close
              </button>
            )}
          </div>

          {/* Role Filter */}
          <div className="relative">
            <select
              value={filters.role}
              onChange={(e) => onFilterChange({ role: e.target.value })}
              className="w-full h-11 px-3.5 pr-8 rounded-xl bg-[#222327] border border-[#292a2f] focus:border-[#ff506d] text-[#f5f5f6] text-sm appearance-none cursor-pointer"
            >
              <option value="ALL">Vai trò: Tất cả</option>
              <option value="USER">USER (Hội viên)</option>
              <option value="TRAINER">TRAINER (HLV)</option>
              <option value="ADMIN">ADMIN (Quản trị)</option>
            </select>
            <span className="material-symbols-outlined absolute right-3 top-3 text-[#8a8d93] pointer-events-none text-lg">
              expand_more
            </span>
          </div>

          {/* Status Filter */}
          <div className="relative">
            <select
              value={filters.status}
              onChange={(e) => onFilterChange({ status: e.target.value })}
              className="w-full h-11 px-3.5 pr-8 rounded-xl bg-[#222327] border border-[#292a2f] focus:border-[#ff506d] text-[#f5f5f6] text-sm appearance-none cursor-pointer"
            >
              <option value="ALL">Trạng thái: Tất cả</option>
              <option value="ACTIVE">Active (Đang hoạt động)</option>
              <option value="LOCKED">Locked (Bị khóa)</option>
              <option value="DISABLED">Disabled (Chưa kích hoạt)</option>
            </select>
            <span className="material-symbols-outlined absolute right-3 top-3 text-[#8a8d93] pointer-events-none text-lg">
              expand_more
            </span>
          </div>

          {/* Registration Date Filter */}
          <div className="relative">
            <select
              value={filters.dateRange}
              onChange={(e) => onFilterChange({ dateRange: e.target.value })}
              className="w-full h-11 px-3.5 pr-8 rounded-xl bg-[#222327] border border-[#292a2f] focus:border-[#ff506d] text-[#f5f5f6] text-sm appearance-none cursor-pointer"
            >
              <option value="ALL">Ngày: Toàn thời gian</option>
              <option value="7D">7 ngày qua</option>
              <option value="30D">30 ngày qua</option>
            </select>
            <span className="material-symbols-outlined absolute right-3 top-3 text-[#8a8d93] pointer-events-none text-lg">
              calendar_today
            </span>
          </div>
        </div>

        {/* Filter Reset Button */}
        <div className="flex items-center justify-end">
          <button
            type="button"
            onClick={onReset}
            className="h-11 px-4 rounded-xl bg-transparent hover:bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f] text-sm font-semibold flex items-center gap-2 transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-base">filter_alt_off</span>
            <span>Xóa bộ lọc</span>
          </button>
        </div>
      </section>

      {/* Stats Summary Strip */}
      <div className="flex flex-wrap items-center justify-between gap-3 px-4 py-2.5 rounded-lg bg-[#222327]/70 border border-[#292a2f] text-xs text-[#a7a9ae]">
        <div className="flex flex-wrap items-center gap-3">
          <span className="text-[#f5f5f6] font-semibold">
            Tổng <span className="tabular-nums">{totalCount}</span> tài khoản
          </span>
          <span className="text-[#34363b] hidden sm:inline">·</span>
          <span className="flex items-center gap-1.5 text-[#35c76f]">
            <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
            <strong className="text-[#f5f5f6] tabular-nums">{activeCount}</strong> Đang hoạt động
          </span>
          <span className="text-[#34363b] hidden sm:inline">·</span>
          <span className="flex items-center gap-1.5 text-[#ff5a5f]">
            <span className="w-1.5 h-1.5 rounded-full bg-[#ff5a5f]" />
            <strong className="text-[#f5f5f6] tabular-nums">{lockedCount}</strong> Bị khóa
          </span>
          <span className="text-[#34363b] hidden sm:inline">·</span>
          <span className="flex items-center gap-1.5 text-[#8a8d93]">
            <span className="w-1.5 h-1.5 rounded-full bg-[#8a8d93]" />
            <strong className="text-[#f5f5f6] tabular-nums">{disabledCount}</strong> Chưa kích hoạt
          </span>
        </div>
        <div className="hidden md:flex items-center gap-2 text-[#8a8d93]">
          <span className="material-symbols-outlined text-sm">lock_clock</span>
          <span>Múi giờ hệ thống: Asia/Ho_Chi_Minh (UTC+7)</span>
        </div>
      </div>
    </div>
  )
}
