import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { AiRulesPage } from './AiRulesPage'

describe('AiRulesPage', () => {
  it('renders AI rules page header, tabs, and prompt editor', () => {
    render(<AiRulesPage />)

    expect(
      screen.getByRole('heading', { level: 1, name: /Quy tắc & Mô hình AI/i })
    ).toBeInTheDocument()
    expect(screen.getByText('MH50')).toBeInTheDocument()
    expect(
      screen.getAllByText(/Workout Planner — Gợi ý giáo án cá nhân hóa/i)[0]
    ).toBeInTheDocument()
    expect(screen.getByText('Claude 3.5 Sonnet', { exact: false })).toBeInTheDocument()
    expect(screen.getByText(/Biến hệ thống được phép/i)).toBeInTheDocument()
  })

  it('switches between tabs: Quy tắc an toàn and Chỉ số AI', () => {
    render(<AiRulesPage />)

    // Switch to Safety Rules tab
    const safetyTabBtn = screen.getByRole('button', { name: /Quy tắc an toàn/i })
    fireEvent.click(safetyTabBtn)
    expect(
      screen.getByText(/Danh mục Quy tắc an toàn Y tế & Giới hạn sinh học/i)
    ).toBeInTheDocument()
    expect(screen.getByText(/SAFE-001/i)).toBeInTheDocument()

    // Switch to AI Metrics tab
    const metricsTabBtn = screen.getByRole('button', { name: /Chỉ số AI/i })
    fireEvent.click(metricsTabBtn)
    expect(
      screen.getByText(/Độ khả dụng hệ thống AI/i)
    ).toBeInTheDocument()
    expect(screen.getByText('99.85%')).toBeInTheDocument()
  })

  it('opens Sandbox Test modal', () => {
    render(<AiRulesPage />)

    const sandboxBtn = screen.getByRole('button', { name: /Sandbox Test/i })
    fireEvent.click(sandboxBtn)

    expect(screen.getByText(/AI Sandbox Simulator/i)).toBeInTheDocument()
    expect(screen.getByText(/Chạy thử nghiệm Sandbox/i)).toBeInTheDocument()
  })

  it('opens Diff Compare modal', () => {
    render(<AiRulesPage />)

    const diffBtn = screen.getByRole('button', { name: /So sánh Diff/i })
    fireEvent.click(diffBtn)

    expect(screen.getByText(/So sánh bản cập nhật/i)).toBeInTheDocument()
  })
})
