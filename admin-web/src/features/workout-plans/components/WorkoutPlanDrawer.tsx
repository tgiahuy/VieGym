import React, { useEffect, useState } from 'react'
import { getMuscleLabel } from '../../exercises/catalogConstants'
import { ExerciseSelectModal } from './ExerciseSelectModal'
import type {
  WorkoutPlan,
  WorkoutPlanDay,
  WorkoutPlanExercise,
  WorkoutPlanGoal,
  WorkoutPlanLevel,
  WorkoutPlanStatus,
} from '../types'

const MUSCLE_MAP: Record<string, string> = {
  chest: 'Cơ ngực',
  back: 'Cơ lưng xô',
  shoulders: 'Cơ vai',
  biceps: 'Cơ tay trước',
  triceps: 'Cơ tay sau',
  legs: 'Cơ đùi & mông',
  abs: 'Cơ bụng',
}

const getDefaultDay = (dayNum: number): WorkoutPlanDay => {
  const templates: Record<number, { name: string; desc: string; muscles: string[] }> = {
    1: {
      name: 'Buổi 1: Thân trên (Upper Body Focus)',
      desc: 'Tập trung cơ ngực, lưng xô và vai',
      muscles: ['chest', 'back', 'shoulders'],
    },
    2: {
      name: 'Buổi 2: Thân dưới (Lower Body Focus)',
      desc: 'Tập trung đùi trước, đùi sau và bắp chân',
      muscles: ['quadriceps', 'hamstrings', 'calves'],
    },
    3: {
      name: 'Buổi 3: Đẩy (Push Focus)',
      desc: 'Tập trung cơ ngực, vai trước và tay sau',
      muscles: ['chest', 'shoulders', 'triceps'],
    },
    4: {
      name: 'Buổi 4: Kéo (Pull Focus)',
      desc: 'Tập trung cơ lưng xô, vai sau và tay trước',
      muscles: ['back', 'biceps'],
    },
    5: {
      name: 'Buổi 5: Chân & Bụng (Legs & Core)',
      desc: 'Tập trung đùi, mông và cơ lõi',
      muscles: ['quadriceps', 'glutes', 'abs'],
    },
    6: {
      name: 'Buổi 6: Toàn thân (Full Body)',
      desc: 'Kích hoạt toàn bộ các nhóm cơ chính',
      muscles: ['chest', 'back', 'quadriceps'],
    },
    7: {
      name: 'Buổi 7: Tim mạch & Phục hồi (Cardio & Recovery)',
      desc: 'Vận động nhẹ nhàng và phục hồi chủ động',
      muscles: ['abs'],
    },
  }

  const tmpl = templates[dayNum] || {
    name: `Buổi ${dayNum}: Buổi tập ${dayNum}`,
    desc: `Mô tả mục tiêu buổi ${dayNum}...`,
    muscles: ['chest'],
  }

  return {
    id: `day-new-${Date.now()}-${dayNum}`,
    dayNumber: dayNum,
    name: tmpl.name,
    description: tmpl.desc,
    targetMuscles: tmpl.muscles,
    exercises: [],
  }
}

interface WorkoutPlanDrawerProps {
  isOpen: boolean
  plan: WorkoutPlan | null
  onClose: () => void
  onSave: (plan: WorkoutPlan) => void
  onDelete?: (id: string) => void
}

interface DrawerFormContentProps {
  plan: WorkoutPlan | null
  onClose: () => void
  onSave: (plan: WorkoutPlan) => void
  onDelete?: (id: string) => void
}

