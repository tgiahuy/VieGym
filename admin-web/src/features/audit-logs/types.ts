export type AuditAction =
  | 'CREATE'
  | 'UPDATE'
  | 'DELETE'
  | 'LOCK'
  | 'HIDE'
  | 'PUBLISH'
  | 'AUTH'

export type AuditTargetType =
  | 'FOOD'
  | 'EXERCISE'
  | 'USER'
  | 'RULE'
  | 'PROMPT'
  | 'SYSTEM'

export type AuditResultStatus = 'SUCCESS' | 'WARNING' | 'FAILED'

export interface AuditDiffField {
  fieldName: string
  colorDot?: string
  beforeValue: string
  afterValue: string
  deltaBadge?: string
  isRedacted?: boolean
}

export interface AuditLogItem {
  id: string
  eventId: string // e.g. "EVT-89241"
  timestamp: string // e.g. "03/10/2026 10:30:12"
  isoTimestamp: string
  actor: {
    name: string
    email: string
    role: 'ADMIN' | 'SYSTEM' | 'AI' | 'USER'
    avatarLabel: string
    sessionId?: string
  }
  action: AuditAction
  actionDesc: string
  targetType: AuditTargetType
  targetId: string // e.g. "#FD-0284"
  targetName: string // e.g. "Ức gà phi lê không da"
  resultStatus: AuditResultStatus
  resultMessage: string
  httpStatus?: string
  latencyMs?: number
  ipAddress: string
  clientInfo: string
  protocol?: string
  correlationId: string // e.g. "req-94a1f8c2-3e7b-4b11-a90c-88bf12d90e21"
  diffFields?: AuditDiffField[]
  rawPayload?: Record<string, unknown>
}

export interface AuditFilterState {
  dateRange: string // 'ALL' | '24H' | '7D' | '30D' | '90D'
  actor: string // 'ALL' | 'ADMIN' | 'SYSTEM' | 'AI'
  action: string // 'ALL' | 'CREATE' | 'UPDATE' | 'DELETE' | 'LOCK' | 'HIDE' | 'PUBLISH'
  targetType: string // 'ALL' | 'FOOD' | 'EXERCISE' | 'USER' | 'RULE' | 'PROMPT'
  resultStatus: string // 'ALL' | 'SUCCESS' | 'WARNING' | 'FAILED'
  search: string // target ID or correlation ID
}
