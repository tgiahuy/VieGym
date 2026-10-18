import React, { useState } from 'react'
import type { EquipmentCategory, EquipmentItem, EquipmentStatus } from '../types'

interface EquipmentModalProps {
  isOpen: boolean
  equipment: EquipmentItem | null
  onClose: () => void
  onSave: (equipment: EquipmentItem) => void
  onDelete?: (id: number) => void
}

const CATEGORY_OPTIONS: { value: EquipmentCategory; label: string }[] = [
  { value: 'free_weights', label: 'Tạ tự do (Free Weights)' },
  { value: 'machines', label: 'Máy khối & Cáp lực' },
  { value: 'bodyweight', label: 'Thể trọng & Calisthenics' },
  { value: 'accessories', label: 'Ghế & Dụng cụ bổ trợ' },
  { value: 'cardio', label: 'Thiết bị Cardio' },
]

const ICON_PRESETS = [
  { name: 'fitness_center', label: 'Tạ đơn' },
  { name: 'sports_gymnastics', label: 'Tạ đòn' },
  { name: 'accessibility_new', label: 'Bodyweight' },
  { name: 'cable', label: 'Cáp lực' },
  { name: 'precision_manufacturing', label: 'Máy tập' },
  { name: 'event_seat', label: 'Ghế tập' },
  { name: 'airline_seat_recline_extra', label: 'Ghế dốc' },
  { name: 'straighten', label: 'Xà đơn' },
  { name: 'gesture', label: 'Dây chun' },
  { name: 'sports_volleyball', label: 'Tạ ấm' },
  { name: 'directions_run', label: 'Chạy bộ' },
]

export const EquipmentModal: React.FC<EquipmentModalProps> = ({
  isOpen,
  equipment,
  onClose,
  onSave,
  onDelete,
}) => {
  if (!isOpen) return null

  return (
    <EquipmentModalForm
      key={equipment?.id ?? 'create'}
      equipment={equipment}
      onClose={onClose}
      onSave={onSave}
      onDelete={onDelete}
    />
  )
}

