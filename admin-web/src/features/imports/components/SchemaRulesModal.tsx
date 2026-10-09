import React, { useState } from 'react'
import { EXERCISE_SCHEMA_RULES, FOOD_SCHEMA_RULES } from '../mockData'
import { ImportEntityType } from '../types'

interface SchemaRulesModalProps {
  isOpen: boolean
  onClose: () => void
  initialType?: ImportEntityType
}

export const SchemaRulesModal: React.FC<SchemaRulesModalProps> = ({
  isOpen,
  onClose,
  initialType = 'EXERCISE',
}) => {
  const [selectedType, setSelectedType] = useState<ImportEntityType>(initialType)

  if (!isOpen) return null

  const rules = selectedType === 'EXERCISE' ? EXERCISE_SCHEMA_RULES : FOOD_SCHEMA_RULES

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fadeIn">
      <div className="bg-[#17181b] border border-[#292a2f] rounded-2xl w-full max-w-4xl max-h-[85vh] flex flex-col shadow-2xl overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 border-b border-[#292a2f] flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <span className="material-symbols-outlined text-[#35c76f] text-xl">tune</span>
            <h3 className="text-base font-semibold text-[#f5f5f6]">
              Quy tắc Schema &amp; Định dạng dữ liệu chuẩn
            </h3>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="p-1 rounded-lg text-[#8a8d93] hover:text-[#f5f5f6] hover:bg-[#222327] transition-colors"
          >
            <span className="material-symbols-outlined text-xl">close</span>
          </button>
        </div>

        {/* Tab Toggle */}
        <div className="px-6 pt-4 flex gap-2">
          <button
            type="button"
            onClick={() => setSelectedType('EXERCISE')}
            className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all ${
              selectedType === 'EXERCISE'
                ? 'bg-[#ff506d] text-white shadow-md'
                : 'bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6]'
            }`}
          >
            Schema Bài tập (Exercise Catalog)
          </button>
          <button
            type="button"
            onClick={() => setSelectedType('FOOD')}
            className={`px-4 py-2 rounded-xl text-xs font-semibold transition-all ${
              selectedType === 'FOOD'
                ? 'bg-[#2cc7b5] text-[#0f1012] shadow-md'
                : 'bg-[#222327] text-[#a7a9ae] hover:text-[#f5f5f6]'
            }`}
          >
            Schema Thực phẩm &amp; Macro (Food Nutrition)
          </button>
        </div>

        {/* Rules Table */}
        <div className="p-6 overflow-y-auto space-y-4">
          <div className="border border-[#292a2f] rounded-xl overflow-hidden">
            <table className="w-full text-left text-xs">
              <thead className="bg-[#222327] border-b border-[#292a2f] text-[#a7a9ae]">
                <tr>
                  <th className="py-2.5 px-3">Tên trường (Field Key)</th>
                  <th className="py-2.5 px-3">Tên tiếng Việt</th>
                  <th className="py-2.5 px-3">Kiểu dữ liệu</th>
                  <th className="py-2.5 px-3">Bắt buộc</th>
                  <th className="py-2.5 px-3">Mô tả &amp; Giá trị hợp lệ</th>
                  <th className="py-2.5 px-3">Mẫu ví dụ</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#292a2f]">
                {rules.map((rule) => (
                  <tr key={rule.fieldKey} className="hover:bg-[#1c1d21]">
                    <td className="py-3 px-3 font-mono font-semibold text-[#ffb2b8]">
                      {rule.fieldKey}
                    </td>
                    <td className="py-3 px-3 font-medium text-[#f5f5f6]">
                      {rule.fieldNameVi}
                    </td>
                    <td className="py-3 px-3">
                      <span className="px-2 py-0.5 rounded bg-[#222327] text-[11px] font-mono text-[#4d8dff]">
                        {rule.dataType}
                      </span>
                    </td>
                    <td className="py-3 px-3">
                      {rule.required ? (
                        <span className="text-[#ff5a5f] font-semibold">Bắt buộc</span>
                      ) : (
                        <span className="text-[#8a8d93]">Tùy chọn</span>
                      )}
                    </td>
                    <td className="py-3 px-3 text-[#a7a9ae] max-w-xs">
                      <div>{rule.description}</div>
                      {rule.allowedEnums && (
                        <div className="mt-1 flex flex-wrap gap-1">
                          {rule.allowedEnums.map((e) => (
                            <span
                              key={e}
                              className="px-1.5 py-0.2 rounded bg-[#0f1012] border border-[#292a2f] text-[10px] text-[#35c76f] font-mono"
                            >
                              {e}
                            </span>
                          ))}
                        </div>
                      )}
                    </td>
                    <td className="py-3 px-3 font-mono text-[#f5f5f6]">
                      {rule.exampleValue}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-3 border-t border-[#292a2f] flex justify-end">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 rounded-xl bg-[#222327] hover:bg-[#1c1d21] text-xs font-semibold text-[#f5f5f6] transition-colors"
          >
            Đóng
          </button>
        </div>
      </div>
    </div>
  )
}
