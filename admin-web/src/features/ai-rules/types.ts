export type PromptUseCase =
  | 'WORKOUT_ENGINE'
  | 'NUTRITION_ENGINE'
  | 'CHAT_COACH'
  | 'SAFETY_FILTER'

export type PromptStatus = 'production' | 'review' | 'draft' | 'archived'

export interface PromptTemplateItem {
  id: string
  code: string // e.g. "PRM-0082"
  useCase: PromptUseCase
  useCaseLabel: string
  title: string
  description: string
  version: string
  status: PromptStatus
  model: string
  fallbackModel: string
  content: string
  updatedAt: string
  author: string
  tokensEstimate: number
  contextWindowPct: number
}

export interface AllowlistVariable {
  tag: string
  typeDesc: string
  color: string
}

export interface SafetyRuleItem {
  id: string
  code: string
  name: string
  category: 'clinical' | 'equipment' | 'intensity' | 'pii'
  severity: 'critical' | 'warning' | 'info'
  description: string
  action: string
  isActive: boolean
}

export interface AiMetricItem {
  name: string
  value: string
  change: string
  isPositive: boolean
  description: string
}
