import React, { useState } from 'react'
import { useAuth } from '../../../core/auth'

interface LoginFormProps {
  onSuccess?: () => void
  onOpenHardwareKeyModal: () => void
  onOpenForgotPasswordModal: () => void
}

export const LoginForm: React.FC<LoginFormProps> = ({
  onSuccess,
  onOpenHardwareKeyModal,
  onOpenForgotPasswordModal,
}) => {
  const { login } = useAuth()

  const [email, setEmail] = useState('admin@viegym.com')
  const [password, setPassword] = useState('admin123')
  const [showPassword, setShowPassword] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [statusMessage, setStatusMessage] = useState<{
    type: 'error' | 'success'
    title: string
    description: string
  } | null>(null)

  const handleSubmit = async (e?: React.FormEvent) => {
    if (e) e.preventDefault()
    setStatusMessage(null)

    if (!email || !password) {
      setStatusMessage({
        type: 'error',
        title: 'Vui lòng điền đầy đủ thông tin',
        description: 'Email và mật khẩu không được để trống.',
      })
      return
    }

    if (password.length < 6) {
      setStatusMessage({
        type: 'error',
        title: 'Thông tin đăng nhập không hợp lệ',
        description: 'Vui lòng kiểm tra lại mật khẩu quản trị viên hoặc kiểm tra trạng thái token.',
      })
      return
    }

    setIsSubmitting(true)

    try {
      await login({
        email,
        password,
        deviceInfo: navigator.userAgent,
      })

      setStatusMessage({
        type: 'success',
        title: 'Khởi tạo phiên HttpOnly thành công',
        description: 'Đang điều hướng tới Tổng quan hệ thống...',
      })

      setTimeout(() => {
        onSuccess?.()
      }, 500)
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Đăng nhập không thành công'
      setStatusMessage({
        type: 'error',
        title: 'Xác thực thất bại',
        description: message || 'Vui lòng kiểm tra lại thông tin hoặc kết nối máy chủ.',
      })
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="w-full max-w-[420px] my-auto">
      {/* Card Container */}
      <div className="bg-[#17181b] rounded-xl border border-[#292a2f] p-7 sm:p-8 shadow-2xl relative">
        {/* Header Section */}
        <div className="mb-6">
          <div className="inline-flex items-center justify-center w-11 h-11 rounded-xl bg-[#222327] border border-[#34363b] text-[#f2305a] mb-4">
            <span className="material-symbols-outlined text-[24px]">lock</span>
          </div>
          <h2 className="text-[20px] font-bold text-[#f5f5f6] tracking-tight">
            Đăng nhập quản trị
          </h2>
          <p className="text-[14px] text-[#a7a9ae] mt-1">
            Truy cập hệ thống quản lý VieGym
          </p>
        </div>

        {/* Security Role Indicator Badge */}
        <div className="mb-6 p-3 rounded-lg bg-[#222327] border border-[#34363b] flex items-start gap-2.5">
          <span className="material-symbols-outlined text-[#f4b740] text-[18px] shrink-0 mt-0.5">shield</span>
          <div className="text-[12px] leading-[18px]">
            <span className="font-semibold text-[#f5f5f6]">Chỉ chấp nhận tài khoản ADMIN</span>
            <p className="text-[#8a8d93]">Phiên làm việc được mã hóa đầu-cuối và giám sát tự động.</p>
          </div>
        </div>

        {/* Login Form */}
        <form className="space-y-4" onSubmit={handleSubmit} noValidate>
          {/* Field 1: Email quản trị */}
          <div className="space-y-1.5">
            <div className="flex items-center justify-between">
              <label className="block text-[12px] font-semibold text-[#f5f5f6]" htmlFor="admin-email">
                Email quản trị
              </label>
            </div>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-[#8a8d93]">
                <span className="material-symbols-outlined text-[18px]">mail</span>
              </div>
              <input
                id="admin-email"
                name="email"
                type="email"
                required
                autoComplete="username"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@viegym.com"
                className="w-full h-[44px] bg-[#222327] text-[#f5f5f6] placeholder:text-[#8a8d93] border border-[#292a2f] rounded-xl pl-10 pr-4 text-[14px] focus:outline-none focus:border-[#f2305a] focus:ring-1 focus:ring-[#f2305a] transition-all"
              />
            </div>
          </div>

          {/* Field 2: Mật khẩu */}
          <div className="space-y-1.5">
            <div className="flex items-center justify-between">
              <label className="block text-[12px] font-semibold text-[#f5f5f6]" htmlFor="admin-password">
                Mật khẩu
              </label>
              <button
                type="button"
                onClick={onOpenForgotPasswordModal}
                className="text-[12px] text-[#a7a9ae] hover:text-[#f5f5f6] transition-colors"
              >
                Quên mật khẩu?
              </button>
            </div>
            <div className="relative">
              <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-[#8a8d93]">
                <span className="material-symbols-outlined text-[18px]">key</span>
              </div>
              <input
                id="admin-password"
                name="password"
                type={showPassword ? 'text' : 'password'}
                required
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••"
                className="w-full h-[44px] bg-[#222327] text-[#f5f5f6] placeholder:text-[#8a8d93] border border-[#292a2f] rounded-xl pl-10 pr-11 text-[14px] focus:outline-none focus:border-[#f2305a] focus:ring-1 focus:ring-[#f2305a] transition-all font-mono"
              />
              <button
                type="button"
                aria-label="Hiện hoặc ẩn mật khẩu"
                title="Hiện/Ẩn mật khẩu"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute inset-y-0 right-0 pr-3.5 flex items-center text-[#8a8d93] hover:text-[#f5f5f6] transition-colors focus:outline-none"
              >
                <span className="material-symbols-outlined text-[18px]">
                  {showPassword ? 'visibility_off' : 'visibility'}
                </span>
              </button>
            </div>
          </div>

          {/* Inline Notice / Status message */}
          {statusMessage && (
            <div
              role="alert"
              className={`text-[12px] p-2.5 rounded-lg border animate-fadeIn ${
                statusMessage.type === 'error'
                  ? 'bg-[#ff5a5f]/10 border-[#ff5a5f]/30 text-[#ff5a5f]'
                  : 'bg-[#35c76f]/10 border-[#35c76f]/30 text-[#35c76f]'
              }`}
            >
              <div className="flex items-center gap-1.5 font-semibold">
                <span className="material-symbols-outlined text-[16px]">
                  {statusMessage.type === 'error' ? 'error' : 'check_circle'}
                </span>
                <span>{statusMessage.title}</span>
              </div>
              <p className="mt-0.5 text-[#a7a9ae]">{statusMessage.description}</p>
            </div>
          )}

          {/* Primary Submit Button */}
          <div className="pt-2">
            <button
              id="submit-button"
              type="submit"
              disabled={isSubmitting}
              className={`w-full h-[48px] text-[#f5f5f6] text-[14px] font-bold rounded-xl transition-all duration-150 flex items-center justify-center gap-2 shadow-lg active:scale-[0.99] ${
                statusMessage?.type === 'success'
                  ? 'bg-[#35c76f] shadow-[#35c76f]/20 cursor-default'
                  : 'bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] shadow-[#f2305a]/20 cursor-pointer'
              } ${isSubmitting ? 'opacity-80 cursor-not-allowed' : ''}`}
            >
              {isSubmitting ? (
                <>
                  <svg className="animate-spin h-5 w-5 text-[#f5f5f6]" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                    <path
                      className="opacity-75"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                      fill="currentColor"
                    />
                  </svg>
                  <span>Đang xác thực thông tin...</span>
                </>
              ) : statusMessage?.type === 'success' ? (
                <>
                  <span className="material-symbols-outlined text-[20px]">check</span>
                  <span>Phiên hợp lệ · Đang chuyển hướng...</span>
                </>
              ) : (
                <>
                  <span className="material-symbols-outlined text-[20px]">login</span>
                  <span>Đăng nhập hệ thống</span>
                </>
              )}
            </button>
          </div>
        </form>

        {/* Divider line */}
        <div className="relative my-6">
          <div className="absolute inset-0 flex items-center">
            <div className="w-full border-t border-[#292a2f]" />
          </div>
          <div className="relative flex justify-center text-center">
            <span className="bg-[#17181b] px-2 text-[11px] font-semibold text-[#8a8d93] tracking-wider uppercase">
              BẢO MẬT &amp; ĐẶC QUYỀN
            </span>
          </div>
        </div>

        {/* Security & Audit Policy Callout */}
        <div className="bg-[#1c1d21] rounded-lg p-3 border border-[#292a2f] text-left space-y-1.5">
          <div className="flex items-center gap-1.5 text-[#f5f5f6] text-[12px] font-semibold">
            <span className="material-symbols-outlined text-[#4d8dff] text-[16px]">info</span>
            <span>Chính sách kiểm toán phiên truy cập</span>
          </div>
          <p className="text-[12px] text-[#8a8d93] leading-relaxed">
            Session cookie HttpOnly · Chống giả mạo CSRF · Giới hạn tần suất 5 lần/phút. Mọi hành động đều được lưu audit log.
          </p>
        </div>
      </div>

      {/* Hardware Key / Passkey Alternative */}
      <div className="mt-4 flex items-center justify-between px-2 text-[12px] font-semibold text-[#8a8d93]">
        <button
          type="button"
          onClick={onOpenHardwareKeyModal}
          className="flex items-center gap-1.5 hover:text-[#f5f5f6] transition-colors"
        >
          <span className="material-symbols-outlined text-[16px] text-[#9b7bff]">usb</span>
          <span>Khóa vật lý FIDO2 / Passkey</span>
        </button>
        <span className="text-[#8a8d93] font-mono text-[11px]">IP: 14.161.42.***</span>
      </div>
    </div>
  )
}
