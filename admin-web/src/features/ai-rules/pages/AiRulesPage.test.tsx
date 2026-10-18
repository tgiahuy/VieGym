import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it, vi } from 'vitest'
import { INITIAL_TEMPLATES, SAFETY_RULES } from '../mockData'
import { AiRulesPage } from './AiRulesPage'

vi.mock('../api', () => ({
  aiRulesApi: {
    listPrompts: vi.fn(async () => INITIAL_TEMPLATES),
    listSafetyRules: vi.fn(async () => SAFETY_RULES),
    metrics: vi.fn(async () => ({
      provider: 'openai', model: 'test-model', serviceReachable: true,
      requests24h: 10, succeeded24h: 9, failed24h: 1, blocked24h: 0,
      averageLatencyMs: 640, warnings: [],
    })),
  },
}))

describe('AiRulesPage', () => {
  it('renders AI rules page header, tabs, and prompt editor', async () => {
    render(<AiRulesPage />)

    expect(await screen.findByRole('heading', { level: 1, name: /Quy tắc & Mô hình AI/i })).toBeInTheDocument()
    expect(screen.getByText('MH50')).toBeInTheDocument()
    expect(screen.getAllByText(/Workout Planner — Gợi ý giáo án cá nhân hóa/i)[0]).toBeInTheDocument()
    expect(screen.getByText('Claude 3.5 Sonnet', { exact: false })).toBeInTheDocument()
    expect(screen.getByText(/Biến hệ thống được phép/i)).toBeInTheDocument()
  })

  it('switches between safety rules and live AI metrics', async () => {
    render(<AiRulesPage />)
    await screen.findByRole('heading', { level: 1, name: /Quy tắc & Mô hình AI/i })

    fireEvent.click(screen.getByRole('button', { name: /Quy tắc an toàn/i }))
    expect(screen.getByText(/Danh mục Quy tắc an toàn Y tế & Giới hạn sinh học/i)).toBeInTheDocument()
    expect(await screen.findByText(/SAFE-001/i)).toBeInTheDocument()

    fireEvent.click(screen.getByRole('button', { name: /Chỉ số AI/i }))
    expect(await screen.findByText(/Yêu cầu AI/i)).toBeInTheDocument()
    expect(screen.getByText('640 ms')).toBeInTheDocument()
  })

  it('opens Sandbox Test modal', async () => {
    render(<AiRulesPage />)
    fireEvent.click(await screen.findByRole('button', { name: /Sandbox Test/i }))
    expect(screen.getByText(/AI Sandbox Simulator/i)).toBeInTheDocument()
  })

  it('opens Diff Compare modal', async () => {
    render(<AiRulesPage />)
    fireEvent.click(await screen.findByRole('button', { name: /So sánh Diff/i }))
    expect(screen.getByText(/Lịch sử triển khai prompt/i)).toBeInTheDocument()
  })
})
