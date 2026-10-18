import React from 'react'

interface DiffCompareModalProps {
  isOpen: boolean
  onClose: () => void
}

export const DiffCompareModal: React.FC<DiffCompareModalProps> = ({ isOpen, onClose }) => {
  if (!isOpen) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/64 backdrop-blur-sm p-4 overflow-y-auto animate-fadeIn"
      onClick={onClose}
    >
      <div
        className="w-full max-w-[840px] bg-[#1c1d21] rounded-2xl border border-[#292a2f] shadow-2xl flex flex-col my-auto relative animate-in fade-in zoom-in-95 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="h-16 px-6 border-b border-[#292a2f] flex items-center justify-between shrink-0">
          <div className="flex items-center gap-2.5">
            <span className="material-symbols-outlined text-[#ff506d] text-xl">difference</span>
            <div>
              <h3 className="text-base font-bold text-[#f5f5f6]">
                Lịch sử triển khai prompt
              </h3>
              <p className="text-xs text-[#8a8d93]">
                Mỗi lần publish được lưu thành một version và audit event trên backend
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-lg bg-[#222327] hover:bg-[#17181b] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f] flex items-center justify-center transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-lg">close</span>
          </button>
        </div>

        {/* Diff Content */}
        <div className="p-6 max-h-[70vh] overflow-y-auto space-y-3 text-sm">
          <div className="p-4 rounded-lg bg-[#131417] border border-[#292a2f] text-[#a7a9ae]">
            Xem các sự kiện <span className="font-mono text-[#f5f5f6]">AI_PROMPT_PUBLISH</span> trong trang Audit Logs để xác minh người phát hành, version và correlation ID. Giao diện diff chi tiết chưa được cung cấp bởi API.
          </div>
        </div>

        {/* Footer */}
        <div className="h-14 px-6 border-t border-[#292a2f] flex items-center justify-end bg-[#17181b] rounded-b-2xl">
          <button
            type="button"
            onClick={onClose}
            className="h-9 px-4 rounded-xl bg-[#222327] hover:bg-[#1c1d21] text-[#f5f5f6] text-xs font-semibold border border-[#292a2f] transition-colors cursor-pointer"
          >
            Đóng
          </button>
        </div>
      </div>
    </div>
  )
}
