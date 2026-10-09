import React from 'react'
import { ConflictStrategy } from '../types'

interface ConflictStrategySelectorProps {
  strategy: ConflictStrategy
  onChange: (strategy: ConflictStrategy) => void
}

export const ConflictStrategySelector: React.FC<ConflictStrategySelectorProps> = ({
  strategy,
  onChange,
}) => {
  return (
    <div className="bg-[#17181b] rounded-2xl border border-[#292a2f] p-6 shadow-sm">
      <div className="flex items-center gap-2.5 mb-2">
        <span className="material-symbols-outlined text-[#ff506d] text-[22px]">policy</span>
        <h3 className="text-base font-semibold text-[#f5f5f6]">
          Chiến lược xử lý bản ghi trùng lặp (Conflict Resolution Strategy)
        </h3>
      </div>
      <p className="text-xs text-[#a7a9ae] mb-5">
        Lựa chọn cơ chế hành vi của hệ thống khi phát hiện mã SKU hoặc tên bài tập đã tồn tại trong cơ sở dữ liệu VieGym.
      </p>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Option 1: UPSERT */}
        <label
          onClick={() => onChange('UPSERT')}
          className={`relative flex flex-col p-4 rounded-xl cursor-pointer transition-all ${
            strategy === 'UPSERT'
              ? 'border-2 border-[#ff506d] bg-[#222327]'
              : 'border border-[#292a2f] hover:border-[#34363b] bg-[#17181b] hover:bg-[#1c1d21]'
          }`}
        >
          <div className="flex items-start justify-between">
            <div className="flex items-center gap-2">
              <input
                type="radio"
                name="conflict_strategy"
                checked={strategy === 'UPSERT'}
                onChange={() => onChange('UPSERT')}
                className="w-4 h-4 text-[#ff506d] bg-[#0f1012] border-[#34363b] focus:ring-[#ff506d]"
              />
              <span className="text-xs font-semibold text-[#f5f5f6]">
                Cập nhật (Upsert &amp; Ghi đè)
              </span>
            </div>
            <span className="text-[10px] px-1.5 py-0.5 rounded bg-[#ff506d]/20 text-[#ffb2b8] font-mono font-semibold">
              Khuyên dùng
            </span>
          </div>
          <p className="text-[11px] text-[#a7a9ae] mt-2.5 leading-relaxed">
            Ghi đè thông tin mới lên bài tập đã tồn tại. Toàn bộ thay đổi sẽ được tạo phiên bản mới trong nhật ký kiểm toán nhằm phục vụ rollback khi cần.
          </p>
        </label>

        {/* Option 2: SKIP */}
        <label
          onClick={() => onChange('SKIP')}
          className={`relative flex flex-col p-4 rounded-xl cursor-pointer transition-all ${
            strategy === 'SKIP'
              ? 'border-2 border-[#ff506d] bg-[#222327]'
              : 'border border-[#292a2f] hover:border-[#34363b] bg-[#17181b] hover:bg-[#1c1d21]'
          }`}
        >
          <div className="flex items-start justify-between">
            <div className="flex items-center gap-2">
              <input
                type="radio"
                name="conflict_strategy"
                checked={strategy === 'SKIP'}
                onChange={() => onChange('SKIP')}
                className="w-4 h-4 text-[#ff506d] bg-[#0f1012] border-[#34363b] focus:ring-[#ff506d]"
              />
              <span className="text-xs font-semibold text-[#f5f5f6]">
                Bỏ qua (Skip duplicates)
              </span>
            </div>
          </div>
          <p className="text-[11px] text-[#a7a9ae] mt-2.5 leading-relaxed">
            Giữ nguyên bài tập cũ trên hệ thống, chỉ thêm mới các bài tập có mã SKU chưa từng xuất hiện. Các dòng trùng lặp được xuất vào file báo cáo.
          </p>
        </label>

        {/* Option 3: ROLLBACK */}
        <label
          onClick={() => onChange('ROLLBACK')}
          className={`relative flex flex-col p-4 rounded-xl cursor-pointer transition-all ${
            strategy === 'ROLLBACK'
              ? 'border-2 border-[#ff506d] bg-[#222327]'
              : 'border border-[#292a2f] hover:border-[#34363b] bg-[#17181b] hover:bg-[#1c1d21]'
          }`}
        >
          <div className="flex items-start justify-between">
            <div className="flex items-center gap-2">
              <input
                type="radio"
                name="conflict_strategy"
                checked={strategy === 'ROLLBACK'}
                onChange={() => onChange('ROLLBACK')}
                className="w-4 h-4 text-[#ff506d] bg-[#0f1012] border-[#34363b] focus:ring-[#ff506d]"
              />
              <span className="text-xs font-semibold text-[#f5f5f6]">
                Dừng toàn bộ (Rollback Atomic)
              </span>
            </div>
          </div>
          <p className="text-[11px] text-[#a7a9ae] mt-2.5 leading-relaxed">
            Hủy toàn bộ giao dịch nếu có bất kỳ bản ghi nào trùng lặp hoặc lỗi. Đảm bảo tính toàn vẹn 100% của cơ sở dữ liệu.
          </p>
        </label>
      </div>
    </div>
  )
}
