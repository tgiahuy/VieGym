import React from 'react'
import type { ExerciseFilterState } from '../types'
import { getEquipmentLabel, getMuscleLabel, MUSCLE_GROUPS, EQUIPMENTS } from '../catalogConstants'

interface ExerciseFilterBarProps {
  filters: ExerciseFilterState
  onChange: (filters: ExerciseFilterState) => void
  totalCount: number
  activeCount: number
  hiddenCount: number
}

export const ExerciseFilterBar: React.FC<ExerciseFilterBarProps> = ({
  filters,
  onChange,
  totalCount,
  activeCount,
  hiddenCount,
}) => {
  const handleReset = () => {
    onChange({
      search: '',
      muscle: '',
      equipment: '',
      level: '',
      status: '',
    })
  }

  const activeFiltersDesc: string[] = []
  if (filters.muscle) {
    activeFiltersDesc.push(`Cơ: ${getMuscleLabel(filters.muscle)}`)
  }
  if (filters.equipment) {
    activeFiltersDesc.push(`Thiết bị: ${getEquipmentLabel(filters.equipment)}`)
  }
  if (filters.status) {
    activeFiltersDesc.push(filters.status === 'active' ? 'Active' : 'Hidden')
  }

  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-xl p-4 space-y-3">
      <div className="grid grid-cols-1 md:grid-cols-12 gap-3 items-center">
        {/* Search bar (4 cols) */}
        <div className="md:col-span-4 relative">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px]">
            search
          </span>
          <input
            type="text"
            value={filters.search}
            onChange={(e) => onChange({ ...filters, search: e.target.value })}
            placeholder="Tìm tên VN/EN..."
            className="w-full h-11 pl-9 pr-8 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] placeholder:text-[#8a8d93] focus:outline-none focus:border-[#f2305a] text-[14px]"
          />
          {filters.search && (
            <button
              type="button"
              onClick={() => onChange({ ...filters, search: '' })}
              className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] hover:text-[#f5f5f6] text-[16px]"
            >
              close
            </button>
          )}
        </div>

        {/* Nhóm cơ Select (2 cols) */}
        <div className="md:col-span-2">
          <div className="relative">
            <select
              value={filters.muscle}
              onChange={(e) => onChange({ ...filters, muscle: e.target.value })}
              className="w-full h-11 px-3 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a] cursor-pointer"
            >
              <option value="">Nhóm cơ: Tất cả</option>
              {MUSCLE_GROUPS.map((mg) => (
                <option key={mg.id} value={String(mg.id)}>
                  {mg.name}
                </option>
              ))}
            </select>
            <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px] pointer-events-none">
              expand_more
            </span>
          </div>
        </div>

        {/* Thiết bị Select (2 cols) */}
        <div className="md:col-span-2">
          <div className="relative">
            <select
              value={filters.equipment}
              onChange={(e) => onChange({ ...filters, equipment: e.target.value })}
              className="w-full h-11 px-3 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a] cursor-pointer"
            >
              <option value="">Thiết bị: Tất cả</option>
              {EQUIPMENTS.map((eq) => (
                <option key={eq.id} value={String(eq.id)}>
                  {eq.name}
                </option>
              ))}
            </select>
            <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px] pointer-events-none">
              expand_more
            </span>
          </div>
        </div>

        {/* Cấp độ Select (2 cols) */}
        <div className="md:col-span-2">
          <div className="relative">
            <select
              value={filters.level}
              onChange={(e) => onChange({ ...filters, level: e.target.value })}
              className="w-full h-11 px-3 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a] cursor-pointer"
            >
              <option value="">Cấp độ: Tất cả</option>
              <option value="beginner">Mới bắt đầu</option>
              <option value="intermediate">Trung bình</option>
              <option value="advanced">Nâng cao</option>
            </select>
            <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px] pointer-events-none">
              expand_more
            </span>
          </div>
        </div>

        {/* Trạng thái & Reset Button (2 cols) */}
        <div className="md:col-span-2 flex items-center gap-2">
          <div className="relative flex-1">
            <select
              value={filters.status}
              onChange={(e) => onChange({ ...filters, status: e.target.value })}
              className="w-full h-11 px-3 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a] cursor-pointer"
            >
              <option value="">Trạng thái: Tất cả</option>
              <option value="active">Active</option>
              <option value="hidden">Hidden</option>
            </select>
            <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px] pointer-events-none">
              expand_more
            </span>
          </div>
          <button
            type="button"
            onClick={handleReset}
            className="h-11 px-3 bg-[#222327] hover:bg-[#1c1d21] border border-[#292a2f] text-[#8a8d93] hover:text-[#f5f5f6] rounded-xl transition-colors flex items-center justify-center cursor-pointer"
            title="Xóa bộ lọc"
          >
            <span className="material-symbols-outlined text-[18px]">restart_alt</span>
          </button>
        </div>
      </div>

      {/* Quick Metrics Summary strip */}
      <div className="flex flex-wrap items-center justify-between pt-2 border-t border-[#292a2f]/60 text-[12px] text-[#8a8d93] gap-2">
        <div className="flex items-center gap-4">
          <span>
            Tổng số: <strong className="text-[#f5f5f6]">{totalCount}</strong> bài tập
          </span>
          <span className="w-1 h-1 rounded-full bg-[#34363b]" />
          <span className="text-[#35c76f] flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-[#35c76f]" /> {activeCount} Đang hoạt động (Active)
          </span>
          <span className="w-1 h-1 rounded-full bg-[#34363b]" />
          <span className="text-[#f4b740] flex items-center gap-1.5">
            <span className="w-2 h-2 rounded-full bg-[#f4b740]" /> {hiddenCount} Ẩn (Hidden)
          </span>
        </div>
        {activeFiltersDesc.length > 0 && (
          <div className="flex items-center gap-2 text-[#a7a9ae]">
            <span>
              Đang lọc theo: <strong>{activeFiltersDesc.join(' · ')}</strong>
            </span>
          </div>
        )}
      </div>
    </div>
  )
}
