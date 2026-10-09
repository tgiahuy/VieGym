import React, { useEffect, useMemo, useState } from 'react'
import { AuditDetailDrawer } from '../components/AuditDetailDrawer'
import { AuditFilterBar } from '../components/AuditFilterBar'
import { AuditTable } from '../components/AuditTable'
import { INITIAL_AUDIT_LOGS } from '../mockData'
import { AuditFilterState, AuditLogItem } from '../types'
import { auditApi } from '../api'

export const AuditLogsPage: React.FC = () => {
  const [logs, setLogs] = useState<AuditLogItem[]>(INITIAL_AUDIT_LOGS)
  const [selectedLogId, setSelectedLogId] = useState<string | undefined>('log-1')
  const [isDrawerOpen, setIsDrawerOpen] = useState(false)
  const [toastMessage, setToastMessage] = useState<string | null>(null)

  useEffect(() => {
    if (import.meta.env.MODE === 'test') return
    auditApi.list().then(setLogs).catch(() => setToastMessage('Không thể tải nhật ký kiểm toán'))
  }, [])

  const showToast = (msg: string) => {
    setToastMessage(msg)
    setTimeout(() => {
      setToastMessage(null)
    }, 3200)
  }

  const [filters, setFilters] = useState<AuditFilterState>({
    dateRange: 'ALL',
    actor: 'ALL',
    action: 'ALL',
    targetType: 'ALL',
    resultStatus: 'ALL',
    search: '',
  })

  const handleFilterChange = (newFilters: Partial<AuditFilterState>) => {
    setFilters((prev) => ({ ...prev, ...newFilters }))
  }

  const handleResetFilters = () => {
    setFilters({
      dateRange: 'ALL',
      actor: 'ALL',
      action: 'ALL',
      targetType: 'ALL',
      resultStatus: 'ALL',
      search: '',
    })
  }

  // Filtered logs
  const filteredLogs = useMemo(() => {
    return logs.filter((log) => {
      // Search matching (target ID or correlation ID or name)
      if (filters.search.trim()) {
        const q = filters.search.toLowerCase().trim()
        const matchTargetId = log.targetId.toLowerCase().includes(q)
        const matchCorrelation = log.correlationId.toLowerCase().includes(q)
        const matchTargetName = log.targetName.toLowerCase().includes(q)
        const matchEventId = log.eventId.toLowerCase().includes(q)
        if (!matchTargetId && !matchCorrelation && !matchTargetName && !matchEventId) {
          return false
        }
      }

      // Actor matching
      if (filters.actor !== 'ALL' && log.actor.role !== filters.actor) {
        return false
      }

      // Action matching
      if (filters.action !== 'ALL' && log.action !== filters.action) {
        return false
      }

      // Target Type matching
      if (filters.targetType !== 'ALL' && log.targetType !== filters.targetType) {
        return false
      }

      // Result Status matching
      if (filters.resultStatus !== 'ALL' && log.resultStatus !== filters.resultStatus) {
        return false
      }

      return true
    })
  }, [logs, filters])

  const selectedLog = useMemo(
    () => logs.find((l) => l.id === selectedLogId) || null,
    [logs, selectedLogId]
  )

  const handleSelectLog = (log: AuditLogItem) => {
    setSelectedLogId(log.id)
    setIsDrawerOpen(true)
  }

  const handleCopyCorrelationId = (id: string) => {
    navigator.clipboard.writeText(id).then(
      () => {
        showToast(`Đã sao chép Correlation ID vào bộ nhớ tạm: ${id}`)
      },
      () => {
        showToast(`Sao chép thất bại`)
      }
    )
  }

  const handleExportCSV = () => {
    const dataStr = JSON.stringify(filteredLogs, null, 2)
    const blob = new Blob([dataStr], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `viegym-audit-logs-${new Date().toISOString().slice(0, 10)}.json`
    link.click()
    URL.revokeObjectURL(url)
    showToast('Đã xuất dữ liệu kiểm toán thành công (.CSV/.JSON)')
  }

  return (
    <div className="space-y-6">
      {/* Toast Feedback */}
      {toastMessage && (
        <div className="fixed top-20 right-8 z-50 bg-[#222327] border border-[#35c76f]/40 text-[#f5f5f6] px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2.5 animate-fadeIn">
          <span className="material-symbols-outlined text-[#35c76f] text-xl">check_circle</span>
          <span className="text-sm font-medium">{toastMessage}</span>
        </div>
      )}

      {/* Page Header & Immutability Badge */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-2xl sm:text-3xl font-bold text-[#f5f5f6] tracking-tight">
              Nhật ký kiểm toán
            </h1>
            <span className="px-2.5 py-1 rounded-full text-xs font-semibold bg-[#222327] text-[#a7a9ae] border border-[#292a2f] flex items-center gap-1.5">
              <span className="material-symbols-outlined text-xs text-[#4d8dff]">verified_user</span>
              Chuỗi khối bất biến (Append-Only)
            </span>
          </div>
          <p className="text-sm text-[#a7a9ae] mt-1">
            Theo dõi mọi tương tác nhạy cảm, thay đổi dữ liệu và thực thi hệ thống được ghi nhận thời gian thực.
          </p>
        </div>

        {/* Telemetry Summary Cards */}
        <div className="flex items-center gap-3 flex-wrap">
          <div className="px-3.5 py-2 rounded-xl bg-[#17181b] border border-[#292a2f] flex items-center gap-3 shadow-none">
            <span className="material-symbols-outlined text-xl text-[#ff506d]">dataset</span>
            <div className="flex flex-col">
              <span className="text-[11px] text-[#a7a9ae] font-medium uppercase tracking-wider">
                Tổng số sự kiện
              </span>
              <span className="text-base font-bold text-[#f5f5f6] font-mono">14,285</span>
            </div>
          </div>

          <div className="px-3.5 py-2 rounded-xl bg-[#17181b] border border-[#292a2f] flex items-center gap-3 shadow-none">
            <span className="material-symbols-outlined text-xl text-[#35c76f]">check_circle</span>
            <div className="flex flex-col">
              <span className="text-[11px] text-[#a7a9ae] font-medium uppercase tracking-wider">
                Thành công
              </span>
              <span className="text-base font-bold text-[#35c76f] font-mono">14,242</span>
            </div>
          </div>

          <div className="px-3.5 py-2 rounded-xl bg-[#17181b] border border-[#292a2f] flex items-center gap-3 shadow-none">
            <span className="material-symbols-outlined text-xl text-[#f4b740]">warning</span>
            <div className="flex flex-col">
              <span className="text-[11px] text-[#a7a9ae] font-medium uppercase tracking-wider">
                Cảnh báo / Lỗi
              </span>
              <span className="text-base font-bold text-[#f4b740] font-mono">43</span>
            </div>
          </div>

          <div className="px-3.5 py-2 rounded-xl bg-[#17181b] border border-[#292a2f] flex items-center gap-3 shadow-none">
            <span className="material-symbols-outlined text-xl text-[#8a8d93]">schedule</span>
            <div className="flex flex-col">
              <span className="text-[11px] text-[#a7a9ae] font-medium uppercase tracking-wider">
                Chính sách lưu trữ
              </span>
              <span className="text-base font-bold text-[#f5f5f6]">90 Ngày</span>
            </div>
          </div>
        </div>
      </div>

      {/* Filter Bar */}
      <AuditFilterBar
        filters={filters}
        onFilterChange={handleFilterChange}
        onReset={handleResetFilters}
        onExport={handleExportCSV}
      />

      {/* Data Table */}
      <AuditTable
        logs={filteredLogs}
        selectedLogId={selectedLogId}
        onSelectLog={handleSelectLog}
      />

      {/* 760px Detail Slide-Over Drawer */}
      <AuditDetailDrawer
        isOpen={isDrawerOpen}
        log={selectedLog}
        onClose={() => setIsDrawerOpen(false)}
        onCopyCorrelationId={handleCopyCorrelationId}
      />
    </div>
  )
}
