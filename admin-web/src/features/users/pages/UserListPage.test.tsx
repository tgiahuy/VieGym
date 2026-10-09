import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { UserListPage } from './UserListPage'

describe('UserListPage', () => {
  it('renders user management header, stats, and users table', () => {
    render(<UserListPage />)

    expect(screen.getByRole('heading', { level: 1, name: 'Người dùng' })).toBeInTheDocument()
    expect(screen.getByText('Minh Anh')).toBeInTheDocument()
    expect(screen.getByText('Tuấn Hùng HLV')).toBeInTheDocument()
    expect(screen.getByText('Đức Đăng')).toBeInTheDocument()
    expect(screen.getByText('Lan Phương Admin')).toBeInTheDocument()
  })

  it('filters users by search query', () => {
    render(<UserListPage />)

    const searchInput = screen.getByPlaceholderText('Email hoặc nickname...')
    fireEvent.change(searchInput, { target: { value: 'Tuấn Hùng' } })

    expect(screen.getByText('Tuấn Hùng HLV')).toBeInTheDocument()
    expect(screen.queryByText('Minh Anh')).not.toBeInTheDocument()
  })

  it('opens user detail drawer when clicking a row', () => {
    render(<UserListPage />)

    const userRow = screen.getByText('Minh Anh')
    fireEvent.click(userRow)

    expect(screen.getByText('Chi tiết tài khoản')).toBeInTheDocument()
    expect(screen.getByText(/minh\.anh\.le94@gmail\.com/i)).toBeInTheDocument()
    expect(screen.getByText('ADR-008')).toBeInTheDocument()
  })

  it('opens invite modal when clicking + Mời quản trị viên', () => {
    render(<UserListPage />)

    const inviteBtn = screen.getByRole('button', { name: /\+ Mời quản trị viên/i })
    fireEvent.click(inviteBtn)

    expect(screen.getByText('Mời tài khoản quản trị')).toBeInTheDocument()
    expect(screen.getByPlaceholderText('VD: alex.nguyen@viegym.internal')).toBeInTheDocument()
  })
})
