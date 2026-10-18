import React, { useCallback, useEffect, useState } from 'react'
import { AiMetricsTab } from '../components/AiMetricsTab'
import { DiffCompareModal } from '../components/DiffCompareModal'
import { PromptEditor } from '../components/PromptEditor'
import { PromptMasterList } from '../components/PromptMasterList'
import { SafetyRulesTab } from '../components/SafetyRulesTab'
import { SandboxTestModal } from '../components/SandboxTestModal'
import { VariableAllowlist } from '../components/VariableAllowlist'
import { aiRulesApi } from '../api'
import { PromptTemplateItem } from '../types'

type ActiveTab = 'safety' | 'prompts' | 'metrics'

export const AiRulesPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState<ActiveTab>('prompts')
  const [templates, setTemplates] = useState<PromptTemplateItem[]>([])
  const [selectedTemplateId, setSelectedTemplateId] = useState<string>('')
  const [editedContents, setEditedContents] = useState<Record<string, string>>({})
  const [toastMessage, setToastMessage] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isSaving, setIsSaving] = useState(false)

  // Modals
  const [isDiffOpen, setIsDiffOpen] = useState(false)
  const [isSandboxOpen, setIsSandboxOpen] = useState(false)

  const showToast = useCallback((msg: string) => {
    setToastMessage(msg)
    setTimeout(() => {
      setToastMessage(null)
    }, 3200)
  }, [])

  useEffect(() => {
    aiRulesApi.listPrompts()
      .then((items) => {
        setTemplates(items)
        setSelectedTemplateId((current) => current || items[0]?.id || '')
      })
      .catch((error: unknown) => {
        showToast(error instanceof Error ? error.message : 'Không thể tải prompt từ backend')
      })
      .finally(() => setIsLoading(false))
  }, [showToast])

  const selectedTemplate =
    templates.find((t) => t.id === selectedTemplateId) || templates[0]

  if (isLoading) {
    return <div className="p-6 text-sm text-[#a7a9ae]">Đang tải cấu hình AI từ backend...</div>
  }

  if (!selectedTemplate) {
    return <div className="p-6 text-sm text-[#ff5a5f]">Không có prompt template khả dụng.</div>
  }

  const currentContent =
    editedContents[selectedTemplate.id] !== undefined
      ? editedContents[selectedTemplate.id]!
      : selectedTemplate.content

  const handleChangeContent = (val: string) => {
    setEditedContents((prev) => ({ ...prev, [selectedTemplate.id]: val }))
  }

  const handleSelectTemplate = (tpl: PromptTemplateItem) => {
    setSelectedTemplateId(tpl.id)
  }

  const handleCopyVariable = (tag: string) => {
    navigator.clipboard.writeText(tag).then(
      () => {
        showToast(`Đã sao chép thẻ biến ${tag} vào bộ nhớ tạm`)
      },
      () => {
        showToast(`Sao chép ${tag} thất bại`)
      }
    )
  }

  const replaceTemplate = (saved: PromptTemplateItem) => {
    setTemplates((prev) => prev.map((item) => item.id === saved.id ? saved : item))
    setEditedContents((prev) => {
      const next = { ...prev }
      delete next[saved.id]
      return next
    })
  }

  const handleSaveDraft = async () => {
    setIsSaving(true)
    try {
      const saved = await aiRulesApi.saveDraft(selectedTemplate, currentContent)
      replaceTemplate(saved)
      showToast(`Server đã lưu bản nháp cho template #${selectedTemplate.code}`)
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Lưu bản nháp thất bại')
    } finally {
      setIsSaving(false)
    }
  }

  const handlePublish = async () => {
    setIsSaving(true)
    try {
      let draft = selectedTemplate
      if (currentContent !== selectedTemplate.content) {
        draft = await aiRulesApi.saveDraft(selectedTemplate, currentContent)
      }
      const published = await aiRulesApi.publish(draft)
      replaceTemplate(published)
      showToast(`Server xác nhận đã phát hành ${published.version} lên Production`)
    } catch (error) {
      showToast(error instanceof Error ? error.message : 'Phát hành thất bại')
    } finally {
      setIsSaving(false)
    }
  }

  const handleResetContent = () => {
    setEditedContents((prev) => {
      const copy = { ...prev }
      delete copy[selectedTemplate.id]
      return copy
    })
    showToast(`Đã khôi phục nội dung gốc của template`)
  }

  return (
    <div className="space-y-6 pb-20">
      {/* Toast Feedback */}
      {toastMessage && (
        <div className="fixed top-20 right-8 z-50 bg-[#222327] border border-[#35c76f]/40 text-[#f5f5f6] px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2.5 animate-fadeIn">
          <span className="material-symbols-outlined text-[#35c76f] text-xl">check_circle</span>
          <span className="text-sm font-medium">{toastMessage}</span>
        </div>
      )}

      {/* Page Header & Action Controls */}
      <section className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-2xl sm:text-3xl font-bold text-[#f5f5f6] tracking-tight">
              Quy tắc &amp; Mô hình AI
            </h1>
            <span className="px-2 py-0.5 rounded-md text-xs font-mono font-bold bg-[#222327] text-[#ffb2b8] border border-[#34363b]">
              MH50
            </span>
          </div>
          <p className="text-sm text-[#a7a9ae] mt-1 max-w-3xl">
            Kiểm soát hành vi AI, quản lý prompt templates theo use case, cấu hình quy tắc an toàn y tế và giám sát chỉ số vận hành thời gian thực.
          </p>
        </div>

        <div className="flex items-center gap-3 shrink-0">
          <button
            type="button"
            onClick={() => setIsDiffOpen(true)}
            className="h-10 px-4 rounded-xl bg-transparent hover:bg-[#222327] text-[#f5f5f6] border border-[#292a2f] hover:border-[#34363b] text-sm font-semibold flex items-center gap-2 transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-lg text-[#8a8d93]">history</span>
            <span>Lịch sử triển khai</span>
          </button>
          <button
            type="button"
            onClick={async () => {
              const newTitle = window.prompt('Nhập tên prompt template mới:', 'Custom Workout Generator')
              if (newTitle) {
                try {
                  const newTpl = await aiRulesApi.createPrompt({
                    code: `PRM-${Math.floor(1000 + Math.random() * 9000)}`,
                    useCase: 'WORKOUT_ENGINE',
                    useCaseLabel: 'WORKOUT_ENGINE',
                    title: newTitle,
                    description: 'Template tạo mới từ Admin Console',
                    model: 'configured-provider-model',
                    fallbackModel: 'Không cấu hình',
                    content: '# ROLE & TASK INSTRUCTIONS\nBạn là VieGym AI...',
                  })
                  setTemplates((prev) => [newTpl, ...prev])
                  setSelectedTemplateId(newTpl.id)
                  showToast(`Server đã tạo bản nháp template "${newTitle}"`)
                } catch (error) {
                  showToast(error instanceof Error ? error.message : 'Tạo prompt thất bại')
                }
              }
            }}
            className="h-10 px-4 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 shadow-sm transition-all cursor-pointer"
          >
            <span className="material-symbols-outlined text-lg">add</span>
            <span>+ Tạo bản nháp mới</span>
          </button>
        </div>
      </section>

      {/* Sticky Tab Bar */}
      <section className="border-b border-[#292a2f] flex items-center gap-8 text-sm">
        {/* Tab 1 */}
        <button
          type="button"
          onClick={() => setActiveTab('safety')}
          className={`pb-3 flex items-center gap-2 transition-colors cursor-pointer ${
            activeTab === 'safety'
              ? 'text-[#f5f5f6] font-semibold border-b-2 border-[#f2305a]'
              : 'text-[#a7a9ae] hover:text-[#f5f5f6]'
          }`}
        >
          <span className="material-symbols-outlined text-lg">verified_user</span>
          <span>Quy tắc an toàn</span>
          <span className="px-2 py-0.5 rounded-full text-xs font-semibold bg-[#222327] text-[#8a8d93] border border-[#292a2f]">
            Backend managed
          </span>
        </button>

        {/* Tab 2 */}
        <button
          type="button"
          onClick={() => setActiveTab('prompts')}
          className={`pb-3 flex items-center gap-2 transition-colors cursor-pointer ${
            activeTab === 'prompts'
              ? 'text-[#f5f5f6] font-semibold border-b-2 border-[#f2305a]'
              : 'text-[#a7a9ae] hover:text-[#f5f5f6]'
          }`}
        >
          <span className="material-symbols-outlined text-lg text-[#f2305a]">code_blocks</span>
          <span>Prompt templates</span>
          <span className="px-2 py-0.5 rounded-full text-xs font-semibold bg-[rgba(242,48,90,0.12)] text-[#ff506d] border border-[#ff506d]/30">
            {selectedTemplate.title.split('—')[0]}
          </span>
        </button>

        {/* Tab 3 */}
        <button
          type="button"
          onClick={() => setActiveTab('metrics')}
          className={`pb-3 flex items-center gap-2 transition-colors cursor-pointer ${
            activeTab === 'metrics'
              ? 'text-[#f5f5f6] font-semibold border-b-2 border-[#f2305a]'
              : 'text-[#a7a9ae] hover:text-[#f5f5f6]'
          }`}
        >
          <span className="material-symbols-outlined text-lg">insights</span>
          <span>Chỉ số AI</span>
          <span className="px-2 py-0.5 rounded-full text-xs font-semibold bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/30">
            Live backend
          </span>
        </button>
      </section>

      {/* Tab Contents */}
      {activeTab === 'safety' && <SafetyRulesTab onNotify={showToast} />}

      {activeTab === 'metrics' && <AiMetricsTab />}

      {activeTab === 'prompts' && (
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
          {/* Left Column: Master List (4 cols) */}
          <div className="lg:col-span-4 xl:col-span-4">
            <PromptMasterList
              templates={templates}
              selectedTemplateId={selectedTemplate.id}
              onSelectTemplate={handleSelectTemplate}
            />
          </div>

          {/* Right Column: Editor & Allowlist (8 cols) */}
          <div className="lg:col-span-8 xl:col-span-8 flex flex-col gap-4">
            <PromptEditor
              template={selectedTemplate}
              content={currentContent}
              onChangeContent={handleChangeContent}
              onOpenDiff={() => setIsDiffOpen(true)}
              onOpenSandbox={() => setIsSandboxOpen(true)}
            />

            <VariableAllowlist onCopyVariable={handleCopyVariable} />
          </div>
        </div>
      )}

      {/* Fixed Bottom Action Footer (72px) */}
      <footer className="fixed bottom-0 right-0 left-0 md:left-64 h-[72px] bg-[#17181b]/95 backdrop-blur-md border-t border-[#292a2f] px-6 sm:px-8 flex items-center justify-between z-30 shadow-2xl">
        {/* Autosave info */}
        <div className="flex items-center gap-2 text-xs text-[#8a8d93]">
          <span className="w-2 h-2 rounded-full bg-[#35c76f]" />
          <span className="hidden sm:inline">
            Chỉ hiển thị thành công sau khi server xác nhận
          </span>
          <span className="sm:hidden">Server-backed</span>
        </div>

        {/* Actions */}
        <div className="flex items-center gap-2 sm:gap-3">
          <button
            type="button"
            onClick={handleResetContent}
            className="h-10 sm:h-11 px-3 sm:px-4 rounded-xl bg-transparent hover:bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6] border border-[#292a2f] hover:border-[#34363b] text-xs sm:text-sm font-semibold transition-colors cursor-pointer"
          >
            Huỷ thay đổi
          </button>
          <button
            type="button"
            onClick={() => void handleSaveDraft()}
            disabled={isSaving}
            className="h-10 sm:h-11 px-4 sm:px-5 rounded-xl bg-[#222327] hover:bg-[#1c1d21] text-[#f5f5f6] border border-[#292a2f] hover:border-[#34363b] text-xs sm:text-sm font-semibold flex items-center gap-2 transition-colors cursor-pointer"
          >
            <span className="material-symbols-outlined text-base text-[#8a8d93]">save</span>
            <span>Lưu bản nháp (Draft)</span>
          </button>
          <button
            type="button"
            onClick={() => void handlePublish()}
            disabled={isSaving}
            className="h-10 sm:h-11 px-4 sm:px-6 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-[#f5f5f6] text-xs sm:text-sm font-semibold flex items-center gap-2 shadow-lg shadow-[#f2305a]/20 transition-all cursor-pointer"
          >
            <span className="material-symbols-outlined text-base">rocket_launch</span>
            <span>{isSaving ? 'Đang xử lý...' : 'Phát hành lên Production'}</span>
          </button>
        </div>
      </footer>

      {/* Modals */}
      <DiffCompareModal isOpen={isDiffOpen} onClose={() => setIsDiffOpen(false)} />
      <SandboxTestModal
        isOpen={isSandboxOpen}
        template={selectedTemplate}
        onClose={() => setIsSandboxOpen(false)}
      />
    </div>
  )
}
