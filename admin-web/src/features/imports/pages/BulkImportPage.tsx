import React, { useMemo, useState } from 'react'
import { ConflictStrategySelector } from '../components/ConflictStrategySelector'
import { ImportConfirmationStep } from '../components/ImportConfirmationStep'
import { ImportFileUploadStep } from '../components/ImportFileUploadStep'
import { ImportHistoryModal } from '../components/ImportHistoryModal'
import { ImportPreviewTable } from '../components/ImportPreviewTable'
import { ImportResultStep } from '../components/ImportResultStep'
import { ImportWizardStepper } from '../components/ImportWizardStepper'
import { SchemaRulesModal } from '../components/SchemaRulesModal'
import { ValidationKpiCards } from '../components/ValidationKpiCards'
import {
  INITIAL_FILE_META,
  MOCK_IMPORT_HISTORY,
  MOCK_IMPORT_ROWS,
} from '../mockData'
import {
  ConflictStrategy,
  ImportEntityType,
  ImportFileMeta,
  ImportStep,
} from '../types'

export const BulkImportPage: React.FC = () => {
  const [currentStep, setCurrentStep] = useState<ImportStep>(2)
  const [fileMeta, setFileMeta] = useState<ImportFileMeta>(INITIAL_FILE_META)
  const [conflictStrategy, setConflictStrategy] = useState<ConflictStrategy>('UPSERT')
  const [activeFilter, setActiveFilter] = useState<'ALL' | 'ERRORS_WARNINGS' | 'VALID'>('ALL')
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [toastMessage, setToastMessage] = useState<string | null>(null)

  // Modals state
  const [isHistoryOpen, setIsHistoryOpen] = useState(false)
  const [isSchemaOpen, setIsSchemaOpen] = useState(false)

  const showToast = (msg: string) => {
    setToastMessage(msg)
    setTimeout(() => {
      setToastMessage(null)
    }, 3200)
  }

  // Filtered rows for Step 2
  const filteredRows = useMemo(() => {
    if (activeFilter === 'VALID') {
      return MOCK_IMPORT_ROWS.filter((r) => r.status === 'VALID')
    }
    if (activeFilter === 'ERRORS_WARNINGS') {
      return MOCK_IMPORT_ROWS.filter(
        (r) =>
          r.status === 'WARNING' ||
          r.status === 'ERROR_ENUM' ||
          r.status === 'ERROR_DUPLICATE' ||
          r.status === 'ERROR_REQUIRED'
      )
    }
    return MOCK_IMPORT_ROWS
  }, [activeFilter])

  const totalCount = fileMeta.totalRows
  const errorWarningCount = fileMeta.warningRows + fileMeta.errorRows
  const validCount = fileMeta.validRows

  const handleDownloadTemplate = (format: 'CSV' | 'XLSX') => {
    const fileName =
      fileMeta.entityType === 'EXERCISE'
        ? `viegym_exercise_template.${format.toLowerCase()}`
        : `viegym_food_template.${format.toLowerCase()}`
    const blob = new Blob(
      [
        fileMeta.entityType === 'EXERCISE'
          ? 'sku,name_vi,name_en,primary_muscle,equipment,difficulty_level\nEX-0001,Hít đất,Push Up,Chest,Bodyweight,BEGINNER'
          : 'sku,name_vi,portion_amount,calories,protein_g,carbs_g,fat_g\nFD-0001,Ức gà,100,165,31.0,0.0,3.6',
      ],
      { type: 'text/csv;charset=utf-8;' }
    )
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = fileName
    link.click()
    URL.revokeObjectURL(url)
    showToast(`Đã tải xuống ${fileName}`)
  }

  const handleDownloadErrorReport = () => {
    const errorRows = MOCK_IMPORT_ROWS.filter(
      (r) => r.status !== 'VALID'
    )
    const csvContent =
      'Dòng,SKU,Tên,Lỗi,Gợi ý sửa\n' +
      errorRows
        .map(
          (r) =>
            `${r.rowNumber},"${r.sku}","${r.nameVi}","${r.validationTitle}: ${r.validationDetail}","${r.suggestedFix || 'N/A'}"`
        )
        .join('\n')

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `error_report_${fileMeta.fileName}.csv`
    link.click()
    URL.revokeObjectURL(url)
    showToast('Đã xuất báo cáo chi tiết các lỗi kiểm tra (.CSV)')
  }

  const handleFileSelect = (file: File) => {
    setFileMeta((prev) => ({
      ...prev,
      fileName: file.name,
      fileSize: `${(file.size / 1024 / 1024).toFixed(2)} MB`,
      uploadedAt: `${new Date().toLocaleTimeString('vi-VN')} - ${new Date().toLocaleDateString('vi-VN')}`,
    }))
    showToast(`Đã nạp tệp "${file.name}" thành công`)
    setCurrentStep(2)
  }

  const handleEntityTypeChange = (type: ImportEntityType) => {
    setFileMeta((prev) => ({
      ...prev,
      entityType: type,
      fileName:
        type === 'EXERCISE'
          ? 'exercises_viegym_batch_v2.csv'
          : 'vietnam_nutrition_table_2026.csv',
    }))
  }

  const handleCommitBatch = () => {
    setIsSubmitting(true)
    setTimeout(() => {
      setIsSubmitting(false)
      setCurrentStep(4)
      showToast('Ghi dữ liệu hàng loạt thành công vào cơ sở dữ liệu VieGym!')
    }, 1200)
  }

  const handleResetImport = () => {
    setCurrentStep(1)
    setActiveFilter('ALL')
    showToast('Sẵn sàng cho mẻ nạp mới')
  }

  return (
    <div className="space-y-6">
      {/* Toast Feedback */}
      {toastMessage && (
        <div className="fixed top-20 right-8 z-50 bg-[#222327] border border-[#35c76f]/40 text-[#f5f5f6] px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2.5 animate-fadeIn">
          <span className="material-symbols-outlined text-[#35c76f] text-xl">
            check_circle
          </span>
          <span className="text-sm font-medium">{toastMessage}</span>
        </div>
      )}

      {/* Page Title & Top Actions */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl sm:text-3xl font-bold text-[#f5f5f6] tracking-tight">
              Nhập dữ liệu hàng loạt
            </h1>
            <span className="ml-1 px-2 py-0.5 rounded text-[11px] bg-[#ff506d]/10 text-[#ff506d] border border-[#ff506d]/30 font-semibold">
              MH48
            </span>
          </div>
          <p className="text-sm text-[#a7a9ae] mt-1">
            Thêm và cập nhật nhiều bài tập hoặc thực phẩm từ tệp CSV/XLSX với quy trình kiểm định an toàn
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={() => setIsHistoryOpen(true)}
            className="h-11 px-4 rounded-xl border border-[#292a2f] hover:border-[#34363b] bg-[#17181b] hover:bg-[#222327] text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 transition-all"
          >
            <span className="material-symbols-outlined text-[18px]">history</span>
            <span>Lịch sử nhập dữ liệu</span>
          </button>
          <button
            type="button"
            onClick={() => setIsSchemaOpen(true)}
            className="h-11 px-4 rounded-xl bg-[#17181b] hover:bg-[#222327] border border-[#292a2f] text-[#a7a9ae] hover:text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 transition-all"
          >
            <span className="material-symbols-outlined text-[18px]">tune</span>
            <span>Quy tắc schema</span>
          </button>
        </div>
      </div>

      {/* 4-Step Wizard Stepper */}
      <ImportWizardStepper
        currentStep={currentStep}
        onStepClick={(step) => setCurrentStep(step)}
      />

      {/* STEP 1: FILE UPLOAD */}
      {currentStep === 1 && (
        <ImportFileUploadStep
          entityType={fileMeta.entityType}
          onEntityTypeChange={handleEntityTypeChange}
          fileMeta={fileMeta}
          onFileSelect={handleFileSelect}
          onDownloadTemplate={handleDownloadTemplate}
          onNextStep={() => setCurrentStep(2)}
        />
      )}

      {/* STEP 2: MAPPING & VALIDATION PREVIEW */}
      {currentStep === 2 && (
        <div className="flex flex-col gap-6 pb-20">
          {/* Top File Context & Source Bar */}
          <div className="bg-[#17181b] rounded-2xl border border-[#292a2f] p-5 shadow-sm">
            <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
              {/* Left: Target entity & File specs */}
              <div className="flex flex-wrap items-center gap-4">
                <div className="px-3 py-1.5 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center gap-2">
                  <span className="text-xs text-[#8a8d93]">Loại dữ liệu:</span>
                  <span className="text-xs font-semibold text-[#f5f5f6] flex items-center gap-1.5">
                    <span className="material-symbols-outlined text-[#ff506d] text-[18px]">
                      {fileMeta.entityType === 'EXERCISE' ? 'fitness_center' : 'restaurant'}
                    </span>
                    {fileMeta.entityType === 'EXERCISE'
                      ? 'Bài tập (Exercise Catalog)'
                      : 'Thực phẩm & Macro (Food Nutrition)'}
                  </span>
                </div>

                {/* Uploaded file pill */}
                <div className="px-3 py-1.5 rounded-xl bg-[#222327] border border-[#292a2f] flex items-center gap-3">
                  <span className="material-symbols-outlined text-[#35c76f] text-[20px]">
                    description
                  </span>
                  <div className="flex flex-col">
                    <div className="flex items-center gap-2">
                      <span className="font-semibold text-[#f5f5f6] font-mono text-xs">
                        {fileMeta.fileName}
                      </span>
                      <span className="text-[10px] px-1.5 py-0.2 rounded bg-[#35c76f]/15 text-[#35c76f] font-semibold border border-[#35c76f]/30">
                        Đã nạp
                      </span>
                    </div>
                    <span className="text-[11px] text-[#8a8d93]">
                      {fileMeta.fileSize} · {fileMeta.totalRows} dòng · Tải lúc {fileMeta.uploadedAt}
                    </span>
                  </div>
                  <button
                    type="button"
                    onClick={() => setCurrentStep(1)}
                    className="ml-2 text-xs text-[#a7a9ae] hover:text-[#f5f5f6] underline transition-colors"
                  >
                    Thay đổi file
                  </button>
                </div>
              </div>

              {/* Right: Standard template downloads */}
              <div className="flex items-center gap-2 self-start lg:self-auto">
                <button
                  type="button"
                  onClick={() => handleDownloadTemplate('CSV')}
                  className="h-9 px-3 rounded-lg border border-[#292a2f] hover:border-[#34363b] bg-[#222327] hover:bg-[#1c1d21] text-[#a7a9ae] hover:text-[#f5f5f6] text-xs font-semibold flex items-center gap-1.5 transition-colors"
                >
                  <span className="material-symbols-outlined text-[16px]">file_download</span>
                  Tải file mẫu chuẩn (.CSV)
                </button>
                <button
                  type="button"
                  onClick={() => handleDownloadTemplate('XLSX')}
                  className="h-9 px-3 rounded-lg border border-[#292a2f] hover:border-[#34363b] bg-[#222327] hover:bg-[#1c1d21] text-[#a7a9ae] hover:text-[#f5f5f6] text-xs font-semibold flex items-center gap-1.5 transition-colors"
                >
                  <span className="material-symbols-outlined text-[16px]">table_view</span>
                  Tải file mẫu (.XLSX)
                </button>
              </div>
            </div>
          </div>

          {/* Validation Summary KPIs Bar (4 Cards) */}
          <ValidationKpiCards
            fileMeta={fileMeta}
            activeFilter={activeFilter}
            onSelectFilter={setActiveFilter}
          />

          {/* Data Mapping & Preview Table */}
          <ImportPreviewTable
            rows={filteredRows}
            activeFilter={activeFilter}
            onFilterChange={setActiveFilter}
            onRefresh={() => showToast('Đã làm mới dữ liệu kiểm tra')}
            totalRowsCount={totalCount}
            errorWarningCount={errorWarningCount}
            validCount={validCount}
          />

          {/* Duplicate Conflict Strategy Selector */}
          <ConflictStrategySelector
            strategy={conflictStrategy}
            onChange={setConflictStrategy}
          />

          {/* Safety Notice Banner */}
          <div className="p-4 rounded-xl bg-[#ff5a5f]/10 border border-[#ff5a5f]/30 flex items-start gap-3">
            <span className="material-symbols-outlined text-[#ff5a5f] text-[22px] shrink-0 mt-0.5">
              shield
            </span>
            <div className="flex flex-col text-xs">
              <span className="font-semibold text-[#ff5a5f]">
                Quy tắc an toàn hệ thống (System Safety Protocol)
              </span>
              <p className="text-[#a7a9ae] mt-0.5">
                Hệ thống phát hiện còn <strong className="text-[#ff5a5f]">1 dòng lỗi enum cấu trúc nghiêm trọng (Dòng #3)</strong> chưa được xử lý. Bạn cần chỉnh sửa trực tiếp trên file và tải lại hoặc loại bỏ dòng này trước khi chuyển sang Bước 3: Xác nhận ghi dữ liệu.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* STEP 3: CONFIRMATION */}
      {currentStep === 3 && (
        <ImportConfirmationStep
          fileMeta={fileMeta}
          conflictStrategy={conflictStrategy}
          onBack={() => setCurrentStep(2)}
          onCommit={handleCommitBatch}
          isSubmitting={isSubmitting}
        />
      )}

      {/* STEP 4: RESULT */}
      {currentStep === 4 && (
        <ImportResultStep
          fileMeta={fileMeta}
          conflictStrategy={conflictStrategy}
          onReset={handleResetImport}
          onDownloadReport={handleDownloadErrorReport}
        />
      )}

      {/* Sticky Wizard Action Footer for Step 2 */}
      {currentStep === 2 && (
        <footer className="fixed bottom-0 right-0 left-64 h-[72px] bg-[#17181b] border-t border-[#292a2f] px-8 flex items-center justify-between z-30 shadow-2xl">
          {/* Left: Previous Step */}
          <div>
            <button
              type="button"
              onClick={() => setCurrentStep(1)}
              className="h-11 px-5 rounded-xl border border-[#292a2f] hover:border-[#34363b] bg-[#222327] hover:bg-[#1c1d21] text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 transition-all"
            >
              <span className="material-symbols-outlined text-[18px]">arrow_back</span>
              <span>Quay lại Bước 1</span>
            </button>
          </div>

          {/* Right: Action cluster */}
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={handleDownloadErrorReport}
              className="h-11 px-4 rounded-xl border border-[#292a2f] hover:border-[#34363b] bg-transparent hover:bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 transition-all"
            >
              <span className="material-symbols-outlined text-[18px]">download</span>
              <span>Tải báo cáo lỗi (.CSV)</span>
            </button>
            <button
              type="button"
              onClick={handleResetImport}
              className="h-11 px-4 rounded-xl bg-transparent hover:bg-[#222327] text-[#8a8d93] hover:text-[#f5f5f6] text-sm font-semibold transition-all"
            >
              Hủy bỏ
            </button>
            {/* Primary Action */}
            <button
              type="button"
              onClick={() => setCurrentStep(3)}
              className="h-11 px-6 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white text-sm font-semibold flex items-center gap-2 transition-all shadow-lg shadow-[#f2305a]/25"
            >
              <span>Tiếp tục: Xác nhận ghi dữ liệu</span>
              <span className="material-symbols-outlined text-[18px]">arrow_forward</span>
            </button>
          </div>
        </footer>
      )}

      {/* History Modal */}
      <ImportHistoryModal
        isOpen={isHistoryOpen}
        onClose={() => setIsHistoryOpen(false)}
        historyList={MOCK_IMPORT_HISTORY}
      />

      {/* Schema Rules Modal */}
      <SchemaRulesModal
        isOpen={isSchemaOpen}
        onClose={() => setIsSchemaOpen(false)}
        initialType={fileMeta.entityType}
      />
    </div>
  )
}
