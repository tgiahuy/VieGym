import React, { useState } from 'react'
import { NavLink } from 'react-router-dom'
import { useAuth } from '../../core/auth'

interface AdminSidebarProps {
  onItemClick?: () => void
}

export const AdminSidebar: React.FC<AdminSidebarProps> = ({ onItemClick }) => {
  const { user, logout } = useAuth()
  const [isLoggingOut, setIsLoggingOut] = useState(false)

  const handleLogout = async () => {
    if (window.confirm('Bạn có chắc chắn muốn đăng xuất khỏi phiên làm việc quản trị?')) {
      try {
        setIsLoggingOut(true)
        await logout()
      } finally {
        setIsLoggingOut(false)
      }
    }
  }

  const navLinkClass = ({ isActive }: { isActive: boolean }) =>
    `relative flex items-center gap-3 px-3 py-2 rounded-lg transition-colors duration-150 ${
      isActive
        ? 'bg-[rgba(242,48,90,0.12)] text-[#f5f5f6] font-semibold border-l-[3px] border-[#ff506d]'
        : 'text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#1c1d21]'
    }`

  return (
    <aside className="h-screen w-64 flex flex-col justify-between bg-[#17181b] border-r border-[#292a2f] select-none shrink-0">
      {/* Top Part: Logo & Navigation Clusters */}
      <div className="flex flex-col flex-1 overflow-y-auto">
        {/* Brand Logo Header */}
        <div className="h-16 flex items-center justify-between px-5 border-b border-[#292a2f] shrink-0">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-[rgba(242,48,90,0.12)] border border-[#f2305a]/30 flex items-center justify-center text-[#ff506d] shadow-sm">
              <span className="material-symbols-outlined text-xl">fitness_center</span>
            </div>
            <div className="flex flex-col">
              <div className="flex items-center gap-1.5">
                <span className="text-[14px] font-bold tracking-tight text-[#f5f5f6]">
                  VIEGYM ADMIN
                </span>
              </div>
              <span className="text-[10px] text-[#8a8d93] uppercase tracking-wider">
                Enterprise Console
              </span>
            </div>
          </div>
          <span className="px-1.5 py-0.5 rounded text-[10px] font-semibold bg-[#222327] text-[#a7a9ae] border border-[#292a2f]">
            v1.0
          </span>
        </div>

        {/* Nav Clusters */}
        <nav className="flex-1 px-3 py-4 space-y-5">
            {/* NHÓM: TỔNG QUAN */}
            <div>
              <div className="px-3 pb-1.5 text-[11px] font-semibold uppercase tracking-wider text-[#8a8d93]">
                TỔNG QUAN
              </div>
              <div className="space-y-1">
                <NavLink to="/dashboard" className={navLinkClass} onClick={onItemClick}>
                  <span className="material-symbols-outlined text-[#ff506d] text-xl">
                    dashboard
                  </span>
                  <span className="text-[14px]">Dashboard</span>
                </NavLink>
              </div>
            </div>

            {/* NHÓM: DỮ LIỆU */}
            <div>
              <div className="px-3 pb-1.5 text-[11px] font-semibold uppercase tracking-wider text-[#8a8d93]">
                DỮ LIỆU
              </div>
              <div className="space-y-1">
                <NavLink to="/exercises" className={navLinkClass} onClick={onItemClick}>
                  <span className="material-symbols-outlined text-xl">fitness_center</span>
                  <span className="text-[14px]">Bài tập</span>
                </NavLink>
                <NavLink to="/equipments" className={navLinkClass} onClick={onItemClick}>
                  <span className="material-symbols-outlined text-xl">exercise</span>
                  <span className="text-[14px]">Thiết bị</span>
                </NavLink>
                <NavLink to="/workout-plans" className={navLinkClass} onClick={onItemClick}>
                  <span className="material-symbols-outlined text-xl">menu_book</span>
                  <span className="text-[14px]">Giáo án</span>
                </NavLink>
                <NavLink to="/foods" className={navLinkClass} onClick={onItemClick}>
                  <span className="material-symbols-outlined text-xl">restaurant</span>
                  <span className="text-[14px]">Thực phẩm</span>
                </NavLink>
                <NavLink to="/imports" className={navLinkClass} onClick={onItemClick}>
                  <span className="material-symbols-outlined text-xl">upload_file</span>
                  <span className="text-[14px]">Nhập dữ liệu</span>
                </NavLink>
              </div>
            </div>

            {/* NHÓM: VẬN HÀNH */}
            <div>
              <div className="px-3 pb-1.5 text-[11px] font-semibold uppercase tracking-wider text-[#8a8d93]">
                VẬN HÀNH
              </div>
              <div className="space-y-1">
                <NavLink to="/users" className={navLinkClass} onClick={onItemClick}>
                  <span className="material-symbols-outlined text-xl">group</span>
                  <span className="text-[14px]">Người dùng</span>
                </NavLink>
                <NavLink to="/ai-config" className={navLinkClass} onClick={onItemClick}>
                  <div className="flex items-center justify-between w-full">
                    <div className="flex items-center gap-3">
                      <span className="material-symbols-outlined text-[#9b7bff] text-xl">smart_toy</span>
                      <span className="text-[14px]">Quy tắc &amp; AI</span>
                    </div>
                    <span className="px-1.5 py-0.5 rounded text-[10px] font-semibold bg-[#4f28ae]/40 text-[#9b7bff] border border-[#9b7bff]/20">
                      v3.4
                    </span>
                  </div>
                </NavLink>
                <NavLink to="/audit-logs" className={navLinkClass} onClick={onItemClick}>
                  <span className="material-symbols-outlined text-xl">receipt_long</span>
                  <span className="text-[14px]">Nhật ký</span>
                </NavLink>
                <NavLink to="/settings" className={navLinkClass} onClick={onItemClick}>
                  <span className="material-symbols-outlined text-xl">settings</span>
                  <span className="text-[14px]">Cấu hình hệ thống</span>
                </NavLink>
              </div>
            </div>
          </nav>
        </div>

        {/* Bottom User Identity & Logout Footers */}
        <div className="p-3 border-t border-[#292a2f] bg-[#17181b] shrink-0">
          <div className="flex items-center justify-between p-2 rounded-xl bg-[#222327] border border-[#292a2f]">
            <div className="flex items-center gap-2.5 min-w-0">
              <div className="relative w-8 h-8 rounded-full overflow-hidden bg-[#1f2022] shrink-0 border border-[#34363b] flex items-center justify-center">
                <span className="material-symbols-outlined text-[#8a8d93] text-[20px]">person</span>
              </div>
              <div className="flex flex-col min-w-0">
                <span className="text-xs font-semibold text-[#f5f5f6] truncate">
                  {user?.email || 'admin@viegym.com'}
                </span>
                <div className="flex items-center gap-1.5">
                  <span className="px-1.5 py-0.5 rounded text-[9px] font-bold bg-[#f2305a]/20 text-[#ff506d] uppercase tracking-wider">
                    {user?.role || 'ADMIN'}
                  </span>
                  <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
                </div>
              </div>
            </div>
            <button
              type="button"
              disabled={isLoggingOut}
              onClick={() => void handleLogout()}
              className="p-1.5 rounded-lg text-[#8a8d93] hover:text-[#ff5a5f] hover:bg-[#1c1d21] transition-colors duration-150 cursor-pointer disabled:opacity-50"
              title="Đăng xuất"
            >
              <span className="material-symbols-outlined text-lg">logout</span>
            </button>
          </div>
        </div>
      </aside>
  )
}
