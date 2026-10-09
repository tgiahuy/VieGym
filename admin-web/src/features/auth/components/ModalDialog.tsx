import React, { useEffect } from 'react'

interface ModalDialogProps {
  isOpen: boolean
  title: string
  icon?: string
  iconColor?: string
  onClose: () => void
  children: React.ReactNode
}

export const ModalDialog: React.FC<ModalDialogProps> = ({
  isOpen,
  title,
  icon = 'info',
  iconColor = 'text-[#4d8dff]',
  onClose,
  children,
}) => {
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

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="dialog-title"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-fadeIn"
      onClick={onClose}
    >
      <div
        className="w-full max-w-md bg-[#17181b] border border-[#292a2f] rounded-2xl p-6 shadow-2xl space-y-4 relative"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
          <div className="flex items-center gap-2">
            <span className={`material-symbols-outlined text-[20px] ${iconColor}`}>{icon}</span>
            <h3 id="dialog-title" className="text-[16px] font-bold text-[#f5f5f6]">
              {title}
            </h3>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Đóng cửa sổ"
            className="text-[#8a8d93] hover:text-[#f5f5f6] p-1 rounded-lg hover:bg-[#222327] transition-colors"
          >
            <span className="material-symbols-outlined text-[20px]">close</span>
          </button>
        </div>

        <div className="text-[13px] leading-relaxed text-[#a7a9ae] space-y-3">{children}</div>

        <div className="pt-2 flex justify-end">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 bg-[#222327] hover:bg-[#292a2f] text-[#f5f5f6] text-[13px] font-semibold rounded-xl transition-colors"
          >
            Đã hiểu
          </button>
        </div>
      </div>
    </div>
  )
}
