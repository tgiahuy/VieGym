import { apiClient } from '../../core/api/client'
import type { AiMetrics, PromptTemplateItem, PromptUseCase, SafetyRuleItem } from './types'

interface PromptDto {
  id: number
  code: string
  useCase: PromptUseCase
  title: string
  description: string
  version: string
  status: PromptTemplateItem['status']
  model: string
  fallbackModel: string | null
  content: string
  draftRevision: number
  updatedAt: string
  author: string
}

interface SafetyRuleDto {
  id: number
  code: string
  name: string
  category: SafetyRuleItem['category']
  severity: SafetyRuleItem['severity']
  description: string
  action: string
  active: boolean
  version: number
}

const mapPrompt = (item: PromptDto): PromptTemplateItem => ({
  id: String(item.id),
  code: item.code,
  useCase: item.useCase,
  useCaseLabel: item.useCase,
  title: item.title,
  description: item.description,
  version: item.version,
  status: item.status,
  model: item.model,
  fallbackModel: item.fallbackModel || 'Không cấu hình',
  content: item.content,
  updatedAt: new Date(item.updatedAt).toLocaleString('vi-VN'),
  author: item.author,
  tokensEstimate: Math.ceil(item.content.length / 4),
  contextWindowPct: Math.round((item.content.length / (128_000 * 4)) * 10_000) / 100,
  draftRevision: item.draftRevision,
})

const mapRule = (item: SafetyRuleDto): SafetyRuleItem => ({
  id: String(item.id),
  code: item.code,
  name: item.name,
  category: item.category,
  severity: item.severity,
  description: item.description,
  action: item.action,
  isActive: item.active,
  version: item.version,
})

export const aiRulesApi = {
  async listPrompts(): Promise<PromptTemplateItem[]> {
    return (await apiClient<PromptDto[]>('/admin/ai-config/prompts')).map(mapPrompt)
  },

  async createPrompt(input: Omit<PromptTemplateItem, 'id' | 'updatedAt' | 'author' | 'tokensEstimate' | 'contextWindowPct' | 'draftRevision' | 'status' | 'version'>): Promise<PromptTemplateItem> {
    return mapPrompt(await apiClient<PromptDto>('/admin/ai-config/prompts', {
      method: 'POST',
      csrfRequired: true,
      body: JSON.stringify(input),
    }))
  },

  async saveDraft(template: PromptTemplateItem, content: string): Promise<PromptTemplateItem> {
    return mapPrompt(await apiClient<PromptDto>(`/admin/ai-config/prompts/${template.id}/draft`, {
      method: 'PUT',
      csrfRequired: true,
      body: JSON.stringify({ content, expectedRevision: template.draftRevision }),
    }))
  },

  async publish(template: PromptTemplateItem): Promise<PromptTemplateItem> {
    return mapPrompt(await apiClient<PromptDto>(`/admin/ai-config/prompts/${template.id}/publish`, {
      method: 'POST',
      csrfRequired: true,
      body: JSON.stringify({ expectedRevision: template.draftRevision }),
    }))
  },

  async listSafetyRules(): Promise<SafetyRuleItem[]> {
    return (await apiClient<SafetyRuleDto[]>('/admin/ai-config/safety-rules')).map(mapRule)
  },

  async updateSafetyRule(rule: SafetyRuleItem, active: boolean): Promise<SafetyRuleItem> {
    return mapRule(await apiClient<SafetyRuleDto>(`/admin/ai-config/safety-rules/${rule.id}`, {
      method: 'PATCH',
      csrfRequired: true,
      body: JSON.stringify({ active, expectedVersion: rule.version }),
    }))
  },

  metrics(): Promise<AiMetrics> {
    return apiClient<AiMetrics>('/admin/ai-config/metrics')
  },
}
