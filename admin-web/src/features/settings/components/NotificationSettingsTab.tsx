import React from 'react'
import { NotificationSettings } from '../types'

interface NotificationSettingsTabProps {
  data: NotificationSettings
  onChange: (fields: Partial<NotificationSettings>) => void
  onTestConnection: (serviceName: string) => void
}

export const NotificationSettingsTab: React.FC<NotificationSettingsTabProps> = ({
  data,
  onChange,
  onTestConnection,
}) => {
  return (
    <div className="space-y-6">
      {/* Email / SMTP Configuration */}
      <div className="p-6 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-5">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#292a2f]">
          <div>
            <h3 className="text-base font-bold text-[#f5f5f6]">Dịch vụ Email Giao dịch (SMTP Relay)</h3>
            <p className="text-xs text-[#8a8d93] mt-0.5">Gửi email kích hoạt tài khoản, đặt lại mật khẩu và thông báo giao dịch</p>
          </div>
          <button
            type="button"
            onClick={() => onTestConnection('SMTP Relay')}
            className="px-3.5 py-1.5 rounded-xl bg-[#222327] hover:bg-[#292a2f] text-xs font-semibold text-[#f5f5f6] border border-[#34363b] flex items-center gap-1.5 transition-colors cursor-pointer self-start sm:self-auto"
          >
            <span className="material-symbols-outlined text-sm text-[#35c76f]">mail</span>
            <span>Gửi email thử nghiệm</span>
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          <div className="space-y-1.5 md:col-span-2">
            <label className="text-xs font-semibold text-[#f5f5f6]">SMTP Host Server</label>
            <input
              type="text"
              value={data.smtpHost}
              onChange={(e) => onChange({ smtpHost: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="smtp.sendgrid.net"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">SMTP Port</label>
            <input
              type="number"
              value={data.smtpPort}
              onChange={(e) => onChange({ smtpPort: Number(e.target.value) || 587 })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Tên người gửi (Sender Name)</label>
            <input
              type="text"
              value={data.senderName}
              onChange={(e) => onChange({ senderName: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="VieGym Fitness & Nutrition"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Email người gửi (From Email)</label>
            <input
              type="email"
              value={data.senderEmail}
              onChange={(e) => onChange({ senderEmail: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="no-reply@viegym.vn"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Mật khẩu / API Key SMTP</label>
            <input
              type="password"
              value={data.smtpPasswordMasked}
              onChange={(e) => onChange({ smtpPasswordMasked: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
          </div>
        </div>
      </div>

      {/* SMS & Telegram Ops Alerts */}
      <div className="p-6 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-5">
        <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
          <div>
            <h3 className="text-base font-bold text-[#f5f5f6]">Kênh Cảnh báo Vận hành &amp; Tin nhắn OTP</h3>
            <p className="text-xs text-[#8a8d93] mt-0.5">Tích hợp Zalo ZNS, Telegram Bot và Slack Webhook</p>
          </div>
          <span className="material-symbols-outlined text-[#f4b740] text-2xl">campaign</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Nhà cung cấp SMS / OTP Brandname</label>
            <select
              value={data.smsProvider}
              onChange={(e) => onChange({ smsProvider: e.target.value as NotificationSettings['smsProvider'] })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d] cursor-pointer"
            >
              <option value="Zalo ZNS">Zalo ZNS (Recommended)</option>
              <option value="VietGuys Brandname">VietGuys SMS Brandname</option>
              <option value="Twilio">Twilio Global SMS</option>
              <option value="None">Tạm tắt dịch vụ SMS</option>
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Telegram Alert Chat ID</label>
            <input
              type="text"
              value={data.telegramChatId}
              onChange={(e) => onChange({ telegramChatId: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="-100192837465"
            />
          </div>

          <div className="space-y-1.5 md:col-span-2">
            <label className="text-xs font-semibold text-[#f5f5f6]">Slack Webhook URL (Báo lỗi 500 &amp; Audit Alert)</label>
            <input
              type="url"
              value={data.slackWebhookUrl}
              onChange={(e) => onChange({ slackWebhookUrl: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
              placeholder="https://hooks.slack.com/services/..."
            />
          </div>
        </div>
      </div>
    </div>
  )
}
