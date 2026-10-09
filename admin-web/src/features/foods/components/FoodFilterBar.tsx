import React from 'react'
import { FoodFilterState } from '../types'

interface FoodFilterBarProps {
  filters: FoodFilterState
  onFilterChange: (newFilters: Partial<FoodFilterState>) => void
  onReset: () => void
  totalCount: number
  activeCount: number
  incompleteCount: number
  hiddenCount: number
}

export const FoodFilterBar: React.FC<FoodFilterBarProps> = ({
  filters,
  onFilterChange,
  onReset,
  totalCount,
  activeCount,
  incompleteCount,
  hiddenCount,
}) => {
  return (
    <section className="bg-[#17181b] rounded-2xl border border-[#292a2f] p-4 flex flex-col gap-3.5">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="flex flex-wrap items-center gap-3 flex-1">
          {/* Search Bar (320px) */}
          <div className="relative w-full sm:w-80">
            <span className="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[19px]">
              search
            </span>
            <input
              type="text"
              value={filters.search}
              onChange={(e) => onFilterChange({ search: e.target.value })}
              placeholder="Tìm tên món ăn hoặc nguyên liệu..."
              className="w-full h-11 pl-10 pr-9 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] placeholder:text-[#8a8d93] text-[14px] focus:outline-none focus:border-[#ff506d] focus:ring-1 focus:ring-[#ff506d] transition-all"
            />
            {filters.search && (
              <button
                type="button"
                onClick={() => onFilterChange({ search: '' })}
                className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] hover:text-[#f5f5f6] text-[16px] cursor-pointer"
                title="Xóa tìm kiếm"
              >
                close
              </button>
            )}
          </div>

          {/* Dropdown: Nhóm thực phẩm */}
          <div className="relative">
            <select
              value={filters.category}
              onChange={(e) => onFilterChange({ category: e.target.value })}
              className="h-11 pl-3.5 pr-8 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#ff506d] cursor-pointer transition-all"
            >
              <option value="">Nhóm thực phẩm: Tất cả</option>
              <option value="meat">Thịt &amp; Gia cầm</option>
              <option value="seafood">Hải sản</option>
              <option value="dairy">Trứng &amp; Sữa</option>
              <option value="carbs">Tinh bột &amp; Ngũ cốc</option>
              <option value="vegetable">Rau củ</option>
              <option value="fruit">Trái cây</option>
              <option value="spice">Gia vị &amp; Sốt</option>
            </select>
            <span className="material-symbols-outlined absolute right-2.5 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-[18px]">
              expand_more
            </span>
          </div>

          {/* Dropdown: Nguồn dữ liệu */}
          <div className="relative">
            <select
              value={filters.source}
              onChange={(e) => onFilterChange({ source: e.target.value })}
              className="h-11 pl-3.5 pr-8 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#ff506d] cursor-pointer transition-all"
            >
              <option value="">Nguồn: Tất cả</option>
              <option value="vn_nin">Viện Dinh Dưỡng QG</option>
              <option value="usda">USDA FoodData Central</option>
              <option value="viegym">VieGym Verified</option>
              <option value="custom">Tùy biến (Custom)</option>
            </select>
            <span className="material-symbols-outlined absolute right-2.5 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-[18px]">
              expand_more
            </span>
          </div>

          {/* Dropdown: Trạng thái dữ liệu */}
          <div className="relative">
            <select
              value={filters.status}
              onChange={(e) => onFilterChange({ status: e.target.value })}
              className="h-11 pl-3.5 pr-8 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#ff506d] cursor-pointer transition-all"
            >
              <option value="">Trạng thái dữ liệu: Tất cả</option>
              <option value="active">Đầy đủ Macro (Active)</option>
              <option value="incomplete">Cần bổ sung macro</option>
              <option value="hidden">Đang ẩn (Hidden)</option>
            </select>
            <span className="material-symbols-outlined absolute right-2.5 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-[18px]">
              expand_more
            </span>
          </div>
        </div>

        {/* Clear Filters Button */}
        <button
          type="button"
          onClick={onReset}
          className="h-11 px-3 text-[#8a8d93] hover:text-[#f5f5f6] hover:bg-[#222327] rounded-xl border border-transparent hover:border-[#292a2f] text-[14px] font-semibold flex items-center gap-1.5 transition-colors cursor-pointer"
        >
          <span className="material-symbols-outlined text-[17px]">filter_alt_off</span>
          <span>Xóa bộ lọc</span>
        </button>
      </div>

      {/* Telemetry Summary Line */}
      <div className="flex flex-wrap items-center gap-4 pt-2.5 border-t border-[#292a2f]/60 text-xs text-[#8a8d93]">
        <span>
          Tổng số: <strong className="text-[#f5f5f6] tabular-nums">{totalCount}</strong> món
        </span>
        <span className="text-[#292a2f] hidden sm:inline">•</span>
        <span className="flex items-center gap-1 text-[#35c76f]">
          <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
          Đang kích hoạt: <strong className="tabular-nums">{activeCount}</strong>
        </span>
        <span className="text-[#292a2f] hidden sm:inline">•</span>
        <span className="flex items-center gap-1 text-[#f4b740]">
          <span className="w-1.5 h-1.5 rounded-full bg-[#f4b740]" />
          Cần bổ sung: <strong className="tabular-nums">{incompleteCount}</strong>
        </span>
        <span className="text-[#292a2f] hidden sm:inline">•</span>
        <span className="flex items-center gap-1 text-[#8a8d93]">
          <span className="w-1.5 h-1.5 rounded-full bg-[#8a8d93]" />
          Đang ẩn: <strong className="tabular-nums">{hiddenCount}</strong>
        </span>
      </div>
    </section>
  )
}
