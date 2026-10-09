import { render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { AuthProvider } from '../../../core/auth'
import { DashboardPage } from './DashboardPage'

describe('DashboardPage', () => {
  const renderDashboard = () =>
    render(
      <AuthProvider>
        <MemoryRouter>
          <DashboardPage />
        </MemoryRouter>
      </AuthProvider>
    )

  it('renders page header and filter controls', async () => {
    renderDashboard()

    expect(await screen.findByRole('heading', { level: 1, name: 'Dashboard' })).toBeInTheDocument()
    expect(
      screen.getByText(/tổng quan hoạt động hệ thống và tình trạng vận hành nền tảng/i)
    ).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '7 ngày' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '30 ngày' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: '90 ngày' })).toBeInTheDocument()
    expect(screen.getByRole('button', { name: 'Tùy chỉnh' })).toBeInTheDocument()
  })

  it('renders all 4 main KPI metric cards', async () => {
    renderDashboard()

    expect(await screen.findByText('NHẬT KÝ & VẬN HÀNH')).toBeInTheDocument()
    expect(screen.getByText('BÀI TẬP VẬN ĐỘNG')).toBeInTheDocument()
    expect(screen.getByText('THỰC PHẨM & DINH DƯỠNG')).toBeInTheDocument()
    expect(screen.getByText('THIẾT BỊ & DANH MỤC')).toBeInTheDocument()
  })

  it('renders daily activity chart and alerts widget', async () => {
    renderDashboard()

    expect(
      await screen.findByRole('heading', { level: 2, name: 'Hoạt động theo ngày' })
    ).toBeInTheDocument()
    expect(
      screen.getByRole('heading', { level: 2, name: 'Cảnh báo dữ liệu & Vận hành' })
    ).toBeInTheDocument()
    expect(screen.getByText('CSRF & RBAC:')).toBeInTheDocument()
  })

  it('renders adherence progress and AI outcome recommendations', async () => {
    renderDashboard()

    expect(
      await screen.findByRole('heading', { level: 2, name: 'Phân bổ danh mục & Tuân thủ dữ liệu' })
    ).toBeInTheDocument()
    expect(
      screen.getByRole('heading', { level: 2, name: 'AI Outcome & Recommendations' })
    ).toBeInTheDocument()
    expect(screen.getByText('Latency: 3.4s')).toBeInTheDocument()
  })
})

