import React, { useEffect, useMemo, useState } from 'react'
import { FoodFilterBar } from '../components/FoodFilterBar'
import { FoodModal } from '../components/FoodModal'
import { FoodTable } from '../components/FoodTable'
import { INITIAL_FOODS } from '../mockData'
import { FoodFilterState, FoodItem } from '../types'
import { foodApi } from '../api'

export const FoodListPage: React.FC = () => {
  const [foods, setFoods] = useState<FoodItem[]>(INITIAL_FOODS)
  const [selectedFoodId, setSelectedFoodId] = useState<string | undefined>('food-1')
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [editingFood, setEditingFood] = useState<FoodItem | null>(null)
  const [toastMessage, setToastMessage] = useState<string | null>(null)

  const showToast = (msg: string) => {
    setToastMessage(msg)
    setTimeout(() => {
      setToastMessage(null)
    }, 3000)
  }

  useEffect(() => {
    if (import.meta.env.MODE === 'test') return
    foodApi.list().then(setFoods).catch(() => setToastMessage('Không thể tải danh sách thực phẩm'))
  }, [])

  const [filters, setFilters] = useState<FoodFilterState>({
    search: '',
    category: '',
    source: '',
    status: '',
  })

  const handleFilterChange = (newFilters: Partial<FoodFilterState>) => {
    setFilters((prev) => ({ ...prev, ...newFilters }))
  }

  const handleResetFilters = () => {
    setFilters({
      search: '',
      category: '',
      source: '',
      status: '',
    })
  }

  // Filtered dataset
  const filteredFoods = useMemo(() => {
    return foods.filter((food) => {
      // Search matching
      if (filters.search.trim()) {
        const query = filters.search.toLowerCase().trim()
        const matchNameVi = food.nameVi.toLowerCase().includes(query)
        const matchNameEn = food.nameEn.toLowerCase().includes(query)
        const matchCode = food.code.toLowerCase().includes(query)
        if (!matchNameVi && !matchNameEn && !matchCode) {
          return false
        }
      }

      // Category matching
      if (filters.category && food.category !== filters.category) {
        return false
      }

      // Source matching
      if (filters.source && food.source !== filters.source) {
        return false
      }

      // Status matching
      if (filters.status && food.status !== filters.status) {
        return false
      }

      return true
    })
  }, [foods, filters])

  // Aggregate metrics
  const activeCount = useMemo(() => foods.filter((f) => f.status === 'active').length, [foods])
  const incompleteCount = useMemo(
    () => foods.filter((f) => f.status === 'incomplete').length,
    [foods]
  )
  const hiddenCount = useMemo(() => foods.filter((f) => f.status === 'hidden').length, [foods])

  // Actions
  const handleOpenCreateModal = () => {
    setEditingFood(null)
    setIsModalOpen(true)
  }

  const handleOpenEditModal = (food: FoodItem) => {
    setSelectedFoodId(food.id)
    setEditingFood(food)
    setIsModalOpen(true)
  }

  const handleSaveFood = (savedFood: FoodItem) => {
    setFoods((prev) => {
      const exists = prev.some((f) => f.id === savedFood.id)
      if (exists) {
        return prev.map((f) => (f.id === savedFood.id ? savedFood : f))
      }
      return [savedFood, ...prev]
    })
    setSelectedFoodId(savedFood.id)
    setIsModalOpen(false)
    showToast(`Đã lưu thành công thực phẩm "${savedFood.nameVi}"`)
    if (import.meta.env.MODE !== 'test') {
      foodApi.save(savedFood).then((serverFood) => setFoods((current) => [serverFood, ...current.filter((item) => item.id !== savedFood.id && item.id !== serverFood.id)])).catch(() => {
        showToast('Lưu thất bại; dữ liệu đã được tải lại')
        void foodApi.list().then(setFoods)
      })
    }
  }

  const handleToggleStatus = (food: FoodItem) => {
    const nextStatus = food.status === 'hidden' ? 'active' : 'hidden'
    setFoods((prev) =>
      prev.map((f) => (f.id === food.id ? { ...f, status: nextStatus } : f))
    )
    showToast(
      `Đã chuyển trạng thái thực phẩm "${food.nameVi}" sang ${
        nextStatus === 'hidden' ? 'Ẩn' : 'Active'
      }`
    )
    if (import.meta.env.MODE !== 'test') {
      foodApi.visibility(food).then((saved) => setFoods((current) => current.map((item) => item.id === saved.id ? saved : item))).catch(() => void foodApi.list().then(setFoods))
    }
  }

  const handleDeleteFood = (id: string) => {
    const target = foods.find((f) => f.id === id)
    if (window.confirm(`Bạn có chắc chắn muốn xóa thực phẩm "${target?.nameVi || id}"?`)) {
      setFoods((prev) => prev.filter((f) => f.id !== id))
      if (selectedFoodId === id) setSelectedFoodId(undefined)
      showToast('Đã xóa thực phẩm khỏi hệ thống')
      if (import.meta.env.MODE !== 'test') foodApi.remove(id).catch(() => void foodApi.list().then(setFoods))
    }
  }

  return (
    <div className="space-y-6">
      {/* Toast Feedback */}
      {toastMessage && (
        <div className="fixed top-20 right-8 z-50 bg-[#222327] border border-[#35c76f]/40 text-[#f5f5f6] px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2.5 animate-fadeIn">
          <span className="material-symbols-outlined text-[#35c76f] text-xl">check_circle</span>
          <span className="text-sm font-medium">{toastMessage}</span>
        </div>
      )}

      {/* Page Header & Actions */}
      <section className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-2xl sm:text-3xl font-bold text-[#f5f5f6] tracking-tight">
              Thực phẩm
            </h1>
            <span className="px-2.5 py-0.5 text-xs font-bold rounded-full bg-[#222327] border border-[#292a2f] text-[#a7a9ae] tabular-nums">
              {foods.length} món
            </span>
          </div>
          <p className="text-sm text-[#a7a9ae] mt-1">
            Quản lý dữ liệu khẩu phần và giá trị dinh dưỡng của thư viện thực phẩm VieGym.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={handleOpenCreateModal}
            className="h-11 px-5 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 shadow-lg shadow-[#f2305a]/20 active:scale-[0.98] transition-all cursor-pointer"
          >
            <span className="material-symbols-outlined text-[20px]">add</span>
            <span>+ Thêm thực phẩm</span>
          </button>
        </div>
      </section>

      {/* Filter & Search Bar */}
      <FoodFilterBar
        filters={filters}
        onFilterChange={handleFilterChange}
        onReset={handleResetFilters}
        totalCount={foods.length}
        activeCount={activeCount}
        incompleteCount={incompleteCount}
        hiddenCount={hiddenCount}
      />

      {/* Data Table */}
      <FoodTable
        foods={filteredFoods}
        selectedFoodId={selectedFoodId}
        onEdit={handleOpenEditModal}
        onToggleStatus={handleToggleStatus}
      />

      {/* 720px Food Edit / Create Modal */}
      <FoodModal
        isOpen={isModalOpen}
        food={editingFood}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSaveFood}
        onDelete={handleDeleteFood}
      />
    </div>
  )
}
