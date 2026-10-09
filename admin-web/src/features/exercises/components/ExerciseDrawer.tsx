import React, { useEffect, useState } from 'react'
import type { ExerciseItem, ExerciseLevel, ExerciseStatus, ExerciseStep } from '../types'
import { MediaUploader } from '../../media/MediaUploader'
import { getEquipmentLabel, getMuscleLabel, MUSCLE_GROUPS, EQUIPMENTS } from '../catalogConstants'

interface ExerciseDrawerProps {
  isOpen: boolean
  exercise: ExerciseItem | null
  onClose: () => void
  onSave: (exercise: ExerciseItem) => void
  onDelete?: (id: string) => void
}

interface DrawerFormContentProps {
  exercise: ExerciseItem | null
  onClose: () => void
  onSave: (exercise: ExerciseItem) => void
  onDelete?: (id: string) => void
}

const DrawerFormContent: React.FC<DrawerFormContentProps> = ({
  exercise,
  onClose,
  onSave,
  onDelete,
}) => {
  const [activeTab, setActiveTab] = useState<'info' | 'instructions' | 'media'>('info')

  const [nameVn, setNameVn] = useState(exercise?.nameVn || '')
  const [nameEn, setNameEn] = useState(exercise?.nameEn || '')
  const [primaryMuscle, setPrimaryMuscle] = useState(exercise?.primaryMuscle || 'chest')
  const [secondaryMuscles, setSecondaryMuscles] = useState<string[]>(
    exercise?.secondaryMuscles || ['Tay sau (Triceps)']
  )
  const [equipment, setEquipment] = useState<string[]>(
    exercise?.equipment || ['Thanh đòn Olympic (Barbell)']
  )
  const [level, setLevel] = useState<ExerciseLevel>(exercise?.level || 'intermediate')
  const [status, setStatus] = useState<ExerciseStatus>(exercise?.status || 'active')
  const [description, setDescription] = useState(exercise?.description || '')
  const [steps, setSteps] = useState<ExerciseStep[]>(
    exercise?.steps || [
      {
        id: 'new-1',
        stepNumber: 1,
        title: 'Bước 1: Chuẩn bị tư thế',
        description: 'Cố định vị trí thân người, giữ cột sống trung tính.',
      },
    ]
  )

  const handleAddSecondaryMuscle = (muscleId: string) => {
    if (muscleId && !secondaryMuscles.some((m) => String(m) === String(muscleId))) {
      setSecondaryMuscles([...secondaryMuscles, muscleId])
    }
  }

  const handleRemoveSecondaryMuscle = (muscleToRemove: string) => {
    setSecondaryMuscles(secondaryMuscles.filter((m) => m !== muscleToRemove))
  }

  const handleRemoveEquipment = (eqToRemove: string) => {
    setEquipment(equipment.filter((e) => e !== eqToRemove))
  }

  const handleAddEquipment = (eqId: string) => {
    if (eqId && !equipment.some((e) => String(e) === String(eqId))) {
      setEquipment([...equipment, eqId])
    }
  }

  const availableSecondaryMuscles = MUSCLE_GROUPS.filter(
    (mg) =>
      String(mg.id) !== primaryMuscle &&
      !secondaryMuscles.some(
        (m) => String(m) === String(mg.id) || m.toLowerCase() === mg.code.toLowerCase()
      )
  )

  const availableEquipments = EQUIPMENTS.filter(
    (eq) =>
      !equipment.some(
        (e) => String(e) === String(eq.id) || e.toLowerCase() === eq.code.toLowerCase()
      )
  )

  const handleDeleteExercise = () => {
    if (!exercise) return
    if (
      window.confirm(
        `Bạn có chắc chắn muốn xóa bài tập "${exercise.nameVn}"? Thao tác này không thể hoàn tác.`
      )
    ) {
      onDelete?.(exercise.id)
      onClose()
    }
  }

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault()
    if (!nameVn.trim()) {
      alert('Vui lòng nhập Tên tiếng Việt cho bài tập.')
      return
    }

    const updatedItem: ExerciseItem = {
      ...exercise,
      id: exercise ? exercise.id : String(Date.now()),
      code: exercise ? exercise.code : `EX-0${Math.floor(100 + Math.random() * 900)}`,
      nameVn: nameVn.trim(),
      nameEn: nameEn.trim() || nameVn.trim(),
      primaryMuscle,
      secondaryMuscles,
      equipment,
      level,
      status,
      updatedAt: 'Hôm nay',
      thumbnailUrl: exercise?.thumbnailUrl || '',
      description,
      steps,
      media: exercise?.media || [],
    }

    onSave(updatedItem)
    onClose()
  }

  const isEditMode = !!exercise

  return (
    <div
      className="w-full max-w-2xl max-h-[90vh] bg-[#17181b] border border-[#292a2f] rounded-2xl flex flex-col shadow-2xl overflow-hidden animate-in zoom-in-95 duration-150"
      onClick={(e) => e.stopPropagation()}
    >
      {/* Drawer Header */}
      <div className="h-16 px-6 border-b border-[#292a2f] bg-[#1c1d21] flex items-center justify-between shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-lg bg-[rgba(242,48,90,0.12)] border border-[#f2305a]/20 flex items-center justify-center text-[#ff506d]">
            <span className="material-symbols-outlined text-[18px]">edit_note</span>
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h2 className="text-[16px] font-bold text-[#f5f5f6]">
                {isEditMode ? 'Chỉnh sửa bài tập' : 'Thêm bài tập mới'}
              </h2>
              {isEditMode && (
                <span className="px-2 py-0.5 rounded text-[11px] font-mono font-medium bg-[#222327] text-[#a7a9ae] border border-[#292a2f]">
                  ID #{exercise.code}
                </span>
              )}
            </div>
            <p className="text-[12px] text-[#8a8d93]">
              {nameEn || 'Kho bài tập AI · VieGym Ops'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <span className="text-[11px] text-[#8a8d93] font-mono hidden sm:inline-block px-1.5 py-0.5 rounded bg-[#222327] border border-[#292a2f]">
            ESC
          </span>
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-lg hover:bg-[#222327] flex items-center justify-center text-[#a7a9ae] hover:text-[#f5f5f6] transition-colors"
          >
            <span className="material-symbols-outlined text-[20px]">close</span>
          </button>
        </div>
      </div>

      {/* Drawer Navigation Tabs */}
      <div className="px-6 border-b border-[#292a2f] bg-[#17181b] shrink-0 flex items-center gap-6">
        <button
          type="button"
          onClick={() => setActiveTab('info')}
          className={`py-3 text-[14px] flex items-center gap-2 border-b-2 transition-colors ${
            activeTab === 'info'
              ? 'font-semibold text-[#f2305a] border-[#f2305a]'
              : 'text-[#a7a9ae] hover:text-[#f5f5f6] border-transparent'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">info</span>
          <span>Thông tin cơ bản</span>
        </button>
        <button
          type="button"
          onClick={() => setActiveTab('instructions')}
          className={`py-3 text-[14px] flex items-center gap-2 border-b-2 transition-colors ${
            activeTab === 'instructions'
              ? 'font-semibold text-[#f2305a] border-[#f2305a]'
              : 'text-[#a7a9ae] hover:text-[#f5f5f6] border-transparent'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">shield</span>
          <span>Hướng dẫn &amp; an toàn</span>
        </button>
        <button
          type="button"
          onClick={() => setActiveTab('media')}
          className={`py-3 text-[14px] flex items-center gap-2 border-b-2 transition-colors ${
            activeTab === 'media'
              ? 'font-semibold text-[#f2305a] border-[#f2305a]'
              : 'text-[#a7a9ae] hover:text-[#f5f5f6] border-transparent'
          }`}
        >
          <span className="material-symbols-outlined text-[18px]">perm_media</span>
          <span>Media</span>
          <span className="text-[10px] px-1.5 py-0.5 rounded-full bg-[#222327] text-[#8a8d93]">
            {exercise?.media.length || 0}/6
          </span>
        </button>
      </div>

      {/* Drawer Scrollable Body */}
      <form id="exercise-form" onSubmit={handleSave} className="flex-1 overflow-y-auto p-6 space-y-6">
        {/* TAB 1: THÔNG TIN CƠ BẢN */}
        {activeTab === 'info' && (
          <div className="space-y-4">
            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Tên tiếng Việt <span className="text-[#f2305a]">*</span>
              </label>
              <input
                type="text"
                required
                value={nameVn}
                onChange={(e) => setNameVn(e.target.value)}
                placeholder="Ví dụ: Đẩy ngực tạ đòn"
                className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] focus:outline-none focus:border-[#f2305a]"
              />
            </div>

            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Tên tiếng Anh (Chuẩn danh pháp Quốc tế) <span className="text-[#f2305a]">*</span>
              </label>
              <input
                type="text"
                required
                value={nameEn}
                onChange={(e) => setNameEn(e.target.value)}
                placeholder="Ví dụ: Barbell Bench Press"
                className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] focus:outline-none focus:border-[#f2305a]"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                  Nhóm cơ chính <span className="text-[#f2305a]">*</span>
                </label>
                <div className="relative">
                  <select
                    value={primaryMuscle}
                    onChange={(e) => setPrimaryMuscle(e.target.value)}
                    className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a]"
                  >
                    {MUSCLE_GROUPS.map((mg) => (
                      <option key={mg.id} value={String(mg.id)}>
                        {mg.name} ({mg.code})
                      </option>
                    ))}
                  </select>
                  <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-[18px]">
                    expand_more
                  </span>
                </div>
              </div>

              <div>
                <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                  Cấp độ yêu cầu <span className="text-[#f2305a]">*</span>
                </label>
                <div className="relative">
                  <select
                    value={level}
                    onChange={(e) => setLevel(e.target.value as ExerciseLevel)}
                    className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a]"
                  >
                    <option value="beginner">Mới bắt đầu (Beginner)</option>
                    <option value="intermediate">Trung bình (Intermediate)</option>
                    <option value="advanced">Nâng cao (Advanced)</option>
                  </select>
                  <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-[18px]">
                    expand_more
                  </span>
                </div>
              </div>
            </div>

            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Nhóm cơ phụ tác động (Secondary Muscles)
              </label>
              <div className="p-2.5 bg-[#222327] border border-[#292a2f] rounded-xl flex flex-wrap gap-2 items-center">
                {secondaryMuscles.map((muscle) => (
                  <span
                    key={muscle}
                    className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-[#292a2c] text-[13px] text-[#f5f5f6] border border-[#34363b]"
                  >
                    {getMuscleLabel(muscle)}
                    <button
                      type="button"
                      onClick={() => handleRemoveSecondaryMuscle(muscle)}
                      className="material-symbols-outlined text-[14px] text-[#8a8d93] hover:text-[#f2305a] transition-colors cursor-pointer"
                      title="Xóa nhóm cơ"
                    >
                      close
                    </button>
                  </span>
                ))}
                {availableSecondaryMuscles.length > 0 && (
                  <div className="relative inline-flex items-center">
                    <select
                      value=""
                      onChange={(e) => {
                        if (e.target.value) {
                          handleAddSecondaryMuscle(e.target.value)
                        }
                      }}
                      className="h-8 pl-2.5 pr-7 bg-[#17181b] hover:bg-[#1f2024] border border-[#292a2f] hover:border-[#f2305a]/50 rounded-lg text-[13px] text-[#ffb2b8] focus:outline-none focus:border-[#f2305a] cursor-pointer appearance-none transition-colors"
                    >
                      <option value="" disabled>
                        + Chọn nhóm cơ phụ...
                      </option>
                      {availableSecondaryMuscles.map((mg) => (
                        <option key={mg.id} value={String(mg.id)} className="bg-[#222327] text-[#f5f5f6]">
                          {mg.name} ({mg.code})
                        </option>
                      ))}
                    </select>
                    <span className="material-symbols-outlined absolute right-1.5 text-[16px] text-[#8a8d93] pointer-events-none">
                      add
                    </span>
                  </div>
                )}
              </div>
            </div>

            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Thiết bị tập luyện bắt buộc <span className="text-[#f2305a]">*</span>
              </label>
              <div className="p-2.5 bg-[#222327] border border-[#292a2f] rounded-xl flex flex-wrap gap-2 items-center">
                {equipment.map((eq) => (
                  <span
                    key={eq}
                    className="inline-flex items-center gap-1.5 px-3 py-1 rounded-lg bg-[#17181b] text-[13px] text-[#f5f5f6] border border-[#292a2f]"
                  >
                    <span className="material-symbols-outlined text-[16px] text-[#f2305a]">
                      check_circle
                    </span>
                    {getEquipmentLabel(eq)}
                    <button
                      type="button"
                      onClick={() => handleRemoveEquipment(eq)}
                      className="material-symbols-outlined text-[14px] text-[#8a8d93] hover:text-[#f2305a] transition-colors cursor-pointer"
                      title="Xóa thiết bị"
                    >
                      close
                    </button>
                  </span>
                ))}
                {availableEquipments.length > 0 && (
                  <div className="relative inline-flex items-center">
                    <select
                      value=""
                      onChange={(e) => {
                        if (e.target.value) {
                          handleAddEquipment(e.target.value)
                        }
                      }}
                      className="h-8 pl-2.5 pr-7 bg-[#17181b] hover:bg-[#1f2024] border border-[#292a2f] hover:border-[#f2305a]/50 rounded-lg text-[13px] text-[#ffb2b8] focus:outline-none focus:border-[#f2305a] cursor-pointer appearance-none transition-colors"
                    >
                      <option value="" disabled>
                        + Thêm thiết bị...
                      </option>
                      {availableEquipments.map((eq) => (
                        <option key={eq.id} value={String(eq.id)} className="bg-[#222327] text-[#f5f5f6]">
                          {eq.name} ({eq.code})
                        </option>
                      ))}
                    </select>
                    <span className="material-symbols-outlined absolute right-1.5 text-[16px] text-[#8a8d93] pointer-events-none">
                      add
                    </span>
                  </div>
                )}
              </div>
            </div>

            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Mô tả &amp; Mục tiêu bài tập
              </label>
              <textarea
                rows={3}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="Nhập mô tả bài tập..."
                className="w-full p-3 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] focus:outline-none focus:border-[#f2305a] resize-none"
              />
              <span className="text-[12px] text-[#8a8d93] block mt-1">
                Được chuẩn hóa cho AI Recommendation Pipeline tự động gán khối lượng.
              </span>
            </div>
          </div>
        )}

        {/* TAB 2: HƯỚNG DẪN & AN TOÀN */}
        {activeTab === 'instructions' && (
          <div className="space-y-4">
            <div className="border border-[#292a2f] rounded-xl p-4 bg-[#1c1d21] space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-[12px] font-semibold text-[#f5f5f6] flex items-center gap-2">
                  <span className="material-symbols-outlined text-[#f2305a] text-[18px]">
                    format_list_numbered
                  </span>
                  Các bước thực hiện chuẩn ({steps.length} bước)
                </span>
                <button
                  type="button"
                  onClick={() => {
                    const title = prompt('Tiêu đề bước mới:')
                    const desc = prompt('Mô tả chi tiết bước:')
                    if (title) {
                      setSteps([
                        ...steps,
                        {
                          id: `step-${Date.now()}`,
                          stepNumber: steps.length + 1,
                          title,
                          description: desc || '',
                        },
                      ])
                    }
                  }}
                  className="text-[12px] text-[#f2305a] cursor-pointer hover:underline font-semibold"
                >
                  + Thêm bước mới
                </button>
              </div>

              <div className="space-y-2">
                {steps.map((st, index) => (
                  <div
                    key={st.id}
                    className="p-2.5 rounded-lg bg-[#17181b] border border-[#292a2f] flex items-start gap-3"
                  >
                    <span className="material-symbols-outlined text-[#8a8d93] text-[18px] mt-0.5 cursor-grab">
                      drag_indicator
                    </span>
                    <div className="flex-1 text-[13px]">
                      <span className="font-semibold text-[#f5f5f6]">
                        Bước {index + 1}: {st.title}
                      </span>
                      <p className="text-[#a7a9ae] mt-0.5">{st.description}</p>
                    </div>
                    <button
                      type="button"
                      onClick={() => setSteps(steps.filter((s) => s.id !== st.id))}
                      className="text-[#8a8d93] hover:text-[#ff5a5f] p-1"
                    >
                      <span className="material-symbols-outlined text-[16px]">delete</span>
                    </button>
                  </div>
                ))}
              </div>
            </div>

            <div className="border border-[#292a2f] rounded-xl p-4 bg-[#1c1d21] space-y-2">
              <span className="text-[12px] font-semibold text-[#f4b740] flex items-center gap-1.5">
                <span className="material-symbols-outlined text-[16px]">warning</span>
                Lưu ý an toàn &amp; Lỗi sai thường gặp
              </span>
              <p className="text-[12px] text-[#a7a9ae] leading-relaxed">
                Tránh nhấc mông khỏi ghế khi đẩy ngực nặng. Đảm bảo có người hỗ trợ (Spotter) hoặc cài
                thanh bảo hiểm khi thực hiện set tập gần ngưỡng thất bại (RPE ≥ 9).
              </p>
            </div>
          </div>
        )}

        {/* TAB 3: MEDIA & VIDEO */}
        {activeTab === 'media' && (
          <div className="space-y-4">
            <MediaUploader ownerType="EXERCISE" ownerId={exercise?.id} />
            <div className="border border-[#292a2f] rounded-xl p-4 bg-[#1c1d21] space-y-3">
              <div className="flex items-center justify-between">
                <span className="text-[12px] font-semibold text-[#f5f5f6] flex items-center gap-2">
                  <span className="material-symbols-outlined text-[#4d8dff] text-[18px]">
                    perm_media
                  </span>
                  Media &amp; Video kỹ thuật (Cloudflare Stream)
                </span>
                <span className="text-[11px] text-[#35c76f] flex items-center gap-1 font-medium">
                  <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" /> Đã đồng bộ CDN
                </span>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="relative group rounded-lg overflow-hidden border border-[#292a2f] bg-[#17181b]">
                  <img
                    src={
                      exercise?.thumbnailUrl ||
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBRnHSgBh8HsSxXUPg0ziT2KxeGEEsb0T2Jx9J2UZrXksgKXDxI9BSYOjAh6gOSVu7yCUTGU3yYS9qTM9n4hFeoJxtWyx1BTI2mYXIwW3KGJ2XWZbEliyLZyIMEvVPCNCGCgTxPS25WnOaR-aRQT9jSJia_sV7edKR34bDb0IRyxjU-uVbn2XmBjHINV1PCCPq84m8jzs6OUaJBWVL4bAqnPiPwuAH4XRQNsgokPVx3MQzJZLtwklKt'
                    }
                    alt="Thumbnail cover"
                    className="w-full h-24 object-cover"
                  />
                  <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                    <button
                      type="button"
                      className="w-7 h-7 rounded bg-[#17181b] text-[#f5f5f6] flex items-center justify-center"
                    >
                      <span className="material-symbols-outlined text-[16px]">visibility</span>
                    </button>
                  </div>
                  <span className="absolute bottom-1.5 left-1.5 px-1.5 py-0.5 rounded bg-[#0f1012]/80 text-[10px] text-[#a7a9ae] font-mono">
                    Cover 1:1
                  </span>
                </div>

                <div className="relative group rounded-lg overflow-hidden border border-[#292a2f] bg-[#17181b] flex flex-col items-center justify-center p-3 text-center">
                  <div className="w-8 h-8 rounded-full bg-[#4d8dff]/20 text-[#4d8dff] flex items-center justify-center mb-1">
                    <span className="material-symbols-outlined text-[18px]">play_arrow</span>
                  </div>
                  <span className="text-[12px] font-medium text-[#f5f5f6] truncate max-w-full">
                    bench_press_1080p.mp4
                  </span>
                  <span className="text-[10px] text-[#8a8d93]">48.2 MB · 60fps</span>
                </div>
              </div>
            </div>
          </div>
        )}
      </form>

      {/* Drawer Sticky Action Footer */}
      <div className="p-4 px-6 border-t border-[#292a2f] bg-[#1c1d21] flex flex-wrap items-center justify-between shrink-0 shadow-lg gap-3">
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setStatus(status === 'active' ? 'hidden' : 'active')}
            className={`h-10 px-3 rounded-xl border text-[13px] font-medium flex items-center gap-1.5 transition-colors cursor-pointer ${
              status === 'active'
                ? 'text-[#ff5a5f] hover:bg-[#ff5a5f]/10 border-[#ff5a5f]/20'
                : 'text-[#35c76f] hover:bg-[#35c76f]/10 border-[#35c76f]/20'
            }`}
          >
            <span className="material-symbols-outlined text-[18px]">
              {status === 'active' ? 'visibility_off' : 'visibility'}
            </span>
            <span>{status === 'active' ? 'Ẩn bài tập' : 'Hiện bài tập'}</span>
          </button>

          {isEditMode && onDelete && (
            <button
              type="button"
              onClick={handleDeleteExercise}
              className="h-10 px-3.5 rounded-xl border border-[#ff506d]/30 bg-[#ff506d]/10 hover:bg-[#ff506d]/20 text-[#ff506d] text-[13px] font-semibold flex items-center gap-1.5 transition-colors cursor-pointer"
              title="Xóa bài tập này"
            >
              <span className="material-symbols-outlined text-[18px]">delete</span>
              <span>Xóa bài tập</span>
            </button>
          )}
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={onClose}
            className="h-10 px-4 rounded-xl bg-[#222327] hover:bg-[#292a2c] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f] text-[13px] font-semibold transition-colors cursor-pointer"
          >
            Hủy
          </button>
          <button
            type="submit"
            form="exercise-form"
            className="h-10 px-5 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white text-[13px] font-semibold flex items-center gap-2 shadow-sm transition-transform active:scale-[0.98] cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]">save</span>
            <span>Lưu thay đổi</span>
          </button>
        </div>
      </div>
    </div>
  )
}

export const ExerciseDrawer: React.FC<ExerciseDrawerProps> = ({
  isOpen,
  exercise,
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
        key={exercise ? exercise.id : 'new-exercise'}
        exercise={exercise}
        onClose={onClose}
        onSave={onSave}
        onDelete={onDelete}
      />
    </div>
  )
}
