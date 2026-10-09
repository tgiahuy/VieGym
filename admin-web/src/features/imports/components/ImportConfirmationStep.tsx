import React from 'react'
import { ConflictStrategy, ImportFileMeta } from '../types'

interface ImportConfirmationStepProps {
  fileMeta: ImportFileMeta
  conflictStrategy: ConflictStrategy
  onBack: () => void
  onCommit: () => void
  isSubmitting: boolean
}

export const ImportConfirmationStep: React.FC<ImportConfirmationStepProps> = ({
  fileMeta,
  conflictStrategy,
  onBack,
  onCommit,
  isSubmitting,
}) => {
  const strategyLabel =
    conflictStrategy === 'UPSERT'
      ? 'Cập nhật & Ghi đè (Upsert)'
      : conflictStrategy === 'SKIP'
        ? 'Bỏ qua bản ghi trùng (Skip duplicates)'
        : 'Hủy toàn bộ nếu có lỗi (Rollback Atomic)'

  const strategyDesc =
    conflictStrategy === 'UPSERT'
      ? 'Ghi đè thông tin lên các bài tập/thực phẩm đã tồn tại mã SKU. Tự động lưu phiên bản trước đó vào nhật ký kiểm toán (Audit Logs).'
      : conflictStrategy === 'SKIP'
        ? 'Chỉ nạp mới các bản ghi chưa có trong hệ thống. Bỏ qua các dòng trùng khóa chính.'
        : 'Toàn bộ 48 dòng sẽ được thực thi trong một transaction duy nhất. Bất kỳ lỗi nào xảy ra sẽ rollback 100% dữ liệu.'

  return (
    <div className="space-y-6">
      <div className="bg-[#17181b] rounded-2xl border border-[#292a2f] p-6 shadow-sm">
        <div className="flex items-center gap-2.5 mb-2">
          <span className="material-symbols-outlined text-[#35c76f] text-[22px]">
            verified
          </span>
          <h3 className="text-base font-semibold text-[#f5f5f6]">
            Xác nhận ghi dữ liệu vào cơ sở dữ liệu VieGym
          </h3>
        </div>
        <p className="text-xs text-[#a7a9ae] mb-6">
          Vui lòng kiểm tra lại thông số mẻ nạp trước khi kích hoạt quy trình commit dữ liệu chính thức.
        </p>

        {/* Breakdown summary cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
          <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f]">
            <span className="text-xs text-[#8a8d93] block">Tệp nguồn nạp</span>
            <span className="text-sm font-mono font-bold text-[#f5f5f6] mt-1 block">
              {fileMeta.fileName}
            </span>
            <span className="text-xs text-[#a7a9ae] mt-1 block">
              {fileMeta.fileSize} · {fileMeta.entityType === 'EXERCISE' ? 'Bài tập' : 'Thực phẩm'}
            </span>
          </div>

          <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f]">
            <span className="text-xs text-[#8a8d93] block">Chiến lược giải quyết trùng lặp</span>
            <span className="text-sm font-semibold text-[#ffb2b8] mt-1 block">
              {strategyLabel}
            </span>
            <span className="text-xs text-[#a7a9ae] mt-1 block">
              Áp dụng cho {fileMeta.warningRows + fileMeta.errorRows} dòng có cảnh báo/trùng mã
            </span>
          </div>

          <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f]">
            <span className="text-xs text-[#8a8d93] block">Dự kiến nạp thành công</span>
            <span className="text-2xl font-bold text-[#35c76f] font-mono mt-0.5 block">
              {conflictStrategy === 'SKIP'
                ? fileMeta.validRows
                : fileMeta.validRows + fileMeta.warningRows + (conflictStrategy === 'UPSERT' ? 1 : 0)}{' '}
              / {fileMeta.totalRows}
            </span>
            <span className="text-xs text-[#35c76f]/80 mt-0.5 block">
              Bản ghi sẵn sàng đưa vào vận hành
            </span>
          </div>
        </div>

        {/* Strategy note */}
        <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f] mb-6">
          <div className="flex items-center gap-2 text-xs font-semibold text-[#f5f5f6] mb-1">
            <span className="material-symbols-outlined text-[18px] text-[#4d8dff]">info</span>
            <span>Chi tiết cơ chế xử lý:</span>
          </div>
          <p className="text-xs text-[#a7a9ae] leading-relaxed">{strategyDesc}</p>
        </div>

        {/* Security & Audit notice */}
        <div className="p-4 rounded-xl bg-[#35c76f]/10 border border-[#35c76f]/30 flex items-start gap-3">
          <span className="material-symbols-outlined text-[#35c76f] text-xl shrink-0 mt-0.5">
            security
          </span>
          <div className="text-xs">
            <span className="font-semibold text-[#35c76f] block">
              Giao dịch nguyên tử có ghi nhận nhật ký kiểm toán (Audit Trail)
            </span>
            <span className="text-[#a7a9ae] mt-0.5 block leading-relaxed">
              Tất cả các bản ghi thêm mới hoặc sửa đổi sẽ được ký mã hóa và xuất hiện trên trang Nhật ký kiểm toán (/audit-logs). Bạn có thể khôi phục lại trạng thái cũ bất kỳ lúc nào nếu cần.
            </span>
          </div>
        </div>
      </div>

      {/* Action Buttons */}
      <div className="flex items-center justify-between">
        <button
          type="button"
          onClick={onBack}
          disabled={isSubmitting}
          className="h-11 px-5 rounded-xl border border-[#292a2f] hover:border-[#34363b] bg-[#222327] hover:bg-[#1c1d21] text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 transition-all disabled:opacity-50"
        >
          <span className="material-symbols-outlined text-[18px]">arrow_back</span>
          <span>Quay lại Bước 2</span>
        </button>

        <button
          type="button"
          onClick={onCommit}
          disabled={isSubmitting}
          className="h-11 px-7 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white text-sm font-semibold flex items-center gap-2 transition-all shadow-lg shadow-[#f2305a]/25 disabled:opacity-50"
        >
          {isSubmitting ? (
            <>
              <svg className="animate-spin h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                <path
                  className="opacity-75"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  fill="currentColor"
                />
              </svg>
              <span>Đang thực thi ghi dữ liệu...</span>
            </>
          ) : (
            <>
              <span className="material-symbols-outlined text-[18px]">save</span>
              <span>Tiến hành ghi dữ liệu (Commit Batch)</span>
            </>
          )}
        </button>
      </div>
    </div>
  )
}
