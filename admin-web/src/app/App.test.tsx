import { render, screen, waitFor } from '@testing-library/react'
import { vi } from 'vitest'
import { authApi } from '../core/auth/authApi'
import { App } from './App'

describe('App', () => {
  beforeEach(() => {
    vi.spyOn(authApi, 'getSession').mockResolvedValue({
      admin: {
        id: 1,
        email: 'admin@viegym.com',
        role: 'ADMIN',
      },
      csrfToken: 'mock-csrf-token',
      expiresIn: 900,
    })
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('renders the admin shell with navigation sidebar and dashboard', async () => {
    render(<App />)

    await waitFor(() => {
      expect(screen.getByRole('heading', { level: 1, name: 'Dashboard' })).toBeInTheDocument()
    })

    expect(screen.getByText('VIEGYM ADMIN')).toBeInTheDocument()
    expect(screen.getByText('Tổng quan hoạt động hệ thống và tình trạng vận hành nền tảng')).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /bài tập/i })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /thiết bị/i })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /giáo án/i })).toBeInTheDocument()
    expect(screen.getByRole('link', { name: /thực phẩm/i })).toBeInTheDocument()
  })
})
