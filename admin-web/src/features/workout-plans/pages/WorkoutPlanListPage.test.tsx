import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { describe, expect, it } from 'vitest'
import { WorkoutPlanListPage } from './WorkoutPlanListPage'

describe('WorkoutPlanListPage', () => {
  const renderWorkoutPlanListPage = () =>
    render(
      <MemoryRouter>
        <WorkoutPlanListPage />
      </MemoryRouter>
    )

  it('renders page header, actions and statistics cards', () => {
    renderWorkoutPlanListPage()

    expect(screen.getByRole('heading', { level: 1, name: 'Giáo án' })).toBeInTheDocument()
    expect(
      screen.getByText(/biên soạn và quản lý giáo án tập luyện từ kho bài tập/i)
    ).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /\+ tạo giáo án mới/i })).toBeInTheDocument()
    expect(screen.getByPlaceholderText(/tìm tên giáo án, mã, thẻ tag/i)).toBeInTheDocument()
    expect(screen.getByText('Tổng số giáo án')).toBeInTheDocument()
  })

  it('renders table with existing workout plans and their days', () => {
    renderWorkoutPlanListPage()

    expect(screen.getByText(/Giáo án Đẩy - Kéo - Chân 4 Buổi Chuyên Sâu/i)).toBeInTheDocument()
    expect(screen.getByText('PL-0201')).toBeInTheDocument()
    expect(screen.getByText(/Tăng cơ bắp/i)).toBeInTheDocument()
    expect(screen.getByText(/Giáo án Toàn Thân 3 Buổi Cho Người Mới Bắt Đầu/i)).toBeInTheDocument()
  })

  it('filters workout plans by search text', async () => {
    const user = userEvent.setup()
    renderWorkoutPlanListPage()

    const searchInput = screen.getByPlaceholderText(/tìm tên giáo án, mã, thẻ tag/i)
    await user.type(searchInput, 'Toàn Thân')

    expect(screen.getByText(/Giáo án Toàn Thân 3 Buổi Cho Người Mới Bắt Đầu/i)).toBeInTheDocument()
    expect(
      screen.queryByText(/Giáo án Đẩy - Kéo - Chân 4 Buổi Chuyên Sâu/i)
    ).not.toBeInTheDocument()
  })

  it('opens and closes drawer when clicking + Tạo giáo án mới', async () => {
    const user = userEvent.setup()
    renderWorkoutPlanListPage()

    const createBtn = screen.getByRole('button', { name: /\+ tạo giáo án mới/i })
    await user.click(createBtn)

    expect(
      screen.getByRole('heading', { level: 2, name: 'Tạo mới giáo án tập luyện' })
    ).toBeInTheDocument()
    expect(screen.getByText('1. Thông tin chung')).toBeInTheDocument()
    expect(screen.getByText(/2. Lịch tập & Bài tập/i)).toBeInTheDocument()
    expect(screen.getByText('3. AI Phân tích & Khối lượng')).toBeInTheDocument()

    const cancelBtn = screen.getByRole('button', { name: 'Hủy' })
    await user.click(cancelBtn)

    expect(
      screen.queryByRole('heading', { level: 2, name: 'Tạo mới giáo án tập luyện' })
    ).not.toBeInTheDocument()
  })

  it('opens edit modal on workout plan row click and displays delete button', async () => {
    const user = userEvent.setup()
    renderWorkoutPlanListPage()

    const planRow = screen.getByText(/Giáo án Đẩy - Kéo - Chân 4 Buổi Chuyên Sâu/i)
    await user.click(planRow)

    expect(
      screen.getByRole('heading', { level: 2, name: 'Chỉnh sửa giáo án' })
    ).toBeInTheDocument()
    const deleteBtn = screen.getByRole('button', { name: /xóa giáo án/i })
    expect(deleteBtn).toBeInTheDocument()
  })

  it('updates days list in tab 2 when changing days per week in tab 1', async () => {
    const user = userEvent.setup()
    renderWorkoutPlanListPage()

    const createBtn = screen.getByRole('button', { name: /\+ tạo giáo án mới/i })
    await user.click(createBtn)

    const daysInput = screen.getByDisplayValue('4')
    await user.clear(daysInput)
    await user.type(daysInput, '5')

    const tab2Btn = screen.getByRole('button', { name: /2\. Lịch tập & Bài tập/i })
    await user.click(tab2Btn)

    expect(screen.getByRole('button', { name: /buổi 5/i })).toBeInTheDocument()
  })
})

