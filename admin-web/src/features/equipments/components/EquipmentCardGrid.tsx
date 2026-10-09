import React from 'react'
import type { EquipmentItem } from '../types'

interface EquipmentCardGridProps {
  equipments: EquipmentItem[]
  selectedId: number | null
  onSelect: (equipment: EquipmentItem) => void
}

export const EquipmentCardGrid: React.FC<EquipmentCardGridProps> = ({
  equipments,
  selectedId,
  onSelect,
}) => {
  if (equipments.length === 0) {
    return (
      <div className="bg-[#17181b] border border-[#292a2f] rounded-xl p-12 text-center text-[#8a8d93] space-y-3">
        <span className="material-symbols-outlined text-[36px] text-[#8a8d93]">search_off</span>
        <p className="text-[14px]">Không tìm thấy thiết bị nào phù hợp với bộ lọc.</p>
      </div>
    )
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
      {equipments.map((item) => {
        const isSelected = selectedId === item.id
        return (
          <div
            key={item.id}
            onClick={() => onSelect(item)}
            className={`p-5 rounded-2xl bg-[#17181b] border transition-all duration-200 cursor-pointer flex flex-col justify-between hover:translate-y-[-2px] hover:shadow-lg ${
              isSelected
                ? 'border-[#ff506d] ring-1 ring-[#ff506d]/30 bg-[#1c1d21]'
                : 'border-[#292a2f] hover:border-[#383a42] hover:bg-[#1a1b1f]'
            }`}
          >
            <div>
              {/* Header Icon + Code */}
              <div className="flex items-center justify-between mb-3">
                <div className="w-12 h-12 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-center text-[#ff506d] shadow-sm">
                  <span className="material-symbols-outlined text-[24px]">{item.iconName}</span>
                </div>
                <div className="flex flex-col items-end gap-1">
                  <span className="text-[11px] font-mono text-[#8a8d93] bg-[#222327] px-2 py-0.5 rounded border border-[#292a2f]">
                    {item.code}
                  </span>
                  {item.isCommon && (
                    <span className="text-[10px] text-[#ff506d] font-bold bg-[rgba(242,48,90,0.1)] px-1.5 py-0.5 rounded">
                      ★ Phổ biến
                    </span>
                  )}
                </div>
              </div>

              {/* Title & Category */}
              <h3 className="text-[16px] font-bold text-[#f5f5f6] tracking-tight">{item.name}</h3>
              <p className="text-[12px] text-[#ff506d] font-medium mb-2">{item.nameEn}</p>
              <span className="inline-block text-[11px] font-medium text-[#a7a9ae] bg-[#222327] px-2.5 py-0.5 rounded-md mb-3 border border-[#292a2f]">
                {item.categoryLabel}
              </span>

              {/* Description */}
              <p className="text-[13px] text-[#8a8d93] line-clamp-2 mb-4 leading-relaxed">
                {item.description}
              </p>
            </div>

            {/* Footer */}
            <div className="pt-3 border-t border-[#292a2f] flex items-center justify-between text-[12px]">
              <span className="text-[#a7a9ae] flex items-center gap-1">
                <span className="material-symbols-outlined text-[15px] text-[#8a8d93]">
                  fitness_center
                </span>
                <strong>{item.exerciseCount}</strong> bài tập
              </span>
              <span className="text-[#35c76f] font-semibold flex items-center gap-1">
                <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
                {item.status === 'active' ? 'Hoạt động' : 'Tạm ẩn'}
              </span>
            </div>
          </div>
        )
      })}
    </div>
  )
}
