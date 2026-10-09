import React from 'react'
import type { ExerciseItem } from '../types'
import { getEquipmentLabel, getMuscleLabel } from '../catalogConstants'

interface ExerciseTableProps {
  exercises: ExerciseItem[]
  selectedId: string | null
  onSelect: (exercise: ExerciseItem) => void
}

export const ExerciseTable: React.FC<ExerciseTableProps> = ({
  exercises,
  selectedId,
  onSelect,
}) => {
  const getLevelBadge = (level: string) => {
    const normalized = (level || '').toLowerCase().trim()
    switch (normalized) {
      case 'beginner':
      case 'mới bắt đầu':
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-md text-[11px] font-medium bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/25 tracking-normal">
            Mới bắt đầu
          </span>
        )
      case 'intermediate':
      case 'trung bình':
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-md text-[11px] font-medium bg-[#eab308]/15 text-[#facc15] border border-[#facc15]/25 tracking-normal">
            Trung bình
          </span>
        )
      case 'advanced':
      case 'nâng cao':
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-md text-[11px] font-medium bg-[#f2305a]/15 text-[#ff506d] border border-[#f2305a]/25 tracking-normal">
            Nâng cao
          </span>
        )
      default:
        return (
          <span className="inline-flex items-center px-2.5 py-0.5 rounded-md text-[11px] font-medium bg-[#222327] text-[#a7a9ae] border border-[#292a2f] tracking-normal">
            {level || 'Tất cả'}
          </span>
        )
    }
  }

  if (exercises.length === 0) {
    return (
      <div className="bg-[#17181b] border border-[#292a2f] rounded-xl p-12 text-center text-[#8a8d93] space-y-3">
        <span className="material-symbols-outlined text-[36px] text-[#8a8d93]">search_off</span>
        <p className="text-[14px]">Không tìm thấy bài tập nào phù hợp với bộ lọc.</p>
      </div>
    )
  }

  return (
    <div className="bg-[#17181b] border border-[#292a2f] rounded-xl overflow-hidden shadow-sm">
      <div className="overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="h-11 bg-[#17181b] border-b border-[#292a2f] text-[12px] font-semibold text-[#a7a9ae] uppercase tracking-wider">
              <th className="py-3 px-4 w-16 text-center">Ảnh</th>
              <th className="py-3 px-4">Tên bài tập (VN / EN)</th>
              <th className="py-3 px-4">Nhóm cơ</th>
              <th className="py-3 px-4">Thiết bị</th>
              <th className="py-3 px-4">Cấp độ</th>
              <th className="py-3 px-4">Trạng thái</th>
              <th className="py-3 px-4">Ngày cập nhật</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-[#292a2f] text-[14px]">
            {exercises.map((item) => {
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
                  {/* Thumbnail */}
                  <td className="py-2 px-4 text-center">
                    <div className="w-12 h-12 rounded-lg overflow-hidden border border-[#292a2f] mx-auto bg-[#222327] flex items-center justify-center">
                      {item.thumbnailUrl ? (
                        <img
                          src={item.thumbnailUrl}
                          alt={item.nameVn}
                          className="w-full h-full object-cover"
                        />
                      ) : (
                        <span className="material-symbols-outlined text-[#8a8d93] text-[20px]">
                          fitness_center
                        </span>
                      )}
                    </div>
                  </td>

                  {/* Name VN / EN */}
                  <td className="py-2 px-4">
                    <div className="flex flex-col">
                      <span className="font-semibold text-[#f5f5f6] flex items-center gap-1.5">
                        {item.nameVn}
                        <span className="text-[10px] bg-[rgba(242,48,90,0.12)] text-[#f2305a] px-1.5 py-0.5 rounded font-mono font-bold">
                          {item.code}
                        </span>
                      </span>
                      <span className="text-[12px] text-[#a7a9ae]">{item.nameEn}</span>
                    </div>
                  </td>

                  {/* Muscle */}
                  <td className="py-2 px-4">
                    <div className="flex flex-col">
                      <span className="text-[#f5f5f6] font-medium">
                        {getMuscleLabel(item.primaryMuscle)}
                      </span>
                      {item.secondaryMuscles.length > 0 && (
                        <span className="text-[12px] text-[#8a8d93]">
                          +{item.secondaryMuscles.length} phụ:{' '}
                          {item.secondaryMuscles.slice(0, 2).map(getMuscleLabel).join(', ')}
                        </span>
                      )}
                    </div>
                  </td>

                  {/* Equipment */}
                  <td className="py-2 px-4 text-[#a7a9ae]">
                    <span>
                      {item.equipment && item.equipment.length > 0
                        ? item.equipment.map(getEquipmentLabel).join(' · ')
                        : 'Trọng lượng cơ thể'}
                    </span>
                  </td>

                  {/* Level */}
                  <td className="py-2 px-4">{getLevelBadge(item.level)}</td>

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

                  {/* Updated At */}
                  <td className="py-2 px-4 text-[#8a8d93] text-[12px] font-mono">
                    {item.updatedAt}
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      {/* Pagination Row */}
      <div className="h-14 px-6 border-t border-[#292a2f] bg-[#17181b] flex flex-wrap items-center justify-between text-[14px] text-[#a7a9ae] gap-4">
        <div className="text-[12px] text-[#8a8d93]">
          Hiển thị <span className="text-[#f5f5f6] font-semibold">1–{exercises.length}</span> trên
          tổng số <span className="text-[#f5f5f6] font-semibold">{exercises.length}</span> bài tập
        </div>
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-2 text-[12px]">
            <span>Dòng mỗi trang:</span>
            <select className="h-8 px-2 bg-[#222327] border border-[#292a2f] rounded-lg text-[#f5f5f6] text-[12px] focus:outline-none focus:border-[#f2305a]">
              <option>20 / trang</option>
              <option>50 / trang</option>
              <option>100 / trang</option>
            </select>
          </div>
          <div className="flex items-center gap-1">
            <button
              type="button"
              disabled
              className="w-8 h-8 rounded-lg bg-[#222327] border border-[#292a2f] flex items-center justify-center text-[#8a8d93] disabled:opacity-40"
            >
              <span className="material-symbols-outlined text-[16px]">chevron_left</span>
            </button>
            <span className="px-2 text-[12px] text-[#f5f5f6] font-medium">1 / 1</span>
            <button
              type="button"
              disabled
              className="w-8 h-8 rounded-lg bg-[#222327] border border-[#292a2f] flex items-center justify-center text-[#8a8d93] disabled:opacity-40"
            >
              <span className="material-symbols-outlined text-[16px]">chevron_right</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
