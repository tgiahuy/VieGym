import React from 'react'
import type { EquipmentCategory, EquipmentItem } from '../types'

interface EquipmentTableProps {
  equipments: EquipmentItem[]
  selectedId: number | null
  onSelect: (equipment: EquipmentItem) => void
}

export const EquipmentTable: React.FC<EquipmentTableProps> = ({
  equipments,
  selectedId,
  onSelect,
}) => {
  const getCategoryBadge = (category: EquipmentCategory, label: string) => {
    switch (category) {
      case 'free_weights':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-md text-[11px] font-medium bg-[#ff506d]/15 text-[#ff506d] border border-[#ff506d]/30">
            <span className="material-symbols-outlined text-[13px]">fitness_center</span>
            {label}
          </span>
        )
      case 'machines':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-md text-[11px] font-medium bg-[#9b7bff]/15 text-[#bfaaff] border border-[#9b7bff]/30">
            <span className="material-symbols-outlined text-[13px]">precision_manufacturing</span>
            {label}
          </span>
        )
      case 'bodyweight':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-md text-[11px] font-medium bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/30">
            <span className="material-symbols-outlined text-[13px]">accessibility_new</span>
            {label}
          </span>
        )
      case 'cardio':
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-md text-[11px] font-medium bg-[#facc15]/15 text-[#facc15] border border-[#facc15]/30">
            <span className="material-symbols-outlined text-[13px]">directions_run</span>
            {label}
          </span>
        )
      default:
        return (
          <span className="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-md text-[11px] font-medium bg-[#222327] text-[#a7a9ae] border border-[#292a2f]">
            <span className="material-symbols-outlined text-[13px]">category</span>
            {label}
          </span>
        )
    }
  }

  if (equipments.length === 0) {
    return (
      <div className="bg-[#17181b] border border-[#292a2f] rounded-xl p-12 text-center text-[#8a8d93] space-y-3">
        <span className="material-symbols-outlined text-[36px] text-[#8a8d93]">search_off</span>
        <p className="text-[14px]">Không tìm thấy thiết bị nào phù hợp với bộ lọc.</p>
      </div>
    )
  }

  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-xl overflow-hidden shadow-sm">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="h-11 bg-[#17181b] border-b border-[#292a2f] text-[12px] font-semibold text-[#a7a9ae] uppercase tracking-wider">
              <th className="py-3 px-4 w-16 text-center">Biểu tượng</th>
              <th className="py-3 px-4">Tên thiết bị (Mã CODE)</th>
              <th className="py-3 px-4">Phân loại</th>
              <th className="py-3 px-4">Mô tả &amp; Ứng dụng</th>
              <th className="py-3 px-4 text-center">Số bài tập liên kết</th>
              <th className="py-3 px-4">Trạng thái</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#292a2f] text-[14px]">
            {equipments.map((item) => {
              const isSelected = selectedId === item.id
              return (
                <tr
                  key={item.id}
                  onClick={() => onSelect(item)}
                  className={`h-16 transition-colors cursor-pointer ${
                    isSelected
                      ? 'bg-[#222327] border-l-[3px] border-l-[#f2305a] hover:bg-[#1c1d21]'
                      : 'hover:bg-[#1c1d21]'
                  }`}
                >
                  {/* Icon */}
                  <td className="py-2 px-4 text-center">
                    <div className="w-10 h-10 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-center text-[#ff506d] mx-auto shadow-inner">
                      <span className="material-symbols-outlined text-[20px]">{item.iconName}</span>
                    </div>
                  </td>

                  {/* Name & Code */}
                  <td className="py-2 px-4">
                    <div className="flex flex-col">
                      <span className="font-semibold text-[#f5f5f6] flex items-center gap-1.5">
                        {item.name}
                        {item.isCommon && (
                          <span className="text-[10px] bg-[rgba(242,48,90,0.12)] text-[#ff506d] px-1.5 py-0.5 rounded font-mono font-bold">
                            Phổ biến
                          </span>
                        )}
                      </span>
                      <span className="text-[12px] text-[#8a8d93] font-mono">{item.code}</span>
                    </div>
                  </td>

                  {/* Category */}
                  <td className="py-2 px-4">
                    {getCategoryBadge(item.category, item.categoryLabel)}
                  </td>

                  {/* Description */}
                  <td className="py-2 px-4 max-w-xs">
                    <p className="text-[13px] text-[#a7a9ae] truncate" title={item.description}>
                      {item.description}
                    </p>
                  </td>

                  {/* Exercise Count */}
                  <td className="py-2 px-4 text-center">
                    <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[12px] font-semibold bg-[#222327] text-[#f5f5f6] border border-[#292a2f]">
                      {item.exerciseCount} bài
                    </span>
                  </td>

                  {/* Status */}
                  <td className="py-2 px-4">
                    {item.status === 'active' ? (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-semibold bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/20">
                        <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
                        Active
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[12px] font-semibold bg-[#f4b740]/10 text-[#f4b740] border border-[#f4b740]/20">
                        <span className="w-1.5 h-1.5 rounded-full bg-[#f4b740]" />
                        Hidden
                      </span>
                    )}
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      {/* Pagination summary */}
      <div className="h-14 px-6 border-t border-[#292a2f] bg-[#17181b] flex items-center justify-between text-[12px] text-[#8a8d93]">
        <div>
          Hiển thị <strong className="text-[#f5f5f6]">1–{equipments.length}</strong> trên tổng số{' '}
          <strong className="text-[#f5f5f6]">{equipments.length}</strong> thiết bị
        </div>
        <div className="flex items-center gap-2">
          <span className="px-2.5 py-1 rounded bg-[#222327] text-[#f5f5f6] font-mono">
            Trang 1 / 1
          </span>
        </div>
      </div>
    </div>
  )
}
