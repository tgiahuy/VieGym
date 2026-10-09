import React, { useState } from 'react'
import { BrandPanel } from '../components/BrandPanel'
import { LoginForm } from '../components/LoginForm'
import { ModalDialog } from '../components/ModalDialog'

interface LoginPageProps {
  onLoginSuccess?: () => void
}

export const LoginPage: React.FC<LoginPageProps> = ({ onLoginSuccess }) => {
  const [activeModal, setActiveModal] = useState<
    'help' | 'security' | 'forgot' | 'passkey' | null
  >(null)

  return (
    <div className="min-h-screen w-full flex flex-col lg:flex-row bg-[#0f1012] text-[#f5f5f6] selection:bg-[#f2305a] selection:text-[#f5f5f6]">
      {/* Brand Panel (44% on desktop, geometric telemetry) */}
      <BrandPanel />

      {/* Right Login Area (56% on desktop) */}
      <main className="w-full lg:w-[56%] flex-1 flex flex-col justify-between items-center px-4 py-8 sm:p-8 md:p-12 lg:p-16 bg-[#0f1012] relative overflow-y-auto">
        {/* Top System Utility Status */}
        <header className="w-full max-w-[420px] flex items-center justify-between text-[#8a8d93] text-[12px] font-semibold mb-6">
          <div className="flex items-center gap-2">
            <span className="inline-block w-2 h-2 rounded-full bg-[#35c76f]" />
            <span className="text-[#a7a9ae]">
              Hệ thống sẵn sàng: <strong className="text-[#f5f5f6] font-semibold">Hoạt động</strong>
            </span>
          </div>
          <div className="flex items-center gap-1 text-[11px] text-[#8a8d93]">
            <span className="material-symbols-outlined text-[15px]">language</span>
            <span>VI (Tiếng Việt)</span>
          </div>
        </header>

        {/* Centered Login Card */}
        <LoginForm
          onSuccess={onLoginSuccess}
          onOpenForgotPasswordModal={() => setActiveModal('forgot')}
          onOpenHardwareKeyModal={() => setActiveModal('passkey')}
        />

        {/* Right Panel Sticky Footer Notice */}
        <footer className="w-full max-w-[420px] text-center pt-6 pb-2 text-[12px] text-[#8a8d93]">
          <div className="flex items-center justify-center gap-4 mb-2">
            <button
              type="button"
              onClick={() => setActiveModal('help')}
              className="hover:text-[#f5f5f6] transition-colors"
            >
              Trợ giúp kỹ thuật
            </button>
            <span>·</span>
            <button
              type="button"
              onClick={() => setActiveModal('security')}
              className="hover:text-[#f5f5f6] transition-colors"
            >
              Quy chuẩn an toàn
            </button>
            <span>·</span>
            <span className="text-[#a7a9ae]">VieGym Ops Core</span>
          </div>
          <p className="text-[11px] text-[#8a8d93]">
            © 2025 VieGym Technology Corporation. Hệ thống nội bộ bảo mật nghiêm ngặt.
          </p>
        </footer>
      </main>

      {/* Modal: Trợ giúp kỹ thuật */}
      <ModalDialog
        isOpen={activeModal === 'help'}
        title="Trung tâm hỗ trợ kỹ thuật VieGym Ops"
        icon="headset_mic"
        iconColor="text-[#4d8dff]"
        onClose={() => setActiveModal(null)}
      >
        <p>Hỗ trợ khẩn cấp dành riêng cho đội ngũ Quản trị viên hệ thống VieGym:</p>
        <div className="p-3 bg-[#222327] rounded-xl border border-[#292a2f] space-y-2 text-[12px]">
          <div>
            <span className="text-[#8a8d93]">Hotline bảo mật 24/7:</span>
            <span className="text-[#f5f5f6] font-mono font-bold block">1900-VIE-ADMIN (843)</span>
          </div>
          <div>
            <span className="text-[#8a8d93]">Cổng phản hồi NOC:</span>
            <span className="text-[#35c76f] font-mono block">noc.internal.viegym.vn</span>
          </div>
        </div>
      </ModalDialog>

      {/* Modal: Quy chuẩn an toàn */}
      <ModalDialog
        isOpen={activeModal === 'security'}
        title="Quy chuẩn an toàn & Bảo mật thông tin"
        icon="security"
        iconColor="text-[#35c76f]"
        onClose={() => setActiveModal(null)}
      >
        <p>Tuân thủ nghiêm ngặt tiêu chuẩn bảo mật hệ thống dữ liệu sức khỏe thể thao:</p>
        <ul className="list-disc pl-5 space-y-1.5 text-[12px]">
          <li>Chứng chỉ an ninh ISO/IEC 27001 &amp; SOC2 Type II.</li>
          <li>Phiên đăng nhập HttpOnly, chặn tấn công XSS và trích xuất token qua script.</li>
          <li>Tự động khóa tài khoản tạm thời sau 5 lần thử sai liên tiếp.</li>
        </ul>
      </ModalDialog>

      {/* Modal: Quên mật khẩu */}
      <ModalDialog
        isOpen={activeModal === 'forgot'}
        title="Khôi phục tài khoản Quản trị viên"
        icon="lock_reset"
        iconColor="text-[#f4b740]"
        onClose={() => setActiveModal(null)}
      >
        <p>
          Vì chính sách bảo vệ dữ liệu cấp độ Enterprise, tài khoản quản trị không thể tự khôi phục qua email công cộng.
        </p>
        <div className="p-3 bg-[#222327] rounded-xl border border-[#292a2f] text-[12px] space-y-1">
          <p className="font-semibold text-[#f5f5f6]">Quy trình cấp lại mật khẩu:</p>
          <p className="text-[#8a8d93]">
            1. Liên hệ Trưởng bộ phận Kỹ thuật Hệ thống qua email{' '}
            <span className="text-[#f2305a] font-mono">sysadmin@viegym.com</span>.
          </p>
          <p className="text-[#8a8d93]">2. Quét mã xác thực OTP nội bộ trực tiếp tại văn phòng điều hành.</p>
        </div>
      </ModalDialog>

      {/* Modal: Hardware Key / FIDO2 Passkey */}
      <ModalDialog
        isOpen={activeModal === 'passkey'}
        title="Xác thực phần cứng FIDO2 / Passkey"
        icon="usb"
        iconColor="text-[#9b7bff]"
        onClose={() => setActiveModal(null)}
      >
        <p>Hệ thống hỗ trợ khóa bảo mật vật lý (YubiKey / Titan Key) và sinh trắc học Touch ID / Windows Hello.</p>
        <div className="p-3 bg-[#222327] rounded-xl border border-[#292a2f] text-[12px] flex items-center gap-3">
          <span className="material-symbols-outlined text-[#9b7bff] text-[28px] animate-pulse">fingerprint</span>
          <div>
            <span className="text-[#f5f5f6] font-semibold block">Đang lắng nghe thiết bị xác thực</span>
            <span className="text-[#8a8d93] text-[11px]">Hãy chạm vào cảm biến vân tay hoặc cắm khóa USB FIDO2</span>
          </div>
        </div>
      </ModalDialog>
    </div>
  )
}
