import { render, screen, fireEvent } from '@testing-library/react'
import { EquipmentListPage } from './EquipmentListPage'

describe('EquipmentListPage', () => {
  it('renders equipment list page with KPI cards and table header', () => {
    render(<EquipmentListPage />)

    expect(screen.getByRole('heading', { level: 1, name: 'Thiết bị' })).toBeInTheDocument()
    expect(screen.getByText('Tổng số thiết bị')).toBeInTheDocument()
    expect(screen.getAllByText('Tạ tự do (Free Weights)').length).toBeGreaterThan(0)
    expect(screen.getAllByText('Máy khối & Cáp lực').length).toBeGreaterThan(0)
    expect(screen.getByText('Thể trọng & Bổ trợ')).toBeInTheDocument()

    // Table rows
    expect(screen.getByText('Tạ đơn')).toBeInTheDocument()
    expect(screen.getByText('Tạ đòn')).toBeInTheDocument()
    expect(screen.getByText('Trọng lượng cơ thể')).toBeInTheDocument()
    expect(screen.getByText('Máy cáp')).toBeInTheDocument()
  })

  it('filters equipment list when searching by keyword', () => {
    render(<EquipmentListPage />)

    const searchInput = screen.getByPlaceholderText(/tìm theo tên thiết bị/i)
    fireEvent.change(searchInput, { target: { value: 'Tạ đơn' } })

    expect(screen.getByText('Tạ đơn')).toBeInTheDocument()
    expect(screen.queryByText('Máy chạy bộ')).not.toBeInTheDocument()
  })

  it('switches between table view and grid card view', () => {
    render(<EquipmentListPage />)

    const gridButton = screen.getByTitle('Xem dạng lưới thẻ')
    fireEvent.click(gridButton)

    // In grid view, "bài tập" count appears in cards
    expect(screen.getAllByText(/bài tập/i).length).toBeGreaterThan(0)

    const tableButton = screen.getByTitle('Xem dạng bảng')
    fireEvent.click(tableButton)

    expect(screen.getByText('Số bài tập liên kết')).toBeInTheDocument()
  })

  it('opens detail and edit modal when clicking a table row', () => {
    render(<EquipmentListPage />)

    const dumbbellRow = screen.getByText('Tạ đơn')
    fireEvent.click(dumbbellRow)

    expect(screen.getByText('Chi tiết & Chỉnh sửa thiết bị')).toBeInTheDocument()
    expect(screen.getByDisplayValue('Tạ đơn')).toBeInTheDocument()
    expect(screen.getByDisplayValue('DUMBBELL')).toBeInTheDocument()

    const cancelBtn = screen.getByRole('button', { name: 'Hủy' })
    fireEvent.click(cancelBtn)

    expect(screen.queryByText('Chi tiết & Chỉnh sửa thiết bị')).not.toBeInTheDocument()
  })

  it('opens create modal when clicking Thêm thiết bị button and can create new equipment', () => {
    render(<EquipmentListPage />)

    const addBtn = screen.getByRole('button', { name: /thêm thiết bị/i })
    fireEvent.click(addBtn)

    expect(screen.getByText('Thêm thiết bị tập luyện mới')).toBeInTheDocument()

    const nameInput = screen.getByPlaceholderText(/ví dụ: tạ đơn/i)
    fireEvent.change(nameInput, { target: { value: 'Bóng tập thể lực' } })

    const buttons = screen.getAllByRole('button', { name: /thêm thiết bị/i })
    const submitBtn = buttons[buttons.length - 1]
    expect(submitBtn).toBeDefined()
    if (submitBtn) {
      fireEvent.click(submitBtn)
    }

    expect(screen.queryByText('Thêm thiết bị tập luyện mới')).not.toBeInTheDocument()
    expect(screen.getByText('Bóng tập thể lực')).toBeInTheDocument()
  })
})
