export type WorkoutPlanLevel = 'beginner' | 'intermediate' | 'advanced' | 'all'

export type WorkoutPlanGoal =
  | 'hypertrophy'
  | 'strength'
  | 'fat_loss'
  | 'endurance'
  | 'general_fitness'

export type WorkoutPlanStatus = 'active' | 'draft' | 'archived'

export interface WorkoutPlanExercise {
  id: string
  exerciseId: string
  exerciseCode: string
  nameVn: string
  nameEn: string
  primaryMuscle: string
  thumbnailUrl?: string
  sets: number
  reps: string
  restSeconds: number
  rpe?: number
  tempo?: string
  notes?: string
}

export interface WorkoutPlanDay {
  id: string
  dayNumber: number
  name: string
  description?: string
  targetMuscles: string[]
  exercises: WorkoutPlanExercise[]
}

export interface WorkoutPlan {
  id: string
  code: string
  title: string
  description: string
  goal: WorkoutPlanGoal
  level: WorkoutPlanLevel
  daysPerWeek: number
  durationWeeks: number
  status: WorkoutPlanStatus
  author: string
  tags: string[]
  estimatedDurationMin: number
  days: WorkoutPlanDay[]
  createdAt: string
  updatedAt: string
  coverImageUrl?: string
}

export interface WorkoutPlanFilterState {
  search: string
  goal: string
  level: string
  daysPerWeek: string
  status: string
}
