import React, { useRef, useState } from 'react'
import { ImportEntityType, ImportFileMeta } from '../types'

interface ImportFileUploadStepProps {
  entityType: ImportEntityType
  onEntityTypeChange: (type: ImportEntityType) => void
  fileMeta: ImportFileMeta
  onFileSelect: (file: File) => void
  onDownloadTemplate: (format: 'CSV' | 'XLSX') => void
  onNextStep: () => void
}

export const ImportFileUploadStep: React.FC<ImportFileUploadStepProps> = ({
  entityType,
  onEntityTypeChange,
  fileMeta,
  onFileSelect,
  onDownloadTemplate,
  onNextStep,
}) => {
  const fileInputRef = useRef<HTMLInputElement>(null)
  const [isDragging, setIsDragging] = useState(false)

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(true)
  }

  const handleDragLeave = () => {
    setIsDragging(false)
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      onFileSelect(e.dataTransfer.files[0])
    }
  }

  const handleFileInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      onFileSelect(e.target.files[0])
    }
  }

  return (
    <div className="space-y-6">
      {/* Target Entity Selector Card */}
      <div className="bg-[#17181b] rounded-2xl border border-[#292a2f] p-6 shadow-sm">
        <div className="flex items-center gap-2.5 mb-2">
          <span className="material-symbols-outlined text-[#ff506d] text-[22px]">
            category
          </span>
          <h3 className="text-base font-semibold text-[#f5f5f6]">
            1. Chọn loại danh mục dữ liệu cần nạp
          </h3>
        </div>
        <p className="text-xs text-[#a7a9ae] mb-4">
          Xác định cấu trúc bảng và luật validation tương ứng để hệ thống kiểm tra đối chiếu.
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <button
            type="button"
            onClick={() => onEntityTypeChange('EXERCISE')}
            className={`p-4 rounded-xl border text-left transition-all flex items-start gap-3.5 ${
              entityType === 'EXERCISE'
                ? 'border-[#ff506d] bg-[#222327] ring-1 ring-[#ff506d]/30'
                : 'border-[#292a2f] bg-[#17181b] hover:bg-[#1c1d21]'
            }`}
          >
            <div className="w-10 h-10 rounded-xl bg-[#ff506d]/15 text-[#ff506d] flex items-center justify-center shrink-0">
              <span className="material-symbols-outlined text-2xl">fitness_center</span>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold text-[#f5f5f6]">
                  Bài tập (Exercise Catalog)
                </span>
                {entityType === 'EXERCISE' && (
                  <span className="text-[10px] px-2 py-0.5 rounded-full bg-[#ff506d]/20 text-[#ffb2b8] font-semibold">
                    Đang chọn
                  </span>
                )}
              </div>
              <p className="text-xs text-[#a7a9ae] mt-1">
                Bao gồm mã SKU, nhóm cơ chính/phụ, video hướng dẫn, thiết bị và độ khó.
              </p>
            </div>
          </button>

          <button
            type="button"
            onClick={() => onEntityTypeChange('FOOD')}
            className={`p-4 rounded-xl border text-left transition-all flex items-start gap-3.5 ${
              entityType === 'FOOD'
                ? 'border-[#ff506d] bg-[#222327] ring-1 ring-[#ff506d]/30'
                : 'border-[#292a2f] bg-[#17181b] hover:bg-[#1c1d21]'
            }`}
          >
            <div className="w-10 h-10 rounded-xl bg-[#2cc7b5]/15 text-[#2cc7b5] flex items-center justify-center shrink-0">
              <span className="material-symbols-outlined text-2xl">restaurant</span>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="text-sm font-semibold text-[#f5f5f6]">
                  Thực phẩm &amp; Macro (Food Nutrition)
                </span>
                {entityType === 'FOOD' && (
                  <span className="text-[10px] px-2 py-0.5 rounded-full bg-[#2cc7b5]/20 text-[#2cc7b5] font-semibold">
                    Đang chọn
                  </span>
                )}
              </div>
              <p className="text-xs text-[#a7a9ae] mt-1">
                Bao gồm khẩu phần tiêu chuẩn (100g), Calories, Protein, Carbs, Fat và Micronutrients.
              </p>
            </div>
          </button>
        </div>
      </div>

      {/* File Upload Dropzone */}
      <div className="bg-[#17181b] rounded-2xl border border-[#292a2f] p-6 shadow-sm">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-4">
          <div>
            <div className="flex items-center gap-2.5">
              <span className="material-symbols-outlined text-[#35c76f] text-[22px]">
                cloud_upload
              </span>
              <h3 className="text-base font-semibold text-[#f5f5f6]">
                2. Tải tệp dữ liệu lên hệ thống
              </h3>
            </div>
            <p className="text-xs text-[#a7a9ae] mt-1">
              Chấp nhận định dạng file .CSV (UTF-8) hoặc .XLSX Microsoft Excel (Tối đa 25MB)
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => onDownloadTemplate('CSV')}
              className="h-9 px-3 rounded-lg border border-[#292a2f] hover:border-[#34363b] bg-[#222327] hover:bg-[#1c1d21] text-[#a7a9ae] hover:text-[#f5f5f6] text-xs font-semibold flex items-center gap-1.5 transition-colors"
            >
              <span className="material-symbols-outlined text-[16px]">file_download</span>
              Tải file mẫu chuẩn (.CSV)
            </button>
            <button
              type="button"
              onClick={() => onDownloadTemplate('XLSX')}
              className="h-9 px-3 rounded-lg border border-[#292a2f] hover:border-[#34363b] bg-[#222327] hover:bg-[#1c1d21] text-[#a7a9ae] hover:text-[#f5f5f6] text-xs font-semibold flex items-center gap-1.5 transition-colors"
            >
              <span className="material-symbols-outlined text-[16px]">table_view</span>
              Tải file mẫu (.XLSX)
            </button>
          </div>
        </div>

        {/* Drag & drop box */}
        <div
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          onDrop={handleDrop}
          onClick={() => fileInputRef.current?.click()}
          className={`border-2 border-dashed rounded-2xl p-8 flex flex-col items-center justify-center text-center cursor-pointer transition-all ${
            isDragging
              ? 'border-[#ff506d] bg-[#ff506d]/10'
              : 'border-[#292a2f] hover:border-[#34363b] bg-[#0f1012]/60 hover:bg-[#1c1d21]'
          }`}
        >
          <input
            ref={fileInputRef}
            type="file"
            accept=".csv,.xlsx"
            onChange={handleFileInputChange}
            className="hidden"
          />

          <div className="w-14 h-14 rounded-2xl bg-[#ff506d]/15 text-[#ff506d] flex items-center justify-center mb-3">
            <span className="material-symbols-outlined text-3xl">upload_file</span>
          </div>

          <span className="text-sm font-semibold text-[#f5f5f6]">
            Kéo thả tệp CSV hoặc Excel vào đây, hoặc click để chọn tệp
          </span>
          <span className="text-xs text-[#8a8d93] mt-1">
            Được mã hóa UTF-8 an toàn, tối đa 5,000 dòng mỗi mẻ
          </span>

          {/* Current File Display */}
          <div className="mt-5 px-4 py-2.5 rounded-xl bg-[#17181b] border border-[#292a2f] flex items-center gap-3">
            <span className="material-symbols-outlined text-[#35c76f] text-xl">
              check_circle
            </span>
            <div className="text-left">
              <span className="text-xs font-mono font-medium text-[#f5f5f6] block">
                {fileMeta.fileName}
              </span>
              <span className="text-[11px] text-[#8a8d93]">
                {fileMeta.fileSize} · {fileMeta.totalRows} dòng · Nạp lúc {fileMeta.uploadedAt}
              </span>
            </div>
            <span className="ml-3 text-[11px] px-2 py-0.5 rounded bg-[#35c76f]/15 text-[#35c76f] font-semibold border border-[#35c76f]/30">
              Đã sẵn sàng
            </span>
          </div>
        </div>
      </div>

      {/* Action Next */}
      <div className="flex items-center justify-end">
        <button
          type="button"
          onClick={onNextStep}
          className="h-11 px-6 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white text-sm font-semibold flex items-center gap-2 transition-all shadow-lg shadow-[#f2305a]/25"
        >
          <span>Tiếp tục: Bước 2 (Ánh xạ &amp; Kiểm tra)</span>
          <span className="material-symbols-outlined text-[18px]">arrow_forward</span>
        </button>
      </div>
    </div>
  )
}
