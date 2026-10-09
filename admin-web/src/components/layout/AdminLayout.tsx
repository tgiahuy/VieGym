import React, { useState } from 'react'
import { Outlet } from 'react-router-dom'
import { AdminHeader } from './AdminHeader'
import { AdminSidebar } from './AdminSidebar'

export const AdminLayout: React.FC = () => {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)

  return (
    <div className="bg-[#0f1012] text-[#f5f5f6] antialiased min-h-screen flex selection:bg-[#f2305a] selection:text-white">
      {/* 1. Desktop Fixed Sidebar (w-64 = 256px) - Always visible on md and up */}
      <div className="hidden md:block fixed top-0 left-0 h-screen w-64 z-40">
        <AdminSidebar />
      </div>

      {/* Mobile Drawer Sidebar (< md) */}
      {isMobileMenuOpen && (
        <div
          className="md:hidden fixed inset-0 z-50 flex bg-black/70 backdrop-blur-sm animate-fadeIn"
          onClick={() => setIsMobileMenuOpen(false)}
        >
          <div
            className="w-72 h-full bg-[#17181b] z-50 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            <AdminSidebar onItemClick={() => setIsMobileMenuOpen(false)} />
          </div>
        </div>
      )}

      {/* 2. Main Workspace Container (Offset 256px on md+) */}
      <div className="flex-1 flex flex-col md:ml-64 min-w-0 bg-[#0f1012] min-h-screen">
        <AdminHeader onToggleMobileMenu={() => setIsMobileMenuOpen(!isMobileMenuOpen)} />
        <main className="flex-1 w-full max-w-[1600px] mx-auto p-4 sm:p-6 lg:p-8 space-y-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}
