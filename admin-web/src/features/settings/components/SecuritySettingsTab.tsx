import React from 'react'
import { SecuritySettings } from '../types'

interface SecuritySettingsTabProps {
  data: SecuritySettings
  onChange: (fields: Partial<SecuritySettings>) => void
}

export const SecuritySettingsTab: React.FC<SecuritySettingsTabProps> = ({ data, onChange }) => {
  return (
    <div className="space-y-6">
      {/* Session & Authentication Policies */}
      <div className="p-6 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-5">
        <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
          <div>
            <h3 className="text-base font-bold text-[#f5f5f6]">Chính sách Phiên làm việc &amp; Xác thực</h3>
            <p className="text-xs text-[#8a8d93] mt-0.5">Quy định thời hạn token, số lần đăng nhập sai và phòng chống brute-force</p>
          </div>
          <span className="material-symbols-outlined text-[#35c76f] text-2xl">shield_lock</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Thời hạn JWT Token (Giờ)</label>
            <input
              type="number"
              min={1}
              max={720}
              value={data.jwtExpiryHours}
              onChange={(e) => onChange({ jwtExpiryHours: Number(e.target.value) || 1 })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
            <p className="text-[11px] text-[#8a8d93]">Khuyến nghị: 24h cho người dùng, 8h cho admin</p>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Đăng nhập sai tối đa (Lần)</label>
            <input
              type="number"
              min={3}
              max={10}
              value={data.maxLoginAttempts}
              onChange={(e) => onChange({ maxLoginAttempts: Number(e.target.value) || 3 })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
            <p className="text-[11px] text-[#8a8d93]">Tự động khóa tạm thời sau khi vượt ngưỡng</p>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Thời gian khóa tạm thời (Phút)</label>
            <input
              type="number"
              min={5}
              max={120}
              value={data.lockoutDurationMinutes}
              onChange={(e) => onChange({ lockoutDurationMinutes: Number(e.target.value) || 5 })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
            <p className="text-[11px] text-[#8a8d93]">Thời gian chờ trước khi được thử lại</p>
          </div>
        </div>

        {/* 2FA Toggles */}
        <div className="pt-4 border-t border-[#292a2f] grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-between">
            <div className="space-y-0.5 pr-3">
              <span className="text-sm font-semibold text-[#f5f5f6]">Bắt buộc 2FA cho Quản trị viên (Admin)</span>
              <p className="text-xs text-[#8a8d93]">Yêu cầu xác thực TOTP (Google/Microsoft Authenticator)</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0">
              <input
                type="checkbox"
                checked={data.require2FAForAdmin}
                onChange={(e) => onChange({ require2FAForAdmin: e.target.checked })}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-[#17181b] border border-[#34363b] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-[#8a8d93] peer-checked:after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#35c76f]" />
            </label>
          </div>

          <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center justify-between">
            <div className="space-y-0.5 pr-3">
              <span className="text-sm font-semibold text-[#f5f5f6]">Bắt buộc 2FA cho Huấn luyện viên (Trainer)</span>
              <p className="text-xs text-[#8a8d93]">Bảo vệ giáo án và dữ liệu theo dõi khách hàng</p>
            </div>
            <label className="relative inline-flex items-center cursor-pointer shrink-0">
              <input
                type="checkbox"
                checked={data.require2FAForTrainer}
                onChange={(e) => onChange({ require2FAForTrainer: e.target.checked })}
                className="sr-only peer"
              />
              <div className="w-11 h-6 bg-[#17181b] border border-[#34363b] peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-[#8a8d93] peer-checked:after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-[#35c76f]" />
            </label>
          </div>
        </div>
      </div>

      {/* Network & CORS Security Card */}
      <div className="p-6 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-5">
        <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
          <div>
            <h3 className="text-base font-bold text-[#f5f5f6]">Mạng lưới &amp; CORS Whitelist</h3>
            <p className="text-xs text-[#8a8d93] mt-0.5">Danh sách domain được phép gọi API và dải IP quản trị tin cậy</p>
          </div>
          <span className="material-symbols-outlined text-[#4d8dff] text-2xl">security</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div className="space-y-1.5">
            <div className="flex items-center justify-between">
              <label className="text-xs font-semibold text-[#f5f5f6]">CORS Allowed Origins (Mỗi dòng 1 domain)</label>
              <span className="text-[11px] text-[#8a8d93] font-mono">Access-Control-Allow-Origin</span>
            </div>
            <textarea
              rows={4}
              value={data.allowedCorsOrigins}
              onChange={(e) => onChange({ allowedCorsOrigins: e.target.value })}
              className="w-full p-3 rounded-xl bg-[#222327] border border-[#292a2f] text-xs font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="https://viegym.vn&#10;https://admin.viegym.vn"
            />
          </div>

          <div className="space-y-1.5">
            <div className="flex items-center justify-between">
              <label className="text-xs font-semibold text-[#f5f5f6]">IP Whitelist cho Admin Portal (CIDR / IP)</label>
              <span className="text-[11px] text-[#8a8d93] font-mono">CIDR Format</span>
            </div>
            <textarea
              rows={4}
              value={data.ipWhitelist}
              onChange={(e) => onChange({ ipWhitelist: e.target.value })}
              className="w-full p-3 rounded-xl bg-[#222327] border border-[#292a2f] text-xs font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="103.21.244.0/22&#10;14.161.0.0/16"
            />
          </div>
        </div>
      </div>
    </div>
  )
}