const EquipmentModalForm: React.FC<Omit<EquipmentModalProps, 'isOpen'>> = ({
  equipment,
  onClose,
  onSave,
  onDelete,
}) => {
  const isEditing = Boolean(equipment)

  const [name, setName] = useState(equipment?.name ?? '')
  const [nameEn, setNameEn] = useState(equipment?.nameEn ?? '')
  const [code, setCode] = useState(equipment?.code ?? '')
  const [category, setCategory] = useState<EquipmentCategory>(equipment?.category ?? 'free_weights')
  const [iconName, setIconName] = useState(equipment?.iconName ?? 'fitness_center')
  const [status, setStatus] = useState<EquipmentStatus>(equipment?.status ?? 'active')
  const [description, setDescription] = useState(equipment?.description ?? '')
  const [suitableFor, setSuitableFor] = useState(equipment?.suitableFor ?? '')
  const [safetyNotes, setSafetyNotes] = useState(equipment?.safetyNotes ?? '')
  const [isCommon, setIsCommon] = useState(equipment?.isCommon ?? true)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!name.trim()) {
      alert('Vui lòng nhập Tên thiết bị.')
      return
    }

    const generatedCode =
      code.trim().toUpperCase() ||
      name
        .trim()
        .toUpperCase()
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .replace(/[^A-Z0-9]+/g, '_')
        .replace(/^_+|_+$/g, '')

    const categoryObj = CATEGORY_OPTIONS.find((c) => c.value === category)

    const updatedItem: EquipmentItem = {
      id: equipment ? equipment.id : Date.now(),
      code: generatedCode,
      name: name.trim(),
      nameEn: nameEn.trim() || name.trim(),
      category,
      categoryLabel: categoryObj?.label || 'Dụng cụ tập luyện',
      description: description.trim() || 'Thiết bị phục vụ luyện tập thể hình và thể lực.',
      iconName,
      status,
      suitableFor: suitableFor.trim() || 'Các bài tập thể hình và rèn luyện thể chất',
      safetyNotes: safetyNotes.trim() || 'Tuân thủ đúng kỹ thuật và kiểm tra an toàn trước khi tập.',
      exerciseCount: equipment ? equipment.exerciseCount : 0,
      isCommon,
      updatedAt: new Date().toLocaleDateString('vi-VN'),
    }

    onSave(updatedItem)
    onClose()
  }

  const handleDelete = () => {
    if (!equipment) return
    if (
      window.confirm(
        `Bạn có chắc chắn muốn xóa thiết bị "${equipment.name}" (${equipment.code})? Hành động này không thể hoàn tác.`
      )
    ) {
      onDelete?.(equipment.id)
      onClose()
    }
  }

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-sm animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        className="w-full max-w-2xl bg-[#17181b] border border-[#292a2f] rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh] animate-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Header */}
        <div className="h-16 px-6 border-b border-[#292a2f] flex items-center justify-between bg-[#17181b] shrink-0">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-[rgba(242,48,90,0.12)] border border-[#f2305a]/30 flex items-center justify-center text-[#ff506d] shadow-inner">
              <span className="material-symbols-outlined text-[22px]">{iconName}</span>
            </div>
            <div>
              <h2 className="text-[16px] font-bold text-[#f5f5f6] tracking-tight">
                {isEditing ? 'Chi tiết & Chỉnh sửa thiết bị' : 'Thêm thiết bị tập luyện mới'}
              </h2>
              <span className="text-[12px] text-[#8a8d93]">
                {equipment ? `Mã định danh: ${equipment.code}` : 'Chuẩn hóa thiết bị vào hệ thống'}
              </span>
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

        {/* Modal Body Form */}
        <form id="equipment-form" onSubmit={handleSubmit} className="flex-1 overflow-y-auto p-6 space-y-5">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {/* Tên thiết bị (VN) */}
            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Tên thiết bị (Tiếng Việt) <span className="text-[#f2305a]">*</span>
              </label>
              <input
                type="text"
                required
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Ví dụ: Tạ đơn, Ghế dốc..."
                className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] focus:outline-none focus:border-[#f2305a]"
              />
            </div>

            {/* Tên tiếng Anh */}
            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Tên tiếng Anh (International)
              </label>
              <input
                type="text"
                value={nameEn}
                onChange={(e) => setNameEn(e.target.value)}
                placeholder="Ví dụ: Dumbbell, Incline Bench..."
                className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] focus:outline-none focus:border-[#f2305a]"
              />
            </div>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {/* Mã CODE */}
            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Mã CODE hệ thống
              </label>
              <input
                type="text"
                value={code}
                onChange={(e) => setCode(e.target.value.toUpperCase())}
                placeholder="Ví dụ: DUMBBELL"
                className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] font-mono focus:outline-none focus:border-[#f2305a]"
              />
            </div>

            {/* Phân loại */}
            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Phân loại thiết bị <span className="text-[#f2305a]">*</span>
              </label>
              <div className="relative">
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value as EquipmentCategory)}
                  className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a] cursor-pointer"
                >
                  {CATEGORY_OPTIONS.map((c) => (
                    <option key={c.value} value={c.value}>
                      {c.label}
                    </option>
                  ))}
                </select>
                <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-[18px]">
                  expand_more
                </span>
              </div>
            </div>

            {/* Trạng thái */}
            <div>
              <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
                Trạng thái hoạt động
              </label>
              <div className="relative">
                <select
                  value={status}
                  onChange={(e) => setStatus(e.target.value as EquipmentStatus)}
                  className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] appearance-none focus:outline-none focus:border-[#f2305a] cursor-pointer"
                >
                  <option value="active">Active (Áp dụng)</option>
                  <option value="inactive">Hidden (Tạm ẩn)</option>
                </select>
                <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-[18px]">
                  expand_more
                </span>
              </div>
            </div>
          </div>

          {/* Icon Presets Selector */}
          <div>
            <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
              Biểu tượng hiển thị (Material Icon)
            </label>
            <div className="p-2.5 bg-[#222327] border border-[#292a2f] rounded-xl flex flex-wrap gap-2 items-center">
              {ICON_PRESETS.map((ic) => {
                const isActive = iconName === ic.name
                return (
                  <button
                    key={ic.name}
                    type="button"
                    onClick={() => setIconName(ic.name)}
                    className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[12px] font-medium border transition-colors cursor-pointer ${
                      isActive
                        ? 'bg-[rgba(242,48,90,0.2)] border-[#ff506d] text-[#ff506d] font-bold shadow-sm'
                        : 'bg-[#17181b] border-[#292a2f] text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#1c1d21]'
                    }`}
                  >
                    <span className="material-symbols-outlined text-[16px]">{ic.name}</span>
                    <span>{ic.label}</span>
                  </button>
                )
              })}
            </div>
          </div>

          {/* Mô tả chi tiết */}
          <div>
            <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
              Mô tả chi tiết thiết bị &amp; Chức năng
            </label>
            <textarea
              rows={3}
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Mô tả cấu tạo, cơ chế hoạt động hoặc ứng dụng..."
              className="w-full p-3 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] focus:outline-none focus:border-[#f2305a] resize-none"
            />
          </div>

          {/* Phù hợp cho */}
          <div>
            <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
              Mục tiêu &amp; Phù hợp bài tập
            </label>
            <input
              type="text"
              value={suitableFor}
              onChange={(e) => setSuitableFor(e.target.value)}
              placeholder="Ví dụ: Tăng cơ cô lập, xây dựng sức mạnh compound, tập luyện tại nhà..."
              className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] focus:outline-none focus:border-[#f2305a]"
            />
          </div>

          {/* Lưu ý an toàn kỹ thuật */}
          <div>
            <label className="block text-[12px] font-semibold text-[#a7a9ae] mb-1.5">
              Lưu ý an toàn kỹ thuật khi sử dụng
            </label>
            <input
              type="text"
              value={safetyNotes}
              onChange={(e) => setSafetyNotes(e.target.value)}
              placeholder="Ví dụ: Luôn sử dụng kẹp khóa tạ, kiểm tra chốt an toàn trước khi tập..."
              className="w-full h-11 px-3.5 bg-[#222327] border border-[#292a2f] rounded-xl text-[#f5f5f6] text-[14px] focus:outline-none focus:border-[#f2305a]"
            />
          </div>

          {/* Thiết bị phổ biến */}
          <div className="flex items-center gap-2 pt-1">
            <input
              type="checkbox"
              id="equipment-is-common"
              checked={isCommon}
              onChange={(e) => setIsCommon(e.target.checked)}
              className="w-4 h-4 rounded text-[#f2305a] accent-[#f2305a] bg-[#222327] border-[#292a2f]"
            />
            <label htmlFor="equipment-is-common" className="text-[13px] font-medium text-[#f5f5f6] cursor-pointer">
              Thiết bị phổ biến (Ưu tiên trong gợi ý bài tập &amp; AI)
            </label>
          </div>
        </form>

        {/* Modal Footer */}
        <div className="h-16 px-6 border-t border-[#292a2f] bg-[#17181b] flex items-center justify-between shrink-0">
          <div>
            {isEditing && onDelete && (
              <button
                type="button"
                onClick={handleDelete}
                className="h-10 px-4 rounded-xl bg-[#f2305a]/10 hover:bg-[#f2305a]/20 border border-[#f2305a]/30 text-[#ff506d] text-[13px] font-medium flex items-center gap-1.5 transition-colors cursor-pointer"
              >
                <span className="material-symbols-outlined text-[16px]">delete</span>
                <span>Xóa thiết bị</span>
              </button>
            )}
          </div>

          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={onClose}
              className="h-10 px-5 bg-[#222327] hover:bg-[#2c2d33] border border-[#292a2f] text-[#f5f5f6] text-[13px] font-medium rounded-xl transition-colors cursor-pointer"
            >
              Hủy
            </button>
            <button
              type="submit"
              form="equipment-form"
              className="h-10 px-5 bg-gradient-to-r from-[#f2305a] to-[#ff506d] hover:brightness-110 text-white text-[13px] font-semibold rounded-xl shadow-md shadow-[#f2305a]/20 flex items-center gap-1.5 transition-all cursor-pointer"
            >
              <span className="material-symbols-outlined text-[17px]">
                {isEditing ? 'save' : 'add'}
              </span>
              <span>{isEditing ? 'Lưu thay đổi' : 'Thêm thiết bị'}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
