import React from 'react'
import { BackupSettings } from '../types'

interface BackupSettingsTabProps {
  data: BackupSettings
  onChange: (fields: Partial<BackupSettings>) => void
  onTriggerInstantBackup: () => void
  isBackingUp: boolean
}

export const BackupSettingsTab: React.FC<BackupSettingsTabProps> = ({
  data,
  onChange,
  onTriggerInstantBackup,
  isBackingUp,
}) => {
  return (
    <div className="space-y-6">
      {/* Backup Schedule & Retention Policy */}
      <div className="p-6 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-5">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-[#292a2f]">
          <div>
            <h3 className="text-base font-bold text-[#f5f5f6]">Chính sách Tự động Sao lưu Cơ sở dữ liệu</h3>
            <p className="text-xs text-[#8a8d93] mt-0.5">Sao lưu snapshot toàn bộ CSDL PostgreSQL và dữ liệu nhật ký hệ thống</p>
          </div>
          <button
            type="button"
            disabled={isBackingUp}
            onClick={onTriggerInstantBackup}
            className="px-4 py-2 rounded-xl bg-[#f2305a] hover:bg-[#d52b50] text-xs font-semibold text-white flex items-center gap-2 shadow-sm transition-colors cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed self-start sm:self-auto"
          >
            <span className={`material-symbols-outlined text-base ${isBackingUp ? 'animate-spin' : ''}`}>
              {isBackingUp ? 'sync' : 'backup'}
            </span>
            <span>{isBackingUp ? 'Đang tạo bản sao lưu...' : 'Sao lưu ngay lập tức'}</span>
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-5">
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Tần suất sao lưu định kỳ</label>
            <select
              value={data.backupFrequency}
              onChange={(e) => onChange({ backupFrequency: e.target.value as BackupSettings['backupFrequency'] })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d] cursor-pointer"
            >
              <option value="DAILY">Hàng ngày (Daily snapshot)</option>
              <option value="WEEKLY">Hàng tuần (Chủ nhật hàng tuần)</option>
              <option value="MONTHLY">Hàng tháng (Ngày 01 mỗi tháng)</option>
            </select>
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Thời điểm kích hoạt (Giờ máy chủ)</label>
            <input
              type="time"
              value={data.backupTime}
              onChange={(e) => onChange({ backupTime: e.target.value })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm font-mono text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
          </div>

          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-[#f5f5f6]">Thời gian lưu trữ snapshot (Ngày)</label>
            <input
              type="number"
              min={7}
              max={365}
              value={data.retentionDays}
              onChange={(e) => onChange({ retentionDays: Number(e.target.value) || 7 })}
              className="w-full h-10 px-3.5 rounded-xl bg-[#222327] border border-[#292a2f] text-sm text-[#f5f5f6] focus:outline-none focus:border-[#ff506d]"
            />
          </div>
        </div>
      </div>

      {/* Backup History Table */}
      <div className="p-6 rounded-2xl bg-[#17181b] border border-[#292a2f] space-y-4">
        <div className="flex items-center justify-between pb-3 border-b border-[#292a2f]">
          <div>
            <h3 className="text-base font-bold text-[#f5f5f6]">Lịch sử các bản sao lưu gần nhất</h3>
            <p className="text-xs text-[#8a8d93] mt-0.5">Danh sách các file snapshot đã được đồng bộ an toàn lên S3 Cold Storage</p>
          </div>
          <span className="material-symbols-outlined text-[#35c76f] text-2xl">history</span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="h-10 border-b border-[#292a2f] text-[11px] font-semibold text-[#8a8d93] uppercase tracking-wider">
                <th className="py-2 px-3">TÊN TẬP TIN SNAPSHOT</th>
                <th className="py-2 px-3">DUNG LƯỢNG</th>
                <th className="py-2 px-3">LOẠI</th>
                <th className="py-2 px-3">THỜI ĐIỂM TẠO</th>
                <th className="py-2 px-3 text-right">TRẠNG THÁI</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#292a2f] text-xs">
              {data.history.map((item) => (
                <tr key={item.id} className="h-12 hover:bg-[#222327]/50 transition-colors">
                  <td className="py-2 px-3 font-mono text-[#f5f5f6]">
                    <div className="flex items-center gap-2">
                      <span className="material-symbols-outlined text-sm text-[#8a8d93]">folder_zip</span>
                      <span>{item.filename}</span>
                    </div>
                  </td>
                  <td className="py-2 px-3 font-mono text-[#a7a9ae]">{item.size}</td>
                  <td className="py-2 px-3">
                    <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                      item.type === 'AUTO'
                        ? 'bg-[#4d8dff]/10 text-[#4d8dff] border border-[#4d8dff]/30'
                        : 'bg-[#9b7bff]/10 text-[#9b7bff] border border-[#9b7bff]/30'
                    }`}>
                      {item.type}
                    </span>
                  </td>
                  <td className="py-2 px-3 tabular-nums text-[#a7a9ae]">{item.createdAt}</td>
                  <td className="py-2 px-3 text-right">
                    <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-[11px] font-semibold bg-[#35c76f]/10 text-[#35c76f] border border-[#35c76f]/20">
                      <span className="w-1.5 h-1.5 rounded-full bg-[#35c76f]" />
                      Hoàn thành
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
