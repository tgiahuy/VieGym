import React, { useEffect, useState } from 'react'
import { FoodCategory, FoodItem, FoodSource, FoodStatus } from '../types'
import { MediaUploader } from '../../media/MediaUploader'

interface FoodModalProps {
  isOpen: boolean
  food: FoodItem | null
  onClose: () => void
  onSave: (food: FoodItem) => void
  onDelete?: (id: string) => void
}

interface FormContentProps {
  initialFood: FoodItem | null
  onClose: () => void
  onSave: (food: FoodItem) => void
  onDelete?: (id: string) => void
}

const ModalFormContent: React.FC<FormContentProps> = ({
  initialFood,
  onClose,
  onSave,
  onDelete,
}) => {
  const isEditing = !!initialFood

  const [nameVi, setNameVi] = useState(initialFood?.nameVi || '')
  const [nameEn, setNameEn] = useState(initialFood?.nameEn || '')
  const [category, setCategory] = useState<FoodCategory>(initialFood?.category || 'meat')
  const [servingSize, setServingSize] = useState<number>(initialFood?.servingSize || 100)
  const [servingUnit, setServingUnit] = useState<string>(initialFood?.servingUnit || '100 g')

  const [calories, setCalories] = useState<number>(initialFood?.nutrients.calories || 0)
  const [protein, setProtein] = useState<number>(initialFood?.nutrients.protein || 0)
  const [carbs, setCarbs] = useState<number>(initialFood?.nutrients.carbs || 0)
  const [fat, setFat] = useState<number>(initialFood?.nutrients.fat || 0)
  const [fiber, setFiber] = useState<number>(initialFood?.nutrients.fiber || 0)
  const [sugar, setSugar] = useState<number>(initialFood?.nutrients.sugar || 0)
  const [sodium, setSodium] = useState<number>(initialFood?.nutrients.sodium || 0)

  const [source, setSource] = useState<FoodSource>(initialFood?.source || 'usda')
  const [aiNotes, setAiNotes] = useState(
    initialFood?.aiNotes || 'Đã chuẩn hóa cho bộ máy AI tính toán Calo & Macro tự động'
  )
  const [image, setImage] = useState(
    initialFood?.image ||
      'https://lh3.googleusercontent.com/aida-public/AB6AXuC7ytE_rjwM0kL_ZZp_SXO9ABjT4qwOa962d3ExydFVTKXD-O6iMwBh6SsuPoGUUktiV9xI1eDTlULxp9g4oQoDXU3Nz-bWxedOWlyJVcBziq13be0q3BO8I6aSkuebNzaEJax0BxCcZbiEaOSZVh1H_8Zl72XPhL_wokSOsFLTh1bPWXBQeWdhwrSV0DqDUI_UIz1qT3z2d0F6Pp6iEGcDuhgisb34u75ifRisPtOKAeoEaiAZFdvx'
  )
  const [status, setStatus] = useState<FoodStatus>(initialFood?.status || 'active')

  // Validation state
  const [errorMsg, setErrorMsg] = useState<string | null>(null)

  // Calorie & Macro calculations
  const calFromProtein = protein * 4
  const calFromCarbs = carbs * 4
  const calFromFat = fat * 9
  const totalMacroCals = calFromProtein + calFromCarbs + calFromFat

  const proteinRatio =
    totalMacroCals > 0 ? Math.round((calFromProtein / totalMacroCals) * 100) : 0
  const carbsRatio =
    totalMacroCals > 0 ? Math.round((calFromCarbs / totalMacroCals) * 100) : 0
  const fatRatio =
    totalMacroCals > 0 ? Math.round((calFromFat / totalMacroCals) * 100) : 0

  const getSourceLabel = (src: FoodSource): string => {
    switch (src) {
      case 'usda':
        return 'USDA FoodData'
      case 'vn_nin':
        return 'Viện Dinh Dưỡng QG'
      case 'viegym':
        return 'VieGym Verif'
      case 'custom':
        return 'Tùy biến'
    }
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!nameVi.trim()) {
      setErrorMsg('Vui lòng nhập tên tiếng Việt cho thực phẩm')
      return
    }

    const now = new Date()
    const formattedDate = `${String(now.getDate()).padStart(2, '0')}/${String(
      now.getMonth() + 1
    ).padStart(2, '0')}/${now.getFullYear()} ${String(now.getHours()).padStart(
      2,
      '0'
    )}:${String(now.getMinutes()).padStart(2, '0')}`

    const updatedFood: FoodItem = {
      ...initialFood,
      id: initialFood?.id || `food-${Date.now()}`,
      code: initialFood?.code || `FD-${Math.floor(1000 + Math.random() * 9000)}`,
      nameVi: nameVi.trim(),
      nameEn: nameEn.trim() || nameVi.trim(),
      category,
      servingSize: Number(servingSize) || 100,
      servingUnit: servingUnit.trim() || '100 g',
      nutrients: {
        calories: Number(calories) || 0,
        protein: Number(protein) || 0,
        carbs: Number(carbs) || 0,
        fat: Number(fat) || 0,
        fiber: Number(fiber) || 0,
        sugar: Number(sugar) || 0,
        sodium: Number(sodium) || 0,
      },
      source,
      sourceLabel: getSourceLabel(source),
      status,
      image,
      aiNotes,
      updatedAt: formattedDate,
    }

    onSave(updatedFood)
  }

  return (
    <form onSubmit={handleSubmit} className="flex flex-col h-full">
      {/* Modal Header */}
      <div className="h-18 px-6 py-4 border-b border-[#292a2f] flex items-center justify-between shrink-0">
        <div className="flex flex-col">
          <div className="flex items-center gap-2">
            <h2 className="text-xl font-bold text-[#f5f5f6]">
              {isEditing ? 'Chỉnh sửa thực phẩm' : 'Thêm thực phẩm mới'}
            </h2>
            <span className="text-xs font-mono font-bold px-2 py-0.5 rounded bg-[#222327] text-[#ff506d] border border-[#34363b]">
              #{initialFood?.code || 'FD-NEW'}
            </span>
          </div>
          <span className="text-xs text-[#8a8d93] mt-0.5">
            {nameVi || 'Thực phẩm mới'} {nameEn ? `(${nameEn})` : ''}
          </span>
        </div>
        <button
          type="button"
          onClick={onClose}
          className="w-8 h-8 rounded-lg bg-[#222327] hover:bg-[#17181b] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f] flex items-center justify-center transition-colors cursor-pointer"
          title="Đóng (ESC)"
        >
          <span className="material-symbols-outlined text-[18px]">close</span>
        </button>
      </div>

      {/* Modal Body (Scrollable interior with 4 partitioned sections) */}
      <div className="p-6 overflow-y-auto max-h-[calc(85vh-144px)] flex flex-col gap-6">
        {errorMsg && (
          <div className="p-3 rounded-xl bg-[#ff5a5f]/15 border border-[#ff5a5f]/30 text-[#ff5a5f] text-sm flex items-center gap-2">
            <span className="material-symbols-outlined text-lg">error</span>
            <span>{errorMsg}</span>
          </div>
        )}

        {/* SECTION 1: NHẬN DIỆN THỰC PHẨM */}
        <div className="flex flex-col gap-3">
          <div className="flex items-center gap-2 pb-1 border-b border-[#292a2f]/60">
            <span className="material-symbols-outlined text-[#ff506d] text-[18px]">badge</span>
            <h3 className="text-[16px] font-semibold text-[#f5f5f6]">1. Nhận diện thực phẩm</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Tên tiếng Việt */}
            <div className="flex flex-col gap-1.5 md:col-span-2">
              <label className="text-xs font-semibold text-[#a7a9ae]">
                Tên tiếng Việt chuẩn hóa <span className="text-[#ff5a5f]">*</span>
              </label>
              <input
                type="text"
                value={nameVi}
                onChange={(e) => {
                  setNameVi(e.target.value)
                  if (errorMsg) setErrorMsg(null)
                }}
                className="h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm focus:outline-none focus:border-[#ff506d]"
                placeholder="VD: Ức gà phi lê không da"
                required
              />
            </div>
            {/* Tên thay thế / Tên khoa học */}
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-semibold text-[#a7a9ae]">
                Tên tiếng Anh / Tên thay thế
              </label>
              <input
                type="text"
                value={nameEn}
                onChange={(e) => setNameEn(e.target.value)}
                className="h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm focus:outline-none focus:border-[#ff506d]"
                placeholder="VD: Chicken Breast, skinless, raw"
              />
            </div>
            {/* Nhóm thực phẩm */}
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-semibold text-[#a7a9ae]">
                Nhóm thực phẩm <span className="text-[#ff5a5f]">*</span>
              </label>
              <div className="relative">
                <select
                  value={category}
                  onChange={(e) => setCategory(e.target.value as FoodCategory)}
                  className="w-full h-11 pl-3.5 pr-8 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm appearance-none focus:outline-none focus:border-[#ff506d] cursor-pointer"
                >
                  <option value="meat">Thịt &amp; Gia cầm (Poultry &amp; Meat)</option>
                  <option value="seafood">Hải sản (Seafood)</option>
                  <option value="dairy">Trứng &amp; Sữa (Dairy &amp; Eggs)</option>
                  <option value="carbs">Tinh bột &amp; Ngũ cốc (Carbohydrates)</option>
                  <option value="vegetable">Rau xanh &amp; Củ (Vegetables)</option>
                  <option value="fruit">Trái cây (Fruits)</option>
                  <option value="spice">Gia vị &amp; Sốt (Spices &amp; Sauces)</option>
                </select>
                <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-[18px]">
                  expand_more
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* SECTION 2: KHẨU PHẦN CHUẨN */}
        <div className="flex flex-col gap-3">
          <div className="flex items-center gap-2 pb-1 border-b border-[#292a2f]/60">
            <span className="material-symbols-outlined text-[#ff506d] text-[18px]">scale</span>
            <h3 className="text-[16px] font-semibold text-[#f5f5f6]">2. Khẩu phần chuẩn</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {/* Khối lượng chuẩn */}
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-semibold text-[#a7a9ae]">
                Khối lượng chuẩn tham chiếu <span className="text-[#ff5a5f]">*</span>
              </label>
              <div className="relative">
                <input
                  type="number"
                  min="1"
                  value={servingSize}
                  onChange={(e) => setServingSize(Number(e.target.value))}
                  className="w-full h-11 pl-3.5 pr-10 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm tabular-nums focus:outline-none focus:border-[#ff506d]"
                />
                <span className="absolute right-3.5 top-1/2 -translate-y-1/2 text-xs font-bold text-[#8a8d93]">
                  g
                </span>
              </div>
              <span className="text-[11px] text-[#8a8d93]">
                Mọi giá trị dinh dưỡng bên dưới tính trên khối lượng này.
              </span>
            </div>
            {/* Tên đơn vị thường dùng */}
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-semibold text-[#a7a9ae]">
                Tên đơn vị gia dụng thường dùng
              </label>
              <input
                type="text"
                value={servingUnit}
                onChange={(e) => setServingUnit(e.target.value)}
                className="h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm focus:outline-none focus:border-[#ff506d]"
                placeholder="VD: 1 miếng phi lê (150 g)"
              />
              <span className="text-[11px] text-[#8a8d93]">
                Gợi ý nhanh cho hội viên khi ghi nhật ký ăn uống.
              </span>
            </div>
          </div>
        </div>

        {/* SECTION 3: GIÁ TRỊ DINH DƯỠNG (4 Key Macro Grid) */}
        <div className="flex flex-col gap-3">
          <div className="flex items-center justify-between pb-1 border-b border-[#292a2f]/60">
            <div className="flex items-center gap-2">
              <span className="material-symbols-outlined text-[#ff506d] text-[18px]">
                pie_chart
              </span>
              <h3 className="text-[16px] font-semibold text-[#f5f5f6]">
                3. Giá trị dinh dưỡng (trên {servingSize}g)
              </h3>
            </div>
            <span className="text-[11px] font-mono text-[#8a8d93]">
              Độ chính xác: 1 chữ số thập phân
            </span>
          </div>

          {/* 4 Core Columns */}
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            {/* Calories */}
            <div className="p-3 rounded-xl bg-[#17181b] border border-[#f28c38]/30 flex flex-col gap-1">
              <span className="text-[11px] font-semibold text-[#f28c38] flex items-center justify-between">
                <span>CALORIES</span>
                <span className="material-symbols-outlined text-[14px]">local_fire_department</span>
              </span>
              <div className="relative mt-1">
                <input
                  type="number"
                  step="1"
                  min="0"
                  value={calories}
                  onChange={(e) => setCalories(Number(e.target.value))}
                  className="w-full h-10 px-2.5 pr-10 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] font-bold tabular-nums text-sm focus:outline-none focus:border-[#f28c38]"
                />
                <span className="absolute right-2 top-1/2 -translate-y-1/2 text-[11px] text-[#8a8d93]">
                  kcal
                </span>
              </div>
            </div>

            {/* Protein */}
            <div className="p-3 rounded-xl bg-[#17181b] border border-[#2cc7b5]/30 flex flex-col gap-1">
              <span className="text-[11px] font-semibold text-[#2cc7b5] flex items-center justify-between">
                <span>PROTEIN</span>
                <span className="material-symbols-outlined text-[14px]">fitness_center</span>
              </span>
              <div className="relative mt-1">
                <input
                  type="number"
                  step="0.1"
                  min="0"
                  value={protein}
                  onChange={(e) => setProtein(Number(e.target.value))}
                  className="w-full h-10 px-2.5 pr-7 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] font-bold tabular-nums text-sm focus:outline-none focus:border-[#2cc7b5]"
                />
                <span className="absolute right-2 top-1/2 -translate-y-1/2 text-[11px] text-[#8a8d93]">
                  g
                </span>
              </div>
            </div>

            {/* Carbs */}
            <div className="p-3 rounded-xl bg-[#17181b] border border-[#35c76f]/30 flex flex-col gap-1">
              <span className="text-[11px] font-semibold text-[#35c76f] flex items-center justify-between">
                <span>CARBS</span>
                <span className="material-symbols-outlined text-[14px]">grain</span>
              </span>
              <div className="relative mt-1">
                <input
                  type="number"
                  step="0.1"
                  min="0"
                  value={carbs}
                  onChange={(e) => setCarbs(Number(e.target.value))}
                  className="w-full h-10 px-2.5 pr-7 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] font-bold tabular-nums text-sm focus:outline-none focus:border-[#35c76f]"
                />
                <span className="absolute right-2 top-1/2 -translate-y-1/2 text-[11px] text-[#8a8d93]">
                  g
                </span>
              </div>
            </div>

            {/* Fat */}
            <div className="p-3 rounded-xl bg-[#17181b] border border-[#4d8dff]/30 flex flex-col gap-1">
              <span className="text-[11px] font-semibold text-[#4d8dff] flex items-center justify-between">
                <span>FAT</span>
                <span className="material-symbols-outlined text-[14px]">water_drop</span>
              </span>
              <div className="relative mt-1">
                <input
                  type="number"
                  step="0.1"
                  min="0"
                  value={fat}
                  onChange={(e) => setFat(Number(e.target.value))}
                  className="w-full h-10 px-2.5 pr-7 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] font-bold tabular-nums text-sm focus:outline-none focus:border-[#4d8dff]"
                />
                <span className="absolute right-2 top-1/2 -translate-y-1/2 text-[11px] text-[#8a8d93]">
                  g
                </span>
              </div>
            </div>
          </div>

          {/* Secondary Macro Row */}
          <div className="grid grid-cols-3 gap-3 pt-1">
            <div className="flex flex-col gap-1">
              <label className="text-[11px] text-[#8a8d93]">Chất xơ (Fiber)</label>
              <div className="relative">
                <input
                  type="number"
                  step="0.1"
                  min="0"
                  value={fiber}
                  onChange={(e) => setFiber(Number(e.target.value))}
                  className="w-full h-9 px-2.5 pr-6 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-xs tabular-nums focus:outline-none focus:border-[#ff506d]"
                />
                <span className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[10px] text-[#8a8d93]">
                  g
                </span>
              </div>
            </div>
            <div className="flex flex-col gap-1">
              <label className="text-[11px] text-[#8a8d93]">Đường (Sugar)</label>
              <div className="relative">
                <input
                  type="number"
                  step="0.1"
                  min="0"
                  value={sugar}
                  onChange={(e) => setSugar(Number(e.target.value))}
                  className="w-full h-9 px-2.5 pr-6 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-xs tabular-nums focus:outline-none focus:border-[#ff506d]"
                />
                <span className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[10px] text-[#8a8d93]">
                  g
                </span>
              </div>
            </div>
            <div className="flex flex-col gap-1">
              <label className="text-[11px] text-[#8a8d93]">Natri (Sodium)</label>
              <div className="relative">
                <input
                  type="number"
                  step="1"
                  min="0"
                  value={sodium}
                  onChange={(e) => setSodium(Number(e.target.value))}
                  className="w-full h-9 px-2.5 pr-8 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-xs tabular-nums focus:outline-none focus:border-[#ff506d]"
                />
                <span className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[10px] text-[#8a8d93]">
                  mg
                </span>
              </div>
            </div>
          </div>

          {/* Real-time Preview Banner */}
          <div className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center gap-3">
            <span className="w-8 h-8 rounded-lg bg-[rgba(242,48,90,0.12)] border border-[#ff506d]/20 text-[#ff506d] flex items-center justify-center shrink-0">
              <span className="material-symbols-outlined text-[18px]">bolt</span>
            </span>
            <div className="flex flex-col text-xs leading-relaxed">
              <span className="text-[#f5f5f6] font-medium">
                ⚡ Xem trước khẩu phần {servingSize} g:{' '}
                <strong className="text-[#f28c38]">{calories} kcal</strong> · P{' '}
                <strong className="text-[#2cc7b5]">{protein.toFixed(1)} g</strong> · C{' '}
                <strong className="text-[#35c76f]">{carbs.toFixed(1)} g</strong> · F{' '}
                <strong className="text-[#4d8dff]">{fat.toFixed(1)} g</strong>
              </span>
              <span className="text-[#8a8d93]">
                Tỷ lệ calo đóng góp:{' '}
                <strong className="text-[#2cc7b5]">{proteinRatio}% Protein</strong> ·{' '}
                <strong className="text-[#35c76f]">{carbsRatio}% Carbs</strong> ·{' '}
                <strong className="text-[#4d8dff]">{fatRatio}% Fat</strong>
              </span>
            </div>
          </div>
        </div>

        {/* SECTION 4: NGUỒN DỮ LIỆU & MEDIA */}
        <div className="flex flex-col gap-3">
          <div className="flex items-center gap-2 pb-1 border-b border-[#292a2f]/60">
            <span className="material-symbols-outlined text-[#ff506d] text-[18px]">verified</span>
            <h3 className="text-[16px] font-semibold text-[#f5f5f6]">4. Nguồn dữ liệu &amp; Media</h3>
          </div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-semibold text-[#a7a9ae]">
                Nguồn dữ liệu tham chiếu <span className="text-[#ff5a5f]">*</span>
              </label>
              <select
                value={source}
                onChange={(e) => setSource(e.target.value as FoodSource)}
                className="h-11 px-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm focus:outline-none focus:border-[#ff506d]"
              >
                <option value="usda">USDA FoodData Central (FDC ID: 171077)</option>
                <option value="vn_nin">Viện Dinh Dưỡng Quốc Gia Việt Nam (Bảng 2020)</option>
                <option value="viegym">VieGym Verified Sports Nutrition Lab</option>
                <option value="custom">Tùy biến (Custom Administrator)</option>
              </select>
            </div>
            <div className="flex flex-col gap-1.5">
              <label className="text-xs font-semibold text-[#a7a9ae]">Ghi chú thẩm định AI</label>
              <input
                type="text"
                value={aiNotes}
                onChange={(e) => setAiNotes(e.target.value)}
                className="h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm focus:outline-none focus:border-[#ff506d]"
              />
            </div>
          </div>

          {/* Media Upload Component */}
          <MediaUploader ownerType="FOOD" ownerId={initialFood?.id} accept="image/jpeg,image/png,image/webp" />
          <div className="p-3.5 rounded-xl bg-[#17181b] border border-[#292a2f] flex flex-wrap items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <img
                src={image}
                alt="Preview"
                className="w-14 h-14 rounded-lg object-cover border border-[#292a2f] bg-[#222327] shrink-0"
              />
              <div className="flex flex-col">
                <div className="flex items-center gap-2">
                  <span className="text-xs font-semibold text-[#f5f5f6]">food-image.webp</span>
                  <span className="inline-flex items-center gap-1 text-[10px] px-1.5 py-0.5 rounded bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/20">
                    <span className="material-symbols-outlined text-[12px]">check</span> Đã tải lên
                  </span>
                </div>
                <span className="text-[11px] text-[#8a8d93] mt-0.5">
                  WebP Tối ưu hóa CDN · 800x800 px
                </span>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={() => {
                  const newUrl = window.prompt('Nhập đường dẫn URL ảnh thực phẩm:', image)
                  if (newUrl && newUrl.trim()) setImage(newUrl.trim())
                }}
                className="h-9 px-3 rounded-lg bg-[#222327] hover:bg-[#1c1d21] border border-[#292a2f] text-[#f5f5f6] text-xs font-semibold transition-colors flex items-center gap-1.5 cursor-pointer"
              >
                <span className="material-symbols-outlined text-[16px]">cached</span>
                <span>Thay thế ảnh</span>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Modal Sticky Footer (Fixed 72px) */}
      <div className="h-18 px-6 py-3.5 border-t border-[#292a2f] bg-[#17181b] flex flex-wrap items-center justify-between rounded-b-2xl shrink-0 gap-3">
        <div className="flex items-center gap-2">
          <button
            type="button"
            onClick={() => setStatus(status === 'hidden' ? 'active' : 'hidden')}
            className={`h-11 px-4 rounded-xl border text-sm font-semibold flex items-center gap-2 transition-colors cursor-pointer ${
              status === 'hidden'
                ? 'text-[#35c76f] hover:bg-[#35c76f]/10 border-[#35c76f]/30'
                : 'text-[#ff5a5f] hover:bg-[#ff5a5f]/10 border-[#ff5a5f]/30'
            }`}
          >
            <span className="material-symbols-outlined text-[18px]">
              {status === 'hidden' ? 'visibility' : 'visibility_off'}
            </span>
            <span>{status === 'hidden' ? 'Hiện thực phẩm' : 'Ẩn thực phẩm'}</span>
          </button>

          {isEditing && onDelete && (
            <button
              type="button"
              onClick={() => {
                if (!initialFood) return
                if (
                  window.confirm(
                    `Bạn có chắc chắn muốn xóa thực phẩm "${initialFood.nameVi}"? Thao tác này không thể hoàn tác.`
                  )
                ) {
                  onDelete(initialFood.id)
                  onClose()
                }
              }}
              className="h-11 px-4 rounded-xl border border-[#ff506d]/30 bg-[#ff506d]/10 hover:bg-[#ff506d]/20 text-[#ff506d] text-sm font-semibold flex items-center gap-2 transition-colors cursor-pointer"
              title="Xóa thực phẩm này"
            >
              <span className="material-symbols-outlined text-[18px]">delete</span>
              <span>Xóa thực phẩm</span>
            </button>
          )}
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={onClose}
            className="h-11 px-5 rounded-xl bg-[#222327] hover:bg-[#1c1d21] text-[#a7a9ae] hover:text-[#f5f5f6] text-sm font-semibold border border-[#292a2f] transition-colors cursor-pointer"
          >
            Hủy
          </button>
          <button
            type="submit"
            className="h-11 px-6 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 shadow-lg shadow-[#f2305a]/25 active:scale-[0.98] transition-all cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]">save</span>
            <span>{isEditing ? 'Lưu thực phẩm' : 'Tạo thực phẩm'}</span>
          </button>
        </div>
      </div>
    </form>
  )
}

export const FoodModal: React.FC<FoodModalProps> = ({
  isOpen,
  food,
  onClose,
  onSave,
  onDelete,
}) => {
  // Close modal on Escape key press
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
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/64 backdrop-blur-sm p-4 overflow-y-auto animate-fadeIn"
      onClick={onClose}
    >
      <div
        className="w-full max-w-[720px] bg-[#1c1d21] rounded-2xl border border-[#292a2f] shadow-2xl flex flex-col my-auto relative animate-in fade-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        <ModalFormContent
          key={food ? food.id : 'new-food'}
          initialFood={food}
          onClose={onClose}
          onSave={onSave}
          onDelete={onDelete}
        />
      </div>
    </div>
  )
}
