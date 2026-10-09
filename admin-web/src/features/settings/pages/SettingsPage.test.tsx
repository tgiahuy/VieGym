import { fireEvent, render, screen } from '@testing-library/react'
import { describe, expect, it } from 'vitest'
import { SettingsPage } from './SettingsPage'

describe('SettingsPage', () => {
  it('renders settings page header and default General tab', () => {
    render(<SettingsPage />)

    expect(screen.getByRole('heading', { level: 1, name: 'Cấu hình hệ thống' })).toBeInTheDocument()
    expect(screen.getByText('Thông tin nền tảng & Thương hiệu')).toBeInTheDocument()
    expect(screen.getByDisplayValue('VieGym Enterprise Platform')).toBeInTheDocument()
    expect(screen.getByDisplayValue('https://viegym.vn')).toBeInTheDocument()
  })

  it('switches between tabs properly', () => {
    render(<SettingsPage />)

    // Switch to Security Tab
    const securityTab = screen.getByRole('button', { name: /Bảo mật & Phiên làm việc/i })
    fireEvent.click(securityTab)
    expect(screen.getByText('Chính sách Phiên làm việc & Xác thực')).toBeInTheDocument()
    expect(screen.getByText('Mạng lưới & CORS Whitelist')).toBeInTheDocument()

    // Switch to Storage Tab
    const storageTab = screen.getByRole('button', { name: /Lưu trữ CDN & S3/i })
    fireEvent.click(storageTab)
    expect(screen.getByText('Mạng phân phối CDN & Object Storage (S3)')).toBeInTheDocument()
    expect(screen.getByDisplayValue('viegym-media-prod-ap-southeast-1')).toBeInTheDocument()

    // Switch to Notifications Tab
    const notifyTab = screen.getByRole('button', { name: /Thông báo & SMS/i })
    fireEvent.click(notifyTab)
    expect(screen.getByText('Dịch vụ Email Giao dịch (SMTP Relay)')).toBeInTheDocument()
    expect(screen.getByDisplayValue('smtp.sendgrid.net')).toBeInTheDocument()

    // Switch to Backup Tab
    const backupTab = screen.getByRole('button', { name: /Sao lưu & Dữ liệu/i })
    fireEvent.click(backupTab)
    expect(screen.getByText('Chính sách Tự động Sao lưu Cơ sở dữ liệu')).toBeInTheDocument()
    expect(screen.getByText('Lịch sử các bản sao lưu gần nhất')).toBeInTheDocument()
  })

  it('updates form fields and allows saving changes', () => {
    render(<SettingsPage />)

    const systemNameInput = screen.getByDisplayValue('VieGym Enterprise Platform')
    fireEvent.change(systemNameInput, { target: { value: 'VieGym NextGen' } })

    expect(screen.getByDisplayValue('VieGym NextGen')).toBeInTheDocument()
    expect(screen.getByText('Lưu thay đổi *')).toBeInTheDocument()

    const saveBtn = screen.getByText('Lưu thay đổi *')
    fireEvent.click(saveBtn)
  })
})