const DrawerFormContent: React.FC<DrawerFormContentProps> = ({
  plan,
  onClose,
  onSave,
  onDelete,
}) => {
  const [activeTab, setActiveTab] = useState<'info' | 'builder' | 'insights'>('info')

  // Basic Info Form State
  const [title, setTitle] = useState(plan?.title || '')
  const [description, setDescription] = useState(plan?.description || '')
  const [goal, setGoal] = useState<WorkoutPlanGoal>(plan?.goal || 'hypertrophy')
  const [level, setLevel] = useState<WorkoutPlanLevel>(plan?.level || 'intermediate')
  const initialDaysCount = plan?.days?.length || plan?.daysPerWeek || 4
  const [daysPerWeek, setDaysPerWeek] = useState<number>(initialDaysCount)
  const [estimatedDurationMin, setEstimatedDurationMin] = useState<number>(
    plan?.estimatedDurationMin || 60
  )
  const [author, setAuthor] = useState(plan?.author || 'VieGym Master Coach')
  const [status, setStatus] = useState<WorkoutPlanStatus>(plan?.status || 'active')

  // Routine Days & Exercises State
  const [days, setDays] = useState<WorkoutPlanDay[]>(() => {
    if (plan?.days && plan.days.length > 0) {
      return plan.days
    }
    return Array.from({ length: initialDaysCount }, (_, idx) => getDefaultDay(idx + 1))
  })

  const [activeDayIndex, setActiveDayIndex] = useState<number>(0)
  const [isExercisePickerOpen, setIsExercisePickerOpen] = useState(false)

  // Ensure active day index is within range
  const currentDay = days[activeDayIndex] || days[0]

  // Synchronize days with daysPerWeek
  const handleDaysPerWeekChange = (count: number) => {
    const targetCount = Math.min(Math.max(1, count), 7)
    setDaysPerWeek(targetCount)

    setDays((prevDays) => {
      if (prevDays.length === targetCount) return prevDays
      if (targetCount > prevDays.length) {
        const added: WorkoutPlanDay[] = []
        for (let i = prevDays.length + 1; i <= targetCount; i++) {
          added.push(getDefaultDay(i))
        }
        return [...prevDays, ...added]
      } else {
        return prevDays.slice(0, targetCount)
      }
    })

    setActiveDayIndex((prev) => (prev >= targetCount ? Math.max(0, targetCount - 1) : prev))
  }

  // Day Operations
  const handleAddDay = () => {
    if (days.length >= 7) {
      alert('Tối đa 7 buổi tập mỗi tuần.')
      return
    }
    const newDayNum = days.length + 1
    const newDay = getDefaultDay(newDayNum)
    const nextDays = [...days, newDay]
    setDays(nextDays)
    setDaysPerWeek(nextDays.length)
    setActiveDayIndex(days.length)
  }

  const handleRemoveDay = (dayIndex: number) => {
    if (days.length <= 1) {
      alert('Giáo án cần có ít nhất 1 buổi tập.')
      return
    }
    const dayToRemove = days[dayIndex]
    if (dayToRemove && window.confirm(`Bạn có chắc chắn muốn xóa "${dayToRemove.name}"?`)) {
      const nextDays = days.filter((_, idx) => idx !== dayIndex)
      const renumbered: WorkoutPlanDay[] = nextDays.map((d, idx) => ({ ...d, dayNumber: idx + 1 }))
      setDays(renumbered)
      setDaysPerWeek(renumbered.length)
      if (activeDayIndex >= renumbered.length) {
        setActiveDayIndex(renumbered.length - 1)
      }
    }
  }

  const handleUpdateDayName = (newName: string) => {
    setDays((prev) =>
      prev.map((d, idx) => (idx === activeDayIndex ? { ...d, name: newName } : d))
    )
  }

  const handleUpdateDayDesc = (newDesc: string) => {
    setDays((prev) =>
      prev.map((d, idx) => (idx === activeDayIndex ? { ...d, description: newDesc } : d))
    )
  }

  // Exercise Operations inside active day
  const handleAddExercisesToCurrentDay = (newExercises: WorkoutPlanExercise[]) => {
    setDays((prev) =>
      prev.map((d, idx) =>
        idx === activeDayIndex
          ? { ...d, exercises: [...d.exercises, ...newExercises] }
          : d
      )
    )
  }

  const handleUpdateExercise = (
    exerciseIndex: number,
    updatedFields: Partial<WorkoutPlanExercise>
  ) => {
    setDays((prev) =>
      prev.map((d, dIdx) => {
        if (dIdx !== activeDayIndex) return d
        const updatedExs = d.exercises.map((ex, eIdx) =>
          eIdx === exerciseIndex ? { ...ex, ...updatedFields } : ex
        )
        return { ...d, exercises: updatedExs }
      })
    )
  }

  const handleRemoveExercise = (exerciseIndex: number) => {
    setDays((prev) =>
      prev.map((d, dIdx) => {
        if (dIdx !== activeDayIndex) return d
        return { ...d, exercises: d.exercises.filter((_, eIdx) => eIdx !== exerciseIndex) }
      })
    )
  }

  const handleMoveExercise = (exerciseIndex: number, direction: 'up' | 'down') => {
    setDays((prev) =>
      prev.map((d, dIdx) => {
        if (dIdx !== activeDayIndex) return d
        const targetIndex = direction === 'up' ? exerciseIndex - 1 : exerciseIndex + 1
        if (targetIndex < 0 || targetIndex >= d.exercises.length) return d
        const updatedExs = [...d.exercises]
        const currentItem = updatedExs[exerciseIndex]
        const targetItem = updatedExs[targetIndex]
        if (!currentItem || !targetItem) return d
        updatedExs[exerciseIndex] = targetItem
        updatedExs[targetIndex] = currentItem
        return { ...d, exercises: updatedExs }
      })
    )
  }

  // Calculate volume & insights
  const muscleSetsBreakdown = days.reduce((acc, d) => {
    d.exercises.forEach((ex) => {
      const muscle = ex.primaryMuscle || 'other'
      acc[muscle] = (acc[muscle] || 0) + Number(ex.sets || 3)
    })
    return acc
  }, {} as Record<string, number>)

  const totalExercisesCount = days.reduce(
    (sum, d) => sum + (d.exercises?.length || 0),
    0
  )
  const totalWeeklySets = Object.values(muscleSetsBreakdown).reduce(
    (sum, count) => sum + count,
    0
  )

  // Save handler
  const handleSave = (e: React.FormEvent) => {
    e.preventDefault()
    if (!title.trim()) {
      alert('Vui lòng nhập tên giáo án.')
      return
    }

    const updatedPlan: WorkoutPlan = {
      id: plan ? plan.id : `wp-${Date.now()}`,
      code: plan ? plan.code : `PL-0${Math.floor(200 + Math.random() * 800)}`,
      title: title.trim(),
      description: description.trim(),
      goal,
      level,
      daysPerWeek: Number(daysPerWeek) || days.length,
      durationWeeks: plan?.durationWeeks || 8,
      estimatedDurationMin: Number(estimatedDurationMin) || 60,
      status,
      author: author.trim() || 'VieGym Master Coach',
      tags: plan?.tags || [],
      days,
      createdAt: plan ? plan.createdAt : 'Hôm nay',
      updatedAt: 'Hôm nay',
    }

    onSave(updatedPlan)
    onClose()
  }

  const handleDeletePlan = () => {
    if (!plan) return
    if (
      window.confirm(
        `Bạn có chắc chắn muốn xóa giáo án "${plan.title}"? Thao tác này không thể hoàn tác.`
      )
    ) {
      onDelete?.(plan.id)
      onClose()
    }
  }

  const isEditMode = !!plan

  return (
    <div
      className="w-full max-w-3xl max-h-[90vh] bg-[#17181b] border border-[#292a2f] rounded-2xl flex flex-col shadow-2xl overflow-hidden animate-in zoom-in-95 duration-150"
      onClick={(e) => e.stopPropagation()}
    >
      {/* Modal Header */}
      <div className="h-16 px-6 border-b border-[#292a2f] bg-[#1c1d21] flex items-center justify-between shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[rgba(242,48,90,0.12)] border border-[#f2305a]/20 flex items-center justify-center text-[#ff506d]">
            <span className="material-symbols-outlined text-[18px]">menu_book</span>
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-[16px] font-bold text-[#f5f5f6]">
                {isEditMode ? 'Chỉnh sửa giáo án' : 'Tạo mới giáo án tập luyện'}
              </h2>
              {isEditMode && (
                <span className="px-2 py-0.5 rounded text-[11px] font-mono font-medium bg-[#222327] text-[#a7a9ae] border border-[#292a2f]">
                  #{plan.code}
                </span>
              )}
            </div>
            <p className="text-[12px] text-[#8a8d93]">
              Thiết lập thông tin, cấu trúc buổi tập và phân bổ bài tập
            </p>
          </div>
        </div>

        <button
          type="button"
          onClick={onClose}
          aria-label="Đóng cửa sổ"
          className="text-[#8a8d93] hover:text-[#f5f5f6] p-1.5 rounded-lg hover:bg-[#222327] transition-colors cursor-pointer"
        >
          <span className="material-symbols-outlined text-[20px]">close</span>
        </button>
      </div>

      {/* Tabs Navigation */}
      <div className="flex items-center px-6 border-b border-[#292a2f] bg-[#17181b] shrink-0 gap-6">
        <button
          type="button"
          onClick={() => setActiveTab('info')}
          className={`h-12 border-b-2 text-[13px] font-semibold flex items-center gap-2 transition-colors cursor-pointer ${
            activeTab === 'info'
              ? 'border-[#f2305a] text-[#f5f5f6]'
              : 'border-transparent text-[#8a8d93] hover:text-[#f5f5f6]'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">info</span>
          <span>1. Thông tin chung</span>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab('builder')}
          className={`h-12 border-b-2 text-[13px] font-semibold flex items-center gap-2 transition-colors cursor-pointer ${
            activeTab === 'builder'
              ? 'border-[#f2305a] text-[#f5f5f6]'
              : 'border-transparent text-[#8a8d93] hover:text-[#f5f5f6]'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">fitness_center</span>
          <span>2. Lịch tập &amp; Bài tập ({days.length} buổi • {totalExercisesCount} bài)</span>
        </button>

        <button
          type="button"
          onClick={() => setActiveTab('insights')}
          className={`h-12 border-b-2 text-[13px] font-semibold flex items-center gap-2 transition-colors cursor-pointer ${
            activeTab === 'insights'
              ? 'border-[#f2305a] text-[#f5f5f6]'
              : 'border-transparent text-[#8a8d93] hover:text-[#f5f5f6]'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">monitoring</span>
          <span>3. AI Phân tích &amp; Khối lượng</span>
        </button>
      </div>

      {/* Main Drawer Form Body */}
      <form onSubmit={handleSave} className="flex-1 overflow-y-auto p-6 space-y-6">
        {/* TAB 1: THÔNG TIN CHUNG */}
        {activeTab === 'info' && (
          <div className="space-y-5 animate-fadeIn">
            {/* Title */}
            <div>
              <label className="block text-[13px] font-medium text-[#f5f5f6] mb-1.5">
                Tên giáo án tập luyện <span className="text-[#ff506d]">*</span>
              </label>
              <input
                type="text"
                required
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Ví dụ: Giáo án Đẩy - Kéo - Chân 4 Buổi (Push - Pull - Legs)"
                className="w-full h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] placeholder-[#8a8d93] focus:outline-none focus:border-[#f2305a] transition-colors"
              />
            </div>

            {/* Description */}
            <div>
              <label className="block text-[13px] font-medium text-[#f5f5f6] mb-1.5">
                Mô tả &amp; Mục tiêu chương trình
              </label>
              <textarea
                rows={3}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Mô tả chi tiết mục tiêu, đối tượng phù hợp, nguyên lý tăng tải hoặc ghi chú vận hành..."
                className="w-full p-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] placeholder-[#8a8d93] focus:outline-none focus:border-[#f2305a] transition-colors resize-none"
              />
            </div>

            {/* Goal & Level */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[13px] font-medium text-[#f5f5f6] mb-1.5">
                  Mục tiêu huấn luyện chính
                </label>
                <select
                  value={goal}
                  onChange={(e) => setGoal(e.target.value as WorkoutPlanGoal)}
                  className="w-full h-11 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors cursor-pointer"
                >
                  <option value="hypertrophy">Tăng cơ bắp (Hypertrophy)</option>
                  <option value="strength">Tăng sức mạnh tối đa (Strength)</option>
                  <option value="fat_loss">Giảm mỡ &amp; Cắt nét (Fat Loss)</option>
                  <option value="general_fitness">Thể lực &amp; Nền tảng (General Fitness)</option>
                  <option value="endurance">Sức bền tim mạch &amp; cơ (Endurance)</option>
                </select>
              </div>

              <div>
                <label className="block text-[13px] font-medium text-[#f5f5f6] mb-1.5">
                  Cấp độ học viên
                </label>
                <select
                  value={level}
                  onChange={(e) => setLevel(e.target.value as WorkoutPlanLevel)}
                  className="w-full h-11 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors cursor-pointer"
                >
                  <option value="beginner">Mới bắt đầu (Beginner &lt; 6 tháng)</option>
                  <option value="intermediate">Trung bình (Intermediate 6 - 24 tháng)</option>
                  <option value="advanced">Nâng cao (Advanced &gt; 2 năm)</option>
                  <option value="all">Tất cả cấp độ (All Levels)</option>
                </select>
              </div>
            </div>

            {/* Schedule & Duration */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[13px] font-medium text-[#f5f5f6] mb-1.5">
                  Số buổi / tuần
                </label>
                <input
                  type="number"
                  min={1}
                  max={7}
                  value={daysPerWeek || ''}
                  onChange={(e) => {
                    const raw = e.target.value
                    if (raw === '') {
                      setDaysPerWeek(0)
                      return
                    }
                    const val = parseInt(raw, 10)
                    if (!isNaN(val)) {
                      handleDaysPerWeekChange(val)
                    }
                  }}
                  onBlur={() => {
                    if (!daysPerWeek || daysPerWeek < 1) {
                      handleDaysPerWeekChange(days.length)
                    }
                  }}
                  className="w-full h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors"
                />
              </div>

              <div>
                <label className="block text-[13px] font-medium text-[#f5f5f6] mb-1.5">
                  Thời lượng / buổi (Phút)
                </label>
                <input
                  type="number"
                  min={15}
                  max={180}
                  step={5}
                  value={estimatedDurationMin}
                  onChange={(e) => setEstimatedDurationMin(Number(e.target.value))}
                  className="w-full h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors"
                />
              </div>
            </div>

            {/* Author & Status */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[13px] font-medium text-[#f5f5f6] mb-1.5">
                  Tác giả / Huấn luyện viên
                </label>
                <input
                  type="text"
                  value={author}
                  onChange={(e) => setAuthor(e.target.value)}
                  placeholder="VieGym Master Coach"
                  className="w-full h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors"
                />
              </div>

              <div>
                <label className="block text-[13px] font-medium text-[#f5f5f6] mb-1.5">
                  Trạng thái phát hành
                </label>
                <select
                  value={status}
                  onChange={(e) => setStatus(e.target.value as WorkoutPlanStatus)}
                  className="w-full h-11 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[13px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a] transition-colors cursor-pointer"
                >
                  <option value="active">Hoạt động (Active - Học viên có thể áp dụng)</option>
                  <option value="draft">Bản nháp (Draft - Đang hiệu chỉnh)</option>
                  <option value="archived">Lưu trữ (Archived - Ngừng sử dụng)</option>
                </select>
              </div>
            </div>

          </div>
        )}

        {/* TAB 2: LỊCH TẬP & BÀI TẬP (BUILDER) */}
        {activeTab === 'builder' && (
          <div className="space-y-5 animate-fadeIn">
            {/* Days Horizontal Tab Picker */}
            <div className="flex items-center justify-between gap-2 pb-2 border-b border-[#292a2f]">
              <div className="flex items-center gap-1.5 overflow-x-auto py-1">
                {days.map((day, idx) => {
                  const isActive = activeDayIndex === idx
                  return (
                    <button
                      key={day.id}
                      type="button"
                      onClick={() => setActiveDayIndex(idx)}
                      className={`px-3.5 py-2 rounded-xl text-[12px] font-semibold shrink-0 transition-all flex items-center gap-1.5 cursor-pointer ${
                        isActive
                          ? 'bg-[#f2305a] text-white shadow-sm'
                          : 'bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f]'
                      }`}
                    >
                      <span>Buổi {day.dayNumber}</span>
                      <span
                        className={`text-[10px] px-1.5 py-0.2 rounded-full ${
                          isActive ? 'bg-white/20 text-white' : 'bg-[#17181b] text-[#8a8d93]'
                        }`}
                      >
                        {day.exercises?.length || 0} bài
                      </span>
                    </button>
                  )
                })}
              </div>

              <button
                type="button"
                onClick={handleAddDay}
                className="h-9 px-3 rounded-xl bg-[#222327] hover:bg-[#292a2f] border border-[#292a2f] text-[#ff506d] text-[12px] font-semibold shrink-0 flex items-center gap-1 transition-colors cursor-pointer"
              >
                <span className="material-symbols-outlined text-[16px]">add</span>
                <span>+ Thêm buổi</span>
              </button>
            </div>

            {/* Current Active Day Settings Card */}
            {currentDay && (
              <div className="bg-[#222327] border border-[#292a2f] rounded-2xl p-4 space-y-4">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                  <div className="flex-1">
                    <input
                      type="text"
                      value={currentDay.name}
                      onChange={(e) => handleUpdateDayName(e.target.value)}
                      placeholder="Tên buổi tập (VD: Buổi 1: Push Day - Ngực & Tay sau)"
                      className="w-full font-bold text-[15px] text-[#f5f5f6] bg-transparent border-b border-transparent hover:border-[#34363b] focus:border-[#f2305a] focus:outline-none pb-1 transition-colors"
                    />
                    <input
                      type="text"
                      value={currentDay.description || ''}
                      onChange={(e) => handleUpdateDayDesc(e.target.value)}
                      placeholder="Ghi chú trọng tâm buổi tập..."
                      className="w-full text-[12px] text-[#8a8d93] bg-transparent border-b border-transparent hover:border-[#34363b] focus:border-[#f2305a] focus:outline-none pb-0.5 mt-1 transition-colors"
                    />
                  </div>

                  <div className="flex items-center gap-2 shrink-0">
                    <button
                      type="button"
                      onClick={() => handleRemoveDay(activeDayIndex)}
                      className="p-1.5 rounded-lg text-[#8a8d93] hover:text-[#ff506d] hover:bg-[#17181b] transition-colors cursor-pointer"
                      title="Xóa buổi tập này"
                    >
                      <span className="material-symbols-outlined text-[18px]">delete</span>
                    </button>
                  </div>
                </div>

                {/* Exercises in Active Day */}
                <div className="space-y-3 pt-2">
                  <div className="flex items-center justify-between">
                    <div className="text-[13px] font-semibold text-[#f5f5f6] flex items-center gap-2">
                      <span className="material-symbols-outlined text-[#ff506d] text-[18px]">
                        format_list_bulleted
                      </span>
                      <span>Danh sách bài tập trong buổi ({currentDay.exercises?.length || 0})</span>
                    </div>

                    <button
                      type="button"
                      onClick={() => setIsExercisePickerOpen(true)}
                      className="h-9 px-3.5 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] text-white text-[12px] font-semibold flex items-center gap-1.5 transition-colors cursor-pointer shadow-sm"
                    >
                      <span className="material-symbols-outlined text-[16px]">add_circle</span>
                      <span>+ Thêm bài tập từ kho</span>
                    </button>
                  </div>

                  {currentDay.exercises?.length === 0 ? (
                    <div className="border-2 border-dashed border-[#292a2f] rounded-xl p-8 text-center space-y-2 bg-[#17181b]/50">
                      <span className="material-symbols-outlined text-[32px] text-[#8a8d93]">
                        fitness_center
                      </span>
                      <p className="text-[13px] text-[#f5f5f6] font-medium">
                        Chưa có bài tập nào trong buổi này
                      </p>
                      <p className="text-[11px] text-[#8a8d93]">
                        Bấm nút "+ Thêm bài tập từ kho" để chọn bài tập từ thư viện dữ liệu
                      </p>
                    </div>
                  ) : (
                    <div className="space-y-3">
                      {currentDay.exercises.map((ex, exIdx) => (
                        <div
                          key={ex.id}
                          className="bg-[#17181b] border border-[#292a2f] rounded-xl p-3.5 space-y-3"
                        >
                          {/* Top row: Exercise Identity & Actions */}
                          <div className="flex items-center justify-between gap-3">
                            <div className="flex items-center gap-2.5 min-w-0">
                              <span className="w-5 h-5 rounded-full bg-[#222327] text-[#a7a9ae] text-[10px] font-bold flex items-center justify-center shrink-0">
                                {exIdx + 1}
                              </span>

                              {/* Thumbnail */}
                              <div className="w-9 h-9 rounded-lg overflow-hidden border border-[#292a2f] bg-[#222327] shrink-0 flex items-center justify-center">
                                {ex.thumbnailUrl ? (
                                  <img
                                    src={ex.thumbnailUrl}
                                    alt={ex.nameVn}
                                    className="w-full h-full object-cover"
                                  />
                                ) : (
                                  <span className="material-symbols-outlined text-[#8a8d93] text-[16px]">
                                    fitness_center
                                  </span>
                                )}
                              </div>

                              <div className="min-w-0">
                                <div className="flex items-center gap-1.5">
                                  <span className="text-[13px] font-semibold text-[#f5f5f6] truncate">
                                    {ex.nameVn}
                                  </span>
                                  <span className="text-[10px] font-mono px-1 rounded bg-[#222327] text-[#8a8d93] border border-[#292a2f]">
                                    {ex.exerciseCode}
                                  </span>
                                </div>
                                <div className="text-[11px] text-[#8a8d93] truncate">
                                  {ex.nameEn} •{' '}
                                  <span className="text-[#ff506d]">
                                    {getMuscleLabel(ex.primaryMuscle) || ex.primaryMuscle}
                                  </span>
                                </div>
                              </div>
                            </div>

                            {/* Reorder and Delete */}
                            <div className="flex items-center gap-1 shrink-0">
                              <button
                                type="button"
                                disabled={exIdx === 0}
                                onClick={() => handleMoveExercise(exIdx, 'up')}
                                className="p-1 text-[#8a8d93] hover:text-[#f5f5f6] disabled:opacity-30 cursor-pointer"
                                title="Di chuyển lên"
                              >
                                <span className="material-symbols-outlined text-[16px]">
                                  arrow_upward
                                </span>
                              </button>
                              <button
                                type="button"
                                disabled={exIdx === currentDay.exercises.length - 1}
                                onClick={() => handleMoveExercise(exIdx, 'down')}
                                className="p-1 text-[#8a8d93] hover:text-[#f5f5f6] disabled:opacity-30 cursor-pointer"
                                title="Di chuyển xuống"
                              >
                                <span className="material-symbols-outlined text-[16px]">
                                  arrow_downward
                                </span>
                              </button>
                              <button
                                type="button"
                                onClick={() => handleRemoveExercise(exIdx)}
                                className="p-1 text-[#8a8d93] hover:text-[#ff506d] transition-colors cursor-pointer"
                                title="Xóa khỏi buổi tập"
                              >
                                <span className="material-symbols-outlined text-[16px]">close</span>
                              </button>
                            </div>
                          </div>

                          {/* Exercise Configuration Row (Sets, Reps, Rest, RPE) */}
                          <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5 pt-1">
                            <div>
                              <label className="block text-[11px] text-[#8a8d93] mb-1">
                                Số Sets (Hiệp)
                              </label>
                              <input
                                type="number"
                                min={1}
                                max={20}
                                value={ex.sets}
                                onChange={(e) =>
                                  handleUpdateExercise(exIdx, { sets: Number(e.target.value) })
                                }
                                className="w-full h-8 px-2.5 rounded-lg bg-[#222327] border border-[#292a2f] text-[12px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a]"
                              />
                            </div>

                            <div>
                              <label className="block text-[11px] text-[#8a8d93] mb-1">
                                Số Reps (Lần lặp)
                              </label>
                              <input
                                type="text"
                                value={ex.reps}
                                onChange={(e) =>
                                  handleUpdateExercise(exIdx, { reps: e.target.value })
                                }
                                placeholder="8 - 12 reps"
                                className="w-full h-8 px-2.5 rounded-lg bg-[#222327] border border-[#292a2f] text-[12px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a]"
                              />
                            </div>

                            <div>
                              <label className="block text-[11px] text-[#8a8d93] mb-1">
                                Nghỉ (Giây)
                              </label>
                              <input
                                type="number"
                                min={15}
                                max={300}
                                step={15}
                                value={ex.restSeconds}
                                onChange={(e) =>
                                  handleUpdateExercise(exIdx, {
                                    restSeconds: Number(e.target.value),
                                  })
                                }
                                className="w-full h-8 px-2.5 rounded-lg bg-[#222327] border border-[#292a2f] text-[12px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a]"
                              />
                            </div>

                            <div>
                              <label className="block text-[11px] text-[#8a8d93] mb-1">
                                RPE / Cường độ
                              </label>
                              <input
                                type="number"
                                min={1}
                                max={10}
                                value={ex.rpe || 8}
                                onChange={(e) =>
                                  handleUpdateExercise(exIdx, { rpe: Number(e.target.value) })
                                }
                                className="w-full h-8 px-2.5 rounded-lg bg-[#222327] border border-[#292a2f] text-[12px] text-[#f5f5f6] focus:outline-none focus:border-[#f2305a]"
                              />
                            </div>
                          </div>

                          {/* Exercise Form Notes */}
                          <div>
                            <input
                              type="text"
                              value={ex.notes || ''}
                              onChange={(e) =>
                                handleUpdateExercise(exIdx, { notes: e.target.value })
                              }
                              placeholder="Ghi chú kỹ thuật (VD: Nghỉ 2s ở điểm co cơ đỉnh, hạ tạ kiểm soát...)"
                              className="w-full h-8 px-2.5 rounded-lg bg-[#222327] border border-[#292a2f] text-[11px] text-[#f5f5f6] placeholder-[#8a8d93] focus:outline-none focus:border-[#f2305a]"
                            />
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            )}
          </div>
        )}

        {/* TAB 3: AI PHÂN TÍCH & KHỐI LƯỢNG */}
        {activeTab === 'insights' && (
          <div className="space-y-5 animate-fadeIn">
            {/* Quick Metrics */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f]">
                <div className="text-[12px] text-[#8a8d93]">Tổng bài tập thiết kế</div>
                <div className="text-[22px] font-bold text-[#f5f5f6] mt-1">
                  {totalExercisesCount} <span className="text-[12px] font-normal text-[#8a8d93]">bài</span>
                </div>
              </div>

              <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f]">
                <div className="text-[12px] text-[#8a8d93]">Tổng Volume (Sets/tuần)</div>
                <div className="text-[22px] font-bold text-[#35c76f] mt-1">
                  {totalWeeklySets} <span className="text-[12px] font-normal text-[#8a8d93]">sets</span>
                </div>
              </div>

              <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f]">
                <div className="text-[12px] text-[#8a8d93]">Tần suất kích hoạt</div>
                <div className="text-[22px] font-bold text-[#ff506d] mt-1">
                  {days.length} <span className="text-[12px] font-normal text-[#8a8d93]">buổi / tuần</span>
                </div>
              </div>
            </div>

            {/* Muscle Volume Breakdown */}
            <div className="bg-[#222327] border border-[#292a2f] rounded-xl p-4 space-y-4">
              <div className="flex items-center justify-between">
                <h3 className="text-[14px] font-bold text-[#f5f5f6]">
                  Phân bổ khối lượng theo nhóm cơ (Weekly Sets)
                </h3>
                <span className="text-[11px] text-[#8a8d93]">Chuẩn Hypertrophy: 10 - 20 sets/nhóm cơ</span>
              </div>

              <div className="space-y-3">
                {Object.entries(MUSCLE_MAP).map(([key, label]) => {
                  const sets = muscleSetsBreakdown[key] || 0
                  const percentage = totalWeeklySets > 0 ? Math.round((sets / totalWeeklySets) * 100) : 0

                  return (
                    <div key={key} className="space-y-1">
                      <div className="flex items-center justify-between text-[12px]">
                        <span className="text-[#f5f5f6] font-medium">{label}</span>
                        <span className="text-[#8a8d93]">
                          <strong className="text-[#ff506d]">{sets}</strong> sets ({percentage}%)
                        </span>
                      </div>
                      <div className="h-2 w-full bg-[#17181b] rounded-full overflow-hidden border border-[#292a2f]">
                        <div
                          className="h-full bg-gradient-to-r from-[#f2305a] to-[#ff7b92] transition-all duration-300"
                          style={{ width: `${Math.min(100, (sets / 20) * 100)}%` }}
                        />
                      </div>
                    </div>
                  )
                })}
              </div>
            </div>

            {/* AI Optimization Check */}
            <div className="bg-[#222327] border border-[#292a2f] rounded-xl p-4 space-y-3">
              <div className="flex items-center gap-2 text-[#9b7bff]">
                <span className="material-symbols-outlined text-[20px]">smart_toy</span>
                <h3 className="text-[14px] font-bold text-[#f5f5f6]">
                  Đánh giá tối ưu từ AI Coaching Engine
                </h3>
              </div>

              <div className="space-y-2 text-[12px]">
                <div className="p-3 rounded-lg bg-[#17181b] border border-[#292a2f] flex items-start gap-2.5">
                  <span className="material-symbols-outlined text-[#35c76f] text-[18px] shrink-0 mt-0.5">
                    check_circle
                  </span>
                  <div>
                    <span className="font-semibold text-[#f5f5f6]">
                      Cấu trúc phân bổ lịch tập:
                    </span>{' '}
                    <span className="text-[#a7a9ae]">
                      Số buổi {days.length} buổi/tuần phù hợp với cấp độ {level}. Đạt chuẩn phục hồi 48h giữa các nhóm cơ chính.
                    </span>
                  </div>
                </div>

                <div className="p-3 rounded-lg bg-[#17181b] border border-[#292a2f] flex items-start gap-2.5">
                  <span className="material-symbols-outlined text-[#35c76f] text-[18px] shrink-0 mt-0.5">
                    check_circle
                  </span>
                  <div>
                    <span className="font-semibold text-[#f5f5f6]">Thời gian nghỉ &amp; RPE:</span>{' '}
                    <span className="text-[#a7a9ae]">
                      Khoảng nghỉ trung bình từ 60-120s tối ưu hóa việc giải phóng ATP-CP và kích hoạt sợi cơ loại II.
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Drawer Sticky Footer */}
        {/* Modal Sticky Footer */}
        <div className="sticky -bottom-6 -mx-6 p-4 px-6 border-t border-[#292a2f] bg-[#1c1d21] flex flex-wrap items-center justify-between shrink-0 shadow-lg mt-8 gap-3">
          <div className="flex items-center gap-3">
            <span className="text-[12px] text-[#8a8d93]">
              {days.length} buổi tập • {totalExercisesCount} bài tập
            </span>

            {isEditMode && onDelete && (
              <button
                type="button"
                onClick={handleDeletePlan}
                className="h-10 px-3.5 rounded-xl border border-[#ff506d]/30 bg-[#ff506d]/10 hover:bg-[#ff506d]/20 text-[#ff506d] text-[13px] font-semibold flex items-center gap-1.5 transition-colors cursor-pointer"
                title="Xóa giáo án này"
              >
                <span className="material-symbols-outlined text-[18px]">delete</span>
                <span>Xóa giáo án</span>
              </button>
            )}
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
              type="submit"
              className="h-10 px-5 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white text-[13px] font-semibold transition-all shadow-sm cursor-pointer"
            >
              {isEditMode ? 'Lưu thay đổi giáo án' : 'Tạo mới giáo án'}
            </button>
          </div>
        </div>
      </form>

      {/* Exercise Picker Modal */}
      <ExerciseSelectModal
        isOpen={isExercisePickerOpen}
        onClose={() => setIsExercisePickerOpen(false)}
        alreadySelectedExerciseIds={currentDay?.exercises?.map((e) => e.exerciseId) || []}
        onSelectExercises={handleAddExercisesToCurrentDay}
      />
    </div>
  )
}

export const WorkoutPlanDrawer: React.FC<WorkoutPlanDrawerProps> = ({
  isOpen,
  plan,
  onClose,
  onSave,
  onDelete,
}) => {
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose()
      }
    }
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [isOpen, onClose])

  if (!isOpen) return null

  return (
    <div
      role="dialog"
      aria-modal="true"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-fadeIn"
      onClick={onClose}
    >
      <DrawerFormContent
        key={plan ? plan.id : 'new-plan'}
        plan={plan}
        onClose={onClose}
        onSave={onSave}
        onDelete={onDelete}
      />
    </div>
  )
}
