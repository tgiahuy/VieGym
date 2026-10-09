import React, { useEffect, useMemo, useState } from 'react'
import { EquipmentCardGrid } from '../components/EquipmentCardGrid'
import { EquipmentFilterBar } from '../components/EquipmentFilterBar'
import { EquipmentModal } from '../components/EquipmentModal'
import { EquipmentTable } from '../components/EquipmentTable'
import { INITIAL_EQUIPMENTS } from '../mockData'
import type { EquipmentFilterState, EquipmentItem } from '../types'
import { equipmentApi } from '../api'

export const EquipmentListPage: React.FC = () => {
  const [equipments, setEquipments] = useState<EquipmentItem[]>(INITIAL_EQUIPMENTS)
  const [selectedEquipment, setSelectedEquipment] = useState<EquipmentItem | null>(null)
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [loadError, setLoadError] = useState<string | null>(null)

  const [filters, setFilters] = useState<EquipmentFilterState>({
    search: '',
    category: '',
    status: '',
    viewMode: 'table',
  })

  useEffect(() => {
    if (import.meta.env.MODE === 'test') return
    equipmentApi
      .list()
      .then(setEquipments)
      .catch((err: unknown) => {
        setLoadError(err instanceof Error ? err.message : 'Không thể tải danh sách thiết bị')
      })
  }, [])

  const filteredEquipments = useMemo(() => {
    return equipments.filter((item) => {
      if (filters.search.trim()) {
        const q = filters.search.toLowerCase().trim()
        const matchesName = item.name.toLowerCase().includes(q)
        const matchesNameEn = item.nameEn.toLowerCase().includes(q)
        const matchesCode = item.code.toLowerCase().includes(q)
        const matchesDesc = item.description.toLowerCase().includes(q)
        if (!matchesName && !matchesNameEn && !matchesCode && !matchesDesc) {
          return false
        }
      }

      if (filters.category && item.category !== filters.category) {
        return false
      }

      if (filters.status && item.status !== filters.status) {
        return false
      }

      return true
    })
  }, [equipments, filters])

  const totalCount = equipments.length
  const activeCount = equipments.filter((e) => e.status === 'active').length
  const freeWeightsCount = equipments.filter((e) => e.category === 'free_weights').length
  const machinesCount = equipments.filter((e) => e.category === 'machines').length
  const bodyweightCount = equipments.filter((e) => e.category === 'bodyweight' || e.category === 'accessories').length

  const handleSelectEquipment = (item: EquipmentItem) => {
    setSelectedEquipment(item)
    setIsModalOpen(true)
  }

  const handleOpenCreate = () => {
    setSelectedEquipment(null)
    setIsModalOpen(true)
  }

  const handleCloseModal = () => {
    setIsModalOpen(false)
  }

  const handleSaveEquipment = (savedItem: EquipmentItem) => {
    setEquipments((prev) => {
      const exists = prev.some((item) => item.id === savedItem.id)
      if (exists) {
        return prev.map((item) => (item.id === savedItem.id ? savedItem : item))
      }
      return [savedItem, ...prev]
    })
  }

  const handleDeleteEquipment = (id: number) => {
    setEquipments((prev) => prev.filter((item) => item.id !== id))
    if (selectedEquipment?.id === id) {
      setSelectedEquipment(null)
    }
  }

  return (
    <div className="space-y-6 pb-12">
      {/* Top Header & Breadcrumb */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2 text-[12px] text-[#8a8d93] mb-1">
            <span>Dữ liệu</span>
            <span className="material-symbols-outlined text-[14px]">chevron_right</span>
            <span className="text-[#f5f5f6] font-medium">Thiết bị tập luyện</span>
          </div>
          <div className="flex items-center gap-3">
            <h1 className="text-[24px] font-bold text-[#f5f5f6] tracking-tight">Thiết bị</h1>
            <span className="px-2.5 py-0.5 rounded-full text-[12px] font-semibold bg-[rgba(242,48,90,0.12)] text-[#ff506d] border border-[#f2305a]/20">
              {totalCount} thiết bị
            </span>
          </div>
          <p className="text-[13px] text-[#8a8d93] mt-0.5">
            Quản lý danh mục thiết bị, máy móc và dụng cụ tập luyện được chuẩn hóa toàn hệ thống VieGym
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={handleOpenCreate}
            className="h-10 px-4 rounded-xl bg-gradient-to-r from-[#f2305a] to-[#ff506d] hover:brightness-110 text-white text-[13px] font-semibold flex items-center gap-2 shadow-lg shadow-[#f2305a]/20 transition-all cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]">add</span>
            <span>Thêm thiết bị</span>
          </button>
        </div>
      </div>

      {loadError && (
        <div className="p-4 rounded-xl bg-[#f2305a]/10 border border-[#f2305a]/30 text-[#ff506d] text-[13px] flex items-center gap-2">
          <span className="material-symbols-outlined text-[18px]">error</span>
          <span>{loadError}</span>
        </div>
      )}

      {/* KPI Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="p-4 rounded-2xl bg-[#17181b] border border-[#292a2f] flex items-center justify-between shadow-sm">
          <div>
            <span className="text-[12px] text-[#8a8d93] font-medium block mb-1">
              Tổng số thiết bị
            </span>
            <span className="text-[26px] font-bold text-[#f5f5f6] tracking-tight font-mono">
              {totalCount}
            </span>
          </div>
          <div className="w-11 h-11 rounded-xl bg-[rgba(242,48,90,0.12)] border border-[#f2305a]/30 flex items-center justify-center text-[#ff506d]">
            <span className="material-symbols-outlined text-[22px]">fitness_center</span>
          </div>
        </div>

        <div className="p-4 rounded-2xl bg-[#17181b] border border-[#292a2f] flex items-center justify-between shadow-sm">
          <div>
            <span className="text-[12px] text-[#8a8d93] font-medium block mb-1">
              Tạ tự do (Free Weights)
            </span>
            <span className="text-[26px] font-bold text-[#ff506d] tracking-tight font-mono">
              {freeWeightsCount}
            </span>
          </div>
          <div className="w-11 h-11 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-center text-[#ff506d]">
            <span className="material-symbols-outlined text-[22px]">sports_gymnastics</span>
          </div>
        </div>

        <div className="p-4 rounded-2xl bg-[#17181b] border border-[#292a2f] flex items-center justify-between shadow-sm">
          <div>
            <span className="text-[12px] text-[#8a8d93] font-medium block mb-1">
              Máy khối &amp; Cáp lực
            </span>
            <span className="text-[26px] font-bold text-[#bfaaff] tracking-tight font-mono">
              {machinesCount}
            </span>
          </div>
          <div className="w-11 h-11 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-center text-[#9b7bff]">
            <span className="material-symbols-outlined text-[22px]">precision_manufacturing</span>
          </div>
        </div>

        <div className="p-4 rounded-2xl bg-[#17181b] border border-[#292a2f] flex items-center justify-between shadow-sm">
          <div>
            <span className="text-[12px] text-[#8a8d93] font-medium block mb-1">
              Thể trọng &amp; Bổ trợ
            </span>
            <span className="text-[26px] font-bold text-[#35c76f] tracking-tight font-mono">
              {bodyweightCount}
            </span>
          </div>
          <div className="w-11 h-11 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-center text-[#35c76f]">
            <span className="material-symbols-outlined text-[22px]">accessibility_new</span>
          </div>
        </div>
      </div>

      {/* Filter Bar */}
      <EquipmentFilterBar
        filters={filters}
        onChange={setFilters}
        totalCount={totalCount}
        activeCount={activeCount}
      />

      {/* Main Content: Table or Grid */}
      {filters.viewMode === 'table' ? (
        <EquipmentTable
          equipments={filteredEquipments}
          selectedId={selectedEquipment?.id ?? null}
          onSelect={handleSelectEquipment}
        />
      ) : (
        <EquipmentCardGrid
          equipments={filteredEquipments}
          selectedId={selectedEquipment?.id ?? null}
          onSelect={handleSelectEquipment}
        />
      )}

      {/* Detail & Edit Modal */}
      <EquipmentModal
        isOpen={isModalOpen}
        equipment={selectedEquipment}
        onClose={handleCloseModal}
        onSave={handleSaveEquipment}
        onDelete={handleDeleteEquipment}
      />
    </div>
  )
}
