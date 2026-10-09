import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { ExerciseListPage } from './ExerciseListPage'

describe('ExerciseListPage', () => {
  const renderExerciseListPage = () =>
    render(
      <MemoryRouter>
        <ExerciseListPage />
      </MemoryRouter>
    )

  it('renders page header, actions and filter controls', () => {
    renderExerciseListPage()

    expect(screen.getByRole('heading', { level: 1, name: 'Bài tập' })).toBeInTheDocument()
    expect(
      screen.getByText('Quản lý kho bài tập dùng trong lịch tập và mô hình AI huấn luyện')
    ).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /\+ thêm bài tập/i })).toBeInTheDocument()
    expect(screen.getByPlaceholderText(/tìm tên vn\/en/i)).toBeInTheDocument()
  })

  it('renders exercise table with items and badges', () => {
    renderExerciseListPage()

    expect(screen.getByText('Đẩy ngực tạ đòn')).toBeInTheDocument()
    expect(screen.getByText('Barbell Bench Press')).toBeInTheDocument()
    expect(screen.getByText('EX-0104')).toBeInTheDocument()
    expect(screen.getByText('Squat gánh tạ đòn')).toBeInTheDocument()
  })

  it('filters exercises by search text', async () => {
    const user = userEvent.setup()
    renderExerciseListPage()

    const searchInput = screen.getByPlaceholderText(/tìm tên vn\/en/i)
    await user.type(searchInput, 'Squat')

    expect(screen.getByText('Squat gánh tạ đòn')).toBeInTheDocument()
    expect(screen.queryByText('Đẩy ngực tạ đòn')).not.toBeInTheDocument()
  })

  it('opens and closes drawer when clicking + Thêm bài tập', async () => {
    const user = userEvent.setup()
    renderExerciseListPage()

    const addBtn = screen.getByRole('button', { name: /\+ thêm bài tập/i })
    await user.click(addBtn)

    expect(screen.getByRole('heading', { level: 2, name: 'Thêm bài tập mới' })).toBeInTheDocument()
    expect(screen.getByText('Thông tin cơ bản')).toBeInTheDocument()
    expect(screen.getByText('Hướng dẫn & an toàn')).toBeInTheDocument()
    expect(screen.getByText('Media')).toBeInTheDocument()

    const cancelBtn = screen.getByRole('button', { name: 'Hủy' })
    await user.click(cancelBtn)

    expect(screen.queryByRole('heading', { level: 2, name: 'Thêm bài tập mới' })).not.toBeInTheDocument()
  })

  it('opens edit modal on exercise row click and allows deleting exercise', async () => {
    const user = userEvent.setup()
    renderExerciseListPage()

    const exerciseRow = screen.getByText('Đẩy ngực tạ đòn')
    await user.click(exerciseRow)

    expect(screen.getByRole('heading', { level: 2, name: 'Chỉnh sửa bài tập' })).toBeInTheDocument()
    const deleteBtn = screen.getByRole('button', { name: /xóa bài tập/i })
    expect(deleteBtn).toBeInTheDocument()
  })
})
