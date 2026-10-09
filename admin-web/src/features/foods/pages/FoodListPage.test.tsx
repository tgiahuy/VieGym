import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { FoodListPage } from './FoodListPage'

describe('FoodListPage', () => {
  it('renders food page header, metrics, and data table', () => {
    render(<FoodListPage />)

    expect(screen.getByRole('heading', { level: 1, name: 'Thực phẩm' })).toBeInTheDocument()
    expect(screen.getByText('Ức gà phi lê không da')).toBeInTheDocument()
    expect(screen.getByText('Cơm trắng nấu chín')).toBeInTheDocument()
    expect(screen.getByText('Trứng gà ta nguyên quả')).toBeInTheDocument()
    expect(screen.getByText('Cá hồi Nauy fillet')).toBeInTheDocument()
  })

  it('filters food items by search text', () => {
    render(<FoodListPage />)

    const searchInput = screen.getByPlaceholderText('Tìm tên món ăn hoặc nguyên liệu...')
    fireEvent.change(searchInput, { target: { value: 'Ức gà' } })

    expect(screen.getByText('Ức gà phi lê không da')).toBeInTheDocument()
    expect(screen.queryByText('Cơm trắng nấu chín')).not.toBeInTheDocument()
  })

  it('opens create modal when clicking + Thêm thực phẩm', () => {
    render(<FoodListPage />)

    const addButton = screen.getByRole('button', { name: /\+ Thêm thực phẩm/i })
    fireEvent.click(addButton)

    expect(screen.getByText('Thêm thực phẩm mới')).toBeInTheDocument()
    expect(screen.getByText('1. Nhận diện thực phẩm')).toBeInTheDocument()
    expect(screen.getByText('2. Khẩu phần chuẩn')).toBeInTheDocument()
    expect(screen.getByText(/3\. Giá trị dinh dưỡng/i)).toBeInTheDocument()
  })

  it('opens edit modal when clicking a food item', () => {
    render(<FoodListPage />)

    const foodTitle = screen.getByText('Ức gà phi lê không da')
    fireEvent.click(foodTitle)

    expect(screen.getByText('Chỉnh sửa thực phẩm')).toBeInTheDocument()
    expect(screen.getByDisplayValue('Ức gà phi lê không da')).toBeInTheDocument()
  })
})
