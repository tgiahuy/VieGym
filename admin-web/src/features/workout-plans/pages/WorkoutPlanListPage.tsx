import React, { useEffect, useMemo, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { WorkoutPlanDrawer } from '../components/WorkoutPlanDrawer'
import { WorkoutPlanFilterBar } from '../components/WorkoutPlanFilterBar'
import { WorkoutPlanTable } from '../components/WorkoutPlanTable'
import { initialWorkoutPlans } from '../mockData'
import type { WorkoutPlan, WorkoutPlanFilterState } from '../types'
import { workoutPlanApi } from '../api'

export const WorkoutPlanListPage: React.FC = () => {
  const [searchParams] = useSearchParams()
  const [plans, setPlans] = useState<WorkoutPlan[]>(initialWorkoutPlans)
  const [selectedPlan, setSelectedPlan] = useState<WorkoutPlan | null>(null)
  const [isDrawerOpen, setIsDrawerOpen] = useState(() => searchParams.get('action') === 'new')
  const [isLoading, setIsLoading] = useState(false)
  const [loadError, setLoadError] = useState<string | null>(null)

  const [filters, setFilters] = useState<WorkoutPlanFilterState>({
    search: '',
    goal: '',
    level: '',
    daysPerWeek: '',
    status: '',
  })

  const loadPlans = () => {
    if (import.meta.env.MODE === 'test') return
    setIsLoading(true)
    workoutPlanApi
      .list()
      .then((items) => {
        setPlans(items)
        setLoadError(null)
      })
      .catch((err: unknown) => {
        setLoadError(err instanceof Error ? err.message : 'Không thể tải danh sách giáo án')
      })
      .finally(() => {
        setIsLoading(false)
      })
  }

  useEffect(() => {
    if (import.meta.env.MODE === 'test') return
    let active = true
    workoutPlanApi
      .list()
      .then((items) => {
        if (!active) return
        setPlans(items)
        setLoadError(null)
      })
      .catch((err: unknown) => {
        if (!active) return
        setLoadError(err instanceof Error ? err.message : 'Không thể tải danh sách giáo án')
      })
      .finally(() => {
        if (active) {
          setIsLoading(false)
        }
      })
    return () => {
      active = false
    }
  }, [])

  // Filter logic
  const filteredPlans = useMemo(() => {
    return plans.filter((item) => {
      if (filters.search.trim()) {
        const q = filters.search.toLowerCase().trim()
        const matchesTitle = item.title.toLowerCase().includes(q)
        const matchesCode = item.code.toLowerCase().includes(q)
        const matchesAuthor = item.author.toLowerCase().includes(q)
        const matchesTags = item.tags.some((t) => t.toLowerCase().includes(q))
        if (!matchesTitle && !matchesCode && !matchesAuthor && !matchesTags) {
          return false
        }
      }
      if (filters.goal && item.goal !== filters.goal) {
        return false
      }
      if (filters.level && item.level !== filters.level) {
        return false
      }
      if (filters.daysPerWeek && String(item.daysPerWeek) !== filters.daysPerWeek) {
        return false
      }
      if (filters.status && item.status !== filters.status) {
        return false
      }
      return true
    })
  }, [plans, filters])

  // Stats calculation
  const totalCount = plans.length
  const activeCount = plans.filter((p) => p.status === 'active').length
  const draftCount = plans.filter((p) => p.status === 'draft').length
  const totalExercisesLinked = plans.reduce(
    (sum, p) => sum + p.days.reduce((dSum, d) => dSum + (d.exercises?.length || 0), 0),
    0
  )

  const handleOpenCreate = () => {
    setSelectedPlan(null)
    setIsDrawerOpen(true)
  }

  const handleSelectPlan = (item: WorkoutPlan) => {
    setSelectedPlan(item)
    setIsDrawerOpen(true)
  }

  const handleToggleStatus = async (item: WorkoutPlan, e: React.MouseEvent) => {
    e.stopPropagation()
    const nextStatus = item.status === 'active' ? 'draft' : 'active'
    const updatedPlan: WorkoutPlan = { ...item, status: nextStatus, updatedAt: 'Hôm nay' }
    try {
      const saved = await workoutPlanApi.save(updatedPlan)
      setPlans(plans.map((p) => (p.id === item.id ? saved : p)))
    } catch {
      setPlans(plans.map((p) => (p.id === item.id ? updatedPlan : p)))
    }
  }

  const handleDeletePlan = async (id: string) => {
    try {
      await workoutPlanApi.remove(id)
    } catch {
      // Continue optimistic delete
    }
    setPlans(plans.filter((p) => p.id !== id))
    if (selectedPlan?.id === id) {
      setIsDrawerOpen(false)
      setSelectedPlan(null)
    }
  }

  const handleSavePlan = async (savedPlan: WorkoutPlan) => {
    try {
      const persisted = await workoutPlanApi.save(savedPlan)
      const existingIndex = plans.findIndex((p) => p.id === savedPlan.id || p.id === persisted.id)
      if (existingIndex >= 0) {
        const updated = [...plans]
        updated[existingIndex] = persisted
        setPlans(updated)
      } else {
        setPlans([persisted, ...plans])
      }
      setLoadError(null)
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Không thể lưu giáo án lên hệ thống'
      setLoadError(msg)
      alert(`Lỗi khi lưu giáo án: ${msg}`)
      const existingIndex = plans.findIndex((p) => p.id === savedPlan.id)
      if (existingIndex >= 0) {
        const updated = [...plans]
        updated[existingIndex] = savedPlan
        setPlans(updated)
      } else {
        setPlans([savedPlan, ...plans])
      }
    }
  }

  return (
    <div className="space-y-6 animate-fadeIn pb-8">
      {/* Page Header & Action Bar */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-[28px] leading-[36px] font-bold tracking-tight text-[#f5f5f6]">
            Giáo án
          </h1>
          <p className="text-[14px] text-[#a7a9ae] mt-1">
            Biên soạn và quản lý giáo án tập luyện từ kho bài tập, thiết lập lộ trình cho học viên
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={loadPlans}
            className="h-11 px-4 rounded-xl bg-[#222327] hover:bg-[#2c2d33] border border-[#292a2f] text-[#f5f5f6] text-[14px] font-medium flex items-center gap-2 transition-colors cursor-pointer"
            title="Làm mới danh sách giáo án"
          >
            <span
              className={`material-symbols-outlined text-[18px] ${
                isLoading ? 'animate-spin text-[#ff506d]' : ''
              }`}
            >
              refresh
            </span>
            <span>Làm mới</span>
          </button>
          <button
            type="button"
            onClick={handleOpenCreate}
            className="h-11 px-5 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white flex items-center gap-2 text-[14px] font-semibold transition-transform active:scale-[0.98] shadow-sm cursor-pointer"
          >
            <span className="material-symbols-outlined text-[20px]">add</span>
            <span>+ Tạo giáo án mới</span>
          </button>
        </div>
      </div>

      {loadError && (
        <div className="p-4 rounded-xl bg-[#f2305a]/10 border border-[#f2305a]/30 text-[#ff506d] text-sm flex items-center gap-2">
          <span className="material-symbols-outlined text-lg">error</span>
          <span>{loadError}</span>
        </div>
      )}

      {/* KPI Overview Metrics */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="p-4 rounded-xl bg-[#17181b] border border-[#292a2f]">
          <div className="text-[12px] text-[#8a8d93] font-medium flex items-center gap-1.5">
            <span className="material-symbols-outlined text-[#ff506d] text-[18px]">menu_book</span>
            <span>Tổng số giáo án</span>
          </div>
          <div className="text-[24px] font-bold text-[#f5f5f6] mt-1.5">{totalCount}</div>
        </div>

        <div className="p-4 rounded-xl bg-[#17181b] border border-[#292a2f]">
          <div className="text-[12px] text-[#8a8d93] font-medium flex items-center gap-1.5">
            <span className="material-symbols-outlined text-[#35c76f] text-[18px]">check_circle</span>
            <span>Đang phát hành</span>
          </div>
          <div className="text-[24px] font-bold text-[#35c76f] mt-1.5">{activeCount}</div>
        </div>

        <div className="p-4 rounded-xl bg-[#17181b] border border-[#292a2f]">
          <div className="text-[12px] text-[#8a8d93] font-medium flex items-center gap-1.5">
            <span className="material-symbols-outlined text-[#facc15] text-[18px]">edit_note</span>
            <span>Bản nháp</span>
          </div>
          <div className="text-[24px] font-bold text-[#facc15] mt-1.5">{draftCount}</div>
        </div>

        <div className="p-4 rounded-xl bg-[#17181b] border border-[#292a2f]">
          <div className="text-[12px] text-[#8a8d93] font-medium flex items-center gap-1.5">
            <span className="material-symbols-outlined text-[#9b7bff] text-[18px]">fitness_center</span>
            <span>Bài tập đã liên kết</span>
          </div>
          <div className="text-[24px] font-bold text-[#9b7bff] mt-1.5">{totalExercisesLinked}</div>
        </div>
      </div>

      {/* Filter Bar */}
      <WorkoutPlanFilterBar
        filters={filters}
        onChange={setFilters}
        totalCount={totalCount}
        activeCount={activeCount}
        draftCount={draftCount}
      />

      {/* Data Table */}
      <WorkoutPlanTable
        plans={filteredPlans}
        selectedId={selectedPlan?.id || null}
        onSelect={handleSelectPlan}
        onToggleStatus={handleToggleStatus}
      />

      {/* Floating Centered Modal */}
      <WorkoutPlanDrawer
        isOpen={isDrawerOpen}
        plan={selectedPlan}
        onClose={() => setIsDrawerOpen(false)}
        onSave={handleSavePlan}
        onDelete={handleDeletePlan}
      />
    </div>
  )
}

