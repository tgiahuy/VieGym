import React, { useState } from 'react'
import { BackupSettingsTab } from '../components/BackupSettingsTab'
import { GeneralSettingsTab } from '../components/GeneralSettingsTab'
import { NotificationSettingsTab } from '../components/NotificationSettingsTab'
import { SecuritySettingsTab } from '../components/SecuritySettingsTab'
import { StorageSettingsTab } from '../components/StorageSettingsTab'
import { INITIAL_SETTINGS } from '../mockData'
import {
  BackupSettings,
  GeneralSettings,
  NotificationSettings,
  SecuritySettings,
  SettingsTabId,
  StorageSettings,
  SystemSettingsState,
} from '../types'

export const SettingsPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState<SettingsTabId>('general')
  const [settings, setSettings] = useState<SystemSettingsState>(INITIAL_SETTINGS)
  const [isDirty, setIsDirty] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [isBackingUp, setIsBackingUp] = useState(false)
  const [toastMessage, setToastMessage] = useState<string | null>(null)

  const showToast = (msg: string) => {
    setToastMessage(msg)
    setTimeout(() => {
      setToastMessage(null)
    }, 3200)
  }

  const handleUpdateGeneral = (fields: Partial<GeneralSettings>) => {
    setSettings((prev) => ({
      ...prev,
      general: { ...prev.general, ...fields },
    }))
    setIsDirty(true)
  }

  const handleUpdateSecurity = (fields: Partial<SecuritySettings>) => {
    setSettings((prev) => ({
      ...prev,
      security: { ...prev.security, ...fields },
    }))
    setIsDirty(true)
  }

  const handleUpdateStorage = (fields: Partial<StorageSettings>) => {
    setSettings((prev) => ({
      ...prev,
      storage: { ...prev.storage, ...fields },
    }))
    setIsDirty(true)
  }

  const handleUpdateNotifications = (fields: Partial<NotificationSettings>) => {
    setSettings((prev) => ({
      ...prev,
      notifications: { ...prev.notifications, ...fields },
    }))
    setIsDirty(true)
  }

  const handleUpdateBackup = (fields: Partial<BackupSettings>) => {
    setSettings((prev) => ({
      ...prev,
      backup: { ...prev.backup, ...fields },
    }))
    setIsDirty(true)
  }

  const handleSaveAll = () => {
    setIsSaving(true)
    setTimeout(() => {
      setIsSaving(false)
      setIsDirty(false)
      showToast('Đã lưu và áp dụng toàn bộ cấu hình hệ thống thành công!')
    }, 600)
  }

  const handleResetDefaults = () => {
    if (window.confirm('Bạn có chắc chắn muốn khôi phục toàn bộ cài đặt về trạng thái mặc định ban đầu?')) {
      setSettings(INITIAL_SETTINGS)
      setIsDirty(false)
      showToast('Đã khôi phục cài đặt hệ thống về mặc định')
    }
  }

  const handleTestConnection = (serviceName: string) => {
    showToast(`Đang kiểm tra kết nối tới ${serviceName}...`)
    setTimeout(() => {
      showToast(`Kết nối tới ${serviceName} thành công! Độ trễ: 24ms (OK)`)
    }, 900)
  }

  const handleTriggerInstantBackup = () => {
    setIsBackingUp(true)
    setTimeout(() => {
      const now = new Date()
      const timestamp = `${String(now.getDate()).padStart(2, '0')}/${String(
        now.getMonth() + 1
      ).padStart(2, '0')}/${now.getFullYear()} ${String(now.getHours()).padStart(
        2,
        '0'
      )}:${String(now.getMinutes()).padStart(2, '0')}:${String(now.getSeconds()).padStart(2, '0')}`

      const newBackup = {
        id: `bk-${Date.now()}`,
        filename: `viegym_db_manual_${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}${String(now.getDate()).padStart(2, '0')}_instant.sql.gz`,
        size: '1.43 GB',
        createdAt: timestamp,
        type: 'MANUAL' as const,
        status: 'COMPLETED' as const,
      }

      setSettings((prev) => ({
        ...prev,
        backup: {
          ...prev.backup,
          history: [newBackup, ...prev.backup.history],
        },
      }))
      setIsBackingUp(false)
      showToast('Đã tạo và tải lên bản sao lưu thủ công thành công!')
    }, 1500)
  }

  const tabs: { id: SettingsTabId; label: string; icon: string }[] = [
    { id: 'general', label: 'Tổng quan & Thương hiệu', icon: 'domain' },
    { id: 'security', label: 'Bảo mật & Phiên làm việc', icon: 'shield_lock' },
    { id: 'storage', label: 'Lưu trữ CDN & S3', icon: 'cloud_upload' },
    { id: 'notifications', label: 'Thông báo & SMS', icon: 'campaign' },
    { id: 'backup', label: 'Sao lưu & Dữ liệu', icon: 'backup' },
  ]

  return (
    <div className="space-y-6 pb-20">
      {/* Toast Feedback */}
      {toastMessage && (
        <div className="fixed top-20 right-8 z-50 bg-[#222327] border border-[#35c76f]/40 text-[#f5f5f6] px-4 py-3 rounded-xl shadow-2xl flex items-center gap-2.5 animate-fadeIn">
          <span className="material-symbols-outlined text-[#35c76f] text-xl">check_circle</span>
          <span className="text-sm font-medium">{toastMessage}</span>
        </div>
      )}

      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold text-[#f5f5f6] tracking-tight">
            Cấu hình hệ thống
          </h1>
          <p className="text-sm text-[#a7a9ae] mt-1">
            Tùy chỉnh thông số vận hành, kết nối CDN và chính sách bảo mật
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            type="button"
            onClick={handleResetDefaults}
            className="h-11 px-4 rounded-xl bg-[#222327] hover:bg-[#1c1d21] border border-[#292a2f] hover:border-[#34363b] text-[#a7a9ae] hover:text-[#f5f5f6] text-sm font-semibold flex items-center gap-2 transition-all cursor-pointer"
          >
            <span className="material-symbols-outlined text-base">restart_alt</span>
            <span>Khôi phục mặc định</span>
          </button>

          <button
            type="button"
            disabled={isSaving}
            onClick={handleSaveAll}
            className={`h-11 px-5 rounded-xl font-semibold text-sm flex items-center gap-2 shadow-sm transition-all cursor-pointer ${
              isDirty
                ? 'bg-[#f2305a] hover:bg-[#d52b50] active:bg-[#c32649] text-white'
                : 'bg-[#222327] text-[#8a8d93] border border-[#292a2f] hover:text-[#f5f5f6]'
            }`}
          >
            <span className={`material-symbols-outlined text-base ${isSaving ? 'animate-spin' : ''}`}>
              {isSaving ? 'sync' : 'save'}
            </span>
            <span>{isSaving ? 'Đang lưu...' : isDirty ? 'Lưu thay đổi *' : 'Lưu cài đặt'}</span>
          </button>
        </div>
      </div>

      {/* Tab Navigation Strip */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1 border-b border-[#292a2f]">
        {tabs.map((tab) => {
          const isActive = activeTab === tab.id
          return (
            <button
              key={tab.id}
              type="button"
              onClick={() => setActiveTab(tab.id)}
              className={`h-11 px-4 rounded-xl text-sm font-semibold flex items-center gap-2.5 transition-all whitespace-nowrap cursor-pointer ${
                isActive
                  ? 'bg-[rgba(242,48,90,0.12)] text-[#ff506d] border border-[#ff506d]/30 shadow-sm'
                  : 'text-[#8a8d93] hover:text-[#f5f5f6] hover:bg-[#17181b]'
              }`}
            >
              <span className="material-symbols-outlined text-lg">{tab.icon}</span>
              <span>{tab.label}</span>
            </button>
          )
        })}
      </div>

      {/* Tab Content Display */}
      <div>
        {activeTab === 'general' && (
          <GeneralSettingsTab data={settings.general} onChange={handleUpdateGeneral} />
        )}
        {activeTab === 'security' && (
          <SecuritySettingsTab data={settings.security} onChange={handleUpdateSecurity} />
        )}
        {activeTab === 'storage' && (
          <StorageSettingsTab
            data={settings.storage}
            onChange={handleUpdateStorage}
            onTestConnection={handleTestConnection}
          />
        )}
        {activeTab === 'notifications' && (
          <NotificationSettingsTab
            data={settings.notifications}
            onChange={handleUpdateNotifications}
            onTestConnection={handleTestConnection}
          />
        )}
        {activeTab === 'backup' && (
          <BackupSettingsTab
            data={settings.backup}
            onChange={handleUpdateBackup}
            onTriggerInstantBackup={handleTriggerInstantBackup}
            isBackingUp={isBackingUp}
          />
        )}
      </div>
    </div>
  )
}
