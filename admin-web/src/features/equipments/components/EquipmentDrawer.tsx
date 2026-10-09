import React from 'react'
import type { EquipmentItem } from '../types'

interface EquipmentDrawerProps {
  isOpen: boolean
  equipment: EquipmentItem | null
  onClose: () => void
}

export const EquipmentDrawer: React.FC<EquipmentDrawerProps> = ({
  isOpen,
  equipment,
  onClose,
}) => {
  if (!isOpen || !equipment) return null

  return (
    <div className="fixed inset-0 z-50 flex justify-end bg-black/60 backdrop-blur-sm transition-opacity duration-200">
      <div
        className="w-full max-w-lg bg-[#17181b] border-l border-[#292a2f] h-full flex flex-col justify-between shadow-2xl animate-in slide-in-from-right duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="h-16 px-6 border-b border-[#292a2f] flex items-center justify-between bg-[#17181b]">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-center text-[#ff506d] shadow-inner">
              <span className="material-symbols-outlined text-[22px]">{equipment.iconName}</span>
            </div>
            <div>
              <h2 className="text-[16px] font-bold text-[#f5f5f6] tracking-tight">
                Chi tiết thiết bị
              </h2>
              <span className="text-[12px] font-mono text-[#8a8d93]">{equipment.code}</span>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-lg bg-[#222327] hover:bg-[#2c2d33] border border-[#292a2f] flex items-center justify-center text-[#8a8d93] hover:text-[#f5f5f6] transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]">close</span>
          </button>
        </div>

        {/* Body Content */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          {/* Main Info Card */}
          <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f] space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-semibold uppercase tracking-wider text-[#8a8d93]">
                Tên thiết bị
              </span>
              <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/20">
                <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
                Hoạt động
              </span>
            </div>
            <div className="text-[20px] font-bold text-[#f5f5f6]">{equipment.name}</div>
            <div className="text-[13px] text-[#ff506d] font-medium">{equipment.nameEn}</div>
            <div className="pt-2 border-t border-[#292a2f] flex items-center gap-2">
              <span className="text-[12px] text-[#8a8d93]">Phân loại:</span>
              <span className="text-[12px] text-[#f5f5f6] font-medium bg-[#17181b] px-2.5 py-1 rounded border border-[#292a2f]">
                {equipment.categoryLabel}
              </span>
            </div>
          </div>

          {/* Description */}
          <div className="space-y-2">
            <label className="text-[12px] font-semibold uppercase tracking-wider text-[#8a8d93]">
              Mô tả chi tiết
            </label>
            <div className="p-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#a7a9ae] leading-relaxed">
              {equipment.description}
            </div>
          </div>

          {/* Suitability */}
          <div className="space-y-2">
            <label className="text-[12px] font-semibold uppercase tracking-wider text-[#8a8d93]">
              Phù hợp cho
            </label>
            <div className="p-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] flex items-start gap-2">
              <span className="material-symbols-outlined text-[#35c76f] text-[18px] shrink-0 mt-0.5">
                task_alt
              </span>
              <span>{equipment.suitableFor}</span>
            </div>
          </div>

          {/* Safety guidelines */}
          <div className="space-y-2">
            <label className="text-[12px] font-semibold uppercase tracking-wider text-[#8a8d93]">
              Lưu ý an toàn kỹ thuật
            </label>
            <div className="p-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f4b740] flex items-start gap-2">
              <span className="material-symbols-outlined text-[#f4b740] text-[18px] shrink-0 mt-0.5">
                warning
              </span>
              <span>{equipment.safetyNotes}</span>
            </div>
          </div>

          {/* Connected stats */}
          <div className="grid grid-cols-2 gap-3">
            <div className="p-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-center space-y-1">
              <span className="text-[11px] text-[#8a8d93] uppercase font-semibold">
                Bài tập liên kết
              </span>
              <div className="text-[20px] font-bold text-[#f5f5f6] font-mono">
                {equipment.exerciseCount}
              </div>
            </div>
            <div className="p-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-center space-y-1">
              <span className="text-[11px] text-[#8a8d93] uppercase font-semibold">
                Độ phổ cập
              </span>
              <div className="text-[13px] font-bold text-[#ff506d] pt-1">
                {equipment.isCommon ? 'Tiêu chuẩn phòng Gym' : 'Thiết bị bổ trợ'}
              </div>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="h-16 px-6 border-t border-[#292a2f] bg-[#17181b] flex items-center justify-end">
          <button
            type="button"
            onClick={onClose}
            className="h-10 px-5 bg-[#222327] hover:bg-[#2c2d33] border border-[#292a2f] text-[#f5f5f6] text-[13px] font-medium rounded-xl transition-colors cursor-pointer"
          >
            Đóng
          </button>
        </div>
      </div>
    </div>
  )
}
