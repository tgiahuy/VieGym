import React, { useEffect, useState } from 'react'
import { UserRole } from '../types'

interface InviteAdminModalProps {
  isOpen: boolean
  onClose: () => void
  onInvite: (data: { email: string; fullName: string; role: UserRole; notes?: string }) => void
}

export const InviteAdminModal: React.FC<InviteAdminModalProps> = ({ isOpen, onClose, onInvite }) => {
  const [email, setEmail] = useState('')
  const [fullName, setFullName] = useState('')
  const [role, setRole] = useState<UserRole>('ADMIN')
  const [notes, setNotes] = useState('')
  const [errorMsg, setErrorMsg] = useState<string | null>(null)

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && isOpen) {
        onClose()
      }
    }
    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [isOpen, onClose])

  if (!isOpen) return null

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!email.trim() || !email.includes('@')) {
      setErrorMsg('Vui lòng nhập địa chỉ email hợp lệ')
      return
    }
    if (!fullName.trim()) {
      setErrorMsg('Vui lòng nhập họ và tên của người được mời')
      return
    }

    onInvite({
      email: email.trim(),
      fullName: fullName.trim(),
      role,
      notes: notes.trim(),
    })

    setEmail('')
    setFullName('')
    setRole('ADMIN')
    setNotes('')
    setErrorMsg(null)
  }

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/64 backdrop-blur-sm p-4 overflow-y-auto animate-fadeIn"
      onClick={onClose}
    >
      <div
        className="w-full max-w-[560px] bg-[#1c1d21] rounded-2xl border border-[#292a2f] shadow-2xl flex flex-col my-auto relative animate-in fade-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="h-16 px-6 border-b border-[#292a2f] flex items-center justify-between shrink-0">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-[rgba(242,48,90,0.12)] border border-[#ff506d]/20 flex items-center justify-center text-[#ff506d]">
              <span className="material-symbols-outlined text-[18px]">person_add</span>
            </div>
            <div>
              <h2 className="text-lg font-bold text-[#f5f5f6]">Mời tài khoản quản trị</h2>
              <p className="text-xs text-[#8a8d93]">Gửi liên kết kích hoạt và cấp quyền truy cập</p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-lg bg-[#222327] hover:bg-[#17181b] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f] flex items-center justify-center transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-[18px]">close</span>
          </button>
        </div>

        {/* Body */}
        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {errorMsg && (
            <div className="p-3 rounded-xl bg-[#ff5a5f]/15 border border-[#ff5a5f]/30 text-[#ff5a5f] text-xs flex items-center gap-2">
              <span className="material-symbols-outlined text-base">error</span>
              <span>{errorMsg}</span>
            </div>
          )}

          <div>
            <label className="block text-xs font-semibold text-[#a7a9ae] mb-1.5">
              Địa chỉ Email doanh nghiệp <span className="text-[#ff5a5f]">*</span>
            </label>
            <input
              type="email"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value)
                if (errorMsg) setErrorMsg(null)
              }}
              placeholder="VD: alex.nguyen@viegym.internal"
              className="w-full h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm focus:outline-none focus:border-[#ff506d]"
              required
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#a7a9ae] mb-1.5">
              Họ và tên đầy đủ <span className="text-[#ff5a5f]">*</span>
            </label>
            <input
              type="text"
              value={fullName}
              onChange={(e) => {
                setFullName(e.target.value)
                if (errorMsg) setErrorMsg(null)
              }}
              placeholder="VD: Nguyễn Văn Alex"
              className="w-full h-11 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm focus:outline-none focus:border-[#ff506d]"
              required
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-semibold text-[#a7a9ae] mb-1.5">
                Vai trò truy cập <span className="text-[#ff5a5f]">*</span>
              </label>
              <div className="relative">
                <select
                  value={role}
                  onChange={(e) => setRole(e.target.value as UserRole)}
                  className="w-full h-11 pl-3.5 pr-8 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm appearance-none focus:outline-none focus:border-[#ff506d] cursor-pointer"
                >
                  <option value="ADMIN">ADMIN (Quản trị viên)</option>
                  <option value="TRAINER">TRAINER (Huấn luyện viên)</option>
                  <option value="USER">USER (Hội viên VIP)</option>
                </select>
                <span className="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-[#8a8d93] pointer-events-none text-lg">
                  expand_more
                </span>
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-[#a7a9ae] mb-1.5">
                Chính sách kích hoạt
              </label>
              <div className="h-11 px-3.5 rounded-xl bg-[#17181b] border border-[#292a2f] text-[#a7a9ae] text-xs flex items-center">
                OTP qua Email (Hạn 48 giờ)
              </div>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold text-[#a7a9ae] mb-1.5">
              Ghi chú bàn giao phân quyền
            </label>
            <textarea
              rows={2}
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="Ghi chú nội bộ cho audit log..."
              className="w-full p-3 rounded-xl bg-[#222327] border border-[#292a2f] text-[#f5f5f6] text-sm focus:outline-none focus:border-[#ff506d] resize-none"
            />
          </div>

          {/* Footer Actions */}
          <div className="pt-3 border-t border-[#292a2f] flex items-center justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="h-11 px-5 rounded-xl bg-[#222327] hover:bg-[#17181b] text-[#a7a9ae] hover:text-[#f5f5f6] text-sm font-semibold border border-[#292a2f] transition-colors cursor-pointer"
            >
              Hủy
            </button>
            <button
              type="submit"
              className="h-11 px-6 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white text-sm font-semibold flex items-center gap-2 shadow-lg shadow-[#f2305a]/25 transition-all cursor-pointer"
            >
              <span className="material-symbols-outlined text-[18px]">send</span>
              <span>Gửi lời mời</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
