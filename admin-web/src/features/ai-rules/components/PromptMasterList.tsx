import React, { useState } from 'react'
import { PromptTemplateItem } from '../types'

interface PromptMasterListProps {
  templates: PromptTemplateItem[]
  selectedTemplateId: string
  onSelectTemplate: (template: PromptTemplateItem) => void
}

export const PromptMasterList: React.FC<PromptMasterListProps> = ({
  templates,
  selectedTemplateId,
  onSelectTemplate,
}) => {
  const [search, setSearch] = useState('')
  const [useCaseFilter, setUseCaseFilter] = useState('ALL')

  const filtered = templates.filter((tpl) => {
    if (search.trim()) {
      const q = search.toLowerCase().trim()
      const matchTitle = tpl.title.toLowerCase().includes(q)
      const matchDesc = tpl.description.toLowerCase().includes(q)
      const matchCode = tpl.code.toLowerCase().includes(q)
      if (!matchTitle && !matchDesc && !matchCode) return false
    }
    if (useCaseFilter !== 'ALL' && tpl.useCase !== useCaseFilter) {
      return false
    }
    return true
  })

  const renderBadge = (useCase: string) => {
    switch (useCase) {
      case 'WORKOUT_ENGINE':
        return (
          <span className="px-2 py-0.5 rounded text-[11px] font-mono font-bold bg-[#9b7bff]/15 text-[#9b7bff] border border-[#9b7bff]/30 uppercase tracking-wide">
            WORKOUT_ENGINE
          </span>
        )
      case 'NUTRITION_ENGINE':
        return (
          <span className="px-2 py-0.5 rounded text-[11px] font-mono font-bold bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/30 uppercase tracking-wide">
            NUTRITION_ENGINE
          </span>
        )
      case 'CHAT_COACH':
        return (
          <span className="px-2 py-0.5 rounded text-[11px] font-mono font-bold bg-[#4f28ae]/30 text-[#cdbdff] border border-[#4f28ae] uppercase tracking-wide">
            CHAT_COACH
          </span>
        )
      case 'SAFETY_FILTER':
        return (
          <span className="px-2 py-0.5 rounded text-[11px] font-mono font-bold bg-[#ff506d]/20 text-[#ff506d] border border-[#ff506d]/30 uppercase tracking-wide">
            SAFETY_FILTER
          </span>
        )
      default:
        return null
    }
  }

  const renderStatus = (status: string) => {
    if (status === 'production') {
      return (
        <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-xs font-semibold bg-[#35c76f]/15 text-[#35c76f] border border-[#35c76f]/30">
          <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
          Production Active
        </span>
      )
    }
    if (status === 'review') {
      return (
        <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-xs font-semibold bg-[#f4b740]/15 text-[#f4b740] border border-[#f4b740]/30">
          <span className="w-1.5 h-1.5 rounded-full bg-[#f4b740]" />
          Review Pending
        </span>
      )
    }
    return (
      <span className="inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-xs font-semibold bg-[#222327] text-[#8a8d93] border border-[#34363b]">
        Draft
      </span>
    )
  }

  return (
    <div className="flex flex-col gap-4">
      {/* Search & Filter Controls */}
      <div className="flex flex-col gap-2.5 p-3.5 rounded-xl bg-[#17181b] border border-[#292a2f]">
        <div className="relative w-full">
          <span className="material-symbols-outlined absolute left-3 top-2.5 text-[#8a8d93] text-lg pointer-events-none">
            search
          </span>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Tìm kiếm prompt, use case..."
            className="w-full h-10 pl-9 pr-3 rounded-lg bg-[#222327] border border-[#292a2f] text-[#f5f5f6] placeholder:text-[#8a8d93] text-sm focus:outline-none focus:border-[#ff506d] transition-colors"
          />
        </div>
        <div className="flex items-center gap-2">
          <select
            value={useCaseFilter}
            onChange={(e) => setUseCaseFilter(e.target.value)}
            className="w-full h-9 px-3 rounded-lg bg-[#222327] border border-[#292a2f] text-[#a7a9ae] text-xs focus:outline-none focus:border-[#ff506d] cursor-pointer"
          >
            <option value="ALL">Tất cả use case</option>
            <option value="WORKOUT_ENGINE">Workout Planner</option>
            <option value="NUTRITION_ENGINE">Meal Planner</option>
            <option value="CHAT_COACH">AI Coach / Chat</option>
            <option value="SAFETY_FILTER">Safety Guardrail</option>
          </select>
          {useCaseFilter !== 'ALL' && (
            <button
              type="button"
              onClick={() => {
                setUseCaseFilter('ALL')
                setSearch('')
              }}
              className="h-9 px-2.5 rounded-lg bg-[#222327] border border-[#292a2f] hover:border-[#34363b] text-[#8a8d93] hover:text-[#f5f5f6] flex items-center justify-center transition-colors cursor-pointer"
              title="Đặt lại bộ lọc"
            >
              <span className="material-symbols-outlined text-sm">filter_alt_off</span>
            </button>
          )}
        </div>
      </div>

      {/* Template Cards List */}
      <div className="flex flex-col gap-3">
        {filtered.map((tpl) => {
          const isSelected = selectedTemplateId === tpl.id
          return (
            <div
              key={tpl.id}
              onClick={() => onSelectTemplate(tpl)}
              className={`p-4 rounded-xl border relative cursor-pointer shadow-sm transition-all duration-150 ${
                isSelected
                  ? 'bg-[#222327] border-2 border-[#ff506d]'
                  : 'bg-[#17181b] border-[#292a2f] hover:border-[#34363b] hover:bg-[#1c1d21]'
              }`}
            >
              {isSelected && <div className="absolute left-0 top-3 bottom-3 w-1 bg-[#f2305a] rounded-r" />}
              <div className="flex items-start justify-between gap-2 mb-2">
                {renderBadge(tpl.useCase)}
                {renderStatus(tpl.status)}
              </div>
              <h2 className="text-[15px] font-bold text-[#f5f5f6] leading-snug">{tpl.title}</h2>
              <p className="text-xs text-[#a7a9ae] mt-1 line-clamp-2">{tpl.description}</p>
              <div className="flex items-center justify-between mt-3 pt-3 border-t border-[#292a2f]/60 text-[11px] text-[#8a8d93]">
                <span className="font-mono text-[#a7a9ae] font-medium">{tpl.version}</span>
                <span>
                  Cập nhật {tpl.updatedAt} bởi {tpl.author}
                </span>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
