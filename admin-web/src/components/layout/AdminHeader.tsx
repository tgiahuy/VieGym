import React, { useState } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'

interface AdminHeaderProps {
  onToggleMobileMenu?: () => void
}

export const AdminHeader: React.FC<AdminHeaderProps> = ({ onToggleMobileMenu }) => {
  const location = useLocation()
  const navigate = useNavigate()

  const [isNotificationOpen, setIsNotificationOpen] = useState(false)
  const [isHelpOpen, setIsHelpOpen] = useState(false)

  // Map route to breadcrumb name
  const getBreadcrumbTitle = (pathname: string) => {
    switch (pathname) {
      case '/dashboard':
      case '/':
        return 'Dashboard'
      case '/exercises':
        return 'Bài tập vận động'
      case '/workout-plans':
        return 'Giáo án tập luyện'
      case '/foods':
        return 'Thực phẩm & Dinh dưỡng'
      case '/imports':
        return 'Nhập dữ liệu'
      case '/users':
        return 'Quản trị Người dùng'
      case '/ai-config':
        return 'Quy tắc & Mô hình AI'
      case '/audit-logs':
        return 'Nhật ký kiểm toán'
      case '/settings':
        return 'Cấu hình hệ thống'
      default:
        return 'Quản trị'
    }
  }

  return (
    <header className="sticky top-0 right-0 w-full h-16 bg-[#17181b]/90 backdrop-blur-md border-b border-[#292a2f] flex items-center justify-between px-4 sm:px-8 z-30 select-none">
      {/* Left: Mobile Toggle & Breadcrumbs */}
      <div className="flex items-center gap-3 text-[14px]">
        {/* Mobile Hamburger */}
        <button
          type="button"
          onClick={onToggleMobileMenu}
          className="lg:hidden p-2 rounded-lg text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#222327] transition-colors"
          aria-label="Mở menu"
        >
          <span className="material-symbols-outlined text-[24px]">menu</span>
        </button>

        <div className="flex items-center gap-2">
          <span
            onClick={() => navigate('/dashboard')}
            className="text-[#8a8d93] hover:text-[#a7a9ae] transition-colors cursor-pointer hidden sm:inline"
          >
            Tổng quan
          </span>
          <span className="text-[#8a8d93] hidden sm:inline">/</span>
          <span className="font-semibold text-[#f5f5f6]">
            {getBreadcrumbTitle(location.pathname)}
          </span>
        </div>
      </div>

      {/* Right Header Indicators & Status */}
      <div className="flex items-center gap-3 sm:gap-5">
        {/* Live System Telemetry Status Badges */}
        <div className="hidden lg:flex items-center gap-3">
          {/* Backend Status */}
          <div className="flex items-center gap-2 px-2.5 py-1 rounded-full bg-[#222327] border border-[#292a2f]">
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-[#35c76f] opacity-75" />
              <span className="relative inline-flex rounded-full h-2 w-2 bg-[#35c76f]" />
            </span>
            <span className="text-xs text-[#a7a9ae] font-medium">
              Backend: <span className="text-[#35c76f] font-semibold">Online</span>
            </span>
            <span className="font-mono text-[11px] text-[#8a8d93]">(12ms)</span>
          </div>

          {/* AI Engine Status */}
          <div className="flex items-center gap-2 px-2.5 py-1 rounded-full bg-[#222327] border border-[#292a2f]">
            <span className="relative inline-flex rounded-full h-2 w-2 bg-[#9b7bff]" />
            <span className="text-xs text-[#a7a9ae] font-medium">
              AI Engine v3.4: <span className="text-[#9b7bff] font-semibold">Online</span>
            </span>
          </div>
        </div>

        <div className="h-5 w-[1px] bg-[#292a2f] hidden sm:block" />

        {/* Quick Notifications & Actions */}
        <div className="flex items-center gap-1 sm:gap-2 relative">
          {/* Notifications Trigger */}
          <button
            type="button"
            onClick={() => {
              setIsNotificationOpen(!isNotificationOpen)
              setIsHelpOpen(false)
            }}
            className="relative p-2 rounded-lg text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#222327] transition-colors cursor-pointer"
            title="Thông báo hệ thống"
          >
            <span className="material-symbols-outlined text-xl">notifications</span>
            <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full bg-[#f2305a]" />
          </button>

          {/* Notification Flyout */}
          {isNotificationOpen && (
            <div className="absolute top-12 right-0 w-80 bg-[#17181b] border border-[#292a2f] rounded-xl shadow-2xl p-4 z-50 animate-fadeIn">
              <div className="flex items-center justify-between pb-2 border-b border-[#292a2f] mb-3">
                <span className="text-[13px] font-bold text-[#f5f5f6]">Thông báo vận hành</span>
                <span className="text-[10px] bg-[#f2305a]/20 text-[#ff506d] px-1.5 py-0.5 rounded font-semibold">
                  3 mới
                </span>
              </div>
              <div className="space-y-2 text-[12px]">
                <div className="p-2 rounded-lg bg-[#222327] border border-[#292a2f]">
                  <p className="text-[#f5f5f6] font-semibold">18 thực phẩm thiếu macro</p>
                  <p className="text-[11px] text-[#8a8d93]">Cần cập nhật calo/protein chuẩn.</p>
                </div>
                <div className="p-2 rounded-lg bg-[#222327] border border-[#292a2f]">
                  <p className="text-[#f5f5f6] font-semibold">7 media bài tập lỗi CDN</p>
                  <p className="text-[11px] text-[#8a8d93]">Đang chờ đồng bộ hóa lại.</p>
                </div>
              </div>
            </div>
          )}

          {/* Help Trigger */}
          <button
            type="button"
            onClick={() => {
              setIsHelpOpen(!isHelpOpen)
              setIsNotificationOpen(false)
            }}
            className="p-2 rounded-lg text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#222327] transition-colors cursor-pointer"
            title="Tài liệu API & Giúp đỡ"
          >
            <span className="material-symbols-outlined text-xl">help_outline</span>
          </button>

          {/* Help Flyout */}
          {isHelpOpen && (
            <div className="absolute top-12 right-0 w-72 bg-[#17181b] border border-[#292a2f] rounded-xl shadow-2xl p-4 z-50 animate-fadeIn">
              <span className="text-[13px] font-bold text-[#f5f5f6] block mb-2">Hỗ trợ quản trị</span>
              <p className="text-[12px] text-[#8a8d93] leading-relaxed mb-3">
                Hotline NOC: <strong className="text-[#f5f5f6]">1900-VIE-ADMIN</strong>
                <br />
                Email: <span className="text-[#ff506d]">sysadmin@viegym.com</span>
              </p>
              <a
                href="/docs"
                target="_blank"
                rel="noreferrer"
                className="text-[12px] text-[#4d8dff] hover:underline flex items-center gap-1 font-semibold"
              >
                <span>Xem tài liệu Swagger / OpenAPI</span>
                <span className="material-symbols-outlined text-sm">open_in_new</span>
              </a>
            </div>
          )}
        </div>
      </div>
    </header>
  )
}
