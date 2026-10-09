import { fireEvent, render, screen } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it, vi } from 'vitest'
import { BulkImportPage } from './BulkImportPage'

// Mock createObjectURL & revokeObjectURL
window.URL.createObjectURL = vi.fn(() => 'blob:mock-url')
window.URL.revokeObjectURL = vi.fn()

describe('BulkImportPage (MH48)', () => {
  it('renders Step 2 Mapping & Validation header and KPIs properly', () => {
    render(
      <MemoryRouter>
        <BulkImportPage />
      </MemoryRouter>
    )

    // Header & Tag
    expect(screen.getByText('Nhập dữ liệu hàng loạt')).toBeInTheDocument()
    expect(screen.getByText('MH48')).toBeInTheDocument()

    // File name
    expect(screen.getByText('exercises_viegym_batch_v2.csv')).toBeInTheDocument()

    // KPIs
    expect(screen.getByText('Tổng số dòng')).toBeInTheDocument()
    expect(screen.getByText('48')).toBeInTheDocument()
    expect(screen.getAllByText('Hợp lệ').length).toBeGreaterThan(0)
    expect(screen.getByText('42')).toBeInTheDocument()
    expect(screen.getAllByText('Cảnh báo').length).toBeGreaterThan(0)
    expect(screen.getAllByText('4').length).toBeGreaterThan(0)
    expect(screen.getByText('Lỗi cấu trúc')).toBeInTheDocument()
    expect(screen.getAllByText('2').length).toBeGreaterThan(0)
  })

  it('filters table rows when clicking segmented filter pills', () => {
    render(
      <MemoryRouter>
        <BulkImportPage />
      </MemoryRouter>
    )

    // Initially "Tất cả (48)" is selected
    expect(screen.getByText('Hít đất kim cương')).toBeInTheDocument()

    // Filter "Chỉ hiện lỗi & cảnh báo (6)"
    const errorFilterBtn = screen.getByRole('button', {
      name: /Chỉ hiện lỗi & cảnh báo/i,
    })
    fireEvent.click(errorFilterBtn)

    // Should still show warning/error row
    expect(screen.getByText('Kéo xà đơn ngửa tay')).toBeInTheDocument()
    expect(screen.getByText('Cử tạ giật Olympic')).toBeInTheDocument()

    // Filter "Hợp lệ (42)"
    const validFilterBtn = screen.getByRole('button', { name: /Hợp lệ \(42\)/i })
    fireEvent.click(validFilterBtn)
    expect(screen.getByText('Hít đất kim cương')).toBeInTheDocument()
  })

  it('allows selecting different conflict resolution strategies', () => {
    render(
      <MemoryRouter>
        <BulkImportPage />
      </MemoryRouter>
    )

    const skipOption = screen.getByText(/Bỏ qua \(Skip duplicates\)/i)
    fireEvent.click(skipOption)
    expect(skipOption).toBeInTheDocument()

    const rollbackOption = screen.getByText(/Dừng toàn bộ \(Rollback Atomic\)/i)
    fireEvent.click(rollbackOption)
    expect(rollbackOption).toBeInTheDocument()
  })

  it('opens and closes History and Schema modals', () => {
    render(
      <MemoryRouter>
        <BulkImportPage />
      </MemoryRouter>
    )

    // History Modal
    const historyBtn = screen.getByRole('button', { name: /Lịch sử nhập dữ liệu/i })
    fireEvent.click(historyBtn)
    expect(
      screen.getByText('Lịch sử nhập dữ liệu (Import History)')
    ).toBeInTheDocument()

    const closeBtn = screen.getByText('Đóng')
    fireEvent.click(closeBtn)
    expect(
      screen.queryByText('Lịch sử nhập dữ liệu (Import History)')
    ).not.toBeInTheDocument()

    // Schema Modal
    const schemaBtn = screen.getByRole('button', { name: /Quy tắc schema/i })
    fireEvent.click(schemaBtn)
    expect(
      screen.getByText('Quy tắc Schema & Định dạng dữ liệu chuẩn')
    ).toBeInTheDocument()
  })

  it('navigates through the 4-step wizard workflow', async () => {
    render(
      <MemoryRouter>
        <BulkImportPage />
      </MemoryRouter>
    )

    // In step 2, click "Tiếp tục: Xác nhận ghi dữ liệu"
    const nextBtn = screen.getByRole('button', {
      name: /Tiếp tục: Xác nhận ghi dữ liệu/i,
    })
    fireEvent.click(nextBtn)

    // Now in Step 3
    expect(
      screen.getByText('Xác nhận ghi dữ liệu vào cơ sở dữ liệu VieGym')
    ).toBeInTheDocument()

    // Click commit batch
    const commitBtn = screen.getByRole('button', {
      name: /Tiến hành ghi dữ liệu/i,
    })
    fireEvent.click(commitBtn)
  })
})
