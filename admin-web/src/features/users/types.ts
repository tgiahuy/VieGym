export type UserRole = 'USER' | 'TRAINER' | 'ADMIN'

export type UserStatus = 'ACTIVE' | 'LOCKED' | 'DISABLED'

export interface UserAuditLog {
  id: string
  title: string
  detail: string
  date: string
  timeAgo: string
  icon: string
  iconColor: string
}

export interface UserItem {
  id: string
  uuid: string
  code: string // e.g. "USR-84920"
  email: string
  maskedEmail: string
  nickname: string
  fullName: string
  initials: string
  role: UserRole
  status: UserStatus
  phone: string
  authMethod: string
  registeredAt: string
  lastLoginAt: string | null
  lastLoginIp?: string
  primaryDevice?: string
  activeSessionsCount: number
  activeSessionsDetail?: string
  planName?: string
  planExpiry?: string
  avatarUrl?: string
  auditLogs?: UserAuditLog[]
}

export interface UserFilterState {
  search: string
  role: string // 'ALL' | 'USER' | 'TRAINER' | 'ADMIN'
  status: string // 'ALL' | 'ACTIVE' | 'LOCKED' | 'DISABLED'
  dateRange: string // 'ALL' | '7D' | '30D'
}
