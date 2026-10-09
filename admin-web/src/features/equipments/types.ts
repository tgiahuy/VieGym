export type EquipmentCategory =
  | 'free_weights'
  | 'machines'
  | 'bodyweight'
  | 'accessories'
  | 'cardio'

export type EquipmentStatus = 'active' | 'inactive'

export interface EquipmentItem {
  id: number
  code: string
  name: string
  nameEn: string
  category: EquipmentCategory
  categoryLabel: string
  description: string
  iconName: string
  status: EquipmentStatus
  suitableFor: string
  safetyNotes: string
  exerciseCount: number
  isCommon: boolean
  updatedAt: string
}

export interface EquipmentFilterState {
  search: string
  category: string
  status: string
  viewMode: 'table' | 'grid'
}
