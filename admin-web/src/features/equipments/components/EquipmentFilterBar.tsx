import React from 'react'
import type { EquipmentFilterState } from '../types'

interface EquipmentFilterBarProps {
  filters: EquipmentFilterState
  onChange: (filters: EquipmentFilterState) => void
  totalCount: number
  activeCount: number
}

export const EquipmentFilterBar: React.FC<EquipmentFilterBarProps> = ({
  filters,
  onChange,
  totalCount,
  activeCount,
}) => {
  const handleReset = () => {
    onChange({
      search: '',
      category: '',
      status: '',
      viewMode: filters.viewMode,
    })
  }

  const hasActiveFilters = Boolean(filters.search || filters.category || filters.status)

  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-xl p-4 space-y-3">
      <div className="grid grid-cols-1 md:grid-cols-12 gap-3 items-center">
        {/* Search bar (5 cols) */}
        <div className="md:col-span-5 relative">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px]">
            search
          </span>
          <input
            type="text"
            value={filters.search}
            onChange={(e) => onChange({ ...filters, search: e.target.value })}
            placeholder="Tìm theo tên thiết bị, mã CODE hoặc mô tả..."
            className="w-full h-11 pl-9 pr-8 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] placeholder:text-[#8a8d93] focus:outline-none focus:border-[#f2305a] text-[14px]"
          />
          {filters.search && (
            <button
              type="button"
              onClick={() => onChange({ ...filters, search: '' })}
              className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] hover:text-[#f5f5f6] text-[16px] cursor-pointer"
            >
              close
            </button>
          )}
        </div>

        {/* Phân loại thiết bị (3 cols) */}
        <div className="md:col-span-3">
          <div className="relative">
            <select
              value={filters.category}
              onChange={(e) => onChange({ ...filters, category: e.target.value })}
              className="w-full h-11 px-3 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a] cursor-pointer"
            >
              <option value="">Phân loại: Tất cả</option>
              <option value="free_weights">Tạ tự do (Free Weights)</option>
              <option value="machines">Máy khối &amp; Cáp lực</option>
              <option value="bodyweight">Thể trọng (Bodyweight)</option>
              <option value="accessories">Ghế &amp; Dụng cụ bổ trợ</option>
              <option value="cardio">Thiết bị Cardio</option>
            </select>
            <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px] pointer-events-none">
              expand_more
            </span>
          </div>
        </div>

        {/* Trạng thái (2 cols) */}
        <div className="md:col-span-2">
          <div className="relative">
            <select
              value={filters.status}
              onChange={(e) => onChange({ ...filters, status: e.target.value })}
              className="w-full h-11 px-3 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a] cursor-pointer"
            >
              <option value="">Trạng thái: Tất cả</option>
              <option value="active">Đang áp dụng</option>
              <option value="inactive">Tạm ẩn</option>
            </select>
            <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px] pointer-events-none">
              expand_more
            </span>
          </div>
        </div>

        {/* View Mode & Reset (2 cols) */}
        <div className="md:col-span-2 flex items-center justify-end gap-2">
          <div className="flex bg-[#222327] p-1 rounded-xl border border-[#292a2f]">
            <button
              type="button"
              onClick={() => onChange({ ...filters, viewMode: 'table' })}
              className={`p-1.5 rounded-lg flex items-center justify-center transition-colors cursor-pointer ${
                filters.viewMode === 'table'
                  ? 'bg-[rgba(242,48,90,0.15)] text-[#ff506d] font-bold'
                  : 'text-[#8a8d93] hover:text-[#f5f5f6]'
              }`}
              title="Xem dạng bảng"
            >
              <span className="material-symbols-outlined text-[18px]">table_rows</span>
            </button>
            <button
              type="button"
              onClick={() => onChange({ ...filters, viewMode: 'grid' })}
              className={`p-1.5 rounded-lg flex items-center justify-center transition-colors cursor-pointer ${
                filters.viewMode === 'grid'
                  ? 'bg-[rgba(242,48,90,0.15)] text-[#ff506d] font-bold'
                  : 'text-[#8a8d93] hover:text-[#f5f5f6]'
              }`}
              title="Xem dạng lưới thẻ"
            >
              <span className="material-symbols-outlined text-[18px]">grid_view</span>
            </button>
          </div>

          {hasActiveFilters && (
            <button
              type="button"
              onClick={handleReset}
              className="h-10 px-3 bg-[#222327] hover:bg-[#2c2d33] border border-[#292a2f] text-[#ff506d] hover:text-[#f5f5f6] rounded-xl text-[13px] font-medium flex items-center gap-1 transition-colors cursor-pointer shrink-0"
              title="Đặt lại bộ lọc"
            >
              <span className="material-symbols-outlined text-[16px]">restart_alt</span>
              <span>Đặt lại</span>
            </button>
          )}
        </div>
      </div>

      {/* Summary KPI Badges */}
      <div className="flex flex-wrap items-center justify-between pt-2 border-t border-[#292a2f] text-[12px] text-[#8a8d93]">
        <div className="flex items-center gap-3">
          <span>
            Tổng số: <strong className="text-[#f5f5f6]">{totalCount}</strong> thiết bị
          </span>
          <span className="text-[#292a2f]">|</span>
          <span className="text-[#35c76f]">
            Đang hoạt động: <strong>{activeCount}</strong>
          </span>
        </div>
        <div className="text-[11px] text-[#8a8d93] flex items-center gap-1.5">
          <span className="material-symbols-outlined text-[14px] text-[#ff506d]">sync</span>
          Đồng bộ với Master Exercise Catalog &amp; Onboarding Profile
        </div>
      </div>
    </div>
  )
}
