export type ExerciseLevel = 'beginner' | 'intermediate' | 'advanced'
export type ExerciseStatus = 'active' | 'hidden'

export interface ExerciseStep {
  id: string
  stepNumber: number
  title: string
  description: string
}

export interface ExerciseMediaItem {
  id: string
  type: 'image' | 'video'
  url: string
  name: string
  isCover?: boolean
  sizeInfo?: string
  status: 'synced' | 'pending' | 'error'
}

export interface ExerciseItem {
  id: string
  code: string
  nameVn: string
  nameEn: string
  primaryMuscle: string
  secondaryMuscles: string[]
  equipment: string[]
  level: ExerciseLevel
  status: ExerciseStatus
  updatedAt: string
  thumbnailUrl: string
  description: string
  steps: ExerciseStep[]
  media: ExerciseMediaItem[]
  version?: number
  slug?: string
}

export interface ExerciseFilterState {
  search: string
  muscle: string
  equipment: string
  level: string
  status: string
}
