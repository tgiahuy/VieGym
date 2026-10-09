export type SettingsTabId = 'general' | 'security' | 'storage' | 'notifications' | 'backup'

export interface GeneralSettings {
  systemName: string
  siteUrl: string
  apiBaseUrl: string
  supportEmail: string
  hotline: string
  timezone: string
  defaultLanguage: 'vi' | 'en'
  maintenanceMode: boolean
  maintenanceMessage: string
}

export interface SecuritySettings {
  jwtExpiryHours: number
  maxLoginAttempts: number
  lockoutDurationMinutes: number
  require2FAForAdmin: boolean
  require2FAForTrainer: boolean
  minPasswordLength: number
  requireSpecialChars: boolean
  allowedCorsOrigins: string
  ipWhitelist: string
}

export interface StorageSettings {
  cdnProvider: 'Cloudflare' | 'AWS S3' | 'Cloudinary' | 'MinIO'
  cdnUrl: string
  s3BucketName: string
  s3Region: string
  accessKeyMasked: string
  maxVideoUploadSizeMb: number
  maxImageUploadSizeMb: number
  allowedVideoFormats: string
  allowedImageFormats: string
  autoOptimizeMedia: boolean
}

export interface NotificationSettings {
  smtpHost: string
  smtpPort: number
  smtpUser: string
  smtpPasswordMasked: string
  senderEmail: string
  senderName: string
  smsProvider: 'Zalo ZNS' | 'Twilio' | 'VietGuys Brandname' | 'None'
  smsApiKeyMasked: string
  telegramBotEnabled: boolean
  telegramChatId: string
  slackWebhookUrl: string
}

export interface BackupHistoryItem {
  id: string
  filename: string
  size: string
  createdAt: string
  type: 'AUTO' | 'MANUAL'
  status: 'COMPLETED' | 'FAILED' | 'IN_PROGRESS'
}

export interface BackupSettings {
  autoBackupEnabled: boolean
  backupFrequency: 'DAILY' | 'WEEKLY' | 'MONTHLY'
  backupTime: string
  retentionDays: number
  auditLogRetentionDays: number
  storageLocation: 'S3_COLD_STORAGE' | 'LOCAL_SERVER' | 'HYBRID'
  history: BackupHistoryItem[]
}

export interface SystemSettingsState {
  general: GeneralSettings
  security: SecuritySettings
  storage: StorageSettings
  notifications: NotificationSettings
  backup: BackupSettings
}
