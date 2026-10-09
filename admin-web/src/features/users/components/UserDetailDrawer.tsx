import React, { useEffect } from 'react'
import { UserItem } from '../types'

interface UserDetailDrawerProps {
  isOpen: boolean
  user: UserItem | null
  onClose: () => void
  onToggleLock: (user: UserItem) => void
  onRevokeSessions: (user: UserItem) => void
  onCopyText: (text: string, label: string) => void
}

export const UserDetailDrawer: React.FC<UserDetailDrawerProps> = ({
  isOpen,
  user,
  onClose,
  onToggleLock,
  onRevokeSessions,
  onCopyText,
}) => {
  // Close on Escape key press
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose()
      }
    }
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [isOpen, onClose])

  if (!isOpen || !user) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200"
      onClick={onClose}
    >
      <div
        className="w-full max-w-2xl max-h-[90vh] bg-[#1c1d21] rounded-2xl border border-[#292a2f] shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Modal Sticky Header */}
        <div className="px-6 py-4 bg-[#17181b] border-b border-[#292a2f] flex items-center justify-between shrink-0">
          <div className="flex items-center gap-3">
            <h2 className="text-lg sm:text-xl font-bold text-[#f5f5f6]">Chi tiết tài khoản</h2>
            <span className="px-2 py-0.5 rounded text-xs font-mono text-[#a7a9ae] bg-[#222327] border border-[#34363b]">
              #{user.code}
            </span>
            {user.status === 'ACTIVE' && (
              <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/20">
                <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
                Active
              </span>
            )}
            {user.status === 'LOCKED' && (
              <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#ff5a5f]/10 text-[#ff5a5f] border border-[#ff5a5f]/20">
                <span className="w-1.5 h-1.5 rounded-full bg-[#ff5a5f]" />
                Locked
              </span>
            )}
            {user.status === 'DISABLED' && (
              <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#222327] text-[#8a8d93] border border-[#34363b]">
                <span className="w-1.5 h-1.5 rounded-full bg-[#8a8d93]" />
                Disabled
              </span>
            )}
          </div>
          <button
            type="button"
            className="w-8 h-8 rounded-lg text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#222327] flex items-center justify-center transition-colors cursor-pointer"
            onClick={onClose}
            title="Đóng (Esc)"
          >
            <span className="material-symbols-outlined text-xl">close</span>
          </button>
        </div>

        {/* Modal Scrollable Content Canvas */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          {/* Summary Identity Header */}
          <div className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] flex items-start gap-4">
            {user.avatarUrl ? (
              <img
                src={user.avatarUrl}
                alt={user.nickname}
                className="w-16 h-16 rounded-full border-2 border-[#ff506d] object-cover shrink-0"
              />
            ) : (
              <div className="w-16 h-16 rounded-full bg-[rgba(242,48,90,0.12)] border-2 border-[#ff506d]/40 flex items-center justify-center text-[#ff506d] font-bold text-xl shrink-0">
                {user.initials}
              </div>
            )}
            <div className="flex-1 min-w-0">
              <div className="flex items-center justify-between gap-2">
                <h3 className="text-xl font-bold text-[#f5f5f6] truncate">{user.nickname}</h3>
                <span className="px-2 py-0.5 rounded text-xs font-bold bg-[rgba(242,48,90,0.12)] text-[#ff506d] border border-[#ff506d]/30 shrink-0">
                  {user.role} ({user.role === 'ADMIN' ? 'Quản trị' : user.role === 'TRAINER' ? 'HLV' : 'Hội viên'})
                </span>
              </div>
              <p className="text-sm text-[#a7a9ae] mt-0.5">{user.fullName}</p>
              <div className="mt-2 flex items-center gap-2">
                <span className="font-mono text-xs text-[#f5f5f6] bg-[#222327] px-2 py-1 rounded border border-[#292a2f] truncate">
                  {user.email}
                </span>
                <button
                  type="button"
                  className="p-1 text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#222327] rounded transition-colors cursor-pointer"
                  onClick={() => onCopyText(user.email, 'Email')}
                  title="Sao chép email"
                >
                  <span className="material-symbols-outlined text-sm">content_copy</span>
                </button>
              </div>
              {user.planName && (
                <div className="mt-3 inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md bg-[#4d8dff]/10 border border-[#4d8dff]/30 text-[#4d8dff] text-xs font-semibold">
                  <span className="material-symbols-outlined text-sm">workspace_premium</span>
                  <span>
                    Gói: {user.planName} {user.planExpiry ? `(Hạn: ${user.planExpiry})` : ''}
                  </span>
                </div>
              )}
            </div>
          </div>

          {/* Sanitized Privacy Security Notice Card (ADR-008 Mandatory Compliance) */}
          <div className="p-4 rounded-xl bg-[#222327]/60 border border-[#34363b] flex items-start gap-3">
            <span className="material-symbols-outlined text-[#f4b740] text-xl shrink-0 mt-0.5">
              verified_user
            </span>
            <div>
              <div className="text-sm font-semibold text-[#f5f5f6] flex items-center gap-1.5">
                <span>Chính sách bảo mật PII &amp; Dữ liệu sức khỏe</span>
                <span className="px-1.5 py-0.2 rounded text-[10px] font-bold bg-[#1c1d21] text-[#f4b740] border border-[#f4b740]/30">
                  ADR-008
                </span>
              </div>
              <p className="text-xs text-[#a7a9ae] mt-1 leading-relaxed">
                Giao diện quản trị chỉ hiển thị siêu dữ liệu tài khoản phục vụ vận hành kỹ thuật. Toàn bộ lịch sử sức khỏe, bài tập cá nhân, thực đơn dinh dưỡng và nhật ký hội thoại AI được bảo vệ riêng tư tuyệt đối và cách ly theo phân quyền.
              </p>
            </div>
          </div>

          {/* Account Operational Metadata Block */}
          <div className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-[#292a2f]">
              <span className="text-[11px] font-semibold text-[#8a8d93] tracking-wider uppercase">
                SIÊU DỮ LIỆU TÀI KHOẢN &amp; TRUY CẬP
              </span>
              <span className="flex items-center gap-1 text-xs text-[#35c76f]">
                <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
                Đã đồng bộ
              </span>
            </div>

            <div className="space-y-3 text-sm">
              {/* UUID */}
              <div className="flex flex-col gap-1">
                <span className="text-xs text-[#8a8d93] font-medium">
                  Mã định danh hệ thống (UUID)
                </span>
                <div className="flex items-center justify-between p-2 rounded-lg bg-[#222327] border border-[#292a2f]">
                  <span className="font-mono text-xs text-[#f5f5f6] break-all">{user.uuid}</span>
                  <button
                    type="button"
                    className="p-1 text-[#a7a9ae] hover:text-[#f5f5f6] hover:bg-[#1c1d21] rounded ml-2 cursor-pointer shrink-0"
                    onClick={() => onCopyText(user.uuid, 'UUID')}
                    title="Sao chép UUID"
                  >
                    <span className="material-symbols-outlined text-sm">content_copy</span>
                  </button>
                </div>
              </div>

              {/* Phone */}
              <div className="flex items-center justify-between py-1.5 border-b border-[#292a2f]">
                <span className="text-[#a7a9ae]">Số điện thoại xác thực</span>
                <span className="font-mono text-[#f5f5f6] font-semibold">{user.phone}</span>
              </div>

              {/* Auth Method */}
              <div className="flex items-start justify-between py-1.5 border-b border-[#292a2f]">
                <span className="text-[#a7a9ae]">Phương thức xác thực</span>
                <div className="text-right">
                  <div className="text-[#f5f5f6] font-medium text-xs">{user.authMethod}</div>
                </div>
              </div>

              {/* Registration Date */}
              <div className="flex items-center justify-between py-1.5 border-b border-[#292a2f]">
                <span className="text-[#a7a9ae]">Ngày đăng ký hệ thống</span>
                <span className="tabular-nums text-[#f5f5f6] text-xs">{user.registeredAt}</span>
              </div>

              {/* Last Login */}
              <div className="flex items-start justify-between py-1.5 border-b border-[#292a2f]">
                <span className="text-[#a7a9ae]">Lần đăng nhập cuối</span>
                <div className="text-right">
                  <span className="tabular-nums text-[#f5f5f6] text-xs">
                    {user.lastLoginAt || '— Chưa đăng nhập'}
                  </span>
                  {user.lastLoginIp && (
                    <div className="text-[11px] text-[#8a8d93] font-mono mt-0.5">
                      {user.lastLoginIp}
                    </div>
                  )}
                </div>
              </div>

              {/* Primary Device */}
              <div className="flex items-start justify-between py-1.5 border-b border-[#292a2f]">
                <span className="text-[#a7a9ae]">Thiết bị sử dụng chính</span>
                <div className="text-right">
                  <div className="text-[#f5f5f6] text-xs font-medium">
                    {user.primaryDevice || 'Chưa xác định'}
                  </div>
                </div>
              </div>

              {/* Active Sessions */}
              <div className="flex items-center justify-between pt-1">
                <span className="text-[#a7a9ae]">Phiên đang hoạt động</span>
                <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded bg-[#222327] border border-[#34363b] text-[#f5f5f6] text-xs font-semibold">
                  <span
                    className={`w-2 h-2 rounded-full ${
                      user.activeSessionsCount > 0 ? 'bg-[#35c76f]' : 'bg-[#8a8d93]'
                    }`}
                  />
                  {user.activeSessionsDetail || `${user.activeSessionsCount} phiên`}
                </span>
              </div>
            </div>
          </div>

          {/* Recent Audit Logs for User */}
          <div className="p-5 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-3">
            <div className="flex items-center justify-between pb-2 border-b border-[#292a2f]">
              <span className="text-[11px] font-semibold text-[#8a8d93] tracking-wider uppercase">
                NHẬT KÝ QUẢN TRỊ LIÊN QUAN
              </span>
              <span className="material-symbols-outlined text-[#8a8d93] text-base">
                receipt_long
              </span>
            </div>
            <div className="space-y-2.5">
              {user.auditLogs && user.auditLogs.length > 0 ? (
                user.auditLogs.map((log) => (
                  <div
                    key={log.id}
                    className="p-3 rounded-xl bg-[#222327] border border-[#292a2f] flex items-start gap-3"
                  >
                    <span
                      className="material-symbols-outlined text-base mt-0.5"
                      style={{ color: log.iconColor }}
                    >
                      {log.icon}
                    </span>
                    <div className="flex-1 min-w-0">
                      <div className="text-xs font-semibold text-[#f5f5f6] truncate">
                        {log.title}
                      </div>
                      <div className="text-[11px] text-[#a7a9ae] tabular-nums mt-0.5">
                        {log.detail}
                      </div>
                    </div>
                    <span className="px-1.5 py-0.5 rounded text-[10px] bg-[#17181b] text-[#8a8d93] border border-[#292a2f] tabular-nums">
                      {log.timeAgo}
                    </span>
                  </div>
                ))
              ) : (
                <p className="text-xs text-[#8a8d93] py-2">Chưa ghi nhận sự kiện bảo mật nào.</p>
              )}
            </div>
          </div>
        </div>

        {/* Modal Action Footer */}
        <div className="px-6 py-4 bg-[#17181b] border-t border-[#292a2f] flex flex-wrap items-center justify-between gap-3 shrink-0">
          <div className="flex items-center gap-2">
            {/* Destructive Lock / Unlock Button */}
            <button
              type="button"
              onClick={() => onToggleLock(user)}
              className={`h-11 px-4 rounded-xl font-semibold text-sm flex items-center gap-2 shadow-sm transition-colors cursor-pointer ${
                user.status === 'LOCKED'
                  ? 'bg-[#35c76f] hover:bg-[#2eb363] text-white'
                  : 'bg-[#ff5a5f] hover:bg-[#e04e53] active:bg-[#c93f44] text-white'
              }`}
            >
              <span className="material-symbols-outlined text-base">
                {user.status === 'LOCKED' ? 'lock_open' : 'lock'}
              </span>
              <span>{user.status === 'LOCKED' ? 'Mở khóa tài khoản' : 'Khóa tài khoản'}</span>
            </button>

            {/* Revoke Sessions Action */}
            <button
              type="button"
              onClick={() => onRevokeSessions(user)}
              className="h-11 px-3.5 rounded-xl bg-[#222327] hover:bg-[#17181b] border border-[#292a2f] hover:border-[#34363b] text-[#a7a9ae] hover:text-[#f5f5f6] font-semibold text-sm flex items-center gap-1.5 transition-colors cursor-pointer"
              title="Hủy kích hoạt các phiên làm việc ngay lập tức"
            >
              <span className="material-symbols-outlined text-base">phonelink_erase</span>
              <span className="hidden sm:inline">Thu hồi tất cả phiên</span>
            </button>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="h-11 px-5 rounded-xl bg-[#222327] hover:bg-[#17181b] border border-[#292a2f] hover:border-[#34363b] text-[#f5f5f6] font-semibold text-sm transition-colors cursor-pointer"
          >
            Đóng
          </button>
        </div>
      </div>
    </div>
  )
}
