import React from 'react'

interface PlaceholderPageProps {
  title: string
  subtitle: string
  icon: string
  tag?: string
}

export const PlaceholderPage: React.FC<PlaceholderPageProps> = ({
  title,
  subtitle,
  icon,
  tag,
}) => {
  return (
    <div className="space-y-6 animate-fadeIn">
      <div className="flex items-center justify-between pb-2 border-b border-[#292a2f]">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-[28px] leading-[36px] font-bold tracking-tight text-[#f5f5f6]">
              {title}
            </h1>
            {tag && (
              <span className="px-2 py-0.5 rounded-full bg-[rgba(242,48,90,0.12)] border border-[#f2305a]/30 text-[#ff506d] text-[11px] font-semibold">
                {tag}
              </span>
            )}
          </div>
          <p className="text-[#a7a9ae] text-sm mt-0.5">{subtitle}</p>
        </div>
      </div>

      <div className="bg-[#17181b] border border-[#292a2f] rounded-[18px] p-12 text-center flex flex-col items-center justify-center space-y-4 min-h-[400px]">
        <div className="w-16 h-16 rounded-2xl bg-[#222327] border border-[#34363b] flex items-center justify-center text-[#ff506d]">
          <span className="material-symbols-outlined text-[32px]">{icon}</span>
        </div>
        <h3 className="text-[18px] font-bold text-[#f5f5f6]">Phân hệ đang hoạt động</h3>
        <p className="text-[14px] text-[#a7a9ae] max-w-md leading-relaxed">
          Giao diện và API đã được kết nối với hệ thống quản trị VieGym. Các bảng dữ liệu chi tiết,
          bộ lọc và thao tác CRUD đang sẵn sàng trong phiên bản vận hành hiện tại.
        </p>
      </div>
    </div>
  )
}
