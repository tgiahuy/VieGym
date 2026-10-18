import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { vi } from 'vitest'
import { AuthProvider } from '../../../core/auth'
import { DashboardPage } from './DashboardPage'

vi.mock('../../ai-rules/api', () => ({
  aiRulesApi: {
    metrics: vi.fn(async () => ({
      provider: 'openai', model: 'test-model', serviceReachable: true,
      requests24h: 10, succeeded24h: 9, failed24h: 1, blocked24h: 0,
      averageLatencyMs: 640, warnings: [],
    })),
  },
}))

describe('DashboardPage', () => {
  const renderDashboard = () => render(<AuthProvider><MemoryRouter><DashboardPage /></MemoryRouter></AuthProvider>)

  it('renders page header and filter controls', async () => {
    renderDashboard()
    expect(await screen.findByRole('heading', { level: 1, name: 'Dashboard' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '7 ngày' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '30 ngày' })).toBeInTheDocument()
  })

  it('renders all 4 main KPI metric cards', async () => {
    renderDashboard()
    expect(await screen.findByText('NHẬT KÝ & VẬN HÀNH')).toBeInTheDocument()
    expect(screen.getByText('BÀI TẬP VẬN ĐỘNG')).toBeInTheDocument()
    expect(screen.getByText('THỰC PHẨM & DINH DƯỠNG')).toBeInTheDocument()
    expect(screen.getByText('THIẾT BỊ & DANH MỤC')).toBeInTheDocument()
  })

  it('shows missing activity telemetry explicitly', async () => {
    renderDashboard()
    expect(await screen.findByText('Chưa có endpoint cung cấp dữ liệu hoạt động theo ngày')).toBeInTheDocument()
  })

  it('renders real AI telemetry', async () => {
    renderDashboard()
    expect(await screen.findByRole('heading', { level: 2, name: 'AI Outcome & Recommendations' })).toBeInTheDocument()
    expect(await screen.findByText('Latency: 640 ms')).toBeInTheDocument()
  })
})
