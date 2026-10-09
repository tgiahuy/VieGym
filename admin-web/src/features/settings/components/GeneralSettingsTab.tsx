import React from 'react'
import { GeneralSettings } from '../types'

interface GeneralSettingsTabProps {
  data: GeneralSettings
  onChange: (fields: Partial<GeneralSettings>) => void
}

export const GeneralSettingsTab: React.FC<GeneralSettingsTabProps> = ({ data, onChange }) => {
  return (
    <div className="space-y-6">
      {/* Platform Branding Card */}
      <div className="p-6 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-5">
        <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
          <div>
            <h3 className="text-base font-bold text-[#f5f5f6]">Thông tin nền tảng &amp; Thương hiệu</h3>
            <p className="text-xs text-[#8a8d93] mt-0.5">Tên hiển thị và các liên kết công khai của hệ thống</p>
          </div>
          <span className="material-symbols-outlined text-[#ff506d] text-2xl">domain</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Tên hệ thống (System Name)</label>
            <input
              type="text"
              value={data.systemName}
              onChange={(e) => onChange({ systemName: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="VD: VieGym Enterprise Platform"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Tên miền chính (Site URL)</label>
            <input
              type="url"
              value={data.siteUrl}
              onChange={(e) => onChange({ siteUrl: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="https://viegym.vn"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">API Gateway Base URL</label>
            <input
              type="url"
              value={data.apiBaseUrl}
              onChange={(e) => onChange({ apiBaseUrl: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="https://api.viegym.vn/v1"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Email liên hệ hỗ trợ (Support Email)</label>
            <input
              type="email"
              value={data.supportEmail}
              onChange={(e) => onChange({ supportEmail: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="hotro@viegym.vn"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Hotline điều hành kỹ thuật</label>
            <input
              type="text"
              value={data.hotline}
              onChange={(e) => onChange({ hotline: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="1900-VIE-ADMIN"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Múi giờ máy chủ (Timezone)</label>
            <select
              value={data.timezone}
              onChange={(e) => onChange({ timezone: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d] cursor-pointer"
            >
              <option value="Asia/Ho_Chi_Minh (UTC+07:00)">Asia/Ho_Chi_Minh (UTC+07:00)</option>
              <option value="Asia/Bangkok (UTC+07:00)">Asia/Bangkok (UTC+07:00)</option>
              <option value="Asia/Singapore (UTC+08:00)">Asia/Singapore (UTC+08:00)</option>
              <option value="UTC (UTC+00:00)">UTC (UTC+00:00)</option>
            </select>
          </div>
        </div>
      </div>

      {/* Maintenance Mode Card */}
      <div className={`p-6 rounded-2xl border transition-all ${
        data.maintenanceMode
          ? 'bg-[#ff5a5f]/5 border-[#ff5a5f]/40'
          : 'bg-[#17181b] border-[#292a2f]'
      }`}>
        <div className="flex items-start justify-between gap-4">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className={`material-symbols-outlined text-xl ${
                data.maintenanceMode ? 'text-[#ff5a5f]' : 'text-[#8a8d93]'
              }`}>
                construction
              </span>
              <h3 className="text-base font-bold text-[#f5f5f6]">Chế độ bảo trì toàn hệ thống (Maintenance Mode)</h3>
            </div>
            <p className="text-xs text-[#a7a9ae] leading-relaxed max-w-2xl">
              Khi kích hoạt, toàn bộ ứng dụng người dùng và huấn luyện viên sẽ tạm dừng truy cập và chuyển sang trang thông báo bảo trì. Tài khoản Quản trị viên vẫn có thể truy cập Web Admin bình thường.
            </p>
          </div>

          {/* Switch toggle */}
          <label className="relative inline-flex items-center cursor-pointer shrink-0 mt-1">
            <input
              type="checkbox"
              checked={data.maintenanceMode}
              onChange={(e) => onChange({ maintenanceMode: e.target.checked })}
              className="sr-only peer"
            />
            <div className="w-12 h-6 bg-[#222327] border border-[#34363b] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-[#8a8d93] peer-checked:after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#ff5a5f]" />
          </label>
        </div>

        {data.maintenanceMode && (
          <div className="mt-4 pt-4 border-t border-[#ff5a5f]/20 space-y-2 animate-in fade-in">
            <label className="text-xs font-semibold text-[#ff5a5f]">Thông điệp bảo trì hiển thị trên App / Web</label>
            <textarea
              rows={3}
              value={data.maintenanceMessage}
              onChange={(e) => onChange({ maintenanceMessage: e.target.value })}
              className="w-full p-3 rounded-xl bg-[#222327] border border-[#ff5a5f]/40 text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff5a5f]"
              placeholder="Nhập thông điệp bảo trì..."
            />
          </div>
        )}
      </div>
    </div>
  )
}
