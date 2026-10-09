import { apiClient } from '../../core/api/client'
import { initialWorkoutPlans } from './mockData'
import type {
  WorkoutPlan,
  WorkoutPlanDay,
  WorkoutPlanExercise,
  WorkoutPlanGoal,
  WorkoutPlanLevel,
  WorkoutPlanStatus,
} from './types'

interface BackendScheduleExercise {
  exerciseId: number
  exerciseName: string
  primaryMuscle: string
  sortOrder: number
  targetSets: number
  targetRepsMin?: number
  targetRepsMax?: number
  targetDurationSeconds?: number
  restSeconds: number
  note?: string
}

interface BackendTemplateDay {
  id: number
  dayNumber: number
  name: string
  note?: string
  exercises: BackendScheduleExercise[]
}

interface BackendWorkoutTemplate {
  id: number
  name: string
  programType: string
  description?: string
  difficulty?: string
  goal?: string
  status: string
  version: number
  days: BackendTemplateDay[]
}

const mapGoal = (goal?: string): WorkoutPlanGoal => {
  const g = (goal || '').toLowerCase()
  if (['hypertrophy', 'strength', 'fat_loss', 'endurance', 'general_fitness'].includes(g)) {
    return g as WorkoutPlanGoal
  }
  return 'hypertrophy'
}

const mapLevel = (level?: string): WorkoutPlanLevel => {
  const l = (level || '').toLowerCase()
  if (['beginner', 'intermediate', 'advanced', 'all'].includes(l)) {
    return l as WorkoutPlanLevel
  }
  return 'intermediate'
}

const mapStatus = (status: string): WorkoutPlanStatus => {
  if (status === 'PUBLISHED') return 'active'
  if (status === 'ARCHIVED') return 'archived'
  return 'draft'
}

const map = (item: BackendWorkoutTemplate): WorkoutPlan => {
  const goal = mapGoal(item.goal)
  const level = mapLevel(item.difficulty)
  const status = mapStatus(item.status)

  const days: WorkoutPlanDay[] = (item.days || []).map((d) => {
    const exercises: WorkoutPlanExercise[] = (d.exercises || []).map((ex) => {
      const reps =
        ex.targetRepsMin && ex.targetRepsMax && ex.targetRepsMin !== ex.targetRepsMax
          ? `${ex.targetRepsMin}-${ex.targetRepsMax}`
          : String(ex.targetRepsMin || ex.targetRepsMax || 10)

      return {
        id: `ex-${ex.exerciseId}-${ex.sortOrder}`,
        exerciseId: String(ex.exerciseId),
        exerciseCode: `EX-${String(ex.exerciseId).padStart(4, '0')}`,
        nameVn: ex.exerciseName || `Bài tập #${ex.exerciseId}`,
        nameEn: ex.exerciseName || `Exercise #${ex.exerciseId}`,
        primaryMuscle: ex.primaryMuscle || 'Toàn thân',
        sets: ex.targetSets || 3,
        reps,
        restSeconds: ex.restSeconds || 60,
        notes: ex.note || '',
      }
    })

    const targetMuscles = Array.from(new Set(exercises.map((e) => e.primaryMuscle).filter(Boolean)))

    return {
      id: `day-${d.id || d.dayNumber}`,
      dayNumber: d.dayNumber,
      name: d.name,
      description: d.note || '',
      targetMuscles: targetMuscles.length > 0 ? targetMuscles : ['Toàn thân'],
      exercises,
    }
  })

  return {
    id: String(item.id),
    code: `PLN-${String(item.id).padStart(4, '0')}`,
    title: item.name,
    description: item.description || 'Giáo án tập luyện chuẩn hóa hệ thống VieGym',
    goal,
    level,
    daysPerWeek: days.length || 3,
    durationWeeks: 8,
    status,
    author: 'VieGym Master Coach',
    tags: [item.programType || 'CUSTOM', item.difficulty || 'Mọi cấp độ'],
    estimatedDurationMin: 60,
    days,
    createdAt: 'Hôm nay',
    updatedAt: 'Mới cập nhật',
  }
}

const payload = (item: WorkoutPlan) => {
  const programType =
    item.days.length === 3 ? 'PPL' : item.days.length === 4 ? 'UPPER_LOWER' : item.days.length <= 2 ? 'FULL_BODY' : 'CUSTOM'

  const status = item.status === 'active' ? 'PUBLISHED' : item.status === 'archived' ? 'ARCHIVED' : 'DRAFT'

  return {
    name: item.title.trim(),
    programType,
    description: item.description || item.title,
    difficulty: (item.level || 'intermediate').toUpperCase(),
    goal: (item.goal || 'hypertrophy').toUpperCase(),
    status,
    days: item.days.map((d, dIdx) => ({
      dayNumber: d.dayNumber || (dIdx + 1),
      name: d.name || `Buổi ${dIdx + 1}`,
      note: d.description || '',
      exercises: (d.exercises || []).map((ex, exIdx) => {
        const repsMatch = ex.reps.match(/(\d+)\s*-\s*(\d+)/) || ex.reps.match(/(\d+)/)
        const repsMin = repsMatch ? Number(repsMatch[1]) : 10
        const repsMax = repsMatch && repsMatch[2] ? Number(repsMatch[2]) : repsMin

        const digits = String(ex.exerciseId).replace(/\D/g, '')
        const parsedId = digits ? Number(digits) : Number(ex.exerciseId)
        return {
          exerciseId: Number.isFinite(parsedId) && parsedId > 0 ? parsedId : 121,
          exerciseName: ex.nameVn || 'Bài tập',
          primaryMuscle: ex.primaryMuscle || 'CHEST',
          sortOrder: exIdx + 1,
          targetSets: ex.sets || 3,
          targetRepsMin: repsMin,
          targetRepsMax: repsMax,
          targetDurationSeconds: null,
          restSeconds: ex.restSeconds ?? 60,
          note: ex.notes || '',
        }
      }),
    })),
  }
}

export const workoutPlanApi = {
  async list(): Promise<WorkoutPlan[]> {
    try {
      const data = await apiClient<BackendWorkoutTemplate[]>('/admin/workout-program-templates')
      if (Array.isArray(data) && data.length > 0) {
        return data.map(map)
      }
      return initialWorkoutPlans
    } catch {
      return initialWorkoutPlans
    }
  },

  async save(plan: WorkoutPlan): Promise<WorkoutPlan> {
    const isEditing = /^\d+$/.test(plan.id)
    const endpoint = isEditing ? `/admin/workout-program-templates/${plan.id}` : '/admin/workout-program-templates'
    const method = isEditing ? 'PUT' : 'POST'

    const res = await apiClient<BackendWorkoutTemplate>(endpoint, {
      method,
      csrfRequired: true,
      body: JSON.stringify(payload(plan)),
    })
    return map(res)
  },

  async remove(id: string): Promise<void> {
    if (!/^\d+$/.test(id)) return
    try {
      await apiClient(`/admin/workout-program-templates/${id}`, {
        method: 'DELETE',
        csrfRequired: true,
      })
    } catch {
      // Ignore if mock or already deleted
    }
  },
}
