import React from 'react'
import { ImportHistoryItem } from '../types'

interface ImportHistoryModalProps {
  isOpen: boolean
  onClose: () => void
  historyList: ImportHistoryItem[]
}

export const ImportHistoryModal: React.FC<ImportHistoryModalProps> = ({
  isOpen,
  onClose,
  historyList,
}) => {
  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm animate-fadeIn">
      <div className="bg-[#17181b] border border-[#292a2f] rounded-2xl w-full max-w-3xl max-h-[85vh] flex flex-col shadow-2xl overflow-hidden">
        {/* Header */}
        <div className="px-6 py-4 border-b border-[#292a2f] flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <span className="material-symbols-outlined text-[#ff506d] text-xl">history</span>
            <h3 className="text-base font-semibold text-[#f5f5f6]">
              Lịch sử nhập dữ liệu (Import History)
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

        {/* Content Table */}
        <div className="p-6 overflow-y-auto space-y-4">
          <div className="border border-[#292a2f] rounded-xl overflow-hidden">
            <table className="w-full text-left text-xs">
              <thead className="bg-[#222327] border-b border-[#292a2f] text-[#a7a9ae]">
                <tr>
                  <th className="py-2.5 px-3">Mã mẻ (Batch ID)</th>
                  <th className="py-2.5 px-3">Tên file &amp; Loại</th>
                  <th className="py-2.5 px-3">Kết quả</th>
                  <th className="py-2.5 px-3">Chiến lược</th>
                  <th className="py-2.5 px-3">Người nạp &amp; Thời gian</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#292a2f]">
                {historyList.map((item) => (
                  <tr key={item.id} className="hover:bg-[#1c1d21]">
                    <td className="py-3 px-3 font-mono font-semibold text-[#f5f5f6]">
                      {item.batchId}
                    </td>
                    <td className="py-3 px-3">
                      <div className="flex flex-col">
                        <span className="text-[#f5f5f6] font-mono">{item.fileName}</span>
                        <span className="text-[#8a8d93] text-[11px]">
                          {item.entityType === 'EXERCISE' ? 'Bài tập' : 'Thực phẩm'} · {item.totalRows} dòng
                        </span>
                      </div>
                    </td>
                    <td className="py-3 px-3">
                      <div className="flex items-center gap-1.5">
                        <span
                          className={`inline-block w-2 h-2 rounded-full ${
                            item.status === 'COMPLETED'
                              ? 'bg-[#35c76f]'
                              : item.status === 'PARTIAL'
                                ? 'bg-[#f4b740]'
                                : 'bg-[#ff5a5f]'
                          }`}
                        />
                        <span
                          className={`font-semibold ${
                            item.status === 'COMPLETED'
                              ? 'text-[#35c76f]'
                              : item.status === 'PARTIAL'
                                ? 'text-[#f4b740]'
                                : 'text-[#ff5a5f]'
                          }`}
                        >
                          {item.successCount}/{item.totalRows} thành công
                        </span>
                      </div>
                    </td>
                    <td className="py-3 px-3 font-mono text-[#a7a9ae]">
                      {item.conflictStrategy}
                    </td>
                    <td className="py-3 px-3">
                      <div className="flex flex-col">
                        <span className="text-[#f5f5f6]">{item.importedBy}</span>
                        <span className="text-[#8a8d93] text-[11px]">{item.importedAt}</span>
                      </div>
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
