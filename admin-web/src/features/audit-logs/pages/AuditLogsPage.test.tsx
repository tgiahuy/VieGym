import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { AuditLogsPage } from './AuditLogsPage'

describe('AuditLogsPage', () => {
  it('renders audit logs header, telemetry cards, and log entries', () => {
    render(<AuditLogsPage />)

    expect(screen.getByRole('heading', { level: 1, name: 'Nhật ký kiểm toán' })).toBeInTheDocument()
    expect(screen.getByText(/Chuỗi khối bất biến/i)).toBeInTheDocument()
    expect(screen.getByText('14,285')).toBeInTheDocument()
    expect(screen.getByText('#FD-0284')).toBeInTheDocument()
    expect(screen.getByText(/Ức gà phi lê không da/i)).toBeInTheDocument()
    expect(screen.getByText(/Đẩy ngực ngang đòn tạ/i)).toBeInTheDocument()
  })

  it('filters audit records by search input', () => {
    render(<AuditLogsPage />)

    const searchInput = screen.getByPlaceholderText(/Target ID/i)
    fireEvent.change(searchInput, { target: { value: '#EX-0104' } })

    expect(screen.getByText(/Đẩy ngực ngang đòn tạ/i)).toBeInTheDocument()
    expect(screen.queryByText(/Khoai lang vàng luộc/i)).not.toBeInTheDocument()
  })

  it('opens audit detail drawer when clicking a log entry', () => {
    render(<AuditLogsPage />)

    const logRow = screen.getByText(/Ức gà phi lê không da/i)
    fireEvent.click(logRow)

    expect(screen.getByText('Chi tiết sự kiện kiểm toán')).toBeInTheDocument()
    expect(screen.getAllByText(/EVT-89241/i)[0]).toBeInTheDocument()
    expect(screen.getByText(/Bảng so sánh thay đổi giá trị/i)).toBeInTheDocument()
    expect(
      screen.getAllByText(/req-94a1f8c2-3e7b-4b11-a90c-88bf12d90e21/i)[0]
    ).toBeInTheDocument()
  })
})
