import React from 'react'
import type { WorkoutPlanFilterState } from '../types'

interface WorkoutPlanFilterBarProps {
  filters: WorkoutPlanFilterState
  onChange: (filters: WorkoutPlanFilterState) => void
  totalCount: number
  activeCount: number
  draftCount: number
}

export const WorkoutPlanFilterBar: React.FC<WorkoutPlanFilterBarProps> = ({
  filters,
  onChange,
  totalCount,
  activeCount,
  draftCount,
}) => {
  const handleReset = () => {
    onChange({
      search: '',
      goal: '',
      level: '',
      daysPerWeek: '',
      status: '',
    })
  }

  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-xl p-4 space-y-3">
      {/* Top Filter Controls */}
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-12 gap-3 items-center">
        {/* Search input (4 cols) */}
        <div className="md:col-span-4 relative">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px]">
            search
          </span>
          <input
            type="text"
            value={filters.search}
            onChange={(e) => onChange({ ...filters, search: e.target.value })}
            placeholder="Tìm tên giáo án, mã, thẻ tag..."
            className="w-full h-10 pl-9 pr-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] placeholder-[#8a8d93] focus:outline-none focus:border-[#f2305a] transition-colors"
          />
        </div>

        {/* Goal select (2 cols) */}
        <div className="md:col-span-2">
          <select
            value={filters.goal}
            onChange={(e) => onChange({ ...filters, goal: e.target.value })}
            aria-label="Lọc theo mục tiêu"
            className="w-full h-10 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors cursor-pointer"
          >
            <option value="">Tất cả mục tiêu</option>
            <option value="hypertrophy">Tăng cơ (Hypertrophy)</option>
            <option value="strength">Tăng sức mạnh (Strength)</option>
            <option value="fat_loss">Giảm mỡ & Cắt nét</option>
            <option value="general_fitness">Thể lực & Nền tảng</option>
            <option value="endurance">Sức bền (Endurance)</option>
          </select>
        </div>

        {/* Level select (2 cols) */}
        <div className="md:col-span-2">
          <select
            value={filters.level}
            onChange={(e) => onChange({ ...filters, level: e.target.value })}
            aria-label="Lọc theo cấp độ"
            className="w-full h-10 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors cursor-pointer"
          >
            <option value="">Tất cả cấp độ</option>
            <option value="beginner">Mới bắt đầu (Beginner)</option>
            <option value="intermediate">Trung bình (Intermediate)</option>
            <option value="advanced">Nâng cao (Advanced)</option>
          </select>
        </div>

        {/* Frequency select (2 cols) */}
        <div className="md:col-span-2">
          <select
            value={filters.daysPerWeek}
            onChange={(e) => onChange({ ...filters, daysPerWeek: e.target.value })}
            aria-label="Lọc theo số buổi tập"
            className="w-full h-10 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors cursor-pointer"
          >
            <option value="">Tất cả lịch tập</option>
            <option value="3">3 buổi / tuần</option>
            <option value="4">4 buổi / tuần</option>
            <option value="5">5 buổi / tuần</option>
            <option value="6">6 buổi / tuần</option>
          </select>
        </div>

        {/* Status select & Reset (2 cols) */}
        <div className="md:col-span-2 flex items-center gap-2">
          <select
            value={filters.status}
            onChange={(e) => onChange({ ...filters, status: e.target.value })}
            aria-label="Lọc theo trạng thái"
            className="w-full h-10 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors cursor-pointer"
          >
            <option value="">Tất cả trạng thái</option>
            <option value="active">Đang áp dụng</option>
            <option value="draft">Bản nháp</option>
            <option value="archived">Lưu trữ</option>
          </select>

          {(filters.search || filters.goal || filters.level || filters.daysPerWeek || filters.status) && (
            <button
              type="button"
              onClick={handleReset}
              title="Đặt lại bộ lọc"
              className="h-10 w-10 shrink-0 rounded-xl bg-[#222327] hover:bg-[#292a2f] border border-[#292a2f] text-[#8a8d93] hover:text-[#ff506d] flex items-center justify-center transition-colors cursor-pointer"
            >
              <span className="material-symbols-outlined text-[18px]">restart_alt</span>
            </button>
          )}
        </div>
      </div>

      {/* Quick Status Pill Bar */}
      <div className="flex flex-wrap items-center justify-between gap-3 pt-2 border-t border-[#292a2f]/60">
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => onChange({ ...filters, status: '' })}
            className={`px-3 py-1.5 rounded-lg text-[12px] font-medium transition-colors cursor-pointer ${
              filters.status === ''
                ? 'bg-[rgba(242,48,90,0.12)] text-[#ff506d] border border-[#ff506d]/30 font-semibold'
                : 'bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f]'
            }`}
          >
            Tất cả ({totalCount})
          </button>
          <button
            type="button"
            onClick={() => onChange({ ...filters, status: 'active' })}
            className={`px-3 py-1.5 rounded-lg text-[12px] font-medium transition-colors cursor-pointer flex items-center gap-1.5 ${
              filters.status === 'active'
                ? 'bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/30 font-semibold'
                : 'bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f]'
            }`}
          >
            <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
            Đang áp dụng ({activeCount})
          </button>
          <button
            type="button"
            onClick={() => onChange({ ...filters, status: 'draft' })}
            className={`px-3 py-1.5 rounded-lg text-[12px] font-medium transition-colors cursor-pointer flex items-center gap-1.5 ${
              filters.status === 'draft'
                ? 'bg-[#eab308]/15 text-[#facc15] border border-[#facc15]/30 font-semibold'
                : 'bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f]'
            }`}
          >
            <span className="w-1.5 h-1.5 rounded-full bg-[#facc15]" />
            Bản nháp ({draftCount})
          </button>
        </div>

        <div className="text-[12px] text-[#8a8d93]">
          Tổng cộng <span className="font-semibold text-[#f5f5f6]">{totalCount}</span> giáo án trong hệ thống
        </div>
      </div>
    </div>
  )
}
