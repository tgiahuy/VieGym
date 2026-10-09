import { apiClient } from '../../core/api/client'
import type { ExerciseItem, ExerciseLevel } from './types'

interface Page<T> { content: T[]; totalElements: number; page: number; size: number; totalPages: number; hasNext: boolean }
interface ExerciseDto { id:number; name:string; slug:string; difficulty:string; description:string; instructionSteps:string[]; visibility:string; muscleGroups:{muscleGroupId:number;role:string}[]; equipment:{equipmentId:number;required:boolean}[]; version:number; updatedAt:string }

const map = (item: ExerciseDto): ExerciseItem => ({
  id: String(item.id), code: `EX-${String(item.id).padStart(4, '0')}`, nameVn: item.name,
  nameEn: item.name, primaryMuscle: item.muscleGroups[0] ? String(item.muscleGroups[0].muscleGroupId) : '',
  secondaryMuscles: item.muscleGroups.slice(1).map((x) => String(x.muscleGroupId)),
  equipment: item.equipment.map((x) => String(x.equipmentId)), level: item.difficulty.toLowerCase() as ExerciseLevel,
  status: item.visibility === 'HIDDEN' ? 'hidden' : 'active', updatedAt: new Date(item.updatedAt).toLocaleString('vi-VN'),
  thumbnailUrl: '', description: item.description,
  steps: item.instructionSteps.map((description, index) => ({ id: `${item.id}-${index}`, stepNumber: index + 1, title: `Bước ${index + 1}`, description })),
  media: [], version: item.version, slug: item.slug,
})

const payload = (item: ExerciseItem) => ({
  name: item.nameVn, slug: item.slug ?? item.nameEn.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, ''), difficulty: item.level.toUpperCase(),
  description: item.description || item.nameVn, instructionSteps: item.steps.map((x) => x.description), commonMistakes: [], safetyNotes: [],
  visibility: item.status === 'hidden' ? 'HIDDEN' : 'PUBLIC',
  muscleGroups: [item.primaryMuscle, ...item.secondaryMuscles].map(Number).filter(Number.isFinite).map((muscleGroupId, index) => ({ muscleGroupId, role: index === 0 ? 'PRIMARY' : 'SECONDARY' })),
  equipment: item.equipment.map(Number).filter(Number.isFinite).map((equipmentId) => ({ equipmentId, required: true })), version: item.version,
})

export const exerciseApi = {
  async list(): Promise<ExerciseItem[]> { const page = await apiClient<Page<ExerciseDto>>('/admin/exercises?size=500'); return page.content.map(map) },
  async save(item: ExerciseItem): Promise<ExerciseItem> { const editing = /^\d+$/.test(item.id); return map(await apiClient<ExerciseDto>(editing ? `/admin/exercises/${item.id}` : '/admin/exercises', { method: editing ? 'PUT' : 'POST', csrfRequired: true, body: JSON.stringify(payload(item)) })) },
  async remove(id: string): Promise<void> { await apiClient(`/admin/exercises/${id}`, { method: 'DELETE', csrfRequired: true }) },
}
