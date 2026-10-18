import { apiClient } from '../../core/api/client'
import { exerciseApi } from './api'

vi.mock('../../core/api/client', () => ({
  apiClient: vi.fn(),
}))

const exercise = (id: number) => ({
  id,
  name: `Bài tập ${id}`,
  slug: `bai-tap-${id}`,
  difficulty: 'BEGINNER',
  description: `Mô tả ${id}`,
  instructionSteps: [],
  visibility: 'PUBLIC',
  muscleGroups: [],
  equipment: [],
  version: 1,
  updatedAt: '2026-10-11T00:00:00Z',
})

describe('exerciseApi.list', () => {
  it('loads every backend page so the exercise total is complete', async () => {
    const firstPageItems = Array.from({ length: 500 }, (_, index) => exercise(index + 1))
    const secondPageItems = [exercise(501), exercise(502)]

    vi.mocked(apiClient)
      .mockResolvedValueOnce({
        content: firstPageItems,
        totalElements: 502,
        page: 0,
        size: 500,
        totalPages: 2,
        hasNext: true,
      })
      .mockResolvedValueOnce({
        content: secondPageItems,
        totalElements: 502,
        page: 1,
        size: 500,
        totalPages: 2,
        hasNext: false,
      })

    const result = await exerciseApi.list()

    expect(result).toHaveLength(502)
    expect(result.at(-1)?.id).toBe('502')
    expect(apiClient).toHaveBeenNthCalledWith(1, '/admin/exercises?page=0&size=500')
    expect(apiClient).toHaveBeenNthCalledWith(2, '/admin/exercises?page=1&size=500')
  })
})
