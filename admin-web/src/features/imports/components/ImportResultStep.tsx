import React from 'react'
import { Link } from 'react-router-dom'
import { ConflictStrategy, ImportFileMeta } from '../types'

interface ImportResultStepProps {
  fileMeta: ImportFileMeta
  conflictStrategy: ConflictStrategy
  onReset: () => void
  onDownloadReport: () => void
}

export const ImportResultStep: React.FC<ImportResultStepProps> = ({
  fileMeta,
  conflictStrategy,
  onReset,
  onDownloadReport,
}) => {
  const successCount =
    conflictStrategy === 'SKIP'
      ? fileMeta.validRows
      : fileMeta.validRows + fileMeta.warningRows + (conflictStrategy === 'UPSERT' ? 1 : 0)
  const skippedCount = conflictStrategy === 'SKIP' ? fileMeta.warningRows + 2 : 0
  const errorCount = conflictStrategy === 'ROLLBACK' ? 0 : 1

  const targetLink =
    fileMeta.entityType === 'EXERCISE' ? '/exercises' : '/foods'
  const targetLabel =
    fileMeta.entityType === 'EXERCISE'
      ? 'Xem danh mục bài tập'
      : 'Xem danh mục thực phẩm'

  return (
    <div className="space-y-6">
      <div className="bg-[#17181b] rounded-2xl border border-[#292a2f] p-8 shadow-sm text-center">
        {/* Success Icon */}
        <div className="w-16 h-16 rounded-2xl bg-[#35c76f]/20 border-2 border-[#35c76f] text-[#35c76f] flex items-center justify-center mx-auto mb-4 shadow-lg shadow-[#35c76f]/20">
          <span className="material-symbols-outlined text-4xl">task_alt</span>
        </div>

        <h2 className="text-2xl font-bold text-[#f5f5f6] tracking-tight">
          Nạp dữ liệu hàng loạt thành công!
        </h2>
        <p className="text-sm text-[#a7a9ae] mt-1.5 max-w-xl mx-auto">
          Mẻ dữ liệu từ tệp <strong className="text-[#f5f5f6] font-mono">{fileMeta.fileName}</strong> đã được đồng bộ an toàn vào cơ sở dữ liệu VieGym.
        </p>

        {/* Results Metric Grid */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mt-8 max-w-3xl mx-auto text-left">
          <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f]">
            <span className="text-xs text-[#8a8d93] block">Tổng số dòng nạp</span>
            <span className="text-2xl font-bold font-mono text-[#f5f5f6] mt-1 block">
              {fileMeta.totalRows}
            </span>
          </div>

          <div className="p-4 rounded-xl bg-[#222327] border border-[#35c76f]/30">
            <span className="text-xs text-[#35c76f] font-semibold block">Ghi thành công</span>
            <span className="text-2xl font-bold font-mono text-[#35c76f] mt-1 block">
              {successCount}
            </span>
          </div>

          <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f]">
            <span className="text-xs text-[#a7a9ae] block">Bỏ qua (Trùng)</span>
            <span className="text-2xl font-bold font-mono text-[#a7a9ae] mt-1 block">
              {skippedCount}
            </span>
          </div>

          <div className="p-4 rounded-xl bg-[#222327] border border-[#292a2f]">
            <span className="text-xs text-[#ff5a5f] block">Lỗi không hợp lệ</span>
            <span className="text-2xl font-bold font-mono text-[#ff5a5f] mt-1 block">
              {errorCount}
            </span>
          </div>
        </div>

        {/* Action Buttons Cluster */}
        <div className="flex flex-wrap items-center justify-center gap-3 mt-8">
          <Link
            to={targetLink}
            className="h-11 px-6 rounded-xl bg-[#ff506d] hover:bg-[#d52b50] text-white text-sm font-semibold flex items-center gap-2 transition-all shadow-md shadow-[#ff506d]/20"
          >
            <span className="material-symbols-outlined text-[18px]">visibility</span>
            <span>{targetLabel}</span>
          </Link>

          <Link
            to="/audit-logs"
            className="h-11 px-5 rounded-xl border border-[#292a2f] hover:border-[#34363b] bg-[#222327] hover:bg-[#1c1d21] text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 transition-all"
          >
            <span className="material-symbols-outlined text-[18px]">history</span>
            <span>Kiểm tra Audit Log</span>
          </Link>

          <button
            type="button"
            onClick={onDownloadReport}
            className="h-11 px-5 rounded-xl border border-[#292a2f] hover:border-[#34363b] bg-[#222327] hover:bg-[#1c1d21] text-[#a7a9ae] hover:text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 transition-all"
          >
            <span className="material-symbols-outlined text-[18px]">download</span>
            <span>Tải báo cáo kết quả (.CSV)</span>
          </button>

          <button
            type="button"
            onClick={onReset}
            className="h-11 px-5 rounded-xl border border-[#292a2f] hover:border-[#34363b] bg-transparent hover:bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 transition-all"
          >
            <span className="material-symbols-outlined text-[18px]">add</span>
            <span>Nhập mẻ dữ liệu mới</span>
          </button>
        </div>
      </div>
    </div>
  )
}
