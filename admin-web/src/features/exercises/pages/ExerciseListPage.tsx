import React, { useEffect, useMemo, useState } from 'react'
import { ExerciseDrawer } from '../components/ExerciseDrawer'
import { ExerciseFilterBar } from '../components/ExerciseFilterBar'
import { ExerciseTable } from '../components/ExerciseTable'
import { initialExercises } from '../mockData'
import type { ExerciseFilterState, ExerciseItem } from '../types'
import { exerciseApi } from '../api'
import { getEquipmentLabel, getMuscleLabel } from '../catalogConstants'

export const ExerciseListPage: React.FC = () => {
  const [exercises, setExercises] = useState<ExerciseItem[]>(initialExercises)
  const [selectedExercise, setSelectedExercise] = useState<ExerciseItem | null>(null)
  const [isDrawerOpen, setIsDrawerOpen] = useState(false)
  const [loadError, setLoadError] = useState<string | null>(null)

  useEffect(() => {
    if (import.meta.env.MODE === 'test') return
    exerciseApi.list().then(setExercises).catch((error: unknown) => {
      setLoadError(error instanceof Error ? error.message : 'Không thể tải danh sách bài tập')
    })
  }, [])

  const [filters, setFilters] = useState<ExerciseFilterState>({
    search: '',
    muscle: '',
    equipment: '',
    level: '',
    status: '',
  })

  // Filtered dataset
  const filteredExercises = useMemo(() => {
    return exercises.filter((item) => {
      if (filters.search) {
        const q = filters.search.toLowerCase()
        const matchesNameVn = item.nameVn.toLowerCase().includes(q)
        const matchesNameEn = item.nameEn.toLowerCase().includes(q)
        const matchesCode = item.code.toLowerCase().includes(q)
        const matchesMuscle = getMuscleLabel(item.primaryMuscle).toLowerCase().includes(q)
        const matchesEquipment = item.equipment.some((eq) =>
          getEquipmentLabel(eq).toLowerCase().includes(q)
        )
        if (!matchesNameVn && !matchesNameEn && !matchesCode && !matchesMuscle && !matchesEquipment)
          return false
      }
      if (filters.muscle) {
        const label = getMuscleLabel(item.primaryMuscle).toLowerCase()
        const target = filters.muscle.toLowerCase()
        if (item.primaryMuscle !== filters.muscle && !label.includes(target)) {
          return false
        }
      }
      if (filters.equipment) {
        const target = filters.equipment.toLowerCase()
        const hasEq = item.equipment.some((eq) => {
          const label = getEquipmentLabel(eq).toLowerCase()
          return eq.toLowerCase().includes(target) || label.includes(target)
        })
        if (!hasEq) return false
      }
      if (filters.level && item.level !== filters.level) {
        return false
      }
      if (filters.status && item.status !== filters.status) {
        return false
      }
      return true
    })
  }, [exercises, filters])

  const totalCount = exercises.length
  const activeCount = exercises.filter((e) => e.status === 'active').length
  const hiddenCount = exercises.filter((e) => e.status === 'hidden').length

  const handleOpenCreate = () => {
    setSelectedExercise(null)
    setIsDrawerOpen(true)
  }

  const handleSelectExercise = (item: ExerciseItem) => {
    setSelectedExercise(item)
    setIsDrawerOpen(true)
  }

  const handleDeleteExercise = (id: string) => {
    setExercises(exercises.filter((ex) => ex.id !== id))
    if (selectedExercise?.id === id) {
      setIsDrawerOpen(false)
      setSelectedExercise(null)
    }
    if (import.meta.env.MODE !== 'test') {
      exerciseApi.remove(id).catch((error: unknown) => {
        setLoadError(error instanceof Error ? error.message : 'Không thể xóa bài tập')
        void exerciseApi.list().then(setExercises)
      })
    }
  }

  const handleSaveExercise = (item: ExerciseItem) => {
    const existingIndex = exercises.findIndex((ex) => ex.id === item.id)
    if (existingIndex >= 0) {
      const updated = [...exercises]
      updated[existingIndex] = item
      setExercises(updated)
    } else {
      setExercises([item, ...exercises])
    }
    if (import.meta.env.MODE !== 'test') {
      exerciseApi.save(item).then((saved) => {
        setExercises((current) => [saved, ...current.filter((entry) => entry.id !== item.id && entry.id !== saved.id)])
      }).catch((error: unknown) => {
        setLoadError(error instanceof Error ? error.message : 'Không thể lưu bài tập')
        void exerciseApi.list().then(setExercises)
      })
    }
  }

  return (
    <div className="space-y-6 animate-fadeIn pb-8">
      {loadError && <div role="alert" className="rounded-xl border border-[#ff5a5f]/40 bg-[#ff5a5f]/10 p-3 text-sm text-[#ff8b8f]">{loadError}</div>}
      {/* Page Header & Action Bar */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-[28px] leading-[36px] font-bold tracking-tight text-[#f5f5f6]">
            Bài tập
          </h1>
          <p className="text-[14px] text-[#a7a9ae] mt-1">
            Quản lý kho bài tập dùng trong lịch tập và mô hình AI huấn luyện
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={handleOpenCreate}
            className="h-11 px-5 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white flex items-center gap-2 text-[14px] font-semibold transition-transform active:scale-[0.98] shadow-sm cursor-pointer"
          >
            <span className="material-symbols-outlined text-[20px]">add</span>
            <span>+ Thêm bài tập</span>
          </button>
        </div>
      </div>

      {/* Filter Bar Card */}
      <ExerciseFilterBar
        filters={filters}
        onChange={setFilters}
        totalCount={totalCount}
        activeCount={activeCount}
        hiddenCount={hiddenCount}
      />

      {/* Data Table Container */}
      <ExerciseTable
        exercises={filteredExercises}
        selectedId={selectedExercise?.id || null}
        onSelect={handleSelectExercise}
      />

      {/* Floating Centered Modal */}
      <ExerciseDrawer
        isOpen={isDrawerOpen}
        exercise={selectedExercise}
        onClose={() => setIsDrawerOpen(false)}
        onSave={handleSaveExercise}
        onDelete={handleDeleteExercise}
      />
    </div>
  )
}
