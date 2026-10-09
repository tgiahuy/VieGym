import React, { useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

interface QuickActionModalProps {
  isOpen: boolean
  onClose: () => void
}

export const QuickActionModal: React.FC<QuickActionModalProps> = ({ isOpen, onClose }) => {
  const navigate = useNavigate()

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

  const actions = [
    {
      title: 'Thêm bài tập mới',
      desc: 'Tạo bài tập kèm video hướng dẫn, nhóm cơ và thiết bị',
      icon: 'fitness_center',
      color: 'text-[#f2305a] bg-[#f2305a]/10 border-[#f2305a]/20',
      path: '/exercises?action=new',
    },
    {
      title: 'Tạo giáo án tập luyện',
      desc: 'Biên soạn lộ trình tập theo buổi, phân bổ bài tập và cường độ',
      icon: 'menu_book',
      color: 'text-[#ff506d] bg-[#ff506d]/10 border-[#ff506d]/20',
      path: '/workout-plans?action=new',
    },
    {
      title: 'Thêm thực phẩm & Dinh dưỡng',
      desc: 'Khai báo thực phẩm, macro calo/protein/carbs/fat',
      icon: 'restaurant',
      color: 'text-[#35c76f] bg-[#35c76f]/10 border-[#35c76f]/20',
      path: '/foods?action=new',
    },
    {
      title: 'Nhập dữ liệu từ Excel / CSV',
      desc: 'Tải lên danh mục bài tập, thực phẩm hàng loạt',
      icon: 'upload_file',
      color: 'text-[#4d8dff] bg-[#4d8dff]/10 border-[#4d8dff]/20',
      path: '/imports',
    },
    {
      title: 'Quy tắc AI & Prompt Template',
      desc: 'Hiệu chỉnh rule gợi ý mức tạ và thực đơn tự động',
      icon: 'smart_toy',
      color: 'text-[#9b7bff] bg-[#9b7bff]/10 border-[#9b7bff]/20',
      path: '/ai-config',
    },
  ]

  const handleSelect = (path: string) => {
    onClose()
    navigate(path)
  }

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-labelledby="quick-action-title"
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/75 backdrop-blur-sm"
      onClick={onClose}
    >
      <div
        className="w-full max-w-lg bg-[#17181b] border border-[#292a2f] rounded-2xl p-6 shadow-2xl space-y-4"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-[rgba(242,48,90,0.12)] border border-[#f2305a]/30 flex items-center justify-center text-[#f2305a]">
              <span className="material-symbols-outlined text-[20px]">add</span>
            </div>
            <div>
              <h3 id="quick-action-title" className="text-[16px] font-bold text-[#f5f5f6]">
                Tạo nhanh tác vụ mới
              </h3>
              <p className="text-[12px] text-[#8a8d93]">Chọn danh mục dữ liệu bạn muốn khởi tạo</p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            aria-label="Đóng cửa sổ"
            className="text-[#8a8d93] hover:text-[#f5f5f6] p-1.5 rounded-lg hover:bg-[#222327] transition-colors"
          >
            <span className="material-symbols-outlined text-[20px]">close</span>
          </button>
        </div>

        <div className="grid grid-cols-1 gap-3">
          {actions.map((act) => (
            <button
              key={act.title}
              type="button"
              onClick={() => handleSelect(act.path)}
              className="w-full text-left p-3.5 rounded-xl bg-[#222327] hover:bg-[#292a2c] border border-[#292a2f] hover:border-[#34363b] flex items-center gap-3.5 transition-all group"
            >
              <div className={`w-10 h-10 rounded-xl border flex items-center justify-center shrink-0 ${act.color}`}>
                <span className="material-symbols-outlined text-[22px]">{act.icon}</span>
              </div>
              <div className="flex-1 min-w-0">
                <span className="text-[13px] font-semibold text-[#f5f5f6] block group-hover:text-[#ff506d] transition-colors">
                  {act.title}
                </span>
                <span className="text-[11px] text-[#8a8d93] block truncate">{act.desc}</span>
              </div>
              <span className="material-symbols-outlined text-[#8a8d93] group-hover:text-[#f5f5f6] text-[18px] group-hover:translate-x-0.5 transition-all">
                chevron_right
              </span>
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
