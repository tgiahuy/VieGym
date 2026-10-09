import React, { useEffect, useMemo, useState } from 'react'
import { exerciseApi } from '../../exercises/api'
import { getEquipmentLabel, getMuscleLabel } from '../../exercises/catalogConstants'
import { initialExercises } from '../../exercises/mockData'
import type { ExerciseItem } from '../../exercises/types'
import type { WorkoutPlanExercise } from '../types'

interface ExerciseSelectModalProps {
  isOpen: boolean
  onClose: () => void
  onSelectExercises: (selectedExercises: WorkoutPlanExercise[]) => void
  alreadySelectedExerciseIds?: string[]
}

const MUSCLE_OPTIONS = [
  { value: '', label: 'Tất cả nhóm cơ' },
  { value: 'chest', label: 'Ngực (Chest)' },
  { value: 'back', label: 'Lưng xô (Back)' },
  { value: 'legs', label: 'Đùi & Mông (Legs)' },
  { value: 'shoulders', label: 'Vai (Shoulders)' },
  { value: 'arms', label: 'Tay (Arms)' },
  { value: 'abs', label: 'Cơ bụng & Lõi (Abs)' },
]

export const ExerciseSelectModal: React.FC<ExerciseSelectModalProps> = ({
  isOpen,
  onClose,
  onSelectExercises,
  alreadySelectedExerciseIds = [],
}) => {
  const [exercises, setExercises] = useState<ExerciseItem[]>(initialExercises)
  const [search, setSearch] = useState('')
  const [selectedMuscle, setSelectedMuscle] = useState('')
  const [selectedItems, setSelectedItems] = useState<ExerciseItem[]>([])

  useEffect(() => {
    if (!isOpen) return
    if (import.meta.env.MODE === 'test') return

    exerciseApi
      .list()
      .then((items) => {
        if (items && items.length > 0) {
          setExercises(items)
        }
      })
      .catch(() => {
        // Fallback to initialExercises if network fails
      })
  }, [isOpen])

  const filteredExercises = useMemo(() => {
    return exercises.filter((item) => {
      if (search.trim()) {
        const q = search.toLowerCase().trim()
        const matchesVn = item.nameVn.toLowerCase().includes(q)
        const matchesEn = item.nameEn.toLowerCase().includes(q)
        const matchesCode = item.code.toLowerCase().includes(q)
        const matchesMuscle = getMuscleLabel(item.primaryMuscle).toLowerCase().includes(q)
        const matchesEquipment = item.equipment.some((eq) =>
          getEquipmentLabel(eq).toLowerCase().includes(q)
        )
        if (!matchesVn && !matchesEn && !matchesCode && !matchesMuscle && !matchesEquipment) {
          return false
        }
      }
      if (selectedMuscle) {
        const label = getMuscleLabel(item.primaryMuscle).toLowerCase()
        const target = selectedMuscle.toLowerCase()
        if (item.primaryMuscle !== selectedMuscle && !label.includes(target)) {
          return false
        }
      }
      return true
    })
  }, [exercises, search, selectedMuscle])

  if (!isOpen) return null

  const handleToggleSelect = (item: ExerciseItem) => {
    const isSelected = selectedItems.some((ex) => ex.id === item.id)
    if (isSelected) {
      setSelectedItems(selectedItems.filter((ex) => ex.id !== item.id))
    } else {
      setSelectedItems([...selectedItems, item])
    }
  }

  const handleConfirm = () => {
    if (selectedItems.length === 0) return

    const planExercises: WorkoutPlanExercise[] = selectedItems.map((item) => ({
      id: `wpe-${Date.now()}-${Math.random().toString(36).substr(2, 6)}`,
      exerciseId: String(item.id),
      exerciseCode: item.code,
      nameVn: item.nameVn,
      nameEn: item.nameEn,
      primaryMuscle: getMuscleLabel(item.primaryMuscle) || item.primaryMuscle,
      thumbnailUrl: item.thumbnailUrl,
      sets: 3,
      reps: '8 - 12 reps',
      restSeconds: 90,
      rpe: 8,
      notes: '',
    }))

    onSelectExercises(planExercises)
    setSelectedItems([])
    onClose()
  }

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="exercise-picker-title"
      className="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fadeIn"
      onClick={onClose}
    >
      <div
        className="w-full max-w-3xl max-h-[85vh] bg-[#17181b] border border-[#292a2f] rounded-2xl flex flex-col shadow-2xl overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Header */}
        <div className="h-16 px-6 border-b border-[#292a2f] bg-[#1c1d21] flex items-center justify-between shrink-0">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-[rgba(242,48,90,0.12)] border border-[#f2305a]/30 flex items-center justify-center text-[#ff506d]">
              <span className="material-symbols-outlined text-[20px]">fitness_center</span>
            </div>
            <div>
              <h3 id="exercise-picker-title" className="text-[16px] font-bold text-[#f5f5f6]">
                Chọn bài tập từ kho dữ liệu
              </h3>
              <p className="text-[12px] text-[#8a8d93]">
                Duyệt hoặc tìm kiếm bài tập để thêm vào buổi tập của giáo án ({exercises.length} bài tập khả dụng)
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Đóng popup"
            className="text-[#8a8d93] hover:text-[#f5f5f6] p-1.5 rounded-lg hover:bg-[#222327] transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-[20px]">close</span>
          </button>
        </div>

        {/* Filter Controls */}
        <div className="p-4 border-b border-[#292a2f] bg-[#17181b] grid grid-cols-1 sm:grid-cols-2 gap-3 shrink-0">
          <div className="relative">
            <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#8a8d93] text-[18px]">
              search
            </span>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Tìm bài tập theo tên, mã code..."
              className="w-full h-10 pl-9 pr-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] placeholder-[#8a8d93] focus:outline-none focus:border-[#f2305a] transition-colors"
            />
          </div>

          <div>
            <select
              value={selectedMuscle}
              onChange={(e) => setSelectedMuscle(e.target.value)}
              aria-label="Lọc theo nhóm cơ"
              className="w-full h-10 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors cursor-pointer"
            >
              {MUSCLE_OPTIONS.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
          </div>
        </div>

        {/* Exercise List */}
        <div className="flex-1 overflow-y-auto p-4 space-y-2">
          {filteredExercises.length === 0 ? (
            <div className="py-12 text-center text-[#8a8d93] space-y-2">
              <span className="material-symbols-outlined text-[32px]">search_off</span>
              <p className="text-[13px]">Không tìm thấy bài tập nào phù hợp với bộ lọc.</p>
            </div>
          ) : (
            filteredExercises.map((item) => {
              const isChecked = selectedItems.some((ex) => ex.id === item.id)
              const isAlreadyAdded = alreadySelectedExerciseIds.includes(item.id)

              return (
                <div
                  key={item.id}
                  onClick={() => handleToggleSelect(item)}
                  className={`p-3 rounded-xl border flex items-center justify-between gap-3 transition-all cursor-pointer ${
                    isChecked
                      ? 'bg-[rgba(242,48,90,0.1)] border-[#f2305a]'
                      : 'bg-[#222327] border-[#292a2f] hover:border-[#34363b]'
                  }`}
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <input
                      type="checkbox"
                      checked={isChecked}
                      onChange={() => {}}
                      className="w-4 h-4 accent-[#f2305a] rounded shrink-0 cursor-pointer"
                    />

                    {/* Thumbnail */}
                    <div className="w-11 h-11 rounded-lg overflow-hidden border border-[#292a2f] bg-[#1c1d21] shrink-0 flex items-center justify-center">
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

                    <div className="min-w-0">
                      <div className="flex items-center gap-2">
                        <span className="text-[13px] font-semibold text-[#f5f5f6] truncate">
                          {item.nameVn}
                        </span>
                        <span className="px-1.5 py-0.2 rounded text-[10px] font-mono text-[#8a8d93] bg-[#1c1d21] border border-[#292a2f]">
                          {item.code}
                        </span>
                        {isAlreadyAdded && (
                          <span className="px-1.5 py-0.5 rounded text-[10px] font-medium bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/20">
                            Đã có trong buổi
                          </span>
                        )}
                      </div>
                      <div className="flex items-center gap-2 mt-0.5 text-[11px] text-[#8a8d93]">
                        <span className="text-[#a7a9ae]">{item.nameEn}</span>
                        <span>•</span>
                        <span className="text-[#ff506d] font-medium">
                          {getMuscleLabel(item.primaryMuscle) || item.primaryMuscle}
                        </span>
                        {item.equipment?.[0] && (
                          <>
                            <span>•</span>
                            <span className="truncate max-w-[150px]">
                              {getEquipmentLabel(item.equipment[0])}
                            </span>
                          </>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="shrink-0">
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation()
                        handleToggleSelect(item)
                      }}
                      className={`px-3 py-1.5 rounded-lg text-[12px] font-medium transition-colors ${
                        isChecked
                          ? 'bg-[#f2305a] text-white'
                          : 'bg-[#1c1d21] text-[#f5f5f6] hover:bg-[#292a2f] border border-[#292a2f]'
                      }`}
                    >
                      {isChecked ? 'Đã chọn' : '+ Chọn'}
                    </button>
                  </div>
                </div>
              )
            })
          )}
        </div>

        {/* Modal Footer */}
        <div className="h-16 px-6 border-t border-[#292a2f] bg-[#1c1d21] flex items-center justify-between shrink-0">
          <div className="text-[13px] text-[#8a8d93]">
            Đã chọn: <span className="text-[#f5f5f6] font-semibold">{selectedItems.length}</span> bài tập
          </div>
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={onClose}
              className="h-10 px-4 rounded-xl border border-[#292a2f] text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#222327] text-[13px] font-medium transition-colors cursor-pointer"
            >
              Hủy
            </button>
            <button
              type="button"
              disabled={selectedItems.length === 0}
              onClick={handleConfirm}
              className="h-10 px-5 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white text-[13px] font-semibold transition-all disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer shadow-sm"
            >
              Thêm vào buổi tập ({selectedItems.length})
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
