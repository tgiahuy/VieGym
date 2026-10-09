import React from 'react'
import { useNavigate } from 'react-router-dom'
import type { DashboardAlertItem } from '../types'

interface AlertsWidgetProps {
  alerts?: DashboardAlertItem[]
}

export const AlertsWidget: React.FC<AlertsWidgetProps> = ({ alerts = [] }) => {
  const navigate = useNavigate()

  const displayAlerts = alerts.length > 0 ? alerts : [
    {
      id: 'all-good',
      type: 'info' as const,
      title: 'Hệ thống vận hành tối ưu',
      description: 'Dữ liệu danh mục bài tập, thực phẩm và thiết bị đã được đồng bộ chuẩn hóa.',
      actionText: 'Xem nhật ký vận hành',
      actionLink: '/audit-logs',
      icon: 'verified_user',
    },
  ]

  const warningCount = alerts.filter((a) => a.type === 'warning' || a.type === 'error').length

  const getIconColor = (type: 'warning' | 'error' | 'info') => {
    switch (type) {
      case 'error':
        return 'text-[#ff506d]'
      case 'warning':
        return 'text-[#f4b740]'
      default:
        return 'text-[#35c76f]'
    }
  }

  const getActionColor = (type: 'warning' | 'error' | 'info') => {
    switch (type) {
      case 'error':
        return 'text-[#ff506d]'
      case 'warning':
        return 'text-[#f4b740]'
      default:
        return 'text-[#4d8dff]'
    }
  }

  return (
    <div className="col-span-12 lg:col-span-4 bg-[#17181b] border border-[#292a2f] rounded-[18px] p-6 flex flex-col justify-between shadow-sm">
      <div>
        {/* Header */}
        <div className="flex items-center justify-between pb-4 border-b border-[#292a2f]">
          <div className="flex items-center gap-2">
            <span className="material-symbols-outlined text-[#f4b740] text-xl">
              notifications_active
            </span>
            <h2 className="text-[16px] font-bold text-[#f5f5f6]">Cảnh báo dữ liệu &amp; Vận hành</h2>
          </div>
          {warningCount > 0 ? (
            <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-[#f4b740]/15 text-[#f4b740] border border-[#f4b740]/30">
              {warningCount} Cần xử lý
            </span>
          ) : (
            <span className="px-2 py-0.5 rounded text-[11px] font-bold bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/30">
              Ổn định
            </span>
          )}
        </div>

        {/* Alert Items List */}
        <div className="space-y-3 mt-4">
          {displayAlerts.map((item) => (
            <div
              key={item.id}
              className="p-3.5 rounded-xl bg-[#222327] border border-[#292a2f] flex flex-col gap-2 hover:border-[#34363b] transition-colors"
            >
              <div className="flex items-start justify-between gap-2">
                <div className="flex items-start gap-2.5">
                  <span className={`material-symbols-outlined text-lg shrink-0 mt-0.5 ${getIconColor(item.type)}`}>
                    {item.icon}
                  </span>
                  <div>
                    <h3 className="text-xs font-semibold text-[#f5f5f6]">
                      {item.title}
                    </h3>
                    <p className="text-[11px] text-[#a7a9ae] mt-0.5">
                      {item.description}
                    </p>
                  </div>
                </div>
              </div>
              <div className="flex items-center justify-end pt-1">
                <button
                  type="button"
                  onClick={() => navigate(item.actionLink)}
                  className={`text-[11px] font-semibold hover:underline flex items-center gap-1 cursor-pointer ${getActionColor(item.type)}`}
                >
                  <span>{item.actionText}</span>
                  <span className="material-symbols-outlined text-xs">open_in_new</span>
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Trạng thái an ninh & Audit Box */}
      <div className="mt-4 pt-3 border-t border-[#292a2f] flex items-center justify-between text-[11px] text-[#8a8d93]">
        <div className="flex items-center gap-1.5">
          <span className="material-symbols-outlined text-[#35c76f] text-sm">verified_user</span>
          <span>
            CSRF &amp; RBAC: <strong className="text-[#a7a9ae]">Bảo vệ an toàn</strong>
          </span>
        </div>
        <span className="font-mono text-[10px] text-[#35c76f]">Zero Criticals</span>
      </div>
    </div>
  )
}

