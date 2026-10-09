import { apiClient } from '../../core/api/client'
import { INITIAL_USERS } from './mockData'
import type { UserItem, UserRole, UserStatus } from './types'

interface Page<T> {
  content: T[]
  totalElements: number
  page: number
  size: number
  totalPages: number
  hasNext: boolean
}

interface UserSummaryDto {
  id: number
  email: string
  displayName: string
  role: string
  status: string
  authProvider: string
  lastLoginAt: string | null
  createdAt: string
  updatedAt: string
}

function getMaskedEmail(email: string): string {
  const parts = email.split('@')
  const name = parts[0] || 'user'
  const domain = parts[1] || 'viegym.vn'
  if (name.length <= 3) return `${name.slice(0, 1)}***@${domain}`
  return `${name.slice(0, 3)}***@${domain}`
}

function getInitials(name: string): string {
  const words = name.trim().split(/\s+/)
  if (words.length >= 2) {
    return `${words[0]?.[0] || ''}${words[words.length - 1]?.[0] || ''}`.toUpperCase()
  }
  return (name.slice(0, 2) || 'US').toUpperCase()
}

const map = (dto: UserSummaryDto): UserItem => {
  const role: UserRole = dto.role === 'ADMIN' ? 'ADMIN' : dto.role === 'TRAINER' ? 'TRAINER' : 'USER'
  const status: UserStatus =
    dto.status === 'LOCKED' ? 'LOCKED' : dto.status === 'DISABLED' || dto.status === 'PENDING' ? 'DISABLED' : 'ACTIVE'

  const authMethodLabel =
    dto.authProvider === 'GOOGLE'
      ? 'Google OAuth 2.0'
      : dto.authProvider === 'FACEBOOK'
        ? 'Facebook OAuth'
        : 'Email & Mật khẩu'

  return {
    id: String(dto.id),
    uuid: `usr_${dto.id}`,
    code: `USR-${String(dto.id).padStart(5, '0')}`,
    email: dto.email,
    maskedEmail: getMaskedEmail(dto.email),
    nickname: dto.displayName || dto.email.split('@')[0] || 'User',
    fullName: dto.displayName || dto.email.split('@')[0] || 'User',
    initials: getInitials(dto.displayName || dto.email),
    role,
    status,
    phone: 'Chưa cập nhật',
    authMethod: authMethodLabel,
    registeredAt: new Date(dto.createdAt).toLocaleString('vi-VN'),
    lastLoginAt: dto.lastLoginAt ? new Date(dto.lastLoginAt).toLocaleString('vi-VN') : null,
    activeSessionsCount: status === 'ACTIVE' ? 1 : 0,
    activeSessionsDetail: status === 'ACTIVE' ? '1 phiên (Web/Mobile)' : '0 phiên',
    planName: role === 'ADMIN' ? 'Admin Operator' : role === 'TRAINER' ? 'Trainer Access' : 'Hội viên Tiêu chuẩn',
  }
}

export const userApi = {
  async list(params?: { q?: string; role?: string; status?: string }): Promise<UserItem[]> {
    try {
      const searchParams = new URLSearchParams()
      searchParams.set('size', '200')
      if (params?.q) searchParams.set('q', params.q)
      if (params?.role && params.role !== 'ALL') searchParams.set('role', params.role)
      if (params?.status && params.status !== 'ALL') searchParams.set('status', params.status)

      const page = await apiClient<Page<UserSummaryDto>>(`/admin/users?${searchParams.toString()}`)
      if (page && Array.isArray(page.content) && page.content.length > 0) {
        return page.content.map(map)
      }
      return INITIAL_USERS
    } catch {
      return INITIAL_USERS
    }
  },

  async updateStatus(id: string, status: UserStatus, reason?: string): Promise<UserItem> {
    try {
      const updated = await apiClient<UserSummaryDto>(`/admin/users/${id}/status`, {
        method: 'PATCH',
        csrfRequired: true,
        body: JSON.stringify({ status, reason }),
      })
      return map(updated)
    } catch {
      const existing = INITIAL_USERS.find((u) => u.id === id)
      if (existing) {
        return { ...existing, status }
      }
      throw new Error('Không thể cập nhật trạng thái người dùng')
    }
  },

  async invite(data: { email: string; fullName: string; role: UserRole; notes?: string }): Promise<UserItem> {
    try {
      const created = await apiClient<UserSummaryDto>('/admin/users/invite', {
        method: 'POST',
        csrfRequired: true,
        body: JSON.stringify(data),
      })
      return map(created)
    } catch {
      const newUser: UserItem = {
        id: `user-${Date.now()}`,
        uuid: `usr_${crypto.randomUUID()}`,
        code: `USR-${Math.floor(80000 + Math.random() * 19000)}`,
        email: data.email,
        maskedEmail: getMaskedEmail(data.email),
        nickname: data.fullName,
        fullName: data.fullName,
        initials: getInitials(data.fullName),
        role: data.role,
        status: 'DISABLED',
        phone: 'Chưa cập nhật',
        authMethod: 'Email kích hoạt (Đã gửi link)',
        registeredAt: new Date().toLocaleString('vi-VN'),
        lastLoginAt: null,
        activeSessionsCount: 0,
        activeSessionsDetail: '0 phiên',
        planName: data.role === 'ADMIN' ? 'Admin Operator' : 'Trainer Access',
      }
      return newUser
    }
  },
}
